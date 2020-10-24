
local  retval, filename = reaper.GetUserFileNameForRead("", "Select a File", ".rpp" )
 
 if retval then
 
         local file = io.open(filename, "r") -- open in read mode
         io.input(file)
         local filetext =  io.read("a")
         io.close(file)
         
         
         filetext = string.gsub(filetext, "BYPASS 1.-WAK %d %d", "")  --removes any bypassed plugins  ".-" gets everything in between (least amount of characters)
         filetext = string.gsub(filetext, "BYPASS 0 1.-WAK %d %d", "")  --removes any bypassed plugins

         local newfilename = string.gsub(filename, ".RPP", "-Bypasses Removed.RPP")      --create new filename
         
         
         file = io.open(newfilename, "w") -- open in WRITE mode
         io.output(file)
         io.write(filetext)
         io.close(file)
         reaper.Main_openProject( newfilename)
         
         
end--if

