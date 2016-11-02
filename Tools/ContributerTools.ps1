##=================================================================================================
# File    : ContributerTools.ps1
# Author  : StephenPSA
# Version : 0.0.6.27
# Date    : Nov, 2016
#
# Defines Funcions for WindowsInsiderTools contributers
#
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

# Global Variables
$Global:WitGitSheet = 'https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf'
$Global:WitGitFlow = 'https://guides.github.com/introduction/flow'

<#
.Synopsis
   Opens a location for work
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
                    # Usefull Locations     
                    'Canary'              { }
                    'Imported'            { }
                    # WIT                   
                    'WitModule'           { Set-Location "$HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools" }
                    'WitImported'         { }
                    'WitUpdate'           { explorer "https://github.com/StephenPSA/WindowsInsiderTools" }
                    # Usefull Web-Sites     
                    'GitHelp'             { git --help $Topic }
                    'GitHub'              { explorer "https://github.com/StephenPSA/WindowsInsiderTools" }
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