--[[
@description TJF Toggle Volume Envelope Visible for Track or Items
@version 2.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Toggle Volume Envelope Visible for Track or Items
  Will Toggle Volume Envelope Visibility for all selected Items, or Tracks if no items selected.
  Toggle will match toggle of first item selected
  
@changelog
  v1.2 added ability to hide ALL active envelopes for track
  v1.2.1 speed adjustments
  v2.0 logic rework
--]]



----------------------------------DEBUG MESSAGES FUNCTION

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



----------------------------------SET COMMON VARIABLES

    Envelope = "Volume"
    
    local item = {}
    local itemcount = reaper.CountSelectedMediaItems(0)
    for i = 1, itemcount do item[i] = reaper.GetSelectedMediaItem(0, i-1) end --  FILL ITEM ARRAY
    
    local track = {}
    local trackcount = reaper.CountSelectedTracks(0)
    for i = 1, trackcount do track[i] = reaper.GetSelectedTrack(0, i-1) end   -- FILL TRACK ARRAY

    local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
                                                                        --second false chooses time or loop points
    
    local curpos =  reaper.GetCursorPosition()  --Get current cursor position

    function take(param) return reaper.GetActiveTake(item[param]) end  --can call take function to match take to item
    
 
    
    
    
----------------------------------CHECK IF ANY TAKES HAVE ENVELOPE VISIBLE

function AnyTakeEnvVisible(param)  -- Param is Envelop to Check ("Volume", "Pan", or "Pitch"
    
          for i=1, itemcount do
          
              
              local NamedEnv = reaper.GetTakeEnvelopeByName(take(i), param)
              
              if NamedEnv then
              
                  local brTakeEnv = reaper.BR_EnvAlloc(NamedEnv,true)
                  local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, taketype, faderScaling, automationItemsOptions = reaper.BR_EnvGetProperties(brTakeEnv)
                  reaper.BR_EnvFree(brTakeEnv, true )
                  
                  if visible then return true end
                  
              end--if

          end--for
          

end--AnyTakeEnvVisible  



----------------------------------TOGGLE TAKE ENVELOPES

function ToggleTakeEnvelope(param) -- Toggles the take envelope visibility Volume, Pan, or Pitch       
          
              local GlobalVisible = not AnyTakeEnvVisible(param)
              
              local ActivateNewEnvelope = false
              
              for i=1, itemcount do  --For each item do
              
                    
                      local NamedEnv = reaper.GetTakeEnvelopeByName(take(i), param)  -- assign our watched envelope
                      
                      if NamedEnv then  reaper.SetMediaItemInfo_Value( item[i], "B_UISEL", 0 ) 
                      
                                  else
                      
                                        ActivateNewEnvelope = true
                      
                      end  -- if named envelope exists.. unselect item in timeline
                    
                    
                    
                    
                      local takeEnvCount = reaper.CountTakeEnvelopes(take(i))
                      
                      for j=0, takeEnvCount-1 do  -- for each take envelope for this item do
              
              
                                    local OtherEnv =  reaper.GetTakeEnvelope(take(i), j)
                                     
                                    local brTakeEnv = reaper.BR_EnvAlloc(OtherEnv,true)
                                    
                                    local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, taketype, faderScaling, automationItemsOptions = reaper.BR_EnvGetProperties(brTakeEnv)
                                         
                                    if OtherEnv == NamedEnv then
                                    
                                          visible = GlobalVisible
                                         
                                        else
                                        
                                          visible = false
                                          
                                    end--if
                                         
                                         reaper.BR_EnvSetProperties(brTakeEnv, active, visible, armed, inLane, laneHeight, defaultShape, faderScaling)
                                         reaper.BR_EnvFree(brTakeEnv, true )
                        end--for
                        
                end--for
                
                        
                       
                if GlobalVisible == true and ActivateNewEnvelope == true then   --  Activate inactive envelopes
                       
                          if param == "Volume" then reaper.Main_OnCommand(40693, 0)  end --toggle take volume envelope
                          if param == "Pan" then reaper.Main_OnCommand(40694, 0) end -- toggle take pan envelope
                          if param == "Pitch" then reaper.Main_OnCommand(41612, 0) end -- toggle take pitch envelope       
                           
                end--if
                       
                
                for i=1, itemcount do  reaper.SetMediaItemInfo_Value( item[i], "B_UISEL", 1 ) end  --reselect all items
                
end--ToggleTakeEnvelope(param)





----------------------------------TOGGLE TRACK ENVELOPES

function toggletrackvisible(param)

if not trackcount then return end



      for i = 1, trackcount do
          local NamedEnv = reaper.GetTrackEnvelopeByName(track[i], param)
          
          if NamedEnv then
          
              reaper.SetMediaTrackInfo_Value(track[i], "I_SELECTED", 0)
          
          else if i==1 then local GlobalVisible = true end

         end --if
         
      end--for
    
    if param == "Volume" then reaper.Main_OnCommand(40406, 0) end --toggle track volume envelope visible

    if param == "Pan" then reaper.Main_OnCommand(40407, 0) end --toggle track pan envelope visible
    
    
    
    for i = 1, trackcount do
    
                reaper.SetMediaTrackInfo_Value(track[i], "I_SELECTED", 1)
                
                local NamedEnv = reaper.GetTrackEnvelopeByName(track[i], param)
                local EnvCount = reaper.CountTrackEnvelopes(track[i])
               
                for j=0, EnvCount-1 do
                    local NewEnv = reaper.GetTrackEnvelope(track[i], j)
                    
                    if NewEnv == NamedEnv then 
                          local brTakeEnv = reaper.BR_EnvAlloc(NamedEnv,true)
                          local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, taketype, faderScaling, automationItemsOptions = reaper.BR_EnvGetProperties(brTakeEnv)
                          
                          if i==1 and GlobalVisible == nil then  GlobalVisible = not visible end
                               
                          reaper.BR_EnvSetProperties(brTakeEnv, active, GlobalVisible, armed, inLane, laneHeight, defaultShape, faderScaling)
                          reaper.BR_EnvFree(brTakeEnv, true )
                          
                    else
                    
                          local brTakeEnv = reaper.BR_EnvAlloc(NewEnv,true)
                          local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, taketype, faderScaling, automationItemsOptions = reaper.BR_EnvGetProperties(brTakeEnv)
                          reaper.BR_EnvSetProperties(brTakeEnv, active, false, armed, inLane, laneHeight, defaultShape, faderScaling)
                          reaper.BR_EnvFree(brTakeEnv, true )
                                 
                    end--if
                    
                  
                end--for     
                
    end--for


end--toggletrackvisible()


                



----------------------------------MAIN FUNCTION
function Main()

    if  itemcount > 0 then

        ToggleTakeEnvelope(Envelope)

    else

        toggletrackvisible(Envelope)

    end--if

end--main()


----------------------------------CALL THE SCRIPT

--reaper.ShowConsoleMsg("")  --reset console window
--reaper.Undo_BeginBlock()
Main()
--reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.Undo_EndBlock("TJF Script Name", -1)

reaper.defer(function() end) --prevent Undo

    
   
