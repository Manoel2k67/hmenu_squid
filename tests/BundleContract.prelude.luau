local services = {
    Lighting = { Brightness = 3 },
}

game = {}
function game:GetService(name)
    services[name] = services[name] or {}
    return services[name]
end

Color3 = {}
function Color3.fromRGB(red, green, blue)
    return { R = red / 255, G = green / 255, B = blue / 255 }
end

Enum = {
    KeyCode = {
        RightShift = "RightShift",
    },
}
