--[[ ReaScript Name: TJF Toggle move mode
 Author: LKC
 REAPER: 5+
 Extensions: SWS
 Version: 2.10
 About:
  Locks item edges, fades, stretch markers, envelopes and time selection and shows visible large red GUI while locking is activated. 
  This enables you to move items like you have real hand tool.
  TJF Improve logic so Move Mode always switches to rectified peaks and regular mode has regular peaks
]]

--[[
 * Changelog:
 * v2.0
  + TJF changed to his preferences
 * v1.10 (2018-06-22)
  + Cleaned junk, rename, new meta info
 * v1.03 (2018-05-21)
  + GUI removed, rectified peaks indicate lock state
 * v1.02 (2018-03-22)
  + New script name
 * v1.0     (2018-03-22)
  + Initial Commit
]]

--meat starts here

local locked = reaper.GetToggleCommandState(1135) -- check lock
local rectify = reaper.GetToggleCommandState(42307) -- check rectify

if locked == 1 then
  reaper.Main_OnCommand(40570,0) -- disable locking
  if rectify == 1 then 
    reaper.Main_OnCommand(42307,0) --rectify peaks
  end
  --reaper.Main_OnCommand(39029,0) --Set default mouse modifier action for "Media item left drag" to "Marquee select items and time ignoring snap"
else
  reaper.Main_OnCommand(40569,0) --enable locking
  reaper.Main_OnCommand(40595,0) -- set item edges lock
  reaper.Main_OnCommand(40598,0) --set item fades lock
  reaper.Main_OnCommand(41852,0) --set item stretch markers lock
  reaper.Main_OnCommand(41849,0) --set item envelope
  reaper.Main_OnCommand(40572,0) --set time selection to UNlock
  --reaper.Main_OnCommand(40571,0) --set time selection to lock  
  if rectify ~= 1 then
  reaper.Main_OnCommand(42307,0) --rectify peaks
  end     
  reaper.Main_OnCommand(40578,0) --Locking: Clear left/right item locking mode
  reaper.Main_OnCommand(40581,0) --Locking: Clear up/down item locking mode
  
  --reaper.Main_OnCommand(39013,0) --Set default mouse modifier action for "Media item left drag" to "Move item ignoring time selection" (factory default)
end

