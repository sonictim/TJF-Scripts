--@description TJF Toggle Item Lock (matches first item)
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Toggle Item Lock (matches first item)
--  Will Toggle Item Lock, but will match all items together based on lock status of first item
--  Mimics Protools Locking Behavior
--
--@changelog
--  v1.0 - nothing to report

if reaper.GetSelectedMediaItem(0,0) then
 
 lock = reaper.GetMediaItemInfo_Value( reaper.GetSelectedMediaItem(0,0), "C_LOCK" )
 if lock == 0 then lock = 1
 else lock = 0
 end

  for i=0, reaper.CountSelectedMediaItems(0)-1 do
  reaper.SetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0,i), "C_LOCK", lock)
  
  end
  
  reaper.UpdateArrange()

end
