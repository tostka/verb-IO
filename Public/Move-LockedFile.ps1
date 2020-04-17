#*------v Function Move-LockedFile v------
function Move-LockedFile {
    <#
    .SYNOPSIS
    Move-LockedFile.ps1 - Move Locked file on next reboot
    .NOTES
    Version     : 1.0.0
    Author      : Lee Holmes
    Website: http://www.leeholmes.com/blog/2009/02/17/moving-and-deleting-really-locked-files-in-powershell/
    Twitter: https://twitter.com/Lee_Holmes
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,FileSystem,File,Move
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    # 11:52 AM 9/2/2015 unscrambled from gmail-mangled unwrapped version
    # 10:13 PM 9/1/2015 updated, added pshelp, and validated params, fixed examples to use FullName
    * 20090217 - Web version
    .DESCRIPTION
    Move Locked file on next reboot.Win32 API that enables this is MoveFileEx. Calling this API with the MOVEFILE_DELAY_UNTIL_REBOOT flag tells Windows to move (or delete) your file at the next boot.
    .PARAMETER path
    Source file path [c:\path-to\file.txt]
    .PARAMETER destination
    Destination path [c:\path-to\destination\]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass[-Whatif switch]
    .EXAMPLE
    gci "W:\archs\pix\20150820-reload-eq\Thumbs.db" -force | % { Move-LockedFile -path $_.FullName -destination (Join-Path c:\tmp ($_.Name + ".Bak")) -whatif }  ;
    .EXAMPLE
    dir C:\Users\leeholm -Filter "NTUser.DAT { 
        * " -force | % { Move-LockedFile $_.FullName (Join-Path c:\temp\txr ($_.Name + ".Bak")) }  ;
    .LINK
    http://www.leeholmes.com/blog/2009/02/17/moving-and-deleting-really-locked-files-in-powershell/
    #>
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = "Source file path [c:\path-to\file.txt]")]
        [ValidateNotNull()] [string]$path,
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "Destination path [c:\path-to\destination\]")]
        [ValidateNotNull()] [string]$destination,
        [Parameter(HelpMessage = 'Debug Output Flag [$switch]')]
        [switch] $ShowDebug,
        [Parameter(HelpMessage = 'Whatif Flag [$switch]')]
        [switch] $whatIf
    ) # PARAM BLOCK END
    if ($showDebug) {
        $bDebug = $true
        "`$path:$path";
        "`$destination:$destination";
    } ;
    if ( (test-path $path) ) {
        $path = (Resolve-Path $path).Path ;
        if ( (!(Test-Path $destination -pathType container)) ) {
            $destination = $executionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($destination) ;
            $MOVEFILE_DELAY_UNTIL_REBOOT = 0x00000004 ;
            $memberDefinition = @'
[DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Auto)] public static extern bool MoveFileEx(string lpExistingFileName, string lpNewFileName, int dwFlags);
'@ ;
            if ($whatif) {
                write-host "Whatif`nMoveFileEx($($path), $($destination), `$MOVEFILE_DELAY_UNTIL_REBOOT)"
            }
            else {
                $type = Add-Type -Name MoveFileUtils -MemberDefinition $memberDefinition -PassThru ;
                $bRet = $type::MoveFileEx($path, $destination, $MOVEFILE_DELAY_UNTIL_REBOOT) ;
                "results:`$bRet:$bRet";
            } # if-block end ;
        }
        else {
            write-error "Invalid `$destination:$destination";
        } # if-E ;
    }
    else {
        write-error "Invalid `$path:$path";
    }  # if-E;
} #*------^ END Function Move-LockedFile ^------