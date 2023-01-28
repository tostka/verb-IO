#*----------v Function Remove-SubtitleSpamLines() v----------
function Remove-SubtitleSpamLines  {
    <#
    .SYNOPSIS
    Remove-SubtitleSpamLines.ps1 - Deletes any lines containing the specified string, from the file specified (Creates a backup of origina file: .srt_BU).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Media,Video,Subtitle,Editing
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 11:18 PM 1/27/2023 confirmed pipeline array of paths works;  updated CBH; added full logging/transcription via write-log (to local SRT_edits-log.txt, w optional Transcript via -Transcribe param) ; 
    added -Revert & -Transcribe params; cleaned out a bunch of rem'd unused code
    * 9:51 PM 1/26/2023 confirmed on another.
    * 10:05 PM 1/25/2023 *might* be working now.
    * 8:47 PM 1/19/2023 init
    .DESCRIPTION
    Remove-SubtitleSpamLines.ps1 - Deletes any lines containing the specified string, from the file specified.
    Supports only .srt files. 
    
    Runs a log file that appends changes over time, in the same directory as the specified .srt file (as 'SRT_edits-log'). 
    If the -Transcribe parameter is used, also produces a standard Powershell Transcript (with -Append to accumulate future changes). 

    The process of 'stripping'/removal of the problem lines leaves the counter 
    integer, and timestamp lines intact, and simply removes entire lines matching 
    the specified 'string

    Either a normal text string: 'Brought to you by advertiser.com!' 
    or regex pattern can be used (a regex -match performed in the code, using the...
    $_ -replace $string,'' operator. 
    
    There is no impact to the removal of lines, as .srt file format supports one or more lines of text, 
    and requires that a blank line appear at the end of a subtitle (see below).
    
    [SRT File Format - docs.fileformat.com/](https://docs.fileformat.com/video/srt/)

    Each subtitle has four parts in the SRT file.

    1.  A numeric counter indicating the number or position of the subtitle.
    2.  Start and end time of the subtitle separated by –> characters
    3.  Subtitle text in one or more lines.
    4.  A blank line indicating the end of the subtitle.
    
    .PARAMETER Path
    Target SRT File path[-path c:\pathto\file.srt]
    .PARAMETER  StringBlank
    String or regex expression for line matches that are to be completely stripped from file[-StringBlank 'somestring']
    .PARAMETER StockStrings
    Predefined array of strings to be automatically replaced in any given .srt file (specifiy -StockStrings:`$null to override)[-StockStrings `$null]
    .PARAMETER stripHtml
    Switch to trigger auto-removal of all html tags in the file (defaults true))[-stripHtml]
    .PARAMETER Revert
    Attempts to restore from a local _BU file for the specified Path, copied back to the original .srt file.
    .PARAMETER Transcribe
    Switch to cause a Powershell transcript to be run for the session (default is solely a log file).[-Transcribe]
    .PARAMETER whatif
    whatif switch)[-whatif]
    .EXAMPLE
    PS> Remove-SubtitleSpamLines -Path 'I:\videos\Movie\The Santa Clause (1994)\The.Santa.Clause.1994.720p.BrRip.x264.YIFY.srt' -StringBlank 'YIFY','OpenSubtitles','YTS.MX' -verbose ;
        SrcFile:I:\videos\Movie\The Santa Clause (1994)\The.Santa.Clause.1994.720p.BrRip.x264.YIFY.srt
        new DestFile:
        I:\videos\Movie\The Santa Clause (1994)\The.Santa.Clause.1994.720p.BrRip.x264.YIFYXXX.srt...
        Net removals:
        InputObject
        -----------
        Created and Encoded by --  Bokutox -- of  www.YIFY-TORRENTS.com. The Best 720p/1080p/3d movies with the lowest file size on th...
        Updates written to:
        I:\videos\Movie\The Santa Clause (1994)\The.Santa.Clause.1994.720p.BrRip.x264.YIFYXXX.srt
    Example creating a backed stripped copy of the specified file.
    .EXAMPLE
    PS>  Remove-SubtitleSpamLines -Path 'I:\videos\Movie\The Santa Clause (1994)\The.Santa.Clause.1994.720p.BrRip.x264.YIFY.srt' -revert -Verbose ;
 
    
    Demo use of the -Revert parameter to restore prior version.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('strip-SRT')]
    PARAM(
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True, 
            HelpMessage = 'Target SRT File path[-path c:\pathto\file.srt]')]
        [Alias('PsPath')]
        [ValidateScript({Test-Path $_})]
        [ValidateScript( { get-childitem $_ |Where-Object{$_.extension -eq '.srt'}})]
        [system.io.fileinfo]$Path,
        [Parameter(Mandatory = $false,Position = 1, 
            HelpMessage = "String or regex expression for line matches that are to be completely stripped from file[-StringBlank 'somestring']")]
        [string[]]$StringBlank,
        [Parameter(
            HelpMessage = "Predefined array of strings to be automatically replaced in any given .srt file (specifiy -StockStrings:`$null to override)[-StockStrings `$null]")]
        [string[]]$StockStrings = @('Support\sus\sand\sbecome\sVIP\smember\s',
            'to\sremove\sall\sads\sfrom\swww\.OpenSubtitles\.org',
            "Please\srate\sthis\ssubtitle\sat\swww\.osdb\.link/[a-zA-z0-9]{5}",
            "Help\sother\susers\sto\schoose\sthe\sbest\ssubtitles",
            "Surf\sthe\sinternet\swith\sbrowser\sof\sfuture",
            "osdb\.link/brave",
            "^Downloaded\sfrom$"
             ),
        [Parameter(
            HelpMessage = "Predefined array of strings to automatically strip *entire* line from file (specifiy -LineStripWords:`$null to override)[-LineStripWords `$null]")]
        [string[]]$LineStripWords = @('YIFY','OpenSubtitles','YTS.MX'),
        [Parameter(HelpMessage = "Switch to trigger auto-removal of all html tags in the file (defaults true))[-stripHtml]")]
        [switch]$stripHtml = $true,
        [Parameter(HelpMessage = "Attempts to restore from a local _BU file for the specified Path, copied back to the original .srt file.[-Revert]")]
        [switch]$Revert,
        [Parameter(HelpMessage = "Switch to cause a Powershell transcript to be run for the session (default is solely a log file).[-Transcribe]")]
        [switch]$Transcribe,
        [Parameter(HelpMessage = "whatif switch)[-whatif]")]
        [switch]$whatif
   ) ; 
    BEGIN {
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        $verbose = ($VerbosePreference -eq "Continue") ;
        if($stripHtml){
                $smsg = "-stripHtml: adding font-removal redex to $StockStrings spec" ; 
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                $stockStrings += "\<[^\>]*\>" ; 
        } ; 
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            $smsg = "Data received from pipeline input: '$($InputObject)'" ; 
            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
             else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        } else {
            #$smsg = "Data received from parameter input: '$($InputObject)'" ; 
            $smsg = "(non-pipeline - param - input)" ; 
            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        } ; 

        $smsg = "Append `$LineStripWords to any defined `$StringBlank" ; 
        if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        $StringBlank += $LineStripWords ; 
    } ;  # BEGIN-E
    PROCESS {
        $Error.Clear() ; 
        
        foreach ($item in $Path){    
            TRY{
                
                # logging, build transcript, in the path's parent folder
                $transcript = join-path -path (split-path $item.fullname) -childpath "SRT_edits-trans.txt" ; 
                $logfile = $transcript.replace('-trans','-log') ; 
                $logging = $true ; 
                if($transcript -AND $Transcribe){
                    $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
                    if($stopResults){
                        $smsg = "Stop-transcript:$($stopResults)" ; 
                        if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    } ; 
                    $startResults = start-Transcript -APPEND -path $transcript ;
                    if($startResults){
                        $smsg = "start-transcript:$($startResults)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ; 
                } ; 

                if(-not $Revert){

                    $BuFile = ($item.fullname.replace($item.Extension,"$($item.Extension)_BU")) ;

                    $smsg = "Creating backup file:`n$($BuFile)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt

                    $pltCI=[ordered]@{
                        path=$item.fullname ;
                        destination=($item.fullname.replace($item.Extension,"$($item.Extension)_BU"))  ;
                        force=$true;
                        verbose=$true;
                        erroraction = 'STOP' ;
                        whatif = $($whatif) ;
                    } ;
                    $smsg = "copy-item  w`n$(($pltCI|out-string).trim())" ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    copy-item @pltCI ; 
                    $smsg = "verify copy: gci `$pltCI.destination`n$((Get-ChildItem $pltCI.destination -ea STOP| Format-Table -a Name,Length,LastWriteTime |out-string).trim())" ; 
                    write-host $smsg ; 
                    
                    $pltGC=[ordered]@{
                        Path = $NULL ; 
                        erroraction = 'STOP' ;
                        verbose = $($VerbosePreference -eq "Continue") ;
                    } ;
                    $pltSC=[ordered]@{
                        Path = $NULL  ; 
                        erroraction = 'STOP' ;
                        verbose = $($VerbosePreference -eq "Continue") ;
                        whatif = $($whatif) ;
                    } ;
                    $smsg = "setting Get/Set-Content -path to $($item.fullname)" ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 

                    $pltGC.path = $pltSC.path = $item.fullname ;

                    $smsg = "Get-Content w`n$(($pltGC|out-string).trim())" ; 
                    $smsg += "`n`nSet-Content w`n$(($pltSC|out-string).trim())" ;  
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 


                    $smsg = "write all lines that *don't* contain the targeted string...." ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    foreach($str in $StringBlank){
                        $smsg = "write-lines that -notmatch $($str)" ; 
                        $smsg += "`nGet-Content w`n$(($pltGC|out-string).trim())" ; 
                        if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;  
                        $newContent = (Get-Content @pltGC ) -notmatch $str ;
                        if($newContent){
                            $smsg = "`n`nSet-Content w`n$(($pltSC|out-string).trim())" ;  
                            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                            $newContent | Set-Content @pltSC ;
                        } else {
                            $smsg = "NO CONTENT PASSED THROUGH INITIAL FILTER!" ; 
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                            BREAK ; 
                        } ; 

                                                <# nother route: [Using PowerShell to remove lines from a text file if it contains a string - Stack Overflow - stackoverflow.com/](https://stackoverflow.com/questions/24326207/using-powershell-to-remove-lines-from-a-text-file-if-it-contains-a-string)
                    Set-Content -Path "C:\temp\Newtext.txt" -Value (get-content -Path "c:\Temp\Newtext.txt" | Select-String -Pattern 'H\|159' -NotMatch)                
                    # another approach:
                    Get-Content C:\new\temp_*.txt |
                        Where-Object { -not $_.Contains('H|159') } |
                        Set-Content C:\new\newfile.txt
                    #>
                    } ; 

                    # loop remove the following strings:$stockStrings
                    foreach($str in $stockStrings){
                        $smsg = "replacing:$($str)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                        $smsg = "nGet-Content w`n$(($pltGC|out-string).trim())" ; 
                        if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 

                        $newContent = (Get-Content @pltGC ) | Foreach-Object {
                            if($_ -match $str){
                                write-verbose 'bing!'
                            } ; 
                            $_ -replace $str ; 
                        } | out-string ;
                        if($newContent){
                            $smsg = "`n`nSet-Content w`n$(($pltSC|out-string).trim())" ;  
                            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                            $newContent | Set-Content  @pltSC  ;
                        } ; 
                    
                    } ;  # loop-E
                    # pull the Losses/Removals: entries with .SideIndicator -eq "<=" (present in left list but not in right)
                    $result = (Compare-Object -ReferenceObject (Get-Content $BuFile) -DifferenceObject (Get-Content $item.fullname)  ) ;
                    $sBnr="`n`n#*======v =Diff:Net removals: v======" ; 
                    $smsg = $sBnr ; 
                    $smsg += "`n$(($result|Where-Object{$_.SideIndicator -eq "<="}|out-string).trim())" ;
                    $smsg += "$($sBnr.replace('=v','=^').replace('v=','^='))`n`n" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                
                    $smsg = "Updates written to:`n$($item.fullname)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                    $smsg = "(returning updated filename to pipeline" ;
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;  

                    $item.fullname | write-output ; 
                } else { 
                    # revert block 
                    $smsg = "-Revert specified with -Path:" ; 
                    $smsg += "`n$(( ($Path -join ',')|out-string).trim())" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                    
                    if($BuFile = gci ($item.fullname.replace($item.Extension,"$($item.Extension)_BU")) ){
                    
                        $smsg = "Located/restoring from backup file:`n$($BuFile)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                        $pltCI=[ordered]@{
                            path= $BuFile.fullname ; 
                            destination= $item.fullname ;
                            #($item.fullname.replace($item.Extension,"$($item.Extension)_BU"))  ;
                            force=$true;
                            verbose=$true;
                            erroraction = 'STOP' ;
                            whatif = $($whatif) ;
                        } ;
                        $smsg = "copy-item  w`n$(($pltCI|out-string).trim())" ; 
                        if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                        copy-item @pltCI ; 
                        $smsg = "verify copy: gci `$pltCI.destination`n$((Get-ChildItem $pltCI.destination -ea STOP| Format-Table -a Name,Length,LastWriteTime |out-string).trim())" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                        
                    } else { 
                        $smsg = "Unable to locate a a matching backup file..." ;
                        $smsg += "`n$($item.fullname.replace($item.Extension,"$($item.Extension)_BU"))" ;
                        $smsg += "...for specified -Path:`n$($item.fullname)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } ; 
                } ;
                if($Transcribe){
                    $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
                    if($stopResults){
                        $smsg = "Stop-transcript:$($stopResults)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                    } ; 
                } ; 
                 
            } CATCH {
                $smsg = $_.Exception.Message ;
                write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)"  ;
                BREAK ;
            } ;
        } ;  # loop-E
    }  # if-E PROC
    END{} ; 
} ; 
#*------^ END Function Remove-SubtitleSpamLines()  ^------