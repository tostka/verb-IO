#*------v Function Get-FsoShortPath v------
    Function Get-FsoShortPath {
        <#
    .SYNOPSIS
    Get-FsoShortPath - Return ShortPath (8.3) for specified Filesystem object
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 7:40 AM 3/29/2016 - added string->path conversion
    * 7:15 AM 3/29/2016 - simple variant, returns the full path to the spec'd filesystem component in 8.3 format.
    * 2:16 PM 3/28/2016 - functional version, no param block
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns ShortPath for specified FSO('s) to the pipeline
    .EXAMPLE
    get-childitem "C:\Program Files\DellTPad\Dell.Framework.Library.dll" | get-fsoShortPath ;
    # Retrieve ShortPath for a file
    .EXAMPLE
    get-childitem ${env:ProgramFiles(x86)} | get-fsoShortPath ;
    Retrieve ShortPath for contents of the folder specified by the 'Program Files(x86)' environment variable
    .EXAMPLE
    $blah="C:\Program Files (x86)\Log Parser 2.2","C:\Program Files (x86)\Log Parser 2.2\SyntaxerHighlightControl.dll" ;
    $blah | get-fsoshortname ;
    Resolve path specification(s) into ShortPaths
    .LINK
    https://blogs.technet.microsoft.com/heyscriptingguy/2013/08/01/use-powershell-to-display-short-file-and-folder-names/
    *---^ END Comment-based Help  ^--- #>
        BEGIN { $fso = New-Object -ComObject Scripting.FileSystemObject } ;
        PROCESS {
            if ($_) {
                $fo = $_;
                switch ($fo.gettype().fullname) {
                    "System.IO.FileInfo" { write-output $fso.getfile($fo.fullname).ShortPath }
                    "System.IO.DirectoryInfo" { write-output $fso.getfolder($fo.fullname).ShortPath }
                    "System.String" {
                        # if it's a gci'able path, convert to fso object and then recurse back through
                        if ($fio = get-childitem -Path $fo -ea 0) { $fio | Get-FsoShortPath }
                        else { write-error "$($fo) is a string variable, but does not reflect the location of a filesystem object" }
                    }
                    default { write-error "$($fo) is not a filesystem object" }
                } ;
            }
            else { write-error "$fo is not a filesystem object" } ;
        }  ;
    }#*------^ END Function Get-FsoShortPath ^------ ;
