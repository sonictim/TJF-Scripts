--@description TJF Nudge Decrease Fade OUT Length
--@version 1.01
--@author Tim Farrell
--
--@about
--  # TJF Nudge Decrease Fade OUT Length
--  Decreases Fade OUT length by amount specified in Nudge Variable
--  
--
--@changelog
--  v1.0 - nothing to report
--  v1.01 - refresh arrange view after processing fades


local nudge = 0.0105  -- 1 frame = .042




local count = reaper.CountSelectedMediaItems(0)

if count > 0 then
    for i=1, count do
    
         local item = reaper.GetSelectedMediaItem(0, i-1)
         local fadeoutlen =  reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN" ) - nudge
            if fadeoutlen < 0 then fadeoutlen = 0 end
         local fadeoutlen_auto =  reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO" ) - nudge
            if fadeoutlen_auto < 0 then fadeoutlen = 0 end
         

         if fadeoutlen_auto > fadeoutlen then fadeoutlen = fadeoutlen_auto end
        

        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", fadeoutlen)
        reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO", fadeoutlen)
    
    end--for
    
end

reaper.UpdateArrange()
