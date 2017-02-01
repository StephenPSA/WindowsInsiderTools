# *** Under construction, use at own risk ***

# WindowsInsiderTools - BETA 0.0.0.2, Feb 2017

## Workaround for 'Advanced Display Settings Missing In Build 15019', as discussed in the Windows Insiders Form here:
https://answers.microsoft.com/en-us/insider/forum/insider_wintp-insider_desktop/advanced-display-settings-missing-in-build-15019/59db2998-282e-4f6c-bd62-9dcaacb53936?page=6&msgId=42ac6d59-1bbb-466d-86ef-6eb56b48c0cf

# Summary
+ A couple of Powershell functions to get and set the Desktop Advanced Display Settings

# Usage
+ Install the Script as described below
+ Use 'Get-DesktopMetric' to retreive the current settings
+ Use 'Set-DesktopMetric [-Metric] Icon [-FontSize] 14' to change the settings

[] Denotes optional
# See Also:
+ ...

# Setup
### For Xxx-StandAlone scripts usage: 
#### How To copy StandAlone Script(s)
+ Double-click the 'Xxx-StandAlone.ps1' script you are interested in to see its contents.
+ *** Always carefully scan the script for safety ***
+ Copy its contents

#### How load (and store) the Script's Cmdlets in the PowerShell ISE
+ Open the Powershell ISE
+ Open a new 'Untitled' document
+ Paste the Script
+ [Optional] Save the Script
+ Press F5 to load the Cmdlets for use

### For WindowsInsiderTools Module Setup
+ in work...
