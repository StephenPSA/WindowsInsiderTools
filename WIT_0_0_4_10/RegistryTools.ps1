##=================================================================================================
# File    : RegistryTools.ps1
# Author  : StephenPSA
# Version : 0.0.3.26
# Date    : Oct, 2016
##-------------------------------------------------------------------------------------------------

<#
.Synopsis
   Short description
.Description
   Long description
.Example
   Example of how to use this cmdlet
.Example
   Another example of how to use this cmdlet
#>
Function Get-RegistryValue {
    [CmdletBinding( DefaultParameterSetName='Fallback' )]
    Param(
        # The Registry Key to get
        [Parameter( Mandatory=$true, ValueFromPipeline=$true, Position=0
                  , HelpMessage='Defaults to HKLM:Key' )]
        [string]$Key,

        # The Registry Key's Property to get
        [Parameter( Mandatory=$true, Position=1 )]
        [string]$Property,

        # The Fallback value (and return Type) of the Registry Key.Property value to get
        [Parameter( ParametersetName='Fallback', Mandatory=$true, Position=2 )]
        $Fallback,

        # The Fallback value (and return Type) of the Registry Key.Property value to get
        [Parameter( ParametersetName='Empty', Mandatory=$true, Position=2 )]
        [Switch]$Empty,

        # The Fallback value (and return Type) of the Registry Key.Property value to get
        [Parameter( ParametersetName='MinusOne', Mandatory=$true, Position=2 )]
        [Switch]$MinusOne,

        # The Fallback value (and return Type) of the Registry Key.Property value to get
        [Parameter( ParametersetName='Zero', Mandatory=$true, Position=2 )]
        [Switch]$Zero,

        # The Fallback value (and return Type) of the Registry Key.Property value to get
        [Parameter( ParametersetName='NA', Mandatory=$true, Position=2 )]
        [Switch]$NA,

        # The Fallback value (and return Type) of the Registry Key.Property value to get
        [Parameter( ParametersetName='NotAvailable', Mandatory=$true, Position=2 )]
        [Switch]$NotAvailable,

        # The Fallback value (and return Type) of the Registry Key.Property value to get
        [Parameter( ParametersetName='MinDateTime', Mandatory=$true, Position=2 )]
        [Switch]$MinDateTime
    )

    Begin {
    }

    Process {
        # Parameter Sets to $Fallback Type/Value
        switch( $PSCmdlet.ParameterSetName ) {
            'MinDateTime'  { [DateTime]$Fallback = [DateTime]::MinValue }
            'Empty'        {   [string]$Fallback = '' }
            'NA'           {   [string]$Fallback = 'NA' }
            'NotAvailable' {   [string]$Fallback = 'not available' }
            'MinusOne'     {    [Int32]$Fallback = -1 }
            'Zero'         {    [Int32]$Fallback = 0 }
            default {}
        }

        # Determine output type by Init to Fallback
        $res = $Fallback

        # Get-Item
        # Get Property REG_xx
        $pth = "HKLM:$Key"
        try {
            $regdata = Get-ItemPropertyValue -Path $pth -Name $Property
        }
        catch [Exception] {}

        # Check exists
        if( $regdata -eq $null ) {
            Write-Verbose "'$pth\$Property' not found, returning fallback value: $Fallback"
        }
        else {
            # Determine REG_xx type
            $REG_Type = switch( $regdata.GetType().Name ) {
                'byte[]' { "REG_BINARY" }
                'Int32' { 
                    "REG_DWORD" 
                }
                'string' { "REG_SZ" }
                default {
                    Write-Error "Unsupported REG_Type: '$REG_Type'"
                    return
                }
            }
            #Write-Verbose "'$pth' found, REG_Type: $REG_Type"

            # (Convert) Fill $res
            switch( $REG_Type ) {
                default {
                    Write-Error "Unsupported REG_Type: '$REG_Type'"
                    return
                }
                'REG_BINARY' { 
                    switch( $Fallback.GetType().Name ) {
                        default {
                            Write-Error "Unsupported conversion REG_Type: '$REG_Type' to '$($Fallback.GetType().Name)'"
                            return
                        }
                        'string' { 'Todo' }
                        'DateTime' {
                            [UInt64]$tics = 0
                            for( $i = 0; $i -le 7; $i++ ) {
                                $tics += $regdata[$i] * [Math]::Pow( 256, $i )
                            }
                            $res = [DateTime]::FromFileTime( $tics )
                        }
                    }
                }
                'REG_DWORD' { 
                    switch( $Fallback.GetType().Name ) {
                        default {
                            Write-Error "Unsupported conversion REG_Type: '$REG_Type' to '$($Fallback.GetType().Name)'"
                            return
                        }
                        'string' { $res = ([Int32]$regdata).ToString() }
                        'Int32' { $res = [Int32]$regdata }
                    }
                 }
                'REG_SZ' { 
                    switch( $Fallback.GetType().Name ) {
                        default {
                            Write-Error "Unsupported conversion REG_Type: '$REG_Type' to '$($Fallback.GetType().Name)'"
                            return
                        }
                        'string' { $res = $regdata }
                    }
                 }
            }
            Write-Verbose "'$pth\$Property' found, REG_Type: $REG_Type converted to $($res.GetType().Name)"

            # EOP
        }

    }

    End {
        # Write to Pipeline
        Write-Output $res
    }
    
    # EOClass
}

# EOS