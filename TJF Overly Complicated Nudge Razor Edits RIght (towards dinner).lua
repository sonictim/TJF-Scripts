    
    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--

reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



    --[[------------------------------[[---
                GLOBAL VARIABLES               
    ---]]------------------------------]]--


Nudge = .04166666666     -- positive value moves toward dinner, negative value moves toward breakfast 


    --[[------------------------------[[---
                    FUNCTIONS              
    ---]]------------------------------]]--    
    
    
local function GetRazorEdits()  -- Function Written by BirdBird on reaper forums
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
    
                --get item data
                local items = {}
                if not isEnvelope then
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
                end
    
                local areaData = {
                    areaStart = areaStart,
                    areaEnd = areaEnd,
                    track = track,
                    items = items,
                    isEnvelope = isEnvelope,
                    GUID = GUID
                }
    
                 table.insert(areaMap, areaData)
    
                j = j + 3
            end
        end
    end
    
    return areaMap
end


local function SetRazorEdits(RazorTable)
      
      prevTrack, str = nil, nil
      
      for i=1, #RazorTable
      do
            local build = tostring( RazorTable[i].areaStart .. " " .. RazorTable[i].areaEnd .. " " .. RazorTable[i].GUID)
            if    RazorTable[i].track == prevTrack
            then  str = str .. " " .. build
            else  str = build             
            end
 
            reaper.GetSetMediaTrackInfo_String(RazorTable[i].track, 'P_RAZOREDITS', str, true)
            prevTrack = RazorTable[i].track
      end
end


local function SplitRazorEdits(razorEdits)
    local areaItems = {}
    
    for i = 1, #razorEdits do
        local areaData = razorEdits[i]
        if not areaData.isEnvelope then
            local items = areaData.items
            for j = 1, #items do 
                local item = items[j]
    
  --              --split items 
                local newItem = reaper.SplitMediaItem(item, areaData.areaStart)
                if newItem == nil then
                    reaper.SplitMediaItem(item, areaData.areaEnd)
                    table.insert(areaItems, item)
                else
                    reaper.SplitMediaItem(newItem, areaData.areaEnd)
                    table.insert(areaItems, newItem)
                end
            end
        end
    end
    
    return areaItems
end

local function CleanUpNewItems(t1, t2)

  for k, v in pairs(t1) do
    if v ~= t2[k] then
       reaper.DeleteTrackMediaItem(  reaper.GetMediaItem_Track( v ), v )       
    end
  end
  return true

end



--[[------------------------------[[--
         ENVELOPE FUNCTIONS          
--]]------------------------------]]--


function ProcessPoints(envelope, starttime, endtime )



            reaper.DeleteEnvelopePointRange( envelope, endtime + .0000001, endtime + Nudge )
            
            for i=0, reaper.CountEnvelopePoints( envelope ) -1 do
                    
                    local retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( envelope, i )
                    if time >= starttime and time<= endtime then
                          reaper.SetEnvelopePoint( envelope, i, time + Nudge, value, shape, tension, selected, true )
                    
                    end
            end
            
            reaper.Envelope_SortPoints( envelope )
            

end


function MoveAutoItems(envelope, starttime, endtime)
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
                
                    reaper.GetSetAutomationItemInfo( envelope, i, "D_POSITION", istart + Nudge, true )
            end
        
        end
    end
        
     
end -- GetAutoItems


function  SplitAutoItems( envelope, item, position)

               aiStart = reaper.GetSetAutomationItemInfo( envelope, item, "D_POSITION", 0, false )
               aiLen = reaper.GetSetAutomationItemInfo( envelope, item, "D_LENGTH", 0, false )
               aiEnd = aiStart + aiLen
               aiOffset = reaper.GetSetAutomationItemInfo( envelope, item, "D_STARTOFFS", 0, false )
              
              
              
              if math.abs(aiStart - position) < .0001  then 
                  return item
              
              elseif aiStart < position and aiEnd > position
              then

                   offset = position - aiStart
                   reaper.GetSetAutomationItemInfo( envelope, item, "D_LENGTH", offset, true )
                   
                   local index = reaper.InsertAutomationItem( envelope, reaper.GetSetAutomationItemInfo( envelope, item, "D_POOL_ID", 0, false ), position, aiLen - offset)
                   --reaper.GetSetAutomationItemInfo( envelope, index, "D_LENGTH", aiLen - offset, true )
                   reaper.GetSetAutomationItemInfo( envelope, index, "D_STARTOFFS", aiOffset + offset, true )

                   return index
              
             
              
              end
