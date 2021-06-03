--[[
Description: Track selection follows item selection
Version: 1.1.3
Author: Lokasenna  -- 
Donation: https://paypal.me/Lokasenna
Changelog:
  Fix: Setting the last touched track wasn't working -- TJF adjusted this again as an experiment
Links:
  Forum Thread http://forum.cockos.com/showthread.php?p=1583631
  Lokasenna's Website http://forum.cockos.com/member.php?u=10417
About:
  Runs in the background and allows you to replicate a behavior
  from Cubase - when selecting items, the  track selection is
  changed to match and the mixer view is scrolled to show the first
  selected track.

  To exit, open the Actions menu, and click on:
  Running script: Lokasenna_Track selection follows item selection.lua
  down at the bottom.

  Note: This script is a rewrite of:
  tritonality_X-Raym_Cubase_Style_SelectTrack_On_ItemSelect.lua

  It had a few bugs and I couldn't understand the original code
  well enough to fix them, so I opted to rewrite it from scratch.
Extensions:
--]]

-- Licensed under the GNU GPL v3

local function Msg(str)
  reaper.ShowConsoleMsg(tostring(str).."\n")
end

local sel_items = {}
local curpos =  nil
local match = false

-- Very limited - no error checking, types, hash tables, etc
local function shallow_equal(t1, t2)
  if #t1 ~= #t2 then return false end
  for k, v in pairs(t1) do
    if v ~= t2[k] then return false end
  end
  return true
end


local function GetItemStartPos(items)

    local pos = nil

    for i=1, #items do
    
        local iStart = reaper.GetMediaItemInfo_Value(items[i], "D_POSITION")
        if pos == nil or iStart < pos then
           pos = iStart
        end
    end

    return pos
end



(function()
  local _, _, sectionId, cmdId = reaper.get_action_context()

  if sectionId ~= -1 then
    reaper.SetToggleCommandState(sectionId, cmdId, 1)
    reaper.RefreshToolbar2(sectionId, cmdId)

    reaper.atexit(function()
      reaper.SetToggleCommandState(sectionId, cmdId, 0)
      reaper.RefreshToolbar2(sectionId, cmdId)
    end)
  end
end)()




local function Main()

    
    local curpos = reaper.GetCursorPosition()
    
    
    
    

    local cur_items = {}
    for i = 1, reaper.CountSelectedMediaItems( 0 ) do
      cur_items[i] = reaper.GetSelectedMediaItem( 0, i - 1 )
    end

    if curpos ~= GetItemStartPos(cur_items) and match == false then 
        reaper.Main_OnCommand(41173,0)
        match = true
    end



    -- If all MediaItems have a partner then the selection hasn't changed
    if not shallow_equal(sel_items, cur_items) then
      match = false
        
      sel_items = cur_items
      
      reaper.Main_OnCommand(41173,0) -- Item navigation: Move cursor to start of items
      
    
    end



  reaper.defer(Main)
end

Main()
