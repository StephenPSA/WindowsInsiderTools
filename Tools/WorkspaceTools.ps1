# File    : WorkspaceTools.ps1
<#=================================================================================================
# Author  : StephenPSA
# Version : 0.0.6.35 !
# Date    : Nov, 2016
#
# Defines Funcions for WindowsInsiderTools contributers
#
##-------------------------------------------------------------------------------------------------#>
#requires -Version 5.0
#using namespace System.IO

# Global Variables - Todo: Consolodate this into a WitPreferences Class
$Global:WitModulePath = "$HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools"
$Global:WitGitHub     = "$HOME\Documents\GitHub\WindowsInsiderTools"
$Global:WitCanary     = "S:\PSA_Sync\WindowsPowerShell\Modules\WindowsInsiderTools"

# Global Workspace
$Global:WitWorkspaceTabExtensions = '.md', '.psd1', '.psm1', '.ps1', '.txt'

## Global Git
#$Global:WitGitHub   = 'https://github.com/StephenPSA/WindowsInsiderTools'
#$Global:WitGitSheet = 'https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf'
#$Global:WitGitFlow  = 'https://guides.github.com/introduction/flow'

<#
.Synopsis
    Returns Versioning info of one or more Workspaces
 #>
Function Get-WorkspaceVersion() {
    [CmdletBinding( DefaultParameterSetName='Imported' )]
    [Alias( 'gwv' )]
    Param(
        # Get the Workspace Version
        [Parameter( ParameterSetName='Workspace', Mandatory=$true, Position=0 )]
        [Switch]$Workspace,

        # Get the Imported Version
        [Parameter( ParameterSetName='Imported', Mandatory=$false, Position=0 )]
        [Switch]$Imported,

        # Get the GitHub (local) Version
        [Parameter( ParameterSetName='GitHub', Mandatory=$true, Position=0 )]
        [Switch]$GitHub,

        # Get the Canary Version
        [Parameter( ParameterSetName='Canary', Mandatory=$true, Position=0 )]
        [Switch]$Canary,

        # Get the Version at
        [Parameter( ParameterSetName='Path', Mandatory=$false )]
        [string]$Path = "."

    )

    Begin { }

    Process {
        # Go
        try {
            # Module by ParameterSet
            switch ( $PSCmdlet.ParameterSetName ) {
                'Imported'     { $m = Get-Module -Name 'WindowsInsiderTools' }
                'Workspace'    { $m = Test-ModuleManifest "$Global:WitModulePath\WindowsInsiderTools.psd1" }
                'GitHub'       { $m = Test-ModuleManifest "$Global:WitGitHub\WindowsInsiderTools.psd1" }
                'Canary'       { $m = Test-ModuleManifest "$Global:WitCanary\WindowsInsiderTools.psd1" }
                'Path'         { Write-Error "Oops: Todo as I can expect anything here" }
            }
                            
            # $m = Test-ModuleManifest $pth -ErrorAction SilentlyContinue
            return $m.Version
        }
        catch {
            return $null
        }    
    }

    End {}
}

<#
.Synopsis
    For WindowsInsiderTools Developers only
