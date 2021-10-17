#*------v Function convert-BinaryToDecimalStorageUnits v------
Function convert-BinaryToDecimalStorageUnits {
    <#
    .SYNOPSIS
    convert-BinaryToDecimalStorageUnits.ps1 - Convert KiB|MiB|GiB|TiB|PiB binary storage units to bytes|mb|kb|gb|tb|pb.  Rationale: 'kilo' is a prefix for base-10 or decimal numbers, which doesn't actually apply to that figure when it's a representation of a binary number (as memory etc represent). The correct prefix is instead kibi, so 1024 bits is really a kibibit.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : convert-BinaryToDecimalStorageUnits.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    REVISIONS
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    convert-BinaryToDecimalStorageUnits.ps1 - Convert KiB|MiB|GiB|TiB|PiB binary storage units to bytes|mb|kb|gb|tb|pb.  Rationale: 'kilo' is a prefix for base-10 or decimal numbers, which doesn't actually apply to that figure when it's a representation of a binary number (as memory etc represent). The correct prefix is instead kibi, so 1024 bits is really a kibibit.
    .PARAMETER Value
    String representation of an integer size and unit in 'KiB|MiB|GiB|TiB|PiB' [-value '1.39 GiB']
    .PARAMETER To
    Desired output metric (Bytes|KB}MB|GB|TB) [-To 'GB']
    .PARAMETER Decimals
    decimal places of rounding[-Decimals 2]
    .OUTPUT
    decimal size in converted decimal unit.
    .EXAMPLE
    $filesizeGB = '1.39 GiB' | convert-BinaryToDecimalStorageUnits -To GB -Decimals 2;
    Example converting a binary Gibibyte value into a decimal gigabyte value, rounded to 2 decimal places.
    .LINK
    https://github.com/tostka/verb-IO
    #>

    #[Alias('convert-
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="String representation of an integer size and unit in 'KiB|MiB|GiB|TiB|PiB' [-value '1.39 GiB']")]
        #[ValidateNotNullOrEmpty()]
        [ValidatePattern("^([\d\.]+)((\s)*)([KMGTP]iB)$")]
        [string]$Value,
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Desired output metric (Bytes|KB}MB|GB|TB) [-To 'GB']")]
        [validateset('Bytes','KB','MB','GB','TB')]
        [string]$To='MB',
        [Parameter(HelpMessage="decimal places of rounding[-Decimals 2]")]
        [int]$Decimals = 4
    )
    if($value.contains(' ')){
        $size,$unit = $value.split(' ') ;
    } else {
        if($value  -match '^([\d\.]+)((\s)*)([KMGTP]iB)$'){
            $size = $matches[1] ;
            $unit = $matches[4] ;
        } ;
    }
    $smsg = "converting"
    switch ($unit){
        'PiB' {
            $smsg += " PiB" ;
            $inBytes = [double]($size * [math]::Pow(1024,5)) ;            
        }
        'TiB' {
            # Tibibyte
            $smsg += " TiB" ;
            $inBytes = [double]($size * [math]::Pow(1024,4)) ;
        }
        'GiB' {
            # gibibyte
            $smsg += " GiB" ;
            write-verbose "converting  GiB -> $($To)" ;
            $inBytes = [double]($size * [math]::Pow(1024,3)) ;
        }
        'MiB' {
            # mebibyte
            $smsg += " MiB" ; 
            write-verbose "converting  MiB -> $($To)" ;
            $inBytes = [double]($size * [math]::Pow(1024,2) ) ;
        }
        'KiB' {
            # kibibyte
            $smsg += " KiB" ;
            $inBytes = [double]($size * 1024 ) ;
        }
        'Bytes' {
            $smsg += " Bytes" ; 
            $inBytes = [double]($size) ; 
        }
    } ;
    $smsg += " -> $($To) (round $($Decimals) places)" ; 
    write-verbose $smsg  ;
    switch($To){
        "Bytes" {$inBytes | write-output }
        "KB" {$output = $inBytes/1KB}
        "MB" {$output = $inBytes/1MB}
        "GB" {$output = $inBytes/1GB}
        "TB" {$output = $inBytes/1TB}
    } ;
    [Math]::Round($output,$Decimals,[MidPointRounding]::AwayFromZero) | write-output ;
} ; 
#*------^ END Function convert-BinaryToDecimalStorageUnits ^------