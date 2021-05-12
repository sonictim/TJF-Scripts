reaper.ClearConsole()
function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end


name = reaper.GetProjectName( 0, "" )
fullrecordpath = reaper.GetProjectPath("Audio Files" )

retval, recordpathshort = reaper.GetSetProjectInfo_String( 0, "RECORD_PATH", "", false )

sessionpath = string.gsub(fullrecordpath, recordpathshort, "") .. name .. "-PROX"

Msg(sessionpath)




testpath = "/Users/tfarrell/TEMP/REAPER/SUB PROJECT TEST/carolina/carolina.RPP"



reaper.InsertMedia( testpath, 0 )
reaper.Main_OnCommandEx(40441,0, 0) 


--[[
item = reaper.GetSelectedMediaItem(0, 0)

Msg( reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO"))
Msg(reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN"))


        reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN", .3 )
        reaper.SetMediaItemInfo_Value( item, "D_FADEINLEN_AUTO", .002 )



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
]]



--source_proj, source_proj_fn = reaper.EnumProjects( -1, "" )

--offset =  reaper.GetProjectTimeOffset( 0, false )

--reaper.SNM_SetDoubleConfigVar("projtimeoffs",offset * 2)

--reaper.UpdateTimeline(0)


--toggle =  reaper.SNM_GetIntConfigVar( "multiprojopt", 0 )

-- reaper.SNM_SetIntConfigVar(  "multiprojopt", 4096)




--track =  reaper.GetMasterTrack( 0 )
 --retval, str = reaper.GetTrackStateChunk( track, "", false )

--Msg(str)

--[[
projIdx = 0
proj = source_proj

while proj ~= nil do
    projIdx = projIdx + 1
    proj, _ = reaper.EnumProjects( projIdx, "" )
end

reaper.Main_OnCommand(41049, 0) --insert new subproject

dest_proj, dest_proj_fn = reaper.EnumProjects(projIdx, "" )

reaper.SelectProjectInstance(dest_proj)
]]

-- retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers( 2 )
-- reaper.SetProjectMarker( 2, isrgn, 25, rgnend, "TIM" )


 --reaper.Main_SaveProject( 0, false )


 --reaper.SetProjectMarkerByIndex( source_proj, 0, false, 25, 25, 1, "=START", 1 )
 --reaper.SetProjectMarkerByIndex( source_proj, 1, false, 50, 50, 2, "=END", 1 )