end




function ProcessAI(envelope, starttime, endtime )

          for i=reaper.CountAutomationItems(envelope)-1, 0, -1 do
                   local retval = SplitAutoItems( envelope, i, endtime)
                   if retval then
                         reaper.GetSetAutomationItemInfo( envelope, retval, "D_POSITION", endtime + Nudge, true )
                         local len = reaper.GetSetAutomationItemInfo( envelope, retval, "D_LENGTH", 0, false )
                         reaper.GetSetAutomationItemInfo( envelope, retval, "D_LENGTH", len - Nudge, true )
                         local offs = reaper.GetSetAutomationItemInfo( envelope, retval, "D_STARTOFFS", 0, false )
                         reaper.GetSetAutomationItemInfo( envelope, retval, "D_STARTOFFS", offs + Nudge, true )
                         
                   end
           end
          
          
          for i=reaper.CountAutomationItems(envelope)-1, 0, -1 do
                  local retval = SplitAutoItems( envelope, i, starttime)
                  if retval then 
                        reaper.GetSetAutomationItemInfo( envelope, retval, "D_POSITION", starttime + Nudge, true )
                        
                  end
          end
          

          for i=reaper.CountAutomationItems(envelope)-1, 0, -1 do
                  local pos = reaper.GetSetAutomationItemInfo( envelope, i, "D_POSITION", 0, false )
                  local len = reaper.GetSetAutomationItemInfo( envelope, i, "D_LENGTH", 0, false )
                  local offset = reaper.GetSetAutomationItemInfo( envelope, i, "D_STARTOFFS", 0, false )
    
                  if pos == endtime then
                          reaper.GetSetAutomationItemInfo( envelope, i, "D_POSITION", pos + Nudge, true )
                          reaper.GetSetAutomationItemInfo( envelope, i, "D_LENGTH", len - Nudge, true )
                          reaper.GetSetAutomationItemInfo( envelope, i, "D_STARTOFFS", offset + Nudge, true )
                  elseif pos == starttime then
                          reaper.GetSetAutomationItemInfo( envelope, i, "D_POSITION", pos + Nudge, true )
                  end
          end


end



    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()

    
    local razor = GetRazorEdits()
    if #razor > 0 then
            local items = SplitRazorEdits(razor)
            local curpos = nil
            
            
            for i=1, #razor
            do
                  if curpos == nil or curpos > razor[i].areaStart then curpos = razor[i].areaStart end
                  
                  
                  if razor[i].isEnvelope
                  then
                      local envelope = reaper.GetTrackEnvelopeByChunkName( razor[i].track, string.gsub(razor[i].GUID, "\"", "" ) )
                      ProcessPoints(envelope, razor[i].areaStart, razor[i].areaEnd )
                      --MoveAutoItems(envelope, razor[i].areaStart, razor[i].areaEnd )
                      ProcessAI(envelope, razor[i].areaStart, razor[i].areaEnd )
                  end
            
                  razor[i].areaStart = razor[i].areaStart + Nudge
                  razor[i].areaEnd = razor[i].areaEnd + Nudge
            end
            
            
            
            for i=1, #items
            do
                  local position =  reaper.GetMediaItemInfo_Value( items[i], "D_POSITION" )
                  reaper.SetMediaItemInfo_Value( items[i], "D_POSITION", position + Nudge )
            end
          
            SetRazorEdits(razor)
            
            CleanUpNewItems(SplitRazorEdits(GetRazorEdits()), items)
            
            reaper.SetEditCurPos2( 0, curpos+Nudge, true, true )
            
            reaper.ApplyNudge(0, 2, 6, 0, Nudge, 0, 0 )  -- nudge edit cursor 1 frame
            
            
            
    else

            reaper.ApplyNudge(0, 2, 0, 18, 1, 0, 0 )  -- nudge item 1 frame
            reaper.Main_OnCommand(41173,0)  --set edit cursor to start of items
    
    end
            
    
    --
    
    

end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
reaper.PreventUIRefresh(-1) -- uncomment only once script works
reaper.UpdateArrange()
reaper.Undo_EndBlock("TJF Nudge Razor Right", -1)


    
  
