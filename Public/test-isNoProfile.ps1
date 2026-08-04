# test-isNoProfile.ps1

#region TEST_ISNOPROFILE ; #*------v test-isNoProfile v------
function test-isNoProfile {
    <#
    .SYNOPSIS
    test-isNoProfile - test current Powershell (or ISE et al) Profile was loaded with -NoProfile
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2026-04-29
    FileName    : set-RDPFileSignatureTDO.ps1
    License     : MIT License
    Copyright   : (c) 2026 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    * 7:41 AM 8/3/2026 revised logic to fail back to get-wmiobject where get-ciminstance is unavail, added throws on fail.
    * 10:07 AM 4/29/2026 fixed bvorked help parsing: removed leading periods from all RDP file ext refs (confused parser on dotted help keywords) ; 
    * 12:59 PM 4/28/2026 init
    .DESCRIPTION
    test-isNoProfile - test current Powershell (or ISE et al) Profile was loaded with -NoProfile
    
    
        #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
        Copilot

        If you're trying to determine whether a PowerShell session was started with -NoProfile, there isn't a built-in variable like $NoProfile that reliably tells you after the fact.

        Option 1: Check the PowerShell process command line

        From within the current session:

        ```powershell
        $pid | ForEach-Object {
         (Get-CimInstance Win32_Process -Filter "ProcessId=$_").CommandLine
        }
        ```

        You can then test for it:

        ```powershell
        PowerShell
        $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID").CommandLine ; 
        $StartedWithNoProfile = $cmdLine -match '(?i)(?:^|\s)-NoProfile(?:\s|$)' ; 
        $StartedWithNoProfile ; 
        ```

        Option 2: Detect from another process (EDR/SIEM hunting)

        PowerShell launched with -NoProfile usually appears in process creation telemetry:

        Windows Event 4688

        Look for:

        powershell.exe -NoProfile
        or
        pwsh.exe -NoProfile

        Defender XDR KQL
        KQL
        DeviceProcessEvents

        | where FileName in~ ("powershell.exe", "pwsh.exe")

        | where ProcessCommandLine has "-NoProfile"

        | project Timestamp, DeviceName, FileName, ProcessCommandLine

        Sentinel / Log Analytics
        KQL
        SecurityEvent

        | where EventID == 4688

        | where CommandLine has "-NoProfile"

        Option 3: Infer from profile execution

        If you're trying to know within a running session whether profiles were skipped, you can set a marker in your profile:

        Profile:

        ```powershell
        $Global:ProfileLoaded = $true
        ```
        Session check:
        ```powershell
        if ($Global:ProfileLoaded) {
         "Profile loaded"
        }
        else {
         "Profile not loaded (possibly started with -NoProfile)"
        }
        ```

        This isn't foolproof (the profile could fail or be edited), but it's a useful administrative technique.

        Detection rule example
        ```powershell
        $cmdLine = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID").CommandLine
        if ($cmdLine -match '(?i)-NoProfile') {
         Write-Host "PowerShell started with -NoProfile"
        }else{
         Write-Host "PowerShell started without -NoProfile"
        }
        ```

        For security monitoring, the most reliable method is inspecting the process command line in process creation logs (4688, Sysmon Event ID 1, Defender XDR DeviceProcessEvents, etc.).

        #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    
    .INPUTS
    Accepts piped input Path 
    .OUTPUTS
    System.boolean
    .EXAMPLE
    PS> if (test-isNoProfile) {Write-Host "Started with -NoProfile"}
    PS> else{
    PS>     write-warning "powershell/powershell_ise -NoProfile`nlaunch may be required to ensure ipmo's run in proper order! (and `$isDesktop errors aren't spamming error stack)" ; 
    PS>     return ; 
    PS> } ; 
    Test, report results, return ("exit") if not -NoProfile
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('tNoPro')]
    PARAM() ;     
    #[boolean]((Get-CimInstance Win32_Process -Filter "ProcessId=$PID").CommandLine -match '-NoProfile|-nop') | write-output  ; 
    $fltr = "ProcessId=$PID" ;
    if (get-command get-ciminstance -ea 0) {$prc = (Get-CimInstance Win32_Process -Filter $fltr)} elseif($prc = Get-WmiObject Win32_Process -Filter $fltr){}else{throw "No CIM & WMI lookups failed (corrupt?)"} ;
    if($prc){[boolean]($prc.CommandLine -match '-NoProfile|-nop') | write-output}else{throw "Unable to isolate host process!"}  ;
} ; 
#endregion TEST_ISNOPROFILE ; #*------^ END test-isNoProfile ^------