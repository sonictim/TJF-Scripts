--[[
@description TJF Escape Key
@version 2.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Escape Key
    Uses Logic to decide how to close windows/selections via escape key
    
    Order of Operations:
    Clear All Envelope Latches (always)
    1.) Toolbar 1 (for me, fades toolbar)
    2.) Time Selection
    3.) Razor Edit Selection
    4.) Item Selection
    5.) Visible Envelopes
    6.) Toggle Show/Hide the Docker
    
    --@changelog
    --  v2.0  Detects and Hides Visible Envelopes before Docker (final toggle)
    --  v1.5  Added Support For Razor Edit
    
    
  
--]]



function RazorEditSelectionExists()
    for i=0, reaper.CountTracks(0)-1 do
        local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
        if x ~= "" then return true end
    end--for
    
    return false

end--RazorEditSelectionExists()



function VisibleEnvelopes()
    for i=0, reaper.CountTracks(0)-1 do
        local track = reaper.GetTrack(0,i)
        local envcount = reaper.CountTrackEnvelopes(track)
        if envcount > 0 then
        for j=0, envcount-1 do
            local env = reaper.GetTrackEnvelope( track, j )
            local _, name = reaper.GetEnvelopeName( env )
            
            if not (name == "Trim Volume" and reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH" ) == 1) then
                env = reaper.BR_EnvAlloc(env, false)
                local  active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderScaling, automationItemsOptions = reaper.BR_EnvGetProperties( env )
                reaper.BR_EnvFree(env, false)
                if visible == true then return true end
            end
        end--for J
        end--if
    end--for I
    
    return false

end--VisibleEnvelopes()



--reaper.Main_OnCommand(42406,0) --Clear Area Selection
--reaper.Main_OnCommand(40020,0) -- remove time selection and loop points
--reaper.Main_OnCommand(40289,0) --Item: Unselect all items
--reaper.Main_OnCommand(41150,0) -- Envelope: Hide all envelopes for all tracks

function ResetAutomationLatches()
      reaper.Undo_BeginBlock()
      local mode = {}
      
      for i=0, reaper.CountTracks(0)-1 do
      
          mode[i] =  reaper.GetTrackAutomationMode(reaper.GetTrack(0,i))
      
      end--for
      
      reaper.SetAutomationMode( 1, false )
      
      for i=0, reaper.CountTracks(0)-1 do
      
          reaper.SetTrackAutomationMode(reaper.GetTrack(0,i), mode[i])
      
      end--for
      reaper.Undo_EndBlock("Disarm Automation Latches",0)
end--ResetAutomationLatches()

function Main()

        --ResetAutomationLatches()
        reaper.Main_OnCommand(42025,0) -- Clear All Envelope Automation Latches

        local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
        
        --reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_WNCLS4"), 0)  --SWS/S&M: Close all FX chain windows
        --reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_WNCLS6"), 0)  --SWS/S&M: Close all floating FX windows, except focused one
        
        
        if reaper.GetToggleCommandStateEx(0,41679) == 1 then -- if toolbar 1 is visible
            reaper.Main_OnCommand(41679,0) --Open/Close toolbar 1
        
        elseif start_time ~= end_time then  --if there is a time selection
            reaper.Main_OnCommand(40020,0) -- remove time selection and loop points
            
        elseif RazorEditSelectionExists() then
            reaper.Main_OnCommand(42406,0) -- remove area selection
        
        elseif reaper.GetSelectedMediaItem(0,0) then --if there is an item selection
            reaper.Main_OnCommand(40289,0) --Item: Unselect all items
            
        elseif VisibleEnvelopes() then    
            reaper.Main_OnCommand(reaper.NamedCommandLookup("_60d85d5be7d54732b7ba82a7af05b08e"),0) --Hide ALL envelopes for all tracks
        else
            reaper.Main_OnCommand(40279, 0) --Show/Hide Docker
        
        end--if

end--Main()

Main()
reaper.defer(function() end)
