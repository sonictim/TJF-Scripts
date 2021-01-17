--@noindex
--  NoIndex: false
--@description TJF Move Razor Edit Selection to New Subproject
--@version 0.1
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Move Razor Edit Selection to New Subproject
--
--  Will Prompt for a new Subproject name and MOVE your current razor edits to the newsubproject.
--  Destination Subproject behavior is different.  Items will be at the same timecode as original project.
--  If no razor selection is visible, no action will be taken
--  
--  Editable Options:
--    Ability to Copy a Video Track along with Items - ENABLED by default
--    Option to Choose what is in view when scripts completes - Original Project is Default setting
--    
--    
--  DISCLAIMER:
--  This script was written for my own personal use and therefore I offer no support of any kind.
--  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--  I strongly recommend never to run this or any other script I've written for any reason what so ever.
--  Ignore this advice at your own peril!
--  
--@changelog
--  v0.1 - initial version nothing to report




    --[[------------------------------[[---
           GLOBAL SETTINGS VARIABLES               
    ---]]------------------------------]]--

CopyVideo = true  --  If true, script will look for any tracks with the name VIDEO or PIX (case insensitive) and copy them along with your selected media
EndInSubproject = true -- If true, script will complete with the subproject tab selected.  If true, the original project will be selected 



    --[[------------------------------[[---
                    FUNCTIONS              
    ---]]------------------------------]]--    
 
 function CountProjects() -- Returns Number of Projects Currently open in Tabs
 
      local projIdx = 0
      local proj = ""
       
      while proj ~= nil
      do
            projIdx = projIdx + 1
            proj, _ = reaper.EnumProjects( projIdx, "" )
      end
             
      return projIdx
 
 end




    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()


                          --==//[[    DECLARE VARIABLES   ]]\\==--
      local startPos=nil  --will eventually be the subproject Start Time
      local endPos=nil    --will eventually be the subproject End Time
      local video=0       --Keeps track of how many video tracks are copied
      
      local tracks = {}   --Table will be filled with 
      
      local source_proj, source_proj_fn = reaper.EnumProjects( -1, "" )                                    -- Get the Current Project's Project info
      local source_start, source_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)          -- Get current start and end time selection value in seconds of current project

      
      
                        --==//[[    GET SOURCE TRACK AND RAZOR EDIT DATA   ]]\\==--
      for i=1, reaper.CountTracks(0)                                                                       -- Cycle through each track and check to see if anything needs processing
      do
            local track = reaper.GetTrack(0,i-1)
            
            if    CopyVideo                                                                                -- Copy Video Tracks (if option is enabled)
            then
                  local _, name = reaper.GetTrackName( track )
                  if    string.upper(name) == "VIDEO" or string.upper(name) == PIX 
                  then
                      local _, str = reaper.GetTrackStateChunk( track, "", false )
                      table.insert(tracks, str)
                      video = video + 1
                  end
            end
           
           
           local  _, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)           -- get track razor edit info
          
           if     area ~= ''                                                                               -- if track contains a razor edit, parse and process it
           then
                  -- PARSE STRING to table--
                  local areaStr = {}
                  
                  for   j in string.gmatch(area, "%S+")
                  do
                        table.insert(areaStr, j)
                  end
                  
                  -- PROCESS AREA DATA in table
                  local j = 1
                  while j <= #areaStr 
                  do
                      local areaStart = tonumber(areaStr[j])
                      local areaEnd = tonumber(areaStr[j+1])
                      if startPos==nil or areaStart < startPos then  startPos = areaStart end             -- Logic for finding Start Position of subproject
                      if endPos == nil or areaEnd > endPos then endPos = areaEnd end                      -- Logic for finding  End  Position of subproject
                      j = j + 3
                  end
                  
                  local _, str = reaper.GetTrackStateChunk( track, "", false )                            -- get all track info via chunk
                  str =  string.gsub(str, "<ITEM.+>", "")                                                 -- remove all items from track chunk leaving empty tracks with envelope information intact
                  
                  table.insert(tracks, str)
            end
              
      end
      
                      --==//[[   CREATE SUBPROJECT AND MOVE ITEMS TO NEW SUBPROJECT   ]]\\==-- 
     
    if       #tracks > video                                                                              -- if the table has been filled
    then  
              reaper.Main_OnCommand(41384, 0)                                                             -- CUT razor edits
              reaper.GetSet_LoopTimeRange2( source_proj, true, false, startPos, endPos, false )           -- set time selection to length of razor edits      
              reaper.Main_OnCommand(41049, 0)                                                             -- insert new subproject
              reaper.GetSet_LoopTimeRange2( source_proj, true, false, source_start, source_end, false )   -- Restore Original Time Selection
              
              
              local dest_proj, dest_proj_fn = reaper.EnumProjects(CountProjects()-1, "" )                 -- get project info for new subproject
              reaper.SelectProjectInstance(dest_proj)                                                     -- switch to destinatin subproject
              
              for i=1, #tracks                                                                            --  Build empty tracks in new subproject --
              do
                  reaper.InsertTrackAtIndex( i-1, true )
                  local track = reaper.GetTrack(0,i-1)
                  reaper.SetTrackStateChunk( track, tracks[i], true )
              end
              
              reaper.SetOnlyTrackSelected( reaper.GetTrack(0,0+video), true )                             -- Select first track to initiate paste
              reaper.SetEditCurPos(startPos, true, true)                                                  -- Set Edit Cursor to start of where items should go
              reaper.Main_OnCommand(42398, 0)                                                             -- Paste Items from source project
               
              reaper.SetProjectMarker( 1, false, startPos, 0, "=START" )                                  -- Adjust Subproject Markers
              reaper.SetProjectMarker( 2, false, endPos, 0, "=END" )
               
              
              --reaper.SelectProjectInstance(source_proj)
              reaper.Main_SaveProject( dest_proj, false )                                                 -- Save Subproject
              
              reaper.SelectProjectInstance(source_proj)
              reaper.Main_OnCommand(40441,0)                                                              -- rebuild peaks for selected items (new subproject)
              
              
              if EndInSubproject then reaper.SelectProjectInstance(dest_proj) end                         -- switch back to subproject if option is enabled
      end

end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
       Main()
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("TJF Move to SubProject", -1)



    
   
