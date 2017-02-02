##=================================================================================================
# File    : W10-15019-Desktop-Metrics-StandAlone.ps1
# Author  : StephenPSA
# Version : 0.0.0.3
# Date    : Feb, 2017
#
# - Change 'Advanced Display Settings' 
# - A workaround powershell script for Build 10.0.15019.1000
#
# PLEASE NOTE: You use this script at your own risk, the author will not accept any responsibility
#              for any result from using it.
#
##-------------------------------------------------------------------------------------------------
# Defines Enums, Classes and Functions
#     [Enums] DesktopMetric
#   [Classes] DesktopMetricFontClass
# [Functions] Get-DesktopMetric, Set-DesktopMetric
##-------------------------------------------------------------------------------------------------
## Also thanks to 
#
# Willy Denoyette, Windows Insider, for...
#
#     $key="HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
#     $size = 12
#     $val = (Get-Itemproperty -Path Registry::$Key ).IconFont
#     $val[0]= 256 - $size
#     Set-Itemproperty -Path Registry::$Key -Name IconFont -Value $val
#
# Slance310, Windows Insider, for voluterring to test...
#
# Cal54, Shilohbob, etc, etc, for providing this and that...
#
##=================================================================================================
#requires -Version 5.0

# Enum - 
Enum DesktopMetric {
    None
    All
    CaptionFont
    SmCaptionFont
    IconFont
    MenuFont
    MessageFont
    StatusFont
}

# Class - 
Class DesktopMetricFontClass {

    # Constructor
    DesktopMetricFontClass ( [DesktopMetric]$Metric )  {
        # Contract
        if( $Metric -eq [DesktopMetric]::All ) {
            throw [System.Exception]::new( "'All' is not allowed here" )
        }
        if( $Metric -eq [DesktopMetric]::None ) {
            throw [System.Exception]::new( "'None' is not allowed here" )
        }
        # Store params
        $this.Metric = $Metric;
        # vars
        if( $Metric -ne [DesktopMetric]::None ) {
            # Get Raw State
            $this.ReadRegistry()
            # Store Original State
            $this.originalData = $this.rawData
            # Calc Properties
            $this.Size = 256 - ($this.rawData[0])
        }
    }

    # Public Fields
    [DesktopMetric]$Metric
    [int]$Size

    # Private Fields
    hidden [Byte[]]$rawData
    hidden [Byte[]]$originalData
    
    # Method
    [void]ApplyChanges() {
        # Validate FontSize
        if( $this.Size -lt 6 ) { $this.Size = 6 }
        if( $this.Size -gt 20 ) { $this.Size = 20 }
        # FontSize
        $this.rawData[0] = (256 - $this.Size)
        #- Write to registry
        $this.WriteRegistry()
    }
    
    # Method
    [void]Revert() {
        # FontSize
        $this.rawData = $this.originalData
        #- Write to Registry
        $this.WriteRegistry()
        #- Read again from Registry
        $this.ReadRegistry()
    }
    
    # Method
    [void]RevertToOOTB() {
        # Default FontSize
        $this.Size = 12
        #- Write to Registry
        $this.WriteRegistry()
        #- Read again from Registry
        $this.ReadRegistry()
    }
    
    # Internal
    hidden [void]ReadRegistry() {
        # vars
        $res = $null
        $key = "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
        # Read OS Registry
        $val = Get-Itemproperty -Path Registry::$Key
        # Select Field
        switch ( $this.Metric ) {
           CaptionFont { $res = $val.CaptionFont } 
           SmCaptionFont { $res = $val.SmCaptionFont } 
           IconFont { $res = $val.IconFont } 
           MenuFont { $res = $val.MenuFont } 
           MessageFont { $res = $val.MessageFont } 
           StatusFont { $res = $val.StatusFont } 
        }
        # Store
        $this.rawData = $res
        # Done
    }

    # Internal - Write OS Registry
    hidden [void]WriteRegistry() {
        # vars
        $key = "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
        # WRITE
        Set-Itemproperty -Path Registry::$Key -Name $this.Metric -Value $this.rawData 
        # Done
    }

}

