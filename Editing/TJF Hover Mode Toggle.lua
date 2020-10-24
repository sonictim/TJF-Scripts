--[[
@description TJF Toggle Hover Mode
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # Will Turn "Hover mode" on or off
  Will create a toggle stage for this function, that my trim scripts will read.
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
