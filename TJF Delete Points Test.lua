function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end
reaper.ClearConsole()


function RemoveAllBREnvelopePoints(envelope)
                      local counter =  reaper.CountEnvelopePoints( envelope )
                      while counter > 0 do
                          counter = counter -1
                          reaper.DeleteEnvelopePointEx( envelope, -1, counter )
                      end--while
end--RemoveAllBREnvelopePoints(envelope)





function IterateEnvelopeBackwards(take)
      
                      local counter = reaper.CountTakeEnvelopes( take )
                      while counter >0 do
                          counter = counter -1
                          local envelope = 

                          RemoveAllBREnvelopePoints(reaper.GetTakeEnvelope( take, counter))

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
