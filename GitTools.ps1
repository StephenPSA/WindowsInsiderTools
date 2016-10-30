##=================================================================================================
# File    : GitTools.ps1
# Author  : StephenPSA
# Version : 0.0.6.11
# Date    : Oct, 2016
#
# Defines Funcions connected to Git use
#
# See:
#    Git Cheat Sheet                 - https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf
#    Git install                     - https://git-scm.com/downloads
#    Git in PowerShell (ISE) module  - https://github.com/dahlbyk/posh-git
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

<#
.Synopsis
    Shows Wit Integration Status and help
   Todo: Opens the GIT Cheat Sheet in Edge
#>
Function Show-GitQuickStart() {
    # var
    $hasGit = $false

    # GIT Status
    try {
        $h = git --help
        $hasGit = $true
        # Cue User
        Write-Host "Git is installed" -ForegroundColor Green
    }
    catch {
        # Cue User
        Write-Host "Git is not installed" -ForegroundColor Red
        Write-Host "Install Git from: https://git-scm.com/downloads" 
    }

    # Posh GIT Status
    $pg = Get-Module -Name posh-git -ErrorAction SilentlyContinue
    if( $pg -eq $null ) {
        # Cue User
        Write-Host "Posh Git is not installed" -ForegroundColor Red
        Write-Host "Install Posh-Git from: https://github.com/dahlbyk/posh-git" 
    }
    else {
        # Cue User
        Write-Host "Posh Git is installed: Version: $($pg.Version)" -ForegroundColor Green
    }

    # Show Cheat Sheet
    Write-Host "See Git Cheat Sheet at: https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf" 

    # EOF
}

# EOS
