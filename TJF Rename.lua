--@noindex
--  NoIndex: true
--@description TJF Simple UCS Format and Rename
--@version 3.3
--@author Tim Farrell
--@about
--  # TJF Simple UCS Format and Rename
--  This will help you rename and format your items to match the UNIVERSAL CATEGORY LIST Naming Conventions
--  Script will remember the variables you use and attempt to create the proper name from the existing filename/project name.
--  There are settings for Title Case and Remove Spaces in this Script... alter if you prefer
--
--  This script will NOT look up UCS CatIDs.. I recommend Using Kai Paquin's Awesome Keyboard Maestro Macros to do this
--
--  BE CAREFUL with RENAME... it is NOT undoable
--
--  REQUIRES LOKASENNA GUI 2.0 - Available on ReaPack!

--@changelog
--  v1.0  Initial release
--  v2.0  Updated to process via Chunks
--  v2.1  User can decide if they want to rename the actual file also
--  v3.0  Updated GUI
--        Will update item based on selection
--  v3.1  Added "ESCAPE KEY" and "ENTER KEY" functionality
--  v3.2  Updated GUI with more options
--  v3.3  lots of internal bug fixes


--[[------------------------------[[--
               SETTINGS         
--]]------------------------------]]--


    local defaultDesigner = "TJF"     -- Sets what you want the default "DESIGNER" Field to be
    local RemoveSpaces = true         -- Will Remove Spaces in your description field when creating final item/source name
    local ConvertToTitleCase = true   -- Will Convert your Description field to Title Case
    
    local SourceRenameWarning = true  -- Tired of rename warning messages?  set this to false, but do so AT YOUR OWN RISK

    local UCSfile = "/Volumes/TJF Library 8tb SSD/Soundminer V5 Support/_categorylist.csv"

--[[------------------------------[[--
            GLOBAL VARIABLES         
--]]------------------------------]]--

local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()

local oldFilenameString = " "



--[[------------------------------[[--
                FUNCTIONS         
--]]------------------------------]]--

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end --Debug Mesages

function take(param) return reaper.GetActiveTake(item[param]) end  --can call take function to match take to item

 function toboolean(value)
    if value == "true" or value == true
    then
         return true
    else
        return false
    end
 end


function titleCase( first, rest )
         return first:upper()..rest:lower()
         --function to call later:  STRING = string.gsub(STRING, "(%a)([%w_']*)", titleCase) 
end

function getUCSCatIDList()

            local CatID = {}
            
            local file = io.open(UCSfile, "r") -- open in read mode
            
            
            io.input(file)
            
            for line in io.lines() do
                local  _, _, catid, _  = line:match("(.-),(.-),(.-),(.*)")
                table.insert(CatID, catid)
            end
            
            
            io.close(file)
            
            return CatID
end

 
     
function SearchTable(table, query)

              for key, value in pairs(table) do
                      if value == query then
                        return true
                      end
              end
              
              return false
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


function OK()
        reaper.Undo_BeginBlock()
        local items = {}
        
        
        RemoveSpaces = GUI.Val("Spaces")
        ConvertToTitlecase = GUI.Val("Titlecase")
        
        
        
        local RenameSource = GUI.Val("Rename")
        

        if reaper.GetSelectedMediaItem(0,0) then
        
        
            if RenameSource == 2 then
                  if SourceRenameWarning then
                    
                      
                      local proceed = reaper.MB("If you want to undo, you'll have to rename any files back to their current names or your session will break.\n\nRenaming a file could break links in other sessions or possibly THIS one\n\nWould you like to continue?","Renaming Source File is NOT Undoable", 1)
                      if proceed == 2 then return end 
                  
                  end
   
                  items = filteruniqueitems() -- build array of items with unique source
            else for i=1, reaper.CountSelectedMediaItems(0) do items[i] = reaper.GetSelectedMediaItem(0,i-1) end
            end--if
            
            if GUI.Val("Close") then
            gfx.quit()
            GUI.quit = true
            end
            
            local newNames = ProcessInput(items) -- Ask user for input and build new names
            
            if newNames and #items == #newNames then
                
                for i=1, #items do 
                    if RenameSource == 2 
                    then 
                         RenameItemAndSource(items[i], newNames[i]) 
                    else
                        reaper.GetSetMediaItemTakeInfo_String( reaper.GetActiveTake(items[i]), "P_NAME", newNames[i], true)
                    end
                end--for
            end--if
                
            reaper.Main_OnCommand(40047, 0)--Peaks: Build any missing peaks
 
            reaper.UpdateArrange()
            
        end--if
        
        
        reaper.Undo_EndBlock("Rename Items", -1)

