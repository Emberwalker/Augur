--[[
    Augur Data Protocol
    Basic comms suite for Augur data.

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

    ----------------------------------------------------------------------------------------------------------------

    The Augur Data Protocol suite supports message type IDs (1-250), message chunking, and can serialise anything
    that the underlying json.lua library can, *except null bytes* as these confuse WoWs addon comms system. IDs 251-255
    are reserved for ADP usage (for future work).

    All ADP functions take a 'context'table, which ADP uses to store partially-received messages and metadata. First,
    get a new context. The addon prefix must be 15 characters or less, else it'll report an error. By default, ADP will
    register your prefix and attach to it - passing false to setupListeners will disable this behaviour.

        ctx, err = AugurDataProtocol.GetNewContext(addonPrefixString[, setupListeners])

    If you choose not to let ADP handle your listener set up, you can pass raw message events from the wire to ADP
    manually in your own listeners. You are responsable for registering your chosen prefix.

        AugurDataProtocol.HandleRawMessage(ctx, ...)

    Next, register any necessary listeners. This method can be called multiple times to attach additional listeners.
    The listener function can accept the following parameters: typeID, message, source, distributionType.
    The source is the sending player name, type is the 2-250 ID, message is the deserialized JSON object and
    distribution type is the type of CHAT_MSG_ADDON (PARTY, RAID, GUILD, BATTLEGROUND or WHISPER).

        AugurDataProtocol.AttachListener(ctx, handlerFn)

    To send a message, use one of the dispatch methods. Message can be any object serializable by json.lua. For
    broadcast messages, specify a WoW SendAddonMessage type: PARTY, RAID, GUILD or BATTLEGROUND.

        ok, err = AugurDataProtocol.DispatchWhisper(ctx, target, message)
        ok, err = AugurDataProtocol.DispatchBroadcast(ctx, type, message)

    Lastly, to print diagnostic output to the chat log, enable debug on the context (this may be very verbose!)

        AugurDataProtocol.EnableDebug(ctx)
]]

-- Pull providing addons name and data table from the providing addon.
local providerName, addonTable = ...

-- Current version of ADP specified by this file.
local ADP_VERSION = 1
local MAX_BYTE = 255
local MAX_TWOBYTE = 65535
local MSG_MAXLEN = 250

if AugurDataProtocol and AugurDataProtocol.VERSION >= ADP_VERSION then return end

if not AugurDataProtocol then
    AugurDataProtocol = {
        _author = "Arkan",
        _provider = providerName,
        _version = ADP_VERSION,
    }
end

local function ADPInternalListener(ctx, type, msg, src, distType)
    -- Unused (for now)
    if ctx.Debug then
        print("ADPMSG: " .. ctx.Prefix .. "/" .. type .. "/" .. src .. "/" .. distType .. ": " .. msg)
    end
end

local function ADPInternalEventHandler(ctx, event, ...)
    -- Check this is actually a CHAT_MSG_ADDON event.
    if event ~= "CHAT_MSG_ADDON" then return end
    AugurDataProtocol.HandleRawMessage(ctx, ...)
end

function AugurDataProtocol.GetNewContext(addonPrefix, setupListeners)
    if #addonPrefix > 15 then
        return nil, "Addon prefix too long"
    end

    local ctx = {
        WorkQueues = {},
        Prefix = addonPrefix,
        Listeners = {},
        Debug = false,
    }

    -- Attach internal listener with context
    local function intListener(type, msg, src, distType) ADPInternalListener(ctx, type, msg, src, distType) end
    table.insert(ctx.Listeners, intListener)

    if setupListeners == nil or setupListeners then
        -- Attach event handlers to the Blizzard event system
        local ok = RegisterAddonMessagePrefix(addonPrefix)
        if not ok then return nil, "RegisterAddonMessagePrefix failed for prefix " .. addonPrefix end
        local frame = CreateFrame("FRAME", addonPrefix .. "ADPEventFrame")
        frame:RegisterEvent("CHAT_MSG_ADDON")
        local function evtHandler(self, event, ...) ADPInternalEventHandler(ctx, event, ...) end
        frame:SetScript("OnEvent", evtHandler)
    end

    return ctx, nil
end

function AugurDataProtocol.HandleRawMessage(ctx, prefix, msg, distType, sender)

end

function AugurDataProtocol.AttachListener(ctx, handlerFn)
    table.insert(ctx.Listeners, handlerFn)
end

function AugurDataProtocol.DispatchWhisper(ctx, target, message)
    -- TODO
end

function AugurDataProtocol.DispatchBroadcast(ctx, type, message)
    -- TODO
end

function AugurDataProtocol.EnableDebug(ctx)
    ctx.Debug = true
end
