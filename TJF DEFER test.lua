--@description TJF Script Name
--@version 1.0
--@author Tim Farrell
--
--@about
--  # TJF Script Name
--  Information about the script
--
--@changelog
--  v1.0 - nothing to report


----------------------------------COMMON FUNCTIONS or FUNCTIONS I WANT TO REMEMBER

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

--[[      CONVERT TEXT TO TITLE CASE
function titleCase( first, rest ) return first:upper()..rest:lower() end
   --How to call in script:  STRING = string.gsub(STRING, "(%a)([%w_']*)", titleCase) 





----------------------------------SET COMMON VARIABLES

    local sel_items = {}

    
    function RazorEditSelectionExists()
          for i=0, reaper.CountTracks(0)-1 do
              local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then return true end
          end
    return false
    
    end--AreaSelectionExists()
    
    
    
    
    -- Very limited - no error checking, types, hash tables, etc
    function shallow_equal(t1, t2)
      if #t1 ~= #t2 then return false end
      for k, v in pairs(t1) do
        if v ~= t2[k] then return false end
      end
      return true
    end
    
 ]]--   
  
    
    


----------------------------------MAIN FUNCTION
function Main()
      reaper.ClearConsole()
      local itemcount = reaper.CountSelectedMediaItems(0)
      
      if itemcount then
      
            --[[local cur_items = {}
            for i = 1, itemcount do cur_items[i] = reaper.GetSelectedMediaItem( 0, i - 1 ) end
            
            if not shallow_equal(sel_items, cur_items) then
                  sel_items = cur_items
            
            ]]--
            
                for i = 0, itemcount-1 do 
                
                  local item = reaper.GetSelectedMediaItem(0, i)
                  
                  for t=0, reaper.CountTakes(item)-1 do
    
                        local take =   reaper.GetTake( item, t )
                        local source = reaper.GetMediaItemTake_Source(take)
                        local sourcechan =  reaper.GetMediaSourceNumChannels( source )
                        local chanmode = reaper.GetMediaItemTakeInfo_Value(take, "I_CHANMODE")
                        
                        
                        if sourcechan == 1 or (chanmode > 1 and chanmode < 67 ) then
                        
                        
                            local fx = reaper.TakeFX_AddByName( take, "TJF Mono to Channel 3 (Center)", 1)
                            reaper.TakeFX_Show( take, fx, 2 )
                            if fx <  reaper.TakeFX_GetCount(take)-1 then
                                reaper.TakeFX_Delete( take, fx )
                                fx = reaper.TakeFX_AddByName( take, "TJF Mono to Channel 3 (Center)", 1)
                                reaper.TakeFX_Show( take, fx, 0 )
                            end--if
                            
                        end--if
                        
                        
                        
                        Msg(sourcechan)
                  end--for
                        
    
                  
                  
                end--for
                
            --end--if
            
            
      
      
      
      
      end--if

reaper.defer(Main)


end--Main()


----------------------------------CALL THE SCRIPT

--reaper.ShowConsoleMsg("")  --reset console window
reaper.Undo_BeginBlock()
--reaper.PreventUIRefresh(1) -- uncomment only once script works
Main()
--reaper.PreventUIRefresh(-1) -- uncomment only once script works
reaper.UpdateArrange()
--reaper.UpdateTimeline()
--reaper.TrackList_AdjustWindows(0)  -- Updates the window view (used when resizing tracks)
reaper.Undo_EndBlock("TJF Script Name", -1)

--reaper.defer(function() end) --prevent Undo

    
   
