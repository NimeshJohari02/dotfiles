local busy = false

function update()
    if busy then return end
    busy = true
    local started = noctalia.runAsync({"python3", noctalia.pluginDir() .. "/display-control.py", "status"}, function(result)
        busy = false
        local data = noctalia.json.decode(result.stdout)
        if result.exitCode ~= 0 or not data or data.error then
            barWidget.setText("Hz ?")
            barWidget.setTooltip("Refresh rate unavailable. Click to retry.")
            return
        end
        local display = data.displays[1]
        if display then
            barWidget.setText(string.format("%.0f Hz", display.rate / 1000))
            barWidget.setTooltip("Refresh rate · " .. display.name .. "\nClick to choose a supported rate")
        else
            barWidget.setText("Hz")
            barWidget.setTooltip("No active displays")
        end
    end)
    if not started then busy = false end
end

function onClick()
    noctalia.togglePanel("local/refresh-rate:panel")
end

barWidget.setGlyph("device-desktop")
barWidget.setText("Hz")
noctalia.setUpdateInterval(5000)
update()
