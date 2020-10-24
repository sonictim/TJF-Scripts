--@description TJF Script Name
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Script Name
--  Information about the script
--
--@changelog
--  v1.0 - nothing to report


----------------------------------COMMON FUNCTIONS or FUNCTIONS I WANT TO REMEMBER

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

--[[      CONVERT TEXT TO TITLE CASE
function titleCase( first, rest ) return first:upper()..rest:lower() end
   --How to call in script:  STRING = string.gsub(STRING, "(%a)([%w_']*)", titleCase) 
]]--




----------------------------------SET COMMON VARIABLES

     item = {}
     itemcount = reaper.CountSelectedMediaItems(0)
    
    

function take(param) return reaper.GetActiveTake(item[param]) end  --can call take function to match take to item


function itemfilename(param)
    return reaper.GetMediaSourceFileName(reaper.GetMediaItemTake_Source(reaper.GetMediaItemTake(param, reaper.CountTakes(param) - 1)), '')
end


function filteruniqueitems()

      local totalunique = 0
      local filenameString = " "

      for i=0, itemcount-1 do
      
          local currentItem = reaper.GetSelectedMediaItem(0,i)
          filename = itemfilename(currentItem)
          
          if not string.find(filenameString, filename) then
          
              filenameString = filenameString .. filename
              totalunique = totalunique + 1
              item[totalunique] = currentItem
          
          end--if
      
          
      end--for
      
      itemcount = totalunique
      
end




----------------------------------MAIN FUNCTION
function Main()


filteruniqueitems()

      










end--Main()


----------------------------------CALL THE SCRIPT

--reaper.ShowConsoleMsg("")  --reset console window
reaper.Undo_BeginBlock()
Main()
reaper.UpdateArrange()
--reaper.UpdateTimeline()
reaper.Undo_EndBlock("TJF Script Name", -1)

--reaper.defer(function() end) --prevent Undo

    
   
