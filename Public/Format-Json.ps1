#*------v Function Format-Json v------
function Format-Json {
    <#
    .SYNOPSIS
    Format-Json.ps1 - Prettifies JSON output.
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : Format-Json.ps1
    License     : (none asserted)
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Json
    AddedCredit : Theo
    AddedWebsite: https://stackoverflow.com/users/9898643/theo
    AddedTwitter: 
    REVISIONS
    * 9:09 AM 10/4/2021 minor reformatting, expansion of CBH
    * 5/27/2019 - Theo posted version (stackoverflow answer)
    .DESCRIPTION
    Format-Json.ps1 - Reformats a JSON string so the output looks better than what ConvertTo-Json outputs.
    In effect it can take a Minified/compressed output (as MS AAD produces for audit logs):
    #-=-=-=-=-=-=-=-=
    [{"id":"59b5c4e8-a576-4aff-84ab-ffd76f605500","createdDateTime":"2019-04-19T14:27:07.7126929+00:00","userDisplayName":"USER NAME","userPrincipalName":"UPN@DOMAIN.COM","userId":"[GUID]","appId":"00000002-0000-0ff1-ce00-000000000000","appDisplayName":"Office 365 Exchange Online","resourceId":"00000002-0000-0ff1-ce00-000000000000","resourceDisplayName":"office 365 exchange online","ipAddress":"192.168.1.1","status":{"signInStatus":"Success","errorCode":0,"failureReason":null,"additionalDetails<TRIMMED>},
    #-=-=-=-=-=-=-=-=
    ... and convert it to a properly indented, human-friendly arrangement:
    #-=-=-=-=-=-=-=-=
    [
        {
            "id": "59b5c4e8-a576-4aff-84ab-ffd76f605500",
            "createdDateTime": "2019-04-19T14:27:07.7126929+00:00",
            "userDisplayName": "USER NAME",
            "userPrincipalName": "UPN@DOMAIN.COM",
            "userId": "[GUID]",
            "appId": "00000002-0000-0ff1-ce00-000000000000",
            "appDisplayName": "Office 365 Exchange Online",
            "resourceId": "00000002-0000-0ff1-ce00-000000000000",
            "resourceDisplayName": "office 365 exchange online",
            "ipAddress": "192.168.1.1",
            "status": {
                "signInStatus": "Success",
                "errorCode": 0,
                "failureReason": null,
                "additionalDetails": null
            },
            <TRIMMED>
        },
    #-=-=-=-=-=-=-=-=

    .PARAMETER Json
    Required: [string] The JSON text to prettify.
    .PARAMETER Minify
    Optional: Returns the json string compressed.
    .PARAMETER Indentation
    Optional: The number of spaces (1..1024) to use for indentation. Defaults to 4.
    .PARAMETER AsArray
    Optional: If set, the output will be in the form of a string array, otherwise a single string is output.
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    System.Boolean
    [| get-member the output to see what .NET obj TypeName is returned, to use here]
    .EXAMPLE
    PS> $json | ConvertTo-Json  | Format-Json -Indentation 2
    .EXAMPLE
    $json = Get-Content 'D:\script\test.json' -Encoding UTF8 | ConvertFrom-Json
    $json.yura.ContentManager.branch = 'test'
    # recreate the object as array, and use the -Depth parameter (your json needs 3 minimum)
    ConvertTo-Json @($json) -Depth 3 | Format-Json | Set-Content "D:\script\test1.json" -Encoding UTF8
    # instead of using '@($json)' you can of course also recreate the array by adding the square brackets manually:
    # '[{0}{1}{0}]' -f [Environment]::NewLine, ($json | ConvertTo-Json -Depth 3) |
    #        Format-Json | Set-Content "D:\script\test1.json" -Encoding UTF8
    .LINK
    https://stackoverflow.com/questions/56322993/proper-formating-of-json-using-powershell#56324247
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding(DefaultParameterSetName = 'Prettify')]
    PARAM(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true,HelpMessage="[string] The JSON text to prettify.[-Json `$jsontext]")]
        [string]$Json,
        [Parameter(ParameterSetName = 'Minify',HelpMessage="Returns the json string compressed.[-Minify SAMPLEINPUT]")]
        [switch]$Minify,
        [Parameter(ParameterSetName = 'Prettify',HelpMessage="The number of spaces (1..1024) to use for indentation. Defaults to 4.[-Indentation 2]")]
        [ValidateRange(1, 1024)]
        [int]$Indentation = 4,
        [Parameter(ParameterSetName = 'Prettify',HelpMessage="If set, the output will be in the form of a string array, otherwise a single string is output.[-AsArray]")]
        [switch]$AsArray
    ) ;
    if ($PSCmdlet.ParameterSetName -eq 'Minify') {
        return ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 -Compress ; 
    } ; 
    # If the input JSON text has been created with ConvertTo-Json -Compress
    # then we first need to reconvert it without compression
    if ($Json -notmatch '\r?\n') {
        $Json = ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 ; 
    } ; 
    $indent = 0 ; 
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)' ; 
    $result = $Json -split '\r?\n' |
        ForEach-Object {
            # If the line contains a ] or } character,
            # we need to decrement the indentation level unless it is inside quotes.
            if ($_ -match "[}\]]$regexUnlessQuoted") {
                $indent = [Math]::Max($indent - $Indentation, 0) ; 
            } ; 
            # Replace all colon-space combinations by ": " unless it is inside quotes.
            $line = (' ' * $indent) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ') ; 
            # If the line contains a [ or { character,
            # we need to increment the indentation level unless it is inside quotes.
            if ($_ -match "[\{\[]$regexUnlessQuoted") {
                $indent += $Indentation ; 
            } ; 
            $line ; 
        }
    if ($AsArray) { return $result } ; 
    return $result -Join [Environment]::NewLine ; 
} ; 
#*------^ END Function Format-Json ^------