

function GetRazorEditStart()
          retval = false  
          position = ""

          for i=0, reaper.CountTracks(0)-1 do
              _, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then 
                  retval = true
                  x = x:match "%d+.%d+"
                  
                  if position == "" then position = x
                  elseif position > x then position = x
                  end
              
              end
              
          end
          
          return retval, position

end



function Main()
    test, position = GetRazorEditStart()

    if    test
    then
          reaper.SetEditCurPos( position, true, true )
    
    end
    
    reaper.UpdateArrange()
    
    --reaper.defer(Main)
end--Main()


Main()
