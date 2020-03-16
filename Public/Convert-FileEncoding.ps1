function Convert-FileEncoding {
    <#
    .SYNOPSIS
    Convert-FileEncoding.ps1 - Converts files to the given encoding.
    .NOTES
    Author: jpoehls
    Website:	https://gist.github.com/jpoehls/2406504
    REVISIONS   :
    *  3:08 PM 6/16/2017 added more pshelp, added functional -whatif support
    * Apr 17, 2012 posted vers
    .DESCRIPTION
    Convert-FileEncoding.ps1 - Converts files to the given encoding.
    Matches the include pattern recursively under the given path.
    .PARAMETER Include
    File filter  [-include *.ps1]
    .PARAMETER Path
    Path [-path c:\path-to\]
    .PARAMETER Encoding
    Encoding [-encoding 'UTF8']
    Out-file Supports: unicode,bigendianunicode,utf8,utf7,utf32,ascii,default,oem
    .PARAMETER showDebug
    Debugging Flag [-showDebug]
    .PARAMETER whatIf
    Whatif Flag  [-whatIf]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    Convert-FileEncoding -Include *.js -Path scripts -Encoding UTF8 ;
    .EXAMPLE
    .LINK
    https://gist.github.com/jpoehls/2406504
    #>
    # switch -Path from required container, to something that can be resolved
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "File filter  [*.ps1]")]
        [string]$Include,
        [Parameter(HelpMessage = "Path [-path c:\path-to\]")]
        [ValidateScript( { Test-Path $_ -PathType 'Container' })][string]$Path,
        [Parameter(HelpMessage = "Encoding [-encoding 'UTF8']")]
        [string]$Encoding = 'UTF8',
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    )  ;
    BEGIN { $count = 0 } ; 
    PROCESS {
        Get-ChildItem -Include $Pattern -Recurse -Path $Path |
        select FullName, @{n = 'Encoding'; e = { Get-FileEncoding $_.FullName } } |
        where-object { $_.Encoding -ne $Encoding } | % {
            (Get-Content $_.FullName) |
            Out-File $_.FullName -Encoding $Encoding -whatif:$($whatif); $count++;
        } ;
    } ; 
    END {write-verbose -verbose:$true "$count $Pattern file(s) converted to $Encoding in $Path." } ; 
}
