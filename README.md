# Under construction, use at own risk

# WindowsInsiderTools - BETA 0.0.6.31, Nov 2016

+ Handy PowerShell Module for Windows Insider members

# Introduction

+ After Installing the WindowsInsiderTools module start with:

        PS >gos

+ This will get you...
    
        PS >
        PS >NN Machine Description  Mem-Free Disk Status  Vol-Free Ring OS-Build        OS-Edition Arch.  Act  AV-Definition Scanned Scan 
        PS >-- ------- -----------  -------- ---- ------  -------- ---- --------        ---------- -----  ---  ------------- ------- ---- 
        PS >.  COMPPSA Computer PSA  13,0 GB SSD  Healthy  47,2 GB Fast 10.0.14955.1000 Win 10 Pro 64-bit Todo 1.231.1020.0  Nov 2   Quick
        PS >

+ To get recent Errors and Warnings from the System and Application EventLogs:

        PS >gev

+ This will get you...
    
        PS >
        PS >Time     Type NN Machine    ID Source          Message                                                                                                                                      
        PS >----     ---- -- -------    -- ------          -------                                                                                                                                      
        PS >22:07:06 ERR  .  COMPPSA  1000 Application ... Faulting application name: taskhostw.exe, version: 10.0.14955.1000, time stamp: 0x58098a46...                                                
        PS >21:47:48 ERR  .  COMPPSA 10016 DCOM            The description for Event ID '10016' in Source 'DCOM' cannot be found.  The local computer may not have the necessary registry information...
        PS >21:15:04 wrn  .  COMPPSA   642 ESENT           wuaueng.dll (780) SUS20ClientDataStore: The database format feature version 8980 (0x2314) could not be used due to the current database fo...
        PS >

# See Also:

+ Git CheatSheet: https://services.github.com/kit/downloads/github-git-cheat-sheet.pdf
+ Git Workflow: https://guides.github.com/introduction/flow
+ Git Download: https://git-scm.com
+ Git in Powershell: https://github.com/dahlbyk/posh-git
+ Git Desktop: https://desktop.github.com/
