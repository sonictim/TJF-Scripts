--@description TJF LINK Razor Edit Selection with Folders, Item Grouping Affects Behavior (reapack test)
--@version 2.0
--@author BirdBird, Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml

--@about
--   # TJF LINK Razor Edit Selection with Folders, Item Grouping Affects Behavior (reapack test)
--
--   This script takes a proof of concept script written by BirdBird and applies a little extra functionality
--   Namely, if grouping is enabled, the script will select all children track
--   If not, Razor edit will behave as normal, except on folder parents... then it will select children also
--   This is a deferred script.  Choose "Terminate" upon running a second time...
--  
--   This script may contain bugs as it is a proof of concept


--   DISCLAIMER:
--   This script was written for my own personal use and therefore I offer no support of any kind.
--   Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--   I strongly recommend never to run this or any other script I've written for any reason what so ever.
--   Ignore this advice at your own peril!
  

--@changelog
--   v1.0 - nothing to report
--   v1.1 - added to reapack (adjusted headers
--   v1.11- reapack test
--   v2.0 - reapack test
    
    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end


    --[[------------------------------[[---
                    FUNCTIONS              
    ---]]------------------------------]]-- 

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
    if string.find(string.lower(action), "razor")-- == "Razor edit" or action == "Edit razor edit area" 
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
                    end
                end--if
            end
        end

        reaper.PreventUIRefresh(-1)
    end
end

    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--

--=====MAIN=====--
local lastProjectChangeCount = reaper.GetProjectStateChangeCount(0)
function main()

    --if reaper.GetToggleCommandState(1156) == 1 then  -- Checks if ITEM grouping is enabled or bypassed
          local projectChangeCount = reaper.GetProjectStateChangeCount(0)
          if lastProjectChangeCount < projectChangeCount then
              local action = reaper.Undo_CanUndo2(0)
              action = tostring(action)
              stateChange(action)
          end
      
          lastProjectChangeCount = projectChangeCount
    --end--if
          
    reaper.defer(main)
end



    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

main()
