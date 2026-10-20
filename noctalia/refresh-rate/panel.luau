local displays = {}
local message = "Loading displays…"
local busy = false
local opened = false
local render

local function request(args)
    if busy then return end
    busy = true
    render()
    local argv = {"python3", noctalia.pluginDir() .. "/display-control.py"}
    for _, value in ipairs(args) do table.insert(argv, value) end
    local started = noctalia.runAsync(argv, function(result)
        busy = false
        local data = noctalia.json.decode(result.stdout)
        if result.exitCode == 0 and data and data.displays then
            displays = data.displays
            message = #displays == 0 and "No active displays." or ""
        else
            message = data and data.error or "Could not read the display settings. Try Refresh."
        end
        if opened then render() end
    end)
    if not started then
        busy = false
        message = "Could not start the display helper."
        render()
    end
end

render = function()
    local cards = {}
    for _, display in ipairs(displays) do
        local buttons = {}
        for _, rate in ipairs(display.rates) do
            local selected = rate == display.rate
            table.insert(buttons, ui.button({
                key = tostring(rate),
                text = string.format("%.3f Hz", rate / 1000) .. (selected and "  ✓" or ""),
                variant = selected and "primary" or "outline",
                enabled = not busy and not selected,
                onClick = function()
                    message = ""
                    request({"set", display.name, tostring(rate)})
                end,
            }))
        end
        table.insert(cards, ui.column({key = display.name, gap = 10, padding = 12, fill = "surface_variant/0.6", radius = 12}, {
            ui.label({text = display.label .. " · " .. display.name, fontWeight = "bold"}),
            ui.label({text = tostring(display.width) .. " × " .. tostring(display.height), color = "on_surface_variant"}),
            ui.column({gap = 6}, buttons),
        }))
    end
    panel.render(ui.column({gap = 12, padding = 16, flexGrow = 1}, {
        ui.row({align = "center", gap = 8}, {
            ui.glyph({name = "device-desktop", size = 20}),
            ui.label({text = "Refresh rate", fontSize = 18, fontWeight = "bold", flexGrow = 1}),
            ui.button({glyph = "refresh", tooltip = "Refresh displays", enabled = not busy, onClick = function() request({"status"}) end}),
            ui.button({glyph = "x", tooltip = "Close", onClick = function() panel.close() end}),
        }),
        ui.label({text = "Choose a rate. Resolution stays the same.", color = "on_surface_variant"}),
        ui.scroll({flexGrow = 1, gap = 12}, cards),
        ui.label({text = busy and "Reading display settings…" or message, visible = busy or message ~= "", color = "on_surface_variant", maxLines = 3}),
    }))
end

function onOpen()
    opened = true
    request({"status"})
end

function onClose()
    opened = false
end

function update()
    if opened then request({"status"}) end
end

noctalia.setUpdateInterval(5000)
