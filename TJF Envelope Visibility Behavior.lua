--@description TJF Envelope Visibility Behavior
--@version 1.1
--@author Tim Farrell
--
--@about
--  # TJF Envelope Visibility Behavior
--  This combines two scripts so I can keep them on one toolbar button
--  ALL Foldertracks will always display TRIM automation IN LANE
--  Will the the Envelope for your last touched parameter
--  Does not stipulate between Take or Track FX
--  Will Hide All other Visible Envelopes on the Track/Take for clarity.
--  Stays Active in the Background and will Automatically Change envelopes as you touch parameters

--
--@changelog
--  v1.0 - nothing to report
--  v1.1 - added X,Y,Z support for ReaSurround2


local EnableZ = true



----------------------------------DEBUG FUNCTIONS

--reaper.ClearConsole()

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

function take(param) return reaper.GetActiveTake(items[param]) end  --can call take function to match take to item
    
----------------------------------SET GLOBAL VARIABLES

local lastProjectChangeCount = 0
local curpos = reaper.GetCursorPosition(0)
local oldvalue = ""
local envelope = ""

----------------------------------SET COMMON FUNCTIONS

function CreateNewEnv(chunkname)
local EnvChunk = chunkname .. [[

EGUID ]]..reaper.genGuid("")..[[
ACT 1 -1
VIS 1 0 1
LANEHEIGHT 0 0
ARM 1
DEFSHAPE 0 -1 -1
VOLTYPE 1
PT 0 1 0
>
]]

return EnvChunk

end -- CreateNewTrimEnv()



function ProcessTrack(track, bool)

            local _,  str = reaper.GetTrackStateChunk(track, "", false )
                      
            local     TrimEnv = string.match(str, "<VOLENV3.->")      --find the volume envelope
                    
              if      TrimEnv
              then      
                      vis = "\nVIS 0 0 1"
                      if bool then vis = "\nVIS 1 0 1"
                                  --TrimEnv = string.gsub(TrimEnv, "PT.->", "PT 0 1 0\n>")
                      
                      
                      end
                      
                      
                      TrimEnv = string.gsub(TrimEnv, "\nVIS %d %d %d", vis)
                       
                      str = string.gsub(str, "<VOLENV3.->", TrimEnv)
              else          
                      if bool then
                          TrimEnv = string.match(str, "MAINSEND %d %d\n")..CreateNewEnv("<VOLENV3")
                          str = string.gsub(str, "MAINSEND %d %d\n", TrimEnv)
                      end
            end
                      
            reaper.SetTrackStateChunk(track, str, false)
            
end -- ProcessFolder()



function isFolder(track)
            if reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH" ) == 1 then return true
            else return false
            end
end -- isFolder()


function ReaSurround2(CurrentEnv, MasterEnvelope, speakers)
    
    if speakers=="" then speakers = 0 end
    
    speakers = tonumber(string.match(speakers, "%d+"))
    
    local _, MasterName = reaper.GetEnvelopeName( MasterEnvelope )
    if string.match(MasterName, "ReaSurroundPan" )
    then
        local channel = string.match(MasterName, "%d+")
        if channel
        then
            local _, CurrentName = reaper.GetEnvelopeName( CurrentEnv )
            
            if      string.find(CurrentName, "in "..channel.." X ") or string.find(CurrentName, "in "..channel.." Y ")
            then    return true
            elseif  EnableZ and speakers > 8 and string.find(CurrentName, "in "..channel.." Z ")
            then    return true
            end
        end
    end
    return false
end





function SetEnvelopeVis(envelope, bool)
    local retval, str = reaper.GetEnvelopeStateChunk( envelope, "VIS", false )
    if retval then
        if bool 
        then str = string.gsub(str, "\nVIS %d", "\nVIS 1")
        else str = string.gsub(str, "\nVIS %d", "\nVIS 0")
        end
    end
    reaper.SetEnvelopeStateChunk( envelope, str, true )
 
end--SetEnvelopeVis()





function TrackFXLastTouched(tracknumber, fxnumber, paramnumber)
              local track = reaper.CSurf_TrackFromID(tracknumber, false)
              local fxvalue, minval, maxval = reaper.TrackFX_GetParam( track, fxnumber, paramnumber )
              local _, speakers = reaper.TrackFX_GetNamedConfigParm( track, fxnumber, "NUMSPEAKERS" )              
              
              if fxvalue ~= oldvalue then
             
                    envelope = reaper.GetFXEnvelope( track, fxnumber, paramnumber, true )
                    if envelope ~= nil then
                            for i=0,  reaper.CountTrackEnvelopes( track ) - 1 do
                            
                                  local env = reaper.GetTrackEnvelope( track, i )
                                  local _, name = reaper.GetEnvelopeName( env )
                                  local _, trackname = reaper.GetTrackName(track)
                                  if env~=envelope  
                                  then 
                                        if (name == "Trim Volume" and reaper.GetMediaTrackInfo_Value(track, "I_FOLDERDEPTH" ) == 1 and trackname ~= "PIX" ) or ReaSurround2(env, envelope, speakers)
                                        then
                                            SetEnvelopeVis(env, true)
                                        else
                                            SetEnvelopeVis(env, false)
                                        end
                                  else SetEnvelopeVis(env, true)
                                        if  reaper.CountEnvelopePoints( envelope ) < 2 then
                                                    if reaper.CountEnvelopePoints(envelope) < 1  
                                                    then  reaper.InsertEnvelopePointEx( envelope, -1, 0, fxvalue, 0, 0, 1, 0 )
                                                    end
                                                    
                                                    local  retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( envelope, 0 )
                                                    reaper.SetEnvelopePoint( envelope, 0, time, fxvalue, shape, tension, selected, false )
                                        end--if
                                  
                                  
                                  
                                  
                                  end--if

                                  
                            end--for
                        reaper.SetCursorContext( 2, envelope ) -- selects envelope
                        --reaper.Main_OnCommand(40332,0) -- Envelope:  Select all points
                    end--if

                    oldvalue = fxvalue
                    reaper.TrackList_AdjustWindows(false)
                    
              end--if
              

