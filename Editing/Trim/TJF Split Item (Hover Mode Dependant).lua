--[[
@description TJF Split Item at Time Selection, otherwise Mouse Cursor
@version 2.1
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Split Item at Time Selection, otherwise Mouse Cursor
  Will also not split if no item is selected.
  Mimics "B" in protools
  Adds Hover Mode Support
  
--]]

function GetRazorEdits()  -- Function Written by BirdBird on reaper forums
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

function SplitRazorEdits(razorEdits)
    local areaItems = {}
    
    for i = 1, #razorEdits do
        local areaData = razorEdits[i]
        if not areaData.isEnvelope then
            local items = areaData.items
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
        end
    end
    
    
    return areaItems
end


function Main()

local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds

    if start_time ~= end_time   -- if there is a time selection
    then
            reaper.Main_OnCommand(40061, 0) -- Item: Split items at time selection
            return
    end
    
    local razor = GetRazorEdits()
     
     if #razor > 0 then
        SplitRazorEdits(razor)
        return
     end
    
  
    local cmd_id = reaper.NamedCommandLookup("_RS7c63ddf7171c4cad70a2a5aa14943b5188b93d74")  --get ID of Hover Mode
    local state = reaper.GetToggleCommandStateEx(0,cmd_id)  -- get command state
                  
    if  state==0
    then  reaper.Main_OnCommand(40759, 0) -- Item: Split items at edit cursor (select right)
          return
    end
  
                        
    local window, segment, details = reaper.BR_GetMouseCursorContext()
    local item = reaper.BR_GetMouseCursorContext_Item()
                         
     if item then
                            
        if  reaper.IsMediaItemSelected( item )
        then    
            reaper.Main_OnCommand(40748, 0) -- Item: Split item under mouse cursor (select right)
        else
            reaper.Main_OnCommand(40746, 0) -- Item: Split Item under mouse cursor

         end--if
     end
                        
end


reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)    
Main()
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("TJF Split", 0)
