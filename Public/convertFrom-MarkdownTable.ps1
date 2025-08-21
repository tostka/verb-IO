# convertFrom-MarkdownTable.ps1
#*------v convertFrom-MarkdownTable.ps1 v------
Function convertFrom-MarkdownTable {
    <#
    .SYNOPSIS
    convertFrom-MarkdownTable.ps1 - Converts a Markdown table to a PowerShell object.
    .NOTES
    Version     : 1.0.3
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-21
    FileName    : convertFrom-MarkdownTable.ps1
    License     : MIT License
    Copyright   : (c) 2024 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Markdown,Input,Conversion
    REVISION
    * 9:12 AM 8/21/2025 add alias: 'cfMarkdownTable' (nother mnemomic)
    * 9:33 AM 4/11/2025 add alias: cfmdt (reflects standard verbalias)
    * 12:33 PM 5/17/2024 fixed odd bug, was failing to trim trailing | on some rows, which caused convertfrom-csv to drop that column.
    * 9:04 AM 9/27/2023 cbh demo output tweaks (unindented, results in 1st line de-indent and rest indented.
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 12:42 PM 6/22/2021 bug workaround: empty fields in source md table (|data||data|) cause later (export-csv|convertto-csv) to create a csv with *missing* delimiting comma on the problem field ;  added trim of each field content, and CBH example for creation of a csv from mdtable input; added aliases
    * 5:40 PM 6/21/2021 init
    .DESCRIPTION
    convertFrom-MarkdownTable.ps1 - Converts a Markdown table to a PowerShell object.
    Also supports convesion of variant 'border' md table syntax (e.g. each line wrapped in outter pipe | chars)
    Intent is as a simpler alternative to here-stringinputs for csv building. 
    .PARAMETER markdowntext
    Markdown-formated table to be converted into an object [-markdowntext 'title text']
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.Object[]
   .EXAMPLE
   PS> $svcs = Get-Service Bits,Winrm | select status,name,displayname | 
      convertTo-MarkdownTable -border | ConvertFrom-MarkDownTable ;  
   Convert Service listing to and back from MD table, demo's working around border md table syntax (outter pipe-wrapped lines)
  .EXAMPLE
   PS> $mdtable = @"
|EmailAddress|DisplayName|Groups|Ticket|
|---|---|---|---|
|da.pope@vatican.org||CardinalDL@vatican.org|999999|
|bozo@clown.com|Bozo Clown|SillyDL;SmartDL|000001|
"@ ; 
      $of = ".\out-csv-$(get-date -format 'yyyyMMdd-HHmmtt').csv" ; 
      $mdtable | convertfrom-markdowntable | export-csv -path $of -notype ;
      cat $of ;

        "EmailAddress","DisplayName","Groups","Ticket"
        "da.pope@vatican.org","","CardinalDL@vatican.org","999999"
        "bozo@clown.com","Bozo Clown","SillyDL;SmartDL","000001"

    Example simpler method for building csv input files fr mdtable syntax, without PSCustomObjects, hashes, or invoked object creation.
    .EXAMPLE
    PS> $mdtable | convertFrom-MarkdownTable | convertTo-MarkdownTable -border ; 
    Example to expand and dress up a simple md table, leveraging both convertfrom-mtd and convertto-mtd (which performs space padding to align pipe columns)
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [alias('convertfrom-mdt','in-markdowntable','in-mdt','cfmdt','cfMarkdownTable')]    
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Markdown-formated table to be converted into an object [-markdowntext 'title text']")]
        $markdowntext
    ) ;
    PROCESS {
        $content = @() ; 
        if(($markdowntext|measure).count -eq 1){$markdowntext  = $markdowntext -split '\n' } ;
        # # bug, empty fields (||) when exported (export-csv|convertto-csv) -> broken csv (missing delimiting comma between 2 fields). 
        # workaround : flip empty field => \s. The $object still comes out properly $null on the field, but the change cause export-csv of the resulting obj to no longer output a broken csv.(weird)
        $markdowntext  = $markdowntext -replace '\|\|','| |' ; 
        $content = $markdowntext  | ?{$_ -notmatch "--" } ;
    } ;  
    END {
        # trim lead/trail '| from each line (borders) ; remove empty lines; foreach
        #$PsObj = $content.trim('|')| where-object{$_} | ForEach-Object{ 
        # 11:19 AM 5/17/2024 issue, it's not triming trailing '|' on "THROTTLE |The message was throttled.|problem|":
        $PsObj = $content.trim('|').trimend('|')| where-object{$_} | ForEach-Object{ 
            #$_.split('|').trim() -join '|' ; # split fields and trim leading/trailing spaces from each , then re-join with '|'
            # still coming through with a surviving trailing |, though the leading border is gone (causes to drop trailing cell)
            # filter populated, trim start/end spaces, and refilter pop'd then join result - that seems to have fixed the bug
            ($_.split('|') | where-object{$_} | foreach-object{$_.trim()} |where-object{$_} )  -join '|' ; 
        } | ConvertFrom-Csv -Delimiter '|'; # convert to object
        $PsObj | write-output ; 
    } ; # END-E
}

#*------^ convertFrom-MarkdownTable.ps1 ^------