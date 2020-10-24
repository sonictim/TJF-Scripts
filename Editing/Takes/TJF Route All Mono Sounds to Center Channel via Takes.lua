--[[
@description TJF Route All Mono Sounds to Center Channel
@version 1.0
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 08 09
@about
  # TJF Route All Mono Sounds to Center Channel
  Will look at all Mono or Single Channel Items and Add JSFX Plugin to Route to Channel 3 (Center)
  If Surround Mode is not Enable, it will REMOVE this plugin
  
--]]


function AddMonoCenter()
    for i=0, reaper.CountMediaItems(0)-1 do
        local take = reaper.GetActiveTake(reaper.GetMediaItem(0,i))
        local track =  reaper.GetMediaItemTakeInfo_Value( take, "P_TRACK")
        local trackchan = reaper.GetMediaTrackInfo_Value( track, "I_NCHAN" )
        
        if trackchan == 2 then
            local fx = reaper.TakeFX_AddByName( take, "TJF Mono to Channel 3 (Center)", 0)
            if fx >= 0 then reaper.TakeFX_Delete( take, fx ) end--if
        else
              local source = reaper.GetMediaItemTake_Source(take)
              local sourcechan =  reaper.GetMediaSourceNumChannels( source )
              local chanmode = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")
              
              if sourcechan == 1 or (chanmode > 1 and chanmode < 67 ) then
                  reaper.TakeFX_AddByName( take, "TJF Mono to Channel 3 (Center)", 1)
              end--if
              
        end--if
    end--for
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
    
    if state == 0 then RemoveMonoCenter()
    else AddMonoCenter()
    end

end--Main()
    
    
    
reaper.Undo_BeginBlock()
Main()


    
    
reaper.UpdateArrange()

reaper.Undo_EndBlock("Add/Remove Mono To Center Channel if Track Supports",0)

