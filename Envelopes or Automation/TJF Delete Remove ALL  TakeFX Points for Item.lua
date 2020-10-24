function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end
reaper.ClearConsole()


function RemoveAllBREnvelopePoints(envelope)
                      local counter = reaper.BR_EnvCountPoints( envelope )
                      while counter >= 0 do
                          counter = counter -1
                          reaper.BR_EnvDeletePoint( envelope, counter )
                      end--while
end--RemoveAllBREnvelopePoints(envelope)





function IterateEnvelopeBackwards(take)
                      local counter = reaper.CountTakeEnvelopes( take )
                      while counter >=0 do
                          counter = counter -1
                          local envelope =  reaper.BR_EnvAlloc(reaper.GetTakeEnvelope( take, counter), false )
                          RemoveAllBREnvelopePoints(envelope)
                          reaper.BR_EnvFree(envelope, true)
                      end--while

end--IterateEnvelopeBackwards(take)



function Main()     
if reaper.GetSelectedMediaItem(0,0) then
      for i=0, reaper.CountSelectedMediaItems(0)-1 do
          local item = reaper.GetSelectedMediaItem(0,i)

          for j = 0, reaper.CountTakes(item)-1 do
                  take = reaper.GetTake( item, j )
                  IterateEnvelopeBackwards(take)
                
            end--for
      end--for
end--if
end Main()

Main()



reaper.UpdateArrange()
