--@noindex
--  NoIndex: true
--@description TJF Script Name
--@version 1.0
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Script Name
--
--  Information about the script
--
--
--  DISCLAIMER:
--  This script was written for my own personal use and therefore I offer no support of any kind.
--  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--  I strongly recommend never to run this or any other script I've written for any reason what so ever.
--  Ignore this advice at your own peril!
--  
--  
--@changelog
--  v1.0 - nothing to report

    
    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--

reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



    --[[------------------------------[[---
                GLOBAL VARIABLES               
    ---]]------------------------------]]--

local item = {}
local itemcount = reaper.CountSelectedMediaItems(0)
for i = 1, itemcount do item[i] = reaper.GetSelectedMediaItem(0, i-1) end --  FILL ITEM ARRAY
    
local track = {}
local trackcount = reaper.CountSelectedTracks(0)
for i = 1, trackcount do track[i] = reaper.GetSelectedTrack(0, i-1) end   -- FILL TRACK ARRAY

start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
                                                                        --second false chooses time or loop points
local curpos =  reaper.GetCursorPosition()  --Get current cursor position

function take(param) return reaper.GetActiveTake(item[param]) end  --can call take function to match take to item



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
                        local itemEndPos = pos+length
    
                        --check if item is in area bounds
                        if (itemEndPos > areaStart and itemEndPos <= areaEnd) or
                            (pos >= areaStart and pos < areaEnd) or
                            (pos <= areaStart and itemEndPos >= areaEnd) then
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

      
      
      local area = GetRazorEdits()
      
      for i = 1, #area do
      
          reaper.GetSet_LoopTimeRange2( 0, true, false, area[i].areaStart, area[i].areaEnd, false )
          reaper.Main_OnCommand(42013, 0) -- Automation: Write current values for actively-writing envelopes to time selection
          --reaper.Main_OnCommand(41160, 0) 
      end
      
      reaper.GetSet_LoopTimeRange2( 0, true, false, start_time, end_time, false )
      
      local mode =  reaper.GetGlobalAutomationOverride()
      reaper.SetGlobalAutomationOverride( 1 )
      reaper.SetGlobalAutomationOverride( mode )
      
    
      
      
     -- track = reaper.GetSelectedTrack(0,0)
      
     -- retval, volume, pan = reaper.GetTrackUIVolPan( track )
      
      
    --  reaper.CountTCPFXParms( 0, track )

     -- retval, fxindex, parmidx = reaper.GetTCPFXParm( 0, track, 0 )




end--Main()


    --[[------------------------------[[---
                CALL THE SCRIPT               
    ---]]------------------------------]]--

    
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
reaper.PreventUIRefresh(-1) -- uncomment only once script works
--reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)
reaper.Undo_EndBlock("TJF Script Name", -1)

--reaper.defer(function() end) --prevent Undo

    
   
