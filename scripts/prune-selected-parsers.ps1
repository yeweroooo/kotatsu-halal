Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$allowedSources = @(
    "AINZSCANS",
    "APKOMIK",
    "IKIRU",
    "KIRYUU",
    "KOMIKCAST",
    "MANGADEX",
    "SHINIGAMI",
    "SOULSCANS",
    "WESTMANGA"
)

$siteRoot = Join-Path $PSScriptRoot "..\src\main\kotlin\org\koitharu\kotatsu\parsers\site"
$siteRoot = (Resolve-Path $siteRoot).Path
$annotationPattern = '@MangaSourceParser\("(?<name>[A-Z0-9_]+)"'
$importPattern = '^\s*import\s+(?<path>org\.koitharu\.kotatsu\.parsers\.site\.[A-Za-z0-9_.]+)'

$siteFiles = Get-ChildItem -Path $siteRoot -Recurse -Filter *.kt -File
$keepPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$queue = [System.Collections.Generic.Queue[string]]::new()

foreach ($file in $siteFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $match = [regex]::Match($content, $annotationPattern)
    if (-not $match.Success) {
        continue
    }

    $sourceName = $match.Groups["name"].Value
    if ($allowedSources -notcontains $sourceName) {
        continue
    }

    $normalizedPath = [System.IO.Path]::GetFullPath($file.FullName)
    $keepPaths.Add($normalizedPath) | Out-Null
    $queue.Enqueue($normalizedPath)
}

while ($queue.Count -gt 0) {
    $currentFile = $queue.Dequeue()
    $content = Get-Content -Path $currentFile -Raw
    $matches = [regex]::Matches($content, $importPattern, [System.Text.RegularExpressions.RegexOptions]::Multiline)

    foreach ($importMatch in $matches) {
        $relativeImportPath = (
            $importMatch.Groups["path"].Value
        ).Replace("org.koitharu.kotatsu.parsers.site.", "").Replace('.', '\')
        $candidate = Join-Path $siteRoot ($relativeImportPath + ".kt")
        if (-not (Test-Path $candidate)) {
            continue
        }

        $normalizedCandidate = [System.IO.Path]::GetFullPath($candidate)
        if ($keepPaths.Add($normalizedCandidate)) {
            $queue.Enqueue($normalizedCandidate)
        }
    }
}

$removed = 0

foreach ($file in $siteFiles) {
    $normalizedPath = [System.IO.Path]::GetFullPath($file.FullName)
    if ($keepPaths.Contains($normalizedPath)) {
        continue
    }

    Remove-Item -Path $file.FullName -Force
    $removed++
}

Get-ChildItem -Path $siteRoot -Recurse -Directory |
    Sort-Object FullName -Descending |
    ForEach-Object {
        if (-not (Get-ChildItem -Path $_.FullName -Force | Select-Object -First 1)) {
            Remove-Item -Path $_.FullName -Force
        }
    }

Write-Host "Removed $removed site files."
