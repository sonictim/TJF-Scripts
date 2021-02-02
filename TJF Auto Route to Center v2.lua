--[[------------------------------------[[---
                    DEBUG               
---]]------------------------------------]]--

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end


--GLOBAL VARIABLES

local plugin = "TJF/JSFX/TJF Mono to Channel 3 (Center).jsfx"
local preset = "none"
local channels = 6

local olditems = {}
local lastProjectChangeCount = reaper.GetProjectStateChangeCount(0)
local maxitems = 400

local cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script



  --------========<<<<<<<<++++++++>>>>>>>>========--------
--[[                    SHALLOW EQUAL                   ]]--
  --------========<<<<<<<<++++++++>>>>>>>>========--------
  
local function shallow_equal(t1, t2)
 
  if #t1 ~= #t2 then return false end
    for k, v in pairs(t1) do
      if v ~= t2[k] then return false end
    end
    return true
end


  --[[------========<<<<<<<<++++++++>>>>>>>>========-----[[---
                          ADD PLUGIN                 
  ---]]-----========<<<<<<<<++++++++>>>>>>>>========------]]--
function AddPlugin(item)

local fxheader = [[
>
<TAKEFX
SHOW 0
LASTSEL 0
DOCKED 0
]]


local pluginchunk = [[
BYPASS 0 0 0
<JS "TJF/JSFX/TJF Mono to Channel 3 (Center).jsfx" ""
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
>
FLOATPOS 0 0 0 0
FXID ]]..reaper.genGuid("")..[[ 
WAK 0 0
>
TAKEFX_NCH ]]..channels

    
    
    local _, str = reaper.GetItemStateChunk( item, "", false )
    
    if string.match(str,"<TAKEFX") then  -- if there are already takefx in the chunk

        str = string.gsub(str, "BYPASS %d %d %d\n<JS \"TJF/JSFX/TJF Mono to Channel 3 %(Center%).jsfx\".-WAK %d %d\n", "") -- remove plugin from current position
        str = string.gsub(str, "TAKEFX_NCH %d+", "") -- removes this if it gets left over
        str = string.gsub(str, "WAK %d %d\n>", "WAK 0 0" .. pluginchunk)  --add plugin at end of chain
    else
    
        str = string.gsub(str, ">\n>", fxheader .. pluginchunk) -- crete takefx header and add plugin at end of chain
    end
    
    reaper.SetItemStateChunk( item, str, false )
 
end--AddPlugin()
 
 
 
 
 function DeletePlugin(item)
  local _, str = reaper.GetItemStateChunk( item, "", false )

  str = string.gsub(str, "BYPASS %d %d %d\n<JS \"TJF/JSFX/TJF Mono to Channel 3 %(Center%).jsfx\".-WAK %d %d\n", "")
 
  reaper.SetItemStateChunk( item, str, false )
  
 end--DeletePlugin()
  
 

function exit()
Initialize(2,0)
end--exit()


function ProcessItems(item)
          if item 
          then
                  local track = reaper.GetMediaItem_Track(item)
                  local trackchan = reaper.GetMediaTrackInfo_Value(track, "I_NCHAN")
                  
                  local take = reaper.GetActiveTake(item)
                  
                  if take 
                  then
                          local source = reaper.GetMediaItemTake_Source(take)
                          local sourcechan = reaper.GetMediaSourceNumChannels(source)
                          local takemode = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")
                          
                          if    trackchan > 2 and (sourcechan == 1 or (takemode > 1 and takemode < 65))
                          then  AddPlugin(item)
                          else  DeletePlugin(item)
                          end
                  end
                  
                  
                  reaper.UpdateArrange()
            end
            
end--function

function Initialize(chan, state)
    if reaper.EnumProjects(0) then
          reaper.SetToggleCommandState( 0, cmd_id, state)
          reaper.RefreshToolbar2(0, cmd_id)
          
          local retval, userinput = reaper.GetUserInputs("Adjust Session to ".. chan .." Channels?", 3, "Items,Tracks,Master", "YES,YES,YES" )
          local itemsok, tracksok, masterok  = userinput:match("(.-),(.-),(.*)")
          
          if retval 
          then
                reaper.PreventUIRefresh(1)
                --reaper.Undo_BeginBlock()
            
            
            -------------SET MASTER TRACK
                 if     masterok == "YES" 
                 then   reaper.SetMediaTrackInfo_Value(reaper.GetMasterTrack(0), "I_NCHAN", chan) 
                 end
            
            -------------SET ALL OTHER TRACKS    
                for i=0, reaper.CountTracks(0)-1 -- set all tracks to channels
                do  
                    local track = reaper.GetTrack(0,i)
                    local trackchan = reaper.GetMediaTrackInfo_Value(track, "I_NCHAN")
                    
                    if trackchan ~= chan
                    then
                          if    tracksok == "YES" 
                          then  reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0,i), "I_NCHAN", chan) 
                          end
                          
                          if    itemsok == "YES" 
                          then
                                for j=0, reaper.CountTrackMediaItems(track)-1 
                                do  ProcessItems(reaper.GetTrackMediaItem(track,j))
                                end --for
                          end--if
                    end--if
                end--for
                
            
                --reaper.Undo_EndBlock("TJF Set/Clear Mono Items to Center Channel", -1)
                reaper.PreventUIRefresh(-1)
                
                
          end--if
    end--if
end--Initialize()



function Main()

    local projectChangeCount = reaper.GetProjectStateChangeCount(0)
    local items = {}

     if reaper.GetSelectedMediaItem(0,0) 
     then
          reaper.PreventUIRefresh(1)
          for   i=1, reaper.CountSelectedMediaItems(0) 
          do    items[i] = reaper.GetSelectedMediaItem(0,i-1) 
          end
          
          if    not shallow_equal(items, olditems) or (lastProjectChangeCount < projectChangeCount)
          then  
                if #items < maxitems 
                then
                    for i=1, #items
                    do ProcessItems(items[i]) 
                    end
                    --reaper.UpdateArrange()
                end--if
          end--if
          reaper.PreventUIRefresh(-1)
    end--if
          
    olditems = items
    lastProjectChangeCount = projectChangeCount

reaper.defer(Main)


end--Main()


if reaper.GetProjectStateChangeCount(0) > 3 then Initialize(channels, 1)
else
          reaper.SetToggleCommandState( 0, cmd_id, 1)
          reaper.RefreshToolbar2(0, cmd_id)
end
reaper.atexit(exit)
Main()
