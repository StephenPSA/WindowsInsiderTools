##=================================================================================================
# File    : WorkspaceTools.ps1
# Author  : StephenPSA
# Version : 0.0.6.32
# Date    : Nov, 2016
#
# Defines Funcions for WindowsInsiderTools contributers
#
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

# Global Variables - Todo: Consolodate this into a WitPreferences Class
$Global:WitModulePath = "$HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools"
$Global:WitGitHub = "$HOME\Documents\GitHub\WindowsInsiderTools"
$Global:WitCanary = "S:\PSA_Sync\WindowsPowerShell\Modules\WindowsInsiderTools"

# Git
$Global:WitGitHub   = 'https://github.com/StephenPSA/WindowsInsiderTools'
$Global:WitGitSheet = 'https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf'
$Global:WitGitFlow  = 'https://guides.github.com/introduction/flow'

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

    Begin {
    }

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
    [CmdletBinding( DefaultParameterSetName='ByPath' )]
    [Alias( 'ows' )]
    Param(

        # The Path to Goto or Open in Explorer
        [Parameter( ParameterSetName='ByPath', Mandatory=$true, Position=0 )]
        [Alias( 'p' )]
        [string[]]$Path,

        # The Workspace to Goto or Open in Explorer
        [Parameter( ParameterSetName='Workspace', Mandatory=$false, Position=0 )]
        [Alias( 'w' )]
        [WitWorkspace[]]$Workspace, # = [WitWorkspace]::WitModule,

        # The Path to Goto or Open in Explorer
        [Parameter( ParameterSetName='Workspace', Mandatory=$false, Position=1 )]
        [string]$Topic = '',

        # Opens ISE Tabs for files known to be Added, Modified or Removed, but not yet Committed
        [Parameter( ParameterSetName='Uncommitted', Mandatory=$true )]
        [Alias( 'u' )]
        [Switch]$Uncommitted,

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
        if( $PSCmdlet.ParameterSetName -eq 'Path' ) {
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
                    if( $w -is [Windows.Storage.StorageFolder] ) {
                        Set-Location $pth
                    }

                    # File
                    if( $pth.EndsWith( ".ps1" ) ) {
                        Write-Host "Todo...deloo...."
                    }

                }
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