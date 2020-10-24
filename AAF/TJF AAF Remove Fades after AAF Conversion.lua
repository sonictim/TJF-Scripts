--@description TJF Remove Excess Fades after AAF conversion
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Remove Excess Fades after AAF conversion
--  After outputting a session from protools to AAF and then converting to reaper, this will remake and remove all the AAF created fade files in reaper
--  This can take A LONG TIME so be patient
--
--@changelog
--  v1.0 - nothing to report


----------------------------------COMMON FUNCTIONS or FUNCTIONS I WANT TO REMEMBER

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



----------------------------------SET COMMON VARIABLES

     local itemcount = reaper.CountMediaItems(0)

    
    local function starts_with(str, start)
       return str:sub(1, #start) == start
    end
    
    local function round(number, decimals)
        local power = 10^decimals
        return math.floor(number * power) / power
    end


----------------------------------MAIN FUNCTION
function Main()

while itemcount ~= 0 do -- This will go backwards through every single item in the session.  Working backwards prevents the list from changing while it works
  itemcount = itemcount - 1
  local item = reaper.GetMediaItem(0, itemcount)
  local take = reaper.GetActiveTake(item)
  local name =  reaper.GetTakeName(take)
  local match = 0
  
        if starts_with(name, "Fade ") then
                
                local fadelength =  reaper.GetMediaItemInfo_Value( item, "D_LENGTH")
                local fadestart = reaper.GetMediaItemInfo_Value( item, "D_POSITION")
                local fadeend = fadestart + fadelength    
                local previtem = reaper.GetMediaItem(0, itemcount - 1)
                local nextitem = reaper.GetMediaItem(0, itemcount + 1)
                
                
                if previtem then  -- process/adjust the item immediately before the fade item
                        take = reaper.GetActiveTake(previtem)
                        local itemstart = reaper.GetMediaItemInfo_Value( previtem, "D_POSITION")
                        local itemlength = reaper.GetMediaItemInfo_Value( previtem, "D_LENGTH")
                        local itemend =  itemstart + itemlength 
                
                        
                        if round(fadestart,2) == round(itemend,2) then  -- if the previous item is currently touching the fade item
                          --Msg("match fade out required")
                          match = match + 1
                          reaper.SetMediaItemInfo_Value( previtem, "D_LENGTH", itemlength + fadelength )
                          reaper.SetMediaItemInfo_Value( previtem, "D_FADEOUTLEN", fadelength)
                
                        end--if
                    
                end--if
                
                
                if nextitem then  -- process/adjust the item immediately after the fade item
                        
                         take = reaper.GetActiveTake(nextitem)
                        local offset = reaper.GetMediaItemTakeInfo_Value( take, "D_STARTOFFS")
                        local itemstart = reaper.GetMediaItemInfo_Value( nextitem, "D_POSITION")
                        local itemlength = reaper.GetMediaItemInfo_Value( nextitem, "D_LENGTH")
                        local itemend =  itemstart + itemlength 
                        
                        if round(itemstart,2) == round(fadeend,2) then  -- if the next item is currently touching the fade item
                        
                              --Msg("match fade in required")
                              match = match + 1
                              reaper.SetMediaItemInfo_Value( nextitem, "D_LENGTH", itemlength + fadelength )
                              reaper.SetMediaItemInfo_Value( nextitem, "D_FADEINLEN", fadelength)
                              reaper.SetMediaItemInfo_Value( nextitem, "D_POSITION", fadestart)
                              reaper.SetMediaItemTakeInfo_Value( take, "D_STARTOFFS", offset - fadelength )      
                        
                        end--if 
                
                end--if
                
                if match == 2 then -- if there's a crossfade change fadetype to equal power
                
                    reaper.SetMediaItemInfo_Value( previtem, "C_FADEOUTSHAPE",1 )
                    reaper.SetMediaItemInfo_Value( nextitem, "C_FADEINSHAPE", 1)
                
                
                end--if
                
          reaper.DeleteTrackMediaItem(reaper.GetMediaItemTrack(item), item)
          --Msg(name .. " deleted")      
                
        end--if

end--while


end--Main()


----------------------------------CALL THE SCRIPT

--reaper.ShowConsoleMsg("")  --reset console window
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
reaper.UpdateTimeline()
reaper.Undo_EndBlock("TJF Delete AAF Fades", -1)


    
   
