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


----------------------------------COMMON FUNCTIONS

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

function RazorEditSelectionExists()
          for i=0, reaper.CountTracks(0)-1 do
              local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then return true end
          end
          return false
    
end--RazorEditSelectionExists()

function SetRazorEdit(track, areaStart, areaEnd, GUID)
    if GUID == nil then GUID = '""' end
    
    --parse area string
    local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
    local str = area ~= nil and area .. ' ' or ''
    str = str .. tostring(areaStart) .. ' ' .. tostring(areaEnd) .. ' ' .. GUID
    
    local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', str, true)
    return ret
end
    


--------------------------------SET COMMON VARIABLES
    local curpos =  reaper.GetCursorPosition()
    local SelItems = {}
    local itemcount = reaper.CountSelectedMediaItems(0)
        

    
----------------------------------MAIN FUNCTION
function Main()


      for i = 1, itemcount do 
              SelItems[i] = reaper.GetSelectedMediaItem(0, i-1)
              itemPosition = reaper.GetMediaItemInfo_Value( SelItems[i], "D_POSITION" )
              itemEnd = itemPosition + reaper.GetMediaItemInfo_Value( SelItems[i], "D_LENGTH" )
              track =  reaper.GetMediaItemTrack( SelItems[i] )
              SetRazorEdit(track, itemPosition, itemEnd)
              
              if itemPosition < curpos then
              curpos = itemPosition
              
              end
      end--for
          
      --if curpos == reaper.GetCursorPosition() and RazorEditSelectionExists()  then reaper.Main_OnCommand(41589, 0) -- show item properties
      
      --elseif curpos == reaper.GetCursorPosition() then reaper.Main_OnCommand(42409,0) --Razor edit: Enclose media items (will unselect all items)
      
      --else 
      reaper.SetEditCurPos(curpos, 1, 0)
      
      --end
      
      --SET RAZOR SELECTION TO ITEMS 
           --reaper.Main_OnCommand(42409,0) --Razor edit: Enclose media items (will unselect all items)
       
      
      --RESTORE ITEM SELECTION    
          --for i=1, itemcount do reaper.SetMediaItemInfo_Value(SelItems[i], "B_UISEL", 1) end
      
      
      
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

    
   
