--@description TJF Export Razor Edit to New Project
--@version 2.6
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
--  v2.2 - additional metadata support
--  v2.3 - added GUI Options Support and a ton of new features
--  v2.4 - added ability to remember last settings as well as GUI improvements
--  v2.51 - added BWF metadata to Description field + minor bugfix
--  v2.6 - bugfix:  if a razor edit includes a track, that track will arrive in the new session, even if there are no items associated with it

    --[[------------------------------[[---
           GLOBAL SETTINGS VARIABLES               
    ---]]------------------------------]]--

OptionsDialog = true                      -- If true, a GUI will pop up giving script options before running
RazorEditsOnly = false                    -- If no razor edits are found, should the script work with selected items instead?

RenderSubproject = true                   -- If true, script will also render the subproject RPP-PROX.  False will just save as a regular project
ImportSubproject = false
ReplaceSelectionWithSubproject = false


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

UserVideoTrackName = "PIX"            -- optional custom video track name for user - NEEDS QUOTATION MARKS

SoundminerFields = {"Description", "Designer", "Library", "Manufacturer", "Show", "URL"}


    --[[------------------------------[[---
                    FUNCTIONS              
    ---]]------------------------------]]--    
 
 reaper.ClearConsole()
 function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end
 
 function toboolean(value)
    if value == "true" or value == true
    then
         return true
    else
        return false
    end
 end
 
function LinkDefaults()

  --local copy = GUI.Val("Copy")
  --if copy[4] == true then copy[5] = true end
  --GUI.Val("Copy", copy)
  
  copy = GUI.Val("Subproject")
 
  if copy[2] == true then copy[1] = false end
  if copy[3] == false then 
      copy[4] = false
      copy[5] = false
  end
  if copy[5] == true then copy[4] = true end
  
  GUI.Val("Subproject", copy)
  
end 

 
 
 function CheckVideo(track)
 
       local _, name = reaper.GetTrackName( track )
       if     string.upper(name) == string.upper(UserVideoTrackName)
           --or string.upper(name) == "VIDEO" 
           --or string.upper(name) == "PIX" 
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

    reaper.MB("Nothing Selected!", "ERROR", 0)
    return false
 
 
 end


