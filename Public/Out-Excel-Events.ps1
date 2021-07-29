
#*------v Function Out-Excel-Events v------
function Out-Excel-Events {
<#
.SYNOPSIS
Out-Excel-Events.ps1 - Simple func() to deliver Excel as a out-gridview alternative, this variant massages array ReplacementStrings into a comma-delimited string.
.NOTES
Version     : 1.0.0
Author      : heyscriptingguy
Website     :	http://blogs.technet.com/b/heyscriptingguy/archive/2014/01/10/powershell-and-excel-fast-safe-and-reliable.aspx
Twitter     :	@tostka / http://twitter.com/tostka
CreatedDate : 2020-
FileName    : Out-Excel-Events.ps1 
License     : (none asserted)
Copyright   : (none asserted)
Github      : https://github.com/tostka/verb-XXX
Tags        : Powershell,Excel
REVISIONS
# vers: * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
# vers: 1/10/2014
.DESCRIPTION
Simple func() to deliver Excel as a out-gridview alternative, this variant massages array ReplacementStrings into a comma-delimited string.
.EXAMPLE
PS> $obj | Out-Excel-Events
.EXAMPLE
.LINK
https://github.com/tostka/verb-IO
#>
    PARAM($Path = "$env:temp\$(Get-Date -Format yyyyMMddHHmmss).csv")
    $input | Select -Property * |
    ForEach-Object {
        $_.ReplacementStrings = $_.ReplacementStrings -join ','
        $_.Data = $_.Data -join ','
        $_
    } | Export-CSV -Path $Path -UseCulture -Encoding UTF8 -NoTypeInformation
    Invoke-Item -Path $Path
}#*------^ END Function Out-Excel-Events ^------