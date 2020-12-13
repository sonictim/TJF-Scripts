--@description TJF Nudge Increase Fade IN Length
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Nudge Increase Fade IN Length
--  Increases Fade In length by amount specified in Nudge Variable
--  
--
--@changelog
--  v1.0 - nothing to report


local nudge = 0.0105  -- 1 frame = .042




local count = reaper.CountSelectedMediaItems(0)

if count > 0 then
    for i=1, count do
    
         local item = reaper.GetSelectedMediaItem(0, i-1)
         local fadeinlen =  reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN" )
         local fadeinlen_auto =  reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO" )
         
         if fadeinlen_auto > fadeinlen then fadeinlen = fadeinlen_auto end
        
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", fadeinlen + nudge )
        reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO", fadeinlen + nudge )
    
    end--for
    
end