end--OK


function Cancel()
        GUI.quit = true
        gfx.quit()
        
end

function GetTakeNameInfo()
      
  local currentItem = reaper.GetSelectedMediaItem(0,0)

  if currentItem ~= oldItem then
  

      
      
      
      local name, category, fxname, designer, project, extra, number, _
      local CatIDs = getUCSCatIDList()
      
      
      if currentItem then
           _, name = reaper.GetSetMediaItemTakeInfo_String(reaper.GetActiveTake(reaper.GetSelectedMediaItem(0,0)), "P_NAME", "nothing", false) --get first selected item name
      else
          name = ""
      end
      
      
      name = string.gsub(name, "-Glued", "")
      name = string.gsub(name, "-glued", "")
      name = string.gsub(name, ".wav", "")
      name = string.gsub(name, ".flac", "")
      
              category = name:match("(.-)_")
              
              if not SearchTable(CatIDs, category) then
              
                    category = ""
                    fxname = name
                    
              else
                    fxname = name:match("_(.*)")
                    if fxname then fxname = string.gsub(fxname, "_.*", "") end
                    designer = name:match("_.-_(.*)")
                    if designer then designer = string.gsub(designer, "_.*", "") end
                    project  = name:match("_.-_.-_(.*)")
                    extra    = name:match("_.-_.-_.-_(.*)")

                    if extra then 
                      
                          project = string.gsub(project, extra)
                          fxname = fxname .. " " .. extra
                    end
              
              end

              
              
              
              ------------ GET/SET THE VARIABLE DEFAULTS STORED IN THE SESSION
      if project == nil then
            project = reaper.GetExtState("TJFRename", "Project")
                if project == "" then 
                    project = reaper.GetProjectName(0, 512) 
                    project = string.gsub(project, ".RPP", "")
                end
      end
      
      
      if designer == nil then
            designer = reaper.GetExtState("TJFRename", "Designer")
                if designer == "" then designer = defaultDesigner end
      end
      
      
      
      if category == "" then category = reaper.GetExtState("TJFRename", "Category") end

      
      
      
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
      if number ~= "" and number ~= nil then fxname = string.gsub(fxname, "^(.*%D)%d+(.-)$" , "%1") end
      if number == "" or number == nil then number = name:match("^.*(%d+).-$") end
      number = tostring(number)
      if number == "nil" then number = "" end
      
      fxname = string.gsub(fxname, "%s+", " ") -- removes excess spaces
      
      
      GUI.Val("DESC", fxname )
      GUI.Val("NUMB", number)
      GUI.Val("CATID", category)
      GUI.Val("DSGNR", designer)
      GUI.Val("SHOW", project)

             
              
              
              
              
              
        
             
             oldItem = currentItem
        
             if startflag ~= 1 then
                   GUI.elms.CATID.focus = true
                   GUI.elms.CATID.sel_s = 0
                   GUI.elms.CATID.sel_e = string.len(GUI.elms.CATID.retval)
                   GUI.elms.CATID.caret = string.len(GUI.elms.CATID.retval)
                   
                   startflag = 1
             end
     
  
  end--if
  
  if GUI.char == 13.0 then OK()           -- If the User presses the ENTER key, RUN the OK script
  elseif GUI.char == 27.0 then Cancel()   -- If the User presses the ESCAPE key, Cancel
  end  
  
  
end


