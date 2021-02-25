--@description TJF Coalesce Take Volume to Track Volume
--@version 0.1
--@author Tim Farrell
--@links
--  TJF Reapack https://github.com/sonictim/TJF-Scripts/raw/master/index.xml
--
--@about
--  # TJF Coalesce Take Volume to Track Volume
--  Functions similar to Protools Coalesce Clip Gain to Volume Automation
--  Option to set wether to use the PreFX volume or regular Volume in Global Variables
--  Option to set Glide Amount in Global Variables
--  Option to set both source and destination envelopes visible (false leaves them as they currently are)
--
--  Known issues:
--  If two selected items are overlapping on the same track, could have unexpected coalesce results
--  Automation Item support is in the very early stages of development and is off by default.
--  I strongly suggest not turning this feature on.
--
--  DISCLAIMER:
--  This script was written for my own personal use and therefore I offer no support of any kind.
--  Any feature requests/bug reports will be ignored entirely, unless of course they interest me and I want to pursue them.
--  I strongly recommend never to run this or any other script I've written for any reason what so ever.
--  Ignore this advice at your own peril!
--  
--  
--@changelog
--  v0.1 - nothing to report
    
    
    --[[------------------------------[[---
                GLOBAL VARIABLES               
    ---]]------------------------------]]--


PreFX = true
GlideAmount = .01
ProcessAutoItems = false

SetSourceVisible = false
SetDestinationVisible  = false





    --[[------------------------------[[---
                    DEBUG               
    ---]]------------------------------]]--

reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end




function CreateNewEnv(chunkname)
local EnvChunk = chunkname .. [[ 
EGUID ]]..reaper.genGuid("")..[[
ACT 1 -1
VIS 0 1 1
LANEHEIGHT 0 0
ARM 1
DEFSHAPE 0 -1 -1
VOLTYPE 1
PT 0 1 0
>
]]

return EnvChunk

end


function AddTrackEnv(track)
        
        local chunkname = "<VOLENV2"
        if PreFX then chunkname = "<VOLENV" end
        local _,  str = reaper.GetTrackStateChunk(track, "", false )
        local volumeEnvelope = string.match(str, "MAINSEND %d %d\n")..CreateNewEnv(chunkname)
        str = string.gsub(str, "MAINSEND %d %d", volumeEnvelope)
        reaper.SetTrackStateChunk(track, str, false)

end--AddTrackEnv


function SetEnvelopeVis(envelope, bool)
    local retval, str = reaper.GetEnvelopeStateChunk( envelope, "VIS", false )
    if retval then
        if bool 
        then str = string.gsub(str, "\nVIS %d", "\nVIS 1")
        else str = string.gsub(str, "\nVIS %d", "\nVIS 0")
        end
    end
    reaper.SetEnvelopeStateChunk( envelope, str, true )
 
end--EnvelopeVis()
    


    --[[------------------------------[[---
               POINT FUNCTIONS              
    ---]]------------------------------]]-- 

function GetAdjustedPoints(item)

    local points = {}

    local take = reaper.GetActiveTake(item)
    local takeEnvelope =  reaper.GetTakeEnvelopeByName( take, takeEnvName )
    if not takeEnvelope then return nil end
    --takeScale = reaper.GetEnvelopeScalingMode(takeEnvelope)
    
    local track =  reaper.GetMediaItem_Track( item )
    local trackEnvelope =   reaper.GetTrackEnvelopeByName( track, trackEnvName )
    if not trackEnvelope then
        AddTrackEnv(track)
        trackEnvelope =   reaper.GetTrackEnvelopeByName( track, trackEnvName )
    end
    --trackScale = reaper.GetEnvelopeScalingMode(trackEnvelope)
    
    
    local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local itemOffset = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local itemEnd = itemStart + itemOffset


    ----GET TRACK START POINT
    local trackstart = {}
    trackstart.time = itemStart - GlideAmount
    local retval, value, dVdS, ddVdS, dddVdS = reaper.Envelope_Evaluate( trackEnvelope, trackstart.time, samplerate, 0 )
    trackstart.value = value
    table.insert(points, trackstart)
    
    ----GET TRACK END POINT
    local trackend = {}
    trackend.time = itemEnd + GlideAmount
    retval, trackend.value, dVdS, ddVdS, dddVdS = reaper.Envelope_Evaluate( trackEnvelope, trackend.time, samplerate, 0 )
    table.insert(points, trackend)
    
    ----GET ADJUSTED TRACK POINTS
    for i=0, reaper.CountEnvelopePoints(trackEnvelope)-1 do
              local CurrentPoint = {}

              local retval, time, trackValue, shape, tension, selected = reaper.GetEnvelopePoint( trackEnvelope, i )
              
              CurrentPoint.time = time
              
              if CurrentPoint.time >= itemStart and CurrentPoint.time <= itemEnd then
                    local retval, takeValue, dVdS, ddVdS, dddVdS = reaper.Envelope_Evaluate( takeEnvelope, CurrentPoint.time - itemStart, samplerate, 0 )
                    CurrentPoint.value = CoalesceVolumeValues(takeValue, trackValue)
                    table.insert(points, CurrentPoint)
              end  
    end
    

    ----GET ADJUSTED TAKE POINTS
    for i=0,  reaper.CountEnvelopePoints( takeEnvelope )-1 do
              local currentPoint = {}
              
              local retval, time, takeValue, shape, tension, selected = reaper.GetEnvelopePoint( takeEnvelope, i )
              currentPoint.time = itemStart + time
              
              local retval, trackValue, dVdS, ddVdS, dddVdS = reaper.Envelope_Evaluate( trackEnvelope, currentPoint.time, samplerate, 0 )
              currentPoint.value = CoalesceVolumeValues(takeValue, trackValue)
              
              table.insert(points, currentPoint)
    end
    
    ----GET ADJUSTED TAKE END POINT
    
    local takeend = {}
    takeend.time = itemEnd
    local retval, takeValue, dVdS, ddVdS, dddVdS = reaper.Envelope_Evaluate( takeEnvelope, itemOffset, samplerate, 0 )
    local retval, trackValue, dVdS, ddVdS, dddVdS = reaper.Envelope_Evaluate( trackEnvelope, takeend.time, samplerate, 0 )
    takeend.value = CoalesceVolumeValues(takeValue, trackValue)
    table.insert(points, takeend)

    return points
