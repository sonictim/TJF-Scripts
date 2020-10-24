--@description TJF Punch Write Envelope Points to all Visible Envelopes to Time Selection or Selected Items
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Punch Write Envelope Points to all Visible Envelopes to Time Selection or Selected Items
--  Mimic's Protools CMD + /
--  Will Set all VISIBLE TakeFX Envelopes to Time Selection Start Value or Edit Cursor Value or Item Starting Value if Edit Cursor is not in Item
--  TAKE VOLUME: There is an ERROR in SWS and this will not work with TAKE VOLUME until you update to latest SWS
--  Lasted SWS can be found here:  https://www.sws-extension.org/download/pre-release/
--
--
--
--@changelog
--  v1.0 - nothing to report





-------------------
--    DEBUG      --
-------------------

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end
reaper.ClearConsole()



------------------
--  FUNCTIONS   --
------------------


function ProcessEnvelope(envelope, pointstart, pointend)
      local curpos = reaper.GetCursorPosition(0)
      local envelope =  reaper.BR_EnvAlloc(envelope, true )
      local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling, automationItemsOptions = reaper.BR_EnvGetProperties( envelope )
      if visible then
          reaper.BR_EnvSetProperties( envelope, true, visible, true, inLane, laneHeight, defaultShape, faderScaling )
          
          local endval = reaper.BR_EnvValueAtPos( envelope, pointend+.01 )
          local startval = reaper.BR_EnvValueAtPos( envelope, pointstart )
          local startval2 = reaper.BR_EnvValueAtPos( envelope, pointstart-.01 )
          if curpos >= pointstart and curpos <= pointend then startval = reaper.BR_EnvValueAtPos( envelope, curpos ) end
                            
          local counter = reaper.BR_EnvCountPoints( envelope )
          while counter >= 0 do
                counter = counter -1
                local retval, position, value, shape, selected, bezier = reaper.BR_EnvGetPoint( envelope, counter )
                                
                if (position > pointstart-.01 and position < pointend+.02)
                then reaper.BR_EnvDeletePoint( envelope, counter ) end
          end--while
        

          reaper.BR_EnvSetPoint( envelope, -1, pointstart, startval, 0, true, 0 )
          reaper.BR_EnvSetPoint( envelope, -1, pointend, startval, 0, true, 0 )
          if endval ~= startval then reaper.BR_EnvSetPoint( envelope, -1, pointend+.01, endval, 0, true, 0 ) end
          if startval2 ~= startval then reaper.BR_EnvSetPoint( envelope, -1, pointstart-.01, startval2, 0, true, 0 )end             
      end--if
      reaper.BR_EnvFree(envelope, true)
end--ProcessEnvelope()










------------------
--    MAIN      --
------------------
function Main()


local starttime, endtime = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds

if starttime ~= endtime then   -- if there is a time selection, process all selected tracks/track envelopes

    for i=0, reaper.CountSelectedTracks(0)-1 do
        local track =  reaper.GetSelectedTrack(0, i)
        for j=0, reaper.CountTrackEnvelopes(track)-1 do
             ProcessEnvelope( reaper.GetTrackEnvelope( track, j ), starttime, endtime)
        end--for j
    end--for i
    
end


      
if reaper.GetSelectedMediaItem(0,0) then
      for i=0, reaper.CountSelectedMediaItems(0)-1 do  
                        ------------------------------------LOGIC FOR SETTING START AND END POINTS
      
                  local item = reaper.GetSelectedMediaItem(0,i)
                  local itemstart = reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                  local itemend = itemstart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                  
                  local pointstart = starttime  -- set points to time selection
                  local pointend = endtime
                  
                  if pointstart == pointend then  -- if there is no time selection
                      pointstart = itemstart 
                      pointend = itemend   
                  end
                        -----------------------------------ITERATE THROUGH TRACK ENVELOPES                  
                  local track =  reaper.GetMediaItem_Track( item )
                  for j=0, reaper.CountTrackEnvelopes(track)-1 do
                       ProcessEnvelope( reaper.GetTrackEnvelope( track, j ), pointstart, pointend)
                  end--for j
                  
                  
                 
                        -----------------------------------ITERATE THROUGH TAKE ENVELOPES
                  if itemstart > starttime then pointstart = itemstart end
                  if itemend < endtime then pointend = itemend end      
                        
                  for j = 0, reaper.CountTakes(item)-1 do
                      take = reaper.GetTake( item, j )
                      
                      for k=0,  reaper.CountTakeEnvelopes( take )-1 do
                          ProcessEnvelope(reaper.GetTakeEnvelope( take, k), pointstart, pointend)
                      end--for k
          
                  end--for j
      end--for i
end--if
end--Main()


-----------------------
--    RUN SCRIPT     --
-----------------------

reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("TJF Punch Visible Envelopes",0)
reaper.UpdateArrange()
