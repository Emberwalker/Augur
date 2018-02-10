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
    elseif command == "dev" then
        local player = GetUnitName("target", true)
        --[[local msg = string.char(1, 88, 45, 1, 2) .. "{\"test\":"
        local msg2 = string.char(1, 88, 45, 2, 2) .. "\"test\"}"
        print(msg)
        print(msg2)
        AugurDataProtocol.HandleRawMessage(augurShared.ADPContext, "augur", msg, "PARTY", player)
        AugurDataProtocol.HandleRawMessage(augurShared.ADPContext, "augur", msg2, "PARTY", player)]]

        local msg = { message = "This is a short test message that should skip the chunker." }
        local err = AugurDataProtocol.DispatchWhisper(augurShared.ADPContext, player, 4, msg)
        if err then print("ADP Error: " .. err) end

        msg = {
            message = "This is a very long message intended to go over the WoW message length limit. Ducks quacks DO" ..
                " in fact echo. Water is wet. I'm running out of things to add now. The answer to Life, the Universe" ..
                " and Everything, is fourty-two. Okay, we can stop this nonsense now."
        }
        local err = AugurDataProtocol.DispatchWhisper(augurShared.ADPContext, player, 5, msg)
        if err then print("ADP Error: " .. err) end
    end
end

-- Init.
augurShared.ADPContext, err = AugurDataProtocol.GetNewContext("augur")
if err then
    print("Augur: ADP setup failed, Augur will not be able to communicate with other players!")
    print("Details: " .. err)
end

-- TODO: Remove me
AugurDataProtocol.EnableDebug(augurShared.ADPContext)
AugurContext = augurShared.ADPContext
AugurJson = augurShared._json
