--[[------------------------------[[--
           INIT GLOBAL VARIABLES        
--]]------------------------------]]--


    local UCSfile = "/Volumes/FLAC Library 8tb SSD/Soundminer V5 Support/8.1_categorylist.csv"
    local selected = 1
    local clipboard = nil
    local click_count, text = 0, ''
    r = reaper

    --GET UCS from Hard Drive
    local UCS = {}
            local file = io.open(UCSfile, "r") -- open in read mode
            
            io.input(file)
            
            for line in io.lines() do
                local Cat, Sub, ID, _  = line:match("(.-),(.-),(.-),(.*)")
                table.insert(UCS, Cat .. "-" .. Sub .. "   " .. ID )
            end
            table.remove(UCS, 1)            
            io.close(file)
            




function FuzzySearchTable(searchtable, query)

             local results = {}
             
              for key, value in pairs(searchtable) do
                   if string.find(value:upper(), query:upper()) then table.insert(results, value) end
              end
              
              return results
end




function SetClipboard(CatID)

    if CatID == nil then CatID = "" end
    CatID = CatID:match("%s%s%s(.*)")
    
    
    if CatID ~= clipboard and CatID ~= nil then
          clipboard = CatID
          r.CF_SetClipboard( CatID )
          r.SetExtState("TJFRename", "Category", CatID, true)
    end


end


--[[------------------------------[[--
                 GUI        
--]]------------------------------]]--





local ctx = r.ImGui_CreateContext('My Script')
local size = r.GetAppVersion():match('OSX') and 12 or 14
local font = r.ImGui_CreateFont('sans-serif', size)
r.ImGui_AttachFont(ctx, font)







function frame()
  local rv
  local results = {}
  
  
  --TEXT INPUT LINE
  --r.ImGui_SetKeyboardFocusHere(ctx, 0)
  rv, text = r.ImGui_InputText(ctx, ': Filter Results', text)
  
  if text == "" then results = UCS
    else results = FuzzySearchTable(UCS, text)
  end
  
  
  r.ImGui_SameLine(ctx)
  
  --SELECT BUTTON
  if r.ImGui_Button(ctx, 'Select') then
    click_count = click_count + 1
  end
  
    
  
  if selected <= 1 then selected = 1
  elseif selected >= #results then selected = #results end
  
  
  -- RESULTS BOX
  if r.ImGui_BeginChild(ctx, 'left pane', nil, 0, true) then
    for i = 1, #results do
      if r.ImGui_Selectable(ctx, results[i], selected == i) then
        selected = i
      end
    end
    r.ImGui_EndChild(ctx)
  end

  
  --Set Selection to Clipboard
  SetClipboard(results[selected])
  
end





function loop()
  r.ImGui_PushFont(ctx, font)
  r.ImGui_SetNextWindowSize(ctx, 400, 800, r.ImGui_Cond_FirstUseEver())
  local visible, open = r.ImGui_Begin(ctx, 'Search UCS', true, r.ImGui_WindowFlags_NoCollapse() )
  if visible then
    frame()
    r.ImGui_End(ctx)
  end
  r.ImGui_PopFont(ctx)
  
  
  
  --ESCAPE
  if r.ImGui_IsKeyPressed(ctx, 27, true) then 
        text = ''
  end
  
  
  --UP ARROW
  if r.ImGui_IsKeyPressed(ctx, 38, true) then 
        selected = selected - 1
  end
  
  
  --DOWN ARROW
  if r.ImGui_IsKeyPressed(ctx, 40, true) then 
        selected = selected + 1
  end
  
  
  --BUTTON PRESS OR DOUBLE CLICK
  if click_count > 0 or r.ImGui_IsKeyPressed(ctx, 13, true) --or reaper.ImGui_IsMouseDoubleClicked(ctx, 0)  
  then
     open = false
   end
  
  
  if open then
    r.defer(loop)
  else
    r.ImGui_DestroyContext(ctx)
  end
end

r.defer(loop)


