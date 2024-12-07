#!/usr/bin/env lua

-- menu bash command
function Menu(options)
    local selected = io.popen("echo '"..options.."' | tofi")
    return selected:read("*l")
end

-- Function to get all files in a directory matching a pattern
local function scan_dir(directory, pattern)
    local files = {}
    local p = io.popen('find "'..directory..'" -type f -name "'..pattern..'"')
    for file in p:lines() do
        table.insert(files, file)
    end
    p:close()
    return files
end

-- Function to parse a .desktop file and extract Name and NoDisplay
local function parse_desktop_file(filepath)
    local file = io.open(filepath, "r")
    if not file then return nil end

    local name, hidden

    for line in file:lines() do
        -- Extract Name if not already found
        Name_match = line:match("^Name=(.+)")
        NoDisplay_match = line:match("^NoDisplay=(.+)")
        Hidden_match = line:match("^Hidden=(.+)")
        OnlyShowIn_match = line:match("^OnlyShowIn=(.+)")

        if not name and Name_match then
            name = Name_match
        end

        if not hidden and NoDisplay_match then
            hidden = "true" == NoDisplay_match:lower()
        end

        if not hidden and Hidden_match then
            hidden = "true" == Hidden_match:lower()
        end

        if not hidden and OnlyShowIn_match then
            hidden = "true"
        end
    end

    file:close()
    return name, hidden
end

-- Main function to get desktop entries
function Get_desktop_entries()
    -- Desktop entry directories
    local desktop_dirs = {
        "/usr/share/applications",
        "/usr/local/share/applications",
        os.getenv("HOME").."/.local/share/applications"
    }

    -- Table to store results (name -> path)
    local entries = {}

    -- Process each directory
    for _, dir in ipairs(desktop_dirs) do
        -- Check if directory exists
        local f = io.open(dir)
        if f then
            f:close()

            -- Get all .desktop files
            local files = scan_dir(dir, "*.desktop")

            -- Process each file
            for _, filepath in ipairs(files) do
                local new_entry = {}
                new_entry.filepath = filepath
                new_entry.name, new_entry.is_hidden = parse_desktop_file(filepath)

                -- Add to entries if visible
                -- check if the file is already int the list
                local found = false
                for i, entry in ipairs(entries) do
                    if entry.name == new_entry.name then
                        found = true
                        new_entry.is_hidden = new_entry.is_hidden or entry.is_hidden
                        entries[i] = new_entry
                    end
                end


                if new_entry.name and not found then
                    table.insert(entries, new_entry)
                end
            end
        end
    end

    return entries
end
