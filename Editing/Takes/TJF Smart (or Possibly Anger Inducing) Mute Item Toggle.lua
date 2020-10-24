--@description TJF Smart (or Possibly Anger Inducing) Mute Toggle
--@version 1.2
--@author Tim Farrell
--
--@about
--  # TJF Smart Mute Toggle
--  This is a mute toggle that will remember what items in a selection are  already muted
--  BE CAREFUL!!!!! This script is like an elephant, it NEVER FORGETS (unless you tell it to)
--
--@changelog
--  v1.0 - nothing to report
--  v1.1 - speed optimizations
--  v1.2 - functionality improvements

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






----------------------------------CHECK IF ALL ITEMS ARE IN THE LIST

function CheckAllInList()

  counter = 0

  for j=1, itemcount do
  
      if string.find(keepmuted, tostring(item[j]))then counter = counter + 1 end
      
  end--for

  
  
  if counter == itemcount then
  
      return true
  
  else
  
      return false
  
  end

end--CheckAllInList()

    
    
    
 
    
    
    
----------------------------------TOGGLE TRACK

function ToggleTrack()

  
    if MuteCheck(track)then mute = 1 else mute = 0 end
    
    for i=1, trackcount do reaper.SetMediaTrackInfo_Value( track[i], "B_MUTE", mute) end  --set all tracks to value
     


end--ToggleTrack()





----------------------------------TOGGLE ITEM    
function ToggleItem()

    keepmuted =  reaper.GetExtState("TJF Smart Mute", "Muted Items")
    if keepmuted == nil then keepmuted = " " end
    
    AllInList = CheckAllInList()
    
    
    
    if MuteCheck(item)then mute = 1 else mute = 0 end
    
    
    for i=1, itemcount do
    
        currentmute = reaper.GetMediaItemInfo_Value( item[i],"B_MUTE" )
        
        string = tostring(item[i])
        
        
        
        
        if mute == 1 then  -- IF WE ARE GOING TO MUTE THE ITEMS

            keepmuted = string.gsub(keepmuted, string, "") -- clear item if in list
            
            if currentmute == 1 then   -- if item is already muted, add to list

                keepmuted = keepmuted .. string  --append item to string
                
            end
            
            reaper.SetMediaItemInfo_Value( item[i], "B_MUTE", mute)
        end--if
        
        if mute == 0 then  -- IF WE ARE GOING TO UNMUTE
  
            
            if AllInList then keepmuted = string.gsub(keepmuted, string, "") end
        
            if not string.find(keepmuted, string) then  -- if the item is not found in the list, unmute 
            
                reaper.SetMediaItemInfo_Value( item[i], "B_MUTE", mute)
                
    
                
            end--if
        
        
        end--if
        
      end--for
      
      --keepmuted = " "
      reaper.SetExtState("TJF Smart Mute", "Muted Items", keepmuted, true)
    
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
reaper.Undo_EndBlock("TJF Smart Mute Toggle", -1)
    
   

