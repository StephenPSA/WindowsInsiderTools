# File    : GitTools.ps1
<#=================================================================================================
# Author  : StephenPSA
# Version : 0.0.6.35
# Date    : Oct, 2016
#
# Defines Funcions connected to Git use
#
# See:
#    Git Cheat Sheet                 - https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf
#    Git install                     - https://git-scm.com/downloads
#    Git in PowerShell (ISE) module  - https://github.com/dahlbyk/posh-git
##-------------------------------------------------------------------------------------------------#>
#requires -Version 5.0

# Global Variables - Todo: Consolodate this into a WitPreferences Class
$Global:WitGitHub   = 'https://github.com/StephenPSA/WindowsInsiderTools'
$Global:WitGitSheet = 'https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf'
$Global:WitGitFlow  = 'https://guides.github.com/introduction/flow'

<#
.Synopsis
    Shows Wit Integration Status and help
#>
Function Show-GitQuickStart() {
    [CmdletBinding()]
    Param()

    # var
    $hasGit = Test-HasGitCommands

    # GIT Status
    if( $hasGit ) {
        # Cue User
        Write-Host "Git is installed" -ForegroundColor Green
        Write-Host "-- See Git at: https://git-scm.com/downloads" 
    }
    else {
        # Cue User
        Write-Host "Git is not installed" -ForegroundColor Red
        Write-Host "Install Git from: https://git-scm.com/downloads" 
    }

    # Posh GIT Status
    $pg = Get-Module -Name posh-git -ErrorAction SilentlyContinue
    if( $pg -eq $null ) {
        # Cue User
        Write-Host "Posh Git is not installed" -ForegroundColor Red
        Write-Host "Install Posh-Git from: https://github.com/dahlbyk/posh-git" 
    }
    else {
        # Cue User
        Write-Host "Posh Git is installed: Version: $($pg.Version)" -ForegroundColor Green
    }

    if( $PSBoundParameters['Verbose'] ) {
        # 

        # Show Cheat Sheet
        Write-Verbose "Open the Git Cheat Sheet by typing: ows GitSheet" 
    }

    # EOF
}

<#
.Synopsis
    Gets Quick Git Status
#>
Function Get-GitQuickStatus() {
    [CmdletBinding()]
    [Alias( 'ggq' )]
    Param(
        # 
        [int]$Indents = 1
    )

    # var
    [string[]]$status = $null
    [string[]]$add = $null
    [string[]]$upd = $null
    [string[]]$rem = $null
    $brn = $null

    # Query git
    $gs = git status
    $summ = git status --short

    ### Verbose
    if( $PSBoundParameters.Verbose ) {
        Write-Verbose 'Gotcha!'
    }

    # Filter Levels
    foreach( $m in $gs ) {
        # Skip Empty Lines
        if( $m.Trim().Length -eq 0 ) { continue }
        # Replace Tab Char
        $m = $m.Replace( "`t", "    " )
        # Extract branch
        if( $brn -eq $null ) {
            $brn = $m.Substring( 10 )
            continue
        }
        # Extract Changed Files
        if( $m.StartsWith( "    new file:" ) ) {
            $add += $m.Substring( 14 ).Trim()
        }
        if( $m.StartsWith( "    modified:" ) ) {
            $upd += $m.Substring( 14 ).Trim()
        }
        if( $m.StartsWith( "    deleted:" ) ) {
            $rem += $m.Substring( 14 ).Trim()
        }
        # Calc Indent
        $i = ($m.Length - $m.TrimStart().Length) / 2
        Write-Verbose "$($i.ToString( "#0" )) | $m"
        # Add if in range
        if( $i -lt $Indents ) { $status += $m }
    }

    # Build out
    $hsh =[ordered]@{
       'Branch'   = $brn
       'Status'   = $status
       'Changes'  = $summ
       'Added'    = $add
       'Modified' = $upd
       'Removed'  = $rem
    }
    $res = New-Object -TypeName PSObject -ArgumentList $hsh

    # Write Pipeline
    Write-Output $res

    # EOF
}

<#
.Synopsis
   Short description
