
--SET GLOBAL VARIABLES


--  item = reaper.GetSelectedMediaItem(0, i) 
--   if item == "" then
--        take = reaper.GetActiveTake(item)
--        src = reaper.GetMediaItemTake_Source(take)
--        proj_subproj = reaper.GetSubProjectFromSource( src )
--        item_mute = reaper.GetMediaItemInfo_Value(item, "B_MUTE")
--        item_vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")
--        item_volDB = 20*(math.log(item_vol, 10)) -- this is the math to convert reaper number to DB
--    end
--
  proj = reaper.GetProjectName( 0, 0 )
--  proj_offset = reaper.GetProjectTimeOffset(0, 0 )
    
  curpos =   reaper.GetCursorPosition()
--  starttime = reaper.format_timestr_pos(proj_offset, "string", -1 )
  
--  timecode = reaper.format_timestr_pos(curpos, "", -1 )
--  local timecodeentry = 01:30:30:00
--  timecodefinal = reaper.format_timestr_pos(timecodeentry, "string", 0 )
  
  
--END SET VARIABLES


function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end

script_path = get_script_path()


function Msg(param)
  reaper.ShowConsoleMsg(tostring(param).."\n")
end



function Main()

    Msg("Project = " .. proj)
    Msg("Cursor Pos = " .. curpos)

    Msg("Folder State = " .. reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,0), "I_FOLDERDEPTH"))    
    Msg("Track Height = " .. reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,0), "I_WNDH"))
    Msg("Compact = " .. reaper.GetMediaTrackInfo_Value(reaper.GetSelectedTrack(0,0), "I_FOLDERCOMPACT"))
        
    
    count_sel_item = reaper.CountSelectedMediaItems(0)
  
    for i = 0, count_sel_item - 1 do
    
        Msg("\ni = "..i)
        
        item = reaper.GetSelectedMediaItem(0, i)
        Msg(item)
        item_mute = reaper.GetMediaItemInfo_Value(item, "B_MUTE")
        Msg("Mute = " .. item_mute)
        item_vol = reaper.GetMediaItemInfo_Value(item, "D_VOL")
        item_volDB = 20*(math.log(item_vol, 10)) -- this is the math to convert reaper number to DB
        Msg("Volume = " .. item_volDB .. "Db")
        item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        Msg("Position = " .. item_pos)
        item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        Msg("Length = " .. item_len)
      
    
    end
    
    for i = 0, count_sel_item - 2 do
    
        item = reaper.GetSelectedMediaItem(0, i)
        nextitem = reaper.GetSelectedMediaItem(0, i + 1)
        item_pos  = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        item_end = reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        nextitem_pos = reaper.GetMediaItemInfo_Value(nextitem, "D_POSITION")
        
        if item_pos <= nextitem_pos then
        
            if item_end >= nextitem_pos then
            
              Msg("Overlapping on " .. i)
            end
        end
    end
  
end    


--reaper.SNM_SetDoubleConfigVar('projtimeoffs', timecodefinal)
--reaper.UpdateTimeline()


--Msg("position = "..position)
--Msg(starttime)
--Msg(proj)
--Msg(position)
--Msg( reaper.GetCursorPosition())
--Msg( reaper.GetProjectTimeOffset( 0, 0 ))
  
--   Msg(item_mute)
--    Msg(item_volDB)
--    Msg(proj_offset)
--    Msg(proj_subproj)
--    Msg(proj_extstate)



reaper.ShowConsoleMsg("")
Main()
reaper.UpdateArrange()
