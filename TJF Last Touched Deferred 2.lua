--@description TJF Show Last Touched FX Envelope and Hide all Others Deferred (STAYS ACTIVE)
--@version 1.1
--@author Tim Farrell
--
--@about
--  # TJF Show Last Touched FX Envelope and Hide all Others Deferred (STAYS ACTIVE)
--  Will the the Envelope for your last touched parameter
--  Will NOT show Envelope if it is not created
--  Does not stipulate between Take or Track FX
--  Will Hide All other Visible Envelopes on the Track/Take for clarity.
--  Stays Active in the Background and will Automatically Change envelopes as you touch parameters

--
--@changelog
--  v1.0 - nothing to report
--  v1.1 - Removed BR_ENV functions for pure reaper API



function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

function EnvelopeVis(envelope, bool)
    local retval, str = reaper.GetEnvelopeStateChunk( envelope, "VIS", false )
    if retval then
        if bool 
        then str = string.gsub(str, "VIS %d", "VIS 1")
        else str = string.gsub(str, "VIS %d", "VIS 0")
        end
    end
    reaper.SetEnvelopeStateChunk( envelope, str, true )
 
end--EnvelopeVis()





function TrackFXLastTouched(tracknumber, fxnumber, paramnumber)
              local track = reaper.CSurf_TrackFromID(tracknumber, false)
              local fxvalue, minval, maxval = reaper.TrackFX_GetParam( track, fxnumber, paramnumber )
              if fxvalue ~= oldvalue then
             
                    envelope = reaper.GetFXEnvelope( track, fxnumber, paramnumber, true )
                    if envelope ~= nil then
                            for i=0,  reaper.CountTrackEnvelopes( track ) - 1 do
                            
                                  local env = reaper.GetTrackEnvelope( track, i )
                                  if env~=envelope
                                  then EnvelopeVis(env, false)
                                  else EnvelopeVis(env, true)
                                        if  reaper.CountEnvelopePoints( envelope ) < 2 then
                                                    if reaper.CountEnvelopePoints(envelope) < 1  
                                                    then  reaper.InsertEnvelopePointEx( envelope, -1, 0, fxvalue, 0, 0, 1, 0 )
                                                    end
                                                    
                                                    local  retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( envelope, 0 )
                                                    reaper.SetEnvelopePoint( envelope, 0, time, fxvalue, shape, tension, selected, false )
                                        end--if
                                  end--if

                                  
                            end--for
                    end--if

                    oldvalue = fxvalue
                    reaper.TrackList_AdjustWindows(false)
                    
              end--if
              

end--TrackFXLastTouched


function TakeFXLastTouched(tracknumber, fxnumber, paramnumber)
              local track = reaper.CSurf_TrackFromID((tracknumber & 0xFFFF), false)
              local takenumber = (fxnumber >> 16)
              fxnumber = (fxnumber & 0xFFFF)
              local item_index = (tracknumber >> 16)-1
              local item = reaper.GetTrackMediaItem(track, item_index)
              local take = reaper.GetTake(item, takenumber)
              local fxvalue, minval, maxval = reaper.TakeFX_GetParam( take, fxnumber, paramnumber )
  
              if fxvalue ~= oldvalue then
                  --reaper.SelectAllMediaItems( 0, false )  --  These two will change your selection to just the media item you are adjusting
                  --reaper.SetMediaItemSelected( item, true )

                  local envelope = reaper.TakeFX_GetEnvelope( take, fxnumber, paramnumber, true )
    
                      if envelope ~= nil then
                          
                          for i=0,  reaper.CountTakeEnvelopes( take )  - 1 do
                          
                                local env = reaper.GetTakeEnvelope( take, i )
                                if env~=envelope  
                                then EnvelopeVis(env, false)  
                                else EnvelopeVis(env, true)
                                        if  reaper.CountEnvelopePoints( envelope ) < 2 then
                                                    if reaper.CountEnvelopePoints(envelope) < 1  
                                                    then  reaper.InsertEnvelopePointEx( envelope, -1, 0, fxvalue, 0, 0, 1, 0 )
                                                    end
                                                    
                                                    local  retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( envelope, 0 )
                                                    reaper.SetEnvelopePoint( envelope, 0, time, fxvalue, shape, tension, selected, false )
                                        end--if
                                end--if
                          end--for
                      end--if
                      oldvalue = fxvalue
                      reaper.UpdateArrange()
                  end--if
                  
              
end--TakeFXLastTouched


    
----------------------------------FUNCTION SETS COMMAND STATE FOR THIS FUNCTION
(function()
  local _, _, sectionId, cmdId = reaper.get_action_context()

  if sectionId ~= -1 then
    reaper.SetToggleCommandState(sectionId, cmdId, 1)
    reaper.RefreshToolbar2(sectionId, cmdId)

    reaper.atexit(function()
      reaper.SetToggleCommandState(sectionId, cmdId, 0)
      reaper.RefreshToolbar2(sectionId, cmdId)
    end)
  end
end)()
    
   


----------------------------------MAIN FUNCTION
function Main()
      curpos = reaper.GetCursorPosition(0)
      local retval, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
      
      if retval then

                if (tracknumber >> 16) == 0 then -- Track FX or Input FX
                      TrackFXLastTouched(tracknumber, fxnumber, paramnumber)
                else -- ITEM FX >>>>>
                      TakeFXLastTouched(tracknumber, fxnumber, paramnumber)
                end
      end

      
      reaper.defer(Main)

end--Main()

-------------------------------CALL THE SCRIPT

local oldvalue = ""

Main()    

    
    
    
    
