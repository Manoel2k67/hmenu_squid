-- HMenu bootstrap. Public entry point (kept under this name for compatibility):
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/Manoel2k67/hmenu_squid/main/KeySystem.lua", true))()

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local RELEASE_VERSION = "1.0.9"
local BUNDLE_PATH = "dist/HMenu.bundle.lua"
local MAX_DOWNLOAD_ATTEMPTS = 4
local RETRY_BASE_DELAY = 0.75
local REPOSITORIES = {
    "https://raw.githubusercontent.com/Manoel2k67/hmenu_squid/main/",
    "https://cdn.jsdelivr.net/gh/Manoel2k67/hmenu_squid@main/",
}

if type(_G.__HMENU_CLEANUP) == "function" then
    pcall(_G.__HMENU_CLEANUP)
end
if type(_G.__HMENU_KEY_CLEANUP) == "function" then
    pcall(_G.__HMENU_KEY_CLEANUP)
    _G.__HMENU_KEY_CLEANUP = nil
end

local function resolveGuiParent()
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then return result end
    end

    local coreGuiOk = pcall(function() return CoreGui.Name end)
    return coreGuiOk and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
end

local function validatePayload(source)
    if type(source) ~= "string" or source == "" then
        return nil, "resposta vazia"
    end

    if string.sub(source, 1, 3) == "\239\187\191" then
        source = string.sub(source, 4)
    end

    local prefix = string.lower(string.sub(source, 1, 512))
    local firstCharacter = string.match(source, "^%s*(.)")
    if firstCharacter == "<" or string.find(prefix, "<!doctype", 1, true)
        or string.find(prefix, "<html", 1, true) then
        return nil, "servidor retornou HTML em vez de Lua"
    end

    return source
end

local function downloadBundle()
    if type(loadstring) ~= "function" then
        error("este executor nao disponibiliza loadstring", 0)
    end

    local lastError = "falha de rede desconhecida"
    for attempt = 1, MAX_DOWNLOAD_ATTEMPTS do
        for _, repository in ipairs(REPOSITORIES) do
            local url = repository .. BUNDLE_PATH .. "?v=" .. RELEASE_VERSION
            local requestOk, response = pcall(function()
                return game:HttpGet(url, true)
            end)

            if requestOk then
                local source, payloadError = validatePayload(response)
                if source then
                    local chunk, compileError = loadstring(source, "@HMenu/" .. BUNDLE_PATH)
                    if chunk then
                        local bundleOk, bundle = pcall(chunk)
                        if bundleOk and type(bundle) == "table"
                            and bundle.Version == RELEASE_VERSION
                            and type(bundle.Create) == "function" then
                            return bundle
                        end
                        lastError = "bundle desatualizado ou invalido"
                    else
                        lastError = "bundle invalido: " .. tostring(compileError)
                    end
                else
                    lastError = payloadError
                end
            else
                lastError = tostring(response)
            end
        end

        if attempt < MAX_DOWNLOAD_ATTEMPTS then
            task.wait(RETRY_BASE_DELAY * (2 ^ (attempt - 1)))
        end
    end

    error("nao foi possivel baixar o HMenu: " .. lastError, 0)
end

_G.__HMENU_RELEASE_VERSION = RELEASE_VERSION

local bundle = downloadBundle()
local result = bundle:Create({
    Parent = resolveGuiParent(),
    AssetBaseUrls = REPOSITORIES,
    AssetVersion = RELEASE_VERSION,
})

print("[HMenu] v1.0 aberto sem validacao de acesso.")
return result
