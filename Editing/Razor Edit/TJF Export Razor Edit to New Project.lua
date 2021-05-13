--@description TJF Export Razor Edit to New Project
--@version 2.1
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
--  v2.0 - logic rework for entire script
--  v2.1 - added ability to export selected items if no razor edit present and COPY METADATA


    --[[------------------------------[[---
           GLOBAL SETTINGS VARIABLES               
    ---]]------------------------------]]--

RazorEditsOnly = false                    -- If no razor edits are found, should the script work with selected items instead?

RenderSubproject = true                   -- If true, script will also render the subproject RPP-PROX.  False will just save as a regular project

EndInSubproject = false                   -- If true, script will complete with the subproject tab selected (similar to reaper default subproject behavior).  If false, the original project will be selected 
CloseSubproject = true                    -- If true, the newly created subproject tab will be closed at the end of the script.  
                                          -- ***NOTE: if EndInSubproject is true, it will override this variable.
                                          
CopyTrackInfo = true                      -- If true, track information from the source tracks (name, color, # of channels, plugins, envelopes,etc) will be copied into the subproject tracks
CopyMaster = true                     -- If true, will also copy the master track info (#channels, plugins, envelopes) IF CopyTrackInfo is enabled
CopyRenderMetadata = true

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
 

 function CheckVideo(track)
 
       local _, name = reaper.GetTrackName( track )
       if     string.upper(name) == "VIDEO" 
           or string.upper(name) == "PIX" 
           or string.upper(name) == string.upper(UserVideoTrackName)
       then
           TimecodeMatch = true
           PreserveRelativeTimelinePosition = true
           return true
       end
 
       return false
 
 end
 
 
 
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

 function OKtoRun()
    
          for i=0, reaper.CountTracks(0)-1 do
              local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then return true end
          end
          
          if not RazorEditsOnly and reaper.GetSelectedMediaItem(-1, 0) then return true end

    return false
 
 
 end

    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()
      
      if not OKtoRun() then return end

                          --==//[[    DECLARE VARIABLES   ]]\\==--

      local startPos = nil  --will eventually be the subproject Start Time
      local endPos = nil    --will eventually be the subproject End Time
      local pasteTrack = nil
      
      local source_proj, source_proj_fn = reaper.EnumProjects( -1 )                                        -- Get the Current Project's Project info
      
      local source_offset =  reaper.GetProjectTimeOffset( source_proj, false )                             -- Save Current Project Start time to Variable
      
      local _, metadata1 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "BWF:Description", false )
      local _, metadata2 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "BWF:OriginationDate", false )
      local _, metadata3 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "BWF:OriginationTime", false )
      local _, metadata4 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "BWF:Originator", false )
      local _, metadata5 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "BWF:OriginatorReference", false )
      local _, metadata6 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:PROJECT", false )
      local _, metadata7 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:SCENE", false )
      local _, metadata8 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:NOTE", false )
      local _, metadata9 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:USER:Name", false )
      local _, metadata10 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:USER:REAPER", false )
      local _, metadata11 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:CIRCLED", false )
      local _, metadata12 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:TAPE", false )
      local _, metadata13 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:TAKE", false )
      local _, metadata14 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:FILE_UID", false )
      local _, metadata15 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:USER", false )
      
      
      reaper.Main_OnCommandEx(41383, 0, source_proj)                                              -- COPY razor edits
      
      reaper.Main_OnCommandEx(40859, 0, source_proj)                                              -- create new project
      
      local dest_proj, dest_proj_fn = reaper.EnumProjects(CountProjects()-1, "" )                 -- get project info for new subproject
      
      reaper.SelectProjectInstance(dest_proj)                                                     -- switch to destination subproject      


      
      
      
      if  CopyMaster                                                                              -- match master track to source session
      then
          local _, source_masterTrack = reaper.GetTrackStateChunk( reaper.GetMasterTrack( 0 ), "", false )     -- Store Current Master Track settings into a variable
          reaper.SetTrackStateChunk( reaper.GetMasterTrack( dest_proj ), source_masterTrack, true )
      end
      
      if CopyRenderMetadata
      then
          
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "BWF:Description|"..metadata1, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "BWF:OriginationDate|"..metadata2, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "BWF:OriginationTime|"..metadata3, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "BWF:Originator|"..metadata4, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "BWF:OriginatorReference|"..metadata5, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:PROJECT|"..metadata6, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:SCENE|"..metadata7, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:NOTE|"..metadata8, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:USER:Name|"..metadata9, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:USER:REAPER|"..metadata10, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:CIRCLED|"..metadata11, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:TAPE|"..metadata12, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:TAKE|"..metadata13, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:FILE_UID|"..metadata14, true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:USER|"..metadata15, true )
      end
      
      
      
                        --==//[[    COPY SOURCE PROJECT DATA TO DESTINATION   ]]\\==--
      
      for i=0, reaper.CountTracks(source_proj)-1                                                     -- Cycle through each track 
      do
            local track = reaper.GetTrack(source_proj,i)
            local _, str = reaper.GetTrackStateChunk( track, "", false )                            -- get all track info via chunk
            
            if CopyVideo and CheckVideo(track) then 
            else
                  str =  string.gsub(str, "<ITEM.+>", "")               -- remove all items from track chunk leaving empty tracks with envelope information intact
                  str =  string.gsub(str, "PT %d.+\n", "")              -- remove automation points
            end
            
            reaper.InsertTrackAtIndex( i, false )                       -- create a new track
            
            if CopyTrackInfo then reaper.SetTrackStateChunk( reaper.GetTrack(dest_proj,i), str, true ) end  -- Copy Chunk to new track

            
            
           
           local  _, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)           -- get track razor edit info
          
           if     area ~= ''                                                                               -- if track contains a razor edit, parse and process it
           then
                  if pasteTrack == nil then pasteTrack = i end
                  
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
            end
      end
      
                            --IF RAXOR EDITS DON"T EXIST COPY SELECTED REGIONS
      
      if pasteTrack == nil
      then
          
          for i=0, reaper.CountSelectedMediaItems(source_proj)-1
          do
                local item = reaper.GetSelectedMediaItem( source_proj, i )
                local itemStart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                if startPos == nil or itemStart < startPos then startPos = itemStart end
                local itemEnd =  itemStart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                if endPos == nil or itemEnd > endPos then endPos = itemEnd end
                
                if i==0 then
                      local itemtrack =  reaper.GetMediaItem_Track( item )
                      pasteTrack =  reaper.GetMediaTrackInfo_Value( itemtrack, "IP_TRACKNUMBER" ) - 1
                end

          end

      end
      
      
                              --==//[[    ADJUST TIMELINE/TIMECODE   ]]\\==--
      
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
      
      
                               --==//[[  PASTE RAZOR EDITS  ]]\\==--
      
      
      if  PreserveRelativeTimelinePosition 
      then 
          reaper.SetEditCurPos(startPos, true, true)                                              -- Set Edit Cursor to start of where items should go
      else
          reaper.SetEditCurPos(0, true, true)                                                     -- Set Edit Cursor to 0
      end

      reaper.SetOnlyTrackSelected( reaper.GetTrack(dest_proj, pasteTrack) ) 
      reaper.Main_OnCommandEx(42398, 0, dest_proj)                                                -- Paste Items from source project
       

      
                              --==//[[    REMOVE EMPTY TRACKS   ]]\\==--
      
     for i=reaper.CountTracks(dest_proj), 1, -1
     do
         local track = reaper.GetTrack(dest_proj, i-1)
         local item = reaper.GetTrackMediaItem( track, 0 )
         if item == nil then reaper.DeleteTrack( track ) end
         
     end 
      
     
                              --==//[[    SET MARKERS   ]]\\==--
          
     if  PreserveRelativeTimelinePosition 
     then
         reaper.AddProjectMarker(dest_proj, false, startPos, 0, "=START", 1 )                              -- Adjust Subproject Markers to match timecode
         reaper.AddProjectMarker(dest_proj, false, endPos, 0, "=END", 2 )
     else
         reaper.AddProjectMarker(dest_proj, false, 0, 0, "=START", 1 ) 
         reaper.AddProjectMarker(dest_proj, false, endPos-startPos, 0, "=END", 2 )                         -- Adjust end marker to length of items
     end
      

   
                              --==//[[  SAVE AND CLOSE  ]]\\==--
      
      if   RenderSubproject
      then
            reaper.Main_OnCommandEx( 42332, 0, dest_proj )                                          -- save and create rpp 
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


end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
       Main()
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("TJF Export Razor Edit to New Project", -1)

