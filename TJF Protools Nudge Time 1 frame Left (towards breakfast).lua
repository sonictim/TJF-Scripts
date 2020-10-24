 --reaper.ApplyNudge( project, nudgeflag, nudgewhat, nudgeunits, value, reverse, copies )
 
-- reaper.Undo_BeginBlock()
 
 reaper.Main_OnCommand(41173,0)  --set edit cursor to start of items
 reaper.ApplyNudge(0, 2, 0, 18, 1, 1, 0 )  -- nudge item 1 frame
 reaper.ApplyNudge(0, 2, 6, 18, 1, 1, 0 )  -- nudge edit cursor 1 frame
 
-- reaper.Undo_EndBlock()
