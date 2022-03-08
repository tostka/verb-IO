#*------v test-MissingMediaSummary.ps1 v------
Function test-MissingMediaSummary {
    <#
    .SYNOPSIS
    test-MissingMediaSummary.ps1 - Checks specified path for supported video files, tests for presence of a -media.xml media summary file, and runs verb-io:test-mediafile on those media files missing summary files
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : test-MissingMediaSummary.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Media,Metadata,Video,Audio,Subtitles
    REVISIONS
    * 8:25 PM 3/7/2022init vers
    .DESCRIPTION
    test-MissingMediaSummary.ps1 - Checks specified path for supported video files, tests for presence of a -media.xml media summary file, and runs verb-io:test-mediafile on those media files missing summary files
    .PARAMETER Path
    Path to a media directory of files to be check.[-Path D:\path-to\]
    .OUTPUT
    None. Outputs summary to console. 
    .EXAMPLE
    PS> test-MissingMediaSummary -Path c:\pathto\
    Example scanning the c:\pathto\ dir for missing media summary files
    .EXAMPLE
    PS> $files = gci "I:\videos\Show\TITLE\S01\*" ; 
    PS> $rgxVideoExts = '\.(MPEG|AVI|ASF|WMV|MP4|MOV|3GP|OGM|MKV|WEBM|MXF)' ; 
    PS> $vfiles = $files  | ? { $_.extension -match $rgxvideoexts } ; 
    PS> foreach ($vf in $vfiles) {
    PS>     if (-not (test-path -path (join-path -path $vf.DirectoryName -childpath "$($vf.basename)-media.xml"))) {
    PS>         write-host "scanning missing -media.xml for:$($vf.fullname)" ; 
    PS>         tmf "$($vf.fullname)" ; 
    PS>     } else {
    PS>         write-verbose "(convirmed:$($vf.basename)-media.xml)"
    PS>     };  
    PS> } ; 
    Demo collecting array of supported video files in target dir, and processing those missing summaries, to comply
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('vmf')]
    PARAM(
        #[Parameter(Position=0,Mandatory=$True,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string[]] $Path,
        [Parameter(HelpMessage="Suppress all outputs but return pass status as`$true/`$false, to the pipeline[-Silent]")]
        [switch] $Silent
    ) ;
    BEGIN{}
    PROCESS{
    
        foreach($p in $Path){
            $vfiles = gci "$($p)\*" | ? { $_.extension -match $rgxvideoexts } ;
            $ttl = ($vfiles|measure).count ; $procd = 0; 
             foreach ($vf in $vfiles) {
                $procd++ ; 
               write-host "($($procd)/$($ttl))scanning missing -media.xml for:$($vf.fullname)" ; 
               if (-not (test-path -path (join-path -path $vf.DirectoryName -childpath "$($vf.basename)-media.xml"))) {
                   tmf "$($vf.fullname)" -Verbose:($VerbosePreference -eq 'Continue') ;  
               } else {
                   write-verbose "(convirmed:$($vf.basename)-media.xml)"
               };  
           } ;   
        }  # loop-E
    }  # PROC-E
    END{};
}

#*------^ test-MissingMediaSummary.ps1 ^------