--[[
function GetTakeNameInfoOLD()
      
  local currentItem = reaper.GetSelectedMediaItem(0,0)

  if currentItem ~= oldItem then
      

      ------------ GET/SET THE VARIABLE DEFAULTS STORED IN THE SESSION
      local project = reaper.GetExtState("TJFRename", "Project")
          if project == "" then 
              project = reaper.GetProjectName(0, 512) 
              project = string.gsub(project, ".RPP", "")
          end
      GUI.Val("SHOW", project)
          

      local designer = reaper.GetExtState("TJFRename", "Designer")
          if designer == "" then designer = defaultDesigner end
      GUI.Val("DSGNR", designer)
      
      
      if reaper.GetSelectedMediaItem(0,0) then
      --if reaper.GetSelectedMediaItem(0,0) then
              
              local retval, name = reaper.GetSetMediaItemTakeInfo_String(reaper.GetActiveTake(reaper.GetSelectedMediaItem(0,0)), "P_NAME", "nothing", false) --get first selected item name
              
              local category = string.match(name, "^.-%_")
              if category == nil then category = reaper.GetExtState("TJFRename", "Category") end
              category = string.gsub(category, "_", "")
              GUI.Val("CATID", category)
    
      
              ------------ CLEAN UP UNDESIREABLE CHARACTERS
              if project ~= "" then name = string.gsub(name, "_" .. project, "") end
              if designer ~= "" then name = string.gsub(name, "_" .. designer, "") end
              if category ~= "" then name = string.gsub(name, category .. "_", "") end
              if ConvertToTitleCase then name = string.gsub(name, "(%l)(%u)", "%1 %2") end -- expand title case
              if ConvertToTitleCase then name = string.gsub(name, "(%s%u)(%u)", "%1 %2") end -- fix single letter words
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
              GUI.Val("DESC", name )
              GUI.Val("NUMB", number)
     end
     
     oldItem = currentItem

     if startflag ~= 1 then
           GUI.elms.CATID.focus = true
           GUI.elms.CATID.sel_s = 0
           GUI.elms.CATID.sel_e = string.len(GUI.elms.CATID.retval)
           GUI.elms.CATID.caret = string.len(GUI.elms.CATID.retval)
           
           startflag = 1
     end
     
  end--if
  
  if GUI.char == 13.0 then OK()           -- If the User presses the ENTER key, RUN the OK script
  elseif GUI.char == 27.0 then Cancel()   -- If the User presses the ESCAPE key, Cancel
  end  
  
  
end
]]


function ProcessInput(items)
      newTakeName = {}
      name = GUI.Val("DESC")
      category = GUI.Val("CATID")
      designer = GUI.Val("DSGNR")
      project = GUI.Val("SHOW")
      number = GUI.Val("NUMB")
      
      
      
      
      -------FORMAT INPUT VARIABLES FOR FINAL ITEM NAME
      --designer = designer:upper()  -- SETS DESIGNER to uppercase
      --project = project:upper()    -- SETS PROJECT to uppercase
      
      if project ~= "" and project ~= nil then name = string.gsub(name, "_" .. project, "") end
      if designer ~= "" and designer ~= nil then name = string.gsub(name, "_" .. designer, "") end
      if category ~= "" and category ~= nil then name = string.gsub(name, category .. "_", "") end

      if ConvertToTitleCase then name = string.gsub(name, "(%a)([%w_']*)", titleCase) end -- title case the name string
      if RemoveSpaces then name = string.gsub(name, " ", "") -- remove spaces if preferred
      end -- remove spaces
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
          if number ~= nil then 
                if not RemoveSpaces then newTakeName[i] = newTakeName[i] .. " " end
                newTakeName[i] = newTakeName[i] .. string.format("%02d", number)
          end
                
                
          if designer ~= "" then newTakeName[i] = newTakeName[i] .. "_" .. designer end
          if project ~= "" then newTakeName[i] = newTakeName[i] .. "_" .. project end
          
          if number then number = number + 1 end
          
          
       end--for
       
       
       --------- STORE VALUES IN SESSION FOR LATER
       reaper.SetExtState("TJFRename", "Project", project, true )
       reaper.SetExtState("TJFRename", "Designer", designer, true )
       reaper.SetExtState("TJFRename", "Category", category, true  )

      
      return newTakeName


