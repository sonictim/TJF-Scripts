--[[
@description TJF Playback that reads "Toggle Insertion Follows Playback"
@version 1.2
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # The Edit cursor will move to playcursor at end of playback depending on setting.
  must be installed in the correct directory to work
  
@changelog

  v1.1 Adding support for Link Loop Selection to Time Selection on Playback script
  
  v1.2 Added Playback Logic based on first Time, then Item selection

--]]


function ResetPlayback()   -- RESET PROJECT PLAYBACK SPEED

    if reaper.GetExtState("playbackrate", "temporary") == "yes" then
         reaper.CSurf_OnPlayRateChange(1)
         reaper.SetExtState("playbackrate", "temporary", "no", 0 )
    end


end--ResetPlayback() 




function PlaybackStartLogic()  -- Decide where to place the Edit/Playback Cursor before playback

      local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
      
          if start_time ~= end_time then 
                  reaper.Main_OnCommand(40630, 0) -- Move Cursor to start of Time Selection
              else
                  --if reaper.GetSelectedMediaItem(0,0) then reaper.Main_OnCommand(41173, 0) end  -- Move Cursor to start of Items
          end--if

end--PlaybackStartLogic()



function CheckLinkLoopPoints()  -- Move loop points to match time selection (useful for REWIRE)

      local cmd_id = reaper.NamedCommandLookup("_RS23f29bf1001455cb1fe89634646ed908a892bb02")  --get ID of Link Time with Loop Points
      local state = reaper.GetToggleCommandStateEx(0,cmd_id)  -- get command state
      
      
      if state == 1 then
          
          reaper.Main_OnCommand(40622,0) --Copy Timeline to Loop Points
      
      end--if

end--CheckLinkLoopPoints()


function TJFPlayback()  -- Playback.. move cursor if state is chosen

      local cmd_id = reaper.NamedCommandLookup("_RS6fdb5644f8ff4e428ccb04d54fc6b071b4d70a29")  --get ID of Insertion follows playback script
      local state = reaper.GetToggleCommandStateEx(0,cmd_id)  -- get command state
      
          if state==1 then
           reaper.Main_OnCommand(40434, 0) --Calls command "View: Move edit cursor to play cursor"
          end
          
      reaper.Main_OnCommand(40044, 0)  --Calls command "Transport: Play/Stop"

end--TJFPlayback


function main()  --  Main

      ResetPlayback()
      PlaybackStartLogic()
      CheckLinkLoopPoints()
      TJFPlayback()

end--main()
        

main()
reaper.defer(function() end) --this prevents undo
