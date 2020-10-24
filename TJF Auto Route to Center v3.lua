----------------------------------
--          DEBUG               --
----------------------------------

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end


--GLOBAL VARIABLES

local plugin = "TJF/JSFX/TJF Mono to Channel 3 (Center).jsfx"
local preset = "none"
local channels = 6
--local counter = 0

local olditems = {}
local lastProjectChangeCount = reaper.GetProjectStateChangeCount(0)

local cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script





local function shallow_equal(t1, t2)
    if #t1 ~= #t2 then return false end
    for k, v in pairs(t1) do
      if v ~= t2[k] then return false end
    end
    return true
end


--[[
function AddPlugin(item)

    local fxheader = "<TAKEFX\nWNDRECT 0 0 0 0\nSHOW 0\nLASTSEL 0\nDOCKED 0\n"
    local pluginchunk = "BYPASS 0 0 0\n<JS \"TJF/JSFX/TJF Mono to Channel 3 (Center).jsfx\" \"\"\n- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - \n>\nFLOATPOS 0 0 0 0\nFXID {30CD82D4-0A65-1E49-9FE4-98EFB486AC68}\nWAK 0 0\n>"
    
    local _, str = reaper.GetItemStateChunk( item, "", false )
     
    str = string.gsub(str, "BYPASS %d %d %d\n<JS \"TJF/JSFX/TJF Mono to Channel 3 %(Center%).jsfx\".-WAK %d %d\n", "") -- removes plugin if it exists
    str = string.gsub(str, "\n>\n>\n", "\n>\n")
     
    local test = string.match(str, "<TAKEFX")
    
    if    test ~= "<TAKEFX" 
    then 
          str = str .. fxheader .. pluginchunk .. ">\nTAKEFX_NCH 6\n>"
          reaper.SetItemStateChunk( item, str, false )
    else
          local header = string.match(str, "<ITEM.*WAK %d %d\n")
          local footer = string.match(str, "WAK?.*$") -- get's end of plugin chunk
          
          if    header and footer 
          then
                str = header .. pluginchunk .. footer .. ">\nTAKEFX_NCH 6\n>"
                reaper.SetItemStateChunk( item, str, false )
          end
    end
 
end--AddPlugin()
 
 
 
 
 function DeletePlugin(item)
  local _, str = reaper.GetItemStateChunk( item, "", false )

  str = string.gsub(str, "BYPASS %d %d %d\n<JS \"TJF/JSFX/TJF Mono to Channel 3 %(Center%).jsfx\".*WAK %d %d\n", "")
 
  reaper.SetItemStateChunk( item, str, false )
  
 end--DeletePlugin()
]]--  
 

function exit()
Initialize(2,0)
end--exit()

--[[
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
                  --reaper.UpdateArrange()
            end
            
end--function
]]--

function ProcessItems(item)

          reaper.PreventUIRefresh(1)
          reaper.Undo_BeginBlock()
          local track = reaper.GetMediaItem_Track(item)
          local trackchan = reaper.GetMediaTrackInfo_Value(track, "I_NCHAN")

          for   j=0,  reaper.CountTakes(item)-1 do
                
               
                local take = reaper.GetMediaItemTake(item, j)
                local source = reaper.GetMediaItemTake_Source(take)
                local sourcechan = reaper.GetMediaSourceNumChannels(source)
                local takemode = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")
                if    trackchan > 2 and (sourcechan == 1 or (takemode > 1 and takemode < 65)) then
                      local fxnumber = reaper.TakeFX_AddByName( take, plugin, 1)
                      if    fxnumber ~= reaper.TakeFX_GetCount(take)-1
                      then  reaper.TakeFX_Delete(take, fxnumber)
                            reaper.TakeFX_AddByName(take, plugin, 1)
                      end--if
                else  local fxnumber = reaper.TakeFX_AddByName( take, plugin, 0)
                      if    fxnumber >= 0 
                      then  reaper.TakeFX_Delete(take, fxnumber) 
                      end
                end--if
          end--for
          reaper.Undo_EndBlock("TJF Set/Clear Mono Items to Center Channel", -1)
          reaper.PreventUIRefresh(-1)
          reaper.UpdateArrange()

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
    --if lastProjectChangeCount < projectChangeCount then
    --    local action = reaper.Undo_CanUndo2(0)
    --    action = string.find(action, "FX")
    --end
    
    
    local items = {}

     if reaper.GetSelectedMediaItem(0,0) 
     then
          
          for   i=1, reaper.CountSelectedMediaItems(0) 
          do    items[i] = reaper.GetSelectedMediaItem(0,i-1) 
          end
          
          --if    not shallow_equal(items, olditems) or (counter > 30 and #items<100)
          if    not shallow_equal(items, olditems) or (lastProjectChangeCount < projectChangeCount)
          then  
                if #items < 100
                then
                      for i=1, #items
                      do ProcessItems(items[i]) 
                      end
                      reaper.UpdateArrange()
                end
          end
          
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
