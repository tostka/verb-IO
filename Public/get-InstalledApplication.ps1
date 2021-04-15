#*------v Function get-InstalledApplication v------
Function get-InstalledApplication {
    <#
    .SYNOPSIS
    get-InstalledApplication.ps1 - Check registry for Installed status of specified application (checks x86 & x64 Uninstall hives, for substring matches on Name)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : get-InstalledApplication
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
    REVISIONS
    * 9:13 AM 4/15/2021 init vers
    .DESCRIPTION
    get-InstalledApplication.ps1 - Check registry for Installed status of specified application (checks x86 & x64 Uninstall hives, for substring matches on Name)
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    if(get-InstalledApplication -name "powershell"){"yes"} else { "no"} ; 
    Default boolean test
    .EXAMPLE    
    get-InstalledApplication -name "powershell" -detail -verbose; 
    Example returning detail (DisplayName and InstallLocation)
    .LINK
    https://github.com/tostka/verb-ex2010
    .LINK
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,HelpMessage="Application Name substring[-Name Powershell]")]
        $Name,
        [Parameter(HelpMessage="Debugging Flag [-Return detailed object on match]")]
        [switch] $Detail
    ) ;
    $x86Hive = Get-ChildItem 'HKLM:Software\Microsoft\Windows\CurrentVersion\Uninstall' |
         % { Get-ItemProperty $_.PsPath } | ?{$_.displayname -like "*$($Name)*"} ;
    if(Test-Path 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'){
        #$x64Hive = ((Get-ChildItem "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        #    Where-Object { $_.'Name' -like "*$($Name)*" } ).Length -gt 0;
        $x64Hive = Get-ChildItem 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
            % { Get-ItemProperty $_.PsPath } | ?{$_.displayname -like "*$($Name)*"} ;
    }
    if(!$Detail){
        # boolean return:
        ($x86Hive -or $x64Hive) | write-output ; 
    } else { 
        $props = 'DisplayName','DisplayVersion','InstallLocation','Publisher' ;
        $x86Hive | Select $props | write-output ; 
        $x64Hive | Select $props | write-output ; 
    } ; 
} #*------^ END Function get-InstalledApplication ^------
