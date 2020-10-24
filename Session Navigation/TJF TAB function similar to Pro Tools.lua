--[[
@description TJF TAB function similar to Protools
@version 1.1
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 28
@about
  # Mimics Protools Tab Function.
  Will TJF Toggle Tab to Transient script which can be assigned to a button
  must be installed in the correct directory to work

--]]



function main()

local cmd_id = reaper.NamedCommandLookup("_RS5e152aaad2a4c4430bdd8392b946a35131a956a2")  --get ID of TJF Toggle Tab to Transient
local transient = reaper.GetToggleCommandStateEx(0,cmd_id)  -- get command state

reaper.Main_OnCommand(41229, 0)  --Calls command "Selection set: Save set #01"
reaper.Main_OnCommand(40421, 0)  --Calls command "Item: Select all items in track"


    if transient==1 then

       reaper.Main_OnCommand(40375, 0) --Calls command "Item navigation: Move cursor to next transient in items"

    else


      reaper.Main_OnCommand(40319, 0)  --Calls command "Item navigation: Move cursor right to edge of item"

    end

    reaper.Main_OnCommand(41239, 0)  --Calls command "Selection set: Load set #01"

end


main()
--reaper.UpdateTimeline()

reaper.defer(function() end) --this prevents undo
