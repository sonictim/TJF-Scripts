----------------------------------DEBUG FUNCTIONS

--reaper.ClearConsole()

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

function take(param) return reaper.GetActiveTake(items[param]) end  --can call take function to match take to item
    
----------------------------------SET GLOBAL VARIABLES

local lastProjectChangeCount = 0

----------------------------------SET COMMON FUNCTIONS

function CreateNewEnv(chunkname)
local EnvChunk = chunkname .. [[

EGUID ]]..reaper.genGuid("")..[[
ACT 1 -1
VIS 1 0 1
LANEHEIGHT 0 0
ARM 1
DEFSHAPE 0 -1 -1
VOLTYPE 1
PT 0 1 0
>
]]

return EnvChunk

end -- CreateNewTrimEnv()



function ProcessTrack(track, bool)

            local _,  str = reaper.GetTrackStateChunk(track, "", false )
                      
            local     TrimEnv = string.match(str, "<VOLENV3.->")      --find the volume envelope
                    
              if      TrimEnv
              then      
                      vis = "\nVIS 0 0 1"
                      if bool then vis = "\nVIS 1 0 1"
                                  --TrimEnv = string.gsub(TrimEnv, "PT.->", "PT 0 1 0\n>")
                      
                      
                      end
                      
                      
                      TrimEnv = string.gsub(TrimEnv, "\nVIS %d %d %d", vis)
                       
                      str = string.gsub(str, "<VOLENV3.->", TrimEnv)
              else          
                      if bool then
                          TrimEnv = string.match(str, "MAINSEND %d %d\n")..CreateNewEnv("<VOLENV3")
                          str = string.gsub(str, "MAINSEND %d %d\n", TrimEnv)
                      end
            end
                      
            reaper.SetTrackStateChunk(track, str, false)
            
end -- ProcessFolder()



function isFolder(track)
            if reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH" ) == 1 then return true
            else return false
            end
end -- isFolder()


    
----------------------------------FUNCTION SETS COMMAND STATE FOR THIS FUNCTION
(function()
  local _, _, sectionId, cmdId = reaper.get_action_context()

  if sectionId ~= -1 then
    reaper.SetToggleCommandState(sectionId, cmdId, 1)
    reaper.RefreshToolbar2(sectionId, cmdId)

    reaper.atexit(function()
      reaper.SetToggleCommandState(sectionId, cmdId, 0)
      reaper.RefreshToolbar2(sectionId, cmdId)
    end)
  end
end)()
    
   


----------------------------------MAIN FUNCTION
function Main()


             reaper.PreventUIRefresh(1)
          
                for i = 0, reaper.CountTracks(0) - 1 do
                      
                    local   track = reaper.GetTrack(0,i)
                    local _, name = reaper.GetTrackName(track)
                      if name == "PIX" then 
                            ProcessTrack(track, false)
                      else
                            ProcessTrack(track, isFolder(track))
                      end
                end
              
              reaper.PreventUIRefresh(-1)
              reaper.UpdateArrange()

end--Main()


reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
