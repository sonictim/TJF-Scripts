--@description TJF Rename and Format Items and SOURCE for SFX Library Cataloguing
--@version 2.1
--@author Tim Farrell
--@about
--  # TJF Rename and Format Items and SOURCE
--  This will help you rename and format your items to match the UNIVERSAL CATEGORY LIST Naming Conventions
--  This will only affect the item, not the source file
--  Script will remember the variables you place into it based on the project you are working in.
--@changelog
--  v1.0  Initial release
--  v2.0  Updated to process via Chunks
--  v2.1  User can decide if they want to rename the actual file also


 
      
----Global Variables
      
      local oldFilenameString = " "        



function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end --Debug Mesages

function take(param) return reaper.GetActiveTake(item[param]) end  --can call take function to match take to item


function titleCase( first, rest )
         return first:upper()..rest:lower()
         --function to call later:  STRING = string.gsub(STRING, "(%a)([%w_']*)", titleCase) 
end

function GetFileExtension(url)
        local str = url
        local temp = ""
        local result = "." -- ! Remove the dot here to ONLY get the extension, eg. jpg without a dot. The dot is added because Download() expects a file type with a dot.
      
        for i = str:len(), 1, -1 do
          if str:sub(i,i) ~= "." then
            temp = temp..str:sub(i,i)
          else
            break
          end
        end
      
        -- Reverse order of full file name
        for j = temp:len(), 1, -1 do
          result = result..temp:sub(j,j)
        end
      
        return result
end



function file_exists(name)
       local f=io.open(name,"r")
       if f~=nil then io.close(f) return true else return false end
end




function itemfilename(item)

    local take = reaper.GetActiveTake(item)
    local source = reaper.GetMediaItemTake_Source(take)
    local parentsource =  reaper.GetMediaSourceParent( source ) -- PCM SOURCE FOR REVERSED ITEMS
    local filename = reaper.GetMediaSourceFileName(source, '')
    if filename == "" then filename = reaper.GetMediaSourceFileName(parentsource, '') end
    return filename
    
end





function filteruniqueitems()  -- THIS WILL FILL AN ARRAY WITH ONLY ITEMS WITH UNIQUE SOURCE
      local unique = {}
      local totalunique = 0
      

      for i=0, reaper.CountSelectedMediaItems(0)-1 do
      
          local currentItem = reaper.GetSelectedMediaItem(0,i)
          local filename = itemfilename(currentItem)
          local path = filename:match('^(.+[\\/])')
          local extension = GetFileExtension(filename)
          
          if not string.find(oldFilenameString, filename) then
          
              oldFilenameString = oldFilenameString .. filename
              totalunique = totalunique + 1
              unique[totalunique] = currentItem

          end--if
      
          
      end--for
      
      return unique
      
end


function GetInput(items)
      local newTakeName = {}

      ------------ GET/SET THE VARIABLE DEFAULTS STORED IN THE SESSION
      local project = reaper.GetExtState("TJFRename", "Project")
          if project == "" then 
              project = reaper.GetProjectName(0, 512) 
              project = string.gsub(project, ".RPP", "")
          end
          

      local designer = reaper.GetExtState("TJFRename", "Designer")
          if designer == "" then designer = "TF" end
      
      local retval, name = reaper.GetSetMediaItemTakeInfo_String(reaper.GetActiveTake(reaper.GetSelectedMediaItem(0,0)), "P_NAME", "nothing", false) --get first selected item name
      
      local category = string.match(name, "^.-%_")
      if category == nil then category = reaper.GetExtState("TJFRename", "Category") end
      category = string.gsub(category, "_", "")
      
      
      ------------ CLEAN UP UNDESIREABLE CHARACTERS
      if project ~= "" then name = string.gsub(name, "_" .. project, "") end
      if designer ~= "" then name = string.gsub(name, "_" .. designer, "") end
      if category ~= "" then name = string.gsub(name, category .. "_", "") end
      name = string.gsub(name, "(%l)(%u)", "%1 %2") -- expand title case
      name = string.gsub(name, "(%s%u)(%u)", "%1 %2") -- fix single letter words
      name = string.gsub(name, "-Glued", "")
      name = string.gsub(name, "-glued", "")
      name = string.gsub(name, ".wav", "")
      name = string.gsub(name, ".flac", "")
      name = string.gsub(name, ",", " ")
      name = string.gsub(name, "_", " ")
      name = string.gsub(name, "-", " ")
      name = string.gsub(name, "%s+", " ") -- removes excess spaces

    
      local number = string.match(name, "%d+")
      number = tostring(number)
      if number == "nil" then number = "" end
      
      name = string.gsub(name, "%d", "") --remove numbers




      ---------- GET INPUTS AND SPLIT OUT INTO VARIABLES
      local retval, userinput = reaper.GetUserInputs("RENAME AND FORMAT ITEMS AND SOURCE", 6, "Description (FXName),Category (CatID),Designer,Project,Start Number (if any), Rename Source Also? (y/n),extrawidth=400", name .. "," .. category .. "," .. designer .. "," .. project .. "," .. number .. ",YES")
      if not retval then return false end  -- if input is canceled, quit the script
      
      name, category, designer, project, number, renamefile  = userinput:match("(.-),(.-),(.-),(.-),(.-),(.*)")
      
      if string.lower(renamefile:match("%a")) == "y" then
            renamefile = true
      else
            renamefile = false
      end
      
      
      
      
      
      
      -------FORMAT INPUT VARIABLES FOR FINAL ITEM NAME
      designer = designer:upper()
      project = project:upper()
      
      if project ~= "" then name = string.gsub(name, "_" .. project, "") end
      if designer ~= "" then name = string.gsub(name, "_" .. designer, "") end
      if category ~= "" then name = string.gsub(name, category .. "_", "") end
    
      name = string.gsub(name, "(%a)([%w_']*)", titleCase) -- title case the name string
      name = string.gsub(name, " ", "") -- remove spaces
      name = string.gsub(name, "_", "") 
      name = string.gsub(name, "'", "")

      if number then number = tonumber(number) end

      if #items > 1 and number == nil then number = 1 end
      if #items > 1 and number < 0 then number = 1 end

      
      -------  BUILD AND ATTACH THE FINAL ITEM NAME FOR EACH ITEM IN THE ARRAY
      for i = 1, #items do
      

          newTakeName[i] = category
          if category ~= "" then newTakeName[i] = newTakeName[i] .. "_" end
          newTakeName[i] = newTakeName[i] .. name
          if number ~= nil then newTakeName[i] = newTakeName[i] .. string.format("%02d", number) end
          if designer ~= "" then newTakeName[i] = newTakeName[i] .. "_" .. designer end
          if project ~= "" then newTakeName[i] = newTakeName[i] .. "_" .. project end
          
          if number then number = number + 1 end
          
          
       end--for
       
       
       --------- STORE VALUES IN SESSION FOR LATER
       reaper.SetExtState("TJFRename", "Project", project, true )
       reaper.SetExtState("TJFRename", "Designer", designer, true )
       reaper.SetExtState("TJFRename", "Category", category, true  )


      return newTakeName, renamefile


