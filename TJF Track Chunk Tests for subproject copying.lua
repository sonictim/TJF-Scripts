--[[

@noindex
  NoIndex: true
@description TJF Script Name
@version 1.0
@author Tim Farrell
@links
  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml

@about
  # TJF Script Name

  Information about the script


  DISCLAIMER:
  This script was written for my own personal use and therefore I offer no support of any kind.
  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
  I strongly recommend never to run this or any other script I've written for any reason what so ever.
  Ignore this advice at your own peril!
  
  

@changelog
  v1.0 - nothing to report

    
    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--

reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



    --[[------------------------------[[---
                GLOBAL VARIABLES               
    ---]]------------------------------]]--

GETVIDEO = true


start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
                                                                        --second false chooses time or loop points
local curpos =  reaper.GetCursorPosition()  --Get current cursor position





    --[[------------------------------[[---
                    FUNCTIONS              
    ---]]------------------------------]]--    
    
function RazorEditSelectionExists()
          for i=0, reaper.CountTracks(0)-1 do
              local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then return true end
          end
          return false
    
end--RazorEditSelectionExists()
    
function GetRazorEdits()  -- Function Written by BirdBird on reaper forums
    local trackCount = reaper.CountTracks(0)
    local areaMap = {}
    for i = 0, trackCount - 1 do
        local track = reaper.GetTrack(0, i)
        local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
        if area ~= '' then
            --PARSE STRING
            local str = {}
            for j in string.gmatch(area, "%S+") do
                table.insert(str, j)
            end
        
            --FILL AREA DATA
            local j = 1
            while j <= #str do
                --area data
                local areaStart = tonumber(str[j])
                local areaEnd = tonumber(str[j+1])
                local GUID = str[j+2]
                local isEnvelope = GUID ~= '""'
    
                --get item data
                local items = {}
                if not isEnvelope then
                    local itemCount = reaper.CountTrackMediaItems(track)
                    for k = 0, itemCount - 1 do 
                        local item = reaper.GetTrackMediaItem(track, k)
                        local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                        local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
                        local endPosPos = pos+length
    
                        --check if item is in area bounds
                        if (endPosPos > areaStart and endPosPos <= areaEnd) or
                            (pos >= areaStart and pos < areaEnd) or
                            (pos <= areaStart and endPosPos >= areaEnd) then
                                table.insert(items,item)
                        end
                    end
                end
    
                local areaData = {
                    areaStart = areaStart,
                    areaEnd = areaEnd,
                    track = track,
                    items = items,
                    isEnvelope = isEnvelope,
                    GUID = GUID
                }
    
                 table.insert(areaMap, areaData)
    
                j = j + 3
            end
        end
    end
    
    return areaMap
end
    


    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
function Main()

startPos=nil
endPos=nil
video=0

tracks = {}

source_proj, source_proj_fn = reaper.EnumProjects( -1, "" )


reaper.SelectProjectInstance(source_proj)



for i=1, reaper.CountTracks(0)  do

 track = reaper.GetTrack(0,i-1)
 retval, name = reaper.GetTrackName( track )
 if GETVIDEO then
      if string.upper(name) == "VIDEO" or string.upper(name) == PIX then
          retval, str = reaper.GetTrackStateChunk( track, "", false )
          table.insert(tracks, str)
          video = video +1
      end
  end
 
 ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)

  if area ~= '' then
        areaStr = {}
        for j in string.gmatch(area, "%S+") do
             table.insert(areaStr, j)
        end
        local j = 1
        while j <= #areaStr do
            --area data
            local areaStart = tonumber(areaStr[j])
            local areaEnd = tonumber(areaStr[j+1])
            
            if startPos==nil or areaStart < startPos then  startPos = areaStart end
            if endPos == nil or areaEnd > endPos then endPos = areaEnd end
            
            
            j = j + 3
        end
        
        retval, str = reaper.GetTrackStateChunk( track, "", false )
        str =  string.gsub(str, "<ITEM.+>", "")
        
        table.insert(tracks, str)
  end
        
end

if #tracks == 0 then return false end

reaper.GetSet_LoopTimeRange2( source_proj, true, false, startPos, endPos, false )

reaper.Main_OnCommand(41384, 0) -- CUT razor edits


projIdx = 0
proj = source_proj

while proj ~= nil do
    projIdx = projIdx + 1
    proj, _ = reaper.EnumProjects( projIdx, "" )
end

reaper.Main_OnCommand(41049, 0) --insert new subproject

dest_proj, dest_proj_fn = reaper.EnumProjects(projIdx, "" )

reaper.SelectProjectInstance(dest_proj)


reaper.SelectProjectInstance(dest_proj)

reaper.Main_OnCommand(40296, 0) -- select all tracks
reaper.Main_OnCommand(40005, 0) -- remove tracks


for i=1, #tracks do

  reaper.InsertTrackAtIndex( i-1, true )
  track = reaper.GetTrack(0,i-1)
  reaper.SetTrackStateChunk( track, tracks[i], true )

end

reaper.SetOnlyTrackSelected( reaper.GetTrack(0,0+video), true )

--reaper.Main_OnCommand(40939, 0) -- select track 1

reaper.SetEditCurPos(startPos, true, true)
reaper.Main_OnCommand(42398, 0)-- Paste Items
 
 
 reaper.SetProjectMarker( 1, false, startPos, 0, "=START" )
 reaper.SetProjectMarker( 2, false, endPos, 0, "=END" )
 
 --reaper.Main_OnCommand(40026, 0) -- save project
 
 --reaper.Main_SaveProject( 0, false )
 

--reaper.SelectProjectInstance(source_proj)
reaper.GetSet_LoopTimeRange2( source_proj, true, false, start_time, end_time, false )

--reaper.Main_SaveProject( dest_proj, false )
--reaper.Main_SaveProject( dest_proj, false )
--reaper.Main_SaveProject( dest_proj, false )
--reaper.Main_SaveProject( dest_proj, false )
reaper.Main_SaveProject( dest_proj, false )
reaper.Main_SaveProject( dest_proj, false )
reaper.SelectProjectInstance(source_proj)



-- reaper.AddProjectMarker( dest_proj, false, startPos, 0, "Start", 1 )
-- reaper.AddProjectMarker( dest_proj, false, endPos, 0, "end", 2 )


--

-- reaper.SetProjectMarker( markrgnindexnumber, isrgn, pos+2, rgnend, name )


--reaper.InsertMedia("/Users/tfarrell/TEMP/REAPER/subproject.RPP", 1) -- Create RPP-PROX

--[[ track = reaper.GetSelectedTrack( 0, 0 )
 retval, str = reaper.GetTrackStateChunk( track, "", true )
 track =  reaper.GetTrack( 0, 1 )
 reaper.SetTrackStateChunk( track, str, true )
]]

end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
reaper.PreventUIRefresh(-1) -- uncomment only once script works
reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)
reaper.Undo_EndBlock("TJF Script Name", -1)

--reaper.defer(function() end) --prevent Undo

    
   
