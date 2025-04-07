#*------v convert-VideoToMp3.ps1 v------
function convert-VideoToMp3 {
    <#
    .SYNOPSIS
    convert-VideoToMp3() - convert passed video files to mp3 files in same directory
    .NOTES
    Author: Todd Kadrie
    Website:	http://toddomation.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 12:38 AM 3/2/2025 added support for Remove-InvalidFileNameCharsTDO, cleaning output filenames of garbage yt adds to titles etc
    * 8:09 PM 11/15/2023 recoded around vlc conversion bugs; moved output into $env:temp, then post-move back to target dir; also add retry: noticed on zero-len outfile, that rerunning sometimes properly processed the file.
    * 1:41 PM 7/26/2023 add: $rgxYTFormatExts = "(?i:^\.(MOV|MPG|MP4|AVI|WMV|FLV|WEBM|MKV|MPEG)$)" ; flipped extension refs to using that combo to detect pre-transcode YT content
    * 10:32 AM 7/21/2023 add both aliases convert-toMp3 & convertTo-Mp3(proper verb); fixed alias; removed unused params & showdebug support (v write-verbose) added xmpl; worked on path [] in latest pass ; add: rename nested 
        try's against rename-item, move-item, and [System.IO.File]::Move() - hasn't 
        triggered move att3empt yet on psv5 (rename-item -literalpath working), but the 
        above were options for all way back to psv2 support. Even then could still 
        proxy through a tmp file as well.  
    * 10:33 PM 7/17/2023 updated clash test rename-item code (was bombing consistently); also updated apostrophe test to solely test in path, not leaf filename.
    * 12:05 AM 7/16/2023 added inputobject.fullname apostrophe test (parent path with apost crashes rediscover post convert)
    * 5:43 PM 4/23/2023 add support for checking progs86 & progs (new support for 64bit vlc), orig wasn't finding vlc on new box.
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    # 5:26 PM 10/5/2021 ren, and alias orig: convert-tomp3 -> convert-VideoToMp3 (added alias:convertto-mp3); also build into freestanding function in verb-IO
    # 12:02 PM 4/1/2017 convert-ToMp3: if it's a string, it's not going to have a fullname prop - it's a full path string
    # 7:03 PM 11/8/2016 code in exception for directory objects, ren the new instead of the original, add -ea 0 to suppress $cf test not found failures, finding that renames fail if there's an existing fn clash -> ren the clash
    * 7:01 PM 11/7/2016 set the $serrf & $soutf to -showdebug only,
    * 7:38 PM 11/6/2016 swap all uses of $inputfile => $tf, replc \ => \\ (parsing bug in vlc, when quotes & dlquotes are comboed)
    * 4:50 PM 11/6/2016 - essentially functional, but still requires a foreach outside of function/script to get through collections/arrays.
        put in inbound object type checking, as fso's have to use fullname, while strings, use base string as a path
        Also renamed convert-VLCWavToMp3.ps1 into convert-ToMp3.ps1
    * 11:44 PM 11/5/2016 - initial pass
    .DESCRIPTION
    convert-VideoToMp3() - convert passed video files to mp3 files in same directory

    [Supported YouTube file formats - YouTube Help](https://support.google.com/youtube/troubleshooter/2888402?hl=en)
    - MOV
    - .MPEG-1
    - .MPEG-2
    - .MPEG4 (h.264)
    - .MP4
    - .MPG
    - .AVI
    - .WMV
    - .MPEGPS
    - .FLV
    - 3GPP
    - WebM
    - DNxHR
    - ProRes
    - CineForm
    - HEVC (h265, h.265 ext:.hevc)

    .PARAMETER  InputObject
    Name or IP address of the target computer
    .PARAMETER Bitrate
    Bitrate for transcoded output (defaults to 320k)
    .PARAMETER samplerate
    Samplerate for transcoded output (defaults to 44100)
    .PARAMETER encoder
    Encoder choice [f|vlc (default)]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass, and log results [-Whatif switch]
    .PARAMETER ShowProgress
    Parameter to display progress meter [-ShowProgress switch]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns an object with uptime data to the pipeline.
    .EXAMPLE
    $bRet=convert-VideoToMp3 -InputObject "C:\video.mkv" ;
    Convert Specified video file to mp3.
    .EXAMPLE
    PS> $whatif = $true ;
    PS> write-verbose 'cd to target dir' ; 
    PS> cd .\somepath ; 
    PS> write-verbose 'run recursive pass from there down' ; 
    PS> $rgxInputExts = "(?i:^\.(MPEG|AVI|ASF|WMV|WMA|MP4|MOV|3GP|OGG|OGM|MKV|WEBM|WAV|DTS|AAC|AC3|A52|FLAC|FLV|MXF|MIDI|SMF)$)" ;
    PS> TRY{
    PS>   if($tvids = get-childitem * -recurse | ?{$_.extension -match $rgxInputExts}){
    PS>       if($tvids |?{$_.fullname -notmatch 'C:\\vidtmp\\convert\\'}){
    PS>           throw "NOT RUNNING FROM PROPER C:\VIDTMP\CONVERT DIR!" ; BREAK ;
    PS>       }else {
    PS>           write-host -foregroundcolor green "`nMatched Vids for Conversion:`n$(($tvids.fullname|out-string).trim())`n" ; 
    PS>           $tvids |%{
    PS>              convert-VideoToMp3 -inputobject $_ -Verbose:$($VerbosePreference -eq 'Continue') -whatif:$($whatif) ;
    PS>           } ;
    PS>       } ;
    PS>   } else { 
    PS>     write-warning "No files matching `n$($rgxInputExts)`nfound..." ; 
    PS>   } ; 
    PS> } CATCH {
    PS>     $ErrTrapd=$Error[0] ;
    PS>     $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
    PS>     write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
    PS> } ; 
    Typical pass with test to ensure proper format and in target convert dir
    #>
    [CmdletBinding()]
    [Alias('convert-ToMp3','convertTo-Mp3')]
    PARAM (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, Mandatory = $True, HelpMessage = "File(s) to be transcoded")]
            $InputObject,
        [parameter(HelpMessage = "Bitrate for transcoded output (defaults to 320k)")]
            [int]$bitrate = 320,
        [parameter(HelpMessage = "Samplerate for transcoded output (defaults to 44100)")]
            [int]$samplerate = 44100,
        [Parameter(Mandatory = $false, HelpMessage = "Specify Encoder forconversion (F(MPEG), VLC; defaults VLC)[-encoder F")]
            [ValidateSet("F", "VLC")]
            [string]$encoder = "VLC",
        [Parameter(HelpMessage = 'Switch to remove invalid filename characters from output names (as default naming of source video files, using online tags, can frequently result in invalid characters in the filenames)[$switch]')]
            [switch] $fixFileNames = $true ,
        [Parameter(HelpMessage = 'Debugging Flag [$switch]')]
            [switch] $showDebug,
        [Parameter(HelpMessage = 'Whatif Flag  [$switch]')]
            [switch] $whatIf
    ) ; # PARAM-E

    <# input formats supported by VLC
        MPEG (ES,PS,TS,PVA,MP3), AVI, ASF |WMV |WMA, MP4 |MOV |3GP, OGG |OGM |Annodex, Matroska (MKV), Real, WAV (including DTS), Raw Audio: DTS, AAC, AC3/A52, Raw DV, FLAC, FLV (Flash), MXF, Nut, Standard MIDI |SMF, Creative™ Voice.
    #>

    BEGIN {

        #*======v FUNCTIONS v======

        #*----------v Function Remove-InvalidFileNameCharsTDO() v----------
        if(-not (get-command Remove-InvalidFileNameCharsTDO -ea 0)){
            function Remove-InvalidFileNameCharsTDO{                                                                                                                                                                                                                                                                                                                                                                                                                                                <#
            .SYNOPSIS
            Remove-InvalidFileNameCharsTDO.ps1 - Removes characters from a string that are not valid in Windows file names.
            .NOTES
            Version     : 1.1.2
            Author      : Todd Kadrie
            Website     :	http://www.toddomation.com
            Twitter     :	@tostka / http://twitter.com/tostka
            CreatedDate : 2025-03-01
            FileName    : Remove-InvalidFileNameCharsTDO.ps1
            License     : http://creativecommons.org/licenses/by-sa/4.0/
            Copyright   : 2016 Chris Carter
            Github      : https://github.com/tostka/verb-io
            Tags        : Powershell,RegularExpression,String,filesystem
            AddedCredit : Chris Carter
            AddedWebsite:	https://gallery.technet.microsoft.com/Remove-Invalid-Characters-39fa17b1
            AddedTwitter:	URL
            REVISIONS
            * 7:15 PM 3/1/2025 spliced in missing -ReplaceBrackets & -dashReplaceChars handling pieces in the unpathed else block (wasn't doing those removals as intended); 
                added -ReplaceBrackets (sub square brackets with parenthesis), and -DashReplaceChars (characters to be replaced with chars specified by the new -DashReplacement character or string); 
                added additional exmpl with pipeline support
            * 10:56 PM 2/13/2025 converted to function, expanded CBH
            * August 8, 2016 v1.5.1  CC posted latest copy
            .DESCRIPTION
            Remove-InvalidFileNameCharsTDO accepts a string and removes characters that are invalid in Windows file names. 

            This is an extension of Chris Carter's original simpler function, extended with support for replacement of brackets (to parenthesis) and configurable additional characters. 

            The -Name parameter can also clean file paths. If the string begins with "\\" or a drive like "C:\", it will then treat the string as a file path and clean the strings between "\". This has the side effect of removing the ability to actually remove the "\" character from strings since it will then be considered a divider.
    
            Use of -RemoveSpace will crush out all space charcters (replace with nothing). 

            Use of the additional -ReplaceBrackets switch will replace square brackets ([]) with matching paranthesis characters. 

            You can optionally use the -DashReplacement parameter to specifify a string array of characters to be replaced with a character/string specified by the new -DashReplaceChars parameter. 

            The resulting cleaned string or path will be returned to the pipeline. 
 
            The Replacement parameter will replace the invalid characters with the specified string. To remove rather than replace the invalid characters, use 
 
            The Name parameter can also clean file paths. If the string begins with "\\" or a drive like "C:\", it will then treat the string as a file path and clean the strings between "\". This has the side effect of removing the ability to actually remove the "\" character from strings since it will then be considered a divider.
    
            .PARAMETER Name
            Array of filenames or fullnames to strip of invalid characters.[-name @('filename.ext','c:\pathto\file.ext')]
            .PARAMETER Replacement
            Specifies the string to use as a replacement for the invalid characters (leave blank to delete without replacement).[-Replacement ' ']
            .PARAMETER RemoveSpace
            Switch to include the space character (U+0020) in the removal process.[-Removespace]
            .PARAMETER ReplaceBrackets
            Switch to replace square brackets with paranthesis characters[-ReplaceBrackets]
            .PARAMETER DashReplaceChars
            Characters to be replaced with the -DashReplacement specification[-DashReplaceChars @('|','~')]
            .PARAMETER DashReplacement
            Character to use for all -DashReplacement characters (defaults to dash '-')[-DashReplacement 'x']
            .INPUTS
            System.String
            Remove-InvalidFileNameCharsTDO accepts System.String objects in the pipeline.
 
            Remove-InvalidFileNameCharsTDO accepts System.String objects in a property Name from objects in the pipeline.
 
            .OUTPUTS
            System.String 
            .EXAMPLE
            PS> Remove-InvalidFileNameCharsTDO -Name "<This /name \is* an :illegal ?filename>.txt"
            Output: This name is an illegal filename.txt
 
            This command will strip the invalid characters from the string and output a clean string.
            .EXAMPLE
            PS> Remove-InvalidFileNameCharsTDO -Name "<This /name \is* an :illegal ?filename>.txt" -RemoveSpace
            Output: Thisnameisanillegalfilename.txt
 
            This command will strip the invalid characters from the string and output a clean string, removing the space character (U+0020) as well.
            .EXAMPLE
            PS> Remove-InvalidFileNameCharsTDO -Name '\\Path/:|?*<\With:*?>\:Illegal /Characters>?*.txt"'
            Output: \\Path\With\Illegal Characters.txt
 
            This command will strip the invalid characters from the path and output a valid path. Note: it would not be able to remove the "\" character.
            .EXAMPLE
            PS> Remove-InvalidFileNameCharsTDO -Name '\\Path/:|?*<\With:*?>\:Illegal /Characters>?*.txt"' -RemoveSpace
            Output: \\Path\With\IllegalCharacters.txt
 
            This command will strip the invalid characters from the path and output a valid path, also removing the space character (U+0020) as well. Note: it would not be able to remove the "\" character.
            .EXAMPLE
            PS> Remove-InvalidFileNameCharsTDO -Name "<This /name \is* an :illegal ?filename>.txt" -Replacement +
            Output: +This +name +is+ an +illegal +filename+.txt
 
            This command will strip the invalid characters from the string, replacing them with a "+", and outputting the result string.
            .EXAMPLE
            PS> Remove-InvalidFileNameCharsTDO -Name "<This /name \is* an :illegal ?filename>.txt" -Replacemet + -RemoveOnly "*", 58, 0x3f
            Output: +This +name +is an illegal filename+.txt
 
            This command will strip the invalid characters from the string, replacing them with a "+", except the "*", the charcter with a decimal value of 58 (:), and the character with a hexidecimal value of 0x3f (?). These will simply be removed, and the resulting string output.
            .EXAMPLE
            PS> $results = Remove-InvalidFileNameCharsTDO  -Name "C:\vidtmp\convert\Westworld\001 - Westworld S4 Official Soundtrack ｜ Main Title Theme - Ramin Djawadi ｜ WaterTower(UL20220815-H9qE9D0TjJo).mp3" -Verbose -ReplaceBrackets ;
            PS> $results ; 

                C:\vidtmp\convert\Westworld\001 - Westworld S4 Official Soundtrack - Main Title Theme - Ramin Djawadi - WaterTower(UL20220815-H9qE9D0TjJo).mp3

            Demo use of -replacebrackets & uses a -Name string with a targeted 
            .EXAMPLE
            PS> $results = "\\jun|/k{$[;:]left" | Remove-InvalidFileNameCharsTDO -Verbose -ReplaceBrackets
            PS> $results ; 

                junk{$(;)left

            .Link
            System.RegEx
            .Link
            about_Join
            .Link
            about_Operators
            .LINK
            https://github.com/tostka/verb-io
            #>
                #[CmdletBinding(HelpURI='https://gallery.technet.microsoft.com/scriptcenter/Remove-Invalid-Characters-39fa17b1')]
                # defer to updated local CBH
                [CmdletBinding()]
                [Alias('Remove-InvalidFileNameChars')]
                Param(
                    [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
                        HelpMessage="Array of filenames or fullnames to strip of invalid characters.[-name @('filename.ext','c:\pathto\file.ext')]")]
                        [String[]]$Name,
                    [Parameter(Position=1,HelpMessage="Specifies the string to use as a replacement for the invalid characters (leave blank to delete without replacement).[-Replacement ' ']")]
                        [String]$Replacement='',
                    [Parameter(HelpMessage="Switch to include the space character (U+0020) in the removal process.[-Removespace]")]
                        [switch]$RemoveSpace,
                    [Parameter(HelpMessage="Switch to replace square brackets with paranthesis characters[-ReplaceBrackets]")]
                        [switch]$ReplaceBrackets,
                    [Parameter(HelpMessage="Characters to be replaced with the -DashReplacement specification (default includes a pipe-lookalike that doesn't replace properly as part of a regex)[-DashReplaceChars @('|','~')]")]
                        [string[]]$DashReplaceChars = @("｜"),
                    [Parameter(HelpMessage="Character to use for all -DashReplacement characters (defaults to dash '-')[-DashReplacement 'x']")]
                        [string]$DashReplacement='-'
                ) ; 
                BEGIN {
                    # dashReplaceChars addresses issues getting pipe-lookalikes purged, that don't come out of the OS list; or even properly match or replace as part of a regex

                    #Get an array of invalid characters from the OS
                    $arrInvalidChars = [System.IO.Path]::GetInvalidFileNameChars()

        
                    #Cast into a string, adding the space character
                    $(@($arrInvalidChars);@(' '))  | 
                        foreach -begin {[string]$rgxChars = $null } -process {$rgxChars+=$_} ; 
                    [regex]$rgxInvalidCharsWithSpace = '[' + [regex]::escape($rgxChars) + ']' ;
                    write-verbose "`$rgxInvalidCharsWithSpace: $($rgxInvalidCharsWithSpace.tostring())" ; 

                    # cast to string wo space char
                    $arrInvalidChars | 
                        foreach -begin {[string]$rgxChars = $null } -process {$rgxChars+=$_} ; 
                    [regex]$rgxinvalidCharsNoSpace = '[' + [regex]::escape($rgxChars) + ']' ;
                    write-verbose "`$rgxinvalidCharsNoSpace: $($rgxinvalidCharsNoSpace.tostring())" ; 

                    # build the $dashReplaceChars into a rgx as well
                    $dashReplaceChars | 
                        foreach -begin {[string]$rgxChars = $null } -process {$rgxChars+=$_} ; 
                    [regex]$rgxdashReplaceChars = '[' + [regex]::escape($rgxChars) + ']' ;
                    write-verbose "`$rgxdashReplaceChars: $($rgxdashReplaceChars.tostring())" ; 

                    #Check that the -Replacement specified does not have invalid characters itself
                    if ($RemoveSpace) {
                        if ($Replacement -match $rgxInvalidCharsWithSpace) {
                            Write-Error "The Replacement string also contains invalid filename characters."; break ; 
                        }
                    } else {
                        if ($Replacement -match $rgxInvalidCharsNoSpace) {
                            Write-Error "The Replacement string also contains invalid filename characters."; break ; 
                        }
                    }

                    #*======v FUNCTIONS v======
                    #*------v Function Remove-Chars v------
                    Function Remove-Chars {
                        PARAM(
                            [Parameter(Mandatory=$true,Position=0,HelpMessage="String to be processed")]
                                [string]$String,
                            [Parameter(Position=0,HelpMessage="Specifies the string to use as a Replacement for the invalid characters.")]
                                [string]$Replacement,
                            [Parameter(HelpMessage="The RemoveSpace parameter will include the space character (U+0020) in the removal process.")]
                                [switch]$RemoveSpace
                        )
                        #Replace the invalid characters with a blank string (removal) or the $Replacement value
                        #Perform replacement based on whether spaces are desired or not
                        if ($RemoveSpace) {
                            [RegEx]::Replace($String, $rgxInvalidCharsWithSpace, $Replacement) | write-output ;
                        } else {
                            [RegEx]::Replace($String, $rgxInvalidCharsNoSpace, $Replacement) | write-output ;
                        }
                    } 
                    #*------^ END Function Remove-Chars ^------      
                    #*======^ END FUNCTIONS  ^======


                } ;  # BEG-E
                PROCESS {
                    foreach ($n in $Name) {
                        $sBnr3="`n#*~~~~~~v PROCESSING : $($n) v~~~~~~" ; 
                        write-verbose $sBnr3; 
                        #Check if the string matches a valid path
                        if ($n -match '(?<start>^[a-zA-z]:\\|^\\\\)(?<path>(?:[^\\]+\\)+)(?<file>[^\\]+)$') {
                            #Split the path into separate directories
                            $path = $Matches.path -split '\\'

                            #This will remove any empty elements after the split, eg. double slashes "\\"
                            $path = $path | Where-Object {$_}
                            #Add the filename to the array
                            $path += $Matches.file

                            #Send each part of the path, except the start, to the removal function
                            $cleanPaths = foreach ($p in $path) {
                                write-verbose "`$p: $($p)" ; 
                                $buffer = Remove-Chars -String $p -Replacement $Replacement -RemoveSpace:$($RemoveSpace) ;
                                if($ReplaceBrackets){
                                    $buffer = $buffer -replace "\[","(" -replace "\]",")" ; 
                                }; 
                                if($rgxdashReplaceChars){
                                    $buffer = $buffer -replace $rgxdashReplaceChars,$dashReplacement ; 
                                }; 
                                $buffer | write-output  ; 
                            }
                            #Remove any blank elements left after removal.
                            $cleanPaths = $cleanPaths | Where-Object {$_}
                            write-verbose "`$cleanPaths: $($cleanPaths)" ; 
            
                            #Combine the path together again
                            $Matches.start + ($cleanPaths -join '\') | write-output ; 
                        } else {
                            #String is not a path, so send immediately to the removal function
                            $buffer = Remove-Chars -String $N -Replacement $Replacement -RemoveSpace:$($RemoveSpace) | write-output ; 
                            if($ReplaceBrackets){
                                $buffer = $buffer -replace "\[","(" -replace "\]",")" ; 
                            }; 
                            if($rgxdashReplaceChars){
                                $buffer = $buffer -replace $rgxdashReplaceChars,$dashReplacement ; 
                            }; 
                            $buffer | write-output ; 
                        } ; 
                        write-verbose $sBnr3.replace('~v','~^').replace('v~','^~')
                    } ;  # loop-E
                } ;  # PROC-E
            } ; 
        } ; 
        #*------^ END Function Remove-InvalidFileNameCharsTDO ^------

        #*======^ END FUNCTIONS ^======

        $Retries = 4 ;
        $RetrySleep = 5 ;
        $rgxInputExts = "(?i:^\.(MPEG|MP3|AVI|ASF|WMV|WMA|MP4|MOV|3GP|OGG|OGM|MKV|WEBM|WAV|DTS|AAC|AC3|A52|FLAC|FLV|MXF|MIDI|SMF)$)" ;
        $rgxYTFormatExts = "(?i:^\.(MOV|MPG|MP4|AVI|WMV|FLV|WEBM|MKV|MPEG)$)" ; 
        $outputExtension = ".mp3" ;
        $audio_codec = "mp3" ;
        #"mpga"
        $channels = 2 ;
        $mux = "dummy" ; # for mp3 audio-only extracts, use the dummy mux
        #"mpeg1"
        $iProcd = 0 ;
        $continue = $true ;
        $progs = @($env:ProgramFiles,${env:ProgramFiles(x86)}) ; 
        foreach($prog in $progs){
            switch ($encoder) {
                "VLC" { $processName = join-path -path $prog -childpath "\VideoLAN\VLC\vlc.exe"  }
                "FFMPEG" { $processName = "C:\apps\ffmpeg\bin\ffmpeg.exe" }
            } ;
            if (test-path -path $processName) {
                write-verbose "matched:$($processname)" ; 
                break ; 
            } 
        } ; 
        if (-not (test-path -path $processName)) { throw "MISSING/INVALID $($encoder) install path!:$($processName)" } ;
        write-host -foregroundcolor green "$((get-date).ToString("HH:mm:ss")):=== v PROCESSING STARTED v ===" ;
    }  # BEG-E ;
    PROCESS {

        $ttl = ($InputObject | measure).count ;
        $iProcd = 0 ; $swp = [System.Diagnostics.Stopwatch]::StartNew() ;

        # foreach, to accommodate arrays passed in
        foreach ($inputFile in $InputObject) {

            $continue = $true ;
            TRY {

                if ($inputfile.GetType().fullname -ne "System.IO.DirectoryInfo") {
                    switch ($inputfile.GetType().fullname) {
                        "System.IO.FileInfo" {
                            if ($tf = Get-childitem -path $inputFile.fullname -ea 0) {}
                            elseif($tf = Get-childitem -literalpath $inputFile.fullname -ea Stop){
                                write-verbose "failed get-childitem -path; hit on -literalpath: likely squarebracket in name/path" ; 
                            } else {
                                write-host -ForegroundColor red "Unable to read infile: $($inputFile.fullname)" ;
                                throw "MISSING/INVALID inputfile:$($inputFile.fullname)"
                            } ;
                        } ;
                        "System.String" {
                            # 12:02 PM 4/1/2017 if it's a string, it's not going to have a fullname prop - it's a full path string
                            if ($tf = Get-childitem -path $inputFile -ea 0 ) {}
                            elseif($tf = Get-childitem -literalpath $inputFile -ea Stop){
                                write-verbose "failed get-childitem -path; hit on -literalpath: likely squarebracket in name/path" ; 
                            } else {
                                write-host -ForegroundColor red "Unable to read infile: $($inputFile.fullname)" ;
                            } ;   
                        };
                        default {
                            write-host -ForegroundColor red "Unable to read infile: $($inputFile.fullname)" ;
                            "inputfile.GetType().fullname:$($inputfile.GetType().fullname)" ;
                            throw "UNRECOGNIZED TYPE OBJECT inputfile:$($inputFile.fullname). ABORTING!" ;
                        } ;
                    } ;
                } else {
                    # code leak to throw out directories
                    # System.IO.DirectoryInfo
                    write-host "(Skipping $($inputfile) -- Directory)" ;
                    Continue ;
                } ;

                $sBnrS="`n#*------v PROCESSING : $($tf.fullname)v------" ; 
                write-verbose $sBnrS ;

                if ($tf.extension -notmatch $rgxInputExts ) { throw "UNSUPPORTED INPUTFILE TYPE:$($inpuptFile)" }  ;

                # 12:01 AM 7/16/2023 apostrophe's in fullname crash rediscovery post conv, test
                #if($inputFile.FullName.contains("'")){
                # actually it's when there's a ' in the path, more than the file name. File name is acommodated, but renaming breaks with it in the path.
                if($inputfile.DirectoryName.contains("'")){
                    throw "INPUTFILE TYPE FULLNAME CONTAINS APOSTROPHE(')!:`n$($inputfile.FULLNAME)`nSKIPPING!"
                } ;

                <# 7:20 PM 11/6/2016 windows docs:https://wiki.videolan.org/Transcode/
                Note: due to command line parsing, at times, especially within single and double quote blocks, a backslash may have to be
                escaped by using a double backslash so that a filename would be D:\\path\\to\\file.mpg)
                Dbling \'s in all path objects used in params going into vlc.exe args and see if it fixes the issues transcodeing:
                C:\vidtmp\OST\Steps of the Rover\Gun Thing (The Proposition) - Nick Cave, Warren Ellis-(UL20111001-MieT8cNeXJA).mp3
                ... which comes out as an mp3 with no extension.
                #>
                if($fixFileNames){
                    $pltRIFNC=[ordered]@{
                        ReplaceBrackets = $true ;
                        Name = $tf.BaseName ;
                        Verbose = $($PSBoundParameters['Verbose'] -eq $true)
                    } ;
                    #write-verbose "(Purge no value keys from splat)" ; 
                    $mts = $pltRIFNC.GetEnumerator() |?{$_.value -eq $null} ; $mts |%{$pltRIFNC.remove($_.Name)} ; rv mts -ea 0 ; 
                    $smsg = "Remove-InvalidFileNameCharsTDO w`n$(($pltRIFNC|out-string).trim())" ; 
                    write-verbose $smsg  ;                      
                    #$fixedFileName = Remove-InvalidFileNameCharsTDO -ReplaceBrackets -Name $tf.BaseName -Verbose:$($PSBoundParameters['Verbose'] -eq $true)
                    $fixedFileName = Remove-InvalidFileNameCharsTDO  @pltRIFNC ; 
                    $outputFileName = (join-path -path $tf.Directory -ChildPath "$($fixedFileName)$($outputExtension)") ;
                } else { 
                    $outputFileName = (join-path -path $tf.Directory -ChildPath "$($tf.BaseName)$($outputExtension)") ;
                    #$outputFileName=$outputFileName.replace("\","\\") ;
                } ; 
                $outputFileName = (join-path -path $tf.Directory -ChildPath "$($tf.BaseName)$($outputExtension)") ;
                #$outputFileName=$outputFileName.replace("\","\\") ;

                # since there's clearly an export bug in VLC, lets use a generic no-spaces file :
                # Generate a unique filename with a specific extension (non-tmp, leverages the GUID-generating call):
                #$tempout = (join-path -path $tf.Directory -ChildPath "$([guid]::NewGuid().tostring())$($outputExtension)").replace("\", "\\")  ;
                # try it out of $env:temp C:\Users\tsk\AppData\Local\Temp
                $tempout = (join-path -path $env:temp -ChildPath "$([guid]::NewGuid().tostring())$($outputExtension)").replace("\", "\\")  ;
                $inputFileName = $tf.FullName.replace("\", "\\") ;

                write-verbose "`$outputFileName:$outputFileName`n`$tempout:$($tempout)"  ;

                switch ($encoder) {
                    "VLC" {
                        #  12:11 PM 11/6/2016 build args where we can see whats going on
                        # 1st spec dummy/non-GUI pass, and input filename  $($inputFileName)
                        $processArgs = "-I dummy -v `"$($inputFileName)`"" ;
                        if ($whatif) {
                            write-host -foregroundcolor green "-whatif detected, test-transcoding only the first 30secs" ;
                            $processArgs += " --stop-time=30" ;
                        } ;
                        # build output transcode settings
                        $processArgs += " :sout=#transcode{" ;
                        $processArgs += "vcodec=none,acodec=$($audio_codec),ab=$($bitrate),channels=$($channels),samplerate=$($samplerate)" ;
                        $processArgs += "acodec=$($audio_codec),ab=$($bitrate),channels=$($channels),samplerate=$($samplerate)" ;
                        # end output transcode settings
                        $processArgs += "}" ;
                        # add the output file specs & mux
                        $processArgs += ":standard{access=`"file`",mux=$($mux),dst=`"$($tempout)`"}"
                        # tell it to exit on completion
                        $processArgs += " vlc://quit" ;
                    }
                    "FFMPEG" {
                        <# C:\apps\ffmpeg\bin\ffmpeg.exe
                        The basic command is:
                        ffmpeg -i filename.mp4 filename.mp3
                        or
                        ffmpeg -i video.mp4 -b:a 192K -vn music.mp3

                        use -q:a for variable bit rate.
                        ffmpeg -i k.mp4 -q:a 0 -map a k.mp3
                        The q option can only be used with libmp3lame and corresponds to the LAME -V option. See:

                        leaving out -vn just copies the audio stream
                        to convert whole directory (including filenames with spaces) with the above command:
                        for i in *.mp4; do ffmpeg -i "$i" -q:a 0 -map a "$(basename "${i/.mp4}").mp3"; done;
                        http://donnieknows.com/blog/mp4-video-mp3-file-using-ffmpeg-ubuntu-910-karmic-koala
                        Encoding VBR (Variable Bit Rate) mp3 audio - https://trac.ffmpeg.org/wiki/Encode/MP3
                        FFmpeg, encode mp3 - http://svnpenn.github.io/2012/08/ffmpeg-encode-mp3

                        To encode a high quality MP3 from an AVI best using -q:a for variable bit rate.
                        ffmpeg -i sample.avi -q:a 0 -map a sample.mp3
                        If you want to extract a portion of audio from a video use the -ss option to specify the starting timestamp, and the -t option to specify the encoding duration, eg from 3 minutes and 5 seconds in for 45 seconds
                        ffmpeg -i sample.avi -ss 00:03:05 -t 00:00:45.0 -q:a 0 -map a sample.mp3
                            The timestamps need to be in HH:MM:SS.xxx format or in seconds.
                            If you don't specify the -t option it will go to the end.
                        ffmpeg -formats
                        or
                        ffmpeg -codecs
                        would give sufficient information so that you know more

                        128 kbps audio (assuming the original video file had good audio!) sampled at the 44,100 sample/second rate used on a CD:
                        ffmpeg -i moviefile.mpeg -ab 128000 -ar 44100 -f mp3 audiofile.mp3
                        #>
                        $processArgs = "-i `"$($inputFileName)`"" ;
                        # $bitrate=320
                        $processArgs += " -ab $($bitrate * 1000)" ;
                        # $samplerate=44100
                        $processArgs += " -ar $($samplerate)" ;
                        $processArgs += " -f mp3" ;
                        $processArgs += " `"$($tempout)`"" ;
                    }
                } ;

                write-verbose "`$processName:$($processName | out-string)" ;
                write-verbose "`$processArgs:$($processArgs | out-string)" ;
                # optional debug: pipe it into the clipboard for cmdline testing
                #"`"$($processName)`" $($processArgs)" | Out-Clipboard ;
                #write-verbose -verbose:$true  "current cmdline piped to Clipboard!" ;
                # launch command
                # capture and echo back errors from .exe
                $soutf = [System.IO.Path]::GetTempFileName() ;
                $serrf = [System.IO.Path]::GetTempFileName()  ;

            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                CONTINUE ; 
            } ; 
                # 7:29 PM 11/15/2023 add retries, sometimes it comes back working                

            $Exit = 0 ;
            Do {
                TRY {
                    write-host -foregroundcolor yellow "Cmd:$($processName) $($processArgs)" ;
                    $process = Start-Process -FilePath $processName -ArgumentList $processArgs -NoNewWindow -PassThru -Wait -RedirectStandardOutput $soutf -RedirectStandardError $serrf -Verbose:$($VerbosePreference -eq "Continue") ; 

                    switch ($process.ExitCode) {
                        0 {
                            write-host -foregroundcolor green "ExitCode 0 returned (No Errors, File converted)"
                            # ren $tempout => $outputFileName
                            $bfound = $useLiteralPath = $false ; 
                            if ($rf = get-childitem -path $tempout ) {
                                if($rf.Length -eq 0){
                                    write-verbose "removing empty `$tempout file" ; 
                                    remove-item -path $rf.fullname -verbose -force ; 
                                    throw "EMPTY output file found: $($tempout)" ;
                                } else {
                                    write-verbose "copy back temp loc copy to final loc..."
                                    move-item -path $tempout -Destination $tf.Directory -verbose:$true -ea STOP ;
                                    write-verbose "reset `$rf to updated location" ; 
                                    $rf = get-childitem -path (join-path -path $tf.Directory -ChildPath (split-path $tempout -Leaf)) -ea STOP
                                } ; 
                                $bfound = $true ; 
                            }elseif($rf = get-childitem -literalpath $tempout ) {
                                write-verbose "gci -literalpath reqd to find returnfile - likely spec chars in path" ; 
                                $bfound = $true ; 
                                $useLiteralPath = $true ;
                            }else {
                                throw "No matching temporary output file found: $($tmpout)" ;
                            } ;
                            if($bfound){
                                # renames fail if there's an existing fn clash -> ren the clash, -ea 0 to suppress notfound errors
                                #if ($cf = get-childitem -path ($outputFileName | split-path -Leaf) -ea 0 ) {
                                if($useLiteralPath){
                                    write-verbose "using -literalpath to check for conflict file on rename target" ; 
                                    $cf = get-childitem -ea 0 -literalpath (join-path -Path (split-path $rf.fullname) -ChildPath ($outputFileName | split-path -Leaf))
                                } else { 
                                    $cf = get-childitem -ea 0 -path (join-path -Path (split-path $rf.fullname) -ChildPath ($outputFileName | split-path -Leaf))
                                } ;
                                if($cf){
                                    $nname = "$($cf.BaseName)-$((get-date).tostring('yyyyMMdd-HHmmtt'))$($cf.Extension)" ; 
                                    $smsg = "existing conflict found, using variant name:" ; 
                                    $smsg = "`nrenaming $($rf.fullname)`nto:$($nname)" ; 
                                    write-verbose $smsg ; 
                                    if($useLiteralPath){
                                        # still may fail on square-brackets, but move-item supports as well, with better tolerance
                                        TRY{
                                            Rename-Item -literalpath $rf.fullname -NewName $nname -ea STOP  -Verbose:$($VerbosePreference -eq "Continue") ; 
                                        }CATCH{
                                            TRY{
                                                write-warning  "FAILED:Rename-Item, retrying move-item..." ;  
                                                move-item -LiteralPath $rf.fullname -Destination (join-path -path $cf.DirectoryName -childpath $nname) -ea STOP  -Verbose:$($VerbosePreference -eq "Continue") ;
                                            }CATCH{
                                                write-warning  "FAILED:move-item, retrying [System.IO.File]::Move()..." ;  
                                                [System.IO.File]::Move( $rf.fullname , (join-path -path $cf.DirectoryName -childpath $nname)) ;
                                            } ;
                                        } ;
                                    } else { 
                                        Rename-Item -path $rf.fullname -NewName $nname -ea STOP -Verbose:$($VerbosePreference -eq "Continue");
                                    } ; 
                                } else {
                                    $nname = $($outputFileName | split-path -Leaf) ; 
                                    write-verbose "renaming $($rf.fullname)`nto:$($nname)" ; 
                                    if($useLiteralPath){
                                        TRY{
                                            Rename-Item -literalpath $rf.fullname -NewName $nname -ea STOP -Verbose:$($VerbosePreference -eq "Continue") ; 
                                        }catch{
                                            TRY{
                                                write-warning  "FAILED:Rename-Item, retrying move-item..." ;
                                                move-Item -literalpath $rf.fullname -Destination (join-path -path $cf.DirectoryName -childpath $nname) -ea STOP  -Verbose:$($VerbosePreference -eq "Continue") ; 
                                            }CATCH{
                                                write-warning  "FAILED:move-item, retrying [System.IO.File]::Move()..." ;
                                                [System.IO.File]::Move($rf.fullname ,(join-path -path $cf.DirectoryName -childpath $nname)) ;  
                                            }
                                        }
                                    } else { 
                                        Rename-Item -path $rf.fullname -NewName $nname -ea STOP -Verbose:$($VerbosePreference -eq "Continue") ;
                                    } ; 
                                };
                            } ; 
                        } ;
                        1 { "ExitCode 1 returned (fatal error)" } ;
                        default { 
                            write-host "ERROR during VLC Transcoding: Non-0/1 ExitCode returned $($process.ExitCode)" ; write-host "`a" ; 
                        } ;
                    } ;

                    $Exit = $Retries ;
                } CATCH {
                    $ErrorTrapped=$Error[0] ;
                    Write-Verbose "Failed to exec cmd because: $($ErrorTrapped)" ;
                    Start-Sleep -Seconds $RetrySleep ;
                    # reconnect-exo/reconnect-ex2010
                    $Exit ++ ;
                    Write-Verbose "Try #: $Exit" ;
                    If ($Exit -eq $Retries) {Write-Warning "Unable to exec cmd!"} ;
                }  ;
            } Until ($Exit -eq $Retries) ; 

                write-verbose "(checking for -RedirectStandardOutput -RedirectStandardError files from conversion...)" ; 
                if ((get-childitem $soutf).length) {
                    if ($VerbosePreference -eq "Continue") { (get-content $soutf) | out-string ; } ;
                    remove-item $soutf  -Verbose:$($VerbosePreference -eq "Continue");
                } ;
                if ((get-childitem $serrf).length) {
                    if ($VerbosePreference -eq "Continue") { (get-content $serrf) | out-string ; } ;
                    remove-item $serrf ;
                } ;

                $iProcd++ ;
                [int]$pct = ($iProcd / $ttl) * 100 ;

                <# SAMPLE TRANSCODE SETTINGS
                -I dummy      Disables the graphical interface
                vlc://quit     Quit VLC after transcoding

                # wav to mp3
                #$processArgs = "-I dummy -vvv `"$($inputFileName)`" --sout=#transcode{acodec=`"mp3`",ab=`"$bitrate`",`"channels=$channels`"}:standard{access=`"file`",mux=`"wav`",dst=`"$outputFileName`"} vlc://quit" ;
                # mp4 to mp3
                #$processArgs = "-I dummy -vvv `"$($inputFileName)`" --sout=#transcode{acodec=`"$audio_codec`",ab=`"$bitrate`",`"channels=$channels`",`"samplerate=$samplerate`"}:standard{access=`"file`",mux=`"$mux`",dst=`"$outputFileName`"} vlc://quit" ;

                # dvd to mp3
                # --qt-start-minimized dvd:///E:\@!Title!:%%C :sout=#transcode{vcodec=none,acodec=mp3,ab=320,channels=2,samplerate=44100}:standard{access="file",mux=dummy,dst="!CD!\!TargetFolder!\!FileNumber!.mp3"} vlc://quit

                # flv to mp3
                # -I dummy -v %1 :sout=#transcode{vcodec=none,acodec=mp3,ab=128,channels=2,samplerate=44100}:standard{access="file",mux=dummy,dst="%_commanm%.mp3"} vlc://quit

                # MOV_to_MPG
                -I dummy -vvv %1
                --sout=#transcode{vcodec=h264,vb=10000,deinterlace=1,acodec=mp3,ab=128,channels=2,samplerate=44100}:standard{access=file,mux=ts,dst=%_new_path%} vlc://quit
                --stop-time=30 to only encode the first 30 seconds (quick test)

                # generic syntax:
                -I dummy -vvv %%a --sout=#transcode{vcodec=VIDEO_CODEC,vb=VIDEO_BITRATE,scale=1,acodec=AUDIO_CODEC,ab=AUDIO_BITRATE,channels=6}:standard{access=file,mux=MUXER,dst=%%a.OUTPUT_EXT} vlc://quit

                # audio-only options:
                --no-sout-video     VLC will not pass on a video component to the streaming output
                --sout-audio     VLC will, however, pass on an audio component to the streaming output

                # Extracting audio in original format
                --no-sout-video dvdsimple:///dev/scd0@1:1 :sout='#std{access=file,mux=raw,dst=./file.ac3}'
                # Extracting audio in FLAC format
                -I dummy --no-sout-video --sout-audio
                --no-sout-rtp-sap --no-sout-standard-sap --ttl=1 --sout-keep
                --sout "#transcode{acodec=flac}:std{mux=raw,dst=C:\User\Admin\Desktop\yourAudio.flac}"
                Video.TS:///C:\User\Admin\Desktop\yourVideo.mp4\#0:01-3:38 vlc://quit
                # Extracting audio in WAV format
                -I dummy --no-sout-video --sout-audio
                --no-sout-rtp-sap --no-sout-standard-sap --ttl=1 --sout-keep
                --sout "#transcode{acodec=s16l,channels=2}:std{access=file,mux=wav,dst=C:\User\Admin\Desktop\yourAudio.wav}"
                Video.TS:///C:\User\Admin\Desktop\yourVideo.mp4\#0:01-3:38 vlc://quit
                # acodec=s16l tells VLC to use convert the audio content using the s16l codec, which is the codec for WAV format audio
                # mux=wav tells VLC to write the s16l audio data into a file with the WAV structure.

                # changes an asf file to an MPEG-2 file
                vlc "C:\Movies\Your File.asf" :sout='#transcode{vcodec=mp2v,vb=4096,acodec=mp2a,ab=192,scale=1,channels=2,deinterlace,audio-sync}:std{access=file, mux=ps,dst="C:\Movies\Your File Output.ps.mpg"}'

                # m4a files to mp3 files (512kb/s encoding with 44100 sampling frequency
                -I dummy -vvv %1
                --sout=#transcode{acodec="mpga",ab="512","channels=2",samplerate="44100"}:standard{access="file",mux="mpeg1",dst="%_commanm%.mp3"} vlc://quit

                # transcode wav to mp3
                -I dummy -vvv `"$($inputFileName)`"
                --sout=#transcode{acodec=`"mp3`",ab=`"$bitrate`",`"channels=$channels`"}:standard{access=`"file`",mux=`"wav`",dst=`"$outputFileName`"} vlc://quit
                #>

            write-verbose $sBnrS.replace('-v','-^').replace('v-','^-') ;

        } #  # loop-E ;
    } # PROC-E ;

    END {
        write-host -foregroundcolor green "$((get-date).ToString("HH:mm:ss")):$($iProcd) conversions processed" ;
        write-host -foregroundcolor green "$((get-date).ToString("HH:mm:ss")):=== ^ PROCESSING COMPLETE ^ ===" ;

    } # END-E
}

#*------^ convert-VideoToMp3.ps1 ^------