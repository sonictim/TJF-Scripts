--[[
@description TJF Half Speed Playback
@version 1.2
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # Mimics Protools Shift Spacebar
  Will playback session at Half Speed.
  Works in conjunction with TJF Toggle Insertion Follows Playback.

@changelog
  v1.2 Updates to Match TJF Playback

--]]



function halfspeedplayback()  --if temporary play at half speed is executed, it will reset playspeed to 100%

         reaper.CSurf_OnPlayRateChange(.5)
         reaper.SetExtState("playbackrate", "temporary", "yes", 0)

end

function PlaybackStartLogic()  -- Decide where to place the Edit/Playback Cursor before playback

      local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
      
          if start_time ~= end_time then 
                  reaper.Main_OnCommand(40630, 0) -- Move Cursor to start of Time Selection
              else
                  if reaper.GetSelectedMediaItem(0,0) then reaper.Main_OnCommand(41173, 0) end  -- Move Cursor to start of Items
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

      halfspeedplayback()
      PlaybackStartLogic()
      CheckLinkLoopPoints()
      TJFPlayback()

end--main()
        

main()
reaper.defer(function() end) --this prevents undo



