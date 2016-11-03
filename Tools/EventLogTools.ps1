##=================================================================================================
# File    : EventLogTools.ps1
# Author  : StephenPSA
# Version : 0.0.4.7
# Date    : Oct, 2016
##-------------------------------------------------------------------------------------------------

# Define Functions that use EventInfoClass

<# 
.Synopsis
    Gets Events from the known EventLogs
.Description
    Queries for and collates Events generated after the last system startup, in the last N minutes, 
    [After|Before] a [Date-]Time or Between two [Date-]Times
.Example
    Get-LocalEventInfo | Format-EventInfoTable or gev | fet
    Collates Error and Warning Events in all EventLogs generated in the last 60 minutes
.Example
    gev -AfterStartup -Ascending | fet
    Collates Error and Warning Events, ascending in time, Events generated after the last time the 
    Machine was Woken or Booted
.Example
    gev -Between (Get-LastStartupTime).AddMinutes( -5 ), (Get-LastStartupTime).AddMinutes( 5 ) -Ascending -ShowInformation | fet
    Collates, ascending in time, all Events generated in the 10 minutes around the last time the Machine was started
.Example
    gev -AfterStartup -Ascending | Select-Object -First 10 | fet
    Collates, ascending in time, the first 10 Error and Warning Events generated after the last time 
    the Machine was Woken or Booted
.Example
    gev -AfterStartup -HideWarnings -Ascending | Where-Object Source -NotIn 'COM', 'DCOM' | fet
    Collates, ascending in time, Error Events whose Source is not 'COM' or 'DCOM' and generated after 
    the last time the Machine was started
.Example
    Get-LocalEventInfo -Between 09:00,17:00 | fet
    Collates Error and Warning Events generated today between 9am and 5pm
.Notes
    Todo: -ExcludeSource -ExcludeEventId
