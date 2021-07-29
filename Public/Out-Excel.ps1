#Out-Excel.ps1

#*------v Function Out-Excel v------
function Out-Excel {
    <#
    .SYNOPSIS
    Out-Excel.ps1 - Simple func to deliver Excel as a out-gridview alternative.
    .NOTES
    Version     : 1.0.0
    Author      : heyscriptingguy
    Website     :	http://blogs.technet.com/b/heyscriptingguy/archive/2014/01/10/powershell-and-excel-fast-safe-and-reliable.aspx
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : Out-Excel.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Excel
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    # vers: * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
    # vers: 1/10/2014
    .DESCRIPTION
    Out-Excel.ps1 - Simple func to deliver Excel as a out-gridview alternative.
    .EXAMPLE
    PS> $obj | Out-Excel
    .EXAMPLE
    .LINK
    https://github.com/tostka/verb-IO
    #>
    PARAM($Path = "$env:temp\$(Get-Date -Format yyyyMMddHHmmss).csv")
    $input | Export-CSV -Path $Path -UseCulture -Encoding UTF8 -NoTypeInformation
    Invoke-Item -Path $Path
}#*------^ END Function Out-Excel ^------