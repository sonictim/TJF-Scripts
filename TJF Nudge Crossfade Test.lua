item = reaper.GetSelectedMediaItem(0,0)

itemstart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
itemend = itemstart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")


 reaper.BR_SetItemEdges( item, itemstart+1, itemend+1 )
 reaper.BR_SetItemEdges( item, itemstart, itemend )

-- reaper.ApplyNudge( 0, 1, 1, 1, itemstart+.001, 0, 0 )

