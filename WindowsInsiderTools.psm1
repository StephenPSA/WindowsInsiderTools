##=================================================================================================
# File    : WindowsInsiderTools.psm1
# Author  : StephenPSA
# Version : 0.0.6.7
# Date    : Oct, 2016
##-------------------------------------------------------------------------------------------------
#requires -Version 5.0
<#requires –runasadministrator#>

using namespace System.Diagnostics
using namespace System.Management.Automation
using namespace Microsoft.Management.Infrastructure
##-------------------------------------------------------------------------------------------------
# Enum
enum DiskBusType {
    NotAvailable = -1
    Unkown = 0
    SCSI   = 1
    ATAPI  = 2
    ATA    = 3
    _1394  = 4
    SSA    = 5
    FibreChannel  = 6
    USB    = 7
    RAID   = 8
    iSCCI  = 9
    SAS    = 10
    SATA   = 11
    SD     = 12
    MMC    = 13
    MAX    = 14
    FileBackedVirtual = 15
    StorageSpaces     = 16
    NVMe   = 17
    MS_Reserved = 18
}

# Enum
enum DiskHealthStatus {
    NotAvailable = -1
    Healthy   = 0
    Warning   = 1
    Unhealthy = 2
    Unknown   = 5
}

# Enum
enum DiskMediaType {
    NotAvailable = -1
    HDD = 0
    SSD = 4
    SCM = 5
    Unspecified
}

# Enum
enum DiskPartitioningStyle {
    NotAvailable = -1
    Unknown = 0
    MBR     = 1
    GPT     = 2
}

# Enum
enum DiskOperationalStatus {
    NotAvailable = -1
    Unkown = 0
    Other = 1
    OK = 2
    Degraded = 3
    Stressed = 4
    PredictiveFailure = 5
    Error = 6
    Non_Recoverable_Error = 7
    Starting = 8
    Stopping = 9
    Stopped = 10
    InService = 11
    NoContact = 12
    LostCommunication = 13
    Aborted = 14
    Dormant = 15
    SupportingEntityError = 16
    Completed = 17
    Online = 0xD010
    NotReady = 0xD011
    NoMedia = 0xD012
    Offline = 0xD013
    Failed = 0xD014
}

# Enum
enum WitWorkspace {
    Imported
    WitModule
    GitHub
    Canary
}

# Define a Data Class
Class DiskInfoClass {

    # Constructor
    DiskInfoClass ( [int]$Number )  {
        # Store
        $this.DiskNumber = $Number
        # Refresh
        $this.Refresh()
    }

    # WIT
    [string]$NickName
    # System
    # Identification Data
    [String]$MachineName
    [int]$DiskNumber

    # Fields
    $SerialNumber
    $Model
    [DiskMediaType]$DiskType
    [DiskHealthSTatus]$HealthStatus
    [DiskOperationalStatus]$OperationalStatus
    $Size
    $UnAllocated
    $IsBoot
    $IsSystem
    [DiskPartitioningStyle]$PartitionStyle
    $PartitionCount
    [DiskBusType]$BusType
    $Location
    $FirmwareVersion

    # Embedded Data
    $MSFT_PhysicalDisk
    $MSFT_Disk

    # Methods
    static [DiskInfoClass]FromDiskNr( [int]$Number ) {
        return [DiskInfoClass]::New( $Number )
    }

    [void]Refresh() {
        # Refresh Embedded
        $ns = "root/Microsoft/Windows/Storage"
        $p = $this.MSFT_PhysicalDisk = Get-WmiObject -Namespace $ns -Class MSFT_PhysicalDisk -Filter "DeviceId=$($this.DiskNumber)"
        $d = $this.MSFT_Disk = Get-WmiObject -Namespace $ns -Class MSFT_Disk -Filter "Number=$($this.DiskNumber)"
        # Import Data
        if( $p -eq $null ) {
            $this.MachineName = $env:COMPUTERNAME
            $this.Model = "No Disk"
            $this.BusType = [DiskBusType]::NotAvailable
            $this.DiskType = [DiskMediaType]::NotAvailable
            $this.PartitionStyle = [DiskPartitioningStyle]::NotAvailable
            $this.HealthStatus = [DiskHealthStatus]::NotAvailable
            $this.OperationalStatus = [DiskOperationalStatus]::NotAvailable
        }
        else {
            $this.MachineName=$p.PSComputerName
            $this.SerialNumber=$p.SerialNumber
            $this.Model=$p.Model
            $this.DiskType= [DiskMediaType]$p.MediaType
            $this.HealthStatus= [DiskHealthSTatus]$p.HealthStatus
            $this.OperationalStatus=[DiskOperationalStatus]$p.OperationalStatus
            $this.Size=$p.Size
            $this.UnAllocated=$p.Size - $p.AllocatedSize
            $this.BusType=[DiskBusType]$p.BusType
            $this.Location=$p.PhysicalLocation
            $this.FirmwareVersion=$p.FirmwareVersion
        }
        # Import Data
        if( $d -ne $null ) {
            $this.IsBoot=$d.IsBoot
            $this.IsSystem=$d.IsSystem
            $this.PartitionStyle=[DiskPartitioningStyle]$d.PartitionStyle
            $this.PartitionCount=$d.NumberOfPartitions
        }
    }

}

