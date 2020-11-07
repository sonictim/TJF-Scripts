--[[

@noindex
  NoIndex: false
@description TJF Move Left Edge of Razor Edits to Edit Cursor
@version 1.0
@author Tim Farrell
@links
  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml

@about
  # TJF Move Left Edge of Razor Edits to Edit Cursor

  Title is pretty self explanatory.  Mimics Protools Control Click Behavior


  DISCLAIMER:
  This script was written for my own personal use and therefore I offer no support of any kind.
  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
  I strongly recommend never to run this or any other script I've written for any reason what so ever.
  Ignore this advice at your own peril!
  
  

@changelog
  v1.0 - nothing to report

    
    --[[------------------------------[[---
                  SETTINGS               
    ---]]------------------------------]]--
    
    local OVERWRITE = true
--  If TRUE, then Razor Edits will behave normally and overwrite what they are going to replace
--  If FALSE, then adjusting razor edits will leave what's currently located in the new position in place




    --[[------------------------------[[---
                    FUNCTIONS               
    ---]]------------------------------]]--

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end  -- DEBUG
reaper.ClearConsole()


function CheckItem(item, table)

    for i=1, #table do
    
        if item == table[i] then return false end
    end

    return true

end


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



function GetRazorEditStart()
          local retval = false  
          local position = ""

          for i=0, reaper.CountTracks(0)-1 do
              local _, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then 
                  retval = true
                  x = x:match "%d+.%d+"
                  
                  if position == "" then position = x
                  elseif position > x then position = x
                  end
              
              end
              
          end
          
          return retval, position

end


        --[[------------------------------[[--
                        MAIN          
        --]]------------------------------]]--

function Main()

    local test, position = GetRazorEditStart()

    if    test
    then
          local offset = position - reaper.GetCursorPosition()
          local areas = GetRazorEdits()
          
          reaper.Main_OnCommand(42406,0) -- Remove all Razor Edits
          reaper.Main_OnCommand(40289,0) -- Unselect all items
          
          
          --SET NEW AREAS
          
          for i=1, #areas do
              local atrack = areas[i].track
              local aStart = areas[i].areaStart - offset
              local aEnd = areas[i].areaEnd - offset
              local aguid = areas[i].GUID

              SetRazorEdit(atrack, aStart, aEnd )
          end
          
          --MOVE ITEMS IN ORIGINAL RAZOR EDIT TO NEW POSITION
          
          areas = SplitRazorEdits(areas)  -- returns only the remaining items after splitting them
          
          for i=1, #areas do
          
              position =  reaper.GetMediaItemInfo_Value( areas[i], "D_POSITION" ) - offset
              reaper.SetMediaItemInfo_Value( areas[i], "D_POSITION", position )
          
          end
          
          --Remove Items that are being replaced with Razor Edit
          
          if OVERWRITE then
          
                local clear = SplitRazorEdits(GetRazorEdits())
                
                for i=1, #clear do
                
                    if    CheckItem(clear[i], areas) 
                    then  reaper.DeleteTrackMediaItem(  reaper.GetMediaItem_Track( clear[i] ), clear[i] )
                    end
      
                end
          end
    
    end

end--Main()

        
        --[[------------------------------[[--
                   CALL THE SCRIPT          
        --]]------------------------------]]--


reaper.Undo_BeginBlock()
Main()
reaper.UpdateArrange()
reaper.Undo_EndBlock("Move Razor Edit to Edit Cursor", -1)
