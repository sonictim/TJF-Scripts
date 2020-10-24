--[[
@description TJF Cycle Through Take Channels
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Cycle Through Take Channels
  Will also work multi channel
--]]

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end --Debug Messages

reaper.Undo_BeginBlock()

local itemcount = reaper.CountSelectedMediaItems(0)

if itemcount > 0 then

      for i=0, itemcount - 1 do

          local item = reaper.GetSelectedMediaItem(0,i)
          local take = reaper.GetActiveTake(item)
          local source = reaper.GetMediaItemTake_Source(take)
          local totalchan =  reaper.GetMediaSourceNumChannels( source )
          local chanmode = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")

          if chanmode < 2 then chanmode = 2 end

          chanmode = chanmode + 1

          if chanmode > totalchan+2 then chanmode = 0 end

          reaper.SetMediaItemTakeInfo_Value( take, "I_CHANMODE", chanmode)

      end--for

end--if

reaper.Undo_EndBlock("Cycle Take Channels Individually",-1)

reaper.UpdateArrange()
