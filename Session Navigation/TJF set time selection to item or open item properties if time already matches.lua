--[[
@description TJF Set Time Selection to Items, or Open Item Properties if Time is already set
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
    # TJF Set Time Selection to Items, or Open Item Propeties if Time is already setTJF Toggle Volume Envelope Visible for Track or Items
  This is meant to be used as a mouse modifyer for double click on an item.
  Often what results is a "triple click" is required to open item properties
--]]


function Main()

item = reaper.GetSelectedMediaItem(0, 0)

if item ~= nil then  -- If no Item is selected, skip this

    item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    item_end = item_start + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    time_start, time_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds

    if item_start == time_start and item_end == time_end

      then

          reaper.Main_OnCommand(41589, 0) --

      else

          reaper.Main_OnCommand(40290, 0) -- Set Time Selection to Items

    end

end

end  --end Main()

Main()
reaper.UpdateArrange()

reaper.defer(function() end) --this prevents undo
