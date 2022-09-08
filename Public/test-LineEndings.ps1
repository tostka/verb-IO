
#*------v Function test-LineEndings v------
function test-LineEndings {
    <#
    .SYNOPSIS
    test-LineEndings.ps1 - Test path/file specified for inconsistent or 'mixed' LineEndings (suppress Pester complaints; general good idea).
    .NOTES
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2022-09-08
    FileName    : test-LineEndings.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : File,LineEndings
    Additional Credits:
    AddedCredit : JasonMArcher (simple native PS EOL detect code)
    AddedWebsite: https://stackoverflow.com/users/64046/jasonmarcher
    AddedTwitter: 
    AddedCredit : phuclv (coerce EOL to CrLf sample code)
    AddedWebsite: https://superuser.com/users/241386/phuclv
    AddedTwitter: 
    REVISIONS   :
    1:20 PM 9/8/2022 expanded CBH examples suppresed noise outputs to w-v, only 
        echos normally are w-w for mixed EOL files; revision to simple JasonMArcher 
        sample: added CBH; swapped echo -> write-host; dumped tee output (declutters), 
        simplified output, built in full function with pipeline path/file looping support.
    * 3/20/22 phuclv pointed out that get-content|set-content autocleans & sample posted in StackEdit response 
    * 4/7/2209 JasonMArcher sample code scrap in stackoverflow response.
    .DESCRIPTION
    test-LineEndings.ps1 - Test path/file specified for inconsistent or 'mixed' LineEndings (suppress Pester complaints; general good idea)

    Examples demo use of get-content|Set-Content to coerce line endings to CrLf 
    underlying mechanism: get-content splits on \n (& drops any existing \r) and set-content always writes \r\n as each EOL (including trailing line of file, if not already set).
    
    Pester has been twigging on mixed/inconsistent EOLs in files. So I wrote this to quickly eval & coerce them into shape (with the fix as a followup cmdblock in the examples).
    
    Examining mixed tagged files, I can see they're turning up as EOL on Example PS> code (other than the last trailing ps line of the block, which has CRLF): likely byproduct of my codeblock -> example conversion script? 
    Yup it was in convertTo-PSHelpExample(), was writing scriptblock EOL as `n, rather than `r`n. Still should check for issue across all files.

    .PARAMETER Path
    Specifies the path or paths to the files that you want to test. To specify multiple paths, and include files in multiple locations, use commas to separate the paths. [-Path c:\path-to\file.ext,c:\pathto\file2.ext]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    write-warning to console for mixed CrLf (use verbose for echo on all tested files)
    Returns fullname value for each mixed/inconsistent EOL file, to pipeline.
    .EXAMPLE
    PS> $mixedcrlf = test-LineEndings -path 'c:\tmp\20170411-0706AM.ps1','c:\tmp\24SbP1B9.ics' -verbose  ;
    PS> $mixedcrlf | %{
    PS>     write-host "==Fix LineEndings $($_)" ; 
    PS>     $content = Get-Content $_ ; 
    PS>     $content | Set-Content -Path $_ -encoding UTF8 -EA STOP -whatif ; 
    PS> } ; 
    Check array of files for mixed CRLF EOLs. Then run mixed returned, through process to output consistent CrLf lineendings (-remove whatif to execute).
    .EXAMPLE
    PS> $mixedcrlf = test-LineEndings -path 'c:\sc\verb-io\public\' -verbose  ;
    PS> $mixedcrlf | %{
    PS>     write-host "==Fix LineEndings $($_)" ; 
    PS>     $content = Get-Content $_ ; 
    PS>     $content | Set-Content -Path $_ -encoding UTF8 -EA STOP -whatif ; 
    PS> } ; 
    Check a folder path (auto-recursed into files), with followup fix.
    .EXAMPLE
    PS> $mixedcrlf = gci c:\sc\verb-dev\public\*  | select -expand fullname | test-lineendings -verbose ; 
    PS> $mixedcrlf | %{
    PS>     write-host "==Fix LineEndings $($_)" ; 
    PS>     $content = Get-Content $_ ; 
    PS>     $content | Set-Content -Path $_ -encoding UTF8 -EA STOP -whatif ; 
    PS> } ; 
    Pipeline demo with followup fix.
    PS> $mixedcrlf = c:\sc\verb-*\public | select -expand path | test-lineendings -verbose ;
        WARNING: ==>C:\sc\verb-IO\Public\test-LineEndings.ps1:has:MIXED CRLF eolS
    PS> $mixedcrlf |?{$_ -notlike '*-log.txt'} | %{
    PS>     write-host "==Fix LineEndings $($_)" ; 
    PS>     $content = Get-Content $_ ; 
    PS>     $content | Set-Content -Path $_ -encoding UTF8 -EA STOP -whatif ; 
    PS> } ;  
    Demo running against entire module set source Public subdirs, with postfiltered results to exclude logs, and trailing fix
    .LINK
    https://superuser.com/questions/460169/is-there-a-way-to-quickly-identify-files-with-windows-or-unix-line-termination
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('Compress-ZipFile')]
    Param(
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True,HelpMessage = "Specifies the path or paths to the files that you want to add to the archive zipped file. To specify multiple paths, and include files in multiple locations, use commas to separate the paths. If a simple folder path is specified, the child files will be recursively checked[-Path c:\path-to\file.ext,c:\pathto\file2.ext]")]
        [ValidateScript( { Test-Path $_ })]
        [Alias('File')]
        [string[]]$Path,
        [Parameter(HelpMessage = "Regular Expression to be used to filter child files when a simple folder path is specified as -Path (defaults to ^\.(TXT|MD|PS1|PSD1|JSON|XML|PSXML|PSM1|CLASS|VBS|CMD|BAT|PY|AHK)$)[-RegexFileExtensions '^\.(TXT|MD|PS1|PSD1|JSON|XML|PSM1|CLASS|VBS|CMD|BAT|PY|AHK)$']")]
        [regex]$RegexFileExtensions = '^\.(TXT|MD|PS1|PSD1|JSON|XML|PSXML|PSM1|CLASS|VBS|CMD|BAT|PY|AHK)$'  
    ) ; 
    BEGIN { 
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 
        $bMixedFound = $false 
    } ;  # BEGIN-E
    PROCESS {
        $Error.Clear() ; 
                
        foreach ($item in $Path){
            write-verbose "==$($item):" ; 
            TRY{
                if(test-path $item -pathtype Container){
                    write-host -foregroundcolor green "Container Path specified, recursing and post-filtering for extensions matching regex:`n$($RegexFileExtensions)" ; 
                    $item = get-childitem -recurse -path $item | ?{$_.extension.toUpper() -match $RegexFileExtensions} ; 
                    write-host -foregroundcolor green "(#Matches returned:$(((($item|measure).count)|out-string).trim()))" ; 
                } else {
                    write-verbose "gci non-container obj" ; 
                    $item = gci $item ; 
                }  ; 
                foreach($f in $item){
                    write-verbose "==$($f.fullname):" ; 
                    $content = Get-Content -Raw $f.fullname ; 
                    $newlines = [regex]::Matches($content, "\r?\n") | Group-Object -Property Length ;
                    if ($newlines.Length -eq 2) {
                        $bMixedFound = $true ; 
                        write-WARNING "==>$($f.fullname):has:MIXED CRLF eolS" ; 
                        $f.fullname | write-output ; 
                    } else {
                        if ($newlines[0].Group[0].Value.Length -eq 2) {
                            write-verbose  "==>$($f.fullname):has:CRLF eolS" ; 
                        } else {
                            write-verbose  "==>$($f.fullname):has:LF eolS" ; 
                        } ; 
                    } ; 
                } ; 
            }CATCH{
                Write-Warning -Message $_.Exception.Message ; 
            } ; 
               
        } ;  # loop-E
    }  # if-E PROC
    END{
        if($bMixedFound){
            write-warning "Mixed LineEnd (CR|LF) found within files! Each pathed file has been returned to the pipeline (for post-processing)" ; 
        } ; 
        write-verbose "Processing ended" ; 
    } ; 
} ; 
#*------^ END Function  ^------
