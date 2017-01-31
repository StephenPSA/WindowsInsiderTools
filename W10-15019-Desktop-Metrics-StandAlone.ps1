##=================================================================================================
# File    : W10-15019-Desktop-Metrics-StandAlone.ps1
# Author  : StephenPSA
# Version : 0.0.0.1
# Date    : Jan, 2017
#
# PLEASE NOTE: CHECK lines 145 to 150, due to BETA some code is DISABLED
# PLEASE NOTE: Please do not forget to remove this comment when changed
#
# A workaround powershell script for Build 10.0.15019.1000
# - Change 'Advanced Display Setting' 
##-------------------------------------------------------------------------------------------------
# Defines Enums, Classes and Functions in lieu of 
  # [Enums] DesktopMetricsFont, DesktopMetricsCategory
# [Classes] 
# [Cmdlets] 
##=================================================================================================
## Also many thanks to 
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
##-------------------------------------------------------------------------------------------------

#requires -Version 5.0

# Enum - 
Enum DesktopMetricsFont {
    None
    All
    Caption
    Icon
    Menu
    Message
    SmCaption
    Status
}

# Class - 
Class DesktopMetricsFontClass {

    # Constructor
    DesktopMetricsFontClass ( [DesktopMetricsFont]$Font )  {
        # Contract
        if( $Font -eq [DesktopMetricsFont]::All ) {
            throw [System.Exception]::new( "'All' is not allowed here" )
        }
        if( $Font -eq [DesktopMetricsFont]::None ) {
            throw [System.Exception]::new( "'None' is not allowed here" )
        }
        # Store params
        $this.Font = $Font;
        # vars
        if( $Font -ne [DesktopMetricsFont]::None ) {
            # Get Raw
            $this.ReadRegistry()
            # Store Original State
            $this.originalData = $this.rawData
            # Calc Properties
            $this.Size = 256 - ($this.rawData[0])
        }
    }

    # Public Fields
    [DesktopMetricsFont]$Font
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
        switch ( $this.Font ) {
           Caption { $res = $val.CaptionFont } 
           Icon { $res = $val.IconFont } 
           Menu { $res = $val.MenuFont } 
           Message { $res = $val.MessageFont } 
           SmCaption { $res = $val.SmCaptionFont } 
           Status { $res = $val.StatusFont } 
        }
        # Store
        $this.rawData = $res
        # Done
    }

    # Internal - Write OS Registry
    hidden [void]WriteRegistry() {
        # vars
        $key = "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
        $nme = $this.Font.ToString() + 'Font'

        #- BETA DISABLED
        Write-Host 'BETA RESTRICTION Write to Registry is disabled' -ForegroundColor DarkYellow

        #- BETA ENABLED
        #    Set-Itemproperty -Path Registry::$Key -Name $nme -Value $this.rawData 
        #    Write-Host 'The Write to Registry was sucessfull' -ForegroundColor Green

        # Done
    }

}

<#
.Synopsis
.DESCRIPTION
.EXAMPLE
#>
Function Get-DesktopMetrics() {
    [Alias( 'gdm' )]
    Param(
        # The Name of the field
        [Parameter( Mandatory=$false, Position=0 )]
        [DesktopMetricsFont[]]$Font = [DesktopMetricsFont]::All
    )

    Begin {
        # Automate 'specials'
        if( $Font -eq [DesktopMetricsFont]::All ) { 
            $Font =  [DesktopMetricsFont]::Caption
            $Font += [DesktopMetricsFont]::SmCaption
            $Font += [DesktopMetricsFont]::Menu 
            $Font += [DesktopMetricsFont]::Message
            $Font += [DesktopMetricsFont]::Status
            $Font += [DesktopMetricsFont]::Icon
        }
    }

    # Go
    Process {
        # Go
        foreach( $f in $Font ) {
            # Skip 'specials'
            if( $f -eq [DesktopMetricsFont]::All ) { continue }
            if( $f -eq [DesktopMetricsFont]::None ) { continue }
            # Normal
            $dfnt =[DesktopMetricsFontClass]::new( $f )
            Write-Output $dfnt
        }
        # Done
    }

    End {}
}

<#
.Synopsis
.DESCRIPTION
.EXAMPLE
    sdm -Font Caption, SmCaption -FontSize 14
#>
Function Set-DesktopMetrics() {
    [Alias( 'sdm' )]
    Param(
        # The Name of the field
        [Parameter( Mandatory=$false, Position=0 )]
        [DesktopMetricsFont[]]$Font = [DesktopMetricsFont]::All,

        # A Font-Size
        [Parameter( Mandatory=$true, Position=1 )]
        [ValidateRange( 6, 20 )]
        [int]$FontSize = 12
    )

    Begin {
        # Automate 'specials'
        if( $Font -eq [DesktopMetricsFont]::All ) { 
            $Font =  [DesktopMetricsFont]::Caption
            $Font += [DesktopMetricsFont]::SmCaption
            $Font += [DesktopMetricsFont]::Menu 
            $Font += [DesktopMetricsFont]::Message
            $Font += [DesktopMetricsFont]::Status
            $Font += [DesktopMetricsFont]::Icon
        }
    }

    Process {
        # Go
        foreach( $f in $Font ) {
            # Skip 'specials'
            if( $f -eq [DesktopMetricsFont]::All ) { continue }
            if( $f -eq [DesktopMetricsFont]::None ) { continue }
            # Normal
            $dfnt =[DesktopMetricsFontClass]::new( $f )
            $dfnt.Size = $FontSize
            $dfnt.ApplyChanges()
            Write-Output $dfnt
        }
        # Done
    }

    End {}
}

# EOS