--[[------------------------------[[--
                DEBUG         
--]]------------------------------]]--

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end



--[[------------------------------[[--
          SET GLOBAL VARIABLES          
--]]------------------------------]]--

local defaultfade = 0.084  -- 2 frames
local defaultFadeShape = 0 -- equal gain
local defaultCrossfadeShape = 1 -- equal power


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


--[[      FUNCTION NO LONGER USED  -- exploiting auto crossfade instead
function Crossfade(item1, item2, fadestart, fadeend)


     local item1start =  reaper.GetMediaItemInfo_Value( item1, "D_POSITION" )
     local item1end = item1start + reaper.GetMediaItemInfo_Value( item1, "D_LENGTH" )

     local item2start = reaper.GetMediaItemInfo_Value( item2, "D_POSITION" )
     local item2end = item2start + reaper.GetMediaItemInfo_Value( item2, "D_LENGTH" )
     
     if item1start < fadestart and item2end > fadeend
     then
       
       reaper.BR_SetItemEdges( item1, item1start, fadeend )
       reaper.SetMediaItemInfo_Value( item1, "D_FADEOUTLEN_AUTO", fadeend - fadestart )
       reaper.SetMediaItemInfo_Value( item1, "C_FADEOUTSHAPE", defaultCrossfadeShape )
       
       reaper.BR_SetItemEdges( item2, fadestart, item2end)
       reaper.SetMediaItemInfo_Value( item2, "D_FADEINLEN_AUTO",  fadeend - fadestart )
       reaper.SetMediaItemInfo_Value( item2, "C_FADEINSHAPE", defaultCrossfadeShape )
       
       return true
     
     else
     
       return false
     
     end
end
]]

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
          reaper.SetMediaItemInfo_Value( item, "C_FADEINSHAPE", defaultFadeShape )
      end
      
      
      if  not FadeOutExists(item)
      then
          reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO", defaultfade)
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
                  end
            end
            
            
            if    itemend <= endtime and not FadeOutExists(item)  -- if item end is within bounds and doesn't have a fade out
            then 
                  reaper.BR_SetItemEdges( item, itemstart, itemend+1 )  -- this will get the autocrossfade to kick in if overlapping other items
                  reaper.BR_SetItemEdges( item, itemstart, itemend )
                 
                  if     not FadeOutExists(item)  -- if there still isn't a fade out
                  then
                        reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO", defaultfade)  -- apply default fadeout
                  end
            end
            
            
            
            if    itemstart >= starttime and itemstart <= endtime and itemend > endtime and j==1  -- if the item starts within bounds but ends outside of them
            then
                  local fadeoutlen = reaper.GetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO")    -- if the boundry interrupts the fadout.....
                  if    fadeoutlen > itemend - endtime
                  then  
                        reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO", itemend - endtime )  -- .....then adjust the fadeout
                  end--if
                  
                  reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO", endtime - itemstart )  --  fade item from start to end boundry 
            
            elseif itemstart < starttime and itemend > starttime and itemend < endtime and j == (#items)  -- if the item starts outside of bounds, but ends within them
            then
                 local fadeinlen = reaper.GetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO")   -- if the boundry falls in the middle of a fade in........
                 if    fadeinlen > starttime - itemstart
                 then  
                       reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO", starttime - itemstart ) -- ..... then adjust the fadein
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
        if    nextitem           -- if next item doesn't exist, don't bother with the rest
        then
              local nextstart = reaper.GetMediaItemInfo_Value( nextitem, "D_POSITION" )
              local nextend = nextstart + reaper.GetMediaItemInfo_Value( nextitem, "D_LENGTH" )
            
          
              if    itemstart < starttime and itemend > starttime and itemend < endtime       --checks to see if we want to just create a big crossfade the size of the boundry
                    and nextstart > starttime and nextstart < endtime and nextend > endtime
                    and starttime ~= endtime
              then
                    reaper.BR_SetItemEdges( item, itemstart, endtime )      -- Do the big crossfade set to the length of the boundry  -- exploits the auto crossfade which we turned on
                    reaper.BR_SetItemEdges( nextitem, starttime, nextend )
                    
                    reaper.SetMediaItemInfo_Value( item, "C_FADEOUTSHAPE", defaultCrossfadeShape )
                    reaper.SetMediaItemInfo_Value( nextitem, "C_FADEINSHAPE", defaultCrossfadeShape )
                    --Crossfade(item, nextitem, starttime, endtime)                             --sets the crossfade to the function bounds  -- function no longer used.. exploiting auto crossfade instead
   
              elseif  math.abs(nextstart - itemend) < defaultfade                               --if the overlap between two items is less than the default fade length
                      and (reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN") < defaultfade or reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO") < defaultfade)     --and the current fadeout length of the first item is smaller than the default fade length
                      and (reaper.GetMediaItemInfo_Value(nextitem, "D_FADEINLEN") < defaultfade or reaper.GetMediaItemInfo_Value(nextitem, "D_FADEINLEN") < defaultfade)    --and the current fadein length of the second item is less than th default fade length
              then 
                      reaper.BR_SetItemEdges( item, itemstart, nextstart - defaultfade/2 + defaultfade )  -- Crossfade these items the length of the default crossfade
                      reaper.BR_SetItemEdges( nextitem, nextstart - defaultfade/2, nextend )
                    
                      reaper.SetMediaItemInfo_Value( item, "C_FADEOUTSHAPE", defaultCrossfadeShape )
                      reaper.SetMediaItemInfo_Value( nextitem, "C_FADEINSHAPE", defaultCrossfadeShape )
                      --Crossfade(item, nextitem, itemend - defaultfade/2, itemend - defaultfade/2 + defaultfade)  -- crossfades to the default length  function no longer used.. exploiting auto crossfade instead 
              end          
        end -- if    
  end -- for J
