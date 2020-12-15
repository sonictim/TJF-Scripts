--@description TJF Nudge Decrease Both Fade Lengths
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Nudge Decrease Both Fade Lengths
--  Decreases both Fade In and Fade Out length by amount specified in Nudge Variable
--  
--
--@changelog
--  v1.0 - nothing to report



local nudge = 0.042 -- 1 frame = .042



local count = reaper.CountSelectedMediaItems(0)

if count > 0 then
    for i=1, count do
    
         local item = reaper.GetSelectedMediaItem(0, i-1)
         local fadeinlen =  reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN" ) - nudge
            if fadeinlen < 0 then fadeinlen = 0 end
         local fadeinlen_auto =  reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO" ) - nudge
            if fadeinlen_auto < 0 then fadeinlen_auto = 0 end
         local fadeoutlen =  reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN" ) - nudge
            if fadeoutlen < 0 then fadeoutlen = 0 end
         local fadeoutlen_auto =  reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO" ) - nudge
            if fadeoutlen_auto < 0 then fadeoutlen = 0 end
         
         
         if fadeinlen_auto > fadeinlen then fadeinlen = fadeinlen_auto end
         if fadeoutlen_auto > fadeoutlen then fadeoutlen = fadeoutlen_auto end
        
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fadeinlen)
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO", fadeinlen)
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", fadeoutlen)
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO", fadeoutlen)
    
    end--for
    
end

reaper.UpdateArrange()
