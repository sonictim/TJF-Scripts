--@description TJF Save all open dirty projects
--@version 1.0
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Save all open dirty projects
--
--  Script will check each open project and save only the ones that have had changes and need saving/updating
--  if 'undo/prompt to save' is disabled in preferences, script will not save anything
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


 
 reaper.PreventUIRefresh(1)     
 
      local cur_proj = reaper.EnumProjects( -1)
      
      local projIdx = 0
      local proj, _ = reaper.EnumProjects( projIdx)
      
       
      while proj ~= nil
      do
            if reaper.IsProjectDirty( proj ) > 0 then reaper.Main_SaveProject( proj, false ) end
            
            projIdx = projIdx + 1
            proj, _ = reaper.EnumProjects( projIdx)
      end
      
      reaper.SelectProjectInstance(cur_proj)
      
 reaper.PreventUIRefresh(-1)
