##*------v Function Echo-Finish v------
Function Echo-Finish {
    <#
    .SYNOPSIS
    Echo-Finish - Close Banner with Elapsed Timer (used with Echo-Finish or Echo-ScriptEnd)
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
    Echo-Finish - Opening Banner with Elapsed Timer (used with Echo-Finish or Echo-ScriptEnd)
    .EXAMPLE
    PS> Echo-Finish ; 
    PS> gci c:\windows\ | out-null ; 
    Echo-Finish ; 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [cmdletbinding()]
    Param()
    Write-Host " "
    $sMsg = "Completed Time: " + (get-date).toshortdatestring() + "-" + (get-date).toshorttimestring()
    Write-Host $sMsg
    # stop .NET Stopwatch object & echo elapsed time
    if ($sw -ne $null) { $sw.Stop() ; write-host -foregroundcolor green "Elapsed Time: (HH:MM:SS.ms)" $sw.Elapsed.ToString() }
    Write-Host " "
} #*------^ END Function Echo-Finish ^------