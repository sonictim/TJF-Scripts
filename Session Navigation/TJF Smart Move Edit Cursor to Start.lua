--@description TJF Smart Move Edit Cursor to Start
--@version 1.0
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Smart Move Edit Cursor to Start
--
--  Moves Edit Cursor to the Start of Time Selection, Razor Edits, Items in that order of priority
--  Additional Setting: PROJECT
--  Edit Script to adjust this variable.  If TRUE and no selection, will move cursor to Start of Project


--  DISCLAIMER:
--  This script was written for my own personal use and therefore I offer no support of any kind.
--  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--  I strongly recommend never to run this or any other script I've written for any reason what so ever.
--  Ignore this advice at your own peril!
  
  

--@changelog
--  v1.0 - nothing to report


    --[[------------------------------[[---
                    SETTINGS               
    ---]]------------------------------]]--

PROJECT = false    
      --if true then will move edit cursor to Start of Project if there is no Selection of any kind
      --default is false      
        
    --[[------------------------------[[---
                   FUNCTIONS               
    ---]]------------------------------]]--

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

    --[[------------------------------[[--
                        MAIN          
    --]]------------------------------]]--

function Main()

    local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
    local test, aStart, aEnd = GetRazorEditBounds()

    if start_time ~= end_time then reaper.Main_OnCommand(40630,0) -- go to start of time selection
    elseif test then reaper.SetEditCurPos( aStart, true, true )
    elseif reaper.GetSelectedMediaItem(0,0) then reaper.Main_OnCommand(41173, 0) -- go to start of items
    elseif PROJECT then reaper.Main_OnCommand(40042, 0) -- go to start of project
            
    end
    
    reaper.UpdateArrange()
    
    --if PERSIST then reaper.defer(Main) end
end

    --[[------------------------------[[--
                   CALL THE SCRIPT          
    --]]------------------------------]]--

Main()
