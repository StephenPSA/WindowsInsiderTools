##=================================================================================================
# File    : MonitoringTools.ps1
# Author  : StephenPSA
# Version : 0.0.6.34
# Date    : Oct, 2016
#
# Defines general Funcions
#
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

<#
.Synopsis
   Show OS State and Event Info
.Description
   Show OS State and Event Info
.Example
    Show-OsMonitor or som
.Example
    som -Prefix lap
#>
Function Show-OsMonitor {
    [CmdletBinding()]
    [Alias( 'som' )]
    Param(
        # The interval in seconds at which to refresh
        [Parameter( Mandatory=$false, Position=0 )]
        [uint16]$LastMinutes = 10,

        # The NickNames of the WitSessions to show, accepts Wildcards
        [Parameter( Mandatory=$false, Position=1 )]
        [string[]]$NickName = '*',

        # The interval in seconds at which to refresh
        [Parameter( Mandatory=$false, Position=2 )]
        [uint16]$Interval = 10
    )

    Begin {
    }

    Process {
        # Go
        do {
            # Stop?

            # Show The OS State(s)
            cls
            Write-Host "OS States and Event as of $([DateTime]::Now), NickName(s): $NickName"
            Write-Host "----------------------------------------------------------------------------------------------------------------"
            $oss = gos -NickName $NickName -LocalNickName "."
            Write-Output $oss

            # Show Recent Events
            $evs = gev -LastMinutes $LastMinutes -LocalNickName "."
            # Report
            if( $evs.Count -eq 0 ) {
                Write-Host "No events in the last $LastMinutes Minutes "
                Write-Host
            }
            else { 
                Write-Host "Events in the last $LastMinutes Minutes: $($evs.Count)"
                Write-Output $evs
            }
            # Cue User
            Write-Host "Next Update at $([DateTime]::Now.AddSeconds( $Interval )), Ctl+C to stop..." -NoNewline
            # Pause
            Start-Sleep -Seconds $Interval
            # Loop
        } while( $true )
    }

    End {
    }
}