#>
Function Get-LocalEventInfo() {
    
    [CmdletBinding( DefaultParameterSetName='LastMinutes' )]
    [Alias( 'lgev' )]
    [OutputType([EventInfoClass[]])]
    Param(
        # Show Events generated in the last N minutes (default: 60 minutes)
        [Parameter( ParameterSetName='LastMinutes', Mandatory=$false, Position=0 )]
        [int]$LastMinutes = 60,

        # Show Events generated after last Startup
        [Parameter( ParameterSetName='AfterStartup', Mandatory=$true, Position=0 )]
        [Switch]$AfterStartup = $false,

        # Show Events generated after last Startup
        [Parameter( ParameterSetName='AnyTime', Mandatory=$true, Position=0 )]
        [Switch]$AnyTime = $false,

        # Show Events generated after the [Date-]Time
        [Parameter( ParameterSetName='After', Mandatory=$true, Position=0 )]
        [DateTime]$After,

        # Show Events generated before the [Date-]Time
        [Parameter( ParameterSetName='Before', Mandatory=$true, Position=0 )]
        [DateTime]$Before,

        # Show Events generated between two [Date-]Times
        [Parameter( ParameterSetName='Between', Mandatory=$true, Position=0 )]
        [ValidateCount( 2, 2 )]
        [DateTime[]]$Between,

        # Show Events generated between two [Date-]Times - ParameterSetName='AllLogs', 
        [Parameter( Mandatory=$false, Position=1 )]
        [Switch]$AllLogs,

        # The name(s) of the EventLogs to search - Accepts WildCards
        [Parameter( Mandatory=$false, Position=1 )]
        [ValidateNotNull()]
        [string[]]$LogName = ( 'System', 'Application' ),

        # The name of the Source to search for - Accepts WildCards
        [Parameter( Mandatory=$false )]
        [ValidateNotNull()]
        [string]$Source = '*',

        # The EventId of the event to search for
        [Parameter( Mandatory=$false )]
        [AllowNull()]
        [Int[]]$EventId = $null,

        # Hide Events typed Error, FailureAudit
        [Parameter( Mandatory=$false )]
        [Switch]$HideErrors,

        # Hide Events typed Warning
        [Parameter( Mandatory=$false )]
        [Switch]$HideWarnings,

        # Show Events typed Information, SuccessAudit
        [Parameter( Mandatory=$false )]
        [Switch]$ShowInformation,

        # Show Events in the 'Security' log (requires Administrator right)
        [Parameter( Mandatory=$false )]
        [Switch]$ShowSecurity,

        # Sort EntryTime Ascending
        [Parameter( Mandatory=$false )]
        [Switch]$Ascending,

        # The NickName(s) to show for remotes
        [Parameter( Mandatory=$false )]
        [string]$LocalNickName = '.'
        
    )
     
    Begin {
        # Cue User
        #Write-Host "Begin: $($PSCmdlet.ParameterSetName), LocalNickName: '$LocalNickName'..."

        # vars
        [EventInfoClass[]]$res = $null
        [object[]]$logs = $null

        # Get Logs to query
        if( $AllLogs ) {
            $Logs = Get-EventLog -List
        }
        else {
            foreach( $l in $LogName ) {
                $Logs += Get-EventLog -List | Where-Object Log -Like $l
            }
        }

        # Filter 'Security'
        if( !($ShowSecurity) ) {
            $Logs = $Logs | Where-Object Log -NotLike 'Security'
        }

    }
    
    Process {

        # Walk LogName
        foreach( $log in $Logs.Log ) {
            # Parameter Set
            if( $PSCmdlet.ParameterSetName -eq 'LastMinutes' ) {
                # Cue User
                Write-Verbose "Collecting events, Log: '$log', in the last $LastMinutes minutes..."

                # vars
                $After = [DateTime]::Now - [TimeSpan]::FromMinutes( $LastMinutes )

                # Work After
                $wrk = Get-EventLog -LogName $log -After $After -ErrorAction SilentlyContinue

            }

            # Parameter Set
            if( $PSCmdlet.ParameterSetName -eq 'AfterStartup' ) {
                # vars
                $After = (Get-LastStartupTime).AddSeconds( -5 )

                # Cue User
                Write-Verbose "Collecting events, Log: '$log', after Startup at $After..."

                # Work After
                $wrk = Get-EventLog -LogName $log -After $After -ErrorAction SilentlyContinue

            }

            # Parameter Set
            if( $PSCmdlet.ParameterSetName -eq 'AnyTime' ) {
                # vars
                #$After = (Get-LastStartupTime).AddSeconds( -5 )

                # Cue User
                Write-Verbose "Collecting events, Log: '$log', at any time..."

                # Work After
                $wrk = Get-EventLog -LogName $log -ErrorAction SilentlyContinue

            }

            # Parameter Set
            if( $PSCmdlet.ParameterSetName -eq 'After' ) {
                # Cue User
                Write-Verbose "Collecting events, Log: '$log', after $After..."

                # Work After
                $wrk = Get-EventLog -LogName $log -After $After -ErrorAction SilentlyContinue

            }

            # Parameter Set
            if( $PSCmdlet.ParameterSetName -eq 'Before' ) {
                # Cue User
                Write-Verbose "Collecting events, Log: '$log', before $Before..."

                # Work After
                $wrk = Get-EventLog -LogName $log -Before $Before -ErrorAction SilentlyContinue

            }

            # Parameter Set
            if( $PSCmdlet.ParameterSetName -eq 'Between' ) {
                # Cue User
                Write-Verbose "Collecting events, Log: '$log', between $($Between[0]) and $($Between[1])..."

                # Work After
                $wrk = Get-EventLog -LogName $log -After $Between[0] -Before $Between[1] -ErrorAction SilentlyContinue

            }

            # Filter Events and Create EventInfoClass's
            foreach( $e in $wrk ) {
                # Filter on EntryType
                if( $HideErrors -eq $true ) {
                    if( $e.EntryType -eq 'Error' ) { continue }
                    if( $e.EntryType -eq 'FailureAudit' ) { continue }
                }
                if( $HideWarnings -eq $true ) {
                    if( $e.EntryType -eq 'Warning' ) { continue }
                }
                if( $ShowInformation -ne $true ) {
                    if( $e.EntryType -eq 'Information' ) { continue }
                    if( $e.EntryType -eq 'SuccessAudit' ) { continue }
                }
                # Filter on Source
                if( $e.Source -notlike $Source ) { continue }

                # Filter on Source
                if( $EventId -ne $null ) {
                    if( $e.EventId -notin $EventId ) { continue }
                }

                # Result!
                $res += [EventInfoClass]::New( $LocalNickName, $log, $e )
            }

        }
        # Done
    }
    
    End {
        # Sort Results            ?ERROR: $res = $res | Sort-Object EntryTime -Descending:!($Acending)
        ##if( $Ascending ) { $res = $res | Sort-Object Sort-Object -Property @{Expression="EntryTime"; Descending=$false}, @{Expression="LogIndex"; Descending=$false} }
        ##else             { $res = $res | Sort-Object Sort-Object -Property @{Expression="EntryTime"; Descending=$true}, @{Expression="LogIndex"; Descending=$true} }
        $desc = !$Ascending
        $res = $res | Sort-Object -Property @{Expression="EntryTime"; Descending=$desc}, @{Expression="LogIndex"; Descending=$desc}
        
        # Write Pipeline
        Write-Output $res

        # Cue User
        Write-Verbose "Done: $($PSCmdlet.ParameterSetName), '$($res.Count)' events found."
    }  
}
# help Get-LocalEventInfo -ShowWindow

