#!/usr/bin/env pwsh

# For activating this pre-commit script it must be referenced in your .git/pre.commit file (must probably be created)
# An example pre.commit file exist here, so for easy setup, just execute "cp pre.commit.example .git/pre.commit"

Write-Output "Add execute permission bits to all script files"

$tmpFileName = "precommit-script-files.txt"

function addExecutableFlagToFiles {
    [string[]]$scriptsArr = Get-Content -Path $tmpFileName
    foreach ($line in $scriptsArr) {
        $lineParts = $line -split '\s+'
        $filename = $lineParts[-1]
        git update-index --chmod=+x $filename
    }
    Remove-Item -Path $tmpFileName
}

git ls-files -s -- *.sh > $tmpFileName
addExecutableFlagToFiles
git ls-files -s -- *.ps1 > $tmpFileName
addExecutableFlagToFiles