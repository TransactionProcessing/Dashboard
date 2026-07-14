param(
    [string]$DataPath = (Join-Path $PSScriptRoot 'readme-data.json'),
    [string]$OutputPath = (Join-Path (Split-Path $PSScriptRoot -Parent) 'Readme.md')
)

function New-BadgeMarkdown {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Type,
        [Parameter(Mandatory = $true)]
        $Value
    )

    switch ($Type) {
        'LatestTag' {
            return "![LatestTag](https://img.shields.io/github/v/tag/$Value)"
        }
        'NightlyBuild' {
            return "[![Last Nightly Build Status Badge](https://github.com/$Value/workflows/Nightly%20Build/badge.svg)](https://github.com/$Value/actions?query=workflow%3A%22Nightly+Build%22)"
        }
        'CodeCoverage' {
            if ($Value -is [string]) {
                return $Value
            }

            return "[![codecov]($($Value.badgeUrl))]($($Value.linkUrl))"
        }
        'CodeQuality' {
            return "[![CodeFactor]($($Value.badgeUrl))]($($Value.linkUrl))"
        }
        'OpenPrs' {
            return "![PullRequests](https://img.shields.io/github/issues-pr/$Value)"
        }
        'Repository' {
            return "[![Repository](https://img.shields.io/badge/github-repo-green)]($Value)"
        }
        default {
            return $Value
        }
    }
}

function Get-RowCells {
    param(
        [Parameter(Mandatory = $true)]
        $Section,
        [Parameter(Mandatory = $true)]
        $Row
    )

    if ($Section.title -eq 'Mobile Applications') {
        return @(
            "**$($Row.name)**",
            $Row.platforms[0],
            $Row.platforms[1],
            $Row.platforms[2],
            $Row.platforms[3],
            (New-BadgeMarkdown -Type 'CodeCoverage' -Value $Row.codeCoverage),
            (New-BadgeMarkdown -Type 'CodeQuality' -Value $Row.codeQuality),
            (New-BadgeMarkdown -Type 'OpenPrs' -Value $Row.openPrsRepo),
            (New-BadgeMarkdown -Type 'Repository' -Value $Row.repositoryUrl)
        )
    }

    return @(
        "**$($Row.name)**",
        (New-BadgeMarkdown -Type 'LatestTag' -Value $Row.tagRepo),
        $(if ($Row.nightlyRepo) { New-BadgeMarkdown -Type 'NightlyBuild' -Value $Row.nightlyRepo } else { 'N/A' }),
        $(if ($Row.codeCoverage) { New-BadgeMarkdown -Type 'CodeCoverage' -Value $Row.codeCoverage } else { 'N/A' }),
        (New-BadgeMarkdown -Type 'CodeQuality' -Value $Row.codeQuality),
        (New-BadgeMarkdown -Type 'OpenPrs' -Value $Row.tagRepo),
        (New-BadgeMarkdown -Type 'Repository' -Value $Row.repositoryUrl)
    )
}

$data = Get-Content -Raw $DataPath | ConvertFrom-Json

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("# $($data.title)")
$lines.Add("")
$lines.Add($data.description)
$lines.Add("")
$lines.Add("## What This Shows")
$lines.Add("")
foreach ($item in $data.legend) {
    $lines.Add("- " + '`' + $item.label + '`' + " - " + $item.description)
}
$lines.Add("")
$lines.Add("## Contents")
$lines.Add("")
foreach ($section in $data.sections) {
    $anchor = ($section.title.ToLowerInvariant() -replace '[^a-z0-9]+', '-').Trim('-')
    $lines.Add("- [$($section.title)](#$anchor)")
}

foreach ($section in $data.sections) {
    $lines.Add("")
    $lines.Add("## $($section.title)")
    $lines.Add("")
    $lines.Add("| $($section.columns -join ' | ') |")
    $lines.Add("| " + (($section.columns | ForEach-Object { '---' }) -join ' | ') + " |")

    foreach ($row in $section.rows) {
        $cells = Get-RowCells -Section $section -Row $row
        $lines.Add("| " + ($cells -join ' | ') + " |")
    }
}

$lines.Add("")
$lines.Add("Generated from " + '`' + 'scripts/readme-data.json' + '`' + " by " + '`' + 'scripts/build-readme.ps1' + '`')

Set-Content -Path $OutputPath -Value $lines -Encoding utf8