function CopyRenderMetadataFunc(source_proj, dest_proj)
    local BWF = { "Description", "OriginationDate", "OriginationTime", "Originator", "OriginatorReference" }
    local BWFmetadata = {}
    local IXML = { "PROJECT", "SCENE", "NOTE", "USER", "CIRCLED", "TAPE", "FILE_UID" }
    local IXMLmetadata = {}
    local CUSTOMmetadata = {}
  
    reaper.SelectProjectInstance(source_proj)  
    
    local settings = reaper.GetSetProjectInfo( source_proj, "RENDER_SETTINGS", 512, false )
    if settings < 512 then settings = settings + 512 end
    local bounds = reaper.GetSetProjectInfo( source_proj, "RENDER_BOUNDSFLAG", 0, false )
    local channels = reaper.GetSetProjectInfo( source_proj, "RENDER_CHANNELS", 2, false )
    local srate = reaper.GetSetProjectInfo( source_proj, "RENDER_SRATE", 0, false )
    local startpos = reaper.GetSetProjectInfo( source_proj, "RENDER_STARTPOS", 0, false )
    local endpos = reaper.GetSetProjectInfo( source_proj, "RENDER_ENDPOS", 0, false )
    local tailflag = reaper.GetSetProjectInfo( source_proj, "RENDER_TAILFLAG", 0, false )
    local tailms = reaper.GetSetProjectInfo( source_proj, "RENDER_TAILMS", 0, false )
    local addtoproj = reaper.GetSetProjectInfo( source_proj, "RENDER_ADDTOPROJ", 0, false )
    local dither = reaper.GetSetProjectInfo( source_proj, "RENDER_DITHER", 0, false )
    local psrate = reaper.GetSetProjectInfo( source_proj, "PROJECT_SRATE", 0, false )
    local psrateuse = reaper.GetSetProjectInfo( source_proj, "PROJECT_SRATE_USE", 0, false )
    
    local _, recordpath = reaper.GetSetProjectInfo_String( source_proj, "RECORD_PATH", "", false )
    local _, renderfile = reaper.GetSetProjectInfo_String( source_proj, "RENDER_FILE", "", false )
    local _, renderpattern = reaper.GetSetProjectInfo_String( source_proj, "RENDER_PATTERN", "", false )
    local _, renderformat = reaper.GetSetProjectInfo_String( source_proj, "RENDER_FORMAT", "", false )
    local _, renderformat2 = reaper.GetSetProjectInfo_String( source_proj, "RENDER_FORMAT2", "", false )
    
    for i=1, #BWF
    do
        local _, metadata = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "BWF:"..BWF[i], false )
        table.insert(BWFmetadata, metadata)
    end
    
    for i=1, #IXML
    do
        local _, metadata = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:"..IXML[i], false )
        table.insert(IXMLmetadata, metadata)
    end
    
    for i=1, #SoundminerFields
    do
        local _, metadata = reaper.GetSetProjectInfo_String( source_proj, "RENDER_METADATA", "IXML:USER:"..SoundminerFields[i], false )
        table.insert(CUSTOMmetadata, metadata)
    end
  
  
    reaper.SelectProjectInstance(dest_proj)
    
    
    reaper.GetSetProjectInfo( dest_proj, "RENDER_SETTINGS", settings, true )
    reaper.GetSetProjectInfo( dest_proj, "RENDER_BOUNDSFLAG", bounds, true )
    reaper.GetSetProjectInfo( dest_proj, "RENDER_CHANNELS", channels, true )
    reaper.GetSetProjectInfo( dest_proj, "RENDER_SRATE", srate, true )
    reaper.GetSetProjectInfo( dest_proj, "RENDER_STARTPOS", startpos, true )
    reaper.GetSetProjectInfo( dest_proj, "RENDER_ENDPOS", endpos, true )
    reaper.GetSetProjectInfo( dest_proj, "RENDER_TAILFLAG", tailflag, true )
    reaper.GetSetProjectInfo( dest_proj, "RENDER_TAILMS", tailms, true )
    reaper.GetSetProjectInfo( dest_proj, "RENDER_ADDTOPROJ", addtoproj, true )
    reaper.GetSetProjectInfo( dest_proj, "RENDER_DITHER", dither, true )
    reaper.GetSetProjectInfo( dest_proj, "PROJECT_SRATE", psrate, true )
    reaper.GetSetProjectInfo( dest_proj, "PROJECT_SRATE_USE", psrateuse, true )
    
    reaper.GetSetProjectInfo_String( source_proj, "RECORD_PATH", recordpath, true )
    reaper.GetSetProjectInfo_String( source_proj, "RENDER_FILE", renderfile, true )
    reaper.GetSetProjectInfo_String( source_proj, "RENDER_PATTERN", renderpattern, true )
    reaper.GetSetProjectInfo_String( source_proj, "RENDER_FORMAT", renderformat, true )
    reaper.GetSetProjectInfo_String( source_proj, "RENDER_FORMAT2", renderformat2, true )
    
    for i=1, #BWF
    do
        reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "BWF:"..BWF[i].."|"..BWFmetadata[i], true )
    end
    
    for i=1, #IXML
    do
        reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:"..IXML[i].."|"..IXMLmetadata[i], true )
    end
    
    for i=1, #SoundminerFields
    do
        reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:USER:"..SoundminerFields[i].."|"..CUSTOMmetadata[i], true )
    end
    
    
    
end

function Cancel()
        GUI.quit = true
        gfx.quit()
end


function OK()

        UserVideoTrackName = GUI.Val("VideoTrack")
        
        local table = GUI.Val("Copy")
        CopyTrackInfo = table[1]
        CopyMaster = table[2]
        CopyRenderMetadata = table[3]
        CopyVideo = table[4]
        PreserveRelativeTimelinePosition = table[5]
        
        local str = tostring(table[1])..","..tostring(table[2])..","..tostring(table[3])..","..tostring(table[4])..","..tostring(table[5])
        reaper.SetExtState( "TJF Export", "Copy", str , true )       
        
        table = GUI.Val("Subproject")
        EndInSubproject = table[1] 
        CloseSubproject = table[2]
        RenderSubproject = table[3]
        ImportSubproject = table[4]
        ReplaceSelectionWithSubproject = table[5]
        
        local str = tostring(table[1])..","..tostring(table[2])..","..tostring(table[3])..","..tostring(table[4])..","..tostring(table[5])
        reaper.SetExtState( "TJF Export", "Subproject", str , true )
        --reaper.SetExtState( "TJF Export", "Description", GUI.Val("Description") , true )
        if GUI.Val("VideoTrack") == "" then GUI.Val("VideoTrack", UserVideoTrackName) end
        reaper.SetExtState( "TJF Export", "PIX", GUI.Val("VideoTrack") , true )
        reaper.SetExtState( "TJF Export", "Channels", tostring(GUI.Val("MasterChan")) , false )
        --reaper.DeleteExtState( "TJF Export", "Channels", true )
        

        GUI.quit = true
        gfx.quit()
        
        
        
        reaper.Undo_BeginBlock()
        reaper.PreventUIRefresh(1)
        if OKtoRun() then  Main() end
        reaper.PreventUIRefresh(-1)
        reaper.Undo_EndBlock("TJF Export Razor Edit to New Project", -1)
