----------------------------------
--          DEBUG               --
----------------------------------

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end


--GLOBAL VARIABLES

plugin = "TJF/JSFX/TJF Mono to Channel 3 (Center).jsfx"
preset = "none"
channels = 6
counter = 0

olditems = " "
oldchains = " "

local cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script



function exit()
Initialize(2,0)
end--exit()


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

    reaper.SetToggleCommandState( 0, cmd_id, state)
    reaper.RefreshToolbar2(0, cmd_id)
    
    local retval, userinput = reaper.GetUserInputs("Adjust Session to ".. chan .." Channels?", 3, "Items,Tracks,Master", "YES,YES,YES" )
    local itemsok, tracksok, masterok  = userinput:match("(.-),(.-),(.*)")
    
    if retval then
        
          reaper.PreventUIRefresh(1)
          reaper.Undo_BeginBlock()
      
      
      -------------SET MASTER TRACK
           if masterok == "YES" then   reaper.SetMediaTrackInfo_Value(reaper.GetMasterTrack(0), "I_NCHAN", chan) end
      
      -------------SET ALL OTHER TRACKS    
          for i=0, reaper.CountTracks(0)-1 do  -- set all tracks to channels
              local track = reaper.GetTrack(0,i)
              local trackchan = reaper.GetMediaTrackInfo_Value(track, "I_NCHAN")
              if trackchan ~= chan then
                    if tracksok == "YES" then reaper.SetMediaTrackInfo_Value( reaper.GetTrack(0,i), "I_NCHAN", chan) end
                    if itemsok == "YES" then
                          for j=0, reaper.CountTrackMediaItems(track)-1 do
                              ProcessItems(reaper.GetTrackMediaItem(track,j))
                          end--for
                    end--if
              end--if
          end--for
          
      
          reaper.Undo_EndBlock("TJF Set/Clear Mono Items to Center Channel", -1)
          reaper.PreventUIRefresh(-1)
          reaper.UpdateArrange()
          
    end--if
    
end--Initialize()



function Main()

 items   = " "
 --chains  = " "
 if reaper.GetSelectedMediaItem(0,0) then

          for   i=0, reaper.CountSelectedMediaItems(0)-1 do
                local item = reaper.GetSelectedMediaItem(0,i)
                items = items .. tostring(reaper.GetSelectedMediaItem(0,i))
                --for j=0, reaper.CountTakes(item)-1 do
                --      local take = reaper.GetMediaItemTake(item, j)
                --      chains = chains .. tostring(reaper.TakeFX_GetCount(take))
                --end--for
          end--for
          
          if items ~= olditems or (counter == 30 and reaper.CountSelectedMediaItems(0)<400) then  -- or chains ~= oldchains
          
               for i=0, reaper.CountSelectedMediaItems(0)-1 do
               ProcessItems(reaper.GetSelectedMediaItem(0,i)) end
               counter = 0
          end
          
end--if
          olditems = items
          --oldchains = chains
          counter = counter + 1

reaper.defer(Main)


end--Main()




Initialize(channels, 1)
reaper.atexit(exit)
Main()
