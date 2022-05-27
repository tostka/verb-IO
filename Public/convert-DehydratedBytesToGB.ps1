#*------v Function convert-DehydratedBytesToGB v------
Function convert-DehydratedBytesToGB {
    <#
    .SYNOPSIS
    convert-DehydratedBytesToGB - Convert MS Dehydrated byte sizes string - NN.NN MB (nnn,nnn,nnn bytes) - into equivelent decimal gigabytes.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : convert-DehydratedBytesToGB.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Conversion,Storage,Unit
    REVISIONS
    * 3:08 PM 5/27/2022 CBH added example for select property expression; strongly typed output as double
    * 1:34 PM 2/25/2022 refactored CBH (was broken, non-parsing), renamed -data -> -string, retained prior name as a parameter alias
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    convert-DehydratedBytesToGB - Convert MS Dehydrated byte sizes string - 'NN.NN MB (nnn,nnn,nnn bytes)' string returned - into equivelent decimal gigabytes.
    Microsoft routinely returns storage values as space/parenthese-delimited string in units value, and a parenthetical comma'd bytes value. Neither of which is usable for comparison or sorting, unless converted to a single underlying unit of value. This does that conversion. 
    .PARAMETER String
    Array of Dehydrated byte sizes to be converted
    .PARAMETER Decimals
    Number of decimal places to return on results
    .INPUTS
    Accepts pipeline input. 
    .OUTPUTS
    System.Double
    .EXAMPLE
    PS> (get-mailbox -id hoffmjj | get-mailboxstatistics).totalitemsize | convert-DehydratedBytesToGB ;
    Convert a series of get-MailboxStatistics.totalitemsize.values ("102.8 MB (107,808,015 bytes)") into decimal gigabyte values.
    .EXAMPLE
    PS> $propsFldr = 'Name','ItemsInFolder', @{Name='FolderSizeGB';Expression={$_.FolderSize | convert-DehydratedBytesToGB -decimals 5 }},@{Name='TopSubjectSizeGB';Expression={$_.TopSubjectSize | convert-DehydratedBytesToGB -decimals 5 }},'TopSubject','TopSubjectCount','TopSubjectClass' ; 
    PS> Connect-ExchangeOnline ; 
    PS> $fldrstats = Get-XOMailboxFolderStatistics -Identity user@domain.com  -IncludeAnalysis -FolderScope RecoverableItems ; 
    PS>  $fldrstats | select $propsFldr |?{$_.TopSubjectSizeGB -gt 1}
    
    Name             : DiscoveryHolds
    ItemsInFolder    : 291212
    FolderSizeGB     : 98.03443
    TopSubjectSizeGB : 49.32737
    TopSubject       : Subject Meeting
    TopSubjectCount  : 29154
    TopSubjectClass  : IPM.Appointment
    
    Demo construction of a select-object properties array that includes expressions leveraging convert-DehydratedBytesToGB to produce decimal gigabyte sizes for EXO two dehydrated byte sizes properties (with 5-digit decimal values), and then postfiltering that value for oversize mailbox folders (with ExchangeOnlineManagement module)
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
                [double]($item -replace '.*\(| bytes\).*|,' |foreach-object {$FmtCode  -f ($_ / 1GB)}) | write-output ;
                # sole difference between GB & MB funcs is the 1GB/1MB above
            } ; 
        } else { 
            throw "unrecoginzed String series:Does not match 'nnnnnn.n MB (nnn,nnn,nnn bytes)' text format" ; 
            Continue ; 
        } ; 
    } ; 
    END {} ;
} ; 
#*------^ END Function convert-DehydratedBytesToGB ^------