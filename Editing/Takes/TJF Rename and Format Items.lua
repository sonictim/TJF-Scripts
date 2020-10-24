--@description TJF Rename and Format Items for SFX Library Cataloguing
--@version 1.0
--@author Tim Farrell
--@about
--  # TJF Rename and Format Items
--  This will help you rename and format your items to match the Skywalker Sound Naming Conventions
--  This will only affect the item, not the source file
--  Script will remember the variables you place into it based on the project you are working in.
--@changelog
--  none



function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end --Debug Mesages

function titleCase( first, rest )
   return first:upper()..rest:lower()
   --function to call later:  STRING = string.gsub(STRING, "(%a)([%w_']*)", titleCase) 
end


function main()

      ----------- COUNT ITEMS AND FILL INTO AN ARRAY
      local item = {}
      local itemcount = reaper.CountSelectedMediaItems(0)
      if itemcount < 1 then return end
      for i = 1, itemcount do item[i] = reaper.GetSelectedMediaItem(0, i-1) end --  FILL ARRAY with ITEMS
      
 

      ------------ GET/SET THE VARIABLE DEFAULTS STORED IN THE SESSION
      local project = reaper.GetExtState("TJFRename", "Project")
          if project == "" then 
              project = reaper.GetProjectName(0, 512) 
              project = string.gsub(project, ".RPP", "")
          end
          
      local category = reaper.GetExtState("TJFRename", "Category")
      
      local designer = reaper.GetExtState("TJFRename", "Designer")
          if designer == "" then designer = "TF" end
      
      local retval, name = reaper.GetSetMediaItemTakeInfo_String( reaper.GetMediaItemTake(item[1], 0), "P_NAME", "nothing", false) --get first selected item name

      
 --[[ FORMATING STRING SEARCH TESTS
      temp1 = name:match("_.*_*_")
      temp2 = name:match("^.-_")
      Msg(temp1)
      Msg(temp2)
]]--
      
      
      if project ~= "" then name = string.gsub(name, "_" .. project, "") end
      if designer ~= "" then name = string.gsub(name, "_" .. designer, "") end
      if category ~= "" then name = string.gsub(name, category .. "_", "") end
      name = string.gsub(name, ",", " ")
      name = string.gsub(name, "_", " ")
      name = string.gsub(name, ".wav", "")
      name = string.gsub(name, ".flac", "")
    
      
      local number



      ---------- GET INPUTS AND SPLIT OUT INTO VARIABLES
      local retval, userinput = reaper.GetUserInputs("RENAME AND FORMAT ITEMS", 5, "Description (FXName),Category (LongID),Designer,Project,Start Number (if any),extrawidth=250", name .. "," .. category .. "," .. designer .. "," .. project)
      if not retval then return end  -- if input is canceled, quit the script
      
      name, category, designer, project, number  = userinput:match("(.-),(.-),(.-),(.-),(.*)")
      
      
      
      
      -------FORMAT VARIABLES FOR FINAL ITEM NAME
      designer = designer:upper()
      project = project:upper()
      
      if project ~= "" then name = string.gsub(name, "_" .. project, "") end
      if designer ~= "" then name = string.gsub(name, "_" .. designer, "") end
      if category ~= "" then name = string.gsub(name, category .. "_", "") end
    
      name = string.gsub(name, "(%a)([%w_']*)", titleCase) -- title case the name string
      name = string.gsub(name, " ", "") -- remove spaces
      name = string.gsub(name, "_", "") 

      if number ~= "" then number = tonumber(number) end

      
      
      
      -------  BUILD AND ATTACH THE FINAL ITEM NAME FOR EACH ITEM IN THE ARRAY
      
      for i = 1, itemcount do
      
          local FinalName = category
          if category ~= "" then FinalName = FinalName .. "_" end
          FinalName = FinalName .. name
          if number then FinalName = FinalName .. number end
          if designer ~= "" then FinalName = FinalName .. "_" .. designer end
          if project ~= "" then FinalName = FinalName .. "_" .. project end
      
          reaper.GetSetMediaItemTakeInfo_String( reaper.GetMediaItemTake(item[i], 0), "P_NAME", FinalName, true)
          
          if number ~= "" then number = number + 1 end
          
      end--for


      --------- STORE VALUES IN SESSION FOR LATER
      reaper.SetExtState("TJFRename", "Project", project, true )
      reaper.SetExtState("TJFRename", "Designer", designer, true )
      reaper.SetExtState("TJFRename", "Category", category, true  )


end--main()




reaper.Undo_BeginBlock()

main()

reaper.Undo_EndBlock("TJF Rename", -1)



