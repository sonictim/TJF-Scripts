--[[
@description TJF OPTION Toggle Check Edit Cursor for Protools Style Automation Write and Glide Functions
@version 2.1
@author Tim Farrell
@links
  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml

@about
  # TJF OPTION Toggle Check Edit Cursor for Protools Style Automation Write and Glide Functions

  Simple little Toggle Script that affects the Check Edit Cursor Behavior of my Automation Punch Scripts
  
  --  DISCLAIMER:
  --  This script was written for my own personal use and therefore I offer no support of any kind.
  --  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
  --  I strongly recommend never to run this or any other script I've written for any reason what so ever.
  --  Ignore this advice at your own peril!



@changelog
  v2.1 - initial release (version matches the other scripts)
  
]]--


local cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script
local state = reaper.GetToggleCommandStateEx(0,cmd_id)
   
    if state ~= 1 then
            state = 1
            else
            state = 0
    end

reaper.SetToggleCommandState( 0, cmd_id, state)
reaper.RefreshToolbar2(0, cmd_id)


reaper.defer(function() end) --this prevents undo
