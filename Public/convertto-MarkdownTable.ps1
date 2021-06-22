#*------v Function convertTo-MarkdownTable v------
Function convertTo-MarkdownTable {
    <#
    .SYNOPSIS
    convertTo-MarkdownTable.ps1 - Converts a PowerShell object to a Markdown table.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-01-20
    FileName    : convertTo-MarkdownTable.ps1
    License     : (none specified, original source github site deleted)
    Copyright   : (none specified, original source github site deleted)
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Markdown,Output
    AddedCredit : alexandrm
    AddedWebsite: https://mac-blog.org.ua/powershell-convertto-markdown/
    AddedTwitter: https://twitter.com/alexandrm
    AddedCredit : Matticusau
    AddedWebsite: https://gist.github.com/Matticusau/49943eb19efd54783966449bde53e9db
    AddedTwitter: URL
    AddedCredit : GuruAnt
    AddedWebsite: https://gist.github.com/GuruAnt/4c837213d0f313715a93
    AddedTwitter: URL
    REVISION
    * 10:51 AM 6/22/2021 added convertfrom-mdt alias
    * 4:49 PM 6/21/2021 pretest $thing.value: suppress errors when $thing.value is $null (avoids:'You cannot call a method on a null-valued expression' trying to eval it's null value len).
    * 10:49 AM 2/18/2021 added default alias: out-markdowntable & out-mdt
8:29 AM 1/20/2021 - ren'd convertto-Markdown -> convertTo-MarkdownTable (avoid conflict with PSScriptTools cmdlet, also more descriptive as this *soley* produces md tables from objects; spliced in -Title -PreContent -PostContent params ; added detect & flip hashtables to cobj: gets them through, but end up in ft -a layout ; updated CBH, added -Border & -Tight params, integrated *some* of forked fixes by Matticusau: A couple of aliases changed to full cmdlet name for best practices;Extra Example for how I use this with PSScriptAnalyzer;
    unknown - alexandrm's revision (undated)
    unknown - Guruant's source version (undated account deleted on github)
    .DESCRIPTION
    convertTo-MarkdownTable.ps1 - Converts a PowerShell object to a Markdown table.
    .PARAMETER collection
    Powershell object to be converted to md table text output
    .PARAMETER Border
    Switch to generate L & R outter border on output [-Border]
    .PARAMETER Tight
    Switch to drop additional whitespace around border/column-delimiters [-Tight]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    String
    .EXAMPLE
    $data | convertTo-MarkdownTable ;
    .EXAMPLE
    convertTo-MarkdownTable($data) ;
    .EXAMPLE
    Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable ;
    Status  | Name  | DisplayName
    ------- | ----- | -----------------------------------------
    Running | Bits  | Background Intelligent Transfer Service
    Running | Winrm | Windows Remote Management (WS-Management)
    Demo of stock use, with a select to spec properties (this cmdlet doesn't observer cmdlet default properties for display, must be manually selected)
    .EXAMPLE
    Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable -border ; 
    | Status  | Name  | DisplayName                               |
    | ------- | ----- | ----------------------------------------- |
    | Running | Bits  | Background Intelligent Transfer Service   |
    | Running | Winrm | Windows Remote Management (WS-Management) |
    Demo effect of the -Border param.
    .EXAMPLE
    Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable -tight ;
    Status |Name |DisplayName
    -------|-----|-----------------------------------------
    Running|Bits |Background Intelligent Transfer Service
    Running|Winrm|Windows Remote Management (WS-Management)
    Demo effect of the -Tight param.
    .EXAMPLE
   Invoke-ScriptAnalyzer -Path C:\MyScript.ps1 | select RuleName,Line,Severity,Message |
   ConvertTo-Markdown | Out-File C:\MyScript.ps1.md
   Converts output of PSScriptAnalyzer to a Markdown report file using selected properties
   .EXAMPLE
   Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable -Title 'This is Title' -PreContent 'A little something *before*' -PostContent 'A little something *after*'
   Demo use of -title, -precontent & -postcontent params:
   .EXAMPLE
   $pltcMT=[ordered]@{
        Title='This is Title' ;
        PreContent='A little something *before*' ;
        PostContent='A little something *after*'
   } ;
   Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable @pltcMT ; 
   Same as prior example, but leveraging more readable splatting
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('out-markdowntable','out-mdt','convertfrom-mdt')]
    [OutputType([string])]
    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PSObject[]]$Collection,
        [Parameter(HelpMessage="Switch to generate L & R outter border on output [-Border]")]
        [switch] $Border,
        [Parameter(HelpMessage="Switch to drop additional whitespace around border/column-delimiters [-Tight]")]
        [switch] $Tight,
        [Parameter(HelpMessage="String to be tagged as H1 [-Title 'title text']")]
        [string] $Title,
        [Parameter(HelpMessage="String to be added above returned md table [-PreContent 'Preface']")]
        [string[]] $PreContent,
        [Parameter(HelpMessage="String to be added below returned md table [-PostContent 'Preface']")]
        [string[]] $PostContent
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
        $items = @() ;
        #$columns = [ordered]@{} ; # no causes "Method invocation failed because [System.Collections.Specialized.OrderedDictionary] does not contain a method named 'ContainsKey'."
        $columns = @{} ;
        $output = @"

"@
        $Delimiter = ' | '
        $BorderLeft = '| '; 
        $BorderRight = ' |'; 
        if($Tight){
            $Delimiter = $Delimiter.replace(' ','') ;
            $BorderLeft = $BorderLeft.replace(' ','') ; 
            $BorderRight = $BorderRight.replace(' ','') ; 
        } ; 
        If ($title) {
            Write-Verbose "Adding Title: $Title"
            $output += "`n# $Title`n`n"
        }
        If ($precontent) {
            Write-Verbose "Adding Precontent"
            $output += $precontent + "`n`n" ; 
        }
    } ;
    PROCESS {
        ForEach($item in $collection) {
            switch($item.GetType().FullName){
                "System.Collections.Hashtable" {
                    # convert inbound hashtable to a cobj
                    # effectively ft -a's the key:values - not optimal, but at least it gets them through. 
                    $item  = [pscustomobject]$item
                }
                default {} ; 
            } ;
            $items += $item ;
            # simpler solution for $null values: (I also like explicit foreach over foreach-object)
            foreach($thing in $item.PSObject.Properties){
                #write-verbose "$($thing|out-string)" ; 
                # suppress errors when $thing.value is $null (avoids:'You cannot call a method on a null-valued expression' trying to eval it's null value len).
                if($thing.Value){$valuLen =  $thing.Value.ToString().Length }
                else {$valuLen = 0 } ;
                if(-not $columns.ContainsKey($thing.Name) -or $columns[$thing.Name] -lt $valuLen) {
                    if ($null -ne $thing.Value) {
                        $columns[$thing.Name] = $thing.Value.ToString().Length
                    } else {
                        $columns[$thing.Name] = 0 ; # null's 0-length, so use it. 
                    } ; 
                } ;

            } ;  # loop-E

        } ;
    } ;  # PROC-E
    END {
        ForEach($key in $($columns.Keys)) {
            $columns[$key] = [Math]::Max($columns[$key], $key.Length) ;
        } ;
        $header = @() ;
        ForEach($key in $columns.Keys) {
            $header += ('{0,-' + $columns[$key] + '}') -f $key ;
        } ;
        if(!$Border){
            $output += ($header -join $Delimiter) + "`n" ; 
        }else{
            $output += $BorderLeft + ($header -join $Delimiter) + $BorderRight + "`n" ; 
        } ;
        $separator = @() ;
        ForEach($key in $columns.Keys) {
            $separator += '-' * $columns[$key] ;
        } ;
        if (!$Border) { 
            $output += ($separator -join $Delimiter) + "`n" ; 
        }
        else{
            $output += $BorderLeft + ($separator -join $Delimiter) + $BorderRight + "`n" ; 
        } ;
        ForEach($item in $items) {
            $values = @() ;
            ForEach($key in $columns.Keys) {
                $values += ('{0,-' + $columns[$key] + '}') -f $item.($key) ;
            } ;
            if (!$Border) { 
                $output += ($values -join $Delimiter) + "`n" ; 
            }else{
                $output += $BorderLeft + ($values -join $Delimiter ) + $BorderRight + "`n" ; 
            } ;
        } ;
        If ($postcontent) {
            Write-Verbose "Adding postcontent"
            $output += "`n"
            $output += $postcontent
            $output += "`n" ; 
        }
        $output | write-output ; 

    } ; # END-E
} ;
#*------^ END Function convertTo-MarkdownTable ^------