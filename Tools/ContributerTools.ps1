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
   Opens a location of Interest
#>
function Open-Explorer {
    [CmdletBinding()]
    Param()

    Begin {
    }

    Process {
    }

    End {
        $path = 'https://github.com/StephenPSA/WindowsInsiderTools'
        explorer $path
    }
}

# EOS