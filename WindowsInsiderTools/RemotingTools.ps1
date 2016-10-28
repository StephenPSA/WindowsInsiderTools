##=================================================================================================
# File    : RemotingTools.ps1
# Author  : StephenPSA
# Version : 0.0.3.1
# Date    : Oct, 2016
#
# Todo    :
#           Get-WitCredential    - preload Credential (option -Path)
#           Export-WitCredential - todo -Path
#           gwit | rwit - To remove all WitSession_xxx sessions
##-------------------------------------------------------------------------------------------------
using namespace System.Management.Automation
using namespace System.Management.Automation.Runspaces

<#
.Synopsis
   Gets a list of current WindowsInsiderTools Sessions
#>
Function Get-WitSession {
    [CmdletBinding()]
    [Alias( 'gwit' )]
    [OutputType( [System.Management.Automation.Runspaces.PSSession[]] )]
    Param(
        # The NickName of the imported session to find - Accepts Wildcards
        [Parameter( Mandatory=$false, ValueFromPipeline=$true, Position=0 )]
        [string]$NickName = '*'
    )

    Begin {
    }

    Process {
        # Session
        [PSSession[]]$session = Get-PSSession | Where-Object Name -Like "WitSession_$($NickName)"
        if( $session -eq $null ) {
            Write-Warning "No Session(s) named: WitSession_$($NickName) found"
        }
        else {
            Write-Output $session
        }
    }

    End {
    }
}

<#
.Synopsis
   Enables implicit remoting of the WindowsInsiderTools module on a Computer
.Description
   Maps all functions in the WindowsInsiderTools module on a remote machine to local Cmdlets
.Example
   Import-RemoteWindowsInsiderTools -ComputerName TABLETPSA -NickName tab 
.Example
   iwit TABLETPSA tab
