#*------v convert-BinaryToDecimalStorageUnits.ps1 v------
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
    # 4:32 PM 9/1/2025 coerce all instances of the $size to double, it's defaulting to string on inbound string
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes. 
    * 12:48 PM 10/20/2021 updated CBH w source article link, added comments
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    convert-BinaryToDecimalStorageUnits.ps1 - Convert KiB|MiB|GiB|TiB|PiB binary storage units to bytes|mb|kb|gb|tb|pb.  Rationale:
    [Gigabytes and Gibibytes - What you need to know - Storage - Tech Explained - HEXUS.net - hexus.net/](https://hexus.net/tech/tech-explained/storage/1376-gigabytes-gibibytes-what-need-know/) :
    The answer lies in the correct representation of binary numbers. When talking about a binary number like computer memory or processor cache, where the memory is made up of a series of memory cells that hold single bits of information, the number of memory cells is always power of 2. For instance, 1024 bits of memory, what you'd likely usually call a kilobit, is 2^10 bits. However, kilo is a prefix for base-10 or decimal numbers, so it doesn't actually apply to that figure when it's a representation of a binary number. The correct prefix is instead kibi, so 1024 bits is really a kibibit.

That rule applies everywhere. So what you'd usually think of as 1GB, or 1 gigabyte, isn't 1,000,000,000 bytes. Giga is the decimal prefix, so when you say gigabyte it means 1,000,000,000 bytes, not the 1,073,741,824 bytes it actually is (1024 * 1024 * 1024, all binary representations). Gibibyte is the correct term, abbreviated as 1GiB. So you have 1GiB of system memory, not 1GB.

The most common exception, where it's very correct, is the hard disk, where 1GB of disk space does actually mean 1,000,000,000 bytes. That's why for every 1GB of hard disk space, you actually see around 950MiB of space in your operating system (regardless of whether the OS tells you that's MB, which it isn't!).

For small values, it's a rounding error difference between GB\GiB. But as the values grow they significantly diverge.
    Specific reason I wrote this: get-MediaInfoRaw() (MediaInfo.dll)'s native storage units ('binary') output is in '[KMGTP]iB' units, which I wanted converted to common [kmgtp]b decimal units.
    .PARAMETER Value
    String representation of a numeric size and units stated in 'KiB|MiB|GiB|TiB|PiB' [-value '1.39 GiB']
    .PARAMETER To
    Desired output metric (Bytes|KB|MB|GB|TB) [-To 'GB']
    .PARAMETER Decimals
    Decimal places of rounding[-Decimals 2]
    .OUTPUT
    Decimal size in converted decimal unit.
    .EXAMPLE
    $filesizeGB = '1.39 GiB' | convert-BinaryToDecimalStorageUnits -To GB -Decimals 2;
    Example converting a binary Gibibyte value into a decimal gigabyte value, rounded to 2 decimal places.
    .LINK
    https://hexus.net/tech/tech-explained/storage/1376-gigabytes-gibibytes-what-need-know/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    #[Alias('convert-xxx')]
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="String representation of a numeric size and units stated in 'KiB|MiB|GiB|TiB|PiB' [-value '1.39 GiB']")]
            #[ValidateNotNullOrEmpty()]
            [ValidatePattern('^([\d\.]+)((\s)*)([KMGTP]iB)$')]
            [string]$Value,
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Desired output metric (Bytes|KB}MB|GB|TB) [-To 'GB']")]
            [validateset('Bytes','KB','MB','GB','TB')]
            [string]$To='MB',
        [Parameter(HelpMessage="decimal places of rounding[-Decimals 2]")]
            [int]$Decimals = 4
    )
    if($value.contains(' ')){
        [double]$size,[string]$unit = $value.split(' ') ;
    } else {
        if($value  -match '^([\d\.]+)((\s)*)([KMGTP]iB)$'){
            # 4:32 PM 9/1/2025 coerce all instances of the size to double, it's defaulting to string on inbound string
            [double]$size = $matches[1] ;
            $unit = $matches[4] ;
        } ;
    }
    $smsg = "converting"
    switch ($unit){
        'PiB' {
            $smsg += " PiB" ;
            $inBytes = [double]($size * [math]::Pow(1024,5)) ; # pb-> pib would be gb/1024^5
        }
        'TiB' {
            # Tibibyte
            $smsg += " TiB" ;
            $inBytes = [double]($size * [math]::Pow(1024,4)) ; # tb-> tib would be gb/1024^4
        }
        'GiB' {
            # gibibyte
            $smsg += " GiB" ;
            write-verbose "converting  GiB -> $($To)" ;
            $inBytes = [double]($size * [math]::Pow(1024,3)) ; # gb-> gib would be gb/1024^3
        }
        'MiB' {
            # mebibyte
            $smsg += " MiB" ;
            write-verbose "converting  MiB -> $($To)" ;
            $inBytes = [double]($size * [math]::Pow(1024,2) ) ; # mb-> mib would be gb/1024^2
        }
        'KiB' {
            # kibibyte
            $smsg += " KiB" ;
            $inBytes = [double]($size * 1024 ) ; # kb-> kib would be gb/1024
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
}

#*------^ convert-BinaryToDecimalStorageUnits.ps1 ^------