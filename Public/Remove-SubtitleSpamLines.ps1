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
    * 9:51 PM 1/26/2023 confirmed on another.
    * 10:05 PM 1/25/2023 *might* be working now.
    * 8:47 PM 1/19/2023 init
    .DESCRIPTION
    Remove-SubtitleSpamLines.ps1 - Deletes any lines containing the specified string, from the file specified.
    Supports only .srt files. 
    
    The removal leaves the counter integer, and timestamp lines intact, and simply removes entire lines matching the specified 'string. 
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
    File path[-path c:\pathto\file.ext]
    .PARAMETER String
    String or regex expression for line matches that are to be completely stripped from file[-string 'somestring']
    .EXAMPLE
    PS> Remove-SubtitleSpamLines -Path 'I:\videos\Movie\The Santa Clause (1994)\The.Santa.Clause.1994.720p.BrRip.x264.YIFY.srt' -string 'YIFY','OpenSubtitles' -verbose ;
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
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('strip-SRT')]
    PARAM(
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True, 
            HelpMessage = 'File path[-path c:\pathto\file.ext]')]
        [Alias('PsPath')]
        [ValidateScript({Test-Path $_})]
        [ValidateScript( { get-childitem $_ |?{$_.extension -eq '.srt'}})]
        [system.io.fileinfo]$Path,
        [Parameter(Mandatory = $true,Position = 1, 
            HelpMessage = "String or regex expression for line matches that are to be completely stripped from file[-string 'somestring']")]
        [string[]]$string,
        [Parameter(HelpMessage = "Predefined array of strings to be automatically replaced in any given .srt file (specifiy -StockStrings:`$null to override)[-StockStrings `$null]")]
        [string[]]$StockStrings = @('Support\sus\sand\sbecome\sVIP\smember\s',
            'to\sremove\sall\sads\sfrom\swww\.OpenSubtitles\.org',
            "Please\srate\sthis\ssubtitle\sat\swww\.osdb\.link/[a-zA-z0-9]{5}",
            "Help\sother\susers\sto\schoose\sthe\sbest\ssubtitles",
            "Surf\sthe\sinternet\swith\sbrowser\sof\sfuture",
            "osdb\.link/brave"
             ),
        [Parameter(HelpMessage = "Switch to trigger auto-removal of all html tags in the file (defaults true))[-stripHtml]")]
        [switch]$stripHtml = $true,
        [Parameter(HelpMessage = "whatif switch)[-whatif]")]
        [switch]$whatif
   ) ; 
    BEGIN {
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if($stripHtml){
                write-verbose "-stripHtml: adding font-removal redex to $StockStrings spec" ; 
                $stockStrings += "\<[^\>]*\>" ; 
        } ; 
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 
    } ;  # BEGIN-E
    PROCESS {
        $Error.Clear() ; 
        
        foreach ($item in $Path){    
            TRY{
                $BuFile = ($item.fullname.replace($item.Extension,"$($item.Extension)_BU")) ;

                write-host "Creating backup file:`n$($BuFile)" ; 
                $pltCI=[ordered]@{
                    path=$item.fullname ;
                    destination=($item.fullname.replace($item.Extension,"$($item.Extension)_BU"))  ;
                    force=$true;
                    verbose=$true;
                    erroraction = 'STOP' ;
                    whatif = $($whatif) ;
                } ;
                $smsg = "copy-item  w`n$(($pltCI|out-string).trim())" ; 
                write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)"  ;
                copy-item @pltCI ; 
                $smsg = "verify copy: gci `$pltCI.destination`n$((gci $pltCI.destination -ea STOP| ft -a Name,Length,LastWriteTime |out-string).trim())" ; 
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
                write-verbose "setting Get/Set-Content -path to $($item.fullname)" ; 
                $pltGC.path = $pltSC.path = $item.fullname ;

                $smsg = "Get-Content w`n$(($pltGC|out-string).trim())" ; 
                $smsg += "`n`nSet-Content w`n$(($pltSC|out-string).trim())" ;  
                write-verbose $smsg ; 


                write-verbose "write all lines that *don't* contain the targeted string...." ; 
                foreach($str in $string){
                    write-verbose "write-lines that -notmatch $($str)" ; 
                    #(Get-Content $item.fullname -EA STOP ) -notmatch $str | Set-Content $item.fullname -EA STOP ;
                    #$newContent = (Get-Content $item.fullname -EA STOP ) -notmatch $str ;
                    $smsg = "Get-Content w`n$(($pltGC|out-string).trim())" ; 
                    #$smsg = "`n`nSet-Content w`n$(($pltSC|out-string).trim())" ;  
                    write-host $smsg ; 
                    $newContent = (Get-Content @pltGC ) -notmatch $str ;
                    if($newContent){
                        #$newContent | Set-Content $item.fullname -EA STOP ;
                        #$smsg = "Get-Content w`n$(($pltGC|out-string).trim())" ; 
                        $smsg = "`n`nSet-Content w`n$(($pltSC|out-string).trim())" ;  
                        write-host $smsg ; 
                        $newContent | Set-Content @pltSC ;
                    } else {
                        $smsg = "NO CONTENT PASSED THROUGH INITIAL FILTER!" ; 
                        write-warning $smsg ; 
                        BREAK ; 
                    } ; 

                    <# nother route: [Using PowerShell to remove lines from a text file if it contains a string - Stack Overflow - stackoverflow.com/](https://stackoverflow.com/questions/24326207/using-powershell-to-remove-lines-from-a-text-file-if-it-contains-a-string)
                    Set-Content -Path "C:\temp\Newtext.txt" -Value (get-content -Path "c:\Temp\Newtext.txt" | Select-String -Pattern 'H\|159' -NotMatch)                
                    # another approach:
                    Get-Content C:\new\temp_*.txt |
                        Where-Object { -not $_.Contains('H|159') } |
                        Set-Content C:\new\newfile.txt
                    #>
                    <#
                    $pltGC=[ordered]@{
                        Path=$item.fullname 
                        erroraction = 'STOP' ;
                    } ;
                    $pltSS=[ordered]@{
                        Pattern = $str ;
                        NotMatch = $true ; 
                        erroraction = 'STOP' ;
                    } ;
                    $pltSC=[ordered]@{
                        Path = $item.fullname ; 
                        erroraction = 'STOP' ;
                        whatif = $($whatif) ;
                    } ;
                    $smsg = "Get-Content w`n$(($pltGC|out-string).trim())" ; 
                    $smsg += "`n`nSelect-String w`n$(($pltSS|out-string).trim())" 
                    $smsg += "`n`nSet-Content w`n$(($pltSC|out-string).trim())" ;  
                    write-host -ForegroundColor green $smsg ; 

                    #Set-Content -Path $item.fullname -EA STOP -whatif:$($whatif) -Value (Get-Content -Path $item.fullname -EA STOP | 
                    #    Select-String -Pattern $str -NotMatch) ; 
                    Set-Content @pltSC -Value (
                        Get-Content @pltGC | Select-String @pltSS 
                    ) ;
                    #>
                } ; 

                # loop remove the following strings:$stockStrings
                foreach($str in $stockStrings){
                    write-verbose "replacing:$($str)" ; 
                    <#(Get-Content $item.fullname ) | Foreach-Object {
                        $_ -replace $str,''
                    } | Set-Content $item.fullname -EA STOP ;
                    #>
                    <#
                    Get-Content @pltGC
                    Set-Content @pltSC 
                    #>
                    #$newContent = (Get-Content $item.fullname -EA STOP ) | Foreach-Object {
                    $smsg = "Get-Content w`n$(($pltGC|out-string).trim())" ; 
                    #$smsg = "`n`nSet-Content w`n$(($pltSC|out-string).trim())" ;  
                    write-host $smsg ; 
                    $newContent = (Get-Content @pltGC ) | Foreach-Object {
                        if($_ -match $str){
                            write-verbose 'bing!'
                        } ; 
                        $_ -replace $str ; 
                    } | out-string ;
                    if($newContent){
                        #$newContent | Set-Content $item.fullname -EA STOP ;
                        #$newContent | Set-Content $item.fullname -EA STOP  -whatif:$($whatif) 
                        #$smsg = "Get-Content w`n$(($pltGC|out-string).trim())" ; 
                        $smsg = "`n`nSet-Content w`n$(($pltSC|out-string).trim())" ;  
                        write-host $smsg ; 
                        $newContent | Set-Content  @pltSC  ;
                    } ; 
                    
                } ; 

                # pull the Losses/Removals: entries with .SideIndicator -eq "<=" (present in left list but not in right)
                $result = (Compare-Object -ReferenceObject (gc $BuFile) -DifferenceObject (gc $item)  ) ;
                write-host "`n`nDiff:Net removals:`n$(($result|?{$_.SideIndicator -eq "<="}|out-string).trim())`n`n" ; 

                write-host "Updates written to:`n$($item.fullname)" ; 
                write-verbose "(returning updated filename to pipeline" ; 

                $item.fullname | write-output ; 
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