#>
Function New-WitSession {
    [Alias( 'nwit' )]
    [CmdletBinding( SupportsShouldProcess=$true, 
                    PositionalBinding=$true,
                    ConfirmImpact='Medium' )]
    [OutputType( [System.Management.Automation.Runspaces.PSSession] )]
    Param(
        # The ComputerName to connect to
        [Parameter( Mandatory=$true, Position=0 )]
        [string]$ComputerName,

        # The WitSession's NickName value
        [Parameter( Mandatory=$true, Position=1 )]
        [string]$NickName,

        # Ask for Credentials even if Credentials where entered before
        [Parameter( Mandatory=$false, Position=2 )]
        [Switch]$AskCredential,

        # The PSCredential to use, 
        [Parameter( Mandatory=$false, Position=3 )]
        [PSCredential]$Credential
    )
    
    Begin {
        # vars
        [PSSession]$ses
    }

    Process {
        # Check for -WhatIf
        if( $WhatIfPreference.IsPresent ) {
            Write-Host "If -WhatIf is not specified, this command will:" -ForegroundColor Yellow
            Write-Host "    If needed or opted by -AskCredential, ask for Credentials for access to $ComputerName" -ForegroundColor Yellow
            Write-Host "    Create a PSSession to connect to $ComputerName" -ForegroundColor Yellow
            Write-Host "    Import the WindowsInsiderTools Module on $ComputerName for implicit use, i.e. Get-$($NickName)EventInfo" -ForegroundColor Yellow
            return
        }

        # Check Should Process
        if( !$PSCmdlet.ShouldProcess( $ComputerName, "Connect to $ComputerName and set-up a WitSession", "New-WitSession - Remote Windows Insider Tools" ) ) {
            return
        }

        # Get new Credential if needed or wanted
        if( $Credential -eq $null -and !$AskCredential ) { 
            # Check for saved Credential
            Write-Verbose "Getting existing Credential for connecting to $ComputerName..."
            # A separate Credential for Each computer: $Credential = Get-Variable -Name "$($ComputerName)_Credential" -ValueOnly
            # A common Credential for all computers: 
            $Credential = Get-Variable -Name "wit_Credential" -ValueOnly -Scope Script -ErrorAction SilentlyContinue
        }
        if( $Credential -eq $null -or $AskCredential ) {
            # Get a new Credential
            Write-Verbose "Getting Credential to connect to $ComputerName..."
            $Credential = Get-Credential -Message "Enter Credentials for $ComputerName..."
        }
        if( $Credential -eq $null ) { 
            Write-Verbose "Cancelled"
            return 
        }
        else {
            # Store Credential for reuse
            Write-Verbose "Storing Credential: $($Credential.UserName) for connecting to $ComputerName..."
            # A separate Credential for Each computer: New-Variable -Name "$($ComputerName)_Credential" -Value $Credential -Scope Script -Force
            # A common Credential for all computers: 
            New-Variable -Name "wit_Credential" -Value $Credential -Scope Script -Force
        }

        # New PSSession
        Write-Verbose "Starting a new PSSession on $ComputerName..."
        $ses = New-PSSession -ComputerName $ComputerName -Credential $Credential -Name "WitSession_$NickName" -ErrorAction SilentlyContinue
        if( $ses -eq $null ) { 
            Write-Error "Failed to create a new PSSession on $ComputerName, using Credential: $($Credential.UserName)"
            return 
        }
        # Report Session
        else {
            Write-Verbose "New PSSession:'$($ses.Name)', Id:'$($ses.Id)' created for Machine:'$ComputerName'"
        }

        # Import Implicit Remoting
        Write-Verbose "Configuring WindowsInsiderTools Commands for WitSession on: '$ComputerName'..."
        #### OLD # # ------ DOES NOT WORK? : $tmpmod = Get-Module -Name WindowsInsiderTools -PSSession $ses
        #### OLD # #$tmpmod = Import-PSSession -Session $ses -Prefix "wit_$Prefix" -AllowClobber -Module WindowsInsiderTools -Verbose:$false

        # Import into Script Context allowing Clobber (or else we would need to force close a prior Session)
        Invoke-Command -Session $ses { Import-Module WindowsInsiderTools }
        $tmpmod = Invoke-Command -Session $ses { Get-Module WindowsInsiderTools }

        # Verify
        if( $tmpmod -eq $null ) {
            Write-Error "The WindowsInsiderTools module is not present on $ComputerName"
            return
        }

        # Usefull for -Alias/NickName parameter?
        #if( $false ) {
        #    # Filter to hide Remote Remoting
        #    $as = $tmpmod.ExportedAliases.Values | Where-Object { $_ -NotLike '*wit' }
        #    $fs = $tmpmod.ExportedFunctions.Values | Where-Object { $_ -NotLike '*Remote*' }
        #
        #    # Import into Global Context, should NOT AllowClobber
        #    $m = Import-Module -Name WindowsInsiderTools -PSSession $ses -Function $fs -Alias $as -Prefix $NickName -NoClobber -Global
        #}

        # Report Import
        Write-Verbose "WitSession, version:'$($tmpmod.Version)', for Machine:'$ComputerName', NickName:'$NickName' is ready"

        # BULL ewit should accept a WitSession # Output the Prefix on the Pipeline for | ewit
        # BULL ewit should accept a WitSession #Write-Output $Prefix

        # EOProcess
    }

    End {
        # Write Pipeline
        Write-Output $ses
    }
}

<#
.Synopsis
   Removes the imported WindowsInsiderTools Module and accompanying Session
#>
Function Remove-WitSession {
    [CmdletBinding()]
    [Alias( 'rwit' )]
    Param(
        # The NickName of the Commands that will be removed
        [Parameter( Mandatory=$true, ValueFromPipeline=$true, Position=0 )]
        [string]$NickName
    )

    Begin {
    }

    Process {
        # vars
        $module = Get-Module | Where-Object Prefix -EQ $NickName
        $session = Get-PSSession | Where-Object Name -EQ "WitSession_$NickName"

        # Module
        # - a copy of the temp module is left in 'C:\Users\psaso\AppData\Local\Temp'. Needs cleanup?
        if( $module -ne $null ) {
            Write-Host "Removing Module : $($module.Name) for machine: $($session.ComputerName), Prefix: $Prefix" -ForegroundColor Cyan
            Remove-Module $module 
        }
        # Session
        if( $session -ne $null ) {
            Write-Host "Removing Session: $($session.Name) for machine: $($session.ComputerName), NickName $Prefix" -ForegroundColor Cyan
            Remove-PSSession $session
        }
    }

    End {
    }
}

<#
.Synopsis
   Enables implicit remoting of the WindowsInsiderTools module on a Computer
.Description
   Maps all functions in the WindowsInsiderTools module on a remote machine to local Cmdlets
.Example
   Import-RemoteWindowsInsiderTools -ComputerName TABLETPSA -Prefix tab 
.Example
   iwit TABLETPSA tab
