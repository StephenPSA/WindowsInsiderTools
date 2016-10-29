##=================================================================================================
# File    : GitTools.ps1
# Author  : StephenPSA
# Version : 0.0.6.6
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
   (Will) Opens the GIT Cheat Sheet in Edge
#>
Function Show-GitHelp() {
    try {
        $h = git --help
        $h
    }
    catch {
        Write-Host "Git is not installed" -ForegroundColor Red
    }
}