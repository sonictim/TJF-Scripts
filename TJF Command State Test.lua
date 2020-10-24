--[[
@description TJF 3 part toggle
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # 
  Will create a toggle stage for this function, that my playback script will read.
--]]


local cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script
local script_id = reaper.NamedCommandLookup("_RS05db2fda3ae94e1ae13faef828db7e1e178f478d")
local state = reaper.GetToggleCommandStateEx(0,cmd_id)
 scriptrunning = reaper.GetToggleCommandState(script_id)

state = state + 1

if state == 3 then 
    state=0
    if scriptrunning==1 then reaper.Main_OnCommand(script_id, 0) end
else
    if scriptrunning==0 then reaper.Main_OnCommand(script_id, 0) end 
end


reaper.SetToggleCommandState( 0, cmd_id, state)
reaper.RefreshToolbar2(0, cmd_id)


reaper.defer(function() end) --this prevents undo
