--@description TJF Write Punch all VISIBLE envelopes to Time, RazorEdit, or Item Selection
--@version 2.4
--@author Tim Farrell
--
--@about
--  # TJF Write Punch all VISIBLE envelopes to Time, RazorEdit, or Item Selection
--  Mimic's Protools CMD + /
--  Will Set all VISIBLE TakeFX Envelopes to Time Selection, Razor Edit Selection or Item Selection
--
--  If the EDIT CURSOR falls within the selection, it will use the VALUE OF THE EDIT CURSOR otherwise, the starting value of the selection
--
--  TIME SELECTION:  if items are selected within the time selection, it will only process selected items
--                   if NO items are selected within the time selection, it will process ALL items
--  DISCLAIMER:
--  This script was written for my own personal use and therefore I offer no support of any kind.
--  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--  I strongly recommend never to run this or any other script I've written for any reason what so ever.
--  Ignore this advice at your own peril!
--
--
--@changelog
--  v1.0 - nothing to report
--  v2.0 - added razor edit support
--       - removed all BR_ENV/SWS functions as they are currently unstable
--  v2.01- added option to disable edit cursor check
--  v2.02- added option to check if envelope is armed.  If unarmed, enevelope will be ignored
--  v2.03- bugfix
--  v2.1 - If Enabled, will write the value at the edit cursor from anywhere in the session
--       - Added Smoothing Parameter to settings
--       - Fixed Logic for Time Selection if NO tracks are selected, then ALL tracks are processed
--       - Bug fixes
--  v2.2 - Added Automation Item Support
--         Known Issues:  Selecting cross the edges of Automation Items doesn't always work as you'd expect
--  v2.3 - Added option to always create 4 points
--  v2.4 - Added support for actively writing envelopes. This is still "in development" and can be disabled via a global variable
--       - Currently will Punch at all actively writing envelopes regardless of razor or item selection  (for now)



--[[------------------------------[[--
               SETTINGS         
--]]------------------------------]]--

      CheckEditCursor = true
--    IF TRUE, this will check if the edit cursor falls within the range of time/razor selection...
--      It will then use value at the EDIT CURSOR to write with
--    IF FALSE, will simply use the value at the start of the time/razor/item selection  ]]--
--    v2.1 adds the option of a helper script. The setting of this script will override this variable.
--      Delete the helper script if you want to set this variable in this script

      
      
      CheckArmed = false
--    If TRUE will only process an envelope if it is armed
--    If FALSE will process the envelopes no matter what    ]]--


      Smoothing = .01
--    Value in seconds of smoothing to adjust to the punch value


      AlwaysCreate4Points = false
--    If true, will always create 4 envelope points instead of 2


      AlsoPunchActivelyWritingEnvelopes = true
--    If true, will also punch actively writing envelopes for all tracks  
      

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
        str = string.match(str, "\nVIS %d")
        str = string.match(str, "%d")
        if str=="1" then return true else return false end

    end
 
end--CheckEnvelope()

function GetAutoItems(envelope, starttime, endtime)
     local AutoItems = {}
     local AutoItemCount = reaper.CountAutomationItems(envelope)
     local flag = true
     
     if AutoItemCount > 0 then
     
        for i=0, AutoItemCount-1 do
        
            local istart =  reaper.GetSetAutomationItemInfo( envelope, i, "D_POSITION", 0, false )
            local iend = istart + reaper.GetSetAutomationItemInfo( envelope, i, "D_LENGTH", 0, false )
            
            if      (istart >= starttime and istart < endtime)
                or  (iend > starttime and iend <= endtime)
                or  (istart < starttime and iend > endtime)
            then
                
                if (istart < starttime and iend > endtime) then flag = false end
                table.insert(AutoItems, i)
            end
        
        end
    end
        
    if flag then table.insert(AutoItems, 1, -1) end
     
    return AutoItems
     


end -- GetAutoItems




function ProcessEnvelope(envelope, pointstart, pointend, curpos, value)
    
    if CheckEnvelope(envelope)
    then
        
        
       local samplerate = reaper.GetSetProjectInfo( 0, "PROJECT_SRATE", 0, false ) 
        
       local _, startvalue = reaper.Envelope_Evaluate( envelope, pointstart, samplerate, 0 )
       local _, endvalue = reaper.Envelope_Evaluate( envelope, pointend, samplerate, 0 )
       local _, smoothstart = reaper.Envelope_Evaluate( envelope, pointstart-Smoothing, samplerate, 0 )
       local _, smoothend = reaper.Envelope_Evaluate( envelope, pointend+Smoothing, samplerate, 0 )

       if not value 
       then   
       
              if    CheckEditCursor --and curpos >= pointstart and curpos <= pointend 
              then
                    _, value = reaper.Envelope_Evaluate( envelope, curpos, samplerate, 0 )

              else
                    value = startvalue
              end
       end
       
       AutoItems = GetAutoItems(envelope, pointstart, pointend)
       
       for i=1, #AutoItems do
       
            if AutoItems[i] ~= -1 then
            
                local istart =  reaper.GetSetAutomationItemInfo( envelope, AutoItems[i], "D_POSITION", 0, false )
                local iend = istart + reaper.GetSetAutomationItemInfo( envelope, AutoItems[i], "D_LENGTH", 0, false )
                
                if istart > pointstart then pointstart = istart end
                if iend < pointend then pointend = iend end
            
            end
       
           reaper.DeleteEnvelopePointRangeEx( envelope, AutoItems[i], pointstart-Smoothing, pointend+Smoothing )
           reaper.InsertEnvelopePointEx( envelope,  AutoItems[i], pointstart, value, 0, 1, 0, true )
           reaper.InsertEnvelopePointEx( envelope, AutoItems[i], pointend, value, 0, 1, 0, true )
           
           if value ~= startvalue or #AutoItems > 1 or AlwaysCreate4Points
           then
              reaper.InsertEnvelopePointEx( envelope, AutoItems[i], pointstart-Smoothing, smoothstart, 0, 1, 0, true )
           end
           
           
           if   value ~= endvalue or #AutoItems > 1 or AlwaysCreate4Points
           then
                reaper.InsertEnvelopePointEx( envelope, AutoItems[i], pointend+Smoothing, smoothend, 0, 1, 0, true )    
           end
           
          reaper.Envelope_SortPointsEx( envelope, AutoItems[i] )
       end
      
       
   
   end--if

