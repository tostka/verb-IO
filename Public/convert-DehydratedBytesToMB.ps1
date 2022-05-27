#*------v Function convert-DehydratedBytesToMB v------
Function convert-DehydratedBytesToMB {
    <#
    .SYNOPSIS
    convert-DehydratedBytesToMB - Convert MS Dehydrated byte sizes string returned - 'NN.NN MB (nnn,nnn,nnn bytes)' - into equivelent decimal megabytes.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : convert-DehydratedBytesToMB.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Conversion,Storage,Unit
    REVISIONS
    * 3:08 PM 5/27/2022 CBH added example for select property expression; strongly typed output as double
    * 1:34 PM 2/25/2022 refactored CBH (was broken, non-parsing), renamed -data -> -string, retained prior name as a parameter alias
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    convert-DehydratedBytesToMB - Convert MS Dehydrated byte sizes string returned - 'NN.NN MB (nnn,nnn,nnn bytes)' - into equivelent decimal megabytes.
    .PARAMETER String
    Array of Dehydrated byte sizes to be converted
    .PARAMETER Decimals
    Number of decimal places to return on results
    .INPUTS
    Accepts pipeline input. 
    .OUTPUTS
    System.Double
    .EXAMPLE
    PS> (get-mailbox -id hoffmjj | get-mailboxstatistics).totalitemsize | convert-DehydratedBytesToMB ;
    Convert a series of get-MailboxStatistics.totalitemsize.values ("102.8 MB (107,808,015 bytes)") into decimal megabyte values.
    .EXAMPLE
    PS> $propsFldr = 'Name','ItemsInFolder', @{Name='FolderSizeMB';Expression={$_.FolderSize | convert-DehydratedBytesToMB -decimals 5 }},@{Name='TopSubjectSizeGB';Expression={$_.TopSubjectSize | convert-DehydratedBytesToGB -decimals 5 }},'TopSubject','TopSubjectCount','TopSubjectClass' ; 
    PS> Connect-ExchangeOnline ; 
    PS> $fldrstats = Get-XOMailboxFolderStatistics -Identity user@domain.com  -IncludeAnalysis -FolderScope RecoverableItems ; 
    PS>  $fldrstats | select $propsFldr |?{$_.TopSubjectSizeMB -gt 1}
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Array of Dehydrated byte sizes to be converted[-String `$array]")]
        [ValidateNotNullOrEmpty()]
        [Alias('Data')]
        [string[]]$String,
        [Parameter(HelpMessage="Number of decimal places to return on results[-Decimals 3]")]
        [int] $Decimals=3
    )
    BEGIN{
        $FmtCode = "{0:N$($Decimals)}" ; 
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 

    } 
    PROCESS{
        $Error.Clear() ; 
        If($String -match '.*\s\(.*\sbytes\)'){ 
            foreach($item in $String){
                # replace ".*(" OR "\sbytes\).*" OR "," (with nothing, results in the raw bytes numeric value), then foreach and format to gb or mb decimal places (depending on tomb or togb variant of the function)
                [double]($item -replace '.*\(| bytes\).*|,' |foreach-object {$FmtCode  -f ($_ / 1MB)}) | write-output ;
                # sole difference between GB & MB funcs is the 1GB/1MB above
            } ; 
        } else { 
            throw "unrecoginzed String series:Does not match 'nnnnnn.n MB (nnn,nnn,nnn bytes)' text format" ; 
            Continue ; 
        } ; 
    } ; 
    END {} ;
} ; 
#*------^ END Function convert-DehydratedBytesToMB ^------