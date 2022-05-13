function Main()
  
  local x,y = reaper.GetMousePosition()
  local retval, info = reaper.GetThingFromPoint( x, y )
  reaper.ClearConsole()
  reaper.ShowConsoleMsg(info)
  
  
  if reaper.GetPlayState() then reaper.Main_OnCommand(40434, 0) end --Calls command "View: Move edit cursor to play cursor"  

reaper.defer(Main)
end--Main()

Main()
