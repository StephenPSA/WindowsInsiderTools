##=================================================================================================
# File    : W10-15019-Desktop-Metrics-StandAlone.ps1
# Author  : StephenPSA
# Version : 0.0.0.1
# Date    : Jan, 2017
#
# Defines Funcions:
#
# As a workaround for Build 10.0.15019.1000 having lost the capability to change 'Advanced Graphics 
#
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

<#
.Synopsis
   Tests whether the 
.DESCRIPTION
   Returns $true if the 
.EXAMPLE
   Test-IsLocalAdmin
#>
Function Test-DesktopMetric() {
    #[Alias( 'tla' )]
    [OutputType( [Bool] )]
    Param(
    )

    # Go
    return $false
}

# EOS