<# 
.Synopsis
    Gets Events from the known EventLogs
.Description
    Queries for and collates Events generated after the last system startup, in the last N minutes, 
    [After|Before] a [Date-]Time or Between two [Date-]Times
.Example
    Get-EventInfo | Format-EventInfoTable or gev | fet
    Collates Error and Warning Events in all EventLogs generated in the last 60 minutes
.Example
    gev -AfterStartup -Ascending | fet
    Collates Error and Warning Events, ascending in time, Events generated after the last time the 
    Machine was Woken or Booted
.Example
    gev -Between (Get-LastStartupTime).AddMinutes( -5 ), (Get-LastStartupTime).AddMinutes( 5 ) -Ascending -ShowInformation | fet
    Collates, ascending in time, all Events generated in the 10 minutes around the last time the Machine was started
.Example
    gev -AfterStartup -Ascending | Select-Object -First 10 | fet
    Collates, ascending in time, the first 10 Error and Warning Events generated after the last time 
    the Machine was Woken or Booted
.Example
    gev -AfterStartup -HideWarnings -Ascending | Where-Object Source -NotIn 'COM', 'DCOM' | fet
    Collates, ascending in time, Error Events whose Source is not 'COM' or 'DCOM' and generated after 
    the last time the Machine was started
.Example
    Get-EventInfo -Between 09:00,17:00 | fet
    Collates Error and Warning Events generated today between 9am and 5pm
.Notes
    Todo: -ExcludeSource -ExcludeEventId
