local Misc = {}

function Misc:Create()
    local runtime = {}
    local destroyed = false

    function runtime:Set(name, value)
        if destroyed then return end
        if name == "MenuTheme" and type(_G.__HMENU_SET_THEME) == "function" then
            _G.__HMENU_SET_THEME(tostring(value or "Default"))
        end
    end

    function runtime:Destroy()
        destroyed = true
    end

    return runtime
end

return Misc
