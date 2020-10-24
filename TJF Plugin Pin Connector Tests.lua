function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

--track = reaper.GetSelectedTrack(0,0)
item = reaper.GetSelectedMediaItem(0,0)
take = reaper.GetActiveTake(item)


 iosize, inputPins, outputPins = reaper.TakeFX_GetIOSize( take, 0 )
 
 pinmap, high32 = reaper.TakeFX_GetPinMappings( take, 1, 0, 0)
 
 --reaper.TakeFX_SetPinMappings( take, 1, 1, 1, 0, 0 )

