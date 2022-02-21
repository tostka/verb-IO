#*------v Function Get-FsoShortName v------
Function Get-FsoShortName {
    <#
    .SYNOPSIS
    Get-FsoShortName - Return ShortName (8.3) for specified Filesystem object
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 7:40 AM 3/29/2016 - added string->path conversion
    * 2:16 PM 3/28/2016 - functional version, no param block
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns Shortname for specified FSO('s) to the pipeline
    .EXAMPLE
    get-childitem "C:\Program Files\DellTPad\Dell.Framework.Library.dll" | get-fsoshortname ;
    # Retrieve ShortName for a file
    .EXAMPLE
    get-childitem ${env:ProgramFiles(x86)} | get-fsoshortname ;
    Retrieve Shortname for contents of the folder specified by the 'Program Files(x86)' environment variable
    .EXAMPLE
    PS> $blah="C:\Program Files (x86)\Log Parser 2.2","C:\Program Files (x86)\Log Parser 2.2\SyntaxerHighlightControl.dll" ;
    PS> $blah | get-fsoshortname ;
    Resolve path specification(s) into ShortNames
    .LINK
    https://blogs.technet.microsoft.com/heyscriptingguy/2013/08/01/use-powershell-to-display-short-file-and-folder-names/
    #>
    BEGIN { $fso = New-Object -ComObject Scripting.FileSystemObject } ;
    PROCESS {
        if($_){
            $fo=$_;
            # 7:25 AM 3/29/2016 add string-path support
            switch ($fo.gettype().fullname){
                "System.IO.FileInfo" {write-output $fso.getfile($fo.fullname).ShortName}
                "System.IO.DirectoryInfo" {write-output $fso.getfolder($fo.fullname).ShortName}
                "System.String" {
                    # if it's a gci'able path, convert to fso object and then recurse back through
                    if($fio=get-childitem -Path $fo -ea 0){$fio | Get-FsoShortName }
                    else{write-error "$($fo) is a string variable, but does not reflect the location of a filesystem object"}
                }
                default { write-error "$($fo) is not a filesystem object" }
            } ;
        } else { write-error "$($fo) is not a filesystem object" } ;
    }  ;
}
#*------^ END Function Get-FsoShortName ^------ ;