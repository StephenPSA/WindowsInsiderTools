##=================================================================================================
# File    : GeneralTools.ps1
# Author  : StephenPSA
# Version : 0.0.0.1
# Date    : Jan, 2017
#
# Defines several general Funcions
#
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

<#
.Synopsis
   Tests whether the current User is a local Admin
.DESCRIPTION
   Returns $true is the current User's Roles contain [Security.Principal.WindowsBuiltInRole]::Administrator
.EXAMPLE
   Test-IsLocalAdmin
#>
Function Test-IsLocalAdmin() {
    [Alias( 'tla' )]
    [OutputType( [Bool] )]
    Param()

    # Go
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

<#
.Synopsis
   Todo: Tests whether the current User is a Domain Admin
.DESCRIPTION
   Always returns $false
.EXAMPLE
   Test-IsDomainAdmin
#>
Function Test-IsDomainAdmin() {
    [Alias( 'tda' )]
    [OutputType( [Bool] )]
    Param()

    # NOT IMPLEMENTED
    Write-Warning 'This function is yet to be implemented and always returns $false'

    # Go
    return $false
}

<#
.Synopsis
   Todo : Tests whether the current User is a local Admin
.DESCRIPTION
   Returns $true if the current User has Local- or DomainAdministrator priviliges
.EXAMPLE
   Test-IsAdmin
#>
Function Test-IsAdmin() {
    [Alias( 'tia' )]
    [OutputType( [Bool] )]
    Param()

    # Go
    return (Test-IsLocalAdmin -or Test-IsDomainAdmin)
}

<#
.Synopsis
   Test whether Git is installed on this machine
#>
function Test-HasGitCommands {
    [CmdletBinding()]
    [OutputType([bool])]
    Param(
        # The NickName(s) of the Machines to test
        [Parameter( Mandatory=$false, Position=0 )]
        [string[]]$NickName
    )

    Begin {
        # vars
        $res = $true

        # Local
        Write-Verbose "Testing whether 'git' is a command..."
        $c = Get-Command -Name git -ErrorAction SilentlyContinue
        $res = $res -and ($c -ne $null)
        if( $res ) {
            Write-Verbose "Testing whether 'git' is a command..."
        }
        else {
            Write-Verbose "Testing whether 'git' is a running..."
            try {
                $h = git --help
            }
            catch {
                Write-Verbose "'git --help' failed"
            }
        }
    }

    Process {
        # If not ok, Done
        if( !$res ) { return }

        # Match NickNames

        # EOP
    }

    End {
        # Write Pipeline
        Write-Output $res
    }
}

<# 
.Synopsis
    Gets the DateTime this Machine's OS was installed
 #>
Function Get-OsBuild() {
    [Alias( 'gosb' )]
    [OutputType( [DateTime] )]
    Param()

    # Go
    return $Global:PSVersionTable.BuildVersion
}

<# 
.Synopsis
    Gets the DateTime this Machine's OS was installed
 #>
Function Get-OsInstallDate() {
    [Alias( 'gosi' )]
    [OutputType( [DateTime] )]
    Param()

    # Go
    return (Get-CimInstance Win32_operatingSystem -Verbose:$false).InstallDate
}

<# 
.Synopsis
    Gets the DateTime this Machine was last Booted
 #>
Function Get-LastBootupTime() {
    [Alias( 'glb' )]
    [OutputType( [DateTime] )]
    Param()

    # Go
    return (Get-CimInstance Win32_operatingSystem -Verbose:$false).LastBootUpTime
}

<# 
.Synopsis
    Gets the DateTime this Machine was last Woken or [DateTime]::MinValue when never
 #>
Function Get-LastWakeupTime() {
    [Alias( 'glw' )]
    [OutputType( [DateTime] )]
    Param()

    # vars
    $w = Get-EventLog System | where EventId -EQ 1 | where Source -EQ 'Microsoft-Windows-Power-Troubleshooter' | Sort-Object TimeGenerated -Descending
    # Any found?
    if( $w -ne $null) { return $w[0].TimeGenerated }
    # No Events
    return [DateTime]::MinValue
}

<# 
.Synopsis
    Gets the DateTime this Machine was last Booted or Woken
 #>
Function Get-LastStartupTime() {
    [Alias( 'gls' )]
    [OutputType( [DateTime] )]
    Param()

    # vars
    [DateTime]$b = Get-LastBootupTime
    [DateTime]$w = Get-LastWakeupTime
    # Last is Wakeup?
    if( $w -gt $b ) { return $w }
    # Last is Booted
    return $b
}

# EOS