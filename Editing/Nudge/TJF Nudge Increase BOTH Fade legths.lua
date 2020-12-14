--@description TJF Nudge Increase Both Fade Lengths
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Nudge Increase Both Fade Lengths
--  Increases both Fade In and Fade Out length by amount specified in Nudge Variable
--  
--
--@changelog
--  v1.0 - nothing to report


local nudge = 0.042 -- 1 frame = .042



local count = reaper.CountSelectedMediaItems(0)

if count > 0 then
    for i=1, count do
    
         local item = reaper.GetSelectedMediaItem(0, i-1)
         local fadeinlen =  reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN" )
         local fadeinlen_auto =  reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO" )
         local fadeoutlen =  reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN" )
         local fadeoutlen_auto =  reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO" )
         
         if fadeinlen_auto > fadeinlen then fadeinlen = fadeinlen_auto end
         if fadeoutlen_auto > fadeoutlen then fadeoutlen = fadeoutlen_auto end
        
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fadeinlen + nudge )
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO", fadeinlen + nudge )
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", fadeoutlen + nudge )
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO", fadeoutlen + nudge )
    
    end--for
    
end
