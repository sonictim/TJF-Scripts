function Msg(param) reaper.ShowConsoleMsg(tostring(param).."\n") end --Debug Mesages

function take(param) return reaper.GetActiveTake(item[param]) end  --can call take function to match take to item


function titleCase( first, rest )
         return first:upper()..rest:lower()
         --function to call later:  STRING = string.gsub(STRING, "(%a)([%w_']*)", titleCase) 
end

function GetFileExtension(url)
        local str = url
        local temp = ""
        local result = "." -- ! Remove the dot here to ONLY get the extension, eg. jpg without a dot. The dot is added because Download() expects a file type with a dot.
      
        for i = str:len(), 1, -1 do
          if str:sub(i,i) ~= "." then
            temp = temp..str:sub(i,i)
          else
            break
          end
        end
      
        -- Reverse order of full file name
        for j = temp:len(), 1, -1 do
          result = result..temp:sub(j,j)
        end
      
        return result
end



function file_exists(name)
       local f=io.open(name,"r")
       if f~=nil then io.close(f) return true else return false end
end




function itemfilename(item)

    local take = reaper.GetActiveTake(item)
    local source = reaper.GetMediaItemTake_Source(take)
    local parentsource =  reaper.GetMediaSourceParent( source ) -- PCM SOURCE FOR REVERSED ITEMS
    local filename = reaper.GetMediaSourceFileName(source, '')
    if filename == "" then filename = reaper.GetMediaSourceFileName(parentsource, '') end
    return filename
    
end


function RenameItemAndSource(item, newname)  -- param 1 is item, parameter 2 is new name

          local take = reaper.GetActiveTake(item)
          local name =  reaper.GetTakeName( take )
          --local retval, section, start, length, fade, reverse = reaper.BR_GetMediaSourceProperties( take )

          local source = reaper.GetMediaItemTake_Source(take)
          local parentsource =  reaper.GetMediaSourceParent( source ) -- PCM SOURCE FOR REVERSED ITEMS
          local filename = reaper.GetMediaSourceFileName(source, '')
          if filename == "" then filename = reaper.GetMediaSourceFileName(parentsource, '') end
          
          if filename then
          
                local path = filename:match('^(.+[\\/])')
                local extension = GetFileExtension(filename)
                local newFilename = path .. newname .. extension 
                
                
                os.rename(filename, newFilename)  -- WILL DESTRUCTIVELY RENAME CAREFUL
                
                for i=0, reaper.CountTracks(0)-1 do
                    local track = reaper.GetTrack(0,i)
                
                    local _, chunk = reaper.GetTrackStateChunk(track, "", false )
                    
                    chunk = string.gsub(chunk, filename, newFilename)
                    chunk = string.gsub(chunk, "\nNAME " .. name .. "\n", "\nNAME " ..newname.. "\n")
                    
                    reaper.SetTrackStateChunk( track, chunk, false )
                
                end--for

          
          end--if
          
          reaper.Main_OnCommand(40047, 0)--Peaks: Build any missing peaks 
          

end--function

for i=0, reaper.CountSelectedMediaItems(0)-1 do

item = reaper.GetSelectedMediaItem(0,i)
name = "Bands"..tostring(i)

RenameItemAndSource(item, name)

end
