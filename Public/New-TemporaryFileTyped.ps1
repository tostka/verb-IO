# New-TemporaryFileTyped.ps1


#*----------v Function New-TemporaryFileTyped() v----------
function New-TemporaryFileTyped{
    <#
    .SYNOPSIS
    New-TemporaryFileTyped.ps1 - Simple wrapper for New-TemporaryFile(), that converts the ouput .tmp into the specified file extension , and returns the updated System.IO.FileInfo object for the renamed file to the pipeline.
    .NOTES
    Version     : 0.0.1
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2025-04-01
    FileName    : New-TemporaryFileTyped.ps1
	License     : MIT License
	Copyright   : (c) 2025 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,CommaSeparatedValues,CSV,filesystem
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	URL
    REVISIONS
    * 3:58 PM 4/1/2025 init
    .DESCRIPTION
    New-TemporaryFileTyped.ps1 - Simple wrapper for New-TemporaryFile(), that converts the ouput .tmp into the specified file extension , and returns the updated System.IO.FileInfo object for the renamed file to the pipeline.
    
    Supported Aliases, that drive specific variant Extensions: 
    New-TemporaryFileCsv,
    New-TemporaryFileXML,
    New-TemporaryFileJSON,
    New-TemporaryFileMD
    
    .PARAMETER Extension
    Extension to be written on new file (defaults to CSV)
    .INPUTS
    None, does not support pipeline input.
    .OUTPUTS
    System.IO.FileInfo 
    .EXAMPLE
    PS> $ofile = New-TemporaryFileTyped -Extension 'rando' ; 
    PS> write-host "Exporting results to temp file:$($ofile.fullname)..." ; 
    PS> Get-CryptoRandom 10001 | out-file -path $ofile.fullname ; 
	Demo create a temp file with the custom Extension 'rando', 
	.EXAMPLE
    PS> $ofile = New-TemporaryFileCsv ; 
    PS> write-host "Exporting results to temp file:$($ofile.fullname)..." ; 
    PS> $data | export-csv -path $ofile.fullname ; 
	Demo create a temp .csv, 
	.EXAMPLE
    PS> $ofile = New-TemporaryFileXML  ; 
    PS> write-host "Exporting results to temp file:$($ofile.fullname)..." ; 
    PS> $data | export-csv -path $ofile.fullname ; 
	Demo create a temp .xml, 
	.EXAMPLE
    PS> $ofile = New-TemporaryFileJSON  ; 
    PS> write-host "Exporting results to temp file:$($ofile.fullname)..." ; 
    PS> Get-Date | Select-Object -Property * | ConvertTo-Json | ConvertFrom-Json | out-file -path $ofile.fullname ; 
	Demo create a temp .json, 
		.EXAMPLE
    PS> $ofile = New-TemporaryFileMD  ; 
    PS> write-host "Exporting results to temp file:$($ofile.fullname)..." ; 
    PS> $markdowncontent | out-file -path $ofile.fullname ; 
	Demo create a temp .md, 
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('New-TemporaryFileCsv','New-TemporaryFileXML','New-TemporaryFileJSON','New-TemporaryFileMD')]
    Param(
		[Parameter(Mandatory=$False,HelpMessage="Optional Extension to be written on new file (ovrides default, 'CSV') [-Extension 'rando']")]
			[AllowEmptyString()][AllowNull()]
			[string]$Extension
    ) ; 
    BEGIN {
		# autopopulate -Extension, around Alias use.
		If ($MyInvocation.Line -match 'New-TemporaryFileCsv') {
			write-verbose "Alias:New-TemporaryFileCsv was used, using -extension .csv" ;
			$Extension = 'csv' ; 
		} ElseIf ($MyInvocation.Line -match 'New-TemporaryFileXML') {
			write-verbose "Alias:New-TemporaryFileXML was used, using -extension .xml" ;
			$Extension = 'xml' ; 
		} ElseIf ($MyInvocation.Line -match 'New-TemporaryFileJSON') {
			write-verbose "Alias:New-TemporaryFileXML was used, using -extension .json" ;
			$Extension = 'json' ; 
		} ElseIf ($MyInvocation.Line -match 'New-TemporaryFileMD') {
			write-verbose "Alias:New-TemporaryFileMD was used, using -extension .md" ;
			$Extension = 'md' ; 
		} ; 
		if(-not $Extension){
			$smsg = "blank -Extension!`nplease use a documented alias, or specify a specific Extension" ; 
			throw $smsg ;
			break ; 
		} ; 
    } ;  # BEG-E
    PROCESS {
        $newfile = New-TemporaryFile | foreach-object {rename-item -path $_.fullname -NewName ($_.name -replace '\.tmp',".$($Extension)") -verbose -PassThru } ;
        $newfile | write-output ;
    } ;  # PROC-E
} ; 
#*------^ END Function New-TemporaryFileTyped ^------