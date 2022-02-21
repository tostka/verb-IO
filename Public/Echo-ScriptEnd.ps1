##*------v Function Echo-ScriptEnd v------
Function Echo-ScriptEnd {
    <#
    .SYNOPSIS
    Echo-ScriptEnd - Close Banner with Elapsed Timer (used with Echo-ScriptEnd or Echo-ScriptEnd)
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
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    # 8:51 AM 10/31/2014 ren'd EchoXXX to Echo-XXX
    # 11/6/2013
    .DESCRIPTION
    .EXAMPLE
    PS> Echo-ScriptEnd ; 
    PS> gci c:\windows\ | out-null ; 
    PS> Echo-ScriptEnd ; 
    Echo-ScriptEnd - Opening Banner with Elapsed Timer (used with Echo-ScriptEnd or Echo-ScriptEnd)
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [cmdletbinding()]
    Param()
    $sMsg = "Script End Time: " + (get-date).toshortdatestring() + "-" + (get-date).toshorttimestring()
    Write-Host $sMsg
    if ($sw -ne $null) { $sw.Stop() ; write-host -foregroundcolor green "Elapsed Time: (HH:MM:SS.ms)" $sw.Elapsed.ToString() }
} #*------^ END Function Echo-ScriptEnd ^------