#>
Function Import-WitSession {
    [Alias( 'iwit' )]
    [CmdletBinding( SupportsShouldProcess=$true, 
                    PositionalBinding=$true,
                    ConfirmImpact='High' )]
    [OutputType( [string] )]
    Param(
        # The ComputerName to connect to
        [Parameter( Mandatory=$true, Position=0 )]
        [string]$ComputerName,

        # The function noun prefix value
        [Parameter( Mandatory=$true, Position=1 )]
        [string]$Prefix
    )
    
    Begin {}

    Process {
        # Check for -WhatIf
        if( $WhatIfPreference.IsPresent ) {
            Write-Host "If -WhatIf is not specified, this command will:" -ForegroundColor Yellow
            Write-Host "    If needed or opted by -AskCredential, ask for Credentials for access to $ComputerName" -ForegroundColor Yellow
            Write-Host "    Create a PSSession to connect to $ComputerName" -ForegroundColor Yellow
            Write-Host "    Import the WindowsInsiderTools Module on $ComputerName for implicit use, i.e. Get-$($Prefix)EventInfo" -ForegroundColor Yellow
            return
        }

        # Check Should Process
        if( !$PSCmdlet.ShouldProcess( $ComputerName, "OBS - Connect to $ComputerName and import the WindowsInsiderTools Module", "OBS - Import Remote Windows Insider Tools" ) ) {
            return
        }

        # OLD CODE
        if( $false ) {
        # Get new Credential if needed or wanted
        if( $Credential -eq $null -and !$AskCredential ) { 
            # Check for saved Credential
            Write-Verbose "Getting existing Credential for connecting to $ComputerName..."
            # A separate Credential for Each computer: $Credential = Get-Variable -Name "$($ComputerName)_Credential" -ValueOnly
            # A common Credential for all computers: 
            $Credential = Get-Variable -Name "wit_Credential" -ValueOnly -Scope Script -ErrorAction SilentlyContinue
        }
        if( $Credential -eq $null -or $AskCredential ) {
            # Get a new Credential
            Write-Verbose "Getting Credential to connect to $ComputerName..."
            $Credential = Get-Credential -Message "Enter Credentials for $ComputerName..."
        }
        if( $Credential -eq $null ) { 
            Write-Verbose "Cancelled"
            return 
        }
        else {
            # Store Credential for reuse
            Write-Verbose "Storing Credential: $($Credential.UserName) for connecting to $ComputerName..."
            # A separate Credential for Each computer: New-Variable -Name "$($ComputerName)_Credential" -Value $Credential -Scope Script -Force
            # A common Credential for all computers: 
            New-Variable -Name "wit_Credential" -Value $Credential -Scope Script -Force
        }

        # New PSSession
        Write-Verbose "Starting a new PSSession on $ComputerName..."
        $ses = New-PSSession -ComputerName $ComputerName -Credential $Credential -Name "WitSession_$Prefix" -ErrorAction SilentlyContinue
        if( $ses -eq $null ) { 
            Write-Error "Failed to create a new PSSession on $ComputerName, using Credential: $($Credential.UserName)"
            return 
        }
        # Report Session
        else {
            Write-Host "New PSSession:'$($ses.Name)', Id:'$($ses.Id)' created for Machine:'$ComputerName'"
        }

        # Import Implicit Remoting
        Write-Verbose "Importing WindowsInsiderTools Commands for $ComputerName, with NickName $Prefix..."
        #### OLD # # ------ DOES NOT WORK? : $tmpmod = Get-Module -Name WindowsInsiderTools -PSSession $ses
        #### OLD # #$tmpmod = Import-PSSession -Session $ses -Prefix "wit_$Prefix" -AllowClobber -Module WindowsInsiderTools -Verbose:$false

        # Import into Script Context allowing Clobber (or else we would need to force close a prior Session)
        Invoke-Command -Session $ses { Import-Module WindowsInsiderTools }

        }

        # Contract
        if( $ses -eq $null) { 
            
            return 
        }

        # 
        $tmpmod = Invoke-Command -Session $ses { Get-Module WindowsInsiderTools }

        # Verify
        if( $tmpmod -eq $null ) {
            Write-Error "The WindowsInsiderTools module is not present on $ComputerName"
            return
        }

        # Filter to hide Remote Remoting
        $as = $tmpmod.ExportedAliases.Values   # | Where-Object { $_ -NotLike '*wit' }
        $fs = $tmpmod.ExportedFunctions.Values # | Where-Object { $_ -NotLike '*Remote*' }
        
        # Import into Global Context, should NOT AllowClobber
        $m = Import-Module -Name WindowsInsiderTools -PSSession $ses -Function $fs -Alias $as -Prefix $Prefix -NoClobber -Global

        # Report Import
        Write-Host "WindowsInsiderTools Module, version:'$($tmpmod.Version)', imported for Machine:'$ComputerName', Prefix:'$Prefix'"

        # EOProcess
    }

    End {
        # Output the Prefix on the Pipeline for | ewit
        Write-Output $Prefix
    }
}

