#*------v test-MissingMediaSummary.ps1 v------
Function test-MissingMediaSummary {
    <#
    .SYNOPSIS
    test-MissingMediaSummary.ps1 - Checks specified path for supported video files, foreach tests for presence of a like-named -media.xml media summary file, and runs verb-io:test-mediafile for media files missing summaries.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-03-07
    FileName    : test-MissingMediaSummary.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Media,Metadata,Video,Audio
    REVISIONS
    * 10:35 AM 3/14/2022 yanked [hash]Requires -Modules Get-MediaInfo: I don't want to install gmi on servers, at all. So we drop the coverage.
    * 8:34 AM 3/9/2022 set gci to recurse whole tree (span season dirs, save re-run needs); added w-v at a few useful points; expanded some alias use; duped rgx from profile into func.
    * 8:25 PM 3/7/2022init vers
    .DESCRIPTION
    test-MissingMediaSummary.ps1 - Checks specified path for supported video files, foreach tests for presence of a like-named -media.xml media summary file, and runs verb-io:test-mediafile for media files missing summaries.
    .PARAMETER Path
    Path to a media directory of files to be check.[-Path D:\path-to\]
    .OUTPUT
    None. Outputs summary to console. 
    .EXAMPLE
    PS> test-MissingMediaSummary -Path c:\pathto\
    Example scanning the c:\pathto\ dir for missing media summary ([name]-media.xml) files, for each discovered media file
    .EXAMPLE
    PS> vmf c:\pathto\
    Example using 'vmf' alias and default path param
    .LINK
    https://github.com/tostka/verb-IO
    #>
    
    [Alias('vmf')]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        [string[]] $Path,
        [Parameter(HelpMessage="Suppress all outputs but return pass status as`$true/`$false, to the pipeline[-Silent]")]
        [switch] $Silent
    ) ;
    BEGIN{
      if(-not $rgxVideoExts){$rgxVideoExts = '\.(MPEG|AVI|ASF|WMV|MP4|MOV|3GP|OGM|MKV|WEBM|MXF)' } ;
    }
    PROCESS{
        foreach($p in $Path){
            write-verbose "checking path $($p)\*)" ; 
            $vfiles = get-childitem "$($p)\*" -recurse | ? { $_.extension -match $rgxVideoExts } ;
            $ttl = ($vfiles|measure).count ; $procd = 0; 
             foreach ($vf in $vfiles) {
                $procd++ ; 
               write-host "($($procd)/$($ttl))checking for missing -media.xml for:$($vf.fullname)" ; 
               if (-not (test-path -path (join-path -path $vf.DirectoryName -childpath "$($vf.basename)-media.xml"))) {
                  write-verbose "test-MediaFile -path $($vf.fullname) -Verbose:$($VerbosePreference -eq 'Continue'))" ;
                   test-MediaFile -path "$($vf.fullname)" -Verbose:($VerbosePreference -eq 'Continue') ;  
               } else {
                   write-verbose "(convirmed present:$($vf.basename)-media.xml)"
               };  
           } ;  # loop-E
        }  # loop-E
    }  # PROC-E
    END{};
}

#*------^ test-MissingMediaSummary.ps1 ^------