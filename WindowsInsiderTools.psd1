##=================================================================================================
# File    : WindowsInsiderTools.psd1
# Author  : StephenPSA
# Version : 0.0.6.34
# Date    : Oct, 2016
#
# Module manifest for module 'WindowsInsiderTools'
# 
# -------------------------------------------------------------------
# Todo:
#       Use HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate\AutoDownload
# -------------------------------------------------------------------
# Generated by: StephenPSA
# Generated on: 12/10/2016
#
# -------------------------------------------------------------------
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0

@{

# Script module or binary module file associated with this manifest.
RootModule = 'WindowsInsiderTools.psm1'

# Version number of this module.
ModuleVersion = '0.0.6.34'

# Supported PSEditions
# CompatiblePSEditions = @()

# ID used to uniquely identify this module
GUID = 'ecd644ea-aa24-4b1d-8ac0-faee7f287162'

# Author of this module
Author = 'StephenPSA'

# Company or vendor of this module
CompanyName = ''

# Copyright statement for this module
Copyright = 'Use at will, but at own risk (BETA!)'

# Description of the functionality provided by this module
Description = 'Handy functions for Windows Insider members'

# Minimum version of the Windows PowerShell engine required by this module
# PowerShellVersion = ''

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
#TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @( 'Formats\WindowsInsiderToolsTypes.Format.ps1xml' )

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
#FunctionsToExport = @()

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
#CmdletsToExport = @()

# Variables to export from this module
#VariablesToExport = '*'

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = @( 'gdh', 'gev', 'glb', 'gls', 'glw', 'gos', 'gosi', 'gwv'
                   , 'lgev',
                   , 'ggq', 'ows', 'sws', 'tda', 'tia', 'tla'
                   , 'ewit', 'iwit', 'gwit', 'nwit', 'pwit', 'rwit', 'uwit'
                   , 'ngb', 'ngc',
                   , 'som' )

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
#PrivateData = @{
#
#    PSData = @{
#
#        # Tags applied to this module. These help with module discovery in online galleries.
#        # Tags = @()
#
#        # A URL to the license for this module.
#        # LicenseUri = ''
#
#        # A URL to the main website for this project.
#        # ProjectUri = ''
#
#        # A URL to an icon representing this module.
#        # IconUri = ''
#
#        # ReleaseNotes of this module
#        # ReleaseNotes = ''
#
#    } # End of PSData hashtable
#
#} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

