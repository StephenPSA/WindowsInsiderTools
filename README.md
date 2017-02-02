# *** Under construction, use at own risk ***

# WindowsInsiderTools - BETA 0.0.0.3, Feb 2017

## Workaround for 'Advanced Display Settings Missing In Build 15019', as discussed in the Windows Insiders Form here:
https://answers.microsoft.com/en-us/insider/forum/insider_wintp-insider_desktop/advanced-display-settings-missing-in-build-15019/59db2998-282e-4f6c-bd62-9dcaacb53936?page=6&msgId=42ac6d59-1bbb-466d-86ef-6eb56b48c0cf

# Summary
+ A couple of Powershell functions to get and set the Desktop Advanced Display Settings

# Usage Examples
+ **Get-DesktopMetric** or **gdm** to retrieve the current settings
+ **Set-DesktopMetric -Metric IconFont -FontSize 14** or **sdm IconFont 14** to change the size of the font as displayed under the icons on the desktop to 14 points
+ **Set-DesktopMetric -Metric CaptionFont, MenuFont -FontSize 14** or **sdm CaptionFont, MenuFont -14** to change the size of the Captions and Menu only
+ **Set-DesktopMetric All -FontSize 14** to set all fonts to 14 points
+ **Set-DesktopMetric All -RestoreOOTB** to restore the default value of 12 for all fonts

a) Options: **All, CaptionFont, SmCaptionFont, MenuFont, MessageFont, StatusFont, IconFont**

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