#>
Function New-GitBranch {
    [CmdletBinding( SupportsShouldProcess=$true, ConfirmImpact='High' )]
    [Alias( 'ngb' )]
    [OutputType([object])]
    Param(
        # A name for the new Branch
        [Parameter( Mandatory=$false, Position=0 )]
        [string]$Name = 'auto',

        # If set, names the new branch
        [Parameter( ParameterSetName='List' )]
        [Switch]$List,

        # If set, names the new branch
        [Parameter()]
        [Switch]$NewRevision,

        # If set, does not checkout the new Branch
        [Parameter()]
        [Switch]$NoCheckout,

        # If set, does not edit the README.md and *.psd1
        [Parameter()]
        [Switch]$NoVersionEdits

        # Force 
    )

    Begin {
        # var
        #$gs = Get-GitQuickStatus
        #if( $gs.Branch -ne 'master' ) {
        #    Write-Error "You must be on master to do this..."
        #    $Name = $null
        #    return
        #}

        # Get the current
        $v = Get-WorkspaceVersion -Imported
        $mj = $v.Major
        $mn = $v.Minor
        $bd = $v.Build
        $rv = $v.Revision

        #
        if( $NewRevision ) { $rv++ }

        # Auto name
        if( $Name -eq 'auto' ) {
            $Name = "V-$mj-$mn-$bd-$rv"
        }

    }

    Process {

        # Should Process
        if( $Name -eq $null) { return }

        # var
        $gs = Get-GitQuickStatus -Verbose:$false
        #if( $gs.Branch -ne 'master' ) {
        #    Write-Error "You must be on master to do this..."
        #    $Name = $null
        #    return
        #}

        # Named
        if( $PSCmdlet.ShouldProcess( $gs.Branch, "Create a new Branch: $Name" ) ) {
            Write-Verbose "Creating a new Branch: $Name..."

            # Option
            if( !$NoCheckout )  {
                Write-Verbose "Checkout Branch: $Name..."
            }

            # Option
            if( !$NoCheckout )  {
                Write-Verbose "Updating Versioning $v -> $mj.$mn.$bd.$rv..."
            }
        }

        #
    }

    End {
    }

}

<#
.Synopsis
   Stages and Commits all Uncommitted work
.Exapmple
    ngc 'My commit comment'


#>
Function New-GitCommit {
    [CmdletBinding( SupportsShouldProcess=$true, ConfirmImpact='High' )]
    [Alias( 'ngc' )]
    [OutputType([object])]
    Param(
        # If set, names the new branch
        [Parameter( Mandatory=$true,
                    ValueFromPipelineByPropertyName=$true,
                    Position=0)]
        [AllowEmptyCollection()]
        [ValidateCount( 0,5 )]
        [string[]]$Comment

        # Force 
    )

    Begin {
        # vars
        $res = $null
        $gs = Get-GitQuickStatus

        # Contract - Requires Git
        if( !(Test-HasGitCommands) ) {
            Write-Error "Aaarrgh! You got me, i.e. Todo:"
            Write-Warning "Git is nit installed, Type 'xxx' to get more help"
            return
        }

        # Ignore empty
        if( $Comment.Count -eq 0 ) { return }

        # Build delimeted single line comment
        $cmmnt = [String]::Join( "; ", $Comment )
    }

    Process {
        # Contract
        if( !(Test-HasGitCommands) ) { return }

        # ShouldProcess - Stage
        if( $PSCmdlet.ShouldProcess( $gs.Branch, "Stage all changes" ) ) {
            # Stage
            $res = git add *
            # Check Staging Result
            if( $res -ne $null ) {
                Write-Warning $res
            }
        }

        # ShouldProcess - Commit
        # Ignore empty
        if( $cmmnt.Length -eq 0 ) { return }
        if( $PSCmdlet.ShouldProcess( $gs.Branch, "Commit changes: $cmmnt" ) ) {
            # Commit
            # - Hides Error Message
            $res = git commit -m $cmmnt # 2>>$null
        }


    }

    End {
        # Write to Pipeline - Ignore empty
        if( $res -ne $null ) { Write-Output $res }
    }
    
    # EOF
}

# EOS
