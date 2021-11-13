#*------v test-MediaFile.ps1 v------
Function test-MediaFile {
    <#
    .SYNOPSIS
    test-MediaFile.ps1 - 1) Pulls media descriptive metadata (from MediaInfo.dll via get-MediaInfoRAW()) out of a media file, 
    2) Compares key A/V metrics against (my arbitrary) thresholds for suitability, 
    and 3) outputs a summary report of the metrics. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : test-MediaFile.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Media,Metadata,Video,Audio,Subtitles
    REVISIONS
    * 7:37 PM 11/12/2021 added example for doing a full dir of files ; flip $path param test-path to use -literalpath - too many square brackets in sources
    * 6:05 PM 11/6/2021 swap $finalfile -> "$($entry)" ; fixed missing use of pltGIMR (wasn't doing xml export)
    * 8:44 PM 11/2/2021 flip gci -path => -literalpath, avoid [] wildcard issues
    * 7:47 PM 10/26/2021 added -ExportToFile defaulted to true
    * 12:53 PM 10/20/2021 init vers - ported over to verb-io from my fix-htpcfiles.ps1
    .DESCRIPTION
    test-MediaFile.ps1 - 1) Pulls media descriptive metadata (from MediaInfo.dll via get-MediaInfoRAW()) out of a media file, 
    2) Compares key A/V metrics against (my arbitrary) thresholds for suitability, 
    and 3) outputs a summary report of the metrics. 

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
    .OUTPUT
    None. Outputs summary to console. 
    .EXAMPLE
    test-MediaFile -Path c:\pathto\video.mp4
    Example summarizing a video file
    .EXAMPLE
    'c:\pathto\video.mp4'| test-MediaFile 
    Example using pipeline support
    .EXAMPLE
    gci "c:\PathTo\*" -include *.mkv | select -expand fullname | test-MediaFile
    .LINK
    https://hexus.net/tech/tech-explained/storage/1376-gigabytes-gibibytes-what-need-know/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    #[Alias('convert-xxx')]
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
            [Parameter(HelpMessage="Switch to create a matching XML metadata export file (with -Path name/location and .xml         ext).[-ExportToFile]")]
            [switch]$ExportMediaToFile=$true
        ) ;
        BEGIN{

        #$propsGeneral1 = @{name="FileName";expression={$_.CompleteName}}, @{name="FileMB";expression={"$($_.FileSize_MB)mb"}}
        #$propsGeneral2 = @{name="FileMB";expression={"$($_.FileSize_MB)mb"}},@{name="Mins";expression={[math]::round($_.Duration_Mins,1)}},@{name="OBitRate";expression={"$($_.OverallBitRate_kbps) kbps"}} ; 
        #$propsAudio = @{name="Chnls";expression={$_.Channel_s__String.replace('annels','')}},@{name="Lang";expression={$_.Language_String}},@{name="Fmt";expression={$_.Format_String}},@{name="BitRate";expression={$_.BitRate_String}},@{name="kHz";expression={$_.SamplingRate_bit}}; 
        #$propsVideo = 'Format_String','BitRate_Mode_String','BitRate_kbps','Width_Pixels','Height_Pixels','DisplayAspectRatio_String','FrameRate_fps','Standard','Encoded_Library_String' ; 

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
                    } ;
                    if(-not $hasVidProps){
                        $smsg = "-LACKS key video meta props!:" ; 
                        $smsg = "`n$(($mediaMeta.video| fl $propsVidTest|out-string).trim())" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ; 
                    } ;
                    if(-not $hasAudioProps){
                        $smsg = "-LACKS key audio meta props!:" ; 
                        $smsg = "`n$(($mediaMeta.audio| fl $propsVidTest|out-string).trim())" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ;
                    } ;
                    if(-not $hasMbps){
                        $smsg = "-has a VERY LOW MB/SEC spec! ($($mediaMeta.general.FileSize_MB/$mediaMeta.general.Duration_Mins) vs min:$($ThresholdMbPerMin))!:" ; 
                        $smsg = "`nPOTENTIALLY UNDERSIZED/NON-VIDEO FILE!" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ;
                    } ;
                    if(-not $hasVRes){
                        $smsg = "-is a VERY LOW RES! ($($mediaMeta.video.Height_Pixels) vs min:$($ThreshVRes))!:" ; 
                        $smsg = "`nPOTENTIALLY UNDERSIZED/NON-VIDEO FILE!" ; 
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