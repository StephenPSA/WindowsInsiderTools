﻿##=================================================================================================
# File    : GitTools.ps1
# Author  : StephenPSA
# Version : 0.0.6.33
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

# Global Variables - Todo: Consolodate this into a WitPreferences Class
# Webpage
$Global:WitGitSheet = 'https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf'
# Webpage
$Global:WitGitFlow  = 'https://guides.github.com/introduction/flow'
# Webpage - appended with current Branch
$Global:WitGitHub   = 'https://github.com/StephenPSA/WindowsInsiderTools'

<#
.Synopsis
    Shows Wit Integration Status and help
#>
Function Show-GitQuickStart() {
    [CmdletBinding()]
    Param()

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

    if( $PSBoundParameters['Verbose'] ) {
        # 

        # Show Cheat Sheet
        Write-Verbose "Open the Git Cheat Sheet by typing: ows GitSheet" 
    }

    # EOF
}

<#
.Synopsis
    Gets Quick Git Status
#>
Function Get-GitQuickStatus() {
    [Alias( 'ggq' )]
    Param(
        # 
        [int]$Indents = 1
    )

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

<#
.Synopsis
   Short description
#>
Function New-GitBranch {
    [CmdletBinding( SupportsShouldProcess=$true )]
    [Alias( 'ngb' )]
    [OutputType([object])]
    Param(
        # If set, names the new branch
        [Parameter( Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        [Switch]$NewRevision

        # Forces 
    )

    Begin {
        # vars
        if( $NewRevision ) {
            Write-Verbose "Aaarrgh! You got me, i.e. Todo:"
        }
    }

    Process {
    }

    End {
    }

}

<#
.Synopsis
   Opens a Workspace for work
.Example
   ows -InWork

   Open PowerShell ISE Tabs for all files in 'work' (as seen by Git)

.Example
   ows PsIseTab .\README.md

   Open PowerShell ISE Tabs for file: .\README.md
#>
Function Open-Workspace {
    [CmdletBinding( DefaultParameterSetName='Workspace' )]
    [Alias( 'ows' )]
    Param(
        # The Workspace to Goto or Open in Explorer
        [Parameter( ParameterSetName='Workspace', Mandatory=$false, Position=0 )]
        [WitWorkspace[]]$Workspace = [WitWorkspace]::WitModule,

        # The Path to Goto or Open in Explorer
        [Parameter( ParameterSetName='Workspace', Mandatory=$false, Position=1 )]
        [string]$Topic = '',

        # Opens ISE Tabs for files known to be Added, Modified or Removed, but not yet Committed
        [Parameter( ParameterSetName='Uncommitted', Mandatory=$true )]
        [Switch]$Uncommitted,

        # Opens ISE Tabs for files known to be Added, Modified or Removed (Todo)
        [Parameter( ParameterSetName='InWork', Mandatory=$true )]
        [Switch]$InWork,

        # The Path to Goto or Open in Explorer
        [Parameter( ParameterSetName='Path', Mandatory=$true )]
        [string]$Path = '.'
    )

    Begin {
        ## Go
        #switch( $PSCmdlet.ParameterSetName ) {
        #    '
        #    default { Set-Location $Path }
        #}
    }

    Process {
        # Select Param set
        # -- Generic
        if( $PSCmdlet.ParameterSetName -eq 'Path' ) {
            # Location or Browser
            if( $Path.StartsWith( 'http' ) ) {
                explorer $Path
            }
            else {
                Set-Location $Path
            }
            # Done
        }
        
        # -- Shortcut - Uncommitted
        if( $PSCmdlet.ParameterSetName -eq 'Uncommitted' ) {
            # Get the Added, Modified or Deleted Files
            Write-Verbose "Querying Git for Uncommited work..."
            $gqs = Get-GitQuickStatus
            $fs = $gqs.Modified
            foreach( $f in $fs ) {
                # vars
                $p = ".\$f"
                Write-Host $p
                # Open
                ise $p
            }
            # Done
        }

        # -- Shortcut - InWork
        if( $PSCmdlet.ParameterSetName -eq 'InWork' ) {
            # Get the Added, Modified or Deleted Files
            Write-Verbose "Querying Git..."
            $gqs = Get-GitQuickStatus
            $fs = $gqs.Modified
            foreach( $f in $fs ) {
                # vars
                $p = ".\$f"
                Write-Host $p
                # Open
                ise $p
            }
            # Done
        }

        # -- WitWorkspace
        if( $PSCmdlet.ParameterSetName -eq 'Workspace' ) {
            # Walk so we can Open multiple Web-sites
            foreach( $ws in $Workspace ) {
                switch( $ws ) {
                    '' {}
                    # Usefull Locations
                    'Documents'           { Set-Location "$HOME\Documents" }
                    'Projects'            { Set-Location "$HOME\Documents\Visual Studio 15\Projects" }
                    'PsModules'           { Set-Location "$HOME\Documents\WindowsPowerShell\Modules" }
                    # Git
                    'GitBranch'           { git checkout $Topic }
                    # Usefull Locations     
                    'Canary'              { Write-Host "Todo: " }
                    'Imported'            { Write-Host "Todo: " }
                    # PowerShell (ISE)
                    'Tab'                 { ise $Topic }
                    # WIT                   
                    'WitModule'           { Set-Location "$HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools" }
                    'WitImported'         { }
                    'WitUpdate'           { explorer "https://github.com/StephenPSA/WindowsInsiderTools" }
                    # Usefull Web-Sites     
                    'GitHelp'             { git --help $Topic }
                    'GitHub'              { explorer "$Global:WitGitHub/tree/$((ggq).Branche)" }
                    'Git'                 { explorer "https://git-scm.com" }
                    'PoshGit'             { explorer "https://github.com/dahlbyk/posh-git" }
                    'GitDesktop'          { explorer "https://desktop.github.com/" }
                    'GitSheet'            { explorer $Global:WitGitSheet }
                    'GitFlow'             { explorer $Global:WitGitFlow }
                    Default {}
                }
            }
        }
    }

    End {
    }
}

# EOS