end

     


function RenameItemAndSource(item, newname)  -- param 1 is item, parameter 2 is new name
          
          local check = SafeToRename(item, newname)
          if check == 2 then return
          elseif check == 7 then  -- do nothing
          elseif check or check == 6 then

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
          end--if

end--function

function SafeToRename(item, newTakeName)

         filename = itemfilename(item)
         path = filename:match('^(.+[\\/])')
         extension = GetFileExtension(filename)
        
        filename = path .. newTakeName .. extension
        
        
        if file_exists(filename) then
        
            if not string.find(oldFilenameString, filename) then

                local replace = reaper.MB(filename .. "\nALREADY EXISTS!!!\nDESTRUCTIVELY REPLACE?","WARNING!!!", 3)
                return replace
            end
        
        end--if

        
    return true



end--CheckSafeToRename()


--[[------------------------------[[--
                GUI         
--]]------------------------------]]--




GUI.req("Classes/Class - Options.lua")()
GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Textbox.lua")()
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end



GUI.name = "Simple UCS Rename and Format Items"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 700, 200
GUI.anchor, GUI.corner = "mouse", "C"

GUI.New("CATID", "Textbox", {
    z = 11,
    x = 144,
    y = 16,
    w = 400,
    h = 20,
    caption = "",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    tab_idx = 1
})

GUI.New("DESC", "Textbox", {
    z = 11,
    x = 144,
    y = 48,
    w = 400,
    h = 20,
    caption = "Description (FX Name) : ",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    tab_idx = 2
})

GUI.New("DSGNR", "Textbox", {
    z = 11,
    x = 144,
    y = 80,
    w = 400,
    h = 20,
    caption = "Designer / Vendor : ",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    tab_idx = 3
})


GUI.New("SHOW", "Textbox", {
    z = 11,
    x = 144,
    y = 112,
    w = 400,
    h = 20,
    caption = "Show / Library : ",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    tab_idx = 4
})


GUI.New("NUMB", "Textbox", {
    z = 11,
    x = 144,
    y = 144,
    w = 400,
    h = 20,
    caption = "Starting Number (if any) : ",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20,
    tab_idx = 5
})


GUI.New("Rename", "Radio", {
    z = 11,
    x = 562,
    y = 16,
    w = 120,
    h = 70,
    caption = "Rename",
    optarray = {"Items Only", "Source Media"},
    dir = "v",
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = true,
    shadow = true,
    swap = nil,
    opt_size = 20
})



GUI.New("Titlecase", "Checklist", {
    z = 11,
    x = 140,
    y = 165,
    w = 96,
    h = 192,
    caption = "",
    optarray = {"Title Case Description"},
    dir = "v",
    pad = 4,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = false,
    swap = false,
    opt_size = 20
})

GUI.New("Spaces", "Checklist", {
    z = 11,
    x = 350,
    y = 165,
    w = 96,
    h = 192,
    caption = "",
    optarray = {"Remove Spaces"},
    dir = "v",
    pad = 4,
    font_a = 2,
    font_b = 3,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = false,
    swap = false,
    opt_size = 20
})

GUI.New("Close", "Checklist", {
    z = 11,
    x = 555,
    y = 165,
    w = 96,
    h = 192,
    caption = "",
    optarray = {"Process and Quit"},
    dir = "v",
    pad = 4,
    font_a = 4,
    font_b = 4,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = false,
    swap = false,
    opt_size = 20
})

GUI.New("UCS", "Checklist", {
    z = 11,
    x = 10,
    y = 165,
    w = 96,
    h = 192,
    caption = "",
    optarray = {"Enable UCS"},
    dir = "v",
    pad = 4,
    font_a = 4,
    font_b = 4,
    col_txt = "txt",
    col_fill = "elm_fill",
    bg = "wnd_bg",
    frame = false,
    shadow = false,
    swap = false,
    opt_size = 20
})

