--@description TJF Move Razor Edit Selection to New Subproject
--@version 1.5
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Move Razor Edit Selection to New Subproject 
--
--  Will create a new Subproject name and move your current razor edit selection to this new subproject.
--  NEW SUBPROJECT WILL BE CREATED ON FIRST SELECTED TRACK (not necessarily razor edit tracks)
--  There are various options the user can set that affect how the razor edits are placed in the Destination Subproject
--  Timecode copy and Video Track Copy are both supported.  
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
--  v0.1 - initial version nothing to report
--  v0.2 - bugfixes and cleanup
--  v0.3 - new optional settings "CopyTrackInfo" and "PreserveRelativeTimelinePosition"
--  v0.4 - added option close subproject
--  v0.5 - added support for master track copy
--  v0.6 - added support to match timecode start of sessions
--  v0.7 - adjusted behavior of Timecode Match to be more intuiative. No longer necessary to Preserve Position for Timecode match
--  v0.8 - added Prompt for Subproject Filename Option
--  v0.9 - added render subproject option
--  v1.0 - added option to sum final RPP-PROX to mono in original timeline
--  v1.1 - bugfix for variable "PreserveRelativeTimelinePosition"
--  v1.2 - Replacing razor edit with new subproject is now optional via Global Variable
--  v1.3 - add EXPORT option to export the newly created subproject
--  v1.4 - added optional user variable for picture track name
--  v1.5 - bugfix


    --[[------------------------------[[---
           GLOBAL SETTINGS VARIABLES               
    ---]]------------------------------]]--

ReplaceRazorEditWithSubproject = true     -- If false, will create the subproject but not replace the contents of the razor edit on the timeline - EXPORT MODE

PromptForFilename = false                 -- If true, script will ask user to name the subproject being created

RenderSubproject = true                   -- If true, script will render the subproject.  False will leave it unrendered
SumToMono = false                         -- If true, will set the resulting subproject file to take mode MONO DOWNMIX.  Requires RenderSubproject = true 

EndInSubproject = false                   -- If true, script will complete with the subproject tab selected (similar to reaper default subproject behavior).  If false, the original project will be selected 
CloseSubproject = true                    -- If true, the newly created subproject tab will be closed at the end of the script.  
                                          -- ***NOTE: if EndInSubproject is true, it will override this variable.
CopyTrackInfo = false                      -- If true, track information from the source tracks (name, color, # of channels, plugins, envelopes,etc) will be copied into the subproject tracks
AlsoCopyMaster = false                     -- If true, will also copy the master track info (#channels, plugins, envelopes) IF CopyTrackInfo is enabled

TimecodeMatch = true                      -- If true, script will adjust the subproject session start time so your moved edits will be placed at the same timecode as the source project.
PreserveRelativeTimelinePosition = false  -- If true, items will be pasted in the subproject equidistant from the project start as they were in the original project.

CopyVideo = true                          -- If true, script will look for any tracks with the name VIDEO or PIX (case insensitive) and copy them along with your selected media
                                          -- ***NOTE: If COPY VIDEO is enabled (TRUE), then if video is found, the PreserveRelativeTimelinePosition and TimecodeMatch variables will be overridden to match Video
UserVideoTrackName = "PIC CUT"           -- optional custom video track name for user - NEEDS QUOTATION MARKS

ExportSubproject = false                  -- If true, will also prompt user to export Subproject


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

      local curpos =  reaper.GetCursorPosition()  --Get current cursor position
      
      local startPos=nil  --will eventually be the subproject Start Time
      local endPos=nil    --will eventually be the subproject End Time
      
      local tracks = {}    
      local vtracks = {}
      
      local source_proj, source_proj_fn = reaper.EnumProjects( -1, "" )                                    -- Get the Current Project's Project info
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
              reaper.SNM_SetIntConfigVar(  "multiprojopt", 4096)                                          -- Disable Automatic Subproject Rendering
              
              reaper.SetEditCurPos(startPos, true, true)
              
              if ReplaceRazorEditWithSubproject
              then
                  reaper.Main_OnCommandEx(41384, 0, source_proj)                                          -- CUT razor edits
              else
                  reaper.Main_OnCommandEx(41383, 0, source_proj)                                          -- COPY razor edits
              end
              
              
              reaper.GetSet_LoopTimeRange2( source_proj, true, false, startPos, endPos, false )           -- set time selection to length of razor edits      
              

              if PromptForFilename
              then
                   reaper.Main_OnCommandEx(41049, 0, source_proj)                                         -- insert new subproject
              else
                   reaper.InsertTrackAtIndex( source_trackCount, true )                                   -- insert blank track
                   reaper.SetOnlyTrackSelected( reaper.GetTrack(source_proj,source_trackCount), true )    -- select this track
                   reaper.Main_OnCommandEx(41997, 0, source_proj)                                         -- Move blank track to subproject
              end
              
              
              
              reaper.GetSet_LoopTimeRange2( source_proj, true, false, source_start, source_end, false )   -- Restore Original Time Selection
              
              
              local dest_proj, dest_proj_fn = reaper.EnumProjects(CountProjects()-1, "" )                 -- get project info for new subproject
              
              
              reaper.SelectProjectInstance(dest_proj)                                                     -- switch to destination subproject
              
              
              
              if not PromptForFilename 
              then 
                     reaper.DeleteTrack(  reaper.GetTrack( dest_proj, 0 ) )
              end
              
              
              
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
                   reaper.SNM_SetIntConfigVar(  "multiprojopt", 0)                                        -- Enable Automatic Subproject Rendering                                                           -- Toggle Automatic subproject rendering
                   if ExportSubproject then reaper.Main_SaveProject( dest_proj, false ) end
              end
             
             
             
              reaper.Main_SaveProject( dest_proj, ExportSubproject )                                      -- Save Subproject
             
              
              
              if not  EndInSubproject and CloseSubproject
              then
                      reaper.Main_OnCommandEx(40860, 0, dest_proj)                                          -- Close Current Tab
              end
              
              
              reaper.SelectProjectInstance(source_proj)
              
              
              reaper.Main_OnCommandEx(40441,0, source_proj)                                               -- rebuild peaks for selected items (new subproject)
              
              
              if not  PromptForFilename
              then
                      if ReplaceRazorEditWithSubproject then reaper.MoveMediaItemToTrack( reaper.GetSelectedMediaItem(source_proj,0), lastTouched ) end
                      reaper.DeleteTrack(  reaper.GetTrack( source_proj, source_trackCount ) )
              end
              
              if not ReplaceRazorEditWithSubproject and PromptForFilename
              then
                  reaper.Main_OnCommandEx(40697, 0, source_proj) -- remove
                  reaper.Main_OnCommandEx(42398, 0, source_proj) -- paste              
              end
              
              if    SumToMono and RenderSubproject
              then
                    reaper.Main_OnCommand(40178, 0)                                                       -- Item properties: Set take channel mode to mono (downmix)
              end
              
              reaper.SetEditCurPos(curpos, true, true)
              
              if    EndInSubproject 
              then 
                    reaper.SelectProjectInstance(dest_proj)                                               -- switch back to subproject if option is enabled
              end
              
              
              reaper.SNM_SetIntConfigVar(  "multiprojopt", projectTabOptions)                             -- Restore Project Tab Settings
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

