function msg(m)
  return reaper.ShowConsoleMsg(tostring(m) .. "\n")
end


function nudge_edit_cursor()
  local is_new_value, filename, sectionID, cmdID, mode, resolution, val = reaper.get_action_context()
  msg(is_new_value)
  msg(mode)
  msg(resolution)
  msg(val)
 
  if val < 0 then -- move START of time selection left by 1 frame
    reaper.Main_OnCommand(40630,0) -- go to time selection start point
    reaper.ApplyNudge(  -- move edit cursor left 1 frame
                        0,    -- ReaProject project
                        2,    -- integer nudgeflag (&1=set to value (otherwise nudge by value), &2=snap)
                        6,    -- 0=position, 1=left trim, 2=left edge, 3=right edge, 4=contents, 5=duplicate, 6=edit cursor
                        18,   -- integer nudgeunits: 0=ms, 1=seconds, 2=grid, 3=256th notes, ..., 15=whole notes, 16=measures.beats (1.15 = 1 measure + 1.5 beats), 17=samples, 18=frames, 19=pixels, 20=item lengths, 21=item selections
                        math.abs(val),    -- value: amount to nudge by, or value to set to
                        true, -- reverse: in nudge mode, nudges left (otherwise ignored)
                        0     -- copies: in nudge duplicate mode, number of copies (otherwise ignored)
                      )
    reaper.Main_OnCommand(40625,0) -- Time Selection: Set start point
    --reaper.Main_OnCommand(40630,0) -- go to time selection start point
  elseif val > 0 then -- move START of time selection left by 1 frame
    reaper.Main_OnCommand(40630,0) -- go to time selection start point
    reaper.ApplyNudge(0, 2, 6, 18, val, false, 0) -- move edit cursor right by 1 frame
    reaper.Main_OnCommand(40625,0) -- Time Selection: Set start point
  end
end

function main()
  nudge_edit_cursor()
end

main()
--reaper.defer(main)
