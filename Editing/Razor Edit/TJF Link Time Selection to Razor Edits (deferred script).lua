--@description TJF Link Time Selection to Razor Edits (deferred script)
--@version 1.0
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Link Time Selection to Razor Edits (deferred script)
--
--  Self Explanatory.  Global Variable "isLoop" determines if the time selection is a loop or not
--  For best results, choose "terminate instance" when running a second time to enable toggling on/off
--
--
--  DISCLAIMER:
--  This script was written for my own personal use and therefore I offer no support of any kind.
--  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--  I strongly recommend never to run this or any other script I've written for any reason what so ever.
--  Ignore this advice at your own peril!
--  
--  
--@changelog
--  v1.0 - nothing to report

    --[[------------------------------[[---
                GLOBAL VARIABLES               
    ---]]------------------------------]]--


local isLoop = true
local lastProjectChangeCount = reaper.GetProjectStateChangeCount(0)



    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--

reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



    --[[------------------------------[[---
              Set Time Selection              
    ---]]------------------------------]]-- 


function SetTimeSelectionToRazorEdits()
      
      local startPos=nil
      local endPos=nil
      
      for i=1, reaper.CountTracks(0)                                                                      -- Cycle through each track and check to see if anything needs processing
      do
            local track = reaper.GetTrack(0,i-1)
            
           local  _, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)           -- get track razor edit info
          
           if     area ~= ''                                                                               -- if track contains a razor edit, parse and process it
           then
                  -- PARSE STRING to table--
                  local areaStr = {}
                  
                  for   j in string.gmatch(area, "%S+")
                  do
                        table.insert(areaStr, j)
                  end
                  
                  -- PROCESS AREA DATA in table
                  local j = 1
                  while j <= #areaStr 
                  do
                      local areaStart = tonumber(areaStr[j])
                      local areaEnd = tonumber(areaStr[j+1])
                      if startPos==nil or areaStart < startPos then  startPos = areaStart end             -- Logic for finding Start Position of subproject
                      if endPos == nil or areaEnd > endPos then endPos = areaEnd end                      -- Logic for finding  End  Position of subproject
                      j = j + 3
                  end
                  
            end
              
      end  
      
      if startPos then
      reaper.GetSet_LoopTimeRange2(0, true, isLoop, startPos, endPos, false)
      end


end -- SetTimeSelectionToRazorEdits()




    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--

function Main()
         
          local projectChangeCount = reaper.GetProjectStateChangeCount(0)
          if lastProjectChangeCount < projectChangeCount then
              local action = reaper.Undo_CanUndo2(0)
              action = tostring(action)
              if string.find(string.lower(action), "razor")-- == "Razor edit" or action == "Edit razor edit area" 
              then
                  reaper.PreventUIRefresh(1)
                  SetTimeSelectionToRazorEdits()
                  reaper.PreventUIRefresh(-1)
              end
               
               
               
          end
          lastProjectChangeCount = projectChangeCount
          
          reaper.defer(Main)
end -- Main()



    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
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
    


Main()

