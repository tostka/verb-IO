# repair-FileEncoding.ps1

#*------v Function repair-FileEncoding v------
function repair-FileEncoding {
    <#
    .SYNOPSIS
    repair-FileEncoding.ps1 - Filter specified Path for risky high-ascii chars & Encoding conversion failure markers, replace each with a low-ascii equiv, (or dash for diamond questionmarks), and convert output file to UTF8
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
    * 4:37 PM 11/22/2022 moved into verb-io; fixed typo utf8 spec (utf-8), flip into an adv function;refactored, added broader try/catch, handling for both 
    file or dir path; simplified logic, does encoding repair always, always detects 
    highascii chars, recommends fixes, but only runs fixes with -ReplaceChars param.
    pulled -ConvertToUTF8Only param, it's the default purpose
    * 1:06 PM 11/22/2022 added adv func/pipeline support; ren fix-encoding (& alias) ->  repair-FileEncoding
    * 12:08 PM 4/21/2021 expanded ss aliases
    * 1:09 PM 1/14/2020 added support for ahk .cbp files (spotted blkdiamonds in ghd), use explicit path to target ahk files. Probably should consider putting .ahk's in as well...
    * 3:00 PM 1/2/2020 got through live pass using ConvertToUTF8Only, initial review of chgs in ghd appears to be functional
    * 2:52 PM 1/2/2020 used a prior version of the replc spec successfully, now have written in the broad conversion, and debugged, but not run prod yet.
    .DESCRIPTION
    repair-FileEncoding.ps1 - Filter specified Path for risky high-ascii chars & Encoding conversion failure markers, replace each with a low-ascii equiv, (or dash for diamond questionmarks), and convert output file to UTF8. Processess all matching ps1, psm1 & psd1 files in the tree.
    doesn't like it when you copy in a revised file from another box from debugging, and the encoding has changed: Tends to describe the file as 'This binary file has changed'. 
    Fix requires flipping the encoding back. 
    Underlying GIT issue documented here:
    [Binary file has changed shows for normal text file · Issue #7857 · desktop/desktop · GitHub - github.com/](https://github.com/desktop/desktop/issues/7857)

    Following high-ascii chars are replaced when -ReplaceChars is used:
    | CharCode | Replacement | Note |
    |---|---|---
    | [Char]0x2013 | " -"  | en dash  |
    | [Char]0x2014 | " -"  | em dash |
    | [Char]0x2015 | " -"  | horizontal bar |
    | [Char]0x2017 | " _"   | double low line |
    | [Char]0x2018 | " `'"  | left single quotation mark |
    | [Char]0x2019 | " `'"  | right single quotation mark |
    | [Char]0x201a | " ,"  | single low-9 quotation mark |
    | [Char]0x201b | " `'"  | single high-reversed-9 quotation mark |
    | [Char]0x201c | " `""  | right double quotation mark |
    | [Char]0x201d | " `""  | right double quotation mark |
    | [Char]0x201e | " `""  | double low-9 quotation mark |
    | [Char]0x2026 | " ..."  | horizontal ellipsis |
    | [Char]0x2032 | " `""  | prime  |
    | [Char]0x2033 | " `"" | double prime |
    | [char]65533  | Unicode Replacement Character (black diamond questionmark) in hex: [char] 0xfffd|


    .PARAMETER  Path
    Path to a file or Directory to be checked for encoding or encoding-conversion damage [-Path C:\sc\powershell]
    .PARAMETER EncodingTarget
    Encoding to be coerced on targeted files (defaults to UTF8, supports:ASCII|BigEndianUnicode|BigEndianUTF32|Byte|Default (system active codepage, freq ANSI)|OEM|String|Unicode|UTF7|UTF8|UTF32)[-EncodingTarget ASCII]
    .PARAMETER showDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS> repair-FileEncoding.ps1 -replaceChars
    In files in default path (C:\sc\powershell), in files Where-Object high-ascii chars are found, replace the chars with matching low-bit chars (whatif is autoforced true to ensure no accidental runs)
    .EXAMPLE
    PS> repair-FileEncoding.ps1 -path C:\sc\verb-AAD -replacechars -whatif:$false ;
    Exec-pass: problem char files, replacements, with explicit path and overridden whatif
    .EXAMPLE
    PS> gci c:\sc\ -recur| ?{$_.extension -match '\.ps((d|m)*)1' } | 
    PS>     select -expand fullname | repair-FileEncoding -whatif ;
    Recurse a sourcecode root, for ps-related files, expand the fullnames and run the set through repair-FileEncoding with whatif
    .LINK
    https://github.com/tostka/verb-io
    #>
    #Requires -Modules verb-IO, verb-logging, verb-Text
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    [CmdletBinding()]
    [Alias('fix-encoding')]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,HelpMessage="Path to a file or Directory to be checked for encoding or encoding-conversion damage [-Path C:\sc\powershell]")]
        #[ValidateScript({Test-Path $_ -PathType 'Container'})]
        [ValidateScript({Test-Path $_ })]
        [string[]] $Path="C:\sc\powershell",
        [Parameter(HelpMessage="Array of extensions to be included in checks of Containers (defaults to .ps1|.psm1|.psd1|.cbp) [-IncludeExtentions '.ps1','.psm1','.psd1']")]
        [array]$IncludeExtentions = @('*.ps1','*.psm1','*.psd1','*.cbp'),
        [Parameter(HelpMessage="Encoding to be coerced on targeted files (defaults to UTF8, supports:ASCII|BigEndianUnicode|BigEndianUTF32|Byte|Default|OEM|String|Unicode|UTF7|UTF8|UTF32)[-EncodingTarget ASCII]")]
        [ValidateSet('ASCII','BigEndianUnicode','BigEndianUTF32','Byte','Default','OEM','String','Unicode','UTF7','UTF8','UTF32')]
        [string]$EncodingTarget= 'UTF8',
        [Parameter(HelpMessage="Switch that specifies to also update files with high ascii chars: All matches are reqplaced with the equiv low-asci equivs[-ReplaceChars]")]
        [switch] $ReplaceChars,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    BEGIN{
        #*======v SUB MAIN v======
        #region INIT; # ------
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        #region START-LOG-HOLISTIC #*------v START-LOG-HOLISTIC v------
        # Single log for script/function example that accomodates detect/redirect from AllUsers scope'd installed code, and hunts a series of drive letters to find an alternate logging dir (defers to profile variables)
        #${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if(!(get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
        foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
        if(!(get-variable rgxPSAllUsersScope -ea 0)){
            $rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;
        } ;
        if(!(get-variable rgxPSCurrUserScope -ea 0)){
            $rgxPSCurrUserScope="^$([regex]::escape([Environment]::GetFolderPath('MyDocuments')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps((d|m)*)1|dll)$" ;
        } ;
        $pltSL=[ordered]@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($whatif) ;} ;
        $pltSL.Tag = $ModuleName ; 
        if($script:PSCommandPath){
            if(($script:PSCommandPath -match $rgxPSAllUsersScope) -OR ($script:PSCommandPath -match $rgxPSCurrUserScope)){
                $bDivertLog = $true ; 
                switch -regex ($script:PSCommandPath){
                    $rgxPSAllUsersScope{$smsg = "AllUsers"} 
                    $rgxPSCurrUserScope{$smsg = "CurrentUser"}
                } ;
                $smsg += " context script/module, divert logging into [$budrv]:\scripts" 
                write-verbose $smsg  ;
                if($bDivertLog){
                    if((split-path $script:PSCommandPath -leaf) -ne $cmdletname){
                        # function in a module/script installed to allusers|cu - defer name to Cmdlet/Function name
                        $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
                    } else {
                        # installed allusers|CU script, use the hosting script name
                        $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
                    }
                } ;
            } else {
                $pltSL.Path = $script:PSCommandPath ;
            } ;
        } else {
            if(($MyInvocation.MyCommand.Definition -match $rgxPSAllUsersScope) -OR ($MyInvocation.MyCommand.Definition -match $rgxPSCurrUserScope) ){
                 $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
            } elseif(test-path $MyInvocation.MyCommand.Definition) {
                $pltSL.Path = $MyInvocation.MyCommand.Definition ;
            } elseif($cmdletname){
                $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
            } else {
                $smsg = "UNABLE TO RESOLVE A FUNCTIONAL `$CMDLETNAME, FROM WHICH TO BUILD A START-LOG.PATH!" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } #Error|Warn|Debug 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                BREAK ;
            } ; 
        } ;
        write-verbose "start-Log w`n$(($pltSL|out-string).trim())" ; 
        $logspec = start-Log @pltSL ;
        $error.clear() ;
        TRY {
            if($logspec){
                $logging=$logspec.logging ;
                $logfile=$logspec.logfile ;
                $transcript=$logspec.transcript ;
                $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
                start-Transcript -path $transcript ;
            } else {throw "Unable to configure logging!" } ;
        } CATCH [System.Management.Automation.PSNotSupportedException]{
            if($host.name -eq 'Windows PowerShell ISE Host'){
                $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
            } else { 
                $smsg = "This host does *not* support native (start-)transcription" ; 
            } ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;
        #endregion START-LOG-HOLISTIC #*------^ END START-LOG-HOLISTIC ^------

        #region BANNER ; #*------v BANNER v------
        $sBnr="#*======v $(${CmdletName}): v======" ;
        $smsg = $sBnr ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #endregion BANNER ; #*------^ END BANNER ^------

    
        # Build a regex char set of chars to be detected and replaced (with the -replace block).
        [array]$chars=@() ;
        $chars+= [Char]0x2013; # en dash
        $chars+= [Char]0x2014; # em dash
        $chars+= [Char]0x2015; # horizontal bar
        $chars+= [Char]0x2017; # double low line
        $chars+= [Char]0x2018; # left single quotation mark
        $chars+= [Char]0x2019; # right single quotation mark
        $chars+= [Char]0x201a; # single low-9 quotation mark
        $chars+= [Char]0x201b; # single high-reversed-9 quotation mark
        $chars+= [Char]0x201c; # left double quotation mark
        $chars+= [Char]0x201d; # right double quotation mark
        $chars+= [Char]0x201e; # double low-9 quotation mark
        $chars+= [Char]0x2026; # horizontal ellipsis
        $chars+= [Char]0x2032; # prime
        $chars+= [Char]0x2033; # double prime
        $chars+= [char]65533;  # Unicode Replacement Character (black diamond questionmark) in hex: [char] 0xfffd
        $chars | ForEach-Object -begin {[string]$rgxChars = $null } -process {$rgxChars+=$_} #-end {"`$rgxChars: $(($rgxChars|out-string).trim())"} ;
        $regex = '[' + [regex]::escape($rgxChars) + ']' ;

    } ;  # BEG-E
    PROCESS{
        $Error.Clear() ;

        foreach($Pth in $Path) {
            TRY{
                switch( (get-item $Pth -ErrorAction STOP).psIsContainer){
                    $true {
                        write-host "Container path detected, recursing files..." ;
                        $smsg = "Collecting matching files:`n$($Pth)..." ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                        else { write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

                        # use select-string to do the regex search for problem chars
                        #$files = Get-ChildItem $Pth\* -Include *.ps1,*.psm1,*.psd1 -recurse |
                        # add ahk cdeblock file support
                        $pltGci=[ordered]@{
                            path="$($Pth)\*" ;
                            #Include='*.ps1', '*.psm1', '*.psd1', '*.cbp' ;
                            Include = $IncludeExtentions ; 
                            recurse=$true ;
                            erroraction = 'STOP' ;
                        } ;
                        $smsg = "Get-ChildItem w`n$(($pltGci|out-string).trim())" ; 
                        if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                        $files = Get-ChildItem @pltGci | where-object { $_.length } ;
                        if ($ReplaceChars) {
                            $smsg = "-ReplaceChars specified: Pulling files with problematic high-ascii chars in specified Path`n$($Pth)" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                            else { write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            $smsg = "`$rgxChars: $(($rgxChars|out-string).trim())"
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                            else { write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            $smsg = "`$regex:$($regex)" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                            else { write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

                            #$files = $files | select-string $regex | select -unique Path ;
                        } ;
                
                    }
                    $false {
                        $smsg = "Leaf File object path detected, handling single file:`n$($Pth)..." ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                        $files = Get-ChildItem $Pth -ErrorAction STOP|
                            where-object { $_.length } ;
                        

                    } ;
                } ;

 
                $rfiles = $files | select-string -pattern $regex | select -unique Path ;
                if($rfiles){
                    $smsg = "`nFiles with high-ascii chars detected (use -ReplaceChars to fix):`n$(($rfiles|out-string).trim())" ; 
                    $smsg += "`n`n`$rgxChars: $(($rgxChars|out-string).trim())"
                    $smsg +="`n`$regex:$($regex)" ;
                    $smsg += "`n$(($rfiles | gci |  select-string -pattern $regex |  ft -a filename,linenumber,line|out-string).trim())`n" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } 
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                } ; 

                $cfiles = $files |
                    select @{n='Path';e={$_.FullName}}, @{n='Encoding';e={Get-FileEncoding $_.FullName}} |
                        Where-Object {$_.Encoding -ne $EncodingTarget} ;
                    # below is no longer the output of get-fileencoding, it's just a string 'Encoding' 
                    #Where-Object {$_.Encoding.HeaderName -ne $EncodingTarget} ;
                $cfiles = $cfiles | select Path ;
                if($cfiles){
                    $smsg = "Files with bad encodings (will be re-encoded):`n$(($cfiles|out-string).trim())" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ; 

                write-verbose "hybrid the two sets"
                #$diff = Compare-Object -ReferenceObject $cfiles -DifferenceObject $rfiles -Property path ; 
                # pull the Additions: entries with .SideIndicator -eq "=>" (present in right list but not in left)
                # $result|?{$_.SideIndicator -eq "=>"}
                # simpler to combo and select uniq
                [array]$tfiles = @() ;
                $tfiles += @($cfiles) ; 
                if ($ReplaceChars){
                    $tfiles += @($rfiles) ; 
                } ; 
                $tfiles = $tfiles.path | select -unique ;

            } CATCH {
                $ErrorTrapped = $Error[0] ;
                #write-warning "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
                $PassStatus += ";ERROR";
                $smsg= "Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } #Error|Warn
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" }
                #Continue #STOP(debug)|EXIT(close)|Continue(move on in loop cycle) ;
            } ;

            $ttl=($tfiles|measure).count ;
            $smsg="Processing $($ttl) matching files..." ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $procd=0 ;
            $tfiles | Foreach-Object {
                $procd++ ;
                TRY {
                    #$ofile=$_.path;
                    #$ofile = $_.fullname ; 
                    $ofile = $_
                    write-host -foregroundcolor green "=($($procd)/$($ttl)):$($ofile )" ;
                    $content = (Get-Content -Raw -Encoding $EncodingTarget $ofile -ErrorAction STOP)  ;
                    if ($content.Contains([char]0xfffd)) {
                        $smsg= "--(UTF8 conversion fault)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        $content = Get-Content -Raw $ofile -ErrorAction STOP ;
                    } ;

                    if ($ReplaceChars){
                        if($content -match $regex){
                            $content = $content -replace [Char]0x2013, "-" `
                            -replace [Char]0x2014, "-" `
                            -replace [Char]0x2015, "-" `
                            -replace [Char]0x2017, "_" `
                            -replace [Char]0x2018, "`'" `
                            -replace [Char]0x2019, "`'" `
                            -replace [Char]0x201a, "," `
                            -replace [Char]0x201b, "`'" `
                            -replace [Char]0x201c, "`"" `
                            -replace [Char]0x201d, "`"" `
                            -replace [Char]0x201e, "`"" `
                            -replace [Char]0x2026, "..." `
                            -replace [Char]0x2032, "`"" `
                            -replace [Char]0x2033, "`"" ;
                        } ;
                        # finally rplc any remaining blackdiamond questionmarks with -
                        $content = $content -replace [char]65533, "-" ;
                    } ;
                    
                    $error.clear() ;
                    #$smsg = "Conv:$((Get-FileEncoding -Path $ofile).headername.tostring())->$($EncodingTarget):$($ofile)" ;
                    # above was working with output of select-string (path), below is gci output (fullname)
                    $smsg = "Conv:$((Get-FileEncoding -Path $ofile).tostring())->$($EncodingTarget):$($ofile)"
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $content | set-content -path $ofile  -Encoding $EncodingTarget  -ErrorAction STOP -whatif:$($whatif) ;
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
            } ;   # foreach-object-E
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
#*------^ END Function repair-FileEncoding ^------