#>
Function Get-EventInfo() {
    
    [CmdletBinding( DefaultParameterSetName='LastMinutes' )]
    [Alias( 'gev' )]
    [OutputType([object[]])]
    Param(
        # Show Events generated in the last N minutes (default: 60 minutes)
        [Parameter( ParameterSetName='LastMinutes', Mandatory=$false, Position=3 )]
        [int]$LastMinutes = 60,

        # Show Events generated after last Startup
        [Parameter( ParameterSetName='AfterStartup', Mandatory=$true, Position=3 )]
        [Switch]$AfterStartup = $false,

        # Show Events generated after last Startup
        [Parameter( ParameterSetName='AnyTime', Mandatory=$true, Position=3 )]
        [Switch]$AnyTime = $false,

        # Show Events generated after the [Date-]Time
        [Parameter( ParameterSetName='After', Mandatory=$true, Position=3 )]
        [DateTime]$After,

        # Show Events generated before the [Date-]Time
        [Parameter( ParameterSetName='Before', Mandatory=$true, Position=3 )]
        [DateTime]$Before,

        # Show Events generated between two [Date-]Times
        [Parameter( ParameterSetName='Between', Mandatory=$true, Position=3 )]
        [ValidateCount( 2, 2 )]
        [DateTime[]]$Between,

        # Show Events generated between two [Date-]Times - ParameterSetName='AllLogs', 
        [Parameter( Mandatory=$false, Position=4 )]
        [Switch]$AllLogs,

        # The name(s) of the EventLogs to search - Accepts WildCards
        [Parameter( Mandatory=$false, Position=4 )]
        [ValidateNotNull()]
        [string[]]$LogName = ( 'System', 'Application' ),

        # The name of the Source to search for - Accepts WildCards
        [Parameter( Mandatory=$false )]
        [ValidateNotNull()]
        [string]$Source = '*',

        # The EventId of the event to search for
        [Parameter( Mandatory=$false )]
        [AllowNull()]
        [Int[]]$EventId = $null,

        # Hide Events typed Error, FailureAudit
        [Parameter( Mandatory=$false )]
        [Switch]$HideErrors,

        # Hide Events typed Warning
        [Parameter( Mandatory=$false )]
        [Switch]$HideWarnings,

        # Show Events typed Information, SuccessAudit
        [Parameter( Mandatory=$false )]
        [Switch]$ShowInformation,

        # Show Events in the 'Security' log (requires Administrator right)
        [Parameter( Mandatory=$false )]
        [Switch]$ShowSecurity,

        # Sort EntryTime Ascending
        [Parameter( Mandatory=$false )]
        [Switch]$Ascending,

        # The NickName(s) to show, accepts Wildcards
        [Parameter( Mandatory=$false )]
        [string[]]$NickName = '*',
        
        # To which Depth to include Remoting WitSession(s)
        # Warning: works as -Recurse when -gt 0
        [Parameter( Mandatory=$false )]
        [uint16]$Depth = 1,

        # The NickName(s) to show for remotes
        [Parameter( Mandatory=$false )]
        [string]$LocalNickName = '.'
        
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
                $res += Get-LocalEventInfo -LastMinutes:$LastMinutes `
                                           -ShowInformation:$ShowInformation `
                                           -LocalNickName:$LocalNickName
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
                        $jobs += Invoke-Command -Session $s { gev -NickName '*' -Depth $Using:rdp `
                                                                  -LastMinutes:$Using:LastMinutes `
                                                                  -ShowInformation:$Using:ShowInformation `
                                                                  -LocalNickName:$Using:rnn `
                                 } -AsJob -JobName "WitJob_$rnn )"
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
            if( $r -ne $null) {
                $r.PSTypeNames.Insert( 0, 'Wit.EventInfoClass' )
            }
        }

        # Write to Pipeline
        Write-Output $res
    }
}
# help Get-EventInfo -ShowWindow

<# 
.Synopsis
    Formats EventInfoClass inout into a table
#>
<#
    Obsolete therefor hidden

Function Format-EventInfoTable() {
    [Alias( 'fet' )]
    Param(
        # Generic Input 
        [Parameter( Mandatory=$false, ValueFromPipeline=$true )]
        $input,

        # Show the Month and Day
        [Parameter( Mandatory=$false )]
        [Switch]$ShowDate
    )

    # Go
    if( $ShowDate ) {
        $input | select @{n='NN';e={$_.NickName}}, @{n='Machine';e={$_.MachineName}}, @{n='EntryTime';e={$_.EntryTime.ToString( 'MMM d, HH:mm:ss')}}, * `
                        -ExcludeProperty PSComputerName, RunspaceId, PSSourceJobInstanceId, NickName, MachineName, EntryTime | ft
    }
    else {
        $input | select @{n='NN';e={$_.NickName}}, @{n='Machine';e={$_.MachineName}}, @{n='EntryTime';e={$_.EntryTime.ToString( 'HH:mm:ss')}}, * `
                        -ExcludeProperty PSComputerName, RunspaceId, PSSourceJobInstanceId, NickName, MachineName, EntryTime | ft
    }
}
#>

# EOS