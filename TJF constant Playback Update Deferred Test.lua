function Main()

  reaper.Main_OnCommand(40434, 0) --Calls command "View: Move edit cursor to play cursor"  

reaper.defer(Main)
end--Main()

Main()
