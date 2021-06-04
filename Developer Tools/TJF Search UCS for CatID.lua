--@description TJF Search UCS for CatID
--@version 1.0
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Search UCS for CatID
--
--  This script will help you search the UCS database for a CatID.
--  After completion, the CatID will be saved to the clipboard
--  NOTE: PLEASE SET THE PATH TO YOUR UCS DATADASE FILE IN THE GLOBAL VARIABLE BELOW
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


--[[------------------------------[[--
            GLOBAL VARIABLES        
--]]------------------------------]]--


    local UCSfile = "/Volumes/TJF Library 8tb SSD/Soundminer V5 Support/_categorylist.csv"
    
    local UCS = {}
    
    local selection = 1
    
    local clipboard = nil
    
--[[------------------------------[[--
              FUNCTIONS         
--]]------------------------------]]--

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end --Debug Mesages


function getUCS()

            local UCS = {}
            local file = io.open(UCSfile, "r") -- open in read mode
            
            io.input(file)
            
            for line in io.lines() do
                
                local Cat, Sub, ID, _  = line:match("(.-),(.-),(.-),(.*)")
                table.insert(UCS, Cat .. "-" .. Sub .. "   " .. ID )
            end
            
            io.close(file)
            
            table.remove(UCS, 1)
            return UCS
end

 
     
function SimpleSearchTable(searchtable, query)

              for key, value in pairs(searchtable) do
                      if value == query then return true end
              end
              
              return false
end


function FuzzySearchTable(searchtable, query)

             local results = {}
             
              for key, value in pairs(searchtable) do
                   if string.find(value:upper(), query:upper()) then table.insert(results, value) end
              end
              
              return results
end


function UpdateUI()

      GUI.elms.Results.list = FuzzySearchTable(UCS,GUI.Val("Search"))
      
      
      if GUI.Val("Results") == nil or GUI.Val("Results") > #GUI.elms.Results.list then GUI.Val("Results", 1) end
      
      if GUI.char == 30064 then UpArrow() end      
      if GUI.char == 1685026670 then DownArrow() end
      
      GUI.elms.Search.focus = true
      
      --Set Selection to Clipboard
      local CatID = GUI.elms.Results.list[GUI.Val("Results")]
      CatID = CatID:match("%s%s%s(.*)")
      if CatID ~= clipboard then
            clipboard = CatID
            reaper.CF_SetClipboard( CatID )
            reaper.SetExtState("TJFRename", "Category", CatID, true)
      end
  
      
end


function UpArrow()

    selection = selection - 1
    if selection < 1 then selection = 1 end
    --local val = GUI.Val("Results") - 1
    --if val == nil or val == 0 then val = 1 end
    GUI.Val("Results", selection)

end


function DownArrow()

    selection = selection + 1
    if selection >  #GUI.elms.Results.list then selection = #GUI.elms.Results.list end
    --local val = GUI.Val("Results") + 1
    --if val == nil then val = 1 end
    --if val > #GUI.elms.Results.list then val = #GUI.elms.Results.list end
    GUI.Val("Results", selection)

end



function OK()
      Cancel()
end


function Cancel()
        GUI.quit = true
        gfx.quit()
end

--[[------------------------------[[--
                GUI         
--]]------------------------------]]--

UCS = getUCS()


local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please install 'Lokasenna's GUI library v2 for Lua', available on ReaPack, then run the 'Set Lokasenna_GUI v2 library path.lua' script in your Action List.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()




GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - Listbox.lua")()
GUI.req("Classes/Class - Button.lua")()
-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end



GUI.name = "Search UCS"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 512, 480
GUI.anchor, GUI.corner = "mouse", "C"



GUI.New("Search", "Textbox", {
    z = 11,
    x = 64,
    y = 16,
    w = 400,
    h = 30,
    caption = "Search: ",
    cap_pos = "left",
    font_a = 3,
    font_b = "monospace",
    color = "txt",
    bg = "wnd_bg",
    shadow = true,
    pad = 4,
    undo_limit = 20
})


GUI.New("Results", "Listbox", {
    z = 11,
    x = 64,
    y = 64,
    w = 400,
    h = 400,
    list = results,
    multi = false,
    caption = "Results: ",
    font_a = 3,
    font_b = 4,
    color = "txt",
    col_fill = "elm_fill",
    bg = "elm_bg",
    cap_bg = "wnd_bg",
    shadow = true,
    pad = 4
})


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
    if GUI.char == 13 then OK() end
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



GUI.elms.Search.focus = true
GUI.elms.Search.sel_s = 0
GUI.elms.Search.sel_e = string.len(GUI.elms.Search.retval)
GUI.elms.Search.caret = string.len(GUI.elms.Search.retval)

GUI.func = UpdateUI
GUI.freq = 0
GUI.version = TJF


GUI.Init()
GUI.Main()


