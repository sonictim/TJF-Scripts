--@description TJF Export Razor Edit to New Project
--@version 1.0
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Export Razor Edit to New Project 
--
--  Will create a new Project and move your current razor edit selection to this new project.
--  There are various options the user can set that affect how the razor edits are placed in the Destination Project
--  Timecode copy and Video Track Copy are both supported.
--  Option to RENDER AS SUBPROJECT
--  If no razor selection is visible, no action will be taken
--
--  ** REQUIRES SWS extension for complete feature compatibility.  If you are experiencing issues, please make sure you have SWS installed and updated to latest version
--
--  ** Thank you to Edgemeal for helping me solve how to set the project time offset
--  
--  Editable Options:
--    Choose which project (source or subproject) is in view at the completion of the script
--    Close new subproject upon completion of the script
--    Copy all Track info into subproject (master too) or create blank tracks for the move
--    Maintain Relative Positiion and Match Timecode start times in Timeline (will preserve timecode and embed into RPP-PROX)
--    Ability to Copy a Video Track along with Items - ENABLED by default
--    
--    
--  DISCLAIMER:
--  This script was written for my own personal use and therefore I offer no support of any kind.
--  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--  I strongly recommend never to run this or any other script I've written for any reason what so ever.
--  Ignore this advice at your own peril!
--  
--@changelog
--  v1.0 - initial version nothing to report


    --[[------------------------------[[---
           GLOBAL SETTINGS VARIABLES               
    ---]]------------------------------]]--


RenderSubproject = true                   -- If true, script will also render the subproject RPP-PROX.  False will just save as a regular project

EndInSubproject = false                   -- If true, script will complete with the subproject tab selected (similar to reaper default subproject behavior).  If false, the original project will be selected 
CloseSubproject = true                    -- If true, the newly created subproject tab will be closed at the end of the script.  
                                          -- ***NOTE: if EndInSubproject is true, it will override this variable.
                                          