end



   --[[------------------------------[[---
                    MAIN              
   ---]]------------------------------]]--
function Main()
      
             --==//[[    DECLARE VARIABLES   ]]\\==--

      local curPos = reaper.GetCursorPosition()
      local startPos = nil  --will eventually be the subproject Start Time
      local endPos = nil    --will eventually be the subproject End Time
      local pasteTrack = nil
      
      local source_proj, source_proj_fn = reaper.EnumProjects( -1 )                                        -- Get the Current Project's Project info
      
      local source_offset =  reaper.GetProjectTimeOffset( source_proj, false )                             -- Save Current Project Start time to Variable
      

          reaper.Main_OnCommandEx(41383, 0, source_proj)                                              -- COPY razor edits

      
      reaper.Main_OnCommandEx(40859, 0, source_proj)                                              -- create new project
      
      local dest_proj, dest_proj_fn = reaper.EnumProjects(CountProjects()-1, "" )                 -- get project info for new subproject
      
      
      if CopyRenderMetadata
      then
          CopyRenderMetadataFunc(source_proj, dest_proj)
      else
          reaper.SelectProjectInstance(dest_proj)                                                     -- switch to destination subproject   
      end
      
      if GUI.Val("Description")
      then
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "BWF:Description|"..GUI.Val("Description"), true )
          reaper.GetSetProjectInfo_String( dest_proj, "RENDER_METADATA", "IXML:USER:Description|"..GUI.Val("Description"), true )
      end
      
      
      
      if  CopyMaster                                                                              -- match master track to source session
      then
          local _, source_masterTrack = reaper.GetTrackStateChunk( reaper.GetMasterTrack( 0 ), "", false )     -- Store Current Master Track settings into a variable
          reaper.SetTrackStateChunk( reaper.GetMasterTrack( dest_proj ), source_masterTrack, true )
          if GUI.Val("MasterChan") ~= ""
          then
             reaper.SetMediaTrackInfo_Value(reaper.GetMasterTrack( 0 ), "I_NCHAN", GUI.Val("MasterChan")) 
          end
      
      end
      
      
      
                        --==//[[    COPY SOURCE PROJECT DATA TO DESTINATION   ]]\\==--
      
      for i=0, reaper.CountTracks(source_proj)-1                                                     -- Cycle through each track 
      do
            local track = reaper.GetTrack(source_proj,i)
            local _, str = reaper.GetTrackStateChunk( track, "", false )                            -- get all track info via chunk
            
            
            if CopyVideo and CheckVideo(track) then 
            else
                  str =  string.gsub(str, "<ITEM.+>", "")               -- remove all items from track chunk leaving empty tracks with envelope information intact
                  str =  string.gsub(str, "PT %d.-\n", "")              -- remove automation points
                
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
      
                            --IF RAZOR EDITS DON"T EXIST COPY SELECTED REGIONS
      
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
         local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)

         if item == nil and area == ""
         
         then reaper.DeleteTrack( track ) end
         
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
             
      
      dest_proj, dest_proj_fn = reaper.EnumProjects(CountProjects()-1, "" )
      
             
      if not  EndInSubproject and CloseSubproject
      then
              reaper.Main_OnCommandEx(40860, 0, dest_proj)                                          -- Close Current Tab
      end
              
      reaper.SelectProjectInstance(source_proj)

      
      if RenderSubproject and ImportSubproject then
      
                reaper.SetEditCurPos2( source_proj, startPos, false, false )
                
                if ReplaceSelectionWithSubproject
                then
                   reaper.Main_OnCommandEx(41384, 0, source_proj)          -- CUT razor Edits
                   reaper.InsertMedia( dest_proj_fn.."-PROX", 0 )
                else
                   reaper.InsertMedia( dest_proj_fn.."-PROX", 1 )
                end
                
                reaper.SetEditCurPos2( source_proj, curPos, true, true )
              
      end        
              
      if    EndInSubproject 
      then 
            reaper.SelectProjectInstance(dest_proj)                                               -- switch back to subproject if option is enabled
      end

