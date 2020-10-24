--@description TJF Script Name
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Script Name
--  Information about the script
--
--@changelog
--  v1.0 - nothing to report


----------------------------------COMMON FUNCTIONS or FUNCTIONS I WANT TO REMEMBER

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

--[[      CONVERT TEXT TO TITLE CASE
function titleCase( first, rest ) return first:upper()..rest:lower() end
   --How to call in script:  STRING = string.gsub(STRING, "(%a)([%w_']*)", titleCase) 
]]--




----------------------------------SET COMMON VARIABLES

    local item = {}
    local itemcount = reaper.CountSelectedMediaItems(0)
    for i = 1, itemcount do item[i] = reaper.GetSelectedMediaItem(0, i-1) end --  FILL ITEM ARRAY
    
    local track = {}
    local trackcount = reaper.CountSelectedTracks(0)
    for i = 1, trackcount do track[i] = reaper.GetSelectedTrack(0, i-1) end   -- FILL TRACK ARRAY
    
    local curpos =  reaper.GetCursorPosition()  --Get current cursor position

     start_time, end_time = reaper.GetSet_LoopTimeRange2(0, true, false, curpos, curpos, false) -- Get start and end time selection value in seconds
                                                                        --second false chooses time or loop points
    

    function take(param) return reaper.GetActiveTake(item[param]) end  --can call take function to match take to item


----------------------------------MAIN FUNCTION
function Main()


end--Main()


----------------------------------CALL THE SCRIPT

--reaper.ShowConsoleMsg("")  --reset console window
reaper.Undo_BeginBlock()
--reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
--reaper.PreventUIRefresh(-1) -- uncomment only once script works
reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)
reaper.Undo_EndBlock("TJF Script Name", -1)

--reaper.defer(function() end) --prevent Undo

    
   
