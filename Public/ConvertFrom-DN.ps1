#*----------v Function ConvertFrom-DN() v----------
function ConvertFrom-DN {
    <#
    .SYNOPSIS
    ConvertFrom-DN.ps1 - This function takes a distinguished name and converts it to a cononical name.
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
    * 4:30 PM 12/15/2020 TSK: expanded CBH, 
    .DESCRIPTION
    .PARAMETER  DistinguishedName
    Distinguished Name
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Canonical Name
    .EXAMPLE
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [cmdletbinding()]
    param(
      [Parameter(Mandatory,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
      [ValidateNotNullOrEmpty()]
      [string[]]$DistinguishedName
    )

    process 
    {
        foreach ($DN in $DistinguishedName) 
        {
            foreach ( $item in ($DN.replace('\,','~').split(","))) 
            {
                switch ($item.TrimStart().Substring(0,2)) 
                {
                    'CN' {$CN = '/' + $item.Replace("CN=","")}

                    'OU' {$OU += ,$item.Replace("OU=","");$OU += '/'}

                    'DC' {$DC += $item.Replace("DC=","");$DC += '.'}

                }
            } 

            $CanonicalName = $DC.Substring(0,$DC.length - 1)

            for ($i = $OU.count;$i -ge 0;$i -- )
            {
                $CanonicalName += $OU[$i]
            }

            if ( $DN.Substring(0,2) -eq 'CN' ) 
            {
                $CanonicalName += $CN.Replace('~','\,')
			}
            Write-Output $CanonicalName
        }
    }
}
#*------^ END Function ConvertFrom-DN ^------
