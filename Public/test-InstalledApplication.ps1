#*------v Function test-InstalledApplication v------
Function test-InstalledApplication {
    <#
    .SYNOPSIS
    test-InstalledApplication.ps1 - Check registry for Installed status of specified application (checks x86 & x64 Uninstall hives, for substring matches on Name)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : test-InstalledApplication
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
    REVISIONS
    * 10:37 AM 11/11/2022 ren get-InstalledApplication -> test-InstalledApplication (better match for function, default is test -detailed triggers dump back); aliased orig name; also pulling in overlapping verb-desktop:check-ProgramInstalled(), aliased -Name with ported programNam ; CBH added expl output demo
    * 9:13 AM 4/15/2021 init vers
    .DESCRIPTION
    test-InstalledApplication.ps1 - Check registry for Installed status of specified application (checks x86 & x64 Uninstall hives, for substring matches on Name)
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    PS> if(test-InstalledApplication -name "powershell"){"yes"} else { "no"} ; 
    yes
    Default boolean test
    .EXAMPLE    
    PS> get-InstalledApplication -Name 'google drive' -detail
    DisplayName  DisplayVersion InstallLocation                                                      Publisher
    -----------  -------------- ---------------                                                      ---------
    Google Drive 63.0.5.0       C:\Program Files\Google\Drive File Stream\63.0.5.0\GoogleDriveFS.exe Google LLC
    Example returning detail (DisplayName and InstallLocation)
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('check-ProgramInstalled','get-InstalledApplication')]
    PARAM(
        [Parameter(Position=0,HelpMessage="Application Name substring[-Name Powershell]")]
        [Alias('programNam')]
        $Name,
        [Parameter(HelpMessage="Debugging Flag [-Return detailed object on match]")]
        [switch] $Detail
    ) ;
    $x86Hive = Get-ChildItem 'HKLM:Software\Microsoft\Windows\CurrentVersion\Uninstall' |
         % { Get-ItemProperty $_.PsPath } | ?{$_.displayname -like "*$($Name)*"} ;
    write-verbose "`$x86Hive:$([boolean]$x86Hive)" ; 
    if(Test-Path 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'){
        #$x64Hive = ((Get-ChildItem "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        #    Where-Object { $_.'Name' -like "*$($Name)*" } ).Length -gt 0;
        $x64Hive = Get-ChildItem 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
            % { Get-ItemProperty $_.PsPath } | ?{$_.displayname -like "*$($Name)*"} ;
         write-verbose "`$x64Hive:$([boolean]$x64Hive)" ; 
    }
    if(!$Detail){
        # boolean return:
        ($x86Hive -or $x64Hive) | write-output ; 
    } else { 
        $props = 'DisplayName','DisplayVersion','InstallLocation','Publisher' ;
        $x86Hive | Select $props | write-output ; 
        $x64Hive | Select $props | write-output ; 
    } ; 
} #*------^ END Function test-InstalledApplication ^------
