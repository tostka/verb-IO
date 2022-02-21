#*----------------v Function convert-VideoToMp3 v------
function convert-VideoToMp3 {
    <#
    .SYNOPSIS
    convert-VideoToMp3() - convert passed video files to mp3 files in same directory
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
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
    #>
    [CmdletBinding()]
    [Aliases('convert-ToMp3','convert-VideoToMp3')]
    PARAM (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, Mandatory = $True, HelpMessage = "File(s) to be transcoded")]
        $InputObject
        , [parameter(HelpMessage = "Bitrate for transcoded output (defaults to 320k)")]
        [int]$bitrate = 320
        , [parameter(HelpMessage = "Samplerate for transcoded output (defaults to 44100)")]
        [int]$samplerate = 44100
        , [Parameter(Mandatory = $false, HelpMessage = "Specify Site to analyze [-SiteName (USEA|GBMK|AUSYD]")]
        [ValidateSet("F", "VLC")]
        [string]$encoder = "VLC"
        , [Parameter(HelpMessage = 'ShowProgress [$switch]')]
        [switch] $showProgress
        , [Parameter(HelpMessage = 'Debugging Flag [$switch]')]
        [switch] $showDebug
        , [Parameter(HelpMessage = 'Whatif Flag  [$switch]')]
        [switch] $whatIf
    ) ; # PARAM-E

    <# input formats supported by VLC
        MPEG (ES,PS,TS,PVA,MP3), AVI, ASF |WMV |WMA, MP4 |MOV |3GP, OGG |OGM |Annodex, Matroska (MKV), Real, WAV (including DTS), Raw Audio: DTS, AAC, AC3/A52, Raw DV, FLAC, FLV (Flash), MXF, Nut, Standard MIDI |SMF, Creative™ Voice.
    #>

    BEGIN {
        $rgxInputExts = "(?i:^\.(MPEG|MP3|AVI|ASF|WMV|WMA|MP4|MOV|3GP|OGG|OGM|MKV|WEBM|WAV|DTS|AAC|AC3|A52|FLAC|FLV|MXF|MIDI|SMF)$)" ;
        $outputExtension = ".mp3" ;
        $audio_codec = "mp3" ;
        #"mpga"
        $channels = 2 ;
        $mux = "dummy" ; # for mp3 audio-only extracts, use the dummy mux
        #"mpeg1"
        $progInterval = 500 ; # write-progress interval in ms
        $iProcd = 0 ;
        $continue = $true ;
        $programFiles = ${env:ProgramFiles(x86)};
        if ($programFiles -eq $null) { $programFiles = $env:ProgramFiles; } ;
        switch ($encoder) {
            "VLC" { $processName = $programFiles + "\VideoLAN\VLC\vlc.exe" ; }
            "FFMPEG" { $processName = "C:\apps\ffmpeg\bin\ffmpeg.exe" }
        } ;
        if (!(test-path -path $processName)) { throw "MISSING/INVALID $($encoder) install path!:$($processName)" } ;
        write-verbose -verbose:$true  "$((get-date).ToString("HH:mm:ss")):=== v PROCESSING STARTED v ===" ;
        $progParam = @{
            CurrentOperation = "Beginning";
            Status           = "Preparing Processing...";
            PercentComplete  = 0;
        } ;
    }  # BEG-E ;

    PROCESS {

        $ttl = ($InputObject | measure).count ;
        $iProcd = 0 ; $swp = [System.Diagnostics.Stopwatch]::StartNew() ;

        # foreach, to accommodate arrays passed in
        foreach ($inputFile in $InputObject) {

            $continue = $true ;
            try {

                if ($inputfile.GetType().fullname -ne "System.IO.DirectoryInfo") {
                    switch ($inputfile.GetType().fullname) {
                        "System.IO.FileInfo" {
                            if ($tf = Get-childitem -path $inputFile.fullname -ea Stop) {
                            }
                            else {
                                write-host -ForegroundColor red "Unable to read infile: $($inputFile.fullname)" ;
                                throw "MISSING/INVALID inputfile:$($inputFile.fullname)"
                            } ;
                        } ;
                        "System.String" {
                            # 12:02 PM 4/1/2017 if it's a string, it's not going to have a fullname prop - it's a full path string
                            if ($tf = Get-childitem -path $inputFile) {

                            }
                            else {
                                write-host -ForegroundColor red "Unable to read infile: $($inputFile.fullname)" ;
                                throw "MISSING/INVALID inputfile:$($inputFile.fullname)"
                            } ;
                        };
                        default {
                            write-host -ForegroundColor red "Unable to read infile: $($inputFile.fullname)" ;
                            "inputfile.GetType().fullname:$($inputfile.GetType().fullname)" ;
                            throw "UNRECOGNIZED TYPE OBJECT inputfile:$($inputFile.fullname). ABORTING!" ;
                        } ;
                    } ;

                    if ($tf.extension -notmatch $rgxInputExts ) { throw "UNSUPPORTED INPUTFILE TYPE:$($inpuptFile)" }  ;

                    <# 7:20 PM 11/6/2016 windows docs:https://wiki.videolan.org/Transcode/
                    Note: due to command line parsing, at times, especially within single and double quote blocks, a backslash may have to be
                    escaped by using a double backslash so that a filename would be D:\\path\\to\\file.mpg)
                    Dbling \'s in all path objects used in params going into vlc.exe args and see if it fixes the issues transcodeing:
                    C:\vidtmp\OST\Steps of the Rover\Gun Thing (The Proposition) - Nick Cave, Warren Ellis-(UL20111001-MieT8cNeXJA).mp3
                    ... which comes out as an mp3 with no extension.
                    #>
                    $outputFileName = (join-path -path $tf.Directory -ChildPath "$($tf.BaseName)$($outputExtension)") ;
                    #$outputFileName=$outputFileName.replace("\","\\") ;
                    # since there's clearly an export bug in VLC, lets use a generic no-spaces file :
                    # Generate a unique filename with a specific extension (non-tmp, leverages the GUID-generating call):
                    $tempout = (join-path -path $tf.Directory -ChildPath "$([guid]::NewGuid().tostring())$($outputExtension)").replace("\", "\\")  ;
                    $inputFileName = $tf.FullName.replace("\", "\\") ;

                    if ($showDebug) { write-verbose -verbose:$true  "`$outputFileName:$outputFileName`n`$tempout:$($tempout)" } ;

                    switch ($encoder) {
                        "VLC" {
                            #  12:11 PM 11/6/2016 build args where we can see whats going on
                            # 1st spec dummy/non-GUI pass, and input filename  $($inputFileName)
                            $processArgs = "-I dummy -v `"$($inputFileName)`"" ;
                            if ($whatif) {
                                write-verbose -verbose:$true  "-whatif detected, test-transcoding only the first 30secs" ;
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

                    if ($showDebug) {
                        write-verbose -verbose:$true  "`$processName:$($processName | out-string)" ;
                        write-verbose -verbose:$true  "`$processArgs:$($processArgs | out-string)" ;
                        # optional debug: pipe it into the clipboard for cmdline testing
                        #"`"$($processName)`" $($processArgs)" | Out-Clipboard ;
                        #write-verbose -verbose:$true  "current cmdline piped to Clipboard!" ;
                    } ;
                    # launch command
                    # capture and echo back errors from robocopy.exe
                    $soutf = [System.IO.Path]::GetTempFileName() ;
                    $serrf = [System.IO.Path]::GetTempFileName()  ;
                    "Cmd:$($processName) $($processArgs)" ;
                    $process = Start-Process -FilePath $processName -ArgumentList $processArgs -NoNewWindow -PassThru -Wait -RedirectStandardOutput $soutf -RedirectStandardError $serrf ;

                    switch ($process.ExitCode) {
                        0 {
                            "ExitCode 0 returned (No Errors, File converted)"
                            # ren $tempout => $outputFileName
                            if ($rf = get-childitem -path $tempout ) {
                                # renames fail if there's an existing fn clash -> ren the clash, -ea 0 to suppress notfound errors
                                if ($cf = get-childitem -path ($outputFileName | split-path -Leaf) -ea 0 ) {
                                    Rename-Item -path $rf.fullname -NewName "$($cf.BaseName)-$((get-date).tostring('yyyyMMdd-HHmmtt'))$($cf.Extension)" ;
                                }
                                else {
                                    Rename-Item -path $rf.fullname -NewName $($outputFileName | split-path -Leaf)
                                };
                            }
                            else {
                                throw "No matching temporary output file found: $($tmpout)" ;
                            } ;
                        } ;
                        1 { "ExitCode 1 returned (fatal error)" } ;
                        default { write-host "ERROR during VLC Transcoding: Non-0/1 ExitCode returned $($process.ExitCode)" ; write-host "`a" ; } ;
                    } ;

                    if ((get-childitem $soutf).length) {
                        if ($ShowDebug) { (gc $soutf) | out-string ; } ;
                        remove-item $soutf ;
                    } ;
                    if ((get-childitem $serrf).length) {
                        if ($ShowDebug) { (gc $serrf) | out-string ; } ;
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

                }
                else {
                    # code leak to throw out directories
                    # System.IO.DirectoryInfo
                    "(Skipping $($inputfile) -- Directory)" ;
                } ;

            }
            catch {
                # BOILERPLATE ERROR-TRAP
                Write "$((get-date).ToString("HH:mm:ss") ): -- SCRIPT PROCESSING CANCELLED" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Error in $($_.InvocationInfo.ScriptName)." ;
                Write "$((get-date).ToString("HH:mm:ss") ): -- Error information" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Line Number: $($_.InvocationInfo.ScriptLineNumber)" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Offset: $($_.InvocationInfo.OffsetInLine)" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Command: $($_.InvocationInfo.MyCommand)" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Line: $($_.InvocationInfo.Line)" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Error Details: $($_)" ;
                Continue ;
                # Exit; here if you want processing to die and not continue on next for-pass
            } # try/cat-E ;

        } #  # loop-E ;
    } # PROC-E ;

    END {
        write-verbose -verbose:$true  "$((get-date).ToString("HH:mm:ss")):$($iProcd) conversions processed" ;
        write-verbose -verbose:$true  "$((get-date).ToString("HH:mm:ss")):=== ^ PROCESSING COMPLETE ^ ===" ;

    } # END-E
} #*----------------^ END Function convert-VideoToMp3 ^--------