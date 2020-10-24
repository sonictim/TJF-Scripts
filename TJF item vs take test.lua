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




----------------------------------SET COMMON VARIABLES

    local item = {}
    local itemcount = reaper.CountSelectedMediaItems(0)
    for i = 1, itemcount do item[i] = reaper.GetSelectedMediaItem(0, i-1) end --  FILL ITEM ARRAY
    
    local track = {}
    local trackcount = reaper.CountSelectedTracks(0)
    for i = 1, trackcount do track[i] = reaper.GetSelectedTrack(0, i-1) end   -- FILL TRACK ARRAY

    local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
                                                                        --second false chooses time or loop points
    
    local curpos =  reaper.GetCursorPosition()  --Get current cursor position

    function take(param) return reaper.GetActiveTake(item[param]) end  --can call take function to match take to item


----------------------------------MAIN FUNCTION
function Main()

   offset = reaper.GetProjectTimeOffset( -1, false )
   time = 10
   format = reaper.format_timestr_pos( time, "", 5 )
   test = "2:25:30:15"
   buf = reaper.parse_timestr_pos( test, 5 )
   reaper.SetEditCurPos( buf, true, true )
    
    for i=1, itemcount do
          Msg(item[i])
          Msg(take(i))
    
    end--for
    
reaper.ClearConsole()    
    gGUID = reaper.genGuid("" )
    Msg(gGUID)
    destNeed64 = reaper.guidToString( gGUID, "" )
    Msg(destNeed64)
    

local _, str = reaper.GetItemStateChunk(item[1], "", false )

MatchChunk = ">\n>"

VolChunk=[[
>
<VOLENV
EGUID ]]..reaper.genGuid("")..[[ 
ACT 1 -1
VIS 1 1 1
LANEHEIGHT 0 0
ARM 1
DEFSHAPE 0 -1 -1
VOLTYPE 1
PT 0 1 0
>]]


str = str:gsub(MatchChunk, VolChunk)

reaper.SetItemStateChunk( item[1], str, false )







    Msg(temp)


end--Main()


----------------------------------CALL THE SCRIPT

--reaper.ShowConsoleMsg("")  --reset console window
reaper.Undo_BeginBlock()
Main()
reaper.UpdateArrange()
--reaper.UpdateTimeline()
reaper.Undo_EndBlock("TJF Script Name", -1)

--reaper.defer(function() end) --prevent Undo
