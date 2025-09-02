# repair-FileEncodingMulti.ps1

    #*------v Function repair-FileEncodingMulti v------
    function repair-FileEncodingMulti {
        <#
        .SYNOPSIS
        repair-FileEncodingMulti.ps1 - Given the path to a problematic file - one that switches encoding mid-file (symptom: suddenly pads every character with spaces (NUL AKA \0 chars)), renames the original file to suffix _BROKENENCODING.[orig extension], and runs a replace '\0','' on the original content, with set-content -encoding UTF8 to a new file copy.
        .NOTES
        Version     : 1.6.2
        Author      : Todd Kadrie
        Website     :	http://www.toddomation.com
        Twitter     :	@tostka / http://twitter.com/tostka
        CreatedDate : 2019-02-06
        FileName    :
        License     : MIT License
        Copyright   : (c) 2019 Todd Kadrie
        Github      : https://github.com/tostka/powershell
        AddedCredit : REFERENCE
        AddedWebsite:	URL
        AddedTwitter:	URL
        REVISIONS
        * 5:03 PM 9/2/2025 init 
        .DESCRIPTION
        repair-FileEncodingMulti.ps1 - Given the path to a problematic file - one that switches encoding mid-file (symptom: suddenly pads every character with spaces (NUL AKA \0 chars)) - this script renames the original file to suffix _BROKENENCODING.[orig extension], and runs a replace '\0','' on the original content, with set-content -encoding UTF8 to a new file copy.

        .PARAMETER  Path
        Path to a file or Directory to be checked for encoding or encoding-conversion damage [-Path C:\sc\powershell]    
        .PARAMETER Whatif
        Parameter to run a Test no-change pass [-Whatif switch]
        .EXAMPLE
        PS> repair-FileEncodingMulti.ps1 -replaceChars
        In files in default path (C:\sc\powershell), in files Where-Object high-ascii chars are found, replace the chars with matching low-bit chars (whatif is autoforced true to ensure no accidental runs)
        .EXAMPLE
        PS> repair-FileEncodingMulti.ps1 -path C:\sc\verb-AAD -replacechars -whatif:$false ;
        Exec-pass: problem char files, replacements, with explicit path and overridden whatif
        .EXAMPLE
        PS> gci c:\sc\ -recur| ?{$_.extension -match '\.ps((d|m)*)1' } | 
        PS>     select -expand fullname | repair-FileEncodingMulti -whatif ;
        Recurse a sourcecode root, for ps-related files, expand the fullnames and run the set through repair-FileEncodingMulti with whatif
        .LINK
        https://github.com/tostka/verb-io
        #>
        # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
        [CmdletBinding()]
        [Alias('fix-encoding')]
        PARAM(
            [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,HelpMessage="Path to a file or Directory to be checked for encoding or encoding-conversion damage [-Path C:\sc\powershell]")]
                #[ValidateScript({Test-Path $_ -PathType 'Container'})]
                [ValidateScript({Test-Path $_ -pathtype leaf})]
                [string[]] $Path,        
            [Parameter(HelpMessage="Encoding to be coerced on targeted files (defaults to UTF8, supports:ASCII|BigEndianUnicode|BigEndianUTF32|Byte|Default|OEM|String|Unicode|UTF7|UTF8|UTF32)[-EncodingTarget ASCII]")]
                [ValidateSet('ASCII','BigEndianUnicode','BigEndianUTF32','Byte','Default','OEM','String','Unicode','UTF7','UTF8','UTF32')]
                [string]$EncodingTarget= 'UTF8',        
            [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
                [switch] $whatIf
        ) ;
        BEGIN{
            #*======v SUB MAIN v======
            write-verbose 'repair-FileEncodingMulti.ps1' 

        } ;  # BEG-E
        PROCESS{
            $Error.Clear() ;
            $ttl=($Path|measure).count ;
            $smsg="Processing $($ttl) matching files..." ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $procd=0 ;
            foreach($Pth in $Path) {
                $procd++ ;
                TRY {
                    $sfile = (get-childitem -path $Pth -ea STOP)
                    $bufile = join-path $sfile.directory -child "$($sfile.basename)_BROKENENCODING$($sfile.extension)" -ea STOP ; 
                    get-childitem -path $Pth -EA STOP| rename-item -newname $bufile -verbose -EA STOP -whatif:$($whatif); 
                    $ofile = $bufile ; 
                    write-host -foregroundcolor green "=($($procd)/$($ttl)):$($ofile )" ;
                    #$content = (Get-Content -Raw -Encoding $EncodingTarget $ofile -ErrorAction STOP)  ;
                    if($whatif){
                        $content = (Get-Content -Raw $sfile -ErrorAction STOP)  ;
                    }else{
                        $content = (Get-Content -Raw $bufile -ErrorAction STOP)  ;
                    } ; 
                    <#
                    if ($content.Contains([char]0xfffd)) {
                        $smsg= "--(UTF8 conversion fault)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        $content = Get-Content -Raw $ofile -ErrorAction STOP ;
                    } ;
                    #>

                    $content = $content -replace '\0', ''    
                    
                    $error.clear() ;
                    #$smsg = "Conv:$((Get-FileEncoding -Path $ofile).headername.tostring())->$($EncodingTarget):$($ofile)" ;
                    # above was working with output of select-string (path), below is gci output (fullname)
                    #$smsg = "Conv:$((Get-FileEncoding -Path $ofile).tostring())->$($EncodingTarget):$($ofile)"
                    $smsg = "SourceFile was:$($Path)" ; 
                    $smsg += "`nBackupFile is:$($bufile)" ;
                    $smsg += "`nWriting repaired file back to:$($sfile.fullname)" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $content | set-content -path $sfile.fullname  -Encoding $EncodingTarget -verbose -ErrorAction STOP -whatif:$($whatif) ;
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
          
            } ;  # loop-E $item ;
        } ; # PROC-E
        END {
            $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
            write-host $stopResults ; 
        } ;  # END-E
    } ; 
    #*------^ END Function repair-FileEncodingMulti ^------