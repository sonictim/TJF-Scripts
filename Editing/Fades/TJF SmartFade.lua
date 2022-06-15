--@description TJF Smart Fade (similar behavior to Protools)
--@version 1.8
--@author Tim Farrell
--
--@about
--  # TJF Smart Fade (similar behavior to Protools)
--  This script mimics certain fade behaviors from protools based on time selection, Razor Edit, or Item Selection.
--  It is a bit contextual, and behaves slightly different based on which tool you are using (time/razor/item selection)
--  I recommend working in a protools style mode with Autocrossfade off and Cut Behind Items enabled
--  
--  DEFAULT FADE LENGTH:
--  This script has a default fade length and allows you to set the default fadeshapes for normal fades as well as scrossfades
--  These settings can be adjusted in GLOBAL VARIABLES
--
--  Thanks to BirdBird and Amagalma for chunks of this code as well as inspiration for learning some techniques to make this script possible
--
--@changelog
--  v1.0 - nothing to report
--  v1.1 - bugfix - fixes error with default fade of last item in a series.
--  v1.2 - bugfix - repeated use was creating undesirable behavior
--  v1.3 - logic rework - time selection is now processed per track for better crossfade manipulation
--       - new feature - Crossfade size can now be decreased.
--  v1.4 - bugfix - can now fade out length of item if time selection is set to exactly the end of the item
--  v1.5 - added GLOBAL VARIABLE option to remove selection after processing fades
--  v1.6 - added GLOBAL VARIABLE option for crossfaces to occur "presplice"
--  v1.7 - bugfix - corrected error where tradition (non auto) fades were being removed from items
--  v1.8 - bugfix - autocrossfade removes regular fades set by previous version of this script



--[[------------------------------[[--
          SET GLOBAL VARIABLES          
--]]------------------------------]]--

local defaultfade = 0.084  -- Set is Seconds:  1 frame = .042
local defaultFadeShape = 0 --  0 = equal gain (straight line) 1 = equal power (curved)
local defaultCrossfadeShape = 1 --  0 = equal gain (straight line) 1 = equal power (curved)
local prespliceCrossfade = true -- if true, default crossfade will occur before the edit point, not across it.  If false, it will fade on either side of the split
local removeSelection = false -- if true will remove the time selection/razor edit selection after running the script



--[[------------------------------[[--
                DEBUG         
--]]------------------------------]]--

reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end





--[[------------------------------[[--
         DECLARE FUNCTIONS          
--]]------------------------------]]--


function RazorEditSelectionExists()
          for i=0, reaper.CountTracks(0)-1 do
              local retval, x = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0,i), "P_RAZOREDITS", "string", false)
              if x ~= "" then return true end
          end
    return false
    
end--razorEditSelectionExists()


function GetRazorEdits()  -- Function Written by BirdBird on reaper forums
        local trackCount = reaper.CountTracks(0)
        local areaMap = {}
        for i = 0, trackCount - 1 do
            local track = reaper.GetTrack(0, i)
            local ret, area = reaper.GetSetMediaTrackInfo_String(track, 'P_RAZOREDITS', '', false)
            if area ~= '' then
                --PARSE STRING
                local str = {}
                for j in string.gmatch(area, "%S+") do
                    table.insert(str, j)
                end
            
                --FILL AREA DATA
                local j = 1
                while j <= #str do
                    --area data
                    local areaStart = tonumber(str[j])
                    local areaEnd = tonumber(str[j+1])
                    local GUID = str[j+2]
                    local isEnvelope = GUID ~= '""'
    
                    --get item data
                    local items = {}
                    if not isEnvelope then
                        local itemCount = reaper.CountTrackMediaItems(track)
                        for k = 0, itemCount - 1 do 
                            local item = reaper.GetTrackMediaItem(track, k)
                            local pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                            local length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
                            local itemEndPos = pos+length
    
                            --check if item is in area bounds
                            if (itemEndPos > areaStart and itemEndPos <= areaEnd) or
                                (pos >= areaStart and pos < areaEnd) or
                                (pos <= areaStart and itemEndPos >= areaEnd) then
                                    table.insert(items,item)
                            end
                        end
                    end
    
                    local areaData = {
                        areaStart = areaStart,
                        areaEnd = areaEnd,
                        track = track,
                        items = items,
                        isEnvelope = isEnvelope,
                        GUID = GUID
                    }
    
                    table.insert(areaMap, areaData)
    
                    j = j + 3
                end
            end
        end
    
        return areaMap
