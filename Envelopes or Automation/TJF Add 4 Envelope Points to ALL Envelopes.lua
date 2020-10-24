--@description TJF Add 4 Envelope Points to VISIBLE Envelopes
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Add 4 Envelope Points to VISIBLE Envelopes
--  Will add 2 points at start and end of Time Selection/Razor Edit/ Item selection
--  Script has setting which will check if envelopes are armed.  Initially set to FALSE
--  Requested by Vijay
--
--  If the EDIT CURSOR falls within the selection, it will use the VALUE OF THE EDIT CURSOR as the final point value
--  (you can turn this off in the SETTINGS section of this script)
--
--  TIME SELECTION:  if items are selected within the time selection, it will only process selected items
--                   if NO items are selected within the time selection, it will process ALL items
--
--@changelog
--  v1.0 - nothing to report


--[[------------------------------[[--
               SETTINGS         
--]]------------------------------]]--

      
      CheckArmed = false
--    If true will only process an envelope if it is armed
--    If false will process the envelopes no matter what    ]]--




--[[------------------------------[[--
                DEBUG         
--]]------------------------------]]--

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end
reaper.ClearConsole()




--[[------------------------------[[--
           DECLARE FUNCTIONS          
--]]------------------------------]]--


function RazorEditSelectionExists()
          for i=0, reaper.CountTracks(0)-1 do
              local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then return true end
          end
    return false
    
end--razorEditSelectionExists()

function GetItemsInRange(track, areaStart, areaEnd)
    local items = {}
    local itemCount = reaper.CountTrackMediaItems(track)
    for k = 0, itemCount - 1 do 
        local item = reaper.GetTrackMediaItem(track, k)
        local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        local itemEndPos = pos+length

        --check if item is in area bounds
        if (itemEndPos > areaStart and itemEndPos <= areaEnd) or
            (pos >= areaStart and pos < areaEnd) or
            (pos <= areaStart and itemEndPos >= areaEnd) then
                table.insert(items,item)
        end
    end

    return items
end

function GetEnvelopePointsInRange(envelopeTrack, areaStart, areaEnd)
    local envelopePoints = {}

    for i = 1, reaper.CountEnvelopePoints(envelopeTrack) do
        local retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint(envelopeTrack, i - 1)

        if time >= areaStart and time <= areaEnd then --point is in range
            envelopePoints[#envelopePoints + 1] = {
                id = i-1 ,
                time = time,
                value = value,
                shape = shape,
                tension = tension,
                selected = selected
            }
        end
    end

    return envelopePoints
end

function GetRazorEdits()
    local trackCount = reaper.CountTracks(0)
    local areaMap = {}
    for i = 0, trackCount - 1 do
        local track = reaper.GetTrack(0, i)
        local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
        if area ~= '' then
            --PARSE STRING
            local str = {}
            for j in string.gmatch(area, "%S+") do
                table.insert(str, j)
            end
        
            --FILL AREA DATA
            local j = 1
            while j <= #str do
                --area data
                local areaStart = tonumber(str[j])
                local areaEnd = tonumber(str[j+1])
                local GUID = str[j+2]
                local isEnvelope = GUID ~= '""'

                --get item/envelope data
                local items = {}
                local envelopeName, envelope
                local envelopePoints
                
                if not isEnvelope then
                    items = GetItemsInRange(track, areaStart, areaEnd)
                else
                    envelope = reaper.GetTrackEnvelopeByChunkName(track, GUID:sub(2, -2))
                    local ret, envName = reaper.GetEnvelopeName(envelope)

                    envelopeName = envName
                    envelopePoints = GetEnvelopePointsInRange(envelope, areaStart, areaEnd)
                end

                local areaData = {
                    areaStart = areaStart,
                    areaEnd = areaEnd,
                    
                    track = track,
                    items = items,
                    
                    --envelope data
                    isEnvelope = isEnvelope,
                    envelope = envelope,
                    envelopeName = envelopeName,
                    envelopePoints = envelopePoints,
                    GUID = GUID:sub(2, -2)
                }

                table.insert(areaMap, areaData)

                j = j + 3
            end
        end
    end

    return areaMap
