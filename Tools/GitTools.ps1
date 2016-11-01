##=================================================================================================
# File    : GitTools.ps1
# Author  : StephenPSA
# Version : 0.0.6.14
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
    $hasGit = Test-HasGitCommands

    # GIT Status
    if( $hasGit ) {
        # Cue User
        Write-Host "Git is installed" -ForegroundColor Green
        Write-Host "-- See Git at: https://git-scm.com/downloads" 
    }
    else {
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

<#
.Synopsis
    Gets Quick Git Status
#>
Function Get-GitQuickStatus( [int]$Indents = 1 ) {
    # var
    [string[]]$status = $null
    [string[]]$add = $null
    [string[]]$upd = $null
    [string[]]$rem = $null
    $brn = $null

    # Query git
    $gs = git status


    # Filter Levels
    foreach( $m in $gs ) {
        # Skip Empty Lines
        if( $m.Trim().Length -eq 0 ) { continue }
        # Replace Tab Char
        $m = $m.Replace( "`t", "    " )
        # Extract branch
        if( $brn -eq $null ) {
            $brn = $m.Substring( 10 )
            continue
        }
        # Extract Changed Files
        if( $m.StartsWith( "    new file:" ) ) {
            $add += $m.Substring( 14 ).Trim()
        }
        if( $m.StartsWith( "    modified:" ) ) {
            $upd += $m.Substring( 14 ).Trim()
        }
        if( $m.StartsWith( "    deleted:" ) ) {
            $rem += $m.Substring( 14 ).Trim()
        }
        # Calc Indent
        $i = ($m.Length - $m.TrimStart().Length) / 2
        Write-Verbose "$($i.ToString( "#0" )) | $m"
        # Add if in range
        if( $i -lt $Indents ) { $status += $m }
    }

    # Build out
    $hsh =[ordered]@{
       'Branche'  = $brn
       'Status'   = $status
       'Added'    = $add
       'Modified' = $upd
       'Removed'  = $rem
    }
    $res = New-Object -TypeName PSObject -ArgumentList $hsh

    # Write Pipeline
    Write-Output $res

    # EOF
}

# EOS
