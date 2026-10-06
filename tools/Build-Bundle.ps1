[CmdletBinding()]
param(
    [switch]$Check
)

$ErrorActionPreference = "Stop"
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$outputPath = Join-Path $repoRoot "dist\HMenu.bundle.lua"
$versionPath = Join-Path $repoRoot "VERSION"
$strictUtf8 = New-Object Text.UTF8Encoding($false, $true)
$utf8NoBom = New-Object Text.UTF8Encoding($false)

function Read-Utf8File([string]$relativePath) {
    $absolutePath = Join-Path $repoRoot $relativePath
    if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
        throw "Arquivo obrigatorio nao encontrado: $relativePath"
    }
    return $strictUtf8.GetString([IO.File]::ReadAllBytes($absolutePath))
}

$releaseVersion = (Read-Utf8File "VERSION").Trim()
if ($releaseVersion -notmatch '^\d+\.\d+\.\d+$') {
    throw "VERSION deve conter somente uma versao semantica no formato X.Y.Z."
}

$configSource = Read-Utf8File "HMenuConfig.lua"
$keySystemSource = Read-Utf8File "KeySystem.lua"
$readmeSource = Read-Utf8File "README.md"
if ([regex]::Matches($readmeSource, 'KeySystem\.lua').Count -lt 2) {
    throw "O bootstrap do README deve conter as duas fontes."
}
$loaderVersionMatch = [regex]::Match($keySystemSource, 'local RELEASE_VERSION = "(\d+\.\d+\.\d+)"')
if (-not $loaderVersionMatch.Success -or $loaderVersionMatch.Groups[1].Value -ne $releaseVersion) {
    throw "RELEASE_VERSION em KeySystem.lua deve ser igual ao arquivo VERSION ($releaseVersion)."
}