<#
.Synopsis
   Removes the imported WindowsInsiderTools Module and accompanying Session
Function Remove-RemoteWindowsInsiderTools {
    [CmdletBinding()]
    [Alias( 'rwit' )]
    Param(
        # The Prefix of the Commands that will be removed
        [Parameter( Mandatory=$true, ValueFromPipeline=$true, Position=0 )]
        [string]$Prefix
    )

    Begin {
    }

    Process {
        # vars
        $module = Get-Module | Where-Object Prefix -EQ $Prefix
        $session = Get-PSSession | Where-Object Name -EQ "WIT_Session_$Prefix"

        # Module
        # - a copy of the temp module is left in 'C:\Users\psaso\AppData\Local\Temp'. Needs cleanup?
        if( $module -ne $null ) {
            Write-Host "Removing Module : $($module.Name) for machine: $($session.ComputerName), Prefix: $Prefix" -ForegroundColor Cyan
            Remove-Module $module 
        }
        # Session
        if( $session -ne $null ) {
            Write-Host "Removing Session: $($session.Name) for machine: $($session.ComputerName), Prefix: $Prefix" -ForegroundColor Cyan
            Remove-PSSession $session
        }
    }

    End {
    }
}
#>

<#
.Synopsis
   Enters a WitSession
#>
Function Enter-WitSession {
    [CmdletBinding()]
    [Alias( 'ewit' )]
    Param(
        # The Prefix of the imported session to enter
        [Parameter( Mandatory=$true, ValueFromPipeline=$true, Position=0 )]
        [string]$Prefix
    )

    Begin {
    }

    Process {
        # Session
        $session = Get-PSSession | Where-Object Name -EQ "WitSession_$Prefix"
        if( $session -eq $null ) {
            Write-Warning "No Session named: WitSession_$Prefix found"
        }
        else {
            Write-Host "Entering Session: $($session.Name)" -ForegroundColor Cyan
            Enter-PSSession $session
        }
    }

    End {
    }
}

<#
.Synopsis
   Enables implicit remoting of the WindowsInsiderTools module on a Computer
.Description
   Maps all functions in the WindowsInsiderTools module on a remote machine to local Cmdlets
.Example
   Import-RemoteWindowsInsiderTools -ComputerName TABLETPSA -Prefix tab 
.Example
   xwit TABLETPSA tab
