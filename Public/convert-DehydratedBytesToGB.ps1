#*------v Function convert-DehydratedBytesToGB v------
Function convert-DehydratedBytesToGB {
    <#
    .SYNOPSIS
    convert-DehydratedBytesToGB.ps1 - Convert MS Dehydrated byte sizes - 102.8 MB (107,808,015 bytes) - into equivelent decimal gigabytes.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : convert-DehydratedBytesToGB.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    REVISIONS
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    convert-DehydratedBytesToGB.ps1 - Convert MS Dehydrated byte sizes - 102.8 MB (107,808,015 bytes) - into equivelent decimal gigabytes.
    .PARAMETER Data
    Array of Dehydrated byte sizes to be converted
    .PARAMETER Decimals
    Number of decimal places to return on results
    .OUTPUT
    System.Object[] 
    .EXAMPLE
     (get-mailbox | get-mailboxstatistics).totalitemsize.value | convert-DehydratedBytesToGB ;
    Convert a series of get-MailboxStatistics.totalitemsize.values ("102.8 MB (107,808,015 bytes)") into decimal gigabyte values
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Array of Dehydrated byte sizes to be converted[-Data `$array]")]
        [ValidateNotNullOrEmpty()]
        [array]$Data,
        [Parameter(HelpMessage="Number of decimal places to return on results[-Decimals 3]")]
        [int] $Decimals=3
    )
    
    BEGIN{
        $FmtCode = "{0:N$($Decimals)}" ; 
    } 
    PROCESS{
        If($Data -match '.*\s\(.*\sbytes\)'){ # test for inbound data in expected text format
            foreach($item in $Data){
                # replace ".*(" OR "\sbytes\).*" OR "," (with nothing, results in the raw bytes numeric value), then foreach and format to gb decimal places 
                $item -replace '.*\(| bytes\).*|,' |foreach-object {$FmtCode  -f ($_ / 1GB)} | write-output ;
                # sole difference between GB & MB funcs is the 1GB/1MB above
            } ; 
        } else { 
            throw "unrecoginzed data series:Does not match 'nnnnnn.n MB (nnn,nnn,nnn bytes)' text format"
            Continue ; 
        } ; 
    } ; 
    END {} ;
} ; 
#*------^ END Function convert-DehydratedBytesToGB ^------