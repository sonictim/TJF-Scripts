--@description TJF Move Edit Cursor to Start of Razor Edits
--@version 1.0
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Move Edit Cursor to Start of Razor Edits
--
--  Title is pretty self explanatory.
--  There is a setting inside the script that will change the function to automatically move the cursor upon razor edit creation
--
--
--  DISCLAIMER:
--  This script was written for my own personal use and therefore I offer no support of any kind.
--  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--  I strongly recommend never to run this or any other script I've written for any reason what so ever.
--  Ignore this advice at your own peril!
--
--
--@changelog
--  v1.0 - nothing to report

    
    --[[------------------------------[[---
                    SETTINGS               
    ---]]------------------------------]]--
    
    PERSIST = false
        --if true then this beomes a deferred functiont that remains active and will automatically move your edit cursor to your razor edits if they exist
        --if false, then this is a one shot function
        --Default is false
        
    --[[------------------------------[[---
                   FUNCTIONS               
    ---]]------------------------------]]--

function GetRazorEditStart()
          local retval = false  
          local position = ""

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

    --[[------------------------------[[--
                        MAIN          
    --]]------------------------------]]--

function Main()
    local test, position = GetRazorEditStart()

    if    test
    then
          reaper.SetEditCurPos( position, true, true )
    
    end
    
    reaper.UpdateArrange()
    
    if PERSIST then reaper.defer(Main) end
end

    --[[------------------------------[[--
                   CALL THE SCRIPT          
    --]]------------------------------]]--

Main()
