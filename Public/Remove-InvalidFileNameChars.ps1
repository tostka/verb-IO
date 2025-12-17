# Remove-InvalidFileNameChars.ps1

#region REMOVE_INVALIDFILENAMECHARS ; #*------v Remove-InvalidFileNameChars v------
#if(-not(gi function:Remove-InvalidFileNameChars -ea 0)){
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
        * 9:55 AM 12/15/2025 added regions
        * 4:35 PM 12/16/2021 added -PurgeSpaces, to fully strip down the result. Added a 2nd CBH example
        * 7:21 AM 9/2/2020 added alias:'Remove-IllegalFileNameChars'
        * 3:32 PM 9/1/2020 added to verb-IO
        * 4/14/14 posted version
        .DESCRIPTION
        Remove-InvalidFileNameChars - Remove OS-specific illegal filename characters from the passed string
        Note: You should pass the filename, and not a full-path specification as '-Name', 
        or the function will remove path-delimters and other routine path components. 
        .PARAMETER Name
        Potential file 'name' string (*not* path), to have illegal filename characters removed. 
        .PARAMETER PurgeSpaces
        Switch to purge spaces along with OS-specific illegal filename characters. 
        .INPUTS
        Accepts piped input.
        .OUTPUTS
        System.String
        .EXAMPLE
        $Name = Remove-InvalidFileNameChars -name $ofile ; 
        Remove OS-specific illegal characters from the sample filename in $ofile. 
        .EXAMPLE
        $Name = Remove-InvalidFileNameChars -name $ofile -purgespaces ; 
        Remove OS-specific illegal characters & spaces from the sample filename in $ofile. 
        .LINK
        https://github.com/tostka/verb-IO
        #>
        [CmdletBinding()]
        [Alias('Remove-IllegalFileNameChars')]
        Param(
            [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
            [String]$Name,
            [switch]$PurgeSpaces
        )
        $verbose = ($VerbosePreference -eq "Continue") ; 
        $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join '' ; 
        if($PurgeSpaces){
            write-verbose "(-PurgeSpaces: removing spaces as well)" ; 
            $invalidChars += ' ' ; 
        } ; 
        $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
        ($Name -replace $re) | write-output ; 
    } ; 
#} ; 
#endregion REMOVE_INVALIDFILENAMECHARS ; #*------^ END Remove-InvalidFileNameChars ^------
