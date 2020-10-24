--@description TJF Select Items withing Time Selection on Selected Tracks
--@version 1.0
--@author Tim Farrell
--
--@about
--  #TJF Select Items withing Time Selection on Selected Tracks
--  Will select all items that start or end within the time selection on selected tracks
--
--@changelog
--  v1.0 - nothing to report


----------------------------------
--          DEBUG               --
----------------------------------

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end


----------------------------------
--         FUNCTIONS            --
----------------------------------

function GetSelections()  -- goes through each item on the selected tracks and determines if it falls within the time selection

    local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
    
    if start_time ~= end_time then
    
          local items = {}
          
          for t=0, reaper.CountSelectedTracks(0)-1 do
          
              local track = reaper.GetSelectedTrack(0,t)
          
              for i=0,  reaper.CountTrackMediaItems( track )-1 do
              
                  local item =  reaper.GetTrackMediaItem( track, i)
                  local istart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                  local iend = istart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                  if      (istart >= start_time and istart <= end_time) or  (iend >= start_time and iend <= end_time)
                  then
                          table.insert(items, item)
                  end--if
              end--for
          end--for
          
          return items
    else
    
          return false
          
    end

end--GetSelections

function CheckItems(items)  -- checks if any items in the table are currently unselected.  if any are unselected, returns true, otherwise, will return false

    for i=1, #items do
    
          if not reaper.IsMediaItemSelected( items[i] ) then return true end
    
    end--for
    
    return false


end


function ProcessItems(items, bool)  -- loops through items and sets selected based on bool parameter

    for i=1, #items do
    
          reaper.SetMediaItemSelected( items[i], bool )
    
    end
end


----------------------------------
--           MAIN               --
----------------------------------
function Main()

  reaper.SelectAllMediaItems( 0, false )  -- clears current item selections

  local items = GetSelections() -- get items that fall within the time range
  
  if items then
  
      ProcessItems(items, CheckItems(items))  -- select (or deselct) items
  
  end


end--Main()


----------------------------------
--        CALL SCRIPT           --
----------------------------------

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
reaper.PreventUIRefresh(-1) -- uncomment only once script works
reaper.UpdateArrange()

reaper.Undo_EndBlock("TJF Select Items withing Time Selection on Selected Tracks", -1)


    
   
