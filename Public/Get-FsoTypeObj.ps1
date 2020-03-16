Function Get-FsoTypeObj {
    <#
    .SYNOPSIS
    Get-FsoTypeObj()- convert file/dir object or path string to an fso obj
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Website:	URL
    Twitter:	URL
    REVISIONS   :
    * 1:37 PM 10/23/2017 Get-FsoTypeObj: simple reworking of get-fsoshortpath() to convert file/dir object or path string to an fso obj
    .DESCRIPTION
    .PARAMETER  PARAMNAME
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Resolves Dir/File/path string into an fso object
    .EXAMPLE
    Get-FsoTypeObj "C:\usr\work\exch\scripts\get-dbmbxsinfo.ps1"
    Resolve a path string into an fso file object
    .EXAMPLE
    Get-FsoTypeObj "C:\usr\work\exch\scripts\"
    Resolve a path string into an fso container object
    .EXAMPLE
    gci "C:\usr\work\exch\scripts\" | Get-FsoTypeObj ;
    Validates and returns an fso container object
    .EXAMPLE
    gci "C:\usr\work\exch\scripts\_.txt" | Get-FsoTypeObj ;
    Validates input is fso and returns an fso file object
    .LINK
    #>
    Param([Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Path or object to be resoved to fso")]$path) ;
    BEGIN {  } ;
    PROCESS {
        if($path){
            $fo=$path;
            switch ($fo.gettype().fullname){
                "System.IO.FileInfo" {$fo | write-output ; } ;
                "System.IO.DirectoryInfo" {$fo | write-output ; } ;
                "System.String" {
                    # if it's a gci'able path, convert to fso object and then recurse back through
                    if($fio=get-childitem -Path $fo -ea 0){$fio | Get-FsoTypeObj }
                    else{write-error "$($fo) is a string variable, but does not reflect the location of a filesystem object"} ;
                } ;
                default { write-error "$($fo) is not a filesystem object" } ;
            } ;
        } else { write-error "$($fo) is not a filesystem object" } ;
    }  ; # PROC-E
}
