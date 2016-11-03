# Under construction, use at own risk

# WindowsInsiderTools - BETA 0.0.6.33, Nov 2016

+ Handy PowerShell Module for Windows Insider members

# HOT

+ New-GitBranche (ngb) [-NewRevision]
+ Example: PS >ngb -NewRevision

+ New-GitCommit (ngc) [-Commend] <comment>
+ Example: PS >ngc 'README.md Updates'

+ Open-Workspace (ows) [-UnCommitted]
+ Example: PS >ows githelp commit
+ Example: PS >ows tab .\README.md
+ Example: PS >ows Issue
+ Example: PS >ows Issue 42

# Summary

+ in work...
+ PowerShell, Git and (optional) Posh-Git integration
+ Improved PowerShell (ISE) usage: See Workspaces

# Introduction

+ After Installing the WindowsInsiderTools module start with:

        PS >gos

+ This will get you...
    
        PS >
        PS >NN Machine Description  Mem-Free Disk Status  Vol-Free Ring OS-Build        OS-Edition Arch.  Act  AV-Definition Scanned Scan 
        PS >-- ------- -----------  -------- ---- ------  -------- ---- --------        ---------- -----  ---  ------------- ------- ---- 
        PS >.  COMPPSA Computer PSA  13,0 GB SSD  Healthy  47,2 GB Fast 10.0.14955.1000 Win 10 Pro 64-bit Todo 1.231.1020.0  Nov 2   Quick
        PS >

+ Now start a WitSession to another machine...
    
        PS >
        PS ># Tip: nwit TABLETPSA tab
        PS >New-WitSession -ComputerName TABLETPSA -NickName tab
        PS > ...possible interactive Credential query...
        PS >
        PS >gos
        PS >
        PS >NN  Machine   Description  Mem-Free Disk Status  Vol-Free Ring OS-Build        OS-Edition Arch.  Act  AV-Definition Scanned Scan 
        PS >--  -------   -----------  -------- ---- ------  -------- ---- --------        ---------- -----  ---  ------------- ------- ---- 
        PS >.   COMPPSA   Computer PSA  12,6 GB SSD  Healthy  46,7 GB Fast 10.0.14955.1000 Win 10 Pro 64-bit Todo 1.231.1033.0  Nov 2   Quick
        PS >tab TABLETPSA Tablet PSA     5,9 GB SSD  Healthy  82,7 GB Fast 10.0.14955.1000 Win 10 Pro 64-bit Todo 1.231.1033.0  Nov 1   Quick
        PS >

+ To get recent Errors and Warnings from the System and Application EventLogs:

        PS >gev

+ This will get you...Please note that you see Events from multiple machines ( NN = NickName ) - Todo: time sort
    
        PS >
        PS >Time     Type NN  Machine      ID Source          Message                                                                                                                                   
        PS >----     ---- --  -------      -- ------          -------                                                                                                                                   
        PS >01:31:02 ERR  .   COMPPSA   10016 DCOM            The description for Event ID '10016' in Source 'DCOM' cannot be found.  The local computer may not have the necessary registry informat...
        PS >01:21:12 ERR  .   COMPPSA    1000 Application ... Faulting application name: MicrosoftEdge.exe, version: 11.0.14955.1000, time stamp: 0x580986fc...                                         
        PS >01:15:04 wrn  .   COMPPSA     642 ESENT           wuaueng.dll (8904) SUS20ClientDataStore: The database format feature version 8980 (0x2314) could not be used due to the current databas...
        PS >00:46:32 ERR  .   COMPPSA   10016 DCOM            The description for Event ID '10016' in Source 'DCOM' cannot be found.  The local computer may not have the necessary registry informat...
        PS >01:23:40 ERR  tab TABLETPSA 10016 DCOM            The description for Event ID '10016' in Source 'DCOM' cannot be found.  The local computer may not have the necessary registry informat...
        PS >01:23:36 ERR  tab TABLETPSA 10016 DCOM            The description for Event ID '10016' in Source 'DCOM' cannot be found.  The local computer may not have the necessary registry informat...
        PS >01:23:36 ERR  tab TABLETPSA 10016 DCOM            The description for Event ID '10016' in Source 'DCOM' cannot be found.  The local computer may not have the necessary registry informat...
        PS >01:23:36 ERR  tab TABLETPSA 10016 DCOM            The description for Event ID '10016' in Source 'DCOM' cannot be found.  The local computer may not have the necessary registry informat...
        PS >

# See Also:

+ Git CheatSheet: https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf
+ Git Workflow: https://guides.github.com/introduction/flow
+ Git Download: https://git-scm.com
+ Git in Powershell: https://github.com/dahlbyk/posh-git
+ Git Desktop: https://desktop.github.com/
