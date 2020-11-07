

function GetRazorEditBounds()
          local retval = false  
          local aStart = ""
          local aEnd = ""

          for i=0, reaper.CountTracks(0)-1 do
              local _, str = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "", false)
              if str ~= "" then 
                  retval = true
                  local x = str:match "%d+.%d+"
                  
                  if aStart == "" then aStart = x
                  elseif aStart > x then aStart = x
                  end
              
                  x = str:match('.+%s(%d+%.%d+).*$')
              
                  if aEnd == "" then aEnd = x
                  elseif aEnd < x then aEnd = x
                  end
              
              end
              
          end
          
          return retval, aStart, aEnd
end



function Main()
    test, position, endpos = GetRazorEditBounds()

    if    test
    then
          reaper.SetEditCurPos( position, true, true )
    
    end
    
    reaper.UpdateArrange()
    
    --reaper.defer(Main)
end--Main()


Main()
