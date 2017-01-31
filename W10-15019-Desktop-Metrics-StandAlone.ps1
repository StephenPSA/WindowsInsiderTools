﻿##=================================================================================================
# File    : W10-15019-Desktop-Metrics-StandAlone.ps1
# Author  : StephenPSA
# Version : 0.0.0.1
# Date    : Jan, 2017
#
# A workaround powershell script for Build 10.0.15019.1000
# - Change 'Advanced Display Setting' 
##-------------------------------------------------------------------------------------------------
# Defines Enums, Classes and Functions in lieu of 
  # [Enums] DesktopMetricsFont, DesktopMetricsCategory
# [Classes] 
# [Cmdlets] 
##=================================================================================================
# Also thanks to Willy Denoyette, Windows Insider
#
#     $key="HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
#     $size = 12
#     $val = (Get-Itemproperty -Path Registry::$Key ).IconFont
#     $val[0]= 256 - $size
#     Set-Itemproperty -Path Registry::$Key -Name IconFont -Value $val
##-------------------------------------------------------------------------------------------------

#requires -Version 5.0

# Enum - 
enum DesktopMetricsFont {
    None
    All
    Caption
    Icon
    Menu
    Message
    SmCaption
    Status
}

# Enum - 
enum DesktopMetricsCategory {
    Raw
    Font
#    AppliedDPI
#    FontName
    FontSize
#    FontBold
#    FontUnderline
#    Width
#    Height
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

    # Internal
    hidden [void]WriteRegistry() {
        #- BETA DISABLED
        Write-Host 'Write to Registry is disabled' -ForegroundColor DarkYellow

        ##- BETA ENABLED
        ## Write OS Registry
        ## vars
        #$key = "HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
        #$nme = $this.Font.ToString() + 'Font'
        #Set-Itemproperty -Path Registry::$Key -Name $nme -Value $this.rawData 
        #Write-Host 'The Write to Registry was sucessfull' -ForegroundColor Green

        # Done
    }
}

### Internal Helper Function
##Function Get-DesktopMetricsFont( [DesktopMetricsFont]$Font ) {
##    # vars
##    $res = $null
##    $key="HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
##    # Read Registry
##    $val = Get-Itemproperty -Path Registry::$Key
##    # Select Fiel
##    switch ( $font ) {
 #      Caption { $res = $val.CaptionFont } 
 #      Icon { $res = $val.IconFont } 
 #      Menu { $res = $val.MenuFont } 
 #      Message { $res = $val.MessageFont } 
 #      SmCaption { $res = $val.SmCaptionFont } 
 #      Status { $res = $val.StatusFont } 
 #   }
##    # Done
##    return $res
##}

<#
.Synopsis
.DESCRIPTION
.EXAMPLE
#>
Function Test-DesktopMetrics() {
    [Alias( 'tdm' )]
    Param()

    # Go
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Caption ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::SmCaption ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Menu ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Message ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Menu ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Status ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Icon ))
    # Done
}

<#
.Synopsis
.DESCRIPTION
.EXAMPLE
#>
Function Get-DesktopMetrics() {
    [Alias( 'gdm' )]
    Param(
        [DesktopMetricsFont]$Font
    )

    # Go
    Write-Output ([DesktopMetricsFontClass]::new( $Font ))
    # Done
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
        # A name for the new Branch
        [Parameter( Mandatory=$false, Position=0 )]
        [DesktopMetricsFont[]]$Font = [DesktopMetricsFont]::All,

        # A name for the new Branch
        [Parameter( Mandatory=$true, Position=1 )]
        [ValidateSet( 6, 7, 9, 10, 11, 12, 14, 16 )]
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