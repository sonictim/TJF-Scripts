--@description TJF Toggle Mute (Match First Selected)
--@version 2.5
--@author Tim Farrell
--
--@about
--  # TJF Toggle Mute (Match First Selected)
--  This will toggle all items to match the mute state of the first selected item
--
--@changelog
--  v1.0 - nothing to report
--  v2.0 - added track support
--  v2.5 - will now match if any item or track is muted.. not just first


----------------------------------DEBUG MESSAGES
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



----------------------------------SET COMMON VARIABLES

    local item = {}
    local itemcount = reaper.CountSelectedMediaItems(0)
    for i = 1, itemcount do item[i] = reaper.GetSelectedMediaItem(0, i-1) end --  FILL ITEM ARRAY
    
    local track = {}
    local trackcount = reaper.CountSelectedTracks(0)
    for i = 1, trackcount do track[i] = reaper.GetSelectedTrack(0, i-1) end   -- FILL TRACK ARRAY
    
    
----------------------------------CHECK IF MUTE IS REQUIRED

function MuteCheck(param)

    if param == item then 
    
          for i=1, itemcount do
          
              check = reaper.GetMediaItemInfo_Value( item[i],"B_MUTE" )
              
              if check == 0 then return true end -- if anything is unmuted, return true

          end--for
          
    else
    
          for i=1, trackcount do
          
              check = reaper.GetMediaTrackInfo_Value( track[i],"B_MUTE" )
              
              if check == 0 then return true end -- if anything is unmuted, return true
          
          end--for
          
    end--if
    
end--AnyMuted()
    
    
    
    
    
----------------------------------TOGGLE TRACK

function ToggleTrack()

  
    if MuteCheck(track)then mute = 1 else mute = 0 end
    
    for i=1, trackcount do reaper.SetMediaTrackInfo_Value( track[i], "B_MUTE", mute) end  --set all tracks to value
     


end--ToggleTrack()





----------------------------------TOGGLE ITEM    
function ToggleItem()    

    
    if MuteCheck(item)then mute = 1 else mute = 0 end
    
    for i=1, itemcount do reaper.SetMediaItemInfo_Value( item[i], "B_MUTE", mute) end  --set all items to value


end--ToggleItem()




    

----------------------------------MAIN FUNCTION
function Main()

    if itemcount > 0 then 
        ToggleItem()
    else 
        if trackcount > 0 then ToggleTrack() end 
    end--if

end--Main()


----------------------------------CALL THE SCRIPT


reaper.Undo_BeginBlock()
Main()
reaper.UpdateArrange()
reaper.UpdateTimeline()
reaper.Undo_EndBlock("TJF Toggle Mute (Match First Selected)", -1)
    
   
