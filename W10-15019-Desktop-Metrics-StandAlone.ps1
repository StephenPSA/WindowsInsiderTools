##=================================================================================================
# File    : W10-15019-Desktop-Metrics-StandAlone.ps1
# Author  : StephenPSA
# Version : 0.0.0.1
# Date    : Jan, 2017
#
# Defines Funcions:
#
# As a workaround for Build 10.0.15019.1000 having lost the capability to change 'Advanced Graphics 
#
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

# Enum - 
enum DesktopMetricsFont {
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
        # Store params
        $this.Font = $Font;
        # vars
        $this.rawData = Get-DesktopMetricsFont $Font
        # Calc
        $this.Size = 256 - ($this.rawData[0])
    }

    # Fields
    [DesktopMetricsFont]$Font
    [int]$Size

    hidden [Byte[]]$rawData
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

# Thanks to Willy Denoyette, Windows Insider
#
# $key="HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
# $size = 12
# $val = (Get-Itemproperty -Path Registry::$Key ).IconFont
# $val[0]= 256 - $size
# Set-Itemproperty -Path Registry::$Key -Name IconFont -Value $val

# Internal Helper Function
Function Get-DesktopMetricsFont( [DesktopMetricsFont]$Font, [DesktopMetricsCategory]$Category ) {
    # vars
    $res = $null
    $key="HKEY_CURRENT_USER\Control Panel\Desktop\WindowMetrics"
    # Read Registry
    $val = Get-Itemproperty -Path Registry::$Key
    # Select Fiel
    switch ( $font ) {
       Caption { $res = $val.CaptionFont } 
       Icon { $res = $val.IconFont } 
       Menu { $res = $val.MenuFont } 
       Message { $res = $val.MessageFont } 
       SmCaption { $res = $val.SmCaptionFont } 
       Status { $res = $val.StatusFont } 
    }
    # Select Return value
    switch ( $Category ) {
        Raw { }
        FontSize { $res = (256 - $res[0]) }
    }
    # Done
    return $res
}

<#
.Synopsis
   Tests whether the 
.DESCRIPTION
   Returns $true if the 
.EXAMPLE
   Test-IsLocalAdmin
#>
Function Test-DesktopMetrics() {
    [Alias( 'tdm' )]
    Param()

    # Go
    # Write-Output 'Caption', (Get-DesktopMetricsFont -Font Caption -Category FontSize)
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Caption ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::SmCaption ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Menu ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Message ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Menu ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Status ))
    ([DesktopMetricsFontClass]::new( [DesktopMetricsFont]::Icon ))
    # Done
}

# EOS