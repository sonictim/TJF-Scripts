
    local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
                                                                        --second false chooses time or loop points
    if start_time == end_time then
    
        reaper.Main_OnCommand(40290,0) -- set time selection to items    
  
    end
