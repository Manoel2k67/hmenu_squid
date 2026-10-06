[CmdletBinding()]
param(
    [string]$LuauCompiler
)

$ErrorActionPreference = "Stop"
$repoRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$strictUtf8 = New-Object Text.UTF8Encoding($false, $true)
$failures = New-Object Collections.Generic.List[string]

& (Join-Path $PSScriptRoot "Build-Bundle.ps1") -Check

$textFiles = Get-ChildItem -LiteralPath $repoRoot -Recurse -File |
    Where-Object { $_.Extension -in @(".lua", ".luau", ".md", ".ps1") -and $_.FullName -notmatch '[\\/]\.git[\\/]' }
foreach ($file in $textFiles) {
    $bytes = [IO.File]::ReadAllBytes($file.FullName)
    try {
        $content = $strictUtf8.GetString($bytes)
    } catch {
        $failures.Add("UTF-8 invalido: $($file.FullName)")
        continue
    }
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        $failures.Add("BOM UTF-8 nao permitido: $($file.FullName)")
    }
    $mojibakeMarkers = @(
        ([string][char]0x00C3 + [string][char]0x00A0),
        ([string][char]0x00C3 + [string][char]0x00A1),
        ([string][char]0x00C3 + [string][char]0x00A2),
        ([string][char]0x00C3 + [string][char]0x00A3),
        ([string][char]0x00C3 + [string][char]0x00A7),
        ([string][char]0x00C3 + [string][char]0x00A9),
        ([string][char]0x00C3 + [string][char]0x00AA),
        ([string][char]0x00C3 + [string][char]0x00AD),
        ([string][char]0x00C3 + [string][char]0x00B3),
        ([string][char]0x00C3 + [string][char]0x00B4),
        ([string][char]0x00C3 + [string][char]0x00B5),
        ([string][char]0x00C3 + [string][char]0x00BA),
        [string][char]0xFFFD
    )
    foreach ($marker in $mojibakeMarkers) {
        if ($content.Contains($marker)) {
            $failures.Add("Possivel texto corrompido por encoding: $($file.FullName)")
            break
        }
    }
}

$luaSource = ($textFiles | Where-Object { $_.Extension -in @(".lua", ".luau") } | ForEach-Object {
    $strictUtf8.GetString([IO.File]::ReadAllBytes($_.FullName))
}) -join "`n"
if ($luaSource -match 'HttpGet\([^\r\n]*os\.time\(') {
    $failures.Add("Cache-buster dinamico com os.time() encontrado em uma chamada HttpGet.")
}

foreach ($runtimeFile in $textFiles | Where-Object {
    $_.Extension -in @(".lua", ".luau") -and $_.FullName.StartsWith((Join-Path $repoRoot "runtime"))
}) {
    $runtimeSource = $strictUtf8.GetString([IO.File]::ReadAllBytes($runtimeFile.FullName))
    $relativePath = $runtimeFile.FullName.Substring($repoRoot.Length).TrimStart('\', '/')
    if ($runtimeSource -notmatch 'function\s+[A-Za-z_][A-Za-z0-9_]*:Create\s*\(') {
        $failures.Add("Runtime sem Create: $relativePath")
    }
    if ($runtimeSource -notmatch 'function\s+runtime:Set\s*\(') {
        $failures.Add("Runtime sem Set: $relativePath")
    }
    if ($runtimeSource -notmatch 'function\s+runtime:Destroy\s*\(') {
        $failures.Add("Runtime sem Destroy: $relativePath")
    }
    if ($runtimeSource -notmatch '(?m)^return\s+[A-Za-z_][A-Za-z0-9_]*\s*$') {
        $failures.Add("Runtime sem retorno de modulo: $relativePath")
    }
}

foreach ($wallpaper in Get-ChildItem -LiteralPath (Join-Path $repoRoot "theme\wallpapers") -Filter "*.png" -File) {
    $bytes = [IO.File]::ReadAllBytes($wallpaper.FullName)
    $signature = @(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)
    if ($bytes.Length -lt 8) {
        $failures.Add("PNG vazio ou truncado: $($wallpaper.FullName)")
        continue
    }
    for ($index = 0; $index -lt $signature.Count; $index++) {
        if ($bytes[$index] -ne $signature[$index]) {
            $failures.Add("Assinatura PNG invalida: $($wallpaper.FullName)")
            break
        }
    }
}

if (-not $LuauCompiler) {
    $compilerCommand = Get-Command "luau-compile" -ErrorAction SilentlyContinue
    if ($compilerCommand) { $LuauCompiler = $compilerCommand.Source }
}
if ($LuauCompiler) {
    if (-not (Test-Path -LiteralPath $LuauCompiler -PathType Leaf)) {
        throw "Compilador Luau nao encontrado: $LuauCompiler"
    }
    foreach ($file in $textFiles | Where-Object { $_.Extension -in @(".lua", ".luau") }) {
        & $LuauCompiler --null --only-parse $file.FullName *> $null
        if ($LASTEXITCODE -ne 0) {
            $failures.Add("Erro de sintaxe Luau: $($file.FullName)")
        }
    }
    Write-Host "Sintaxe validada com $LuauCompiler."

    $luauRuntime = Join-Path (Split-Path -Parent $LuauCompiler) "luau.exe"
    if (Test-Path -LiteralPath $luauRuntime -PathType Leaf) {
        $preludePath = Join-Path $repoRoot "tests\BundleContract.prelude.luau"
        $bundlePath = Join-Path $repoRoot "dist\HMenu.bundle.lua"
        $prelude = $strictUtf8.GetString([IO.File]::ReadAllBytes($preludePath))
        $bundle = $strictUtf8.GetString([IO.File]::ReadAllBytes($bundlePath))
        $contractSource = $prelude + "`nlocal Bundle = (function()`n" + $bundle + "`nend)()`n" +
            "local result = Bundle:Validate()`n" +
            "print(string.format(`"Contract OK: %d categories, %d controls, %d runtimes`", result.Categories, result.Controls, result.Runtimes))`n"
        $contractPath = Join-Path ([IO.Path]::GetTempPath()) ("hmenu-contract-" + [guid]::NewGuid().ToString("N") + ".luau")
        $utf8NoBom = New-Object Text.UTF8Encoding($false)
        try {
            [IO.File]::WriteAllText($contractPath, $contractSource, $utf8NoBom)
            & $luauRuntime $contractPath
            if ($LASTEXITCODE -ne 0) {
                $failures.Add("Teste de contrato do bundle falhou.")
            }
        } finally {
            if (Test-Path -LiteralPath $contractPath) {
                Remove-Item -LiteralPath $contractPath -Force
            }
        }
    } else {
        Write-Warning "luau.exe nao encontrado ao lado do compilador; testes de contrato foram ignorados."
    }
} else {
    Write-Warning "luau-compile nao encontrado; a validacao de sintaxe foi ignorada."
}

if ($failures.Count -gt 0) {
    $message = "Validacao falhou:`n - " + ($failures -join "`n - ")
    throw $message
}

Write-Host "Projeto validado com sucesso."
