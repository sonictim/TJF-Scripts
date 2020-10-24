--@description TJF LINK Razor Edit with Item Selection
--@version 2.0
--@author Tim Farrell
--
--@about
--  # TJF LINK Razor Edit with Item Selection
--  Runs in Background
--  When enabled will select any items in your razor edit selection
--  This will select the entirety of the item
--  New Secondary Toggle that will split your items and select only the items inside razor edit
--  When running for the first time, run twice and BE SURE to chose START NEW INSTANCE (NOT terminate) for cycle to behave properly
--
--@changelog
--  v1.0 - nothing to report
--  v2.0 - added split functionality and cycle toggle


----------------------------------COMMON FUNCTIONS

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



function RazorEditSelectionExists()
          for i=0, reaper.CountTracks(0)-1 do
              local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then return true end
          end
    return false
    
end--AreaSelectionExists()


   
    
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
    
    reaper.PreventUIRefresh(1)
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
    reaper.PreventUIRefresh(-1)
    
    return areaItems
end



 
----------------------------------MAIN FUNCTION
function Main(state)
    
    --local cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script
    local state = reaper.GetToggleCommandStateEx(0,({reaper.get_action_context()})[4])


    
    if state < 1 or state > 2 then return end
    reaper.PreventUIRefresh(1)
    
          if RazorEditSelectionExists() then

               local selections = GetRazorEdits()
               
               if state == 2 then
                        local items = SplitRazorEdits(selections)
                        for i = 1, #items do
                            --local item = items[i]
                            reaper.SetMediaItemSelected(items[i], true)
                        end
              else
                        for i = 1, #selections do
                            local areaData = selections[i]
                            local items = areaData.items
                            for j = 1, #items do reaper.SetMediaItemSelected(items[j], true) end
                        end
              
              end--if
                
                
                
          end--if
          
    reaper.PreventUIRefresh(-1)
    
 if state == 1 or state == 2 then reaper.defer(Main) end
    
    
end--Main()
    
    



----------------------------------CALL THE SCRIPT


      local cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script
      local state = reaper.GetToggleCommandStateEx(0,cmd_id)
      local state = state + 1
      
      if state > 2 or state < 0 then state=0 end
      
      if reaper.GetProjectStateChangeCount(0)<4 then state = 1 end
      
      reaper.SetToggleCommandState( 0, cmd_id, state)
      reaper.RefreshToolbar2(0, cmd_id)
      
      
      Main()


