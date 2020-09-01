#*------v Function Remove-InvalidFileNameChars v------
Function Remove-InvalidFileNameChars {
  <#
    .SYNOPSIS
    Remove-InvalidFileNameChars - Remove OS-specific illegal filename characters from the passed string
    .NOTES
    Author: Ansgar Wiechers
    Website:	https://stackoverflow.com/questions/23066783/how-to-strip-illegal-characters-before-trying-to-save-filenames
    Twitter     :	
    AddedCredit : 
    AddedWebsite:	
    Version     : 1.0.0
    CreatedDate : 2020-09-01
    FileName    : Remove-InvalidFileNameChars.ps1
    License     : 
    Copyright   : 
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Filesystem
    REVISIONS   :
    * 3:32 PM 9/1/2020 added to verb-IO
    * 4/14/14 posted version
    .DESCRIPTION
    Remove-InvalidFileNameChars - Remove OS-specific illegal filename characters from the passed string
    .PARAMETER Name
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.String
    .EXAMPLE
    $Name = Remove-InvalidFileNameChars -name $ofile ; 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    ##[Alias('rx10')]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Name
    )
    $verbose = ($VerbosePreference -eq "Continue") ; 
    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
    ($Name -replace $re) | write-output ; 
}#*------^ END Function Remove-InvalidFileNameChars ^------ ;
