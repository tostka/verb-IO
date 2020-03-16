function Expand-ZIPFile {
    <#
    .SYNOPSIS
    VERB-NOUN.ps1 - 1LINEDESC
    .NOTES
    Author: Taylor Gibb
    Website:	https://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Additional Credits:
    REVISIONS   :
    * 7:28 AM 3/14/2017 updated tsk: pshelp, param() block, OTB format
    * 06/13/13 (posted version)
    .DESCRIPTION
    .PARAMETER  Destination
    Destination for zip file contents [-Destination c:\path-to\]
    .PARAMETER  File
    File [-file c:\path-to\file.zip]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    Expand-ZIPFile -File "C:\pathto\file.zip" -Destination "c:\pathdest\" ;
    .LINK
    https://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
    #>

    # ($file, $destination)
    Param(
        [Parameter(HelpMessage = "Path [-Destination c:\path-to\]")]
        [ValidateScript( { Test-Path $_ -PathType 'Container' })][string]$Destination,
        [Parameter(HelpMessage = "File [-file c:\path-to\file.ext]")]
        [ValidateScript( { Test-Path $_ })][string]$File,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) # PARAM BLOCK END
    $shell = new-object -com shell.application ;
    $zip = $shell.NameSpace($file) ;
    foreach ($item in $zip.items()) {
        $shell.Namespace($destination).copyhere($item) ;
    } ;
}
