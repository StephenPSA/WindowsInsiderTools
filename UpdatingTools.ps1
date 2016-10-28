##=================================================================================================
# File    : UpdatingTools.psm1
# Author  : StephenPSA
# Version : 0.0.5.6
# Date    : Oct, 2016, II
#
# Publish, Distribute
#
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

$WitModulePath = "$HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools"
$WitGitHub = "$HOME\Documents\GitHub\WindowsInsiderTools\WindowsInsiderTools"
$WitCanary = "S:\PSA_Sync\WindowsPowerShell\Modules\WindowsInsiderTools"

<#
.Synopsis
    Returns the '\WindowsInsiderTools.psd1' version
 #>
Function Get-WitModuleVersion() {
    [CmdletBinding( DefaultParameterSetName='Imported' )]
    [Alias( 'gwv' )]
    Param(
        # Get the Workspace Version
        [Parameter( ParameterSetName='Workspace', Mandatory=$true, Position=0 )]
        [Switch]$Workspace,

        # Get the Imported Version
        [Parameter( ParameterSetName='Imported', Mandatory=$false, Position=0 )]
        [Switch]$Imported,

        # Get the GitHub (local) Version
        [Parameter( ParameterSetName='GitHub', Mandatory=$true, Position=0 )]
        [Switch]$GitHub,

        # Get the Canary Version
        [Parameter( ParameterSetName='Canary', Mandatory=$true, Position=0 )]
        [Switch]$Canary,

        # Get the Version at
        [Parameter( ParameterSetName='Path', Mandatory=$false )]
        [string]$Path = "."

    )

    Begin { }

    Process {
        # Go
        try {
            # Module by ParameterSet
            switch ( $PSCmdlet.ParameterSetName ) {
                'Imported'     { $m = Get-Module -Name 'WindowsInsiderTools' }
                'Workspace'    { $m = Test-ModuleManifest "$WitModulePath\WindowsInsiderTools.psd1" }
                'GitHub'       { $m = Test-ModuleManifest     "$WitGitHub\WindowsInsiderTools.psd1" }
                'Canary'       { $m = Test-ModuleManifest     "$WitCanary\WindowsInsiderTools.psd1" }
                'Path'         { $m = Test-ModuleManifest          "$Path\WindowsInsiderTools.psd1" }
            }
                            
            # $m = Test-ModuleManifest $pth -ErrorAction SilentlyContinue
            return $m.Version
        }
        catch {
            return $null
        }    
    }

    End {}
}

<#
.Synopsis
    Unconditionally Imports Version updates    
#>
Function Update-WindowsInsiderTools {
    [CmdletBinding()]
    [Alias( 'uwit' )]
    Param(
        # Overwrite current Module unconditinally
        [Switch]$Force
    )

    Begin {
        # Install WindowsInsiderTools
        $dist = "S:\PSA_Sync\WindowsPowerShell\Modules\WindowsInsiderTools"
        $modp = "$HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools"
        # Check needed
        $vd = Get-WitModuleVersion -Canary
        $vi = Get-WitModuleVersion -Imported
        $Force = $Force -or ($vd -gt $vi)
    }

    Process {
    }

    End {
        # if needed, Go
        if( !$Force ) {
            # Cue User
            Write-Verbose "No Update needed"
        }
        else {
            # Cue User
            Write-Verbose "Updating WIT to: $vd (public) from: $vi (imported)..."
            Write-Verbose "Collecting files..."
            $fs = Get-ChildItem -Path $dist -Recurse
            # Cue User
            Write-Verbose "Copying files..."
            $fs | Copy-Item -Destination $modp
            # Reset
            Reset-WindowsInsiderTools
        }
    } 

}

<#
.Synopsis
    Unconditionally Distributes Version updates    
#>
Function Publish-WindowsInsiderTools {
    [CmdletBinding()]
    [Alias( 'pwit' )]
    Param()

    Begin {
        # Canary locations - WindowsInsiderTools
        $modp = "$HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools"
        $hist = "S:\PSA_Sync\WindowsPowerShell"
        $dist = "S:\PSA_Sync\WindowsPowerShell\Modules\WindowsInsiderTools"
    }

    Process {
        $curl = Get-Location
        Write-Verbose "Collecting files..."

        Set-Location $modp
        $fs = Get-ChildItem -Recurse

        Write-Verbose "Saving Version..."
        Set-Location $hist
        $cv = (Get-WitModuleVersion -Workspace).ToString().Replace( '.', '_' )
        $hl = mkdir "WIT_$cv"
        $fs | Copy-Item -Destination $hl -Force
        Write-Host "A Backup named: '$($hl.Name)' was made in '$hist'"

        Write-Verbose "Distributing Version..."
        Set-Location $dist
        $fs | Copy-Item -Destination .
        Write-Host "WindowsInsiderTools version: '$(Get-WitModuleVersion -Workspace)' was published in '$dist'"

        Set-Location $curl
        Write-Verbose "Done"
    }

    End {
    } 

}

<#
.Synopsis
    Removes and Reloads the WindowsInsiderModule from the Workspace
#>
Function Reset-WindowsInsiderTools {
    [CmdletBinding()]
    Param()

    Begin {
        # Cue Verbose
        Write-Verbose "Reset-WindowsInsiderTools - Resetting Module WindowsInsiderTools..."
    }

    Process {
        # Cue User
        Write-Host "Removing Version: '$(Get-WitModuleVersion -Imported)'..."
        Remove-Module 'WindowsInsiderTools' -ErrorAction SilentlyContinue
        Write-Host "Importing Version: '$(Get-WitModuleVersion -Workspace)'..."
        Import-Module 'WindowsInsiderTools'
    }

    End {
        # Cue Verbose
        Write-Verbose "Reset-WindowsInsiderTools - Done"
    } 

}

<#
.Synopsis
    For WindowsInsiderTools Developers only
#>
Function Show-Workspace {
    [CmdletBinding()]
    [Alias( 'sws' )]
    Param()

    Begin {
    }

    Process {
        # Checkin Test
        Write-Host "CHANGED!!!!!" -ForegroundColor Red
        # Cue User
        Write-Host "Workspace: '$(Get-WitModuleVersion -Workspace)'..."
        Write-Host "Imported : '$(Get-WitModuleVersion -Imported)'..."
        #Write-Host "GitHub   : '$(Get-WitModuleVersion -GitHub)'..."
        Write-Host "Canary   : '$(Get-WitModuleVersion -Canary)'..."
    }

    End {
    } 

}