end--Main()



--[[------------------------------[[--
                GUI         
--]]------------------------------]]--



local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()




GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - Options.lua")()
GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Label.lua")()
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end



GUI.name = "EXPORT RAZOR EDIT OR SELECTED ITEMS TO NEW PROJECT"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 640, 200
GUI.anchor, GUI.corner = "mouse", "C"




GUI.New("Copy", "Checklist", {
    z = 11,
    x = 16,
    y = 2,
    w = 180,
    h = 125,
    caption = "",
    optarray = {"Copy Track Info                      # of channels", "Copy Master Track", "Copy Render Metadata", "Copy Video Track Named:", "Preserve Relative Position in New Project"},
    dir = "v",
    pad = 4,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    
    bg = "wnd_bg",
    frame = false,
    shadow = false,
    swap = nil,
    opt_size = 20
})

GUI.New("Subproject", "Checklist", {
    z = 11,
    x = 288,
    y = 2,
    w = 250,
    h = 125,
    caption = "",
    optarray = {"End with New Project Selected", "Close New Project", "Render as Subproject", "Import Subproject to Timeline (to new track)", "Replace Selection with Imported Subproject"},
    dir = "v",
    pad = 4,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = false,
    swap = nil,
    opt_size = 20
})

GUI.New("MasterChan", "Textbox", {
    z = 11,
    x = 194.0,
    y = 31,
    w = 90,
    h = 20,
    caption = "",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    tab_idx = 2
})

GUI.New("VideoTrack", "Textbox", {
    z = 11,
    x = 194.0,
    y = 80,
    w = 90,
    h = 20,
    caption = "",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    tab_idx = 3
})

GUI.New("Description", "Textbox", {
    z = 11,
    x = 93,
    y = 160,
    w = 520,
    h = 20,
    caption = "Description: ",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    tab_idx = 1
})

GUI.New("CANCEL", "Button", {
    z = 11,
    x = 528,
    y = 44,
    w = 100,
    h = 24,
    caption = "CANCEL",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = Cancel
})

GUI.New("OK", "Button", {
    z = 11,
    x = 528,
    y = 12,
    w = 100,
    h = 24,
    caption = "OK",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = OK
})

GUI.New("Warning", "Label", {
    z = 11,
    x = 52,
    y = 132,
    w = 100,
    h = 24,
    --caption = "THE STATE OF SOME CHECKBOXES AFFECT THE ABILITY OF OTHERS TO BE MANIPULATED",
    caption = "NOTE: The state of some checkboxes affect the ability of others to be manipulated",
    font = 4,
    --col_txt = "txt",
    --col_fill = "elm_frame",
    --func = OK
})

GUI.New("Optional", "Label", {
    z = 15,
    x = 94,
    y = 182,
    w = 100,
    h = 24,
    caption = "*optional - replaces BWF/IXML description field in render metadata of new project",
    font = 3,
    --col_txt = "txt",
    --col_fill = "elm_frame",
    --func = OK
})


function GUI.Textbox:onupdate()
  if self.focus then
     if self.blink == 0 then
      self.show_caret = true
      self:redraw()
    elseif self.blink == math.floor(GUI.txt_blink_rate / 2) then
      self.show_caret = false
      self:redraw()
    end
    self.blink = (self.blink + 1) % GUI.txt_blink_rate
 else
    self.sel_s = 0
    self.sel_e = string.len(self.retval)
    self.caret = string.len(self.retval)
  end
  
end


GUI.Main = function ()
    xpcall( function ()

        if GUI.Main_Update_State() == 0 then return end

        GUI.Main_Update_Elms()

        -- If the user gave us a function to run, check to see if it needs to be
        -- run again, and do so.
        if GUI.func then

            local new_time = reaper.time_precise()
            if new_time - GUI.last_time >= (GUI.freq or 1) then
                GUI.func()
                GUI.last_time = new_time

            end
        end


        -- Maintain a list of elms and zs in case any have been moved or deleted
        GUI.update_elms_list()


        GUI.Main_Draw()

    end, GUI.crash)
