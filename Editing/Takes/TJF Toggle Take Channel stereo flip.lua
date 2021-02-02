--[[
@description TJF Toggle Take Channel Stereo Flip
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Toggle Take Channel Stereo Flip
  Will Flip L and R Channels of all selected items
--]]


reaper.Undo_BeginBlock()

local itemcount = reaper.CountSelectedMediaItems(0)

if itemcount > 0 then

      for i=0, itemcount - 1 do

          local item = reaper.GetSelectedMediaItem(0,i)
          local take = reaper.GetActiveTake(item)


          if  reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE") ~= 0 then

              reaper.SetMediaItemTakeInfo_Value( take, "I_CHANMODE", 0)

              else

              reaper.SetMediaItemTakeInfo_Value( take, "I_CHANMODE", 1)

          end--if

      end--for


end--if

reaper.Undo_EndBlock("Toggle Take Channel Stereo Flip",-1)

reaper.UpdateArrange()
