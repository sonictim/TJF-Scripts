function Main()
  
  local x,y = reaper.GetMousePosition()
  local retval, info = reaper.GetThingFromPoint( x, y )
  reaper.ClearConsole()
  reaper.ShowConsoleMsg(info)
  reaper.ShowConsoleMsg( reaper.GetProjectStateChangeCount(0))
  
  if (info == "arrange") then reaper.Main_OnCommand(40513, 0) end -- move edit cursor to mouse
  
  
  if reaper.GetPlayState() then reaper.Main_OnCommand(40434, 0) end --Calls command "View: Move edit cursor to play cursor"  

reaper.defer(Main)
end--Main()

Main()