CopyTrackInfo = true                      -- If true, track information from the source tracks (name, color, # of channels, plugins, envelopes,etc) will be copied into the subproject tracks
AlsoCopyMaster = true                     -- If true, will also copy the master track info (#channels, plugins, envelopes) IF CopyTrackInfo is enabled

TimecodeMatch = true                      -- If true, script will adjust the subproject session start time so your moved edits will be placed at the same timecode as the source project.
PreserveRelativeTimelinePosition = false  -- If true, items will be pasted in the subproject equidistant from the project start as they were in the original project.

CopyVideo = true                          -- If true, script will look for any tracks with the name VIDEO or PIX (case insensitive) and copy them along with your selected media
                                          -- ***NOTE: If COPY VIDEO is enabled (TRUE), then if video is found, the PreserveRelativeTimelinePosition and TimecodeMatch variables will be overridden to match Video

UserVideoTrackName = "PIC CUT"            -- optional custom video track name for user - NEEDS QUOTATION MARKS



    --[[------------------------------[[---
                    FUNCTIONS              
    ---]]------------------------------]]--    
 
 reaper.ClearConsole()
 function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end
 
 
 function CountProjects() -- Returns Number of Projects Currently open in Tabs
 
      local projIdx = 0
      local proj = ""
       
      while proj ~= nil
      do
            projIdx = projIdx + 1
            proj, _ = reaper.EnumProjects( projIdx)
      end
             
      return projIdx
    
 
 end




    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()
      
                          --==//[[    DECLARE VARIABLES   ]]\\==--

      local curpos =  reaper.GetCursorPosition()  --Get current cursor position
      
      local startPos=nil  --will eventually be the subproject Start Time
      local endPos=nil    --will eventually be the subproject End Time
      
      local tracks = {}   
      local vtracks = {}
      
      local source_proj, source_proj_fn = reaper.EnumProjects( -1 )                                        -- Get the Current Project's Project info
      local source_start, source_end = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)          -- Get current start and end time selection value in seconds of current project
      
      local _, source_masterTrack = reaper.GetTrackStateChunk( reaper.GetMasterTrack( 0 ), "", false )     -- Store Current Master Track settings into a variable
      local source_offset =  reaper.GetProjectTimeOffset( source_proj, false )                             -- Save Current Project Start time to Variable
      local source_trackCount = reaper.CountTracks(source_proj)
      
      
      
      local projectTabOptions = reaper.SNM_GetIntConfigVar( "multiprojopt", 0 )                            -- Save Current Project MultiTab Options
      local lastTouched =  reaper.GetLastTouchedTrack()
      
      
                        --==//[[    GET SOURCE TRACK AND RAZOR EDIT DATA   ]]\\==--
      
      for i=1, source_trackCount                                                                       -- Cycle through each track and check to see if anything needs processing
      do
            local track = reaper.GetTrack(0,i-1)
            
            if    CopyVideo                                                                                -- Copy Video Tracks (if option is enabled)
            then
                  local _, name = reaper.GetTrackName( track )
                  if    string.upper(name) == "VIDEO" or string.upper(name) == "PIX" or string.upper(name) == string.upper(UserVideoTrackName)
                  then
                      local _, str = reaper.GetTrackStateChunk( track, "", false )
                      table.insert(vtracks, str)
                      PreserveRelativeTimelinePosition = true                                                -- Overriding these variables ensures timecode match
                      TimecodeMatch = true
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
     
    if       #tracks > 0                                                                              -- if the table has been filled
    then  
              
              reaper.Main_OnCommandEx(41383, 0, source_proj)                                          -- COPY razor edits

              reaper.Main_OnCommandEx(40859, 0, source_proj)                                         -- create new project


              local dest_proj, dest_proj_fn = reaper.EnumProjects(CountProjects()-1, "" )                 -- get project info for new subproject

              
              reaper.SelectProjectInstance(dest_proj)                                                     -- switch to destination subproject
              
              
              
              
              
              if    TimecodeMatch                                                                         
              then
                    if  PreserveRelativeTimelinePosition                                                  -- Logic for adjusting timecode of subproject to match source based on user prefs
                    then
                        reaper.SNM_SetDoubleConfigVar("projtimeoffs",source_offset)                       
                    else
                        reaper.SNM_SetDoubleConfigVar("projtimeoffs",source_offset+startPos)
                    end
                    reaper.UpdateTimeline()
              end
              
              
              
              if  CopyTrackInfo and AlsoCopyMaster                                                        -- match master track to source session
              then
                  reaper.SetTrackStateChunk( reaper.GetMasterTrack( dest_proj ), source_masterTrack, true )
              end
              
              
              if #vtracks > 0
              then
                  for i=1, #vtracks
                  do
                        reaper.InsertTrackAtIndex( i-1, true )
                        local track = reaper.GetTrack(dest_proj,i-1)
                        reaper.SetTrackStateChunk( track, vtracks[i], true )
                  end
              end
              
              
              for i=1, #tracks                                                                            --  Build empty tracks in new subproject --
              do
                  reaper.InsertTrackAtIndex( #vtracks+i-1, true )
                  if  CopyTrackInfo
                  then
                      local track = reaper.GetTrack(dest_proj,#vtracks+i-1)
                      reaper.SetTrackStateChunk( track, tracks[i], true )
                  end
              end
              
              
              reaper.SetOnlyTrackSelected( reaper.GetTrack(dest_proj,0+#vtracks), true )                     -- Select first track to initiate paste
              
              
              
              if  PreserveRelativeTimelinePosition 
              then 
                  reaper.SetEditCurPos(startPos, true, true)                                              -- Set Edit Cursor to start of where items should go
              else
                  reaper.SetEditCurPos(0, true, true)                                                     -- Set Edit Cursor to 0
              end
              
              
              
              reaper.Main_OnCommandEx(42398, 0, dest_proj)                                                -- Paste Items from source project
               
              reaper.Main_OnCommandEx(40020, 0, dest_proj)                                                -- clear any time selection in subproject
              
              
              
              
              if  PreserveRelativeTimelinePosition 
              then
                  reaper.SetProjectMarker( 1, false, startPos, 0, "=START" )                              -- Adjust Subproject Markers to match timecode
                  reaper.SetProjectMarker( 2, false, endPos, 0, "=END" )
              else
                  reaper.SetProjectMarker( 1, false, 0, 0, "=START" ) 
                  reaper.SetProjectMarker( 2, false, endPos-startPos, 0, "=END" )                         -- Adjust end marker to length of items
              end
              
             
             
              if   RenderSubproject
              then
                   reaper.Main_OnCommandEx( 42332, 0, dest_proj )                                         -- save and create rpp                                                           -- Toggle Automatic subproject rendering
              else
                   reaper.Main_SaveProject( dest_proj, false )                                             -- Save Subproject
              end
             
             
             
              if not  EndInSubproject and CloseSubproject
              then
                      reaper.Main_OnCommandEx(40860, 0, dest_proj)                                          -- Close Current Tab
              end
              
              reaper.SelectProjectInstance(source_proj)
              
              if    EndInSubproject 
              then 
                    reaper.SelectProjectInstance(dest_proj)                                               -- switch back to subproject if option is enabled
              end
        
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

