#*------v Function test-IsLink v------
function test-IsLink{
    <#
    .SYNOPSIS
    test-IsLink.ps1 - Tests a given file or directory path, for 'Symlink'/'Hardlink'/Reparsepoint status.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-06-16
    FileName    : test-IsLink.ps1
    License     : MIT License
    Copyright   : (c) 2023 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell, fileystem, junctionpoint,  symlink,  reparsepoint
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 1:07 PM 6/19/2023 retooled with more extensive gi/gci -type tests for target & linktype, but only works in PsWin v5.1, psCore has zero support
    * 1:45 PM 6/16/2023 init
    .DESCRIPTION
    test-IsLink - Tests a given file or directory path, for 'Symlink'/'Hardlink'/Reparsepoint status.
    .PARAMETER Path
    Path [-path c:\path-to\]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    PS> if(test-IsLink -path c:\tmp\){
    PS>     write-host 'ReparsePoint (Symlink/Hardlink/JuntionPoint) detected' ;
    PS> }else{
    PS>     write-host 'No ReparsePoint (Symlink/Hardlink/JuntionPoint) detected' ;
    PS> }
    Typical usage
    .EXAMPLE
    PS> join-path (split-path $profile) 'profile.ps1' | test-IsLink -verbose ; 

        VERBOSE: Data received from pipeline input: ''
        VERBOSE: C:\Users\LOGON\OneDrive - COMPANY\Documents\WindowsPowerShell\profile.ps1 is a File
        True
    
    Demo testing resolved profile.ps1 in CU profile, via pipeline.
    .EXAMPLE
    PS> join-path (split-path $profile) 'profile.ps1' | test-islink -verbose -type HardLink ; 
    Test for hardlink type file link
    .LINK
    https://github.com/tostka/verb-io
    .LINK
    https://bitbucket.org/tostka/powershell/
    #>
    [CmdletBinding()]
    [Alias('test-IsSymlink','test-IsJunction', 'test-IsHardLink')]
    PARAM(
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True, HelpMessage = 'Paths[-path c:\pathto\file.ext or c:\pathto]')]
            [Alias('PsPath')]
            [ValidateScript({Test-Path $_})]
            [string[]]$Path,
        [Parameter(Mandatory = $false,HelpMessage = 'ItemType specification (SymbolicLink|HardLink|Junction)[-Type HardLink]')]
            [ValidateSet('SymbolicLink','HardLink','Junction','Any')]
            [string[]]$Type
    ) ; 
    BEGIN {
        
        switch -regex ($PSCmdlet.MyInvocation.Line){
            ($PSCmdlet.MyInvocation.mycommand.name) {
                write-verbose "called via native cmdlet name" ; 
                if(-not $Type){
                    $Type = 'Any' ; 
                } ; 
            }
            'test-IsSymlink'{
                write-verbose "called via alias:test-IsSymlink" ; 
                $Type = 'SymbolicLink' ;
            }
            'test-IsHardLink'{
                write-verbose "called via alias:test-IsHardLink" ; 
                $Type = 'HardLink' ;
            }
            
            'test-IsJunction'{
                write-verbose "called via alias:test-IsJunction" ; 
                $Type = 'Junction' ;
            }
            default{
                $smsg = "unrecognized call!" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                break ; 
            } 
        } ; 

        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ;
        } 
    } ;
    PROCESS {
        foreach($item in $Path) {
            #$smsg = $sBnrS="`n#*------v PROCESSING : $($item) v------" ; 
            #write-verbose $smsg ; 
            $Error.Clear() ; 
            $obj = Get-Item $item -Force -ea SilentlyContinue ;
            switch($obj.PSIsContainer){
                $true  {
                    write-verbose "$($obj.fullname) is a Container" ; 
                } 
                $false {
                    write-verbose "$($obj.fullname) is a File" ; 
                } 
                default {
                    write-warning "$($obj.fullname) is of *unrecognized* object type!" ; 
                    break ; 
                } ; 
            } ; 
            #[bool]($obj.Attributes -band [IO.FileAttributes]::ReparsePoint) | write-output ; 
            # issue is OneDriveForBusiness (ODFB) has *everything* tagged a ReparsePoint, even if they aren't hard/sym-links|junctionpoint|mountpoints.
            <# - workaround Psv5.5 gi & gci have link related properties:
                gi "$env:onedrive\documents\windowspowershell\*.ps1" | ?{$_.target -AND $_.linktype} | fl mode,target,linktype,fullname ; 

                Mode     : -a---l
                Target   : {C:\sc\powershell\PSProfileUID\profile.ps1}
                LinkType : HardLink
                FullName : C:\Users\kadrits\OneDrive - The Toro Company\documents\windowspowershell\profile.ps1

                Mode instr 'l' == link (tagged on hard/symlinks & odfb reparsepoints -= worthless)
                Target resolves actual target, but not on PSc6+
                LinkType only works on PsWin5.1.

              - Powershell Core has -view support:
                gi "$env:onedrive\documents\windowspowershell\test.txt" | ft -view childrenWithHardLink

                    Directory: C:\Users\kadrits\OneDrive - The Toro Company\documents\windowspowershell

                Mode                 LastWriteTime         Length Name
                ----                 -------------         ------ ----
                la---           6/16/2023 12:46 PM              0 test.txt

                but that's worthless, and is equiv to mode -like '*l*', and it's fooled and mistags ODFB reparsepoints. 
                So completley drop tests support under PsC. 
                It provides *zero* target resolution support. Reportedly pulled for performance issues (and doesn't even permit explicit check at calling user's spec, as Unix would do).
            #>
            if($IsCoreCLR){
                $smsg = "Powershell Core detected: PsC has had *all* hardlink/symlink functional support stripped post psC6+" ; 
                $smsg += "`n(close and rerun under WindowsPowershell v5.1!)" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                break ; 
            }else {
                [bool]$isReparsePoint = ($obj.Attributes -band [IO.FileAttributes]::ReparsePoint) ; 
                [bool]$isObjLink = ($obj.target -AND $obj.linktype) ;
                # if it has a .target, it's sometype of redirected object.
            } ; 

            switch ($type){
                'any' {
                    [bool]($isReparsePoint -AND $isObjLink) | write-output ; 
                }
                'SymbolicLink' {
                    [bool]($isReparsePoint -AND $obj.target -AND ($obj.linktype -eq 'SymbolicLink')) | write-output ; 
                }
                'HardLink' {
                    [bool]($isReparsePoint -AND $obj.target -AND ($obj.linktype -eq 'HardLink')) | write-output ; 
                }
                'Junction' {
                    [bool]($isReparsePoint -AND $obj.target -AND ($obj.linktype -eq 'Junction')) | write-output ; 
                }
            }

            #write-verbose $sBnrS.replace('-v','-^').replace('v-','^-') ;
        } ;  # loop-E
    } ;  # PROC-E
} ; 
#*------^ END Function test-IsLink ^------