# Test-FileBlockedStatusTDO.ps1


#region TEST_FILEBLOCKEDSTATUSTDO ; #*------v Test-FileBlockedStatusTDO v------
Function Test-FileBlockedStatusTDO {
        <#
        .SYNOPSIS
        Test-FileBlockedStatusTDO - Tests files for 'Blocked' status by checking the ZoneIdentifier alternate data stream.
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-09-09
        FileName    : Test-FileBlockedStatusTDO
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-io
        Tags        : Powershell,FileSystem,Security,Block
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 4:02 PM 9/15/2025 Test-FileBlockedStatusTDO(): flipped -Path to [string] -> [string[]] and test-path validation; process stack of specs, emit blocks, to pipeline; 
             add CBH demos for 1-liner test and unblock & vsdev/xopBuildLibrary loads 
        * 6:02 PM 9/11/2025 flipped pipeline output to fileinfo object, vs string fullname (unblock won't pipeline process the string, doers the object) ; 
            ren'd Test-FileBlockedStatus -> Test-FileBlockedStatusTDO, aliased orig name
        * 4:56 PM 9/9/2025 Test-FileBlockedStatusTDO():revised: error workaround: $adsPath = "$($file.FullName):$ZoneIdentifierStream"; test-Path -LiteralPath $adsPath ;  init
        .DESCRIPTION
        Test-FileBlockedStatusTDO - Tests files for 'Blocked' status by checking the ZoneIdentifier alternate data stream.
        
        This function inspects files to determine if they are marked as 'Blocked' by Windows.

        It checks for the presence of the ZoneIdentifier ADS and returns the full path of matching files.
        On block detection, it emits the fullbame/pathed-filename to the pipeline (ready for pipe into unblock-file).

        If fed a directory specification, it attempts to gci -recurse the child objects for analysis.
        If you want to filter content within the recursion, do the filtering *before* feeding the list to this function. 
        (see Example 4 for an example of post-filtering Directory property to exclude a subtree).

        Note: This uses get-content with the -stream parameter to test for ZoneID=3 spec:
        -stream *only retrives the targeted stream data*, even on huge files. 
        Point it at a 6gb .ISO, you don't gc 6gb of data to return the ZoneID for testing, just a few k of stream data.

        GUI alt is Explorer file > Properties: displays:
        'This file came from another computer and might be blocked to help protect this computer [ ] Unblock'

        .PARAMETER Path
        The path to the file or directory to inspect. Accepts input from the pipeline.
        .INPUTS
        System.String[] Array of file path specifications (or fileinfo objects etc that convert into path strings).
        .OUTPUTS
        System.String - Full path of files that are marked as 'Blocked'.
        .EXAMPLE
        PS> Get-ChildItem -Path "C:\Downloads" | Test-FileBlockedStatusTDO
        Simple test of all files within the downloads directory. Emits full path to blocked files.
        .EXAMPLE
        PS> gci d:\cab\* -include @('*.ps1','*.psm1')  | Test-FileBlockedStatusTDO | Unblock-File -verbose ;    
        Demo collecting all ps1 & psm1 files in target directory, testing for blocked status, and running an unblock on matches.
        .EXAMPLE
        PS> $somefile = 'd:\pathto\file.ext' ; 
        PS> if(gi $somefile  -Stream 'Zone.Identifier' -ea 0 |%{gc $_.FileName -Stream 'Zone.Identifier' |?{$_ -match "ZoneId=3"}}){
        PS>         gci $somefile| Unblock-File -verbose -whatif:$($whatif)  ; 
        PS> } else{write-verbose "$tfile isn't blocked" } ; 
        Freestanding no dependancy one-line test block & unblock, wo dependancy on this function.
        .EXAMPLE
        PS> $whatif = $true ; 
        PS> cd d:\cab; 
        PS> $tfiles = @() ; 
        PS> If($vdevISEFiles = gc .\vdevISEFiles.txt -ea 1){$tfiles += @(gci d:\cab\*_func.ps1 -Include $vdevISEFiles)} ; 
        PS> $tfiles += @(gci "D:\cab\xopBuildLibrary.ps1") ; 
        PS> $tfiles | %{
        PS>     $thisfile = $_ ; 
        PS>     gi $thisfile.fullname  -Stream 'Zone.Identifier' -ea 0 |%{
        PS>         if(gc $_.FileName -Stream 'Zone.Identifier' |?{$_ -match "ZoneId=3"}){
        PS>             unblock-file -path $thisfile.fullname -verbose -whatif:$($whatif) ;  
        PS>         } else{write-verbose "$($thisfile.fullname) isn't blocked" } ; 
        PS>     }  ; 
        PS>     $thisfile | ipmo -fo -verb ; 
        PS> } ; 
        Expanded wrapper on the above, to collect files (static list stored in .txt), unblock & ipmo vsdev & xopBuildLibrary modules/functions. 
        .EXAMPLE
        PS> $whatif = $true ; 
        PS> cd d:\cab;
        PS> $tfiles = @() ;
        PS> $bftypeExts = '.cer','.chm','.cmd','.crt','.dat','.dll','.eml','.exe','.Hlp','.ico','.ini','.lnk','.msc','.pfx','.ps1','.psm1','.reg','.txt','.url','.xml','.zip' ;
        PS> $fltrBftypeExts = $bftypeExts |%{$_.replace('.','*.')} ;
        PS> write-host "Gci: gci d:\cab\* -include $fltrbftypeExts -exclude "\unpacked\" -recur ..." ; 
        PS> $tfiles += @(gci d:\cab\* -include $fltrbftypeExts -exclude "\unpacked\" -recur  | ?{$_.fullname -notmatch '\\unpacked\\'} ) ;
        PS> $tfiles | %{
        PS>     $thisfile = $_ ;
        PS>     gi $thisfile.fullname  -Stream 'Zone.Identifier' -ea 0 |%{
        PS>         if(gc $_.FileName -Stream 'Zone.Identifier' |?{$_ -match "ZoneId=3"}){
        PS>             unblock-file -path $thisfile.fullname -verbose -whatif:$($whatif) ;
        PS>         } else{write-verbose "$($thisfile.fullname) isn't blocked" } ;
        PS>     }  ;
        PS> } ; 
        Expanded wrapper on the above - no dependancy self-contained vers - to collect all files of specified extension (types), test & unblock as needed (no dependancy version)
        .EXAMPLE
        PS> $whatif = $true ; 
        PS> cd d:\cab;
        PS> $tfiles = @() ;
        PS> $bftypeExts = '.cer','.chm','.cmd','.crt','.dat','.dll','.eml','.exe','.Hlp','.ico','.ini','.lnk','.msc','.pfx','.ps1','.psm1','.reg','.txt','.url','.xml','.zip' ;
        PS> $fltrBftypeExts = $bftypeExts |%{$_.replace('.','*.')} ;
        PS> write-host "Gci: gci d:\cab\* -include $fltrbftypeExts -exclude "\unpacked\" -recur ..." ; 
        PS> $tfiles += @(gci d:\cab\* -include $fltrbftypeExts -exclude "\unpacked\" -recur  | ?{$_.fullname -notmatch '\\unpacked\\'} ) ;
        PS> $tfiles | Test-FileBlockedStatusTDO | Unblock-File -verbose -whatif:$($whatif) ; 
        Expanded wrapper on the above - relies on verb-io\Test-FileBlockedStatus for testing - to collect all files of specified extension (types), test & unblock as needed.
        .LINK
        https://learn.microsoft.com/en-us/windows/win32/shell/zone-identifiers
        .LINK
        https://github.com/tostka/verb-IO        
        #>
        [CmdletBinding()]
        [Alias('Test-FileBlockedStatus')]
        PARAM (
            [Parameter( Mandatory = $true, ValueFromPipeline = $true, HelpMessage = "Specify the path to the file or directory to inspect." )]         
                [ValidateNotNullOrEmpty()]
                [ValidateScript({Test-Path $_})]
                [string[]]$Path
        ) 
        BEGIN {
            $ZoneIdentifierStream = 'Zone.Identifier'
            $BlockedZoneId = 3
            $rgxZoneID = [regex]::Escape("ZoneId=$($BlockedZoneId)")
        }
        PROCESS {
            foreach($AnItem in $Path){
                write-verbose $AnItem ; 
                TRY {
                    $item = Get-Item -LiteralPath $AnItem -ErrorAction Stop
                    # If it's a directory, enumerate files
                    if ($item.PSIsContainer) {
                        $files = Get-ChildItem -Path $item.FullName -File -Recurse -ErrorAction SilentlyContinue
                    } else {
                        $files = @(get-childitem -path $item)
                    }
                    foreach ($file in $files) {
                        TRY {
                            #if(Get-Item $file.FullName -Stream "Zone.Identifier" -ErrorAction SilentlyContinue){
                            if(Get-Item $file.FullName -Stream $ZoneIdentifierStream -ErrorAction SilentlyContinue){
                                $smsg = "$($file.fullname) has  Stream $($ZoneIdentifierStream)" ; 
                                #if(Get-Content $file.FullName -Stream "Zone.Identifier" |?{$_ -match 'ZoneId=3'}){
                                if(Get-Content $file.FullName -Stream "Zone.Identifier" |?{$_ -match $rgxZoneID}){                            
                                    $smsg = "$($smsg) and matches $($rgxZoneID.tostring()):  isBLOCKED" ;
                                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                                    #$file.FullName | write-output ; # unblock-file won't take the fullname string properly via pipeline (throws Unblock-File : The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or the input and its properties do not match any of the parameters that take pipeline input.)
                                    # drop the fileinfo object into the pipe
                                    $file | write-output ; 
                                } else { 
                                    $smsg = "$($smsg) and NOTmatches $($rgxZoneID.tostring())': isUNBLOCKED" ; 
                                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;       
                                } ; 
                            } else { 
                                $smsg = "$($file.fullname) has NO Stream $($ZoneIdentifierStream): isUNBLOCKED" ; 
                                if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;       
                            } ;  
                    
                        } CATCH {
                            Write-Warning "Failed to read ADS for '$($file.FullName)': $_"
                        }
                    }
                } CATCH {
                    Write-Warning "Failed to process path '$AnItem': $_"
                }
            } ;  # loop-E
        }
        END {
            # No cleanup needed
        }
    }
#endregion TEST_FILEBLOCKEDSTATUSTDO ; #*------^ END Test-FileBlockedStatusTDO ^------