end


function FadeInExists(item)
    if    reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO") > 0 or reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN") > 0
    then  return true
    else  return false
    end
end -- function


function FadeOutExists(item)
    if  reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO") > 0 or reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN") > 0
    then  return true
    else  return false
    end
end -- function



function ApplyDefaultFades(item)
      
      if  not FadeInExists(item)
      then
          reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO", defaultfade )
          reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", defaultfade )
          reaper.SetMediaItemInfo_Value( item, "C_FADEINSHAPE", defaultFadeShape )
      end
      
      
      if  not FadeOutExists(item)
      then
          reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO", defaultfade)
          reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", defaultfade)
          reaper.SetMediaItemInfo_Value( item, "C_FADEOUTSHAPE", defaultFadeShape )
          
      end

end



function ProccessFades(items, starttime, endtime) -- items should be a table


    for j = 1, #items do
         
                                ---++=<{[ PROCESS INDIVIDUAL ITEMS ]}>=++---
      
      local item = items[j]
      local itemstart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
      local itemend = itemstart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
      
      if    starttime ~= endtime -- if there is a set time parameter (bounds)
      then
            if    itemstart >= starttime and not FadeInExists(item)  -- if item start is within bounds and doesn't have a fade in
            then 
                  reaper.BR_SetItemEdges( item, itemstart+1, itemend )
                  reaper.BR_SetItemEdges( item, itemstart, itemend )    -- this will get the autocrossfade to kick in if overlapping other items
                  
                  if    not FadeInExists(item) --  if item still doesn't have a fadein
                  then
                        reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO", defaultfade )   --apply defauilt fadein
                        reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", defaultfade )   --apply defauilt fadein
                  end
            end
            
            
            if    itemend <= endtime and not FadeOutExists(item)  -- if item end is within bounds and doesn't have a fade out
            then 
                  reaper.BR_SetItemEdges( item, itemstart, itemend+1 )  -- this will get the autocrossfade to kick in if overlapping other items
                  reaper.BR_SetItemEdges( item, itemstart, itemend )
                 
                  if     not FadeOutExists(item)  -- if there still isn't a fade out
                  then
                        reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO", defaultfade)  -- apply default fadeout
                        reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", defaultfade)  -- apply default fadeout
                  end
            end
            
            
            
            if    itemstart >= starttime and itemstart <= endtime and itemend > endtime and #items == 1  -- if the item starts within bounds but ends outside of them  *** commented section allows multiple files on same lane to adjust to razor edit
            then
                  local fadeoutlen = reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO")    -- if the boundry interrupts the fadout.....
                  if    fadeoutlen > itemend - endtime
                  then  
                        reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO", itemend - endtime )  -- .....then adjust the fadeout
                        reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", itemend - endtime )  -- .....then adjust the fadeout
                  end--if
                  
                  reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO", endtime - itemstart )  --  fade item from start to end boundry 
                  reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", endtime - itemstart )  --  fade item from start to end boundry 
            
            elseif itemstart < starttime and itemend > starttime and itemend <= endtime and #items == 1  -- if the item starts outside of bounds, but ends within them  *** commented section allows multiple files on same lane to adjust to razor edit
            then
                 local fadeinlen = reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO")   -- if the boundry falls in the middle of a fade in........
                 if    fadeinlen > starttime - itemstart
                 then  
                       reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO", starttime - itemstart ) -- ..... then adjust the fadein
                       reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", starttime - itemstart ) -- ..... then adjust the fadein
                 end--if 
                  reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO", itemend - starttime)  -- fade out item from start of bounds to end of item
            end

        else      -- Fades will just be based on item selection
               reaper.BR_SetItemEdges( item, itemstart+1, itemend+1 )
                reaper.BR_SetItemEdges( item, itemstart, itemend )
               ApplyDefaultFades(item)  -- if no time parameters have been set, just apply the default fadein and fade out
        end -- if



        
        ---++=<{[ LOOK AHEAD TO NEXT ITEM TO SEE IF CROSSFADES ARE REQUIRED ]}>=++---
 
        
        
        local nextitem = items[j+1]  -- process next item to see if a crossfade is required
        if    nextitem          -- if next item doesn't exist, don't bother with the rest
        then
              local nextstart = reaper.GetMediaItemInfo_Value( nextitem, "D_POSITION" )
              local nextend = nextstart + reaper.GetMediaItemInfo_Value( nextitem, "D_LENGTH" )
          
              if    #items == 2 
                    and starttime ~= endtime
                    --and itemstart < starttime and itemend > starttime and itemend < endtime       --checks to see if we want to just create a big crossfade the size of the boundry
                    --and nextstart > starttime and nextstart < endtime and nextend > endtime

              then
                    
                    if      itemstart < starttime and nextend > endtime
                    then    reaper.BR_SetItemEdges( item, itemstart, endtime )      -- Do the big crossfade set to the length of the boundry  -- exploits the auto crossfade which we turned on
                            reaper.BR_SetItemEdges( nextitem, starttime, nextend )
                    
                    elseif  itemstart < starttime and nextstart < starttime and itemend < nextend
                    then    reaper.BR_SetItemEdges( nextitem, starttime, nextend )
                    
                    elseif  itemend > endtime and nextend > endtime and itemend < nextend
                    then    reaper.BR_SetItemEdges( item, itemstart, endtime )
                     
                    end
                    reaper.SetMediaItemInfo_Value( item, "C_FADEOUTSHAPE", defaultCrossfadeShape )
                    reaper.SetMediaItemInfo_Value( nextitem, "C_FADEINSHAPE", defaultCrossfadeShape )
                    --Crossfade(item, nextitem, starttime, endtime)                             --sets the crossfade to the function bounds  -- function no longer used.. exploiting auto crossfade instead
            
      
             --  This prevents creep from reuse
             
             elseif  itemend > endtime and #items > 2 and starttime ~= endtime
             then    reaper.BR_SetItemEdges( item, itemstart, endtime )
             
             elseif nextstart < starttime and #items > 2 and starttime ~= endtime
             then    reaper.BR_SetItemEdges( nextitem, starttime, nextend )
             
             
              

              elseif  math.abs(nextstart - itemend) < defaultfade - .001                              --if the overlap between two items is less than the default fade length
                      and (reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN") < defaultfade-.001 or reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO") < defaultfade-.001)     --and the current fadeout length of the first item is smaller than the default fade length
                      and (reaper.GetMediaItemInfo_Value(nextitem, "D_FADEINLEN") < defaultfade-.001 or reaper.GetMediaItemInfo_Value(nextitem, "D_FADEINLEN_AUTO") < defaultfade-.001)    --and the current fadein length of the second item is less than the default fade length
              then 
                      if prespliceCrossfade then
                            reaper.BR_SetItemEdges( nextitem, nextstart - defaultfade, nextend )
                      else
                            reaper.BR_SetItemEdges( item, itemstart, itemend - defaultfade/2 + defaultfade )  -- Crossfade these items the length of the default crossfade
                            reaper.BR_SetItemEdges( nextitem, nextstart - defaultfade/2, nextend )
                      end
                    
                      reaper.SetMediaItemInfo_Value( item, "C_FADEOUTSHAPE", defaultCrossfadeShape )
                      reaper.SetMediaItemInfo_Value( nextitem, "C_FADEINSHAPE", defaultCrossfadeShape )
              
              end
              
        end -- if    
      
  end -- for J
