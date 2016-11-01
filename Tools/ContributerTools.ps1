##=================================================================================================
# File    : ContributerTools.ps1
# Author  : StephenPSA
# Version : 0.0.6.17
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
    Param(
        # The Path to Goto or Open in Explorer
        [string]$Path = 'https://github.com/StephenPSA/WindowsInsiderTools'
    )

    Begin {
        ## Go
        #switch( $PSCmdlet.ParameterSetName ) {
        #    '
        #    default { Set-Location $Path }
        #}
    }

    Process {
    }

    End {
        explorer $Path
    }
}

# EOS