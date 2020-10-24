function Msg(param) reaper.ShowConsoleMsg(param.."\n") end

--footer = "TAKEFX_NCH 6\n>"

reaper.ClearConsole()

function AddPlugin(item)

local fxheader = "<TAKEFX\nWNDRECT 0 0 0 0\nSHOW 0\nLASTSEL 0\nDOCKED 0\n"
local pluginchunk = "BYPASS 0 0 0\n<JS \"TJF/JSFX/TJF Mono to Channel 3 (Center).jsfx\" \"\"\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n>\nFLOATPOS 0 0 0 0\nFXID {30CD82D4-0A65-1E49-9FE4-98EFB486AC68}\nWAK 0 0\n>\n"

 local _, str = reaper.GetItemStateChunk( item, "", false )
 
 str = string.gsub(str, "BYPASS %d %d %d\n<JS \"TJF/JSFX/TJF Mono to Channel 3 %(Center%).jsfx\".-WAK %d %d\n", "") -- removes plugin if it exists
 str = string.gsub(str, "\n>\n>\n", "\n>\n")
 
 local test = string.match(str, "<TAKEFX")
 if test ~= "<TAKEFX" then 
 str = str .. fxheader .. pluginchunk
 reaper.SetItemStateChunk( item, str, false )
 else
      local header = string.match(str, "<ITEM.*WAK %d %d\n")
      local footer = string.match(str, "WAK?.*$") -- get's end of plugin chunk
      if header and footer then
      str = header .. pluginchunk .. footer
      reaper.SetItemStateChunk( item, str, false )
      end
  end
 
end--AddPlugin()
 
 
 
 
 function DeletePlugin(item)
  local _, str = reaper.GetItemStateChunk( item, "", false )

  str = string.gsub(str, "BYPASS %d %d %d\n<JS \"TJF/JSFX/TJF Mono to Channel 3 %(Center%).jsfx\".*WAK %d %d\n", "")
 
  reaper.SetItemStateChunk( item, str, false )
  
 end--DeletePlugin()
  
  
 
 
 
 
 item = reaper.GetSelectedMediaItem(0,0)
AddPlugin(item)
--DeletePlugin(item)
 
 
 reaper.UpdateArrange()