##-------------------------------------------------------------------------------------------------
# Define a Data Class
Class EventInfoClass {

   # Constructor
   EventInfoClass () { }
   
   # Constructor
   EventInfoClass ( [string]$logName, [EventLogEntry]$entry ) {
        # Store
        $this.LogName = $logName
        $this.LogEntry = $entry
        # Populate
        $this.MachineName = $entry.MachineName
        $this.LogIndex = $entry.Index
        $this.EntryTime = $entry.TimeGenerated
        $this.EntryType = $entry.EntryType
        $this.Source = $entry.Source
        $this.EventID = $entry.EventID
        $this.Message = $entry.Message
   }

   # Constructor
   EventInfoClass ( [string]$nickName, [string]$logName, [EventLogEntry]$entry ) {
        #Write-Host "Gotcha!" -ForegroundColor Red
        # Store
        $this.NickName = $nickName
        $this.LogName = $logName
        $this.LogEntry = $entry
        # Populate
        $this.MachineName = $entry.MachineName
        $this.LogIndex = $entry.Index
        $this.EntryTime = $entry.TimeGenerated
        $this.EntryType = $entry.EntryType
        $this.Source = $entry.Source
        $this.EventID = $entry.EventID
        $this.Message = $entry.Message
   }

   # Simple Properties
   # WIT
   [string]$NickName
   # System
   [string]$MachineName
   [DateTime]$EntryTime
   [EventLogEntryType]$EntryType
   [string]$LogName
   [int32]$LogIndex
   [string]$Source
   [int32]$EventID
   [string]$Message
   [EventLogEntry]$LogEntry

}

##-------------------------------------------------------------------------------------------------
# Define Functions that use OsStateClass

# Enum
enum DefenderScanType {
    NotAvailable = -1
    Full    = 0
    Quick   = 1
    Custom  = 2
}

