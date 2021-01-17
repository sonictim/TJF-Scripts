source_proj, source_proj_fn = reaper.EnumProjects( -1, "" )
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


 reaper.Main_SaveProject( 0, false )


 --reaper.SetProjectMarkerByIndex( source_proj, 0, false, 25, 25, 1, "=START", 1 )
 --reaper.SetProjectMarkerByIndex( source_proj, 1, false, 50, 50, 2, "=END", 1 )
