##=================================================================================================
# File    : GeneralTools.ps1
# Author  : StephenPSA
# Version : 0.0.4.3
# Date    : Nov, 2016
#
# Defines general Funcions
#
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

<#
.Synopsis
   Gets local current OS State
.Description
   Todo: Activation, CPU Hardware
#>
Function Get-LocalOsState {
    [Alias( 'lgos' )]
    Param()

    [OsStateClass]$res = [OsStateClass]::New()
    Write-Output $res
}

<#
.Synopsis
   Gets current OS State
.Description
   Todo: Activation, CPU Hardware
.Example
   Get-OsState or gos
.Example
   Get-OsState -NickName tab, lap
#>
Function Get-OsState {
    [CmdletBinding()]
    [Alias( 'gos' )]
    [OutputType( [object[]] )]
    Param (
        # The NickName(s) to show, accepts Wildcards
        [Parameter( Mandatory=$false, Position=0 )]
        [string[]]$NickName = '*',
        
        # To which Depth to include Remoting WitSession(s)
        # Test: that does not work as -Recurse when -gt 0
        [Parameter( Mandatory=$false, Position=1 )]
        [uint16]$Depth = 1,

        # The NickName(s) to show for remotes
        [Parameter( Mandatory=$false, Position=2 )]
        [string[]]$LocalNickName = '.'
        
    )

    Begin {
        # Vars
        [object[]]$res = $null
        [object[]]$jobs = $null
    }

    Process {
        # Walk NickName
        foreach( $nn in $NickName ) {
            # Cue Verbose
            Write-Verbose "Processing: '$nn'..."
            # Local OsState
            if( $nn -in '.', '*' ) {
                # Inline - is much faster
                $res += [OsStateClass]::New( $LocalNickName )
                # WRONG $jobs += Invoke-Command -ComputerName '.' -ScriptBlock { [OsStateClass]::New() } -JobName "WitJob_local" 
                # Background
                #$jobs += start-job -ScriptBlock { [OsStateClass]::New() }
                #$jobs += start-job -ScriptBlock { Get-LocalOsState }

            }
            
            # Init (Background) Work WitSessions
            if( $Depth -gt 0 ) {
                $ss = Get-WitSession -NickName $nn -WarningAction SilentlyContinue
                if( $ss -ne $null ) {
                    # Inline
                    #$res += Invoke-Command $ss { gos } # [OsStateClass]::New() ?
                    # Background
                    foreach( $s in $ss ) {
                        # vars
                        $rdp = $Depth - 1
                        $rnn = $s.Name.Substring(11)
                        $jobs += Invoke-Command -Session $s { gos -NickName '*' -Depth $Using:rdp -LocalNickName $Using:rnn } -AsJob -JobName "WitJob_$rnn)"
                    }
                    #### WRONG $jobs += start-job -ScriptBlock { invoke-command -Session $ss -ScriptBlock { gos -NickName $nn -Depth $($Depth - 1) } } 
                    #### WRONG? $jobs += start-job -scriptblock { Invoke-Command $ss { gos } }
                }
            }

        }
    }
    
    End {
        # Finish all jobs
        if( $jobs -ne $null ) {
            Write-Verbose "Waiting for WIT Jobs: '$NickName'..."
            $res += $jobs | Receive-Job -Wait -AutoRemoveJob
        }
        # Insert Type
        foreach( $r in $res ) {
            $r.PSTypeNames.Insert( 0, 'Wit.OsStateClass' )
        }

        #Update-TypeData -TypeName "Wit.OsStateClass" -MemberType NoteProperty -MemberName "NickName" -Value $NickName -Force

        #Update-TypeData -TypeName "Wit.OsStateClass" -MemberType ScriptProperty -MemberName "FooMember" -Value { $this.MachineName }
        
        # Write to Pipeline
        Write-Output $res
    }
}

# Define Misc Functions 

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

<#
.Synopsis
   Shows various views on the OS States
.Description
   -Defense (default)
   -Hardware
.Example
   gos | Show-OsState or gos | sos
#>
Function Show-OsState {
    [CmdletBinding( DefaultParametersetName='Defense' )]
    [Alias( 'sos' )]
    Param(
        # Show the Month and Day
        [Parameter( Mandatory=$false, ValueFromPipeline=$true )]
        $input,

        # Show the WindowsDefender Information
        [Parameter( ParameterSetName='Defense', Mandatory=$false )]
        [Switch]$Defense = $true,

        # Show the installation Hardware Information
        [Parameter( ParameterSetName='Hardware', Mandatory=$false )]
        [Switch]$Hardware

    )

    # Go - Hardware
    if( $Hardware ) {
        $input | select @{n='NN';e={$_.NickName}}, `
                        MachineName, `
                        Description, `
                        Build, `
                        OsDisk, `
                        OsDiskHealth, `
                        OsDiskBus, `
                        OsDiskLocation `
                        | ft
        # Done
        return
    }
   
    # Go - Defense
    if( $Defense ) {
        $input | select @{n='NN';e={$_.NickName}}, `
                        MachineName, `
                        Description, `
                        Build, `
                        InstallDate, `
                        WitVersion, `
                        DefenderAVDefinition, `
                        DefenderDefinitionDate, `
                        DefenderLastScanDate, `
                        DefenderLastScanType `
                        | ft
    }
   
}

# EOS