#>
Function Show-Workspace {
    [CmdletBinding()]
    [Alias( 'sws' )]
    Param()

    Begin {}

    Process {
        # Cue User
        # Tobe user defined by Path parameter 
        Write-Host
        Write-Host "Workspace version: Todo Version state colors"
        Write-Host "--------------------------------------------"
        Write-Host "Workspace Version: $(Get-WorkspaceVersion -Workspace)"
        Write-Host "Imported  Version: $(Get-WorkspaceVersion -Imported)"
        #Write-Host "Canary    Version: $(Get-WitModuleVersion -Canary)"
        Write-Host "Git Branch     : $((Get-GitQuickStatus -ErrorAction SilentlyContinue ).Branch)"
        Write-Host "Git Last Commit: Todo"
        Write-Host "GitHub    Version: Todo"
        Write-Host

        ### Verbose
        if( !$Short ) {
            $gss = git status --short
            foreach( $fs in $gss ) {
                Write-Host '[' -NoNewline -ForegroundColor Yellow
                Write-Host $fs[0] -NoNewline -ForegroundColor Green
                Write-Host $fs[1] -NoNewline -ForegroundColor Red
                Write-Host $fs[2] -NoNewline -ForegroundColor Magenta
                Write-Host '] ' -NoNewline -ForegroundColor Yellow
                Write-Host $fs.SubString( 3 )
            }
            Write-Host
            Write-Host 'Green'            -NoNewLine -ForegroundColor Green
            Write-Host ' is Committed, '  -NoNewLine 
            Write-Host 'Red'              -NoNewLine -ForegroundColor Red
            Write-Host ' is not Staged, ' -NoNewLine 
            Write-Host 'Magenta'          -NoNewLine -ForegroundColor Magenta
            Write-Host ' is Stashed'
            Write-Host
        }


    }

    End {} 

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
    [CmdletBinding( DefaultParameterSetName='ByPath' )]
    [Alias( 'ows' )]
    Param(

        # The Path to Goto or Open in Explorer
        [Parameter( ParameterSetName='ByPath', Mandatory=$true, Position=0 )]
        [Alias( 'p' )]
        [string[]]$Path,

        # Opens ISE Tabs for files known to be Added, Modified or Removed (Todo)
        [Parameter( ParameterSetName='Branch', Mandatory=$true )]
        [Switch]$Branch,

        # The Path to Goto or Open in Explorer
        [Parameter( ParameterSetName='Branch', Mandatory=$true, Position=1 )]
        [string]$Name,

        # The Workspace to Goto or Open in Explorer
        [Parameter( ParameterSetName='Workspace', Mandatory=$false, Position=0 )]
        [Alias( 'w' )]
        [WitWorkspace[]]$Workspace, # = [WitWorkspace]::WitModule,

        # The Path to Goto or Open in Explorer
        [Parameter( ParameterSetName='Workspace', Mandatory=$false, Position=1 )]
        [string]$Topic = '',

        # Opens ISE-Tabs for files known to be changed, but not yet Staged
        [Parameter( ParameterSetName='UnStaged', Mandatory=$true, Position=0 )]
        [Alias( 'us' )]
        [Switch]$UnStaged,

        # Opens ISE-Tabs for files known to be changed, Staged but not yet Committed
        [Parameter( ParameterSetName='UnCommitted', Mandatory=$true )]
        [Alias( 'uc' )]
        [Switch]$UnCommitted,

        # Opens ISE-Tabs for files known to be changed, Committed but not yet Pushed
        [Parameter( ParameterSetName='UnPushed', Mandatory=$true )]
        [Switch]$UnPushed,

        # Opens ISE-Tabs for files known to be changed, Pushed but not yet Published
        [Parameter( ParameterSetName='UnPublished', Mandatory=$true )]
        [Switch]$UnPublished,

        [Parameter( ParameterSetName='UnCommitted', Mandatory=$false, Position=1 )]
        [Parameter( ParameterSetName='UnStaged', Mandatory=$false, Position=1 )]
        [Switch]$DontCollapse,

        # Opens ISE-Tabs for files known to be changed, Pushed but not yet Published
        [Parameter( ParameterSetName='NewISE', Mandatory=$true )]
        [Switch]$NewISE,

        # Opens ISE Tabs for files known to be Added, Modified or Removed (Todo)
        [Parameter( ParameterSetName='InWork', Mandatory=$true )]
        [Switch]$InWork
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
        if( $PSCmdlet.ParameterSetName -eq 'ByPath' ) {
            # Walk Path(s)
            foreach( $pth in $Path ) {
                # Location or Browser
                if( $pth.StartsWith( 'http' ) ) {
                    explorer $pth
                }
                else {
                    # vars
                    $w = Get-Item $pth

                    # Folder
                    if( $w -is [System.IO.DirectoryInfo] ) {
                        Set-Location $pth
                    }

                    # File
                    if( $w -is [System.IO.FileInfo] ) {
                        Write-Host $w.Extension
                        if( $w.Extension -in ($Global:WitWorkspaceTabExtensions) ) {
                            # Tell and Open
                            Write-Host "New Tab: '$w'"
                            $res = $psISE.CurrentPowerShellTab.Files.Add( $w.FullName )
                            # Todo: Adorn the Tab
                        }
                    }

                }
            }
            # Done
        }
        
        # -- Shortcut - UnStaged
        if( $PSCmdlet.ParameterSetName -eq 'UnStaged' ) {
            # Get the Added, Modified or Deleted Files
            Write-Verbose "Querying Git for UnStaged work..."
            $gr = git status --short
            foreach( $f in $gr ) {
                # Filter but UnStaged
                if( $f[1] -eq ' ') { continue }

                # vars
                $p = ".\$($f.SubString( 3 ))"

                # Tell and Open
                Write-Host "New Tab [$($f.SubString( 0, 3))] $p"
                $res = $psISE.CurrentPowerShellTab.Files.Add( "$(Get-Location)$p" )
                # Adorn the Tab
                if( $res -ne $null) {
                    # PowerShell ISE
                    $psISE.CurrentPowerShellTab.DisplayName = "[$($f.SubString( 0, 3))] $p"
                    # Option
                    if( !$DontCollapse ) { $res.Editor.ToggleOutliningExpansion() }
                    # Option
                    #$res,Editor.SetCaretPosition( x, y )
                    #$res.Editor.EnsureVisible( 251 )
                }

            }
            # Done
        }

        # -- Shortcut - UnCommitted
        if( $PSCmdlet.ParameterSetName -eq 'UnCommitted' ) {
            # Get the Added, Modified or Deleted Files
            Write-Verbose "Querying Git for Uncommited work..."
            $gr = git status --short
            foreach( $f in $gr ) {
                # Filter Unstaged
                if( $f[0] -ne ' ' ) { continue }
                # vars
                $p = ".\$($f.SubString( 3 ))"
                # Tell and Open
                Write-Host "New Tab [$f[0]] : '$p'"
                $res = $psISE.CurrentPowerShellTab.Files.Add( "$(Get-Location)$p" )
                # Todo: Adorn the Tab
            }
            #$gqs = Get-GitQuickStatus
            #$fs = $gqs.Modified
            #foreach( $f in $fs ) {
            #    # vars
            #    $p = ".\$f"
            #    # Tell and Open
            #    Write-Host "New Tab: $p"
            #    ise $p
            #}
            # Done
        }

        # -- Shortcut - InWork
        if( $PSCmdlet.ParameterSetName -eq 'InWork' ) {
            # Get the Added, Modified or Deleted Files
            Write-Verbose "Querying Git..."
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
                    # Git - Todo, use Get-Branch to show Commits, etc. info
                    'Branch'              { git checkout $Topic }
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
                    'GitHub'              { explorer "$Global:WitGitHub/tree/$((ggq).Branch)" }
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
        # Write Pipeline
        if( $res -ne $null) { Write-Output $res }
    }
}

# EOS