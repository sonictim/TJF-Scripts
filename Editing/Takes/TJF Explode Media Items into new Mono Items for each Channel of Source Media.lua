--@description TJF Explode Media Items into new Mono Items for each Channel of Source Media
--@version 0.1
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Explode Media Items into new Mono Items for each Channel of Source Media
--  Will create new 1 channel media items for each channel in your media item source across your current tracks
--  Will create a new track to expand to if necessary
--  Option Variable to group all items together.   
--  Option Variable to create all new items on current track or "explode" across existing tracks.
--
--  TO DO:  adjust pan... will likely use new Media item channel mapping funciton.  Waiting for further development
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
--  v0.1 - nothing to report




    --[[------------------------------[[---
                GLOBAL VARIABLES               
    ---]]------------------------------]]--

CreateGroups = true
ExplodeAcrossTracks = false
    
    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--


reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end


function CopyMediaItem (item,destinationTrack)

  local retval, chunk = reaper.GetItemStateChunk( item, "", false )
  chunk = string.gsub(chunk, "GUID {.-}", "GUID "..reaper.genGuid(""))
  local newItem =  reaper.AddMediaItemToTrack(destinationTrack)
  reaper.SetItemStateChunk( newItem, chunk, false )
  return newItem

end



function Main()

    local itemcount = reaper.CountSelectedMediaItems(0)
    
    if itemcount then
        
        local item = {}
        for i=itemcount, 1, -1 do 
              item[i] = reaper.GetSelectedMediaItem(0, i-1)
              reaper.SetMediaItemSelected( item[i], false )
              
              
        
        end
        
        
        for i=1, #item do
            
            
            local take = reaper.GetActiveTake(item[i])
            local source = reaper.GetMediaItemTake_Source(take)
            local sourcechan = reaper.GetMediaSourceNumChannels(source)
            local chanmode = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")
            
            if sourcechan > 1  then
                
                if CreateGroups then
                      local group = reaper.GetMediaItemInfo_Value(item[i], "I_GROUPID")
                      if group == 0 then
                            reaper.SetMediaItemSelected( item[i], true )
                            reaper.Main_OnCommand(40032, 0) -- group items
                            reaper.SetMediaItemSelected( item[i], false )
                      end
                end
            
                local track = reaper.GetMediaItemTrack( item[i] )
                local idx = reaper.GetMediaTrackInfo_Value( track, "IP_TRACKNUMBER")
                  
            
                for j=1, sourcechan-1 do
                    newTrack = reaper.GetTrack(0, idx + j-1)
                    if not ExplodeAcrossTracks then newTrack = track end
                    if not newTrack then
                        reaper.InsertTrackAtIndex( idx + j-1, true )
                        newTrack = reaper.GetTrack( 0, idx + j-1)
                    end
                    local newItem = CopyMediaItem(item[i], newTrack)
                    local newTake = reaper.GetActiveTake(newItem)
                    reaper.SetMediaItemTakeInfo_Value(newTake, "I_CHANMODE", 3 + j)
      
                end--for
                
                reaper.SetMediaItemTakeInfo_Value(take, "I_CHANMODE", 3)
            
            
            end--if
        end--for
    end--if

end--Main()


reaper.PreventUIRefresh(1)
 reaper.Undo_BeginBlock()

Main()

reaper.Undo_EndBlock("TJF Explode Media Items into new Mono Items for each Channel of Source Media", -1)
reaper.PreventUIRefresh(-1)





