--@description TJF Toggle Last Touched FX Envelope Visible and Hide all Others
--@version 1.5
--@author Tim Farrell
--
--@about
--  # TJF Toggle Last Touched FX Envelope Visible and Hide all Others
--  Will the the Envelope for your last touched parameter
--  Does not stipulate between Take or Track FX
--  Will Hide All other Visible Envelopes on the Track/Take for clarity.
--  TakeFX will update if you adjust the Parameter
--
--@changelog
--  v1.0 - nothing to report
--  v1.1 - removed BR_Env functions for all Native Reaper API
--  v1.2 - Added Ability to update value after adjusting TAKEFX - Track FX depends on automation mode
--  v1.3 - updated SetEnvelopeVis() function to prevent future breaking
--  v1.4 - Sets Last Touched Envelope as Selected when adjusting parameter
--         Take FX - Will also select all points also (for easy clear/deletion)
--  v1.4.1 Script maintainance (removed unused functions)
--  v1.5 - added support for folder trim automation visibility

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

function round(number, decimals)
    local power = 10^decimals
    return math.floor(number * power) / power
end


function GetEnvelopeVis(envelope)
    local retval, str = reaper.GetEnvelopeStateChunk( envelope, "", false )
    if retval then
        str = string.match(str, "\nVIS %d")
        str = string.match(str, "%d")
        if str=="1" then return true else return false end

    end
    --reaper.SetEnvelopeStateChunk( envelope, str, true )
 
end--EnvelopeVis()


function SetEnvelopeVis(envelope, bool)
    local retval, str = reaper.GetEnvelopeStateChunk( envelope, "VIS", false )
    if retval then
        if bool 
        then str = string.gsub(str, "\nVIS %d", "\nVIS 1")
        else str = string.gsub(str, "\nVIS %d", "\nVIS 0")
        end
    end
    reaper.SetEnvelopeStateChunk( envelope, str, true )
 
end--EnvelopeVis()



function TrackFXLastTouched(tracknumber, fxnumber, paramnumber)
              local track = reaper.CSurf_TrackFromID(tracknumber, false)
              fxvalue, minval, maxval = reaper.TrackFX_GetParam( track, fxnumber, paramnumber )
              fxvalue = round(fxvalue,7)
              envelope = reaper.GetFXEnvelope( track, fxnumber, paramnumber, false )
              if not reaper.ValidatePtr2(0, envelope, "TrackEnvelope*") or not envelope then
                  envelope = reaper.GetFXEnvelope( track, fxnumber, paramnumber, true ) 
                  created = true
              end
              local visible = not GetEnvelopeVis(envelope)

              --[[        ---------ADJUST VALUE
              if  reaper.CountEnvelopePoints( envelope ) < 2 then
                           if reaper.CountEnvelopePoints(envelope) < 1  
                           then  reaper.InsertEnvelopePointEx( envelope, -1, 0, fxvalue, 0, 0, 1, 0 )
                           end
                           
                            retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( envelope, 0 )
                             value = round(value,7)
                           if value ~= fxvalue then visible = true end
                           reaper.SetEnvelopePoint( envelope, 0, time, fxvalue, shape, tension, selected, false )
               end--if
              ]]--
                      ----------SET VISIBILITY
              for i=0,  reaper.CountTrackEnvelopes( track )  - 1 do
              
                    local env = reaper.GetTrackEnvelope( track, i )
                    local _, name = reaper.GetEnvelopeName( env )
                    local _, trackname = reaper.GetTrackName(track)
                    
                    if (name == "Trim Volume" and reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH" ) == 1 and trackname ~= "PIX" ) then SetEnvelopeVis(env, true)
                    
                    
                    elseif env~=envelope then SetEnvelopeVis(env, false)
                    elseif created then SetEnvelopeVis(env, true)
                    else SetEnvelopeVis(env, visible)
                    end
                    
              end--for
              
              reaper.SetCursorContext( 2, envelope ) -- selects envelope
              --reaper.Main_OnCommand(40332,0) -- Envelope:  Select all points
              

end--TrackFXLastTouched


function TakeFXLastTouched(tracknumber, fxnumber, paramnumber)
              local track = reaper.CSurf_TrackFromID((tracknumber & 0xFFFF), false)
              local takenumber = (fxnumber >> 16)
              fxnumber = (fxnumber & 0xFFFF)
              local item_index = (tracknumber >> 16)-1
              local item = reaper.GetTrackMediaItem(track, item_index)
              local take = reaper.GetTake(item, takenumber)
              fxvalue, minval, maxval = reaper.TakeFX_GetParam( take, fxnumber, paramnumber )
              fxvalue = round(fxvalue,7)
              local envelope = reaper.TakeFX_GetEnvelope( take, fxnumber, paramnumber, false )

              if envelope == nil then 
                    envelope = reaper.TakeFX_GetEnvelope( take, fxnumber, paramnumber, true ) 
                    created = true
              end
              
              local visible = not GetEnvelopeVis(envelope)
              
                      ---------ADJUST VALUE
              if  reaper.CountEnvelopePoints( envelope ) < 2 then
                           if reaper.CountEnvelopePoints(envelope) < 1  
                           then  reaper.InsertEnvelopePointEx( envelope, -1, 0, fxvalue, 0, 0, 1, 0 )
                           end
                           
                            retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( envelope, 0 )
                             value = round(value,7)
                           if value ~= fxvalue then visible = true end
                           reaper.SetEnvelopePoint( envelope, 0, time, fxvalue, shape, tension, selected, false )
               end--if
         
                      ----------SET VISIBILITY
              for i=0,  reaper.CountTakeEnvelopes( take )  - 1 do
              
                    local env = reaper.GetTakeEnvelope( take, i )
                    if env~=envelope then SetEnvelopeVis(env, false)
                    elseif created then --SetEnvelopeVis(env, true)
                    else SetEnvelopeVis(env, visible)
                    end
                    
              end--for
              
              reaper.SetCursorContext( 2, envelope ) -- selects envelope
              reaper.Main_OnCommand(40332,0) -- Envelope:  Select all points
              
end--TakeFXLastTouched





function Main()
      local retval, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
      if retval then
          if (tracknumber >> 16) == 0 then TrackFXLastTouched(tracknumber, fxnumber, paramnumber) -- Track FX or Input FX
          else TakeFXLastTouched(tracknumber, fxnumber, paramnumber) -- ITEM FX >>>>>
          end
      end
end--Main()


Main()
reaper.UpdateArrange()
reaper.TrackList_AdjustWindows(false)

reaper.defer(function() end) --prevent Undo
    
    
    
    
