--[[
@description TJF Non Destructive Timeline reverse of Time selection or Items
@version 2.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Non Destructive Timeline Reverse of Time Selection or Items
  Will Reverse either your time selection, or items if none.
  Will also reverse any fades on items also
  
@changelog
  v1.1 speed improvements
  v2.0 Added BASIC Support for Razor Edits (ONLY RECTANGLES FOR NOW)
--]]



function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end  --debug messages

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



function main() --thank you reaper forum
      local item = {}
      local itemcount =  reaper.CountSelectedMediaItems(0)
      local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

      if RazorEditSelectionExists() then
              local selections = GetRazorEdits()
              local item = SplitRazorEdits(selections)
              for i = 1, #item do
                  reaper.SetMediaItemSelected(item[i], true)
              end--for

              start_time = selections[1].areaStart
              end_time = selections[1].areaEnd

          
      elseif start_time ~= end_time then

            reaper.Main_OnCommand(40061, 0)  --split items at time selection

      else

            if itemcount > 0 then

            start_time = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "D_POSITION")
            end_time = start_time + reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0, 0), "D_LENGTH")

             for i = 0, itemcount - 1 do

                 item[i] = reaper.GetSelectedMediaItem(0, i)
                 local item_start = reaper.GetMediaItemInfo_Value(item[i], "D_POSITION")
                 local item_end = item_start + reaper.GetMediaItemInfo_Value(item[i], "D_LENGTH")

                 if item_start < start_time then start_time = item_start end

                 if item_end > end_time then end_time = item_end end

              end--for

              end--if

        end--if



      reaper.Main_OnCommand(41051, 0)  -- Reverse Takes


      for i = 1, itemcount do
        item[i] = reaper.GetSelectedMediaItem(0, i-1)
      end--for

      for i = 1, itemcount do
        local item_pos = reaper.GetMediaItemInfo_Value(item[i], "D_POSITION")
        local item_len = reaper.GetMediaItemInfo_Value(item[i], "D_LENGTH")
        local new_pos = end_time - item_len - item_pos + start_time


        if item_pos >= start_time and item_pos <= end_time then

        reaper.SetMediaItemInfo_Value(item[i],"D_POSITION", new_pos )

                    j = reaper.GetMediaItemInfo_Value(item[i], "D_FADEINLEN")
                    reaper.SetMediaItemInfo_Value(item[i],"D_FADEINLEN", reaper.GetMediaItemInfo_Value(item[i], "D_FADEOUTLEN") )
                    reaper.SetMediaItemInfo_Value(item[i],"D_FADEOUTLEN", j )

                    j = reaper.GetMediaItemInfo_Value(item[i], "D_FADEINDIR")
                    reaper.SetMediaItemInfo_Value(item[i],"D_FADEINDIR", reaper.GetMediaItemInfo_Value(item[i], "D_FADEOUTDIR") )
                    reaper.SetMediaItemInfo_Value(item[i],"D_FADEOUTDIR", j )

                    j = reaper.GetMediaItemInfo_Value(item[i], "D_FADEINLEN_AUTO")
                    reaper.SetMediaItemInfo_Value(item[i],"D_FADEINLEN_AUTO", reaper.GetMediaItemInfo_Value(item[i], "D_FADEOUTLEN_AUTO") )
                    reaper.SetMediaItemInfo_Value(item[i],"D_FADEOUTLEN_AUTO", j )

                    j = reaper.GetMediaItemInfo_Value(item[i], "C_FADEINSHAPE")
                    reaper.SetMediaItemInfo_Value(item[i],"C_FADEINSHAPE", reaper.GetMediaItemInfo_Value(item[i], "C_FADEOUTSHAPE") )
                    reaper.SetMediaItemInfo_Value(item[i],"C_FADEOUTSHAPE", j )



        end--if

      end--for

end--function




reaper.Undo_BeginBlock()
reaper.ShowConsoleMsg("")

main()

reaper.UpdateArrange()
reaper.Undo_EndBlock("Reverse Fades with Items in Time TJF", 0)
