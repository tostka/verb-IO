#*------v Function Remove-JsonComments v------
Function Remove-JsonComments{ 
    <#
    .SYNOPSIS
    Remove-JsonComments.ps1 - Removes \\Comments from JSON, to permit ConvertFrom-JSON in ps5.1, to properly process json (PsCv7 ConvertFrom-JSON handles wo issues).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-05
    FileName    : Remove-JsonComments.ps1
    License     : (none-asserted)
    Copyright   : (none-asserted)
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell
    AddedCredit : Paul Harrison
    AddedWebsite:	https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/parsing-json-with-powershell/ba-p/2768721
    AddedTwitter:	URL
    REVISIONS
    * 1:37 PM 10/5/2021 added CBH, and minor formatting. 
    * Sep 20 2021 02:25 PM PaulH's posted version
    .DESCRIPTION
    Remove-JsonComments.ps1 - Removes \\Comments from JSON, to permit ConvertFrom-JSON in ps5.1, to properly process json (PsCv7 ConvertFrom-JSON handles comments wo issues).
    Comments will prevent ConvertFrom-Json from working properly in PowerShell 5.1.  I like to use this simple function to fix my JSON for me. 
    .PARAMETER  File
[string] The JSON file from which to remove \\Comments.[-File c:\path-to\file.json]
    .EXAMPLE
    PS> Remove-Comments .\test.json 
    .LINK
    https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/parsing-json-with-powershell/ba-p/2768721
    .LINK
    https://github.com/tostka/verb-IO
    #>
    PARAM( 
        [CmdletBinding()] 
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0,HelpMessage="[string] The JSON file from which to remove \\Comments.[-File c:\path-to\file.json]")] 
        [ValidateScript({test-path $_})] 
        [string] $File 
    )  ; 
    $CComments = "(?s)/\\*.*?\\*/"  ; 
    $content = Get-Content $File -Raw  ; 
    [regex]::Replace($content,$CComments,"") | Out-File $File -Force  ; 
}  ; 
#*------^ END Function Remove-JsonComments ^------
