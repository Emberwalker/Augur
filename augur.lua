--[[
    Augur
    Stat-tracking for dummies.

    ----------------------------------------------------------------------------------------------------------------

    This code is distributed under the terms of the ISC License:
    
    Copyright 2018 Arkan Emberwalker <arkan@drakon.io>

    Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby
    granted, provided that the above copyright notice and this permission notice appear in all copies.

    THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL
    IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
    INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER
    IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
    PERFORMANCE OF THIS SOFTWARE.
]]

local augurName, augurShared = ...

SLASH_AUGURMAIN1 = '/augur'
function SlashCmdList.AUGURMAIN(msg, editBox)
    local command, rest = msg:match("^%s*(%w+)(.*)$")
    local command = string.lower(command)

    if command == "version" then
        print("Augur v" .. GetAddOnMetadata(augurName, "Version"))
        print("Using ADP v" .. AugurDataProtocol._version .. " (branch: " .. AugurDataProtocol._provider .. "/" ..
              AugurDataProtocol._author .. ")")
        print("Powered by json.lua v" .. augurShared._json._version)
    elseif command == "debug" then
        local fn, err = loadstring(msg, "AugurDebug")
        if not fn then
            print("Failed to load fn: " .. err)
        else
            local res, err = pcall(fn, augurShared)
            if err then
                print("Error in evaluation: " .. err)
            end
        end
    end
end

-- Init.
augurShared.ADPContext = AugurDataProtocol.GetNewContext("augur")
