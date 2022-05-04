#*------v Find-LockedFileProcess.ps1 v------
function Find-LockedFileProcess {
    <#
    .SYNOPSIS
    Find-LockedFileProcess.ps1 - Find locking process on a file
    .NOTES
    Author: Adam Bertram
    Website:	https://www.adamtheautomator.com/file-cannot-accessed-fix-handle-exe/
    REVISIONS   :
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
    * 7:53 AM 8/27/2018 Find-LockedFileProces:added, added pshelp, tightened a little, defaulted to choco handle.exe loc
    * Mar 26, 2018 posted version
    Req's sysinternals handle.exe (bundled in choco, otherwise):
    #-=-=-=-=-=-=-=-=
    Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/Handle.zip' -OutFile C:\handle.zip
    Expand-Archive -Path C:\handle.zip
    #-=-=-=-=-=-=-=-=
    .DESCRIPTION
    .PARAMETER  FileName
    File [-FileName c:\path-to\file.ext]
    .PARAMETER  HandleFilePath
    File [-HandleFilePath c:\path-to\file.ext]
    .INPUTS
    None
    .OUTPUTS
    Outputs to pipeline
    .EXAMPLE
    Find-LockedFileProcess -FileName TestWordDoc.docx
    .EXAMPLE
    .LINK
    https://www.adamtheautomator.com/file-cannot-accessed-fix-handle-exe/
    #>
    param(
        [Parameter(Mandatory=$true)][string]$FileName,
        [Parameter()][string]$HandleFilePath = 'C:\ProgramData\chocolatey\bin\handle.exe'
    ) ;
    $splitter = '------------------------------------------------------------------------------' ;
    $handleProcess = ((& $HandleFilePath) -join "`n") -split $splitter | Where-Object { $_ -match [regex]::Escape($FileName) } ;
    (($handleProcess -split "`n")[2] -split ' ')[0] ;
}

#*------^ Find-LockedFileProcess.ps1 ^------