<#
.SYNOPSIS
    Reports the current Desktop Metric values
.DESCRIPTION
    Reports the current Desktop Metric values as stored in the Registry under key:
    HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics
.EXAMPLE
    Get-DesktopMetric or gdm
                     or
    gdm
.EXAMPLE
    Get-DesktopMetric -Metric Caption, Menu
                     or
    gdm Caption, Menu
#>
Function Get-DesktopMetric() {
    [Alias( 'gdm' )]
    Param(
        # The Name of the field
        [Parameter( Mandatory=$false, Position=0 )]
        [DesktopMetric[]]$Metric = [DesktopMetric]::All
    )

    Begin {
        # Automate 'specials'
        if( $Metric -eq [DesktopMetric]::All ) { 
            $Metric =  [DesktopMetric]::CaptionFont
            $Metric += [DesktopMetric]::SmCaptionFont
            $Metric += [DesktopMetric]::MenuFont
            $Metric += [DesktopMetric]::MessageFont
            $Metric += [DesktopMetric]::StatusFont
            $Metric += [DesktopMetric]::IconFont
        }
    }

    # Go
    Process {
        # Go
        foreach( $f in $Metric ) {
            # Skip 'specials'
            if( $f -eq [DesktopMetric]::All ) { continue }
            if( $f -eq [DesktopMetric]::None ) { continue }
            # Normal
            $dfnt =[DesktopMetricFontClass]::new( $f )
            Write-Output $dfnt
        }
        # Done
    }

    End {}
}

<#
.SYNOPSIS
    WORKAROUND for Builds 15019-?? lacking the ability to change Desktop Font sizes

    Sets one or more of the Desktop Font Size(s)
.DESCRIPTION
    WORKAROUND for Builds 15019-?? to sets one or more Desktop Font Size(s)

    Set the Desktop Metric values stored in the Registry under key:
    HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics
.EXAMPLE
    Set-DesktopMetric -Metric Caption, Menu -FontSize 14
.EXAMPLE
    sdm Caption, Menu 14
#>
Function Set-DesktopMetric() {
    [Alias( 'sdm' )]
    Param(
        # The name of the Font Metric to change
        [Parameter( ParameterSetName='FontSize', Mandatory=$false, Position=0 )]
        [Parameter( ParameterSetName='RestoreOOTB', Mandatory=$false, Position=0 )]
        [DesktopMetric[]]$Metric = [DesktopMetric]::All,

        # A Font-Size to set
        [Parameter( ParameterSetName='FontSize', Mandatory=$true, Position=1 )]
        [ValidateRange( 6, 20 )]
        [int]$FontSize = 12,

        # A Font-Size to set
        [Parameter( ParameterSetName='RestoreOOTB', Mandatory=$true, Position=1 )]
        [Switch]$RestoreOOTB
    )

    Begin {
        # Automate 'specials'
        if( $Metric -eq [DesktopMetric]::All ) { 
            $Metric =  [DesktopMetric]::CaptionFont
            $Metric += [DesktopMetric]::SmCaptionFont
            $Metric += [DesktopMetric]::MenuFont
            $Metric += [DesktopMetric]::MessageFont
            $Metric += [DesktopMetric]::StatusFont
            $Metric += [DesktopMetric]::IconFont
        }
    }

    Process {
        # Go
        foreach( $f in $Metric ) {
            # Skip 'specials'
            if( $f -eq [DesktopMetric]::All ) { continue }
            if( $f -eq [DesktopMetric]::None ) { continue }
            # Vars
            $dfnt =[DesktopMetricFontClass]::new( $f )
            # Go
            if($PSCmdlet.ParameterSetName -eq 'FontSize' ) {
                $dfnt.Size = $FontSize
            }
            if($PSCmdlet.ParameterSetName -eq 'RestoreOOTB' ) {
                $dfnt.RevertToOOTB()
            }
            # Write the changes to the Registry
            $dfnt.ApplyChanges()
            # Output
            Write-Output $dfnt
        }
        # Done
    }

    End {
        # Cue User
        Write-Host 'You must Signout and Signin again for changes to take effect' -ForegroundColor Cyan
    }
}

# EOS