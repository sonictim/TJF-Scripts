--[[
@description TJF Cycle Through Take Channels (Stereo)
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 05 01
@about
  # TJF Cycle Through Take Channels (Stereo)
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
          --Msg(chanmode)

          if chanmode < 67 then chanmode = 66 end

          chanmode = chanmode + 1

          if chanmode > totalchan+65 then chanmode = 0 end

          reaper.SetMediaItemTakeInfo_Value( take, "I_CHANMODE", chanmode)

      end--for

end--if
reaper.Undo_EndBlock("Cycle Take Channels in Pairs",-1)

reaper.UpdateArrange()