end -- ProcessFades ()



--[[------------------------------[[--
           MAIN FUNCTION       
--]]------------------------------]]--

function Main()

      -------------------------------------------------------------------------++=<{[ CHECK TRIM/AutoCrossfade STATE ]]--
      
      local trimstate = reaper.GetToggleCommandStateEx( 0, 41117) -- get Options: Toggle trim behind items state
      
      if    trimstate == 1
      then  reaper.Main_OnCommand(41121, 0) -- Options: Disable trim behind items when editing
      end
      
      local crossstate =  reaper.GetToggleCommandStateEx( 0, 40041) -- Options: Toggle auto-crossfade on/off
      
      if    crossstate == 0
      then  reaper.Main_OnCommand(41118, 0) -- Options: Enable auto-crossfades
      end
      
      
      
      
      --[[ LOGIC FOR CHOOSING WHICH ITEMS TO PROCESS FOR FADES ]]--

      -------------------------------------------------------------------------++=<{[ FIRST PRIORITY: TIME SELECTION ]}>=++---
      
      local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
      
      if start_time ~= end_time
      then
          local selected = false
          if reaper.CountSelectedMediaItems(0) > 0 then selected = true end
          
          for t=0, reaper.CountTracks(0)-1 do
          
              local track = reaper.GetTrack(0,t)
              local items = {}                                -- Create 2 table.  items = items that fall within the time selection
              local selitems = {}                             --                  selitems = items that fall within the time seleciton that are also selected
                    
                    
                    for   i=1, reaper.CountTrackMediaItems(track)
                    do
                          
                          local item = reaper.GetTrackMediaItem(track,i-1)
                          local itemstart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION")
                          local itemend = itemstart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH")
                          
                          if    (itemstart >= start_time and itemstart <= end_time)   -- logic for deciding which items fall within the time selection
                                or (itemend >= start_time and itemend <= end_time)
                                or (itemstart <= start_time and itemend >= end_time)
                          then
                                if selected then
                                
                                  if    reaper.IsMediaItemSelected( item )
                                  then
                                        table.insert(items, item)
                                  end--if
                                
                                else
                                    table.insert(items, item)                             -- fill the table
                                end--if
                                
                          end--if
                          
                    end--for(i)
                    
                    if      #items > 0                                   -- if there are selected items, process them
                    then  
                            ProccessFades(items, start_time, end_time)
                            if removeSelection then reaper.Main_OnCommand(40635, 0) end -- remove time selection
                    end
            end--for t
                  
      
      -------------------------------------------------------------------------++=<{[ SECOND PRIORITY: RAZOR EDIT ]}>=++--- 
      
      elseif  RazorEditSelectionExists()
      then

              local selections = GetRazorEdits()            -- returns razor edits in an array by track

              for   i = 1, #selections                      --  for each track, process any razor edits on it              
              do
                    areaData = selections[i]                                       
                    
                    ProccessFades(areaData.items, areaData.areaStart, areaData.areaEnd)
                    if removeSelection then reaper.Main_OnCommand(42406, 0) end -- remove razor edit selection selection 
              end -- for(i)


      -------------------------------------------------------------------------++=<{[ THIRD PRIORITY: SELECTED ITEMS ]}>=++---

      elseif  reaper.GetSelectedMediaItem(0,0) 
      then
              local items = {}
              
              for i=1, reaper.CountSelectedMediaItems(0)
              do
                  items[i] = reaper.GetSelectedMediaItem(0, i-1)
              end
          
              ProccessFades(items, 1, 1)  -- setting the last 2 variables to match changes the behavior of the processing function.  In theory, could leave these blank
              if removeSelection then reaper.Main_OnCommand(40289, 0) end -- remove item selections    
      end
                                           
      --------------------------------------------------------------------------++=<{[ RESTORE TRIM/AutoCrossfade STATE ]}>=++---     
        
      if      trimstate == 1 
      then
              reaper.Main_OnCommand(41120,0) -- Re-enable trim behind items (if it was enabled)
      end
        
        
      if      crossstate == 0 
      then
              reaper.Main_OnCommand(41119,0) -- Re-disable auto-crossfades (if it was enabled)
      end
          
end--Main()



--[[------------------------------[[--
            CALL THE SCRIPT          
--]]------------------------------]]--

--reaper.ClearConsole()
reaper.PreventUIRefresh(1)

reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("TJF Smart Fade",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()

