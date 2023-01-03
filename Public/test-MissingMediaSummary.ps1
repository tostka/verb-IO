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
    * 8:36 PM 1/2/2023 added transcript logging with 4-file rotation (for post-review when running large number of dirs, and they scroll off of ps buffer recording).
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
    [CmdletBinding()]
    [Alias('vmf')]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        #[string[]] $Path,
        [system.io.fileinfo[]]$Path,
        [Parameter(HelpMessage="Suppress all outputs but return pass status as`$true/`$false, to the pipeline[-Silent]")]
        [switch] $Silent
    ) ;
    BEGIN{
        if(-not $rgxVideoExts){$rgxVideoExts = '\.(MPEG|AVI|ASF|WMV|MP4|MOV|3GP|OGM|MKV|WEBM|MXF)' } ;
        #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
        # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        $Verbose = ($VerbosePreference -eq 'Continue') ; 
        #if ($PSScriptRoot -eq "") {
        if( -not (get-variable -name PSScriptRoot -ea 0) -OR ($PSScriptRoot -eq '')){
            if ($psISE) { $ScriptName = $psISE.CurrentFile.FullPath } 
            elseif($psEditor){
                if ($context = $psEditor.GetEditorContext()) {$ScriptName = $context.CurrentFile.Path } 
            } elseif ($host.version.major -lt 3) {
                $ScriptName = $MyInvocation.MyCommand.Path ;
                $PSScriptRoot = Split-Path $ScriptName -Parent ;
                $PSCommandPath = $ScriptName ;
            } else {
                if ($MyInvocation.MyCommand.Path) {
                    $ScriptName = $MyInvocation.MyCommand.Path ;
                    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent ;
                } else {throw "UNABLE TO POPULATE SCRIPT PATH, EVEN `$MyInvocation IS BLANK!" } ;
            };
            if($ScriptName){
                $ScriptDir = Split-Path -Parent $ScriptName ;
                $ScriptBaseName = split-path -leaf $ScriptName ;
                $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($ScriptName) ;
            } ; 
        } else {
            if($PSScriptRoot){$ScriptDir = $PSScriptRoot ;}
            else{
                write-warning "Unpopulated `$PSScriptRoot!" ; 
                $ScriptDir=(Split-Path -parent $MyInvocation.MyCommand.Definition) + "\" ;
            }
            if ($PSCommandPath) {$ScriptName = $PSCommandPath } 
            else {
                $ScriptName = $myInvocation.ScriptName
                $PSCommandPath = $ScriptName ;
            } ;
            $ScriptBaseName = (Split-Path -Leaf ((& { $myInvocation }).ScriptName))  ;
            $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;
        } ;
        if(!$ScriptDir){
            write-host "Failed `$ScriptDir resolution on PSv$($host.version.major): Falling back to $MyInvocation parsing..." ; 
            $ScriptDir=(Split-Path -parent $MyInvocation.MyCommand.Definition) + "\" ;
            $ScriptBaseName = (Split-Path -Leaf ((&{$myInvocation}).ScriptName))  ; 
            $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;     
        } else {
            if(-not $PSCommandPath ){
                $PSCommandPath  = $ScriptName ; 
                if($PSCommandPath){ write-host "(Derived missing `$PSCommandPath from `$ScriptName)" ; } ;
            } ; 
            if(-not $PSScriptRoot  ){
                $PSScriptRoot   = $ScriptDir ; 
                if($PSScriptRoot){ write-host "(Derived missing `$PSScriptRoot from `$ScriptDir)" ; } ;
            } ; 
        } ; 
        if(-not ($ScriptDir -AND $ScriptBaseName -AND $ScriptNameNoExt)){ 
            throw "Invalid Invocation. Blank `$ScriptDir/`$ScriptBaseName/`ScriptNameNoExt" ; 
            BREAK ; 
        } ; 

        $smsg = "`$ScriptDir:$($ScriptDir)" ;
        $smsg += "`n`$ScriptBaseName:$($ScriptBaseName)" ;
        $smsg += "`n`$ScriptNameNoExt:$($ScriptNameNoExt)" ;
        $smsg += "`n`$PSScriptRoot:$($PSScriptRoot)" ;
        $smsg += "`n`$PSCommandPath:$($PSCommandPath)" ;  ;
        write-host $smsg ; 

        #region TRANSCRIPTPATH ; #*------v TRANSCRIPT FROM A $PATH VARI v------
        #$transcript = "$($path.directoryname)\logs" ; 
        # simple root of path'd drive x:\scripts\logs transcript on the functionname
        $transcript = "$((split-path $path[0]).split('\')[0])\scripts\logs" ; 
        if(!(test-path -path $transcript)){ write-host "Creating missing log dir $($transcript)..." ; mkdir $transcript -verbose:$true  ; } ;
        #$transcript += "\$($path[0].basename)" ; 
        $transcript += "\$($ScriptNameNoExt)" ; 
        <#$transcript += "-WHATIF-$(get-date -format 'yyyyMMdd-HHmmtt')-trans.txt" ; 
        if(get-variable whatif -ea 0){
            if(-not $whatif){$transcript = $transcript.replace('-WHATIF-','-EXECUTE-')} 
        } ;
        #>
        # rotating series of 4 logs named for the base $transcript
        $transcript += "-transNO.txt" ; 
        $rotation = (get-childitem $transcript.replace('NO','*')) ; 
        if(-not $rotation ){
            write-verbose "Establishing 4 rotating log files ($transcript)..." ; 
            1..4 | %{echo $null > $transcript.replace('NO',"0$($_)") } ; 
            $rotation = (get-childitem $transcript.replace('NO','*')) ;
        } ;
        $transcript = $rotation | sort LastWriteTime | select -first 1 | select -expand fullname ; 
        $logfile = $transcript.replace('-trans','-log') ; 
        #$logging = $true ; 
        #endregion TRANSCRIPTPATH ; #*------^ END TRANSCRIPT FROM A $PATH VARI ^------
        #region STARTTRANS ; #*------v STARTTRANSCRIPT v------
        TRY {
            if($transcript){
                $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
                if($stopResults){
                    $smsg = "Stop-transcript:$($stopResults)" ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                } ; 
                $startResults = start-Transcript -path $transcript ;
                if($startResults){
                    $smsg = "start-transcript:$($startResults)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ; 
            } else {
                $smsg = "UNPOPULATED `$transcript! - ABORTING!" ; 
                write-warning $smsg ; 
                throw $smsg ; 
                break ; 
            } ;  
        } CATCH [System.Management.Automation.PSNotSupportedException]{
            if($host.name -eq 'Windows PowerShell ISE Host'){
                $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
            } else { 
                $smsg = "This host does *not* support native (start-)transcription" ; 
            } ; 
            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        } ;
        #endregion STARTTRANS ; #*------^ END STARTTRANSCRIPT ^------
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
    END {
        $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
        if($stopResults){
            $smsg = "Stop-transcript:$($stopResults)" ; 
            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        } ; 
    } ;  # END-E
}

#*------^ test-MissingMediaSummary.ps1 ^------
