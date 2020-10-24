--[[
@description TJF Toggle Link Loop Selection to Time Selection on Playback
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 05 08
@about
  # TJF Toggle Link Loop Selection to Time Selection on Playback
  While working with Rewire, will allow to you keep time and loop somewhat linked
  THIS FUNCTION creates a toggle stag that my TJF playback script will read.
--]]


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
