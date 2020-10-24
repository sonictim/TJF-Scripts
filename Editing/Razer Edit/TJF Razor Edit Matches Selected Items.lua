--reaper.Main_OnCommand(42406,0) -- Razor Edit: Clear All Areas
function SetRazorEdit(track, areaStart, areaEnd, GUID)
    if GUID == nil then GUID = '""' end
    
    --parse area string
    local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
    local str = area ~= nil and area .. ' ' or ''
    str = str .. tostring(areaStart) .. ' ' .. tostring(areaEnd) .. ' ' .. GUID
    
    local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', str, true)
    return ret
end



for i=0, reaper.CountSelectedMediaItems(0)-1 do
      item = reaper.GetSelectedMediaItem(0,i)
      track =  reaper.GetMediaItemTrack( item )
      
      itemstart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
      itemend = itemstart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
      
      SetRazorEdit(track, itemstart, itemend)
      
end

reaper.UpdateArrange()