end

function SplitRazorEdits(razorEdits)
    local areaItems = {}
    local tracks = {}
    reaper.PreventUIRefresh(1)
    for i = 1, #razorEdits do
        local areaData = razorEdits[i]
        if not areaData.isEnvelope then
            local items = areaData.items
            
            --recalculate item data for tracks with previous splits
            if tracks[areaData.track] ~= nil then 
                items = GetItemsInRange(areaData.track, areaData.areaStart, areaData.areaEnd)
            end
            
            for j = 1, #items do 
                local item = items[j]
                --split items 
                local newItem = reaper.SplitMediaItem(item, areaData.areaStart)
                if newItem == nil then
                    reaper.SplitMediaItem(item, areaData.areaEnd)
                    table.insert(areaItems, item)
                else
                    reaper.SplitMediaItem(newItem, areaData.areaEnd)
                    table.insert(areaItems, newItem)
                end
            end

            tracks[areaData.track] = 1
        end
    end
    reaper.PreventUIRefresh(-1)
    
    return areaItems
end


--[[------------------------------[[--
         ENVELOPE FUNCTIONS          
--]]------------------------------]]--



function CheckEnvelope(envelope)
    local retval, str = reaper.GetEnvelopeStateChunk( envelope, "", false )
    if retval then
        if    CheckArmed
        then  
              if string.match(str, "\nARM 0") then return false end
        end
        
        --str = string.match(str, "\nVIS %d")
        --str = string.match(str, "%d")
        --if str=="1" then return true else return false end

    end
    
    return true
 
end--CheckEnvelope()


function ProcessEnvelope(envelope, pointstart, pointend, curpos, value)
    
    if CheckEnvelope(envelope)
    then

       local _, startvalue = reaper.Envelope_Evaluate( envelope, pointstart, 48000, 0 )
       local _, endvalue = reaper.Envelope_Evaluate( envelope, pointend, 48000, 0 )

       reaper.InsertEnvelopePoint( envelope, pointstart, startvalue, 0, 1, 0, true )
       reaper.InsertEnvelopePoint( envelope, pointstart, startvalue, 0, 1, 0, true )
       reaper.InsertEnvelopePoint( envelope, pointend, endvalue, 0, 1, 0, true )
       reaper.InsertEnvelopePoint( envelope, pointend, endvalue, 0, 1, 0, true )

       reaper.Envelope_SortPoints( envelope )
   
   end--if

end--ProcessEnvelope



function ProcessItemEnvelopes(items, starttime, endtime, curpos, value)  -- 

      for i=1, #items do  -- iterate for items
      
                  local item = items[i]
                  local itemstart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                  local itemlen = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                  local itemend = itemstart + itemlen
                  
                  curpos = curpos - itemstart
                  
                  local pointstart = starttime - itemstart
                  local pointend = endtime - itemstart
                  
                  if pointstart == pointend then  -- if there is no time selection
                      pointstart  = 0 
                      pointend = itemlen
                  end
                  
                  if itemstart > starttime then pointstart = 0 end  --adjusts bounds for envelope points if items start/end inside of time selection
                  if itemend < endtime then pointend = itemlen end 

                        
                  for j = 0, reaper.CountTakes(item)-1 do
                      local take = reaper.GetTake( item, j )
                      
                      for k=0,  reaper.CountTakeEnvelopes( take )-1 do
                          ProcessEnvelope(reaper.GetTakeEnvelope( take, k), pointstart, pointend, curpos)
                      end--for k
          
                  end--for j
      end--for i
end -- ProcessItems
      


--[[------------------------------[[--
                MAIN          
--]]------------------------------]]--

