--Author: Original Script by BirdBird ... 
--        Minor Tweaks by Tim Farrell


--This is just a proof of concept. May contain bugs


function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

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

function literalize(str)
    return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", function(c) return "%" .. c end)
end

function GetEnvelopeByGUID(track, GUID)
    for j = 1, reaper.CountTrackEnvelopes(track) do
        local envelope = reaper.GetTrackEnvelope(track, j - 1)
        local ret2, envelopeChunk = reaper.GetEnvelopeStateChunk(envelope, "")
        local retval, buf = reaper.GetEnvelopeName( envelope )
                
        if string.match(envelopeChunk, literalize(GUID:sub(2, -2))) then
            return buf,envelope
        end
    end
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
                    envelopeName, envelope = GetEnvelopeByGUID(track, GUID)
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

function SetRazorEdit(track, areaStart, areaEnd, GUID)
    if GUID == nil then GUID = '""' end
    
    --parse area string
    local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
    local str = area ~= nil and area .. ' ' or ''
    str = str .. tostring(areaStart) .. ' ' .. tostring(areaEnd) .. ' ' .. GUID
    
    local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', str, true)
    return ret
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

function RazorEditSelectionExists()
          for i=0, reaper.CountTracks(0)-1 do
              local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then return true end
          end
    return false
    
end--AreaSelectionExists()


--[[
function SetRazorEditToSelectedItems()
    local item = {}
    local itemcount = reaper.CountSelectedMediaItems(0)
    for i = 1, itemcount do item[i] = reaper.GetSelectedMediaItem(0, i-1) end
    
    
     reaper.Main_OnCommand(42409,0) --Razor edit: Enclose media items (will unselect all items)
   
    for i=1, itemcount do reaper.SetMediaItemInfo_Value(item[i], "B_UISEL", 1) end

end--function
]]--



function GetParent(track)
            if      reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH") == 1
            then    return  track
            elseif  reaper.GetTrackDepth(track) > 0 then return reaper.GetParentTrack(track)
            else    return false
            end
end--GetParent()


--Thanks to Embass for the function
function GetChildren(parent)

        if parent then 
        
              local parentdepth = reaper.GetTrackDepth(parent)
              local parentnumber = reaper.GetMediaTrackInfo_Value(parent, "IP_TRACKNUMBER")
              local children = {}
              
              for i=parentnumber, reaper.CountTracks(0)-1 do
                    local track = reaper.GetTrack(0,i)
                    local depth = reaper.GetTrackDepth(track)
                    
                    if depth > parentdepth then
                        table.insert(children, track)
                    else
                        break -- exit loop
                    end
              end--for
              
              return children
        end--if
        
end--GetChildren()
            



--=====SELECTION OPERATIONS=====--
function stateChange(action)
    if string.find(string.lower(action), "razor") or string.find(string.lower(action), "folder")  -- == "Razor edit" or action == "Edit razor edit area" 
    then
        reaper.PreventUIRefresh(1)

        local selections = GetRazorEdits()
        for i = 1, #selections do
            local areaData = selections[i]
            local track = areaData.track
            if not areaData.isEnvelope then
               if reaper.GetToggleCommandState(1156) == 1 then --Checks if ITEM grouping is enabled or bypassed
               track = GetParent(track) end  -- sets track to the track's parent
            
            
                local childTracks = GetChildren(track)
                
                if childTracks then
                    for j = 1, #childTracks do
                        local child = childTracks[j]
                        SetRazorEdit(child, areaData.areaStart, areaData.areaEnd)
                    end--for
                end--if
            end--if
        end--for

        reaper.PreventUIRefresh(-1)
    end
end

--=====<[[ MAIN ]] >=====--
local lastProjectChangeCount = reaper.GetProjectStateChangeCount(0)
function main()
         
          local projectChangeCount = reaper.GetProjectStateChangeCount(0)
          if lastProjectChangeCount < projectChangeCount then
              local action = reaper.Undo_CanUndo2(0)
              action = tostring(action)
              stateChange(action, state)
          end
          lastProjectChangeCount = projectChangeCount
          
          
          
          local state = reaper.GetToggleCommandStateEx(0,({reaper.get_action_context()})[4])
          if RazorEditSelectionExists() then
    
                   local selections = GetRazorEdits()
                   if state == 2 then
                            local items = {}
                            
                            --for i=1, reaper.CountSelectedMediaItems(0) do items[i] = reaper.GetSelectedMediaItem(0,i-1) end
                            --for i=1, #items do reaper.SetMediaItemSelected( items[i], false ) end
                              
                            items = SplitRazorEdits(selections)
                            
                            for i = 1, #items do
                                --local item = items[i]
                                reaper.SetMediaItemSelected(items[i], true)
                                
                                
                            end
                  elseif state == 1 then
                            for i = 1, #selections do
                                local areaData = selections[i]
                                local items = areaData.items
                                for j = 1, #items do reaper.SetMediaItemSelected(items[j], true) end
                                
                            end
                  end--if
                  
          end--if
          
          if state == 1 or state == 2 then reaper.defer(main) end
end


----------------------------------CALL THE SCRIPT


      cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script
      local state = reaper.GetToggleCommandStateEx(0,cmd_id)
      state = state + 1
      
      if state > 2 or state < 0 then state=0 end
      
      if reaper.GetProjectStateChangeCount(0)<4 then state = 1 end
      reaper.ClearConsole()
      reaper.SetToggleCommandState( 0, cmd_id, state)
      reaper.RefreshToolbar2(0, cmd_id)


main()
