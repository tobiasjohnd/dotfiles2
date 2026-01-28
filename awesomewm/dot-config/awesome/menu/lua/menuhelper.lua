#!/usr/bin/env lua

local Menu_helper = {}

-- menu bash command
function Menu_helper.Menu(menu_options, multiselect)
    multiselect = multiselect or false
    local selected_items = {}
    local menu_options_string = table.concat(menu_options, "\n")
    local result = io.popen("echo '"..menu_options_string.."' | tofi")
    if result then
        repeat
            local item = result:read("*l")
            if item and item ~= "" then
                table.insert(selected_items, item)
            end
        until not item or item == "" or not multiselect
        result:close()
    end
    return selected_items or {}
end
return Menu_helper
