----------------------------------
--          DEBUG               --
----------------------------------

function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end

defaultfade = 0.084

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

function Crossfade(item1, item2, fadestart, fadeend)


                                 local item1start =  reaper.GetMediaItemInfo_Value( item1, "D_POSITION" )
                                 local item1end = item1start + reaper.GetMediaItemInfo_Value( item1, "D_LENGTH" )

                                 local item2start = reaper.GetMediaItemInfo_Value( item2, "D_POSITION" )
                                 local item2end = item2start + reaper.GetMediaItemInfo_Value( item2, "D_LENGTH" )
                                 
                                 if item1start < fadestart and item2end > fadeend then
                                 
                                 reaper.BR_SetItemEdges( item1, item1start, fadeend )
                                 reaper.SetMediaItemInfo_Value( item1, "D_FADEOUTLEN_AUTO", fadeend - fadestart )
                                 reaper.SetMediaItemInfo_Value( item1, "C_FADEOUTSHAPE", 1 )
                                 
                                 reaper.BR_SetItemEdges( item2, fadestart, item2end)
                                 reaper.SetMediaItemInfo_Value( item2, "D_FADEINLEN_AUTO",  fadeend - fadestart )
                                 reaper.SetMediaItemInfo_Value( item2, "C_FADEINSHAPE", 1 )
                                 
                                 return true
                                 
                                 else
                                 
                                 return false
                                 
                                 end



end

function ApplyDefaultFades(item)
      
      if reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN") == 0  then 
          reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO", defaultfade ) end
      
      
      if reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN") == 0 then 
          reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN_AUTO", defaultfade) end

end



----------------------------------MAIN FUNCTION
function Main()

      local trimstate = reaper.GetToggleCommandStateEx( 0, 41117) -- get Options: Toggle trim behind items state
      if trimstate == 1 then
        reaper.Main_OnCommand(41121, 0) -- Options: Disable trim behind items when editing
      end


               local selections = GetRazorEdits()
               

                        for i = 1, #selections do
                             local areaData = selections[i]
                             local items = areaData.items
                       
                                    for j = 1, #items do 
                                    
                                          
                                          local item = items[j]
                                          local itemstart =  reaper.GetMediaItemInfo_Value( item, "D_POSITION" )
                                          local itemend = itemstart + reaper.GetMediaItemInfo_Value( item, "D_LENGTH" )
                                          
                                          
                                          if itemstart >= areaData.areaStart and reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN") == 0  then 
                                              reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", defaultfade ) end
                                          
                                          
                                          
                                          if itemend <= areaData.areaEnd and reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN") == 0 then 
                                              reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", defaultfade) end
                                          
                                          if j==1 and itemstart > areaData.areaStart and itemstart < areaData.areaEnd and itemend > areaData.areaEnd then
                                            reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", areaData.areaEnd - itemstart )   
                                          
                                          
                                          elseif j == (#items) and itemstart < areaData.areaStart and itemend > areaData.areaStart and itemend < areaData.areaEnd then
                                              reaper.SetMediaItemInfo_Value( item, "D_FADEOUTLEN", itemend - areaData.areaStart)
                                          
                                          end
                                        
                                          
                                          
                                          
                                          --
                                          local nextitem = items[j+1]
                                              if nextitem then
                                                  nextstart = reaper.GetMediaItemInfo_Value( nextitem, "D_POSITION" )
                                                  nextend = nextstart + reaper.GetMediaItemInfo_Value( nextitem, "D_LENGTH" )
                                                  
                                                  if itemstart < areaData.areaStart and itemend > areaData.areaStart and itemend < areaData.areaEnd
                                                   and nextstart > areaData.areaStart and nextstart < areaData.areaEnd and nextend > areaData.areaEnd then
                                                    Crossfade(item, nextitem, areaData.areaStart, areaData.areaEnd)
                                                  
                                                  
                                                  
                                                  
                                                  
                                                  
                                                  elseif math.abs(nextstart - itemend) < defaultfade and reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN") < defaultfade and reaper.GetMediaItemInfo_Value(nextitem, "D_FADEINLEN") < defaultfade then 
                                                        Crossfade(item, nextitem, nextstart - defaultfade/2, itemend + defaultfade/2)
                                                  end
                                              
                                              end
                                          
                                    

                                      end -- for
                             
                             
                             
                             
                             end--for
                           
                            
                        
      
                        
                
                        
                        
                  reaper.UpdateArrange()

                        
              
        if trimstate == 1 then
          reaper.Main_OnCommand(41120,0) -- Re-enable trim behind items (if it was enabled)
        end
                
    
    
end--Main()

reaper.ClearConsole()
reaper.Undo_BeginBlock()
Main()
reaper.Undo_EndBlock("Apply Fades to razor edit",0)
