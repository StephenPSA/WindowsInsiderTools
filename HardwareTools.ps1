##=================================================================================================
# File    : HardwareTools.ps1
# Author  : StephenPSA
# Version : 0.0.3.15
# Date    : Oct, 2016
#
# Defines general Funcions
#
# THIS IS AN ADDITION
#
# See: MSFT_Disk         - https://msdn.microsoft.com/en-us/library/windows/desktop/hh830493(v=vs.85).aspx
# See: MSFT_PhysicalDisk - https://msdn.microsoft.com/en-us/library/windows/desktop/hh830532(v=vs.85).aspx
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

<#
.Synopsis
    Gets Disk Hardware Information
#>
function Get-DiskHardwareInfo {
    [CmdletBinding()]
    [Alias( 'gdh' )]
    [OutputType([DiskInfoClass[]])]
    Param(
        # Param1 help description
        [Parameter( Mandatory=$true, ValueFromPipeline=$true )]
        [Alias( 'Number' )]
        [int[]]$DiskNumber
    )

    Begin {
        # Vars
        [DiskInfoClass[]]$res = $null
    }

    Process {
        # Collect Data
        foreach( $n in $DiskNumber ) {
            $res += [DiskInfoClass]::FromDiskNr( $n )
        }
    }

    End {
        # Output to Pipeline
        Write-Output $res
    }
}