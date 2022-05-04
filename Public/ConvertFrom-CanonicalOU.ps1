#*------v ConvertFrom-CanonicalOU.ps1 v------
function ConvertFrom-CanonicalOU {
    <#
    .SYNOPSIS
    ConvertFrom-CanonicalOU.ps1 - This function takes a canonical OU path and converts it to a distinguished name.
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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes. 
    * 12:26 PM 6/18/2021 added alias:ConvertTo-DNOU
    * 4:30 PM 12/15/2020 TSK: expanded CBH,
    .DESCRIPTION
    ConvertFrom-CanonicalOU.ps1 - This function takes a canonical OU path and converts it to a distinguished name.
    .PARAMETER  CanonicalName
    CanonicalName Name
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    DistinguishedName Name
    .EXAMPLE
    PS> Get-OrganizationalUnit 'OU=Users,OU=SITE,DC=SUB,DC=SUB2,DC=DOMAIN,DC=com' | select -expand distinguishedname | ConvertTo-CanonicalName | ConvertFrom-CanonicalOU
        OU=Users,OU=SITE,DC=SUB,DC=SUB2,DC=DOMAIN,DC=com
    Convert OU distinguishedname to Canonical format, and back to OU DistinguishedName
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('ConvertTo-DNOU')]
    [cmdletbinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [ValidateNotNullOrEmpty()]
        [string]$CanonicalName
    )
    process {
        $obj = $CanonicalName.Replace(',','\,').Split('/')
        [string]$DN = "OU=" + $obj[$obj.count - 1]
        for ($i = $obj.count - 2;$i -ge 1;$i--){$DN += ",OU=" + $obj[$i]}
        $obj[0].split(".") | ForEach-Object { $DN += ",DC=" + $_}
        return $DN
    }
}

#*------^ ConvertFrom-CanonicalOU.ps1 ^------