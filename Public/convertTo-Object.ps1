#*------v Function convertTo-Object v------
Function convertTo-Object {

    <#
    .SYNOPSIS
    convertTo-Object.ps1 - Pipeline filter that converts a stream of hashtables into an object, note not 3 nested objects in the Cobj, one Cobj with the single list of properties.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : convertTo-Object.ps1
    License     : (none-asserted)
    Copyright   : (none-asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Hashtable,PSCustomObject,Conversion
    AddedCredit : https://community.idera.com/members/tobias-weltner
    AddedWebsite:	https://community.idera.com/members/tobias-weltner
    AddedTwitter:	URL
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 12:26 PM 10/17/2021 init vers
    * 11/17/2008 Tobias Weltner's thread post. 
    .DESCRIPTION
    convertTo-Object.ps1 - Pipeline filter that converts a stream of hashtables into an object, note not 3 nested objects in the Cobj, one Cobj with the single list of properties.
    .PARAMETER hashtable
    String representation of an integer size and unit in 'KiB|MiB|GiB|TiB|PiB' [-value '1.39 GiB']
    .OUTPUT
    System.Object
    .EXAMPLE
    PS> $hash1 = @{name='Melzer';firstname='Tim';age=68} ;
    PS> $hash2 = @{id=12;count=100;remark='Second Hash Table'} ;
    PS> $cobj = $hash1, $hash2 | ConvertTo-Object ;  
    Combine hash1 & 2 into cobj customobject.  
    .LINK
    https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/converting-hash-tables-to-objects
    .LINK
    https://github.com/tostka/verb-IO
    #>

    #[Alias('convert-
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Hasthtable(s) to be converted into a single object[-hashtable `$hash]")]
        [string]$hashtable        
    )
    BEGIN { $object = New-Object Object } ; 
    PROCESS {
        $_.GetEnumerator() | ForEach-Object { Add-Member -inputObject $object -memberType NoteProperty -name $_.Name -value $_.Value }   ; 
    } ; 
    END { $object } ; 
} ; 
#*------^ END Function convertTo-Object ^------
