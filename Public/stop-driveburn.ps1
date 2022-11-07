#*----------v Function stop-driveburn() v----------
Function stop-driveburn {
    <#
    .SYNOPSIS
    stop-driveburn - stop drive high IO processes that lag down workstation
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-10-05
    FileName    : stop-driveburn.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Performance,Workstation
    REVISIONS
    7:35 AM 10/5/2020 ported to verb-IO, updated tsksid/admin-incl-ServerCore.ps1
    * 8:48 AM 10/22/2019 added ldesk gatherproducts
    *11:34 AM 4/16/2019 rearranging cmd order
    * 11:46 AM 3/12/2019 rewrote/internalized the wsearch stop, updated the output to be write-hosts with timestamps
    *7:57 AM 2/27/2018 #36, was getting obj as output, tried out-string/out-default to see if we could clean it to just the id & name properties as string
    *9:04 AM 10/18/2017 found it picking up $whatif from ps, so added it as an explicit param (don't want a whatif, want them dead), added sig, added passthrough -whatif on the stop-indexing call
    *9:47 AM 5/5/2017 broke out, had it echo on matches, added pshelps, added process echos & results
    *7:01 AM 3/31/2017 added call to stop-indexing-win7.ps1
    *7:35 AM 3/20/2017 initial vers
    .DESCRIPTION
    stop-driveburn - stop drive high IO processes that lag down workstation
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    .EXAMPLE
    stop-driveburn
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    #>
    [CmdletBinding()]
    [Alias('sdb')]
    Param([Parameter(HelpMessage="Whatif Flag  [-whatIf]")][switch] $whatIf) ; 
    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):KILLING DRIVE SUCKERS!`nQUIT READING BY THE HARDDRIVE LIGHT!" ; 
    "LDIScn32","Cagent32","gatherproducts" | foreach {
        #"==Checking for $($_)" ;
        if($gp=get-process "$($_)" -ea 0 ){
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):PROCMATCH:Stopping proc:`n$(($gp | ft -auto ID,ProcessName|out-string).trim())" ; 
            $gp | stop-process -force -whatif:$($whatif)
        } else {
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):(no $($_) processes found)" ; 
        } ; 
    } ; 

    #  tack index stop in here too
    $stat=(Get-Service -Name wsearch).status ; 
    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):===Windows Search:Status:$($stat)" ; 
    if ($stat -eq 'Running') {
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):STOPPING WSEARCH SVC" ; 
        stop-Service -Name wsearch ; 
    } else { 
        write-verbose "$((get-date).ToString('HH:mm:ss')):(wsearch is *not* running)" ; 
    } ; 
    write-verbose "$((get-date).ToString('HH:mm:ss')):(waiting 5secs to close)" ; 
    #start-sleep -s 5 ; 
} ;
#*------^ END Function stop-driveburn ^------
