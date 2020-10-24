--[[
@description TJF Set Item to Mono
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Set Take to Mono
  Will downmix items to mono and apply desired surround plugin and preset
--]]



----X RayM Code for deleting envelopes
function Action(env)
  retval, xml_env = reaper.GetEnvelopeStateChunk(env, "", false)
  xml_env = xml_env:gsub("\n", "¤¤")
  retval, xml_env = reaper.SetEnvelopeStateChunk(env, xml_env, false)
return xml_env

end

function DeleteEnv(env, track)

          retval, xml_track = reaper.GetTrackStateChunk(track, "", false)
          xml_track = xml_track:gsub("\n", "¤¤")
          xml_env =  Action(env)
end



----------------------------------------------------
--               MAIN
----------------------------------------------------

function Main()
reaper.Undo_BeginBlock()

local fxname = "Surround Pan 3.0 Nick"
local presetname = "Mono Center"

local cmd_id = reaper.NamedCommandLookup("_RS01195a2f4fa80dd3dea539db37f9d0729d14c07a") 
local state = reaper.GetToggleCommandStateEx(0,cmd_id) -- Checks if surround toggle is enabled

start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
                                                                        --second false chooses time or loop points
local curpos =  reaper.GetCursorPosition()  --Get current cursor position
reaper.SetEditCurPos( 0, false, false )





local itemcount = reaper.CountSelectedMediaItems(0)

if itemcount > 0 then

      for i=0, itemcount - 1 do
      
          reaper.Main_OnCommand(41163,0)  -- Unarm ALL envelopes

          local item = reaper.GetSelectedMediaItem(0,i)
          local take = reaper.GetActiveTake(item)
          reaper.SetMediaItemTakeInfo_Value( take, "I_CHANMODE", 2)  -- Set Take to Mono Downmix
          
          
          
          
          local istart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
          local iend = istart + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
          reaper.GetSet_LoopTimeRange2( 0, true, false, istart, iend, false)
          --reaper.SetEditCurPos( istart, false, false )

          
          local track = reaper.GetMediaItemTrack( item )
          local mode =  reaper.GetTrackAutomationMode(track)
          reaper.SetTrackAutomationMode(track, 2)
          
          
          
          
          
          local fx =  reaper.TrackFX_AddByName( track, fxname, false, 1 )
          
          for k = 0, reaper.TrackFX_GetNumParams( track, fx )-1 do  --Enable all Envelopes (Except Bypass) for chosen FX
              local envelope = reaper.GetFXEnvelope(track, fx, k, 1)
              
              
                --Set Envelope points
              reaper.DeleteEnvelopePointRange( envelope, (istart - 0.1), (iend + 0.1) )  
              local retval, value = reaper.Envelope_Evaluate( envelope, istart, 0, 0)
              reaper.InsertEnvelopePoint( envelope, istart, value, 0, 0, false, true )
              retval, value = reaper.Envelope_Evaluate( envelope, iend, 0, 0)
              reaper.InsertEnvelopePoint( envelope, iend, value, 0, 0, false, true )
              reaper.Envelope_SortPoints( envelope )
              
              --Arm and Hide Envelope
              BRenvelope = reaper.BR_EnvAlloc( envelope, false )
              local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, etype, faderScaling, automationItemsOptions = reaper.BR_EnvGetProperties( BRenvelope )
              reaper.BR_EnvSetProperties( BRenvelope, true, true, true, inLane, laneHeight, defaultShape, faderScaling)
              reaper.BR_EnvFree( BRenvelope, true )  --return envelope and commit changes
              
              
              
              
              --Remove Envelope if it is for Bypass
              retval, name = reaper.GetEnvelopeName( envelope )  --TJF Add - gets name of created envelope
              if string.find(name, "Bypass") then                --if has Bypass in the name
               DeleteEnv(envelope, track) end 
              
          end--for

          
          reaper.TrackFX_SetPreset( track, fx, presetname )
          
          reaper.Main_OnCommand(41160,0)   -- Automation: Write current values for all writing envelopes to time selection
          
          --reaper.SetTrackAutomationMode(track, mode)  -- Return Track to Previous Automation Mode

          
      end--for

end--if

--reaper.GetSet_LoopTimeRange2( 0, true, false, start_time, end_time, false)
--reaper.SetEditCurPos( curpos, false, false )


reaper.Main_OnCommand(reaper.NamedCommandLookup("_RS3686508f41ad06cc68e14f108c20bbaa14152897"),0) -- ARM ALL Track Envelopes


reaper.UpdateArrange()

reaper.Undo_EndBlock("Downmix to Mono TJF", 0)
end--Main()


reaper.PreventUIRefresh(1)
Main()
reaper.PreventUIRefresh(-1)
reaper.TrackList_AdjustWindows(false)

--ClearLatches()
