# repair-FileEncodingMulti.ps1

    #region REPAIR_FILEENCODINGMIXED ; #*------v repair-FileEncodingMixed v------   
    function repair-FileEncodingMixed {
        <#
        .SYNOPSIS
        repair-FileEncodingMixed.ps1 - Given the path to a problematic file - one that switches encoding mid-file (symptom: suddenly pads every character with spaces (NUL AKA \0 chars)) - this script renames the original file to suffix _MIXEDENCODING.[orig extension], and runs a replace '\0','' on the original content, then writtes updated content back to original file name, with UTF8 explicit encoding.
        .NOTES
        Version     : 0.1.3
        Author      : Todd Kadrie
        Website     :	http://www.toddomation.com
        Twitter     :	@tostka / http://twitter.com/tostka
        CreatedDate : 2025-09-03
        FileName    :
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-IO
        Tags        : Powershell,Filesystem,Encoding,Maintenance,Repair
        AddedCredit : REFERENCE
        AddedWebsite:	URL
        AddedTwitter:	URL
        REVISIONS
        * 10:57 AM 9/3/2025 fixed typo, add missing skip return original path to pipe;
             made the BackupFileNameSuffix an overridable param;
            change bufile suffix BROKENENCODING -> MIXEDENCODING;
            ren:repair-FileEncodingMulti -> repair-FileEncodingMixed, more descriptive; 
            added internal pretest for \0 chars, with skip comment (can safely run at all files, skips undamaged); 
            flipped $Path from string[] -> system.io.fileinfo[] fileinfo array ; still have to validate: it will class non-existant files (with distinctive 12/31/1600 timestamps)
            updated CBH w demo that pretests for damage before autorunning fix; 
            updated Alias fix-encoding -> fix-encodingMulti; made -Path mandatory.
        * 3:44 PM 9/2/2025 init 
        .DESCRIPTION
        repair-FileEncodingMixed.ps1 - Given the path to a problematic file - one that switches encoding mid-file (symptom: suddenly pads every character with spaces (NUL AKA \0 chars)) - this script renames the original file to suffix _MIXEDENCODING.[orig extension], and runs a replace '\0','' on the original content, then writtes updated content back to original file name, with UTF8 explicit encoding        
        .PARAMETER Path
        Array of file paths to text files to be checked for mixed encoding issues[-Path C:\pathto\file.txt]
        .PARAMETER EncodingTarget
        Encoding to be coerced on targeted files (defaults to UTF8, supports:ASCII|BigEndianUnicode|BigEndianUTF32|Byte|Default|OEM|String|Unicode|UTF7|UTF8|UTF32)[-EncodingTarget ASCII]
        .PARAMETER BackupFileNameSuffix
        Suffix tag that backupfilename is built with (defaults to 'MIXEDENCODING', override for other variant output)[-BackupFileNameSuffix BADENCODING]
        .PARAMETER Whatif
        Parameter to run a Test no-change pass [-Whatif switch]
        .INPUTS
        Accepts piped input Path leaf filespec array
        .OUTPUTS
        None. Returns no objects or output (.NET types)
        .EXAMPLE
        PS> write-verbose "Test for symptom of break ('\0' chars in file)" ; 
        PS> if(gci $filepath | select-string '\0'){ 
        PS>     write-warning "$($_):`n has BROKEN ENCODING! (contains `'\0`' chars)`nRunning Fix:repair-FileEncodingMult()..."  ; 
        PS>     repair-FileEncodingMult -path $filepath -verbose ; 
        PS> } else {write-host -foregroundcolor green "$($_):`n has NO Encoding issues (no  `'\0`' chars)" } ;  
        Demo that pretests for damaged files, and autoruns repair.
        .EXAMPLE
        PS> if($logfile = gci ".\\InstallCache\$($env:COMPUTERNAME)_Install-Exchange15-TTC.ps1_*.log"  | ?{$_.basename -match '\d{4}\d{2}\d{2}\d{6}$'} | repair-FileEncodingMixed){gc $logfile | select -last 100 } ;  
        Demo resolving & autorepairing a log file, before parsing & tailing most recent log entries to console, for review.
        .LINK
        https://github.com/tostka/verb-io
        #>
        # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
        [CmdletBinding()]
        [Alias('fix-encodingMulti')]
        PARAM(
            [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true,HelpMessage="Array of file paths to text files to be checked for mixed encoding issues[-Path C:\pathto\file.txt]")]
                [ValidateScript({Test-Path $_ -pathtype leaf})]
                [system.io.fileinfo[]] $Path,
            [Parameter(HelpMessage="Encoding to be coerced on targeted files (defaults to UTF8, supports:ASCII|BigEndianUnicode|BigEndianUTF32|Byte|Default|OEM|String|Unicode|UTF7|UTF8|UTF32)[-EncodingTarget ASCII]")]
                [ValidateSet('ASCII','BigEndianUnicode','BigEndianUTF32','Byte','Default','OEM','String','Unicode','UTF7','UTF8','UTF32')]
                [string]$EncodingTarget= 'UTF8',
            [Parameter(HelpMessage="Suffix tag that backupfilename is built with (defaults to 'MIXEDENCODING', override for other variant output)[-BackupFileNameSuffix BADENCODING]")]        
                [string]$BackupFileNameSuffix= 'MIXEDENCODING',         
            [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
                [switch] $whatIf
        ) ;
        BEGIN{
            ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
            $sBnr="#*======v $($CmdletName): v======" ;
            $smsg = $sBnr ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        }  
        PROCESS{
            $ttl=($Path|measure).count ;
            $smsg="Processing $($ttl) file(s)..." ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $procd=0 ;
            foreach($Pth in $Path) {                
                $procd++ ;
                $smsg = $sBnrS="`n#*------v PROCESSING : ($($procd)/$($ttl)): $($Pth.fullname ) v------" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H2 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                TRY {
                    $error.clear() ;
                    #$sfile = (get-childitem -path $Pth -ea STOP)
                    $sfile = $Pth
                    if($Pth | select-string '\0'){
                        $smsg = "CONFIRMED: $($sfile.fullname) HAS MIXED ENCODING (contains `'\0`' chars)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        $bufile = join-path $sfile.directory -child "$($sfile.basename)_$($BackupFileNameSuffix)$($sfile.extension)" -ea STOP ;  
                        $smsg = "Backing up source file to:`n$($bufile)..." ; 
                        if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;                    
                        $Pth | rename-item -newname $bufile -verbose -EA STOP -whatif:$($whatif);                         
                        if($whatif){
                            $workfile = $sfile  ;
                        }else{
                            $workfile = $bufile ; 
                        } ;     
                        $content = (Get-Content -Raw $workfile -ErrorAction STOP)  ;                             
                        if($whatif){$smsg = "-WHATIF:$($whatif):"}else{$smsg = "" }  ; 
                        $smsg += "SourceFile was:`n$($sfile.fullname)" ; 
                        $smsg += "`nBackupFile is:`n$($bufile)" ;
                        $smsg += "`nWriting repaired file back to:`n$($sfile.fullname)" ;
                        $smsg += "`n(returning updated file path to pipeline)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        $content | set-content -path $sfile.fullname  -Encoding $EncodingTarget -verbose -ErrorAction STOP -whatif:$($whatif) ;
                        $sfile.fullname | write-output ;
                        
                    } else {
                        $smsg = "SKIPPING:`n$($sfile.fullname) has *NO* mixed-encoding (does *not* contain '\0' chars)" ; 
                        $smsg += "`n(returning original unmodified file path to pipeline)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        $sfile.fullname | write-output ;
                    } ;                                             
                } CATCH {
                    $ErrorTrapped = $Error[0] ;
                    #write-warning "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
                    $PassStatus += ";ERROR";
                    $smsg= "Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } #Error|Warn
                    else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" }
                    #Continue #STOP(debug)|EXIT(close)|Continue(move on in loop cycle) ;
                    Continue ; 
                } ;
                $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H2 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;  # loop-E $item ;
        } ; # PROC-E
        END {
            $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;  # END-E
    } ; 
    #endregion REPAIR_FILEENCODINGMIXED ; #*------^ END repair-FileEncodingMixed ^------