end -- ProcessFades ()



--[[------------------------------[[--
           MAIN FUNCTION       
--]]------------------------------]]--

function Main()
      --CHECK TRIM/AutoCrossfade STATE
      local trimstate = reaper.GetToggleCommandStateEx( 0, 41117) -- get Options: Toggle trim behind items state
      
      if    trimstate == 1
      then  reaper.Main_OnCommand(41121, 0) -- Options: Disable trim behind items when editing
      end
      
      local crossstate =  reaper.GetToggleCommandStateEx( 0, 40041) -- Options: Toggle auto-crossfade on/off
      
      if    crossstate == 0
      then  reaper.Main_OnCommand(41118, 0) -- Options: Enable auto-crossfades
      end
      
      
      
      
      --[[ LOGIC FOR CHOOSING WHICH ITEMS TO PROCESS FOR FADES ]]--

      ---++=<{[ FIRST PRIORITY: TIME SELECTION ]}>=++---
      
      local start_time, end_time = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false) -- Get start and end time selection value in seconds
      
      if start_time ~= end_time
      then
      
             items = {}
             selitems = {}
            
            for   i=1, reaper.CountMediaItems(0)
            do
                  
                  local item = reaper.GetMediaItem(0,i-1)
                  local itemstart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION")
                  local itemend = itemstart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH")
                  
                  if    (itemstart >= start_time and itemstart <= end_time)
                        or (itemend >= start_time and itemend <= end_time)
                  then
                        table.insert(items, item)
                        if    reaper.IsMediaItemSelected( item )
                        then
                              table.insert(selitems, item)
                        end--if
                  end--if
                  
            end--for(i)
            
            if      #selitems > 0
            then  
                    ProccessFades(selitems, start_time, end_time)
                    
            elseif  #items > 0
            then
                    ProccessFades(items, start_time, end_time)
            end
                
                  
      
      ---++=<{[ SECOND PRIORITY: RAZOR EDIT ]}>=++--- 
      
      elseif RazorEditSelectionExists()
      then
      
              local selections = GetRazorEdits()

              for   i = 1, #selections
              do
                    local areaData = selections[i]
                    ProccessFades(areaData.items, areaData.areaStart, areaData.areaEnd)
              end   -- for i



      ---++=<{[ THIRD PRIORITY: SELECTED ITEMS ]}>=++---

      elseif reaper.GetSelectedMediaItem(0,0) 
      then
      
          local items = {}
          for i=1, reaper.CountSelectedMediaItems(0)
          do
              items[i] = reaper.GetSelectedMediaItem(0, i-1)
          end
          
          ProccessFades(items, 1, 1)
          
      end
                                           
        --RESTORE TRIM/AutoCrossfade STATE      
        if trimstate == 1 then
          reaper.Main_OnCommand(41120,0) -- Re-enable trim behind items (if it was enabled)
        end
        
        
        if crossstate == 0 then
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

