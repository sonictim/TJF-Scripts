--@description TJF Gridlock (Link Snap and Grid Visibility)
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Gridlock  (Link Snap and Grid Visibility)
--  This will link Snapping and Grid Visibility.
--  If the Grid is Visible, Snapping will be turned on.
--
--@changelog
--  v1.0 - nothing to report



reaper.Main_OnCommand(40145, 0) -- Toggle Grid Lines

state = reaper.GetToggleCommandStateEx(0,40145)  -- get command state of "Options: Toggle Grid Lines"

if state == 1 then

    reaper.Main_OnCommand(40754, 0) -- Enable Snap
    
else

    reaper.Main_OnCommand(40753, 0) -- Disable Snap

end
        
        
        
        

