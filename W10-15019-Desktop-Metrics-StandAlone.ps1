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
        # Store params
        $this.Font = $Font;
        # vars
        if( $Font -ne [DesktopMetricsFont]::None ) {
            # Get Raw
            $this.rawData = Get-DesktopMetricsFont $Font
            # Calc Properties
            $this.Size = 256 - ($this.rawData[0])
        }
    }

    # Fields
    [DesktopMetricsFont]$Font
    [int]$Size

    # Methods
    #- Todo: store Properties in raw and write to registry
    [void]ApplyChanges() {
        # FontSize
        $this.rawData[0] = (256 - $this.Size)
        #- Todo: write to registry
        Write-Host 'Write to Registry is disabled' -ForegroundColor DarkYellow
    }
    # Internal
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
Function Get-DesktopMetricsFont( [DesktopMetricsFont]$Font ) {
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
    # Done
    return $res
}

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
        [DesktopMetricsFont[]]$Font = [DesktopMetricsFont]::Caption,

        # A name for the new Branch
        [ValidateSet( 6, 7, 9, 10, 11, 12, 14, 16 )]
        [int]$FontSize = 12
    )

    Begin {
    }

    Process {
        # Go
        foreach( $f in $Font ) {
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