# Define a Data Class
Class OsStateClass {

   # Constructor
   OsStateClass ()  {
        # Init
        $this.OsCimInstance
        # Initialize
        $this.InitInstance()
   }
   
   # Constructor
   OsStateClass( [string]$nickName ) {
        # Store
        $this.NickName = $nickName
        # Initialize
        $this.InitInstance()
    }

    # Helper
    hidden InitInstance() {
        # vars
        $cimi = $this.OsCimInstance = Get-CimInstance CIM_OperatingSystem

        # Harware
        $this.MachineName = $cimi.CSName
        $this.Description = $cimi.Description
        $this.PhysicalMemory = $cimi.TotalVisibleMemorySize
        $this.PhysicalMemoryFree = $cimi.FreePhysicalMemory
        # CPU - Todo
        # Insider

        # OS
        $this.Edition = $cimi.Caption
        $this.Architecture = $cimi.OSArchitecture
        #$this.Build = Get-ItemPropertyValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Flighting\Build' -Name 'OSVersion' 
        $this.Build = $Global:PSVersionTable.BuildVersion
        $this.InstallDate = $cimi.InstallDate
        $this.Activation = 'Todo'
        $this.WindowsDirectory = $cimi.WindowsDirectory
        # Volume
        $this.VolumeLetter = $cimi.WindowsDirectory[0]
        $this.BootDevice = $cimi.BootDevice
        $this.SystemDevice = $cimi.SystemDevice
        # Calculated
        $this.SystemLocation = ($cimi.Name.Split( "|" ))[2]
        $this.DriveNumber    = [int]::Parse( $this.SystemLocation.Split( '\' )[2].Substring( 8 ) )
        $this.DrivePartition = [int]::Parse( $this.SystemLocation.Split( '\' )[3].Substring( 9 ) )
        # OS Volume
   $v = $this.OsVolumeCimInstance = Get-Volume -DriveLetter $this.VolumeLetter
        if( $v -ne $null ) {
            $this.VolumeLabel      = $v.FileSystemLabel
            $this.VolumeFileSystem = $v.FileSystem
            $this.VolumeSize       = $v.Size
            $this.VolumeFree       = $v.SizeRemaining
        }
        # OS Disk 
   $d = $this.OsDiskInfo = Get-DiskHardwareInfo -DiskNumber $this.DriveNumber
        if( $d -ne $null ) {
            $this.DiskModel        = $d.Model
            $this.DiskType         = $d.DiskType
            $this.DiskPartinioning = $d.PartitionStyle
            $this.DiskHealth       = $d.HealthStatus
            $this.DiskStatus       = $d.OperationalStatus
            $this.DiskBus          = $d.BusType
            $this.DiskLocation     = $d.Location
        }
        # Refresh
        $this.Refresh()
        # EOC
   }
    
    # Simple Properties
              # WIT
      [string]$NickName
              # System
      [string]$MachineName
      [string]$Description
      [UInt64]$PhysicalMemory
      [UInt64]$PhysicalMemoryFree
              # CPU - Todo
              # Insider
      [string]$InsiderRing      = 'n.a.'
              # OS
      [string]$Edition
      [string]$Architecture
      [string]$Build
    [DateTime]$InstallDate
              # Todo Activation state
      [string]$Activation       = 'n.a.'
      [string]$WindowsDirectory
      [string]$WitVersion
              # Defender
    [DateTime]$DefenderDefinitionDate
    [DateTime]$DefenderLastScanDate
[DefenderScanType]$DefenderLastScanType = [DefenderScanType]::NotAvailable
      [string]$DefenderASDefinition
      [string]$DefenderAVDefinition
              # Drive
         [int]$DriveNumber      = -1
         [int]$DrivePartition   = -1
              # Volume
      [string]$VolumeFileSystem = 'n.a.'
        [char]$VolumeLetter     = '?'
      [string]$VolumeLabel      = 'n.a.'
      [uint64]$VolumeSize      
      [uint64]$VolumeFree
              # Disk
      [string]$DiskModel                       = 'n.a.'
      [DiskMediaType]$DiskType                 = [DiskMediaType]::NotAvailable
      [DiskPartitioningStyle]$DiskPartinioning = [DiskPartitioningStyle]::NotAvailable
      [DiskHealthStatus]$DiskHealth            = [DiskHealthStatus]::NotAvailable
      [DiskOperationalStatus]$DiskStatus       = [DiskOperationalStatus]::NotAvailable
      [DiskBusType]$DiskBus                    = [DiskBusType]::NotAvailable
      [string]$DiskLocation                    = 'n.a.'
              # Booting
      [string]$BootDevice
      [string]$SystemDevice
      [string]$SystemLocation

    # Embedded Objects
    [DiskInfoClass]$OsDiskInfo
    [CimInstance]$OsCimInstance
    [CimInstance]$OsVolumeCimInstance

    # Method
    [void] Refresh() {
        # Cue User
        Write-Verbose "Refresh invoked..."
        # WindowsInsiderTools Version
        $this.WitVersion = (Get-Module 'WindowsInsiderTools').Version.ToString()

        # Insider Ringd
        $key = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\SettingsRequests'
        # this getthe Settings syn time? $x = Get-RegistryValue $key 'LastDownloadTime' -MinDateTime
        #$x = Get-RegistryValue $key 'LastTelSettingsRingId' -NotAvailable
        $x = Get-RegistryValue $key 'LastTelSettingsRingName' -NotAvailable
        $this.InsiderRing = switch( $x ) {
            'WIF' { 'Fast' }
            'WIS' { 'Slow' }
            'WIP' { 'Prvw' }
            Default { $x }
        }
        # SOFTWARE\Microsoft\WindowsSelfHost\Applicability
        # - Ring, Enabled
        # Specialists
        $this.RefreshDefender()
    }

    # Method - return SFCState ?
    [void] RefreshDefender() {
        Write-Verbose "Refreshing WindowsDefenderState..."
        $key = '\SOFTWARE\Microsoft\Windows Defender\Signature Updates'
        $this.DefenderASDefinition = Get-RegistryValue $key 'ASSignatureVersion' -NotAvailable
        $this.DefenderAVDefinition = Get-RegistryValue $key 'AVSignatureVersion' -NotAvailable
        $this.DefenderDefinitionDate = Get-RegistryValue $key 'SignaturesLastUpdated' -MinDateTime
        $key = '\SOFTWARE\Microsoft\Windows Defender\Scan'
        $this.DefenderLastScanDate = Get-RegistryValue $key 'LastScanRun' -MinDateTime
        $this.DefenderLastScanType = Get-RegistryValue $key 'LastScanType' -MinusOne
        #$this.DefenderSFCState = Get-RegistryValue $key 'SFCState' ([DateTime]::MinValue)
    }

    # Method
    [void] ShowDefender() {
        & "$env:ProgramFiles\Windows Defender\MSASCui.exe"
    }

    # Method
    [string[]] ShowDefenderHelp() {
        $res = & "$env:ProgramFiles\Windows Defender\MpCmdRun.exe" "-?"
        return $res
    }

    # Method - InThread
    [string[]] RunDefenderScan() {
        $res = & "$env:ProgramFiles\Windows Defender\MpCmdRun.exe" "-Scan" "-ScanType 1"
        return $res
    }

    # Method - Job
    [void] StartDefenderScan() {
        Write-Error "Todo: RunDefenderScan -AsJob..."
    }

    # Method - InThread
    [string] UpdateDefenderDefinitions() {
        $res = & "$env:ProgramFiles\Windows Defender\MpCmdRun.exe" "-SignatureUpdate"
        return $res
    }

    # Method - Job
    [void] StartUpdateDefenderDefinitions() {
        Write-Error "Todo..."
    }

}

##-------------------------------------------------------------------------------------------------
# Import Tooling
. $HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools\Tools\ContributerTools.ps1
. $HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools\Tools\EventLogTools.ps1
. $HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools\Tools\GeneralTools.ps1
. $HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools\Tools\GitTools.ps1
. $HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools\Tools\HardwareTools.ps1
. $HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools\Tools\IoTTools.ps1
. $HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools\Tools\MonitoringTools.ps1
. $HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools\Tools\RegistryTools.ps1
. $HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools\Tools\RemotingTools.ps1
. $HOME\Documents\WindowsPowerShell\Modules\WindowsInsiderTools\Tools\UpdatingTools.ps1

#$ps = { Machine, Description, InstallDate, Build }
#Update-TypeData -TypeName OsStateClass -DefaultDisplayPropertySet MachineName, Description, InstallDate, Build -Force

# EOS