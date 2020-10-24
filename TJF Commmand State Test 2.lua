function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end 

reaper.ClearConsole()
 
local State = reaper.GetToggleCommandState( reaper.NamedCommandLookup("_RSc57e3a1ee76817d514d77be2841470f57eba9961") )
 
 
local retval, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
 
 
local item = reaper.GetSelectedMediaItem(0,0)
 
local take = reaper.GetTake(item, 0)

count = reaper.CountTakeEnvelopes(take)
 
 
for i=0, reaper.TakeFX_GetCount( take )-1 do
    for j=0, reaper.TakeFX_GetNumParams( take, i )-1 do
        local envelope = reaper.BR_EnvAlloc(reaper.TakeFX_GetEnvelope( take, i, j, 0 ), false )
        if envelope then
            retval, buf = reaper.TakeFX_GetFXName( take, i, buf )
            local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, taketype, faderScaling, automationItemsOptions = reaper.BR_EnvGetProperties(envelope)
            Msg(visible)
            reaper.BR_EnvSetProperties(envelope, active, false, armed, inLane, laneHeight, defaultShape, faderScaling)
            active, visible = reaper.BR_EnvGetProperties(envelope)
            Msg(visible)
            
            
            
            reaper.BR_EnvSetPoint( envelope, -1, 0,1, 1, 1, 1 )
            
            
            
            test = reaper.BR_EnvFree(envelope, false )
        end--if
    end--for
end--for
 
 reaper.UpdateTimeline()

 
 
