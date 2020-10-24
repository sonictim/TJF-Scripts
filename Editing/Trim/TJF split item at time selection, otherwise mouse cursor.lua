--[[
@description TJF Split Item at Time Selection, otherwise Mouse Cursor
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Split Item at Time Selection, otherwise Mouse Cursor
  Will also not split if no item is selected.
  Mimics "B" in protools
--]]

reaper.Undo_BeginBlock()

start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
curpos =  reaper.GetCursorPosition()
itemcount = reaper.CountSelectedMediaItems(0)

item = {}



if start_time ~= end_time then -- if there is a time selection
  reaper.Main_OnCommand(40061, 0)

  else

  if itemcount > 0 then  --if there are items selected


                  for i = 1, itemcount do item[i] = reaper.GetSelectedMediaItem(0, i-1) end  --fill item array with first set of items

                  for i = 1, itemcount do


                      item_start = reaper.GetMediaItemInfo_Value(item[i], "D_POSITION")
                      item_end = item_start + reaper.GetMediaItemInfo_Value(item[i], "D_LENGTH")

                      if curpos > item_start and curpos < item_end then

                          reaper.Main_OnCommand(40757, 0)  -- Split items at edit cursor

                      else

                          reaper.Main_OnCommand(40746, 0) --split item at mouse cursor


                      end--if


                   end--for
  else

    reaper.Main_OnCommand(40746, 0) --split item at mouse cursor


  end--if

end--if

reaper.Undo_EndBlock("Split item at cursor or Time Selection", -1)
