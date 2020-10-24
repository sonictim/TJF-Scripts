--[[
@description TJF Reverse Fades with Item
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Reverse fades with item
  Mimics Pro Tools Reverse
  This will also swap your fades when you reverse and item
--]]


function Msg(param)
    reaper.ShowConsoleMsg(tostring(param).."\n")
end



function main()
      itemcount = reaper.CountSelectedMediaItems(0)

      if itemcount then

            for i = 0, itemcount - 1 do   --for each item do

                 item = reaper.GetSelectedMediaItem(0, i)

                    j = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN")
                    reaper.SetMediaItemInfo_Value(item,"D_FADEINLEN", reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN") )
                    reaper.SetMediaItemInfo_Value(item,"D_FADEOUTLEN", j )

                    j = reaper.GetMediaItemInfo_Value(item, "D_FADEINDIR")
                    reaper.SetMediaItemInfo_Value(item,"D_FADEINDIR", reaper.GetMediaItemInfo_Value(item, "D_FADEOUTDIR") )
                    reaper.SetMediaItemInfo_Value(item,"D_FADEOUTDIR", j )

                    j = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO")
                    reaper.SetMediaItemInfo_Value(item,"D_FADEINLEN_AUTO", reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO") )
                    reaper.SetMediaItemInfo_Value(item,"D_FADEOUTLEN_AUTO", j )

                    j = reaper.GetMediaItemInfo_Value(item, "C_FADEINSHAPE")
                    reaper.SetMediaItemInfo_Value(item,"C_FADEINSHAPE", reaper.GetMediaItemInfo_Value(item, "C_FADEOUTSHAPE") )
                    reaper.SetMediaItemInfo_Value(item,"C_FADEOUTSHAPE", j )

             end  --endfor

      end --endif

      reaper.Main_OnCommand(41051, 0)  -- Reverse Takes

end


reaper.Undo_BeginBlock()
reaper.ShowConsoleMsg("")

main()

reaper.UpdateArrange()
reaper.Undo_EndBlock("Reverse Fades with Item", 0)
