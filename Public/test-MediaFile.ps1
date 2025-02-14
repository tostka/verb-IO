#*------v test-MediaFile.ps1 v------
Function test-MediaFile {
    <#
    .SYNOPSIS
    test-MediaFile.ps1 - First pulls media descriptive metadata (from MediaInfo.dll via get-MediaInfoRAW()) out of a media file, then compares key A/V metrics against (my arbitrary) thresholds for suitability,and finally outputs a summary report of the metrics. 
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : test-MediaFile.ps1
    License     : MIT License
    Copyright   : (c) 2024 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Media,Metadata,Video,Audio,Subtitles
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    REVISIONS
    * 8:10 PM 2/13/2025 retooled borked CBH, now properly outputs via get-help
    * 8:43 AM 3/9/2022 fixed consecutive $smsg's wo += to trigger string addition.
        * 10:25 AM 2/21/2022 updated CBH, added an example sample output. Not sure if worked before, but CBH currently doesn't seem to get-hepl correctly. Needs debugging, but can't determine issue source.
        * 8:08 PM 12/11/2021 added simpler pipeline example 
        * 11:12 AM 11/27/2021 fixed echo typo in the test block, added detailed echo on fail attrib/test details
        * 8:15 PM 11/19/2021 added tmr alias
        * 7:37 PM 11/12/2021 added example for doing a full dir of files ; flip $path param test-path to use -literalpath - too many square brackets in sources
        * 6:05 PM 11/6/2021 swap $finalfile -> "$($entry)" ; fixed missing use of pltGIMR (wasn't doing xml export)
        * 8:44 PM 11/2/2021 flip gci -path => -literalpath, avoid [] wildcard issues
        * 7:47 PM 10/26/2021 added -ExportToFile defaulted to true
        * 12:53 PM 10/20/2021 init vers - ported over to verb-io from my fix-htpcfiles.ps1
    .DESCRIPTION
    test-MediaFile.ps1 - First pulls media descriptive metadata (from MediaInfo.dll via get-MediaInfoRAW()) out of a media file, then compares key A/V metrics against (my arbitrary) thresholds for suitability,and finally outputs a summary report of the metrics. 

    This is a wrapper function for my Get-MediaINfoRaw() cmdlet, which is part of my [Get-MediaInfo](https://github.com/tostka/Get-MediaInfo)
        module, which is forked from Frank Skare/stax76's Get-MediaInfoSummary() function (part of his [get-MediaInfo module](https://github.com/stax76/Get-MediaInfo)).
        which in turn leverages the [MediaInfo.dll](https://mediaarea.net/en/MediaInfo/Support/SDK/ReadFirst),
        development component made available by the open source [MediaInfo](https://mediaarea.net/en/MediaInfo) project 
        (which has a nifty free-standing .exe gui version as their core tool). 
        
        1) This wrapper function calls Get-MediaInfoRaw(), to retrieve desciptive media metadata on the file specified by the -Path param.
        
        2) It then and processes the returned media metadata, checking the following thresholds:
        
        - Has all of the following General stream properties populated:
            CompleteNamem, OverallBitRate_String and OverallBitRate_kbps 
            (last 2 are my Get-MediaInfoRaw() decimal-parsed variants of the xxx_String properties).
        
        - Has a 'mb-Per-Minute' ratio of _2_ or better (specified via the -Threshmbpm parameter).  
            I calulate 'mb-Per-Minute' as: General stream 'FileSize_MB' / General stream 'Duration_Mins' 
            (both are my numeric parses of the underlying xxx_String properties)

            Goal of this metric is flagging 'bogus' files, that don't have 
            enough "size to metadata minutes" to reflect a typical "legit" video file.    
            
        - Has a minimum vertical resolution of at least 480 pixels (specified via the -ThresholdMinVerticalRes parameter), 
            as reported in the Video stream Height_String property.
      
        - Has all of the following Video stream properties populated:
            Format_String, CodecID, Duration_Mins, BitRate_kbps, FrameRate_fps 
            (the trailing three are numeric parses of the matching _String properties). 
        
        - Has all of the following Audio stream properties populated:
          Format_String, CodecID, SamplingRate_bit
          (last is my numeric parse of SamplingRate_String).

        3) It then outputs a summary report to console.

    .PARAMETER Path
    Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]
    .PARAMETER ThresholdMbPerMin
    [float] Cutoff threshold for ratio of 'file size in mb'/'minutes duration' (defaults 2).[-ThresholdMbPerMin 1.5]
    .PARAMETER ThresholdMinVerticalRes
    [int] Cutoff threshold for minimum video lines of resolution (in pixels the underlying video stream 'Height_String').[-ThresholdMinVerticalRes 300]

    .INPUTS
    System.String.ARray Accepts piped media file path input
    .OUTPUTS
    None. Outputs summary to console. 
    .EXAMPLE
    PS> if(test-mediafile "C:\users\USER\Documents\Reflections Video.mp4"){
    PS>     write-host "Valid, meets specs"}else{write-warning "INVALID, DOES not meets specs" ;
    PS> }  ;

        (writing metadata to matching -media.XML file)
        09:42:35:-----
        FileName
        C:\users\USER\Documents\Reflections Video.mp4
        FileMB | Mins | OBitRate  | Format      | Ext
        70mb   | 9.3  | 1058 kbps | MPEG-4 kbps | .mp4
        V-Fmt | V-Kbps | V-WxH:Ratio    | V-fps | V-Std | V-Encoder
        AVC   | 881    | 1920x1080:16:9 | 30    |       |
        A-Chnls   | A-Lang | A-Fmt  | A-BitRate | A-kHz
        2 channel |        | AAC LC | 174 Kbps  | 48.0
        -----
        Valid, meets specs

    Example testing the validity of a video file, to output a descriptive output to console.
    .EXAMPLE
    PS> 'c:\pathto\video.mp4'| test-MediaFile ; 
    Example using pipeline support
    .EXAMPLE
    PS> gci "c:\PathTo\*" -include *.mkv | select -expand fullname | test-MediaFile ; 
    Bulk file pipeline example
    .EXAMPLE
    PS> gci "c:\pathto\*.mp4" | tmf ; 
    Another simpler pipeline example, leveraging the native tmf alias.
    .LINK
    https://hexus.net/tech/tech-explained/storage/1376-gigabytes-gibibytes-what-need-know/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('tmf')]
    PARAM(
            #[Parameter(Position=0,Mandatory=$True,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]
            [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]
            [ValidateScript({Test-Path -literalpath $_})]
            [string[]] $Path,
            [Parameter(HelpMessage="[float] Cutoff threshold for ratio of 'file size in mb'/'minutes duration' (defaults 2).[-ThresholdMbPerMin 1.5]")]
            [float]$ThresholdMbPerMin=2,
            [Parameter(HelpMessage="[int] Cutoff threshold for minimum video lines of resolution (in pixels the underlying video stream 'Height_String').[-ThresholdMinVerticalRes 300]")]
            [int]$ThresholdMinVerticalRes=480,
            [Parameter(HelpMessage="Suppress all outputs but return pass status as`$true/`$false, to the pipeline[-Silent]")]
            [switch] $Silent,
            [Parameter(HelpMessage="Switch to create a matching XML metadata export file (with -Path name/location and .xml ext).[-ExportToFile]")]
            [switch]$ExportMediaToFile=$true
        ) ;
        BEGIN{

        $propsGeneral1 = @{name="FileName";expression={$_.CompleteName}}
                        
        $propsGeneral2 = @{name="FileMB";expression={"$($_.FileSize_MB)mb"}},@{name="Mins";expression={[math]::round($_.Duration_Mins,1)}},
            @{name="OBitRate";expression={"$($_.OverallBitRate_kbps) kbps"}},@{name="Format";expression={"$($_.Format_String) kbps"}},@{name="Ext";expression={$pfile.extension}} ; 
        $propsAudio = @{name="A-Chnls";expression={$_.Channel_s__String.replace('annels','')}},@{name="A-Lang";expression={$_.Language_String}},
            @{name="A-Fmt";expression={$_.Format_String}},@{name="A-BitRate";expression={$_.BitRate_String}},
            @{name="A-kHz";expression={$_.SamplingRate_bit}}; 

        $propsVideo = @{name="V-Fmt";expression={$_.Format_String}},@{name="V-Kbps";expression={$_.BitRate_kbps}},
            @{name="V-WxH:Ratio";expression={"$($_.Width_Pixels)x$($_.Height_Pixels):$($_.DisplayAspectRatio_String)"}},
            @{name="V-fps";expression={[math]::round($_.FrameRate_fps,1)}},@{name="V-Std";expression={$_.Standard}},
            @{name="V-Encoder";Expression={(($_.Encoded_Library_String.ToString())).substring(0,[System.Math]::Min(10, $_.Encoded_Library_String.Length)).trim() + "..."}} ;

        
        $propsGeneralTest = 'CompleteName','OverallBitRate_String','OverallBitRate_kbps' ;
        $propsVidTest = 'Format_String','CodecID','Duration_Mins','BitRate_kbps','FrameRate_fps' ;
        $propsAudioTest = 'Format_String','CodecID','SamplingRate_bit' ; 

        $isLegit = $false ; 
        $isWarn = $false ; 
        
        }  # BEG-E
        PROCESS{
            foreach($entry in $Path){
                $entry = (Convert-Path -LiteralPath $entry) ;
                $pfile = get-childitem -literalpath $entry ; 
                # pull get-mediaInfo and validate it's legit    
                $pltGMIR=[ordered]@{
                    ExportToFile = $($ExportMediaToFile) ; 
                    verbose = $($VerbosePreference -eq "Continue")
                } ; 
                if(-not$Silent){
                    $smsg = "Get-MediaInfoRAW w`n$(($pltGMIR|out-string).trim())`n-Path: -$($entry)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                } ; 
                $mediaMeta = Get-MediaInfoRAW -Path "$($entry)" @pltGMIR ; 
                $finalfile = get-childitem -literalpath "$($entry)"; 
               
                $hasGeneralProps = [boolean]($mediaMeta.general.CompleteName -AND $mediaMeta.general.OverallBitRate_String -AND $mediaMeta.general.OverallBitRate_kbps) 
                $hasMbps = [boolean]([double]$mediaMeta.general.FileSize_MB/[double]$mediaMeta.general.Duration_Mins -gt $ThresholdMbPerMin) ; 
                $hasVRes = [boolean]([int]$mediaMeta.video.Height_Pixels -gt $ThreshVRes)
                $hasVidProps = [boolean](($mediameta.video.Format_String -AND $mediameta.video.CodecID -AND $mediameta.video.Duration_Mins -AND $mediameta.video.BitRate_kbps -AND $mediameta.video.FrameRate_fps) )
                $hasAudioProps = [boolean](($mediameta.audio.Format_String -AND $mediameta.audio.CodecID -AND $mediameta.audio.SamplingRate_bit ) )               

                $MDtbl=[ordered]@{NoDashRow=$true } ; # out-markdowntable splat
                
                $sRpt = '-'*5 ; 
                $sRpt += "`n$(($mediaMeta.general| select $propsGeneral1|out-markdowntable @MDtbl |out-string).trim())" ;
                $sRpt += "`n$(($mediaMeta.general| select $propsGeneral2|out-markdowntable @MDtbl |out-string).trim())" ;
                $sRpt += "`n$(($mediaMeta.video| select $propsVideo|out-markdowntable @MDtbl |out-string).trim())" ;
                $sRpt += "`n$(($mediaMeta.audio| select $propsAudio|out-markdowntable @MDtbl |out-string).trim())" ;
                $sRpt += "`n$(($mediaMeta.SubtitleLanguagesInternal|out-markdowntable @MDtbl |out-string).trim())" ;
                $sRpt += "`n$('-'*5)" ; 

                if($hasGeneralProps -AND $hasMbps -AND $hasVRes -AND $hasVidProps -AND $hasAudioProps){
                    $isLegit = $true ; 
                    $smsg = "($($finalname) passes meta props test)" ;                         
                    if(-not$Silent){
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        $smsg = $sRpt ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ; 
                } else { 
                    $isLegit = $false ; 
                    $smsg = "$($finalname) *FAILS* meta props test" ; 
                    $smsg += $sRpt ;
                    if(-not$Silent){
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } ; 
                    if(-not $hasGeneralProps){
                        $smsg = "-LACKS key general meta props!:" ; 
                        $smsg = "`n$(($mediaMeta.general| fl $propsGeneralTest|out-string).trim())" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        }
                        $smsg = $null ; 
                        if(-not $mediaMeta.general.CompleteName){
                            $smsg += "`n(missing general.CompleteName)" ; 
                        }
                        if(-not $mediaMeta.general.OverallBitRate_String){
                            $smsg += "`n(missing general.OverallBitRate_String)" ; 
                        } 
                        if(-not $mediaMeta.general.OverallBitRate_kbps){
                            $smsg += "`n(missing general.OverallBitRate_kbps)" ; 
                        } ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } ;
                    if(-not $hasVidProps){
                        $smsg = "-LACKS key video meta props!:" ; 
                        $smsg += "`n$(($mediaMeta.video| fl $propsVidTest|out-string).trim())" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ; 
                        $smsg = $null ; 
                        if(-not $mediameta.video.Format_String ){
                            $smsg += "`n(missing video.Format_String)" ; 
                        }
                        if(-not $mediameta.video.CodecID){
                            $smsg += "`n(missing video.CodecID)" ; 
                        } 
                        if(-not $mediameta.video.Duration_Mins){
                            $smsg += "`n(missing video.Duration_Mins)" ; 
                        } ; 
                        if(-not $mediameta.video.BitRate_kbps){
                            $smsg += "`n(missing video.BitRate_kbps)" ; 
                        } ; 
                        if(-not $mediameta.video.FrameRate_fps){
                            $smsg += "`n(missing video.FrameRate_fps)" ; 
                        } ;   
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;                       
                    } ;
                    if(-not $hasAudioProps){
                        $smsg = "-LACKS key audio meta props!:" ; 
                        $smsg += "`n$(($mediaMeta.audio| fl $propsVidTest|out-string).trim())" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ;
                        $smsg += $null ; 
                        if(-not $mediameta.audio.Format_String ){
                            $smsg += "`n(missing audio.Format_String)" ; 
                        }
                        if(-not $mediameta.audio.CodecID){
                            $smsg += "`n(missing audio.CodecID)" ; 
                        } 
                        if(-not $mediameta.audio.SamplingRate_bit){
                            $smsg += "`n(missing audio.SamplingRate_bit)" ; 
                        } ; 
                        if(-not $mediameta.video.BitRate_kbps){
                            $smsg += "`n(missing video.BitRate_kbps)" ; 
                        } ;                        
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;                      
                    } ;
                    if(-not $hasMbps){
                        $smsg = "-has a VERY LOW MB/SEC spec! ($($mediaMeta.general.FileSize_MB/$mediaMeta.general.Duration_Mins) vs min:$($ThresholdMbPerMin))!:" ; 
                        $smsg += "`nPOTENTIALLY UNDERSIZED/NON-VIDEO FILE!" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ;
                    } ;
                    if(-not $hasVRes){
                        $smsg = "-is a VERY LOW RES! ($($mediaMeta.video.Height_Pixels) vs min:$($ThreshVRes))!:" ; 
                        $smsg += "`nPOTENTIALLY UNDERSIZED/NON-VIDEO FILE!" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        };
                    } ;
                } ;  # good/bad
                
                $isLegit | write-output ;

            }  # loop-E
        }  # PROC-E
        END{
          
        };
}

#*------^ test-MediaFile.ps1 ^------
