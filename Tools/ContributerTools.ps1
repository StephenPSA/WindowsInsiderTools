##=================================================================================================
# File    : ContributerTools.ps1
# Author  : StephenPSA
# Version : 0.0.6.26
# Date    : Nov, 2016
#
# Defines Funcions for WindowsInsiderTools contributers
#
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

<#
.Synopsis
   Opens a location for work
#>
function Open-Workspace {
    [CmdletBinding()]
    [Alias( 'ows' )]
    Param(
        # The Path to Goto or Open in Explorer
        [Parameter( ParameterSetName='Path', Mandatory=$false, Position=0 )]
        [string]$Path = '.',

        # The Workspace to Goto or Open in Explorer
        [Parameter( ParameterSetName='Workspace', Mandatory=$false, Position=0 )]
        [WitWorkspace[]]$Workspace = [WitWorkspace]::NotSet
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
                    'MyDocuments'         { Set-Location "$HOME\Documents" }
                    'MyProjects'          { Set-Location "$HOME\Documents\Visual Studio 15\Projects" }
                    # Usefull Locations     
                    'Canary'              { }
                    'Imported'            { }
                    # WIT                   
                    'WitModule'           { Set-Location "$HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools" }
                    'WitImported'         { }
                    'WitUpdate'           { explorer "https://github.com/StephenPSA/WindowsInsiderTools" }
                    # Usefull Web-Sites     
                    'GitHub'              { explorer "https://github.com/StephenPSA/WindowsInsiderTools" }
                    'Git'                 { explorer "https://git-scm.com" }
                    'PoshGit'             { explorer "https://github.com/dahlbyk/posh-git" }
                    'GitDesktop'          { explorer "https://desktop.github.com/" }
                    'GitSheet'            { explorer "https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf" }
                    Default {}
                }
            }
        }
    }

    End {
    }
}

# EOS