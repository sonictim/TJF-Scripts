 function ProcessEnvelope(envelope, pointstart, pointend, value)
       local curpos = reaper.GetCursorPosition(0)
       _, startvalue = reaper.Envelope_Evaluate( envelope, pointstart, 48000, 0 )
       _, endvalue = reaper.Envelope_Evaluate( envelope, pointend, 48000, 0 )
       if not value then  value = startvalue end
       
       reaper.DeleteEnvelopePointRange( envelope, pointstart-.01, pointend+.01 )
       reaper.InsertEnvelopePoint( envelope, pointstart, value, 0, 1, 0, true )
       reaper.InsertEnvelopePoint( envelope, pointend, value, 0, 1, 0, true )
       
       if value ~= startvalue
       then
          reaper.InsertEnvelopePoint( envelope, pointstart-.01, startvalue, 0, 1, 0, true )
       end
       
       
       if value ~= endvalue 
       then
          reaper.InsertEnvelopePoint( envelope, pointend+.01, endvalue, 0, 1, 0, true )    
       end
       
       
       
       reaper.Envelope_SortPoints( envelope )
end
       
       
item = reaper.GetSelectedMediaItem(0,0)
take = reaper.GetActiveTake(item)
itemstart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
itemlen = reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
itemend = itemstart + itemlen
                  
envelope = reaper.GetTakeEnvelopeByName( take, "Volume" )
--envelope =  reaper.GetTakeEnvelope( take, 0 )
      
starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)

--envelope =  reaper.GetSelectedEnvelope( 0 )

curpos = reaper.GetCursorPosition()

samplerate = reaper.GetSetProjectInfo( 0, "RENDER_SRATE", 0 , false )

--retval, value, dVdS, ddVdS, dddVdS = reaper.Envelope_Evaluate( envelope, curpos, 0, 0 )

ProcessEnvelope(envelope, starttime - itemstart, endtime-itemstart)
 
 
       
       
      
