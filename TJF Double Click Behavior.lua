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



--------------------------------SET COMMON VARIABLES
    local curpos =  reaper.GetCursorPosition()
    local SelItems = {}
    local itemcount = reaper.CountSelectedMediaItems(0)
        

    
----------------------------------MAIN FUNCTION
function Main()


      for i = 1, itemcount do 
              SelItems[i] = reaper.GetSelectedMediaItem(0, i-1)
              itemPosition = reaper.GetMediaItemInfo_Value( SelItems[i], "D_POSITION" )
              if itemPosition < curpos then
              curpos = itemPosition
              
              end
      end--for
          
      if curpos == reaper.GetCursorPosition() then reaper.Main_OnCommand(41589, 0) -- show item properties
      
      else reaper.SetEditCurPos(curpos, 1, 0)
      
      end
      
      --reaper.Main_OnCommand(40290,0) -- set time selection to items
      
end--Main()


----------------------------------CALL THE SCRIPT

--reaper.ShowConsoleMsg("")  --reset console window
--reaper.Undo_BeginBlock()
Main()
reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.Undo_EndBlock("TJF Script Name", -1)

reaper.defer(function() end) --prevent Undo

    
   
