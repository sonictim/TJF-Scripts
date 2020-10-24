
envelope = reaper.GetSelectedEnvelope(0)

_, name =  reaper.GetEnvelopeName( envelope )


     AutoItems = {}
     AutoItemCount = reaper.CountAutomationItems(envelope)
     
     if AutoItemCount > 0 then
     
        for i=0, AutoItemCount-1 do
        
            istart =  reaper.GetSetAutomationItemInfo( envelope, i, "D_POSITION", 0, false )
            ilen = reaper.GetSetAutomationItemInfo( envelope, i, "D_LENGTH", 0, false )
            
            reaper.InsertEnvelopePointEx( envelope, i, istart + (ilen / 2) , 500, 0, 1, 0, true )
            
            reaper.Envelope_SortPointsEx( envelope, i )
            
            
            
            
            
            --if      (istart >= starttime and istart < endtime)
            --    or  (iend > starttime and iend <= endtime)
            --    or  (istart < starttime and iend > endtime)
            --then
            
                table.insert(AutoItems, i)
            --end
        
        end
    end
        
    if #AutoItems == 0 then AutoItems = {-1} end
    
    for i=1, #AutoItems do
    
        --reaper.InsertEnvelopePointEx( envelope, AutoItems[i], 1, 500, 0, 1, 0, true )
        --reaper.InsertEnvelopePointEx( envelope, i, pointend, value, 0, 1, 0, true )
    
    
    
    end
     
     

     







function ProcessEnvelope(envelope, pointstart, pointend, curpos, value)
    
    if CheckEnvelope(envelope)
    then
        
        
        
        
       local _, startvalue = reaper.Envelope_Evaluate( envelope, pointstart, 48000, 0 )
       local _, endvalue = reaper.Envelope_Evaluate( envelope, pointend, 48000, 0 )
       local _, smoothstart = reaper.Envelope_Evaluate( envelope, pointstart-Smoothing, 48000, 0 )
       local _, smoothend = reaper.Envelope_Evaluate( envelope, pointend+Smoothing, 48000, 0 )

       if not value 
       then   
       
              if    CheckEditCursor --and curpos >= pointstart and curpos <= pointend 
              then
                    _, value = reaper.Envelope_Evaluate( envelope, curpos, 48000, 0 )

              else
                    value = startvalue
              end
       end
       
       --AutoItems = GetAutoItems(envelope, pointstart, pointend)
       local AutoItemCount = reaper.CountAutomationItems(envelope)  -- Need to work on this more
       
       for i=-1, AutoItemCount-1 do
       
           reaper.DeleteEnvelopePointRangeEx( envelope, i, pointstart-Smoothing, pointend+Smoothing )
           reaper.InsertEnvelopePointEx( envelope, i, pointstart, value, 0, 1, 0, true )
           reaper.InsertEnvelopePointEx( envelope, i, pointend, value, 0, 1, 0, true )
           
           if value ~= startvalue
           then
              reaper.InsertEnvelopePointEx( envelope, i, pointstart-Smoothing, smoothstart, 0, 1, 0, true )
           end
           
           
           if   value ~= endvalue 
           then
                reaper.InsertEnvelopePointEx( envelope, i, pointend+Smoothing, smoothend, 0, 1, 0, true )    
           end
       
       end
      
       reaper.Envelope_SortPoints( envelope )
   
   end--if

end--ProcessEnvelope
