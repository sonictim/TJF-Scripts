function Msg(var)
  reaper.ShowConsoleMsg(tostring(var))
end



function Action(env)
  retval, xml_env = reaper.GetEnvelopeStateChunk(env, "", false)
  xml_env = xml_env:gsub("\n", "¤¤")
  retval, xml_env = reaper.SetEnvelopeStateChunk(env, xml_env, false)
return xml_env

end

function DeleteEnv(env, track)

          retval, xml_track = reaper.GetTrackStateChunk(track, "", false)
          
          xml_track = xml_track:gsub("\n", "¤¤")
          
          xml_env =  Action(env)
        
end


--function Main()
      track = reaper.GetSelectedTrack(0,0)
       envelope =  reaper.GetFXEnvelope(track, 0, 18, 0)
       retval, name = reaper.GetEnvelopeName( envelope )
       
      if string.find(name, "Bypass") then 
       DeleteEnv(envelope, track) end

--end

--Main()
