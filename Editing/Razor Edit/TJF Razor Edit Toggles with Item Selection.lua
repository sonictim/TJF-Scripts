
function SetRazorEdit(track, areaStart, areaEnd, GUID)
    if GUID == nil then GUID = '""' end
    
    --parse area string
    local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
    local str = area ~= nil and area .. ' ' or ''
    str = str .. tostring(areaStart) .. ' ' .. tostring(areaEnd) .. ' ' .. GUID
    
    local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', str, true)
    return ret
end


function Main()

    local item, mousepos = reaper.BR_ItemAtMouseCursor()
    
    --reaper.SetEditCurPos(mousepos, 1, 0)
    
    
 
    if item then 
    
          selected = reaper.GetMediaItemInfo_Value(item,"B_UISEL" )
       
          if    selected == 0
          then  reaper.SetMediaItemInfo_Value(item, "B_UISEL", 1)
          else  reaper.SetMediaItemInfo_Value(item, "B_UISEL", 0)
          end--if
          
          reaper.Main_OnCommand(42406, 0) -- Razor Edit: Clear All Areas
          
          for i=0, reaper.CountSelectedMediaItems(0)-1 do
                item = reaper.GetSelectedMediaItem(0,i)
                track =  reaper.GetMediaItemTrack( item )
                
                itemstart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                itemend = itemstart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                
                SetRazorEdit(track, itemstart, itemend)
                
          end
          
          
          
    end--if




end -- Main()

Main()