end


GUI.Main_Update_State = function()

    -- Update mouse and keyboard state, window dimensions
    if GUI.mouse.x ~= gfx.mouse_x or GUI.mouse.y ~= gfx.mouse_y then

        GUI.mouse.lx, GUI.mouse.ly = GUI.mouse.x, GUI.mouse.y
        GUI.mouse.x, GUI.mouse.y = gfx.mouse_x, gfx.mouse_y

        -- Hook for user code
        if GUI.onmousemove then GUI.onmousemove() end

    else

        GUI.mouse.lx, GUI.mouse.ly = GUI.mouse.x, GUI.mouse.y

    end
    GUI.mouse.wheel = gfx.mouse_wheel
    GUI.mouse.cap = gfx.mouse_cap
    GUI.char = gfx.getchar()

    if GUI.cur_w ~= gfx.w or GUI.cur_h ~= gfx.h then
        GUI.cur_w, GUI.cur_h = gfx.w, gfx.h

        GUI.resized = true

        -- Hook for user code
        if GUI.onresize then GUI.onresize() end

    else
        GUI.resized = false
    end

    --  (Escape key)  (Window closed)    (User function says to close)
    --if GUI.char == 27 or GUI.char == -1 or GUI.quit == true then
    if GUI.char == 27 then Cancel() end
    if GUI.char == 13 then OK() end
    if (GUI.char == 27 and not (  GUI.mouse.cap & 4 == 4
                                or   GUI.mouse.cap & 8 == 8
                                or   GUI.mouse.cap & 16 == 16
                                or  GUI.escape_bypass))
            or GUI.char == -1
            or GUI.quit == true then

        GUI.cleartooltip()
        return 0
    else
        if GUI.char == 27 and GUI.escape_bypass then GUI.escape_bypass = "close" end
        reaper.defer(GUI.Main)
    end

end
   
  local str = reaper.GetExtState( "TJF Export", "Copy" )
  if  str
  then
      CopyTrackInfo, CopyMaster, CopyRenderMetadata, CopyVideo, PreserveRelativeTimelinePosition = str:match("(.-),(.-),(.-),(.-),(.*)")
     -- name, category, designer, project, number, renamefile  = userinput:match("(.-),(.-),(.-),(.-),(.-),(.*)")
  end
      
  GUI.Val("Copy", {toboolean(CopyTrackInfo), toboolean(CopyMaster), toboolean(CopyRenderMetadata), toboolean(CopyVideo), toboolean(PreserveRelativeTimelinePosition)})

  local str = reaper.GetExtState( "TJF Export", "Subproject" )
  if  str
  then
      EndInSubproject, CloseSubproject, RenderSubproject, ImportSubproject, ReplaceSelectionWithSubproject = str:match("(.-),(.-),(.-),(.-),(.*)")
     -- name, category, designer, project, number, renamefile  = userinput:match("(.-),(.-),(.-),(.-),(.-),(.*)")
  end
  
  GUI.Val("Subproject", {toboolean(EndInSubproject), toboolean(CloseSubproject), toboolean(RenderSubproject), toboolean(ImportSubproject), toboolean(ReplaceSelectionWithSubproject)})
  
  
  
  if reaper.GetExtState( "TJF Export", "PIX" ) ~= "" then UserVideoTrackName = reaper.GetExtState( "TJF Export", "PIX" ) end
  GUI.Val("VideoTrack", UserVideoTrackName )
  
  chans = tonumber(reaper.GetExtState( "TJF Export", "Channels" ))
  
  if not chans
  then 
        chans =reaper.GetMediaTrackInfo_Value(reaper.GetMasterTrack( 0 ), "I_NCHAN")
  end

  GUI.Val("MasterChan", chans, "I_NCHAN")
  
  
  
GUI.elms.Description.focus = true
GUI.elms.Description.sel_s = 0
GUI.elms.Description.sel_e = string.len(GUI.elms.Description.retval)
GUI.elms.Description.caret = string.len(GUI.elms.Description.retval)

GUI.func = LinkDefaults
GUI.freq = .3

GUI.version = TJF




if OKtoRun() 
then 

      
      if OptionsDialog
      then
      
          GUI.Init()
          GUI.Main()
          
      else
          Main()
      end
end