end




function RenameItemAndSource(item, newname)  -- param 1 is item, parameter 2 is new name

          local take = reaper.GetActiveTake(item)
          local name =  reaper.GetTakeName( take )
          --local retval, section, start, length, fade, reverse = reaper.BR_GetMediaSourceProperties( take )

          local source = reaper.GetMediaItemTake_Source(take)
          local parentsource =  reaper.GetMediaSourceParent( source ) -- PCM SOURCE FOR REVERSED ITEMS
          local filename = reaper.GetMediaSourceFileName(source, '')
          if filename == "" then filename = reaper.GetMediaSourceFileName(parentsource, '') end
          
          if filename then
          
                local path = filename:match('^(.+[\\/])')
                local extension = GetFileExtension(filename)
                local newFilename = path .. newname .. extension 
                
                
                os.rename(filename, newFilename)  -- WILL DESTRUCTIVELY RENAME CAREFUL
                
                for i=0, reaper.CountTracks(0)-1 do
                    local track = reaper.GetTrack(0,i)
                
                    local _, chunk = reaper.GetTrackStateChunk(track, "", true )
                    
                    chunk = string.gsub(chunk, filename, newFilename)
                    chunk = string.gsub(chunk, name, newname)
                    
                    reaper.SetTrackStateChunk( track, chunk, true )
                
                end--for

          
          end--if
          
          reaper.Main_OnCommand(40047, 0)--Peaks: Build any missing peaks 
          

end--function

function SafeToRename(item, newTakeName)

        local filename = itemfilename(item)
        local path = filename:match('^(.+[\\/])')
        local extension = GetFileExtension(filename)
        
        filename = path .. newTakeName .. extension
        
        
        if file_exists(filename) then
        
            if not string.find(oldFilenameString, filename) then
            
            
            local replace = reaper.MB(filename .. "\nALREADY EXISTS!!!\nDESTRUCTIVELY REPLACE?","WARNING!!!", 3)
            
            return replace
            end
        
        end--if

   
    return true



end--CheckSafeToRename()



function main()
      
      if reaper.GetSelectedMediaItem(0,0) then

          local items = filteruniqueitems() -- build array of items with unique source
      
          local newNames, fileRenameOK = GetInput(items) -- Ask user for input and build new names
          
          if newNames and #items == #newNames then
              
              for i=1, #items do 
                  if fileRenameOK then
                      local check = SafeToRename(items[i], newNames[i])
                      if check == 2 then return
                      elseif check == 7 then -- do nothing
                      elseif check or check == 6 then
                          RenameItemAndSource(items[i], newNames[i]) 
                      end
                  else
                      reaper.GetSetMediaItemTakeInfo_String( reaper.GetActiveTake(items[i]), "P_NAME", newNames[i], true)
                  end
              end
          end--if
              
          reaper.Main_OnCommand(40047, 0)--Peaks: Build any missing peaks
          --reaper.Main_OnCommand(41858, 0)--Item: Set item name from active take filename
          reaper.UpdateArrange()

      end--if
      
      

      
end--main()




reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
main()
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("TJF Rename", -1)

--reaper.defer(function() end) --prevent Undo