end--ProcessEnvelope



function ProcessItemEnvelopes(items, starttime, endtime, curpos, value)  -- 

      CheckArmed = false  -- item envelopes do not have an armed option and must not be checked (technically, they are set to unarmed, so they wont process)

      for i=1, #items do  -- iterate for items
      
                  local item = items[i]
                  local itemstart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                  local itemlen = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                  local itemend = itemstart + itemlen
                  
                  if curpos < itemstart then curpos = itemstart
                  elseif curpos > itemend then curpos = itemend - Smoothing
                  end
                  
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

      local cmd_id = reaper.NamedCommandLookup("_RSef4e379475418f119f753ec5962d3ae4abe84c8e")
      if cmd_id ~= 0 then
      
          local state = reaper.GetToggleCommandStateEx(0,cmd_id)
          if state == 1 then 
              CheckEditCursor = true
          else
              CheckEditCursor = false
          end
      end

      local curpos = reaper.GetCursorPosition(0)
      
                            
                            
                            -----FIRST PRIORITY: LOGIC AND PROCESSING FOR TIME SELECTION
      
      local starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
      
      if starttime ~= endtime
      then   -- if there is a time selection, process all selected tracks/track envelopes according to time selected
         
          local tracks = {}
          local items = {}                                -- Create 2 table.  items = items that fall within the time selection
          local selitems = {}                             --                  selitems = items that fall within the time seleciton that are also selected
          
          
          if reaper.CountSelectedTracks(0) > 0 then 
                for i=1, reaper.CountSelectedTracks(0) do
                         tracks[i] = reaper.GetSelectedTrack(0,i-1)
                end
          else
                for i=1, reaper.CountTracks(0) do
                         tracks[i] = reaper.GetTrack(0, i-1)
                end
          end
          
          for i=1, #tracks do
              local track =  tracks[i]
              
              for j=0,  reaper.CountTrackMediaItems(track)-1 do         -- Go through each track and figure out if any items should be processed
              
                    local item = reaper.GetTrackMediaItem(track,j)
                    local itemstart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION")
                    local itemend = itemstart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH")
                    
                    if      (itemstart < starttime and itemend > starttime)
                        or  (itemend > endtime and itemstart < endtime)
                        or  (itemstart >= starttime and itemend <=endtime)
                            -- logic for deciding which items fall within the time selection
                    
                    then
                          table.insert(items, item)                             -- fill the table
                          if    reaper.IsMediaItemSelected( item )
                          then
                                table.insert(selitems, item)
                          end--if
                    end--if
      
              end--for
              
              
              for j=0, reaper.CountTrackEnvelopes(track)-1 do         -- process all track envelopes
                   ProcessEnvelope( reaper.GetTrackEnvelope( track, j ), starttime, endtime, curpos)
              end--for j
          end--for i
          
          if      #selitems > 0                                   -- if there are selected items, process them
          then  
                  ProcessItemEnvelopes(selitems, starttime, endtime, curpos)
                  
          elseif  #items > 0                                      -- if no items are selected, process ALL items that fall within the time selection
          then
                  ProcessItemEnvelopes(items, starttime, endtime, curpos)
          end
          
          if AlsoPunchActivelyWritingEnvelopes then reaper.Main_OnCommand(42013, 0) end -- Automation: Write current values for actively-writing envelopes to time selection
      
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
                
                if AlsoPunchActivelyWritingEnvelopes then
                    reaper.GetSet_LoopTimeRange2( 0, true, false, areaData.areaStart, areaData.areaEnd, false )
                    reaper.Main_OnCommand(42013, 0) -- Automation: Write current values for actively-writing envelopes to time selection
                end
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
                        
                        if AlsoPunchActivelyWritingEnvelopes then
                              reaper.GetSet_LoopTimeRange2( 0, true, false, itemstart, itemend, false )
                              reaper.Main_OnCommand(42013, 0) -- Automation: Write current values for actively-writing envelopes to time selection
                        end
                        
                        
              end--for i
              
              ---------------------------------------------------ITERATE THROUGH TAKE ENVELOPES
              
              ProcessItemEnvelopes(items, 1, 1, curpos)
      
      end--if
      
    
    
    if AlsoPunchActivelyWritingEnvelopes then
      reaper.GetSet_LoopTimeRange2( 0, true, false, starttime, endtime, false )
      
      local mode =  reaper.GetGlobalAutomationOverride()
      reaper.SetGlobalAutomationOverride( 1 )
      reaper.SetGlobalAutomationOverride( mode )

    end
      
      
end--Main()



--[[------------------------------[[--
           CALL THE SCRIPT          
--]]------------------------------]]--


reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("TJF Punch Visible Envelopes",0)
reaper.UpdateArrange()
