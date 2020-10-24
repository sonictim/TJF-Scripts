--[[
@description TJF Toggle Take Channel Stereo Flip
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Toggle Take Channel Stereo Flip
  Will Flip L and R Channels of all selected items
--]]

reaper.Undo_BeginBlock()

local fxname = "Surround Pan 2.1"
local presetname = "Default Mono TJF"

local cmd_id = reaper.NamedCommandLookup("_RS01195a2f4fa80dd3dea539db37f9d0729d14c07a")
local state = reaper.GetToggleCommandStateEx(0,cmd_id)


local itemcount = reaper.CountSelectedMediaItems(0)

if itemcount > 0 then

      for i=0, itemcount - 1 do

          local item = reaper.GetSelectedMediaItem(0,i)
          local take = reaper.GetActiveTake(item)
          
          reaper.SetMediaItemTakeInfo_Value( take, "I_CHANMODE", 2)
         
          if state == 1 then
              local fx =  reaper.TakeFX_AddByName( take, fxname, 1 )
              reaper.TakeFX_SetPreset( take, fx, presetname )
              reaper.TakeFX_SetEnabled( take, fx, true )
          else
              local fx =  reaper.TakeFX_AddByName( take, fxname, 0 )
              if fx >= 0 then reaper.TakeFX_SetEnabled( take, fx, false ) end
          end

      end--for


end--if

reaper.UpdateArrange()

reaper.Undo_EndBlock("Downmix to Mono TJF", 0)
