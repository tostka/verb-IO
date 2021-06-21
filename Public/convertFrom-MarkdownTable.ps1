#*------v Function convertFrom-MarkdownTable v------
Function convertFrom-MarkdownTable {
    <#
    .SYNOPSIS
    convertFrom-MarkdownTable.ps1 - Converts a Markdown table to a PowerShell object.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-21
    FileName    : convertFrom-MarkdownTable.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Markdown,Input,Conversion
    REVISION
    * 6:21 PM 6/21/2021 init, minor bug in raw input from herestring md table (not trimming trailing border off title line.
    .DESCRIPTION
    convertFrom-MarkdownTable.ps1 - Converts a Markdown table to a PowerShell object.
    Also supports convesion of variant 'border' md table syntax (e.g. each line wrapped in outter pipe | chars)
    Intent is as a simpler alternative to here-stringinputs for csv building. 
    .PARAMETER markdowntext
    Markdown-formated table to be converted into an object [-markdowntext 'title text']
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    String
   .EXAMPLE
   PS> Get-Service Bits,Winrm | select status,name,displayname | convertTo-MarkdownTable | ConvertFrom-MarkDownTable ; 
   Convert Service listing to and back from MD table. 
   .EXAMPLE
   -EmailAddress david.hiltzman@ditchwitch.com -groups LYN-DL-TorowideSourcing@toro.com -Ticket 999999 -verbose -whatif
   PS> $mdtable = @"
|EmailAddress|DisplayName|Groups|Ticket|
|---|---|---|---|
|david.hiltzman@ditchwitch.com||LYN-DL-TorowideSourcing@toro.com|999999|
"@ ; 
    $mdtable | convertfrom-markdowntable | export-csv -path .\999999-process.csv -notype ;
    Example demoing a simpler non-hashstring-and-customobject method for building csv input files (using simpler mdtable syntax).
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Markdown-formated table to be converted into an object [-markdowntext 'title text']")]
        $markdowntext
    ) ;
    PROCESS {
        $content = @() ; 
        if(($markdowntext|measure).count -eq 1){
            $content = $markdowntext -split '\n' | ?{$_ -notmatch "--" } ; 
        } else { 
            $content = $markdowntext  | ?{$_ -notmatch "--" } ;
        } ; 
    } ;  
    END {
        # support removal of md 'border' syntax |DATA|DATA|DATA| (trim leading & trailing pipe chars)
        $PsObj = $content.trim("|") -replace ' +', '' | ConvertFrom-Csv -Delimiter '|' ; 
        $PsObj | write-output ; 
    } ; # END-E
} ;
#*------^ END Function convertFrom-MarkdownTable ^------
