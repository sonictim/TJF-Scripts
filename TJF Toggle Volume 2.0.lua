--[[
@description TJF Toggle Volume Envelope Visible for Track or Items
@version 2.3
@author Tim Farrell
@link http://github.com/sonictim/TJF-Scripts/
@date 2020 04 26
@about
  # TJF Toggle Volume Envelope Visible for Track or Items
  Will Toggle Volume Envelope Visibility for all selected Items, or Tracks if no items selected.
  Toggle will match toggle of first item selected
  
@changelog
  v1.2 added ability to hide ALL active envelopes for track
  v1.2.1 speed adjustments
  v2.0 logic rework
  v2.1 removed all SWS functions (recoded from scratch)
  v2.2 accounts for trim volume on folders
  v2.3 bugfix for take envelopes not working correctly
--]]


----------------------------------DEBUG FUNCTIONS

--reaper.ClearConsole()

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

function take(param) return reaper.GetActiveTake(items[param]) end  --can call take function to match take to item
    
 



----------------------------------SET COMMON VARIABLES
items = {}
for i=1, reaper.CountSelectedMediaItems(0) do items[i] = reaper.GetSelectedMediaItem(0,i-1) end

tracks = {}
for i=1, reaper.CountSelectedTracks(0) do tracks[i] = reaper.GetSelectedTrack(0,i-1) end




----------------------------------SET COMMON FUNCTIONS

function CreateNewEnv(chunkname)
local EnvChunk = chunkname .. [[ 
EGUID ]]..reaper.genGuid("")..[[
ACT 1 -1
VIS 1 1 1
LANEHEIGHT 0 0
ARM 0
DEFSHAPE 0 -1 -1
VOLTYPE 1
PT 0 1 0
>
]]

return EnvChunk

end



function GetEnvelopeVis(envelope)
    local retval, str = reaper.GetEnvelopeStateChunk( envelope, "", false )
    if retval then
        str = string.match(str, "\nVIS %d")
        str = string.match(str, "%d")
        if str=="1" then return true else return false end

    end
 
end--EnvelopeVis()


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


function AddTrackEnv(track)

        local _,  str = reaper.GetTrackStateChunk(track, "", false )
        local volumeEnvelope = string.match(str, "MAINSEND %d %d\n")..CreateNewEnv("<VOLENV")
        str = string.gsub(str, "MAINSEND %d %d", volumeEnvelope)
        reaper.SetTrackStateChunk(track, str, false)

end--AdTrackEnv
    
 
    
    
    
----------------------------------CHECK IF ANY TAKES/TRACKS HAVE ANY ENVELOPES VISIBLE

function AnyTakeEnvVisible(param)  -- Param is Envelop to Check ("Volume", "Pan", or "Pitch"
    
          for i=1, #items
          do
              local NamedEnv = reaper.GetTakeEnvelopeByName(take(i), param)
              
              if NamedEnv then
                 if GetEnvelopeVis(NamedEnv)then return true end                  
              end--if

          end--for
          

end--AnyTakeEnvVisible  


function AnyTrackEnvVisible(param)  -- Param is Envelop to Check ("Volume", "Pan", or "Pitch"
    
          for i=1, #tracks 
          do
              local NamedEnv = reaper.GetTrackEnvelopeByName(tracks[i], param)
              
              if NamedEnv then
                 if GetEnvelopeVis(NamedEnv)then return true end                  
              end--if

          end--for
          

end--AnyTakeEnvVisible 



----------------------------------TOGGLE TAKE ENVELOPES

function ToggleTakeEnvelope(kind) -- Toggles the take envelope visibility Volume, Pan, or Pitch

      local visible = not AnyTakeEnvVisible(kind)     --decide if we should show or hide the envelope
      if visible then visible = "1" else visible = "0" end
      
      for i=1, #items do

            local _,  str = reaper.GetItemStateChunk( items[i], "", false )
                      str = string.gsub(str, "\nVIS %d", "\nVIS 0")  -- hide all envelopes for item
                      
            local     VolEnv = string.match(str, "<VOLENV.->")      --find the volume envelope
            
            if not    VolEnv 
            then      VolEnv = CreateNewEnv("<VOLENV")
                      
            end

            VolEnv = string.gsub(VolEnv, "\nVIS %d", "\nVIS "..visible)  -- adjust visibility per toggle we set earlier

            str =  str:match('(<ITEM.*)>.-$')
            str =  str .. VolEnv
            

            reaper.SetItemStateChunk(items[i], str, false)  -- write chunk
           
      end--for
      
      if #items == 1 then 
          reaper.SetCursorContext( 2, reaper.GetTakeEnvelopeByName(reaper.GetActiveTake(items[1]), "Volume" )) -- selects envelope
          --reaper.Main_OnCommand(40332,0) -- Envelope:  Select all points
      end
      
end--ToggleTakeEnvelope(param)





----------------------------------TOGGLE TRACK ENVELOPES

function toggletrackvisible(param)

      visible = not AnyTrackEnvVisible(param)  --decide to show or hide envelope


      for i=1, #tracks  -- loop through selected tracks
      do
            local   NamedEnv = reaper.GetTrackEnvelopeByName( tracks[i], param )  --check for the envelope we want
            if not  NamedEnv
            then 
                    AddTrackEnv(tracks[i])
                    NamedEnv = reaper.GetTrackEnvelopeByName( tracks[i], param )  --if it doesn't exist, create it and then point to it
            end
            
            for j=0,    reaper.CountTrackEnvelopes(tracks[i])-1 do       --loop through all track envelopes
                  local envelope = reaper.GetTrackEnvelope(tracks[i], j)
                  local _, name = reaper.GetEnvelopeName( envelope )
                  local _, trackname = reaper.GetTrackName(tracks[i])
                  
                  
                  if    envelope == NamedEnv
                  then
                        SetEnvelopeVis(envelope, visible)       --if the envelope matches our envelope we are looking for, adjust visibility
                       
                  else
                        if (name == "Trim Volume" and reaper.GetMediaTrackInfo_Value(tracks[i], "I_FOLDERDEPTH" ) == 1 and trackname ~= "PIX" ) then
                              SetEnvelopeVis(envelope, true)
                        else
                              SetEnvelopeVis(envelope, false)         --hide the rest 
                        end
                  end
            end--for
            if #tracks == 1 then 
                reaper.SetCursorContext( 2, NamedEnv ) 
                --reaper.Main_OnCommand(40332,0) -- Envelope:  Select all points    
            end -- selects envelope
      end--for

end--toggletrackvisible()


                



----------------------------------MAIN FUNCTION
function Main()

    if      #items > 0
    then
            ToggleTakeEnvelope("Volume")
          
    elseif  #tracks > 0 
    then    toggletrackvisible("Volume (Pre-FX)")
    
    end--if

end--main()


----------------------------------CALL THE SCRIPT

reaper.PreventUIRefresh(1)  --reset console window
Main()
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()


reaper.defer(function() end) --prevent Undo


