--TEMPLATE FOR VIJAY....  FOR MAKING CUSTOM ON/OFF STATES


--[[ THIS SECTION CHECKS THE TOOLBAR TO SEE IF IT'S ON OR OFF  ]]--

local cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script
local state = reaper.GetToggleCommandStateEx(0,cmd_id)

if    state == 0
then  state = 1    

        --[[ RUN THESE COMMANDS WHEN YOU TURN ON THE SCRIPT (the button lights up) ]]--
        
        reaper.Main_OnCommand(41186, 0)   -- Options: New recording trims existing items behind new recording (tape mode)
        reaper.Main_OnCommand(40927, 0)   -- Options: Enable auto-crossfade on split
        reaper.Main_OnCommand(41118, 0)   -- Options: Enable Auto-crossfades
      --reaper.Main_OnCommand(COMMAND_ID, 0)  -- just replace COMMAND_ID with the command ID from the action list (right click your action and choose Copy Selected Command ID)
    
else  state =0

        --[[ RUN THESE COMMANDS WHEN YOU TURN OFF THE SCRIPT (the button goes dark) ]]--
        
        reaper.Main_OnCommand(41329, 0)  -- Options: New recording creates new media in separate lanes (layers)
        reaper.Main_OnCommand(41119, 0)  -- Options: Disable auto-crossfades
        reaper.Main_OnCommand(40928, 0)  -- Options: Disable auto-crossfade on split


end


--[[ THIS SECTION WILL UPDATE YOUR TOOLBAR ]]--

reaper.SetToggleCommandState( 0, cmd_id, state) 
reaper.RefreshToolbar2(0, cmd_id)

