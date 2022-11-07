function Get-FileEncoding {
    <#
    .SYNOPSIS
    Get-FileEncoding.ps1 - Gets Simple subset file encoding (compatible with Set-Content -encoding param)
    .NOTES
    Version     : 1.0.1
    Author:     : Andy Arismendi
    Website     : https://stackoverflow.com/questions/9121579/powershell-out-file-prevent-encoding-changes
    CreatedDate : 2012-2-2
    FileName    : 
    License     : 
    Copyright   : 
    Github      : 
    Tags        : Powershell,Filesystem,Encoding
    REVISIONS
    * 2:08 PM 11/7/2022 updated CBH example3 to reset to UTF8 (vs prior Ascii); added examples for running the entire source tree recursive, and added example echos of the per-file processing.
    * 3:08 PM 2/25/2020 re-implemented orig code, need values that can be fed back into set-content -encoding, and .net encoding class doesn't map cleanly (needs endian etc, and there're a raft that aren't supported). Spliced in UTF8BOM byte entries from https://superuser.com/questions/418515/how-to-find-all-files-in-directory-that-contain-utf-8-bom-byte-order-mark/914116
    * 2/12/2012 posted vers
    .DESCRIPTION
    Get-FileEncoding() - Gets file encoding..
    The Get-FileEncoding function determines encoding by looking at Byte Order Mark (BOM).
    http://unicode.org/faq/utf_bom.html
    http://en.wikipedia.org/wiki/Byte_order_mark
    Missing: 
    UTF8BOM: Encodes in UTF-8 format with Byte Order Mark (BOM)
    UTF8NoBOM: Encodes in UTF-8 format without Byte Order Mark (BOM)
    UTF32: Encodes in UTF-32 format.
    OEM: Uses the default encoding for MS-DOS and console programs.
    ## code to dump first 9 bytes of each:
    ```ps
    $encodingS = "unicode","bigendianunicode","utf8","utf7","utf32","ascii","default","oem" ;foreach($encoding in $encodings){    "`n==$($encoding):" ;    Get-Date | Out-File date.txt -Encoding $encoding ;    [byte[]] $x = get-content -encoding byte -path .\date.txt -totalcount 9 ;    $x | format-hex ;} ; 
    ```
    
    .PARAMETER Path
    The Path of the file that we want to check.
    .PARAMETER DefaultEncoding
    The Encoding to return if one cannot be inferred.
    You may prefer to use the System's default encoding:  [System.Text.Encoding]::Default
    List of available Encodings is available here: http://goo.gl/GDtzj7
    One's commonly seen dumping uwes:
    System.Text.ASCIIEncoding
    System.Text.UTF8Encoding
    System.Text.UnicodeEncoding
    System.Text.UTF32Encoding
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Text.Encoding
    .EXAMPLE
    PS> Get-ChildItem  *.ps1 | ?{$_.length -gt 0} | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'UTF8'} | ft -a ; 
    This command gets ps1 files in current directory (with non-zero length) where encoding is not UTF8 ;
    .EXAMPLE
    PS> $Encoding = 'UTF8' ; 
    PS> Get-ChildItem  *.ps1 | ?{$_.length -gt 0} | 
    PS>    select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | 
    PS>    where {$_.Encoding -ne $Encoding} | foreach-object { 
    PS>        write-host "==$($_.fullname):" ; 
    PS>        (get-content $_.FullName) | set-content $_.FullName -Encoding $Encoding -whatif ;
    PS>    } ;
    Gets ps1 files in current directory (with non-zero length) where encoding is not UTF8, and then sets encoding to UTF8 using set-content ;
    .EXAMPLE
    PS> $Encoding = 'UTF8' ;
    PS> Get-ChildItem  c:\sc\*.ps1 -recur | ?{$_.length -gt 0} |
    PS>     select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} |
    PS>     where {$_.Encoding -ne $Encoding}  | ft -a ; 
        FullName                        Encoding
        --------                        --------
        C:\sc\AADInternals\MDM.ps1      ASCII
        C:\sc\AADInternals\OneDrive.ps1 ASCII
    Demo recursing down the entire c:\sc source tree, and reporting non-UTF8s
    .EXAMPLE
    PS> $Encoding = 'UTF8' ;
    PS> Get-ChildItem  c:\sc\*.ps1 -recur | ?{$_.length -gt 0} |
    PS>     select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} |
    PS>     where {$_.Encoding -ne $Encoding} | foreach {
    PS>         write-host "==$($_.fullname):" ;
    PS>         (get-content $_.FullName) | set-content $_.FullName -Encoding $Encoding -whatif ;
    PS>     } ;
    Demo recursing source tree, and coercing non-UTF8 PS1's to UTF8.
    .LINK
    https://github.com/tostka/verb-io
    http://franckrichard.blogspot.com/2010/08/powershell-get-encoding-file-type.html
    https://gist.github.com/jpoehls/2406504
    http://goo.gl/XQNeuc
    http://poshcode.org/5724
    #>
    [CmdletBinding()]
    Param ([Alias("PSPath")][Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)][string]$Path) ;
    process {
        [byte[]] $byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path ; 
        if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )
            { $encoding = 'UTF8' }  
        elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
            { $encoding = 'BigEndianUnicode' }
        elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe)
             { $encoding = 'Unicode' } # AKA UTF-16LE/Little-endian-Unicode
        elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
            { $encoding = 'UTF32' }
        elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76)
            { $encoding = 'UTF7'}
        elseif ($byte[0] -eq 0xEF -and $byte[1] -eq 0xBB -and $byte[2] -eq 0xBF)
            { $encoding = 'UTF8BOM'} 
        else
            { $encoding = 'ASCII' } # ascii/default/oem are identical first 9 bytes
        return $encoding
    } ;
}
