item = reaper.GetSelectedMediaItem(0,0)
track = reaper.GetSelectedTrack(0,0)

retval, str = reaper.GetItemStateChunk( item, "", false )
 
MatchChunk = "(%c>)$"
 
VolChunk=[[
 <VOLENV
 EGUID ]]..reaper.genGuid("")..[[ 
 ACT 1 -1
 VIS 1 1 1
 LANEHEIGHT 0 0
 ARM 1
 DEFSHAPE 0 -1 -1
 VOLTYPE 1
 PT 0 1 0
 >]]
 
 
--str = "The number 777 is in the middle" 
 
--str =  str:match('number(.*)middle$')

str =  str:match('(<ITEM.*)>.-$')

str =  str .. VolChunk

 
--str = str:gsub(MatchChunk,  VolChunk)
 
reaper.SetItemStateChunk( item, str, false )


reaper.ClearConsole()
reaper.ShowConsoleMsg(str)














 
reaper.UpdateTimeline()
