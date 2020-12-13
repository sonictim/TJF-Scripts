--@description TJF Nudge Decrease Fade IN Length
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Nudge Decrease Fade IN Length
--  Decreases Fade In length by amount specified in Nudge Variable
--  
--
--@changelog
--  v1.0 - nothing to report

local nudge = 0.0105  -- 1 frame = .042




local count = reaper.CountSelectedMediaItems(0)

if count > 0 then
    for i=1, count do
    
         local item = reaper.GetSelectedMediaItem(0, i-1)
         local fadeinlen =  reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN" ) - nudge
            if fadeinlen < 0 then fadeinlen = 0 end
         local fadeinlen_auto =  reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO" ) - nudge
            if fadeinlen_auto < 0 then fadeinlen_auto = 0 end
         
         
         if fadeinlen_auto > fadeinlen then fadeinlen = fadeinlen_auto end

        
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fadeinlen)
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO", fadeinlen)

    
    end--for
    
end