end


function CoalesceVolumeValues(value1, value2)

      local value =  20*(math.log(reaper.ScaleFromEnvelopeMode(1, value1), 10)) + 20*(math.log(reaper.ScaleFromEnvelopeMode(1, value2), 10))
      value = reaper.ScaleToEnvelopeMode(1, math.exp(value*0.115129254))
      return value

end

function GetAutoItems(envelope, starttime, endtime)
     local AutoItems = {}
     
     table.insert(AutoItems, -1)
     
     if ProcessAutoItems then

           local AutoItemCount = reaper.CountAutomationItems(envelope)
           
           if AutoItemCount > 0 then
           
              for i=0, AutoItemCount-1 do
              
                  local istart =  reaper.GetSetAutomationItemInfo( envelope, i, "D_POSITION", 0, false )
                  local iend = istart + reaper.GetSetAutomationItemInfo( envelope, i, "D_LENGTH", 0, false )
                  
                  if      (istart >= starttime and istart < endtime)
                      or  (iend > starttime and iend <= endtime)
                      or  (istart < starttime and iend > endtime)
                  then
                      table.insert(AutoItems, i)
                  end
              
              end
          end
    end
        
    --table.insert(AutoItems, 1, -1)
     
    return AutoItems
     


end -- GetAutoItems



function SetAdjustedPoints(item, points)

    local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local itemOffset = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    local itemEnd = itemStart + itemOffset
    

    local take = reaper.GetActiveTake(item)
    local takeEnvelope =  reaper.GetTakeEnvelopeByName( take, takeEnvName )
    if takeEnvelope then
    
      reaper.DeleteEnvelopePointRange( takeEnvelope, 0, itemOffset )
      reaper.InsertEnvelopePoint( takeEnvelope, 0, reaper.ScaleToEnvelopeMode(1,1), 0, 0, true, true  )
      reaper.InsertEnvelopePoint( takeEnvelope, itemOffset, reaper.ScaleToEnvelopeMode(1,1), 0, 0, true, true  )
      reaper.Envelope_SortPoints( takeEnvelope )
      
      if SetSourceVisible then SetEnvelopeVis(takeEnvelope, true) end
      
    
    end
    
  
    
    local track =  reaper.GetMediaItem_Track( item )
    local trackEnvelope =   reaper.GetTrackEnvelopeByName( track, trackEnvName )
    if trackEnvelope then
        
        local AutoItems = GetAutoItems(trackEnvelope, itemStart-GlideAmount, itemEnd+GlideAmount)
        
        for j=1, #AutoItems do
        
        
      
                  reaper.DeleteEnvelopePointRangeEx( trackEnvelope, AutoItems[j],itemStart-GlideAmount, itemEnd+GlideAmount )
                  
                  for i=1, #points do
                        reaper.InsertEnvelopePointEx( trackEnvelope, AutoItems[j], points[i].time, points[i].value, 0, 0, true, true  )
                  end
                  
                  reaper.Envelope_SortPointsEx( trackEnvelope, AutoItems[j] )
    
        end
        
        if SetDestinationVisible then SetEnvelopeVis(trackEnvelope, true) end
    
    end


end

    --[[------------------------------[[---
                    MAIN              
    ---]]------------------------------]]--
    
function Main()

      samplerate = reaper.GetSetProjectInfo( 0, "PROJECT_SRATE", 0, false )
      takeEnvName = "Volume"
      if    PreFX
      then  trackEnvName = "Volume (Pre-FX)"
      else  trackEnvName = "Volume"
      end

      local itemcount = reaper.CountSelectedMediaItems(0)
      
      if itemcount then
      
              for i=0, itemcount-1 do
                  
                  local item = reaper.GetSelectedMediaItem(0, i)
                  local points = GetAdjustedPoints(item)
                  if points ~= nil then SetAdjustedPoints(item, points) end
                  
              
              end
      
      end


end


reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("TJF Coalesce Take Volume to Track Volume", -1)
reaper.PreventUIRefresh(-1)
