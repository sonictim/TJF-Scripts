function Msg (param)
  reaper.ShowConsoleMsg(tostring (param).."\n")
end

 vals = {}

function set_ext_state()
    
    local str = table.concat(vals, ",")
    --                  Section (script name)   Item name  Val.  Keep when Reaper is closed
    reaper.SetExtState("Andrew K GetUserInputs", "Values", str, true)
    
end

function get_ext_state()
   
    local str = reaper.GetExtState("Andrew K GetUserInputs", "Values")
    
    if str and str ~= "" then
        vals = mysplit(str, ",")
    end
    
end

function mysplit(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[#t+1] = str      
    end
    
    Msg(t[#t])
    
    return t
end


function MAIN()
    reaper.ClearConsole()
    
    -- Load the values
    get_ext_state()
    
    local val_str
    if #vals == 0 then
        val_str = "1,2,3"
    else
        --        Returns a contiguous table as a string using the second
        --        as a separator
        val_str = table.concat(vals, ",")
    end
    
    retval, retvals_csv = reaper.GetUserInputs( "Test", 3,"Field 1,Field 2,Field 3", val_str )
    
    -- Don't try to split the CSV if the user pressed Cancel
    if not retval then return end
    
    Msg(retvals_csv)
    
    vals = mysplit(retvals_csv,",")

    -- Store the values
    set_ext_state()

end


MAIN()