$modulePaths = New-Object Collections.Generic.List[string]
$modulePaths.Add("HMenuConfig.lua")
$modulePaths.Add("HMenuSchema.lua")
$modulePaths.Add("HMenu.lua")
foreach ($folder in @("categories", "runtime")) {
    Get-ChildItem -LiteralPath (Join-Path $repoRoot $folder) -Filter "*.lua" -File |
        Sort-Object Name |
        ForEach-Object {
            $relativePath = $_.FullName.Substring($repoRoot.Length).TrimStart('\', '/')
            $modulePaths.Add($relativePath.Replace('\', '/'))
        }
}

$builder = New-Object Text.StringBuilder
function Add-Line([string]$line = "") {
    [void]$builder.Append($line).Append("`n")
}

Add-Line "-- AUTO-GENERATED FILE. DO NOT EDIT DIRECTLY."
Add-Line "-- Run tools/Build-Bundle.ps1 after changing a source module."
Add-Line "-- Release is read from VERSION at runtime."
Add-Line
Add-Line "local __modules = {}"
Add-Line

foreach ($modulePath in $modulePaths) {
    $source = (Read-Utf8File $modulePath).Replace("`r`n", "`n").Replace("`r", "`n").TrimEnd("`n")
    Add-Line "-- BEGIN $modulePath"
    Add-Line "__modules[`"$modulePath`"] = function()"
    [void]$builder.Append($source).Append("`n")
    Add-Line "end"
    Add-Line "-- END $modulePath"
    Add-Line
}

Add-Line "local Bundle = {"
Add-Line "    Version = tostring(rawget(_G, `"__HMENU_RELEASE_VERSION`") or `"unknown`"),"
Add-Line "    ModuleCount = $($modulePaths.Count),"
Add-Line "}"
Add-Line
Add-Line "local function createImporter()"
Add-Line "    local cache = {}"
Add-Line "    local loaded = {}"
Add-Line "    local loading = {}"
Add-Line
Add-Line "    return function(path)"
Add-Line "        if loaded[path] then return cache[path] end"
Add-Line "        local factory = __modules[path]"
Add-Line "        if type(factory) ~= `"function`" then"
Add-Line "            error(`"Modulo nao incluido no bundle: `" .. tostring(path), 0)"
Add-Line "        end"
Add-Line "        if loading[path] then"
Add-Line "            error(`"Dependencia circular ao importar: `" .. tostring(path), 0)"
Add-Line "        end"
Add-Line
Add-Line "        loading[path] = true"
Add-Line "        local ok, result = pcall(factory)"
Add-Line "        loading[path] = nil"
Add-Line "        if not ok then"
Add-Line "            error(`"Falha no modulo `" .. tostring(path) .. `": `" .. tostring(result), 0)"
Add-Line "        end"
Add-Line "        if result == nil then"
Add-Line "            error(`"O modulo `" .. tostring(path) .. `" nao retornou um valor`", 0)"
Add-Line "        end"
Add-Line
Add-Line "        cache[path] = result"
Add-Line "        loaded[path] = true"
Add-Line "        return result"
Add-Line "    end"
Add-Line "end"
Add-Line
Add-Line "function Bundle:Validate()"
Add-Line "    local import = createImporter()"
Add-Line "    local schema = import(`"HMenuSchema.lua`")"
Add-Line "    local config = import(`"HMenuConfig.lua`")"
Add-Line "    schema.ValidateConfig(config)"
Add-Line "    local categoryIds = {}"
Add-Line "    local controlIds = {}"
Add-Line "    local runtimePaths = {}"
Add-Line "    for _, path in ipairs(config.CategoryModules) do"
Add-Line "        schema.RequireModulePath(path, `"Config.CategoryModules[]`")"
Add-Line "        local category = import(path)"
Add-Line "        schema.ValidateCategory(category, path, categoryIds, controlIds)"
Add-Line "        if category.RuntimeModule then runtimePaths[category.RuntimeModule] = true end"
Add-Line "    end"
Add-Line "    if not categoryIds[config.DefaultCategory] then"
Add-Line "        error(`"DefaultCategory nao esta registrada: `" .. tostring(config.DefaultCategory), 0)"
Add-Line "    end"
Add-Line "    local runtimeCount = 0"
Add-Line "    for path in pairs(runtimePaths) do"
Add-Line "        local runtimeModule = import(path)"
Add-Line "        if type(runtimeModule) ~= `"table`" or type(runtimeModule.Create) ~= `"function`" then"
Add-Line "            error(path .. `" deve expor Create`", 0)"
Add-Line "        end"
Add-Line "        runtimeCount = runtimeCount + 1"
Add-Line "    end"
Add-Line "    local controlCount = 0"
Add-Line "    for _ in pairs(controlIds) do controlCount = controlCount + 1 end"
Add-Line "    return { Categories = #config.CategoryModules, Controls = controlCount, Runtimes = runtimeCount }"
Add-Line "end"
Add-Line
Add-Line "function Bundle:Create(options)"
Add-Line "    options = options or {}"
Add-Line "    local resolvedOptions = {}"
Add-Line "    for key, value in pairs(options) do resolvedOptions[key] = value end"
Add-Line "    resolvedOptions.Import = createImporter()"
Add-Line "    local menu = resolvedOptions.Import(`"HMenu.lua`")"
Add-Line "    if type(menu) ~= `"table`" or type(menu.Create) ~= `"function`" then"
Add-Line "        error(`"HMenu.lua nao expoe uma funcao Create`", 0)"
Add-Line "    end"
Add-Line "    return menu:Create(resolvedOptions)"
Add-Line "end"
Add-Line
Add-Line "return Bundle"

$generated = $builder.ToString()
if ($Check) {
    if (-not (Test-Path -LiteralPath $outputPath -PathType Leaf)) {
        throw "Bundle ausente. Execute tools/Build-Bundle.ps1."
    }
    $current = $strictUtf8.GetString([IO.File]::ReadAllBytes($outputPath)).Replace("`r`n", "`n").Replace("`r", "`n")
    if ($current -cne $generated) {
        throw "Bundle desatualizado. Execute tools/Build-Bundle.ps1 e versione o resultado."
    }
    Write-Host "Bundle atualizado: dist/HMenu.bundle.lua ($($modulePaths.Count) modulos, v$releaseVersion)."
    return
}

$outputDirectory = Split-Path -Parent $outputPath
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory | Out-Null
}
[IO.File]::WriteAllText($outputPath, $generated, $utf8NoBom)
Write-Host "Bundle gerado: dist/HMenu.bundle.lua ($($modulePaths.Count) modulos, v$releaseVersion)."
