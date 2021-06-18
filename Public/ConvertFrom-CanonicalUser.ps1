#*----------v Function ConvertFrom-CanonicalUser() v----------
function ConvertFrom-CanonicalUser {
    <#
    .SYNOPSIS
    ConvertFrom-CanonicalUser.ps1 - This function takes a canonical name and converts it to a distinguished name.
    .NOTES
    Version     : 1.0.0
    Author      : joegasper
    Website     :	https://gist.github.com/joegasper/3fafa5750261d96d5e6edf112414ae18
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-12-15
    FileName    : 
    License     : (not specified)
    Copyright   : (not specified)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,ActiveDirectory,DistinguishedName,CanonicalName,Conversion
    AddedCredit : Todd Kadrie
    AddedWebsite:	http://www.toddomation.com
    AddedTwitter:	@tostka / http://twitter.com/tostka
    AddedCredit : McMichael
    AddedWebsite:	https://github.com/timmcmic/DLConversion/blob/master/src/DLConversion.ps1
    REVISIONS
    * 12:26 PM 6/18/2021 added alias:ConvertTo-DNUser
    * 4:30 PM 12/15/2020 TSK: expanded CBH, 
    .DESCRIPTION
    ConvertFrom-CanonicalUser.ps1 - This function takes a canonical name and converts it to a distinguished name.
    .PARAMETER  DistinguishedName
    CanonicalName Name
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    DistinguishedName Name
    .EXAMPLE
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('ConvertTo-DNUser')]
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
        [ValidateNotNullOrEmpty()] 
        [string]$CanonicalName
    )
    process {
        $obj = $CanonicalName.Replace(',','\,').Split('/')
        [string]$DN = "CN=" + $obj[$obj.count - 1]
        for ($i = $obj.count - 2;$i -ge 1;$i--){$DN += ",OU=" + $obj[$i]}
        $obj[0].split(".") | ForEach-Object { $DN += ",DC=" + $_}
        return $DN
    }
} ; 
#*------^ END Function ConvertFrom-CanonicalUser ^------