end--TrackFXLastTouched



function TakeFXLastTouched(tracknumber, fxnumber, paramnumber)
              local track = reaper.CSurf_TrackFromID((tracknumber & 0xFFFF), false)
              local takenumber = (fxnumber >> 16)
              fxnumber = (fxnumber & 0xFFFF)
              local item_index = (tracknumber >> 16)-1
              local item = reaper.GetTrackMediaItem(track, item_index)
              local take = reaper.GetTake(item, takenumber)
              local fxvalue, minval, maxval = reaper.TakeFX_GetParam( take, fxnumber, paramnumber )
              local _, speakers = reaper.TakeFX_GetNamedConfigParm( take, fxnumber, "NUMSPEAKERS" )
  
              if fxvalue ~= oldvalue then
                  --reaper.SelectAllMediaItems( 0, false )  --  These two will change your selection to just the media item you are adjusting
                  --reaper.SetMediaItemSelected( item, true )

                  local envelope = reaper.TakeFX_GetEnvelope( take, fxnumber, paramnumber, true )
    
                      if envelope ~= nil then
                          
                          for i=0,  reaper.CountTakeEnvelopes( take )  - 1 do
                          
                                local env = reaper.GetTakeEnvelope( take, i )
                                if env~=envelope  
                                then 
                                      if   ReaSurround2(env, envelope, speakers)
                                      then SetEnvelopeVis(env, true)
                                      else SetEnvelopeVis(env, false)
                                      end
                                
                                
                                else SetEnvelopeVis(env, true)
                                        if  reaper.CountEnvelopePoints( envelope ) < 2 then
                                                    if reaper.CountEnvelopePoints(envelope) < 1  
                                                    then  reaper.InsertEnvelopePointEx( envelope, -1, 0, fxvalue, 0, 0, 1, 0 )
                                                    end
                                                    
                                                    local  retval, time, value, shape, tension, selected = reaper.GetEnvelopePoint( envelope, 0 )
                                                    reaper.SetEnvelopePoint( envelope, 0, time, fxvalue, shape, tension, selected, false )
                                        end--if
                                end--if
                          end--for
                          
                          reaper.SetCursorContext( 2, envelope )  -- selects envelope
                          reaper.Main_OnCommand(40332,0) -- Envelope:  Select all points
                      end--if
                      oldvalue = fxvalue
                      --reaper.UpdateArrange()
                  end--if
                  
              
end--TakeFXLastTouched







    
----------------------------------FUNCTION SETS COMMAND STATE FOR THIS FUNCTION
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
    
   


----------------------------------MAIN FUNCTION
function Main()
      --reaper.PreventUIRefresh(1)
      curpos = reaper.GetCursorPosition(0)


      local retval, tracknumber, fxnumber, paramnumber = reaper.GetLastTouchedFX()
      
      if retval then

                if (tracknumber >> 16) == 0 then -- Track FX or Input FX
                      TrackFXLastTouched(tracknumber, fxnumber, paramnumber)
                else -- ITEM FX >>>>>
                      TakeFXLastTouched(tracknumber, fxnumber, paramnumber)
                end
      end
     
      projectChangeCount = reaper.GetProjectStateChangeCount(0)
            
      if projectChangeCount > lastProjectChangeCount --or counter > 100
      then
      
          action =  tostring(reaper.Undo_CanUndo2(0))
          
          if string.find(string.lower(action), "toggle track folder") --or counter > 100
          then
      
                  for i = 0, reaper.CountTracks(0) - 1 do
                        
                      local   track = reaper.GetTrack(0,i)
                      local _, name = reaper.GetTrackName(track)
                        if name == "PIX" then 
                              ProcessTrack(track, false)
                        else
                              ProcessTrack(track, isFolder(track))
                        end
                  end
          end
          
          --counter = 0   
      end
      
      lastProjectChangeCount = projectChangeCount

      --reaper.PreventUIRefresh(-1)
      reaper.UpdateArrange()
      

      reaper.defer(Main)

end--Main()

-------------------------------CALL THE SCRIPT

local oldvalue = ""


Main()
