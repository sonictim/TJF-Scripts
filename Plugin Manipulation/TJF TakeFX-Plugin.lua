--@description TJF Add/Recall TakeFX-Plugin
--@version 1.1
--@author Tim Farrell
--
--@about
--  # TJF Add/Recall TakeFX-Plugin
--  Adds or Recalls Named Plugin via Take FX
--  Looks to filename to find Named Plugin
--  Looks Between "-" and "." to find what it's looking for.
--
--@changelog
--  v1.0 - nothing to report
--  v1.1 - now floats FX Plugin Window



local PluginName = "Get From Filename" -- Leave as is to get Plugin Name from Filename.  Change to specify




----------------------------------SET COMMON VARIABLES/FUNCTIONS

    
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

function GetPluginNameFromFilename()

        local info = debug.getinfo(1,'S')  -- Builds a table with info about the lua script
        info.plugin = string.match(info.source, "%-.*%.")  -- info.source is filename in the table
        info.plugin = info.plugin:sub(2,#info.plugin-1) -- removes first/last character of string
        return info.plugin
end
--[[                                  UNUSED FUNCTIONS
function HideAllTakeFX(take)
        
        for i=0, reaper.TakeFX_GetCount(take)-1 do
        Msg("plugin " .. i)
        reaper.TakeFX_Show( take, i, 0) -- Close FX Chain
        reaper.TakeFX_Show( take, i, 2) -- Close Floating FX1
          
        end
end

function FloatOnlyChosenTakeFX(take, index)
        
        for i=0, reaper.TakeFX_GetCount(take)-1 do
            if i==index then
                    
                    reaper.TakeFX_Show( take, i, 3) -- Float Desired Plugin Window
                else
                    reaper.TakeFX_Show( take, i, 2) -- Hide Other Windows
                end
                
            reaper.TakeFX_Show( take, i, 0) -- Close FX Chain    
        end
end
]]

function AddTakeFX(PluginName)
    for i=0, reaper.CountSelectedMediaItems(0)-1 do
          local take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0,i))
          local index = reaper.TakeFX_AddByName(take, PluginName, 1 )  -- Returns index of plugin (will add plugin if not already added)
          reaper.TakeFX_Show( take, index, 3) -- Float Desired Plugin Window
          --FloatOnlyChosenTakeFX(take, index)
    end--for
end--function

--[[
function AddTrackFX(PluginName)
    for i=0, reaper.CountSelectedTracks(0)-1 do
          local track = reaper.GetSelectedTrack(0, i)
          local index = reaper.TrackFX_AddByName(track, PluginName, false, 1 )
          reaper.TrackFX_Show(track, index, 3)
    end--for
end--function
]]

function get_file_name(file)
      return file:match("^.+/(.+)$")
end





----------------------------------MAIN FUNCTION
function Main()

          if PluginName == "Get From Filename" then
              PluginName = GetPluginNameFromFilename()  -- Sets Variable to Plugin in the filename (if you follow my filename format) Comment out to use Default setting from above
          end
          
          if reaper.GetSelectedMediaItem(0,0) then                               -- If there are items selected 
                AddTakeFX(PluginName)
          --else
                --AddTrackFX(PluginName)
          end


end--Main()


----------------------------------CALL THE SCRIPT

--reaper.ShowConsoleMsg("")  --reset console window
--reaper.Undo_BeginBlock()
--reaper.PreventUIRefresh(1) -- uncomment only once script works
--reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_FOCUS_TRACKS"), 0)
Main()
--reaper.PreventUIRefresh(-1) -- uncomment only once script works
--reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)
--reaper.Undo_EndBlock("TJF TakeFX-Plugin", -1)

reaper.defer(function() end) --prevent Undo

    
   
