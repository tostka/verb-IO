#*------v Function Shorten-Path v------
    function Shorten-Path([string] $path) {
        <#
    .SYNOPSIS
    Shorten-Path - Abbreviates path entries to the first letter of all but the most leaf dir
    .NOTES
    Author: from winterdom.com
    Website:	winterdom.com
    Twitter:
    REVISIONS   :
    12:25 PM 11/2/2015 - added pshelp
    .DESCRIPTION
    Shorten-Path - Abbreviates path entries to the first letter of all but the most leaf dir
    c:\usr\work\exch\scripts becomes: C:\u\w\e\scripts
    .INPUTS
    Takes a standard path string
    .OUTPUTS
    Output's the abbreviated path
    .EXAMPLE
    write-host (shorten-path (pwd).Path) -n -f $cloc
    .LINK
    #>
        $loc = $path.Replace($HOME, '~')
        # remove prefix for UNC paths
        $loc = $loc -replace '^[^:]+::', ''
        # make path shorter like tabs in Vim,
        # handle paths starting with \\ and . correctly
        return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)', '\$1$2')
    } #*------^ END Function Shorten-Path ^------