function Main()

      local curpos = reaper.GetCursorPosition(0)
      
                            
                            
                            -----FIRST PRIORITY: LOGIC AND PROCESSING FOR TIME SELECTION
      
      local starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
      
      if starttime ~= endtime
      then   -- if there is a time selection, process all selected tracks/track envelopes according to time selected
      
          for i=0, reaper.CountSelectedTracks(0)-1 do
              local track =  reaper.GetSelectedTrack(0, i)
              for j=0, reaper.CountTrackEnvelopes(track)-1 do
                   ProcessEnvelope( reaper.GetTrackEnvelope( track, j ), starttime, endtime, curpos)
              end--for j
          end--for i
          
          
          local items = {}                                -- Create 2 table.  items = items that fall within the time selection
          local selitems = {}                             --                  selitems = items that fall within the time seleciton that are also selected
          
          for   i=1, reaper.CountMediaItems(0)
          do
                
                local item = reaper.GetMediaItem(0,i-1)
                local itemstart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION")
                local itemend = itemstart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH")
                
                if    (itemstart <= endtime)   -- logic for deciding which items fall within the time selection
                      or (itemend <= starttime)
                then
                      table.insert(items, item)                             -- fill the table
                      if    reaper.IsMediaItemSelected( item )
                      then
                            table.insert(selitems, item)
                      end--if
                end--if
                
          end--for(i)
          
          if      #selitems > 0                                   -- if there are selected items, process them
          then  
                  ProcessItemEnvelopes(selitems, starttime, endtime, curpos)
                  
          elseif  #items > 0                                      -- if no items are selected, process ALL items that fall within the time selection
          then
                  ProcessItemEnvelopes(items, starttime, endtime, curpos)
          end
          
          
      
                             -----SECOND PRIORITY: LOGIC AND PROCESSING FOR RAZOR EDITS
      
      
      elseif RazorEditSelectionExists()
      then
          
          local selections = GetRazorEdits()            -- returns razor edits in an array by track
          
          for   i = 1, #selections                      --  for each track, process any razor edits on it              
          do
                local areaData = selections[i]
               
                if areaData.isEnvelope == true
                then 
      
                      ProcessEnvelope(areaData.envelope, areaData.areaStart, areaData.areaEnd, curpos)
                end
                      ProcessItemEnvelopes(areaData.items, areaData.areaStart, areaData.areaEnd, curpos)
          end
          
      
      
                              -----THIRD PRIORITY: LOGIC AND PROCESSING FOR ITEM SELECTION
           
      elseif reaper.GetSelectedMediaItem(0,0) then
      
            local items = {}
            
            for i=1, reaper.CountSelectedMediaItems(0) do  -- iterate for items
                              ------------------------------------LOGIC FOR SETTING START AND END POINTS
            
                        items[i] = reaper.GetSelectedMediaItem(0,i-1)
                        local itemstart = reaper.GetMediaItemInfo_Value( items[i], "D_POSITION" )
                        local itemlen = reaper.GetMediaItemInfo_Value( items[i], "D_LENGTH" )
                        local itemend = itemstart + itemlen
                              -----------------------------------ITERATE THROUGH TRACK ENVELOPES                  
                        local track =  reaper.GetMediaItem_Track( items[i] )
                        for j=0, reaper.CountTrackEnvelopes(track)-1 do
                             ProcessEnvelope( reaper.GetTrackEnvelope( track, j ), itemstart, itemend, curpos)
                        end--for j
              
              end--for i
              
              ---------------------------------------------------ITERATE THROUGH TAKE ENVELOPES
              
              ProcessItemEnvelopes(items, 1, 1, curpos)
      
      end--if
end--Main()



--[[------------------------------[[--
           CALL THE SCRIPT          
--]]------------------------------]]--


reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("TJF Punch Visible Envelopes",0)
reaper.UpdateArrange()
