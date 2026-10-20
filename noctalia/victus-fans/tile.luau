local busy = false

local function run(action)
    if busy then return end
    busy = true
    shortcut.setEnabled(false)
    local path = noctalia.pluginDir() .. "/fan-control.py"
    local quoted = "'" .. path:gsub("'", "'\\''") .. "'"
    local started = noctalia.runAsync("python3 " .. quoted .. " " .. action, function(result)
        busy = false
        local mode = result.stdout:match("^%s*(%u[%u_]*)%s*$")
        if result.exitCode == 0 and mode then
            shortcut.setLabel(mode == "AUTO" and "Fans Auto" or mode == "MAX" and "Fans Max" or "Fans " .. mode)
            shortcut.setActive(mode == "MAX")
        else
            shortcut.setLabel("Fans Offline")
            shortcut.setActive(false)
            if action == "toggle" then
                noctalia.notifyError("Victus fan control failed", result.stderr)
            end
        end
        shortcut.setEnabled(true)
    end, 8000)
    if not started then
        busy = false
        shortcut.setEnabled(true)
        shortcut.setLabel("Fans Offline")
    end
end

function update()
    run("status")
end

function onClick()
    run("toggle")
end

shortcut.setIcon("propeller")
shortcut.setLabel("Victus Fans")
shortcut.setActive(false)
noctalia.setUpdateInterval(3000)
run("status")
