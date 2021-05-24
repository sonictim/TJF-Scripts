ConvertToTitleCase = true

reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end --Debug Mesages




function getUCSCatIDList()

            local CatID = {}
            local UCSfile = "/Volumes/TJF Library 8tb SSD/Soundminer V5 Support/_categorylist.csv"
            local file = io.open(UCSfile, "r") -- open in read mode
            
            
            io.input(file)
            
            for line in io.lines() do
                local  _, _, catid, _  = line:match("(.-),(.-),(.-),(.*)")
                table.insert(CatID, catid)
            end
            
            
            io.close(file)
            
            return CatID
end

 
     
function searchCatIDs(table, cat)

              for key, value in pairs(table) do
                      if value == cat then
                        return value
                      end
              end
              
              return false


end
     
     
function Main()     
     
              local currentItem = reaper.GetSelectedMediaItem(0,0)

              local CatIDs = getUCSCatIDList()
              local category, fxname, designer, project, extra
  
              if currentItem then
              local _, name = reaper.GetSetMediaItemTakeInfo_String(reaper.GetActiveTake(reaper.GetSelectedMediaItem(0,0)), "P_NAME", "nothing", false) --get first selected item name
              else
              name = ""
              end
              
              name = string.gsub(name, "-Glued", "")
              name = string.gsub(name, "-glued", "")
              name = string.gsub(name, ".wav", "")
              name = string.gsub(name, ".flac", "")
              
              
              test1 = string.match(name, "_(.*)")
              test1 = string.gsub(test1, "_.*", "")
              test2 = string.match(name, "_.-_(.*)")
              test2 = string.gsub(test2, "_.*", "")
              
              category = name:match("(.-)_")
              
              if not searchCatIDs(CatIDs, category) then
              
                    category = ""
                    fxname = name
                    
              else
                    category, fxname, designer, project = name:match("(.-)_(.-)_(.-)_(.*)")
                    extra =     name:match(".-_.-_.-_.-_(.*)")
                    if extra then 
                      
                          project = string.gsub(project, extra)
                          
                          fxname = fxname .. " " .. extra
                    end
              
              end

    
              
              
              ------------ GET/SET THE VARIABLE DEFAULTS STORED IN THE SESSION
              if project == "" then
              
                    project = reaper.GetExtState("TJFRename", "Project")
                        if project == "" then 
                            project = reaper.GetProjectName(0, 512) 
                            project = string.gsub(project, ".RPP", "")
                        end
              end
              
                  
        
              if designer == "" then
                    designer = reaper.GetExtState("TJFRename", "Designer")
                        if designer == "" then designer = defaultDesigner end
              end
              
              
              
              if category == "" then
                    category = reaper.GetExtState("TJFRename", "Category")
              
              end
              
       
              
      ------------ CLEAN UP UNDESIREABLE CHARACTERS
      if project ~= nil then fxname = string.gsub(fxname, project, "") end
      if designer ~= nil then fxname = string.gsub(fxname, designer, "") end
      if category ~= nil then fxname = string.gsub(fxname, category .. "_", "") end
      
      if ConvertToTitleCase then fxname = string.gsub(fxname, "(%l)(%u)", "%1 %2") end -- expand title case
      if ConvertToTitleCase then fxname = string.gsub(fxname, "(%s%u)(%u)", "%1 %2") end -- fix single letter words
      if ConvertToTitleCase then fxname = string.gsub(fxname, "(%a)(%d)", "%1 %2") end
      if ConvertToTitleCase then fxname = string.gsub(fxname, "(%d)(%a)", "%1 %2") end
      fxname = string.gsub(fxname, ",", " ")
      fxname = string.gsub(fxname, "_", " ")
      fxname = string.gsub(fxname, "-", " ")
      
      
      _, number = fxname:match("^(.+)%D(%d+).-$")
      if number ~= "" then fxname = string.gsub(fxname, "^(.*%D)%d+(.-)$" , "%1") end
      if number == "" then number = name:match("^.*(%d+).-$") end
      --number = tostring(number)
      --if number == "nil" then number = "" end
      
      fxname = string.gsub(fxname, "%s+", " ") -- removes excess spaces
      
              
              Msg("Item Name: " .. name)
              Msg("CatID " .. category)
              Msg("FXName: " .. fxname)
              Msg("Number: " .. number)
              Msg("Designer " .. designer)
              Msg("Project " .. project)
             
              
end -- Main()


Main()



  


