##=================================================================================================
# File    : PowerShellTools.ps1
# Author  : StephenPSA
# Version : 0.0.6.33
# Date    : Oct, 2016
#
# Defines Funcions connected to Git under PowerShell (ISE) use.
#
# See:
#    Git Cheat Sheet                 - https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf
#    Git install                     - https://git-scm.com/downloads
#    Git in PowerShell (ISE) module  - https://github.com/dahlbyk/posh-git
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

# Global Variables - Todo: Consolodate this into a WitPreferences Class

#using static namespace System.String

<#
.Synopsis
   Opens a Workspace for work (help ows -ShowWindow)
.Example
   ows -Uncommitted

   Open PowerShell ISE Tabs for all files that are not yet committed

.Example
   ows Tab .\README.md

   Open PowerShell ISE Tabs for file: .\README.md

.Example 
    ows Issue

    Open the Browser at the List of active Issues

.Example 
    ows Issue 42

    Open the Browser at a specific Issue

#>
Function Open-Workspace {
    [CmdletBinding( DefaultParameterSetName='Workspace' )]
    [Alias( 'ows' )]
    [OutputType( [object] )]
    Param(
        # The Workspace to Goto or Open in Explorer
        [Parameter( ParameterSetName='Workspace', Mandatory=$false, Position=0 )]
        [WitWorkspace[]]$Workspace = [WitWorkspace]::WitModule,

        # The Path to Goto or Open in Explorer
        [Parameter( ParameterSetName='Workspace', Mandatory=$false, Position=1 )]
        [string]$Topic = '',

        # Opens the GitHub Issue by Number
        [Parameter( ParameterSetName='IssueNr', Mandatory=$false, Position=1 )]
        [int]$IssueNr,

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
        # var
        [System.Object]$res = $null

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
        
        # -- Shortcut - IssueNr
        if( $PSCmdlet.ParameterSetName -eq 'IssueNr' ) {
            # Vars
            $url = "$Global:WitGitHub/issues/$IssueNr"
            # Get the Added, Modified or Deleted Files
            Write-Verbose "Opening Website: '$url'..."
            explorer $url
            # Done
        }

        # -- Shortcut - Uncommitted
        if( $PSCmdlet.ParameterSetName -eq 'Uncommitted' ) {
            # Get the Added, Modified or Deleted Files
            Write-Verbose "Querying Git for Uncommited work..."
            $gqs = Get-GitQuickStatus
            $fs = $gqs.Added + $gqs.Modified + $gqs.Removed
            foreach( $f in $fs ) {
                # Skip Empties
                if( $f.Length -eq 0 ) { continue }
                # vars
                $p = ".\$f"
                Write-Verbose "New Tab: $p"
                # Open
                $hr = ise $p
                Write-Output $hr
            }
            # Done
        }

        # -- Shortcut - InWork
        if( $PSCmdlet.ParameterSetName -eq 'InWork' ) {
            # Get the Added, Modified or Deleted Files
            Write-Warning "[Deprecated] Use -Uncommitted instead"
            #Write-Verbose "Querying Git..."
            #$gqs = Get-GitQuickStatus
            #$fs = $gqs.Modified
            #$fs = $gqs.Added + $gqs.Modified + $gqs.Removed
            #foreach( $f in $fs ) {
            #    # Skip Empties
            #    if( $f.Length -eq 0 ) { continue }
            #    # vars
            #    $p = ".\$f"
            #    Write-Host $p
            #    # Open
            #    ise $p
            #}
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
                    # Git Integration
                    'Branch'              { $res = git checkout $Topic 2>>$null }
                    'Issue'               { 
                                            $url = "$Global:WitGitHub/issues"
                                            if( $Topic.Length -ne 0 ) { $url += "/$Topic" }
                                            Write-Verbose "Opening '$url'..."
                                            explorer $url
                                          }
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

        # EOP
    }

    End {
        # Ignore if no result
        if( $res -ne $null ) { Write-Output $res }
    }

    # EOF
}

# EOS