#>
Function Export-RemoteWindowsInsiderToolsModule {
    [Alias( 'xwit' )]
    [CmdletBinding( SupportsShouldProcess=$true, 
                    PositionalBinding=$true,
                    ConfirmImpact='High' )]
    [OutputType( [string] )]
    Param(
        # The ComputerName to connect to
        [Parameter( Mandatory=$true, Position=0 )]
        [string]$ComputerName,

        # The function noun prefix value
        [Parameter( Mandatory=$true, Position=1 )]
        [string]$Prefix,

        # Ask for Credentials even if Credentials where entered before
        [Parameter( Mandatory=$false, Position=2 )]
        [Switch]$AskCredential,

        # The PSCredential to use, 
        [Parameter( Mandatory=$false, Position=3 )]
        [System.Management.Automation.PSCredential]$Credential
    )
    
    Begin {}

    Process {
        # Check for -WhatIf
        if( $WhatIfPreference.IsPresent ) {
            Write-Host "If -WhatIf is not specified, this command will:" -ForegroundColor Yellow
            Write-Host "    If needed or opted by -AskCredential, ask for Credentials for access to $ComputerName" -ForegroundColor Yellow
            Write-Host "    Create a PSSession to connect to $ComputerName" -ForegroundColor Yellow
            Write-Host "    Export an implicit remoting WindowsInsiderTools Module for $ComputerName using Prefix $Prefix, i.e. Get-$($Prefix)EventInfo" -ForegroundColor Yellow
            return
        }

        # Check Should Process
        if( !$PSCmdlet.ShouldProcess( $ComputerName, "Connect to $ComputerName and export the remoting WindowsInsiderTools Module using Prefix $Prefix", "Export Remote WindowsInsiderTools Module" ) ) {
            return
        }

        # Get new Credential if needed or wanted
        if( $Credential -eq $null -and !$AskCredential ) { 
            # Check for saved Credential
            Write-Verbose "Getting existing Credential for connecting to $ComputerName..."
            # A separate Credential for Each computer: $Credential = Get-Variable -Name "$($ComputerName)_Credential" -ValueOnly
            # A common Credential for all computers: 
            $Credential = Get-Variable -Name "wit_Credential" -ValueOnly -Scope Script -ErrorAction SilentlyContinue
        }
        if( $Credential -eq $null -or $AskCredential ) {
            # Get a new Credential
            Write-Verbose "Getting Credential to connect to $ComputerName..."
            $Credential = Get-Credential -Message "Enter Credentials for $ComputerName..."
        }
        if( $Credential -eq $null ) { 
            Write-Verbose "Cancelled"
            return 
        }
        else {
            # Store Credential for reuse
            Write-Verbose "Storing Credential: $($Credential.UserName) for connecting to $ComputerName..."
            # A separate Credential for Each computer: New-Variable -Name "$($ComputerName)_Credential" -Value $Credential -Scope Script -Force
            # A common Credential for all computers: 
            New-Variable -Name "wit_Credential" -Value $Credential -Scope Script -Force
        }

        # New PSSession
        Write-Verbose "Starting a new PSSession on $ComputerName..."
        $ses = New-PSSession -ComputerName $ComputerName -Credential $Credential -Name "WitSession_$Prefix" -ErrorAction SilentlyContinue
        if( $ses -eq $null ) { 
            Write-Error "Failed to create a new PSSession on $ComputerName, using Credential: $($Credential.UserName)"
            return 
        }
        # Report Session
        else {
            Write-Host "A new PSSession named: $($ses.Name), Id: $($ses.Id) was created for machine $ComputerName"
        }

        # Export Implicit Remoting
        Write-Verbose "Importing WindowsInsiderTools Commands for $ComputerName, with Prefix: $Prefix..."
        #### OLD # # ------ DOES NOT WORK? : $tmpmod = Get-Module -Name WindowsInsiderTools -PSSession $ses
        #### OLD # #$tmpmod = Import-PSSession -Session $ses -Prefix "wit_$Prefix" -AllowClobber -Module WindowsInsiderTools -Verbose:$false

        # Import into Script Context allowing Clobber (or else we would need to force close a prior Session)
        #Invoke-Command -Session $ses { Import-Module WindowsInsiderTools -Prefix $Local:Prefix }
        Invoke-Command -Session $ses { Import-Module WindowsInsiderTools }
        $tmpmod = Invoke-Command -Session $ses { Get-Module WindowsInsiderTools }

        # Verify
        if( $tmpmod -eq $null ) {
            Write-Error "The WindowsInsiderTools module is not present on $ComputerName"
            return
        }

        # Filter to hide Remote Remoting
        $fs = $tmpmod.ExportedFunctions.Values | Where-Object { $_ -NotLike '*Remote*' }
        
        # Import into Global Context, should NOT AllowClobber
        Export-PSSession -Session $ses -Module WindowsInsiderTools -CommandName $fs -OutputModule "WindowsInsiderTools_$($ComputerName)_$($Prefix)" -AllowClobber -Force
        #    Import-Module $tmpmod -Function $fs -Alias $as -Prefix $Prefix -NoClobber -Global

        # Report Import
        Write-Verbose "Remoting WindowsInsiderTools Module for $ComputerName, with Prefix: $Prefix exported"

        # Import the new Module
        Import-Module "WindowsInsiderTools_$($ComputerName)_$($Prefix)" -Prefix $Prefix -Global

        # Import Aliases
        $as = $tmpmod.ExportedAliases.Values | Where-Object { $_ -NotLike '*wit' }
        $al = Invoke-Command -Session $ses { Get-Alias }
        foreach( $a in $as ) {
            $cm = $al | Where-Object Name -eq $a
            $cm = [string]::Join( "-tab", ( $cm.ResolvedCommand.Split( "-" ) ) )
            Write-Verbose "Mapping alias: $($Prefix)$($a) -> $($cm) ?" 
            New-Alias -Name "$($Prefix)$($a)" -Value $cm -Scope Global
        }

        # Output the Prefix on the Pipeline for | ewit
        Write-Output $Prefix

        # EOProcess
    }

    End {}
}

# EOS