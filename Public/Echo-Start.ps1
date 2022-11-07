##*------v Function Echo-Start v------
Function Echo-Start {
    <#
    .SYNOPSIS
    Echo-Start - Opening Banner with Elapsed Timer (used with Echo-Finish or Echo-ScriptEnd)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    # 3:21 PM 4/17/2020 added cbh
    # 8:51 AM 10/31/2014 ren'd EchoXXX to Echo-XXX
    .DESCRIPTION
    Echo-Start - Opening Banner with Elapsed Timer (used with Echo-Finish or Echo-ScriptEnd)
    .EXAMPLE
    PS> Echo-Start ; 
    PS> gci c:\windows\ | out-null ; 
    PS> Echo-Finish ; 
    Echo bracketing banners around a command
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [cmdletbinding()]
    Param()
    Write-Host " "
    # datetime stamp
    $sMsg = "Start Time: " + (get-date).toshortdatestring() + "-" + (get-date).toshorttimestring()
    # timestamp
    #$sMsg = "Time: " + (get-date).toshorttimestring()
    Write-Host $sMsg
    Write-Host " "
    # start .NET Stopwatch object
    $sw = [Diagnostics.Stopwatch]::StartNew()
} #*------^ END Function Echo-Start ^------
