local Schema = {}

local VALID_CONTROL_KINDS = {
    Toggle = true,
    Slider = true,
    Dropdown = true,
    Button = true,
    Paragraph = true,
}

local REQUIRED_THEME_KEYS = {
    "Window", "WindowHighlight", "WindowDark", "Sidebar", "Header",
    "Surface", "SurfaceHover", "Control", "Accent", "Bookmark",
    "Text", "Muted", "Dim", "Border", "Success", "Danger",
}

local function requireNonEmptyString(value, context)
    if type(value) ~= "string" or value:match("^%s*$") then
        error(context .. " deve ser uma string não vazia", 0)
    end
end

function Schema.ValidateConfig(config)
    if type(config) ~= "table" then error("HMenuConfig.lua deve retornar uma tabela", 0) end
    requireNonEmptyString(config.GuiName, "Config.GuiName")
    requireNonEmptyString(config.Version, "Config.Version")
    requireNonEmptyString(config.DefaultCategory, "Config.DefaultCategory")
    if config.ToggleKey == nil then error("Config.ToggleKey não pode ser nil", 0) end
    if type(config.Theme) ~= "table" then error("Config.Theme deve ser uma tabela", 0) end
    for _, key in ipairs(REQUIRED_THEME_KEYS) do
        if config.Theme[key] == nil then
            error("Config.Theme não possui a cor obrigatória " .. key, 0)
        end
    end
    if type(config.Icons) ~= "table" then error("Config.Icons deve ser uma tabela", 0) end
    if type(config.Window) ~= "table" or type(config.Window.Width) ~= "number"
        or type(config.Window.Height) ~= "number" then
        error("Config.Window deve informar Width e Height numéricos", 0)
    end
    if config.Window.Width <= 0 or config.Window.Height <= 0
        or type(config.Window.MinScale) ~= "number" or config.Window.MinScale <= 0
        or type(config.Window.Margin) ~= "number" or config.Window.Margin < 0 then
        error("Config.Window possui dimensões, MinScale ou Margin inválidos", 0)
    end
    if type(config.CategoryModules) ~= "table" or #config.CategoryModules == 0 then
        error("Config.CategoryModules não pode estar vazio", 0)
    end
end

function Schema.ValidateCategory(category, path, categoryIds, controlIds)
    if type(category) ~= "table" then
        error(path .. " deve retornar uma tabela", 0)
    end
    requireNonEmptyString(category.Id, path .. ".Id")
    requireNonEmptyString(category.Label, path .. ".Label")
    requireNonEmptyString(category.Icon, path .. ".Icon")
    if categoryIds[category.Id] then
        error("Id de categoria duplicado '" .. category.Id .. "' em " .. path, 0)
    end
    categoryIds[category.Id] = path

    if category.RuntimeModule ~= nil then
        requireNonEmptyString(category.RuntimeModule, path .. ".RuntimeModule")
    end
    if type(category.Sections) ~= "table" or #category.Sections == 0 then
        error(path .. ".Sections deve conter ao menos uma seção", 0)
    end

    for sectionIndex, section in ipairs(category.Sections) do
        local sectionContext = path .. ".Sections[" .. tostring(sectionIndex) .. "]"
        if type(section) ~= "table" then error(sectionContext .. " deve ser uma tabela", 0) end
        requireNonEmptyString(section.Title, sectionContext .. ".Title")
        if section.Icon ~= nil then requireNonEmptyString(section.Icon, sectionContext .. ".Icon") end
        if type(section.Controls) ~= "table" then
            error(sectionContext .. ".Controls deve ser uma tabela", 0)
        end

        for controlIndex, control in ipairs(section.Controls) do
            local context = sectionContext .. ".Controls[" .. tostring(controlIndex) .. "]"
            if type(control) ~= "table" then error(context .. " deve ser uma tabela", 0) end
            if not VALID_CONTROL_KINDS[control.Kind] then
                error(context .. " possui Kind inválido: " .. tostring(control.Kind), 0)
            end
            requireNonEmptyString(control.Label, context .. ".Label")
            if control.Description ~= nil and type(control.Description) ~= "string" then
                error(context .. ".Description deve ser uma string", 0)
            end
            if control.Callback ~= nil and type(control.Callback) ~= "function" then
                error(context .. ".Callback deve ser uma função", 0)
            end

            if control.Kind ~= "Paragraph" then
                requireNonEmptyString(control.Id, context .. ".Id")
                if controlIds[control.Id] then
                    error("Id de controle duplicado '" .. control.Id .. "' em " .. context, 0)
                end
                controlIds[control.Id] = context
            end
            if control.Setting ~= nil then
                requireNonEmptyString(control.Setting, context .. ".Setting")
                if not category.RuntimeModule then
                    error(context .. " possui Setting, mas a categoria não possui RuntimeModule", 0)
                end
            end
            if control.OptionsSource ~= nil then
                requireNonEmptyString(control.OptionsSource, context .. ".OptionsSource")
                if not category.RuntimeModule then
                    error(context .. " possui OptionsSource, mas a categoria não possui RuntimeModule", 0)
                end
            end

            if control.Kind == "Slider" then
                if type(control.Min) ~= "number" or type(control.Max) ~= "number" or control.Max <= control.Min then
                    error(context .. " precisa de Min e Max numéricos, com Max maior que Min", 0)
                end
                if control.Step ~= nil and (type(control.Step) ~= "number" or control.Step <= 0) then
                    error(context .. ".Step deve ser um número positivo", 0)
                end
                if control.Default ~= nil and (type(control.Default) ~= "number"
                    or control.Default < control.Min or control.Default > control.Max) then
                    error(context .. ".Default deve estar entre Min e Max", 0)
                end
            elseif control.Kind == "Dropdown" then
                local optionsType = type(control.Options)
                if optionsType ~= "table" and optionsType ~= "function"
                    and type(control.OptionsSource) ~= "string" then
                    error(context .. " precisa de Options ou OptionsSource", 0)
                end
                if optionsType == "table" and #control.Options == 0 then
                    error(context .. ".Options não pode estar vazio", 0)
                end
                if optionsType == "table" and control.Default ~= nil then
                    local defaultExists = false
                    for _, option in ipairs(control.Options) do
                        if option == control.Default then defaultExists = true break end
                    end
                    if not defaultExists then
                        error(context .. ".Default não existe em Options", 0)
                    end
                end
            elseif control.Kind == "Toggle" and control.Default ~= nil
                and type(control.Default) ~= "boolean" then
                error(context .. ".Default deve ser booleano", 0)
            elseif control.Kind == "Button" and control.ButtonText ~= nil
                and type(control.ButtonText) ~= "string" then
                error(context .. ".ButtonText deve ser uma string", 0)
            end
        end
    end
end

function Schema.RequireModulePath(path, context)
    requireNonEmptyString(path, context or "caminho do módulo")
end

return Schema