GUI.New("CANCEL", "Button", {
    z = 11,
    x = 578,
    y = 130,
    w = 100,
    h = 24,
    caption = "QUIT",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = Cancel
})

GUI.New("OK", "Button", {
    z = 11,
    x = 578,
    y = 98,
    w = 100,
    h = 24,
    caption = "PROCESS",
    font = 2,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = OK
})

GUI.New("CatSearch", "Button", {
    z = 11,
    x = 30,
    y = 16,
    w = 110,
    h = 24,
    caption = "Category (CAT ID) :",
    font = 3,
    col_txt = "txt",
    col_fill = "elm_frame",
    func = SearchCatID
})

function GUI.Textbox:onupdate()
  if self.focus then
     if self.blink == 0 then
      self.show_caret = true
      self:redraw()
    elseif self.blink == math.floor(GUI.txt_blink_rate / 2) then
      self.show_caret = false
      self:redraw()
    end
    self.blink = (self.blink + 1) % GUI.txt_blink_rate
 else
    self.sel_s = 0
    self.sel_e = string.len(self.retval)
    self.caret = string.len(self.retval)
  end
  
end


GUI.Main = function ()
    xpcall( function ()

        if GUI.Main_Update_State() == 0 then return end

        GUI.Main_Update_Elms()

        -- If the user gave us a function to run, check to see if it needs to be
        -- run again, and do so.
        if GUI.func then

            local new_time = reaper.time_precise()
            if new_time - GUI.last_time >= (GUI.freq or 1) then
                GUI.func()
                GUI.last_time = new_time

            end
        end


        -- Maintain a list of elms and zs in case any have been moved or deleted
        GUI.update_elms_list()


        GUI.Main_Draw()

    end, GUI.crash)
end


GUI.Main_Update_State = function()

    -- Update mouse and keyboard state, window dimensions
    if GUI.mouse.x ~= gfx.mouse_x or GUI.mouse.y ~= gfx.mouse_y then

        GUI.mouse.lx, GUI.mouse.ly = GUI.mouse.x, GUI.mouse.y
        GUI.mouse.x, GUI.mouse.y = gfx.mouse_x, gfx.mouse_y

        -- Hook for user code
        if GUI.onmousemove then GUI.onmousemove() end

    else

        GUI.mouse.lx, GUI.mouse.ly = GUI.mouse.x, GUI.mouse.y

    end
    GUI.mouse.wheel = gfx.mouse_wheel
    GUI.mouse.cap = gfx.mouse_cap
    GUI.char = gfx.getchar()

    if GUI.cur_w ~= gfx.w or GUI.cur_h ~= gfx.h then
        GUI.cur_w, GUI.cur_h = gfx.w, gfx.h

        GUI.resized = true

        -- Hook for user code
        if GUI.onresize then GUI.onresize() end

    else
        GUI.resized = false
    end

    --  (Escape key)  (Window closed)    (User function says to close)
    --if GUI.char == 27 or GUI.char == -1 or GUI.quit == true then
    if GUI.char == 27 then Cancel() end
    if (GUI.char == 27 and not (  GUI.mouse.cap & 4 == 4
                                or   GUI.mouse.cap & 8 == 8
                                or   GUI.mouse.cap & 16 == 16
                                or  GUI.escape_bypass))
            or GUI.char == -1
            or GUI.quit == true then

        GUI.cleartooltip()
        return 0
    else
        if GUI.char == 27 and GUI.escape_bypass then GUI.escape_bypass = "close" end
        reaper.defer(GUI.Main)
    end

end

GUI.Val("Titlecase", toboolean(ConvertToTitleCase))
GUI.Val("Spaces", toboolean(RemoveSpaces))
GUI.Val("Close", true)
GUI.Val("UCS", true)


GUI.func = GetTakeNameInfo
GUI.freq = 0
GUI.version = TJF

GUI.Init()
GUI.Main()


