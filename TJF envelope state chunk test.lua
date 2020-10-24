 function EnvelopeVis(envelope, bool)
    local retval, str = reaper.GetEnvelopeStateChunk( envelope, "VIS", false )
    if retval then
        if bool 
        then str = string.gsub(str, "VIS %d", "VIS 1")
        else str = string.gsub(str, "VIS %d", "VIS 0")
        end
    end
    reaper.SetEnvelopeStateChunk( envelope, str, true )
 
 end--EnvelopeVis()


reaper.ClearConsole()
item = reaper.GetSelectedMediaItem(0,0)
take = reaper.GetActiveTake(item)
envelope =  reaper.GetTakeEnvelope( take, 1 )
EnvelopeVis(envelope, true)

boolean = false

test = tonumber(boolean)
 
 reaper.UpdateArrange()
 
