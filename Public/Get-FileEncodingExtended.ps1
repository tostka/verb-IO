function Get-FileEncodingExtended {
    <#
    .SYNOPSIS
    Get-FileEncodingExtended.ps1 - Gets file encoding..
    .NOTES
    Version     : 1.0.1
    Author: jpoehls
    Website:	https://gist.github.com/jpoehls/2406504
    CreatedDate : 2012-
    FileName    : 
    License     : 
    Copyright   : 
    Github      : https://gist.github.com/jpoehls/2406504
    Tags        : Powershell,Filesystem,Encoding
    REVISIONS
    * 3:08 PM 2/25/2020 tightened up, updated CBH, purged old rem'd codeblock
    * 8:21 AM 10/23/2017 Get-FileEncodingExtended: updated help pointers
    * 6:55 PM 6/18/2017 Get-FileEncodingExtended: spliced in: 2015/02/03, VertigoRay - Adjusted to use .NET's [System.Text.Encoding Class](http://goo.gl/XQNeuc). (http://poshcode.org/5724)
    * 6:25 PM 6/18/2017 tsk: fixed a few typos/vscode conversion encoding errors
    * 3:08 PM 6/16/2017 added more pshelp, OTB fmt
    * Apr 17, 2012 posted vers
    .DESCRIPTION
    Get-FileEncodingExtended() - Gets file encoding..
    The Get-FileEncodingExtended function determines encoding by looking at Byte Order Mark (BOM).
    Based on port of C# code from http://www.west-wind.com/Weblog/posts/197245.aspx
    Convert-FileEncoding.ps1 - Converts files to the given encoding.
    Matches the include pattern recursively under the given path.
    Modified by F.RICHARD August 2010
    add comment + more BOM
    http://unicode.org/faq/utf_bom.html
    http://en.wikipedia.org/wiki/Byte_order_mark
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
    Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncodingExtended $_.FullName}} | where {$_.Encoding -ne 'ASCII'} ;
    This command gets ps1 files in current directory where encoding is not ASCII ;
    .EXAMPLE
    Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncodingExtended $_.FullName}} | where {$_.Encoding -ne 'ASCII'} | foreach {(get-content $_.FullName) | set-content $_.FullName -Encoding ASCII} ;
    Same as previous example but fixes encoding using set-content ;
    .LINK
    http://franckrichard.blogspot.com/2010/08/powershell-get-encoding-file-type.html
    .LINK
    https://gist.github.com/jpoehls/2406504
    .LINK
    http://goo.gl/XQNeuc
    .LINK
    http://poshcode.org/5724
#>
    [CmdletBinding()]
    Param (
        [Alias("PSPath")]
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [string]$Path,
        [Parameter(Mandatory = $False)]
        [System.Text.Encoding]$DefaultEncoding = [System.Text.Encoding]::ASCII
    ) ;
    # 6:50 PM 6/18/2017 orig byte code, supplanted by use of .NET's [System.Text.Encoding Class]
    process {
        [Byte[]]$bom = Get-Content -Encoding Byte -ReadCount 4 -TotalCount 4 -Path $Path ;
        $encoding_found = $false ;
        foreach ($encoding in [System.Text.Encoding]::GetEncodings().GetEncoding()) {
            $preamble = $encoding.GetPreamble() ;
            if ($preamble) {
                foreach ($i in 0..$preamble.Length) {
                    if ($preamble[$i] -ne $bom[$i]) {
                        break ;
                    }
                    elseif ($i -eq $preable.Length) {
                        $encoding_found = $encoding ;
                    } ;
                } ;
            } ;
        } ;
        if (!$encoding_found) {
            $encoding_found = $DefaultEncoding ;
        } ;
        $encoding_found ;
    } ;
}
