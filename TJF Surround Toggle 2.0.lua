--[[
@description TJF Toggle Session Stereo or Surround (Rename file for default number of channels)
@version 2.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # Toggles Stereo or Number of  Channels in filename on all tracks
  Will Enable/Disable any surround plugins on all tracks and takes
  Initially will use number of tracks listed in filename.
  Mill mimic/populate master track track count.  
  Will create a toggle stage for this function, that can be button mapped.
  
--]]

function GetChannelsFromFilename()

        local info = debug.getinfo(1,'S')  -- Builds a table with info about the lua script
        info.channels = tonumber(string.match(info.source, "%d+"))  -- info.source is filename in the table
        if info.channels % 2 ~= 0 then
          info.channels = info.channels + 1
        end
        
        info.channels = math.max(2, math.min(info.channels, 64))
        
      
        return info.channels
end


--[[
local cmd_id = ({reaper.get_action_context()})[4] -- gets command ID for this script
local state = reaper.GetToggleCommandStateEx(0,cmd_id)

local track = reaper.GetMasterTrack(0)

local channels = tonumber(reaper.GetExtState("TJF", "SurroundChannels"))
if not channels then 
      channels = GetChannelsFromFilename() 
      reaper.SetExtState("TJF", "SurroundChannels", channels, 0)
  end

local current = reaper.GetMediaTrackInfo_Value(track, "I_NCHAN")

if current ~= channels then

      if current ~= 2 then
          channels = current
          reaper.SetExtState("TJF", "SurroundChannels", current, 0)
          state = 0
      end
end


local enable = true




    if state ~= 1 then
            state = 1
            -------------------WILL SET MASTER CHANNEL REASURROUND PLUGIN
            --local fx = reaper.TrackFX_AddByName(track, "ReaSurround", false, 1)
            --reaper.TrackFX_SetPreset( track, fx, "Master Channel 5.1 to 5.1 outputs" )
            
            
            else
            state = 0
            channels = 2
            enable = false
            --index = reaper.TrackFX_AddByName(track, "Master 5.1 to Stereo Downmixer.rfxchain", false, 1 )
            --reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", 2)
            
            -------------------WILL SET MASTER CHANNEL REASURROUND PLUGIN
            --local fx = reaper.TrackFX_AddByName(track, "ReaSurround", false, 1)
            --reaper.TrackFX_SetPreset( track, fx, "Master Channel 5.1 to Stereo Mix Down" )
            
    end
 
    
    
-------------SET MASTER TRACK
        reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", channels)
        local fx =  reaper.TrackFX_AddByName( track, "ReaSurround", false, 0)
        if fx >= 0 then reaper.TrackFX_SetEnabled( track, fx, enable ) end
        fx =  reaper.TrackFX_AddByName( track, "Surround Pan 2.1", false, 0)
        if fx >= 0 then reaper.TrackFX_SetEnabled( track, fx, enable ) end 
        
        
-------------SET ALL OTHER TRACKS    
    for i=0, reaper.CountTracks(0)-1 do  -- set all tracks to channels
        
        --------Set Number of Track Channels for all tracks
        track = reaper.GetTrack(0,i)
        reaper.SetMediaTrackInfo_Value(track, "I_NCHAN", channels)
        
        --------Enable/Disable Surround Plugins for all tracks
        fx =  reaper.TrackFX_AddByName( track, "ReaSurround", false, 0)
        if fx >= 0 then reaper.TrackFX_SetEnabled( track, fx, enable ) end
        fx =  reaper.TrackFX_AddByName( track, "Surround Pan 2.1", false, 0)
        if fx >= 0 then reaper.TrackFX_SetEnabled( track, fx, enable ) end
    end

    
    
]]--
-------------SET ITEMS

function AddMonoCenter()
    for i=0, reaper.CountMediaItems(0)-1 do
        local take = reaper.GetActiveTake(reaper.GetMediaItem(0,i))
        local source = reaper.GetMediaItemTake_Source(take)
        local totalchan =  reaper.GetMediaSourceNumChannels( source )
        local chanmode = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")
        
        if totalchan == 1 or (chanmode > 1 and chanmode < 67 ) then
        
        local fx reaper.TakeFX_AddByName( take, "TJF Mono to Channel 3 (Center)", 1)
        
        end
    end
end--AddMonoCenter()


function RemoveMonoCenter()
    for i=0, reaper.CountMediaItems(0)-1 do
        local take = reaper.GetActiveTake(reaper.GetMediaItem(0,i))
        local fx = reaper.TakeFX_AddByName( take, "TJF Mono to Channel 3 (Center)", 0)
        if fx >= 0 then reaper.TakeFX_Delete( take, fx ) end
    end
end--RemoveMonoCenter()


function Main()
    local state = reaper.GetToggleCommandStateEx(0,reaper.NamedCommandLookup("_RS01195a2f4fa80dd3dea539db37f9d0729d14c07a"))
    
    if state == 1 then AddMonoCenter()
    else RemoveMonoCenter()
    end

end--Main()
    
    
    
reaper.Undo_BeginBlock()
Main()


    
    
reaper.UpdateArrange()
--reaper.SetToggleCommandState( 0, cmd_id, state)
--reaper.RefreshToolbar2(0, cmd_id)

reaper.Undo_EndBlock("TJF Surround Toggle",0)

