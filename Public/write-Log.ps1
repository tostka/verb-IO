# 

#region WRITE_LOG ; #*------v write-log v------
#if(-not(gi function:write-log -ea 0)){
    function Write-Log {
            <#
            .SYNOPSIS
            Write-Log.ps1 - Write-Log writes a message to a specified log file with the current time stamp, and write-verbose|warn|error's the matching msg.
            .NOTES
            Version     : 1.0.0
            Author      : Todd Kadrie
            Website     :	http://www.toddomation.com
            Twitter     :	@tostka / http://twitter.com/tostka
            CreatedDate : 2021-06-11
            FileName    : Write-Log.ps1
            License     : MIT License
            Copyright   : (c) 2022 Todd Kadrie
            Github      : https://github.com/tostka/verb-logging
            Tags        : Powershell,Logging,Output,Echo,Console
            AddedCredit : Jason Wasser
            AddedWebsite:	https://www.powershellgallery.com/packages/MrAADAdministration/1.0/Content/Write-Log.ps1
            AddedTwitter:	@wasserja
            REVISIONS
            * 3:12 PM 9/16/2025 add: seamless support for Write-MyVerbose|Write-MyOutput|Write-MyWarning|Write-MyError: where they gcm, divert into those functions, otherwise normal material applies
                Unfortunately write-myOutput lacks -indent support, so we just drop the indents with a wv notice it's dropped, and do the usual write-MyOutput. 
                Also note, I'm expecting the stock 821 write-myOutput has been replaced with my updated write-myOutput(), 
                to suppresse default write-output of the message behavior in the original into the pipeline, blowing the buffer, corrupting function returns. 
                Instead my tweaked write-myOutput() does a normal write-host of the message within the write-myOutput. 
            * 12:27 PM 5/12/2025 SupportsShouldProcess support: added overrid - -whatif:$false -confirm:$false - to new-item & out-file cmds (otherwise, SSP skips logging outputs)
            * 1:42 PM 11/8/2024 CBH expl fixes
            * 10:59 AM 2/17/2023 #529:added workaround for rando 'The variable cannot be validated because the value System.String[] is not a valid value for the Object variable.' err (try catch and strip to text w diff method) suddently seeing NUL char interleave on outputs (C:\usr\work\ps\scripts\logs\monitor-ExecPol-LOG-BATCH-EXEC-log.txt, utf-16/bigendianunicode?), forcing out-file -encoding UTF8
            * 2:11 PM 2/15/2023 buffered over debugs from psv2 ISE color bizaareness. Completely refactored the psise & psv2 color block - have to use wildly inappaprop colors to get anything functional. 
            * 2:26 PM 2/3/2023 combo'd the pair of aliases; added if$indent) around the flatten and split block in PROC (was lost in last move) ; 
                added |out-string).trim to multiline non-indent text coming through, to ensure it's [string] when it gets written.
                 updated CBH, spliced over param help for write-hostindent params prev ported over ; 
                added demo of use of flatten and necessity of |out-string).trim() on formattedobject outputs, prior to using as $object with -Indent ; 
                roughed in attempt at -useHostBackgroundmoved, parked ; 
                added pipeline detect write-verbose ; 
                moved split/flatten into process block (should run per inbound string); added pipeline detect w-v
                fixed bug in pltColors add (check keys contains before trying to add, assign if preexisting)
            * 5:54 PM 2/2/2023 add -flatten, to strip empty lines from -indent auto-splits ; fix pltColors key add clash err; cbh updates, expanded info on new -indent support, added -indent demo
            * 4:20 PM 2/1/2023 added full -indent support; updated CBH w related demos; flipped $Object to [System.Object]$Object (was coercing multiline into single text string); 
                ren $Message -> $Object (aliased prior) splice over from w-hi, and is the param used natively by w-h; refactored/simplified logic prep for w-hi support. Working now with the refactor.
            * 4:47 PM 1/30/2023 tweaked color schemes, renamed splat varis to exactly match levels; added -demo; added Level 'H4','H5', and Success (rounds out the set of banrs I setup in psBnr)
            * 11:38 AM 11/16/2022 moved splats to top, added ISE v2 alt-color options (ISE isn't readable on psv2, by default using w-h etc)
            * 9:07 AM 3/21/2022 added -Level verbose & prompt support, flipped all non-usehost options, but verbose, from w-v -> write-host; added level prefix to console echos
            * 3:11 PM 8/17/2021 added verbose suppress to the get-colorcombo calls, clutters the heck out of outputs on verbose, no benef.
            * 10:53 AM 6/16/2021 get-help isn't displaying param details, pulled erroneous semi's from end of CBH definitions
            * 7:59 AM 6/11/2021 added H1|2|3 md-style #|##|## header tags ; added support for get-colorcombo, and enforced bg colors (legible regardless of local color scheme of console); expanded CBH, revised Author - it's diverged so substantially from JW's original concept, it's now "inspired-by", less than a variant of the original.
            * 10:54 AM 5/7/2021 pulled weird choice to set: $VerbosePreference = 'Continue' , that'd reset pref everytime called
            * 8:46 AM 11/23/2020 ext verbose supp
            * 3:50 PM 3/29/2020 minor tightening layout
            * 11:34 AM 8/26/2019 fixed missing noecho parameter desig in comment help
            * 9:31 AM 2/15/2019:Write-Log: added Level:Debug support, and broader init
                block example with $whatif & $ticket support, added -NoEcho to suppress console
                echos and just use it for writing logged output
            * 8:57 PM 11/25/2018 Write-Log:shifted copy to verb-transcript, added defer to scope $script versions
            * 2:30 PM 10/18/2018 added -useHost to have it issue color-keyed write-host commands vs write-(warn|error|verbose)
                switched timestamp into the function (as $echotime), rather than redundant code in the $Message contstruction.
            * 10:18 AM 10/18/2018 cleanedup, added to pshelp, put into OTB fmt, added trailing semis, parame HelpMessages, and -showdebug param
            * Code simplification and clarification - thanks to @juneb_get_help  ;
            * Added documentation.
            * Renamed LogPath parameter to Path to keep it standard - thanks to @JeffHicks  ;
            * Revised the Force switch to work as it should - thanks to @JeffHicks  ;
            .DESCRIPTION
            Write-Log is intended to provide console write-log echos in addition to commiting text to a log file. 
        
            It was originally based on a concept by Jason Wasser demoed at...
            [](https://gallery.technet.microsoft.com/scriptcenter/Write-Log-PowerShell-999c32d0)
        
            ... of course as is typical that link was subsequently broken by MS over time... [facepalm]
        
            But since that time I have substantially reimplemented jason's code from 
            scratch to implement my evolving concept for the function

            My variant now includes a wide range of Levels, a -useHost parameter 
            that implements a more useful write-host color coded output for console output 
            (vs use of the native write-error write-warning write-verbose cmdlets that 
            don't permit you to differentiate types of output, beyond those three niche 
            standardized formats)
         
            ### I typically use write-host in the following way:
        
            1. I configure a $logfile variable centrally in the host script/function, pointed at a suitable output file. 
            2. I set a [boolean]$logging variable to indicate if a log file is present, and should be written to via write-log 
            or if a simple native output should be used (I also use this for scripts that can use the block below, without access to my hosting verb-io module's copy of write-log).
          3. I then call write-log from an if/then block to feed the message via an $smsg variable.
      
          ```powershell
            $smsg = "" ; 
          if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
          else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
          #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            ```
            ### Hn Levels
        
            The H1..H5 Levels are intended to "somewhat" emulate Markdown's Heading Levels 
            (#,##,###...#####) for output. No it's not native Markdown, but it does provide 
            another layer of visible output demarcation for scanning dense blocks of text 
            from process & analysis code. 
       
            ### Indent support

            Now includes -indent parameter support ported over from my verb-io:write-hostIndent cmdlet
            Native indent support relies on setting the $env:HostIndentSpaces to target indent. 
            Also leverages following verb-io funcs: (life cycle: (init indent); (mod indent); (clear indent e-vari))
            (reset-HostIndent), (push-HostIndent,pop-HostIndent,set-HostIndent), (clear-HostIndent),
        
            Note: Psv2 ISE fundementally mangles and fails to shows these colors properly 
            (you can clearly see it running get-Colornames() from verb-io)

            It appears to just not like writing mixed fg & bg color combos quickly.
            Works fine for writing and logging to file, just don't be surprised 
            when the ISE console output looks like technicolor vomit. 
        
            .PARAMETER Object <System.Object>
            Objects to display in the host.
            .PARAMETER Path
            The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.
            .PARAMETER Level
            Specify the criticality of the log information being written to the log (defaults Info): (Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success)[-level Info]
            .PARAMETER useHost
            Switch to use write-host rather than write-[verbose|warn|error] (does not apply to H1|H2|H3|DEBUG which alt via uncolored write-host) [-useHost]
            .PARAMETER NoEcho
            Switch to suppress console echos (e.g log to file only [-NoEcho]
            .PARAMETER NoClobber
            Use NoClobber if you do not wish to overwrite an existing file.
            .PARAMETER BackgroundColor
            Specifies the background color. There is no default. The acceptable values for this parameter are:
            (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)
            .PARAMETER ForegroundColor <System.ConsoleColor>
            Specifies the text color. There is no default. The acceptable values for this parameter are:
            (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)
            .PARAMETER NoNewline <System.Management.Automation.SwitchParameter>
            The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
            the output strings. No newline is added after the last output string.
            .PARAMETER Separator <System.Object>
            Specifies a separator string to insert between objects displayed by the host.
            .PARAMETER PadChar
            Character to use for padding (defaults to a space).[-PadChar '-']
            .PARAMETER usePID
            Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
            .PARAMETER Indent
            Switch to use write-HostIndent-type code for console echos(see get-help write-HostIndent)[-Indent]
            .PARAMETER Flatten
            Switch to strip empty lines when using -Indent (which auto-splits multiline Objects)[-Flatten]
            .PARAMETER ShowDebug
            Parameter to display Debugging messages [-ShowDebug switch]
            .PARAMETER demo
            Switch to output a demo display of each Level, and it's configured color scheme (requires specification of a 'dummy' message string to avoid an error).[-Demo]
            .EXAMPLE
            PS>  Write-Log -Message 'Log message'   ;
            Writes the message to default log loc (c:\Logs\PowerShellLog.log, -level defaults to Info).
            .EXAMPLE
            PS> Write-Log -Message 'Restarting Server.' -Path c:\Logs\Scriptoutput.log ;
            Writes the content to the specified log file and creates the path and file specified.
            .EXAMPLE
            PS> write-log -level warn "some information" -Path c:\tmp\tmp.txt
            WARNING: 10:17:59: some information
            Demo default use of the native write-warning cmdlet (default behavior when -useHost is not used)
            .EXAMPLE
            PS> write-log -level warn "some information" -Path c:\tmp\tmp.txt -usehost
                10:19:14: WARNING: some information
            Demo use of the "warning" color scheme write-host cmdlet (behavior when -useHost *IS* used)
            .EXAMPLE
            PS> Write-Log -level Prompt -Message "Enter Text:" -Path c:\tmp\tmp.txt -usehost  ;
            PS> invoke-soundcue -type question ;
            PS> $enteredText = read-host ;
            Echo's a distinctive Prompt color scheme for the message (vs using read-host native non-color-differentiating -prompt parameter), and writes a 'Prompt'-level entry to the log, uses my verb-io:invoke-soundCue to play a the system question sound; then uses promptless read-host to take typed input.
            PS> Write-Log -level Prompt -Message "Enter Password:" -Path c:\tmp\tmp.txt -usehost  ;
            PS> invoke-soundcue -type question ;
            PS> $SecurePW = read-host -AsSecureString ;
            Variant that demos collection of a secure password using read-host's native -AsSecureString param.
            .EXAMPLE
            PS>  $smsg = "ENTER CERTIFICATE PFX Password: (use 'dummy' for UserName)" ;
            PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level PROMPT }
            PS>  else{ write-host -foregroundcolor Blue -backgroundcolor White "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            PS>  $pfxcred=(Get-Credential -credential dummy) ;
            PS>  Export-PfxCertificate -Password $pfxcred.password -Cert= $certpath -FilePath c:\path-to\output.pfx;
            Demo use of write-log -level prompt, leveraging the get-credential popup GUI to collect a secure password (without use of username)
            .EXAMPLE
            PS>  # init content in script context ($MyInvocation is blank in function scope)
            PS>  $logfile = join-path -path $ofile -childpath "$([system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName))-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-LOG.txt"  ;
            PS>  $logging = $True ;
            PS>  $sBnr="#*======v `$tmbx:($($Procd)/$($ttl)):$($tmbx) v======" ;
            PS>  $smsg="$($sBnr)" ;
            PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug|H1|H2|H3
            PS>  else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            Demo with conditional write-log (with -useHost switch, to trigger native write-host use), else failthru to write-host output
            PS>  .EXAMPLE
            PS>  $transcript = join-path -path (Split-Path -parent $MyInvocation.MyCommand.Definition) -ChildPath "logs" ;
            PS>  if(!(test-path -path $transcript)){ "Creating missing log dir $($transcript)..." ; mkdir $transcript  ; } ;
            PS>  $transcript=join-path -path $transcript -childpath "$([system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName))"  ;
            PS>  $transcript+= "-Transcript-BATCH-$(get-date -format 'yyyyMMdd-HHmmtt')-trans-log.txt"  ;
            PS>  # add log file variant as target of Write-Log:
            PS>  $logfile=$transcript.replace("-Transcript","-LOG").replace("-trans-log","-log")
            PS>  if($whatif){
            PS>      $logfile=$logfile.replace("-BATCH","-BATCH-WHATIF") ;
            PS>      $transcript=$transcript.replace("-BATCH","-BATCH-WHATIF") ;
            PS>  } else {
            PS>      $logfile=$logfile.replace("-BATCH","-BATCH-EXEC") ;
            PS>      $transcript=$transcript.replace("-BATCH","-BATCH-EXEC") ;
            PS>  } ;
            PS>  if($Ticket){
            PS>      $logfile=$logfile.replace("-BATCH","-$($Ticket)") ;
            PS>      $transcript=$transcript.replace("-BATCH","-$($Ticket)") ;
            PS>  } else {
            PS>      $logfile=$logfile.replace("-BATCH","-nnnnnn") ;
            PS>      $transcript=$transcript.replace("-BATCH","-nnnnnn") ;
            PS>  } ;
            PS>  $logging = $True ;
            PS>  $sBnr="#*======v START PASS:$($ScriptBaseName) v======" ;
            PS>  $smsg= "$($sBnr)" ;
            PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } ; #Error|Warn
            More complete boilerplate including $whatif & $ticket
            .EXAMPLE
            PS>  $pltSL=@{ NoTimeStamp=$false ; Tag = $null ; showdebug=$($showdebug) ; whatif=$($whatif) ; Verbose=$($VerbosePreference -eq 'Continue') ; } ;
            PS>  $pltSL.Tag = "$(split-path -path $CSVPath -leaf)"; # build tag from a variable
            PS>  # construct log name on calling script/function fullname
            PS>  if($PSCommandPath){ $logspec = start-Log -Path $PSCommandPath @pltSL }
            PS>  else { $logspec = start-Log -Path ($MyInvocation.MyCommand.Definition) @pltSL } ;
            PS>  if($logspec){
            PS>      $logging=$logspec.logging ;
            PS>      $logfile=$logspec.logfile ;
            PS>      $transcript=$logspec.transcript ;
            PS>      $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
            PS>      start-Transcript -path $transcript ;
            PS>  } else {throw "Unable to configure logging!" } ;
            PS>  $sBnr="#*======v $(${CmdletName}): v======" ;
            PS>  $smsg = $sBnr ;
            PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            PS>  else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            Demo leveraging splatted start-log(), and either $PSCommandPath or $MyInvocation (support varies by host/psversion) to build the log name.
            .EXAMPLE
            PS> write-log -demo -message 'Dummy' ;
            Demo (using required dummy error-suppressing messasge) of sample outputs/color combos for each Level configured).
            .EXAMPLE
            PS>  $smsg = "`n`n===TESTIPAddress: was *validated* as covered by the recursed ipv4 specification:" ;
            PS>  $smsg += "`n" ;
            PS>  $smsg += "`n---> This host *should be able to* send email on behalf of the configured SPF domain (at least in terms of SPF checks)" ;
            PS>  $env:hostindentspaces = 8 ;
            PS>  $lvl = 'Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success'.split('|') ;
            PS>  foreach ($l in $lvl){Write-Log -LogContent $smsg -Path $tmpfile -Level $l -useHost -Indent} ;
            Demo indent function across range of Levels (alt to native -Demo which also supports -indent).
            .EXAMPLE
            PS>  write-verbose 'set to baseline' ;
            PS>  reset-HostIndent ;
            PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ;
            PS>  write-verbose 'write an H1 banner'
            PS>  $sBnr="#*======v  H1 Banner: v======" ;
            PS>  $smsg = $sBnr ;
            PS>  Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1;
            PS>  write-verbose 'push indent level+1' ;
            PS>  push-HostIndent ;
            PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ;
            PS>  write-verbose 'write an INFO entry with -Indent specified' ;
            PS>  $smsg = "This is information (indented)" ;
            PS>  Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info -Indent:$true ;
            PS>  write-verbose 'push indent level+2' ;
            PS>  push-HostIndent ;
            PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ;
            PS>  write-verbose 'write a PROMPT entry with -Indent specified' ;
            PS>  $smsg = "This is a subset of information (indented)" ;
            PS>  Write-Log -LogContent $smsg -Path $logfile -useHost -Level Prompt -Indent:$true ;
            PS>  write-verbose 'pop indent level out one -1' ;
            PS>  pop-HostIndent ;
            PS>  write-verbose 'write a Success entry with -Indent specified' ;
            PS>  $smsg = "This is a Successful information (indented)" ;
            PS>  Write-Log -LogContent $smsg -Path $logfile -useHost -Level Success -Indent:$true ;
            PS>  write-verbose 'reset to baseline for trailing banner'
            PS>  reset-HostIndent ;
            PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ;
            PS>  write-verbose 'write the trailing H1 banner'
            PS>  $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
            PS>  Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1;
            PS>  write-verbose 'clear indent `$env:HostIndentSpaces' ;
            PS>  clear-HostIndent ;
            PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ;
                $env:HostIndentSpaces:0
                16:16:17: #  #*======v  H1 Banner: v======
                $env:HostIndentSpaces:4
                    16:16:17: INFO:  This is information (indented)
                $env:HostIndentSpaces:8
                        16:16:17: PROMPT:  This is a subset of information (indented)
                    16:16:17: SUCCESS:  This is a Successful information (indented)
                $env:HostIndentSpaces:0
                16:16:17: #  #*======^  H1 Banner: ^======
                $env:HostIndentSpaces:
            Demo broad process for use of verb-HostIndent funcs and write-log with -indent parameter.
            .EXAMPLE
            PS>  write-host "`n`n" ;
            PS>  $smsg = "`n`n==ALL Grouped Status.errorCode :`n$(($EVTS.status.errorCode | group| sort count -des | format-table -auto count,name|out-string).trim())" ;
            PS>  $colors = (get-colorcombo -random) ;
            PS>  if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info -Indent @colors -flatten }
            PS>  else{ write-host @colors  "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            PS>  PS>  write-host "`n`n" ;
            When using -Indent with group'd or other cmd-multiline output, you will want to:
            1. use the...
                $smsg = $(([results]|out-string).trim())"
                ...structure to pre-clean & convert from [FormatEntryData] to [string]
                (avoids errors, due to formatteddata *not* having split mehtod)
            2. Use -flatten to avoid empty _colored_ lines between each entry in the output (and sprinkle write-host "`n`n"'s pre/post for separation).
            These issues only occur under -Indent use, due to the need to `$Object.split to get each line of indented object properly collored and indented.
            .EXAMPLE
            PS> $pltH1=@{foregroundcolor='black';backgroundcolor='darkyellow'};
            PS> write-host "Running demo of current settings..." @pltH1
            PS> $combos = "H1; #*======v STATUSMSG: SBNR v======","H2;`n#*------v PROCESSING : sBnrS v------","H3;`n#*~~~~~~v SUB-PROCESSING : sBnr3 v~~~~~~","H4;`n#*``````v DETAIL : sBnr4 v``````","H5;`n#*______v FOCUS : sBnr5 v______","INFO;This is typical output","PROMPT;What is your quest?","SUCCESS;Successful execution!","WARN;THIS DIDN'T GO AS PLANNED","ERROR;UTTER FAILURE!","VERBOSE;internal comment executed"
            PS> $tmpfile = [System.IO.Path]::GetTempFileName().replace('.tmp','.txt') ;
            PS> foreach($cmbo in $combos){
            PS>     $level,$text = $cmbo.split(';') ;
            PS>     $pltWL=@{
            PS>         message= $text ;
            PS>         Level=$Level ;
            PS>         Path=$tmpfile  ;
            PS>         useHost=$true;
            PS>     } ;
            PS>     if($Indent){$PltWL.add('Indent',$true)} ;
            PS>     $whsmsg = "write-log w`n$(($pltWL|out-string).trim())`n" ;
            PS>     write-host $whsmsg ;
            PS>     write-logNoDep @pltWL ;
            PS> } ;
            PS> remove-item -path $tmpfile ;
            Demo code adapted from the -demo param, for manual passes.
            #>
            [CmdletBinding()]
            PARAM (
                    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true,
                        HelpMessage = "Message is the content that you wish to add to the log file")]
                        [ValidateNotNullOrEmpty()]
                        [Alias("LogContent",'Message')]
                        [System.Object]$Object,
                    [Parameter(Mandatory = $false,
                        HelpMessage = "The path to the log file to which you would like to write. By default the function will create the path and file if it does not exist.")]
                        [Alias('LogPath')]
                        [string]$Path = 'C:\Logs\PowerShellLog.log',
                    [Parameter(Mandatory = $false,
                        HelpMessage = "Specify the criticality of the log information being written to the log (defaults Info): (Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success)[-level Info]")]
                        [ValidateSet('Error','Warn','Info','H1','H2','H3','H4','H5','Debug','Verbose','Prompt','Success')]
                        [string]$Level = "Info",
                    [Parameter(
                        HelpMessage = "Switch to use write-host rather than write-[verbose|warn|error] [-useHost]")]
                        [switch] $useHost,
                    [Parameter(
                        HelpMessage="Specifies the background color. There is no default. The acceptable values for this parameter are:
                (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)")]
                        [System.ConsoleColor]$BackgroundColor,
                    [Parameter(
                        HelpMessage="Specifies the text color. There is no default. The acceptable values for this parameter are:
            (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)")]
                        [System.ConsoleColor]$ForegroundColor,
                    [Parameter(
                        HelpMessage="The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
            the output strings. No newline is added after the last output string.")]
                        [System.Management.Automation.SwitchParameter]$NoNewline,
                    [Parameter(
                        HelpMessage = "Switch to use write-HostIndent-type code for console echos(see get-help write-HostIndent)[-Indent]")]
                        [Alias('in')]
                        [switch] $Indent,
                    [Parameter(
                        HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
                        [switch]$usePID,
                    [Parameter(
                        HelpMessage = "Switch to strip empty lines when using -Indent (which auto-splits multiline Objects)[-Flatten]")]
                        #[Alias('flat')]
                        [switch] $Flatten,
                    [Parameter(
                        HelpMessage="Specifies a separator string to insert between objects displayed by the host.")]
                    [System.Object]$Separator,
                    [Parameter(
                        HelpMessage="Character to use for padding (defaults to a space).[-PadChar '-']")]
                    [string]$PadChar = ' ',
                    [Parameter(
                        HelpMessage="Number of spaces to pad by default (defaults to 4).[-PadIncrment 8]")]
                    [int]$PadIncrment = 4,
                    [Parameter(
                        HelpMessage = "Switch to suppress console echos (e.g log to file only [-NoEcho]")]
                        [switch] $NoEcho,
                    [Parameter(Mandatory = $false,
                        HelpMessage = "Use NoClobber if you do not wish to overwrite an existing file.")]
                        [switch]$NoClobber,
                    [Parameter(
                        HelpMessage = "Debugging Flag [-showDebug]")]
                        [switch] $showDebug,
                    [Parameter(
                        HelpMessage = "Switch to output a demo display of each Level, and it's configured color scheme (requires specification of a 'dummy' message string to avoid an error).[-Demo]")]
                        [switch] $demo
                )  ;
            BEGIN {
                #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
                # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
                ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
                if(($PSBoundParameters.keys).count -ne 0){
                    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
                    write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
                } ; 
                $Verbose = ($VerbosePreference -eq 'Continue') ;     
                # revised verbose detect - Psv7 reportedly doesn't respect:
                $Verbose = ('-Verbose' -in $MyInvocation.UnboundArguments -or $MyInvocation.BoundParameters.ContainsKey('Verbose'))
                #$VerbosePreference = "SilentlyContinue" ;
                #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======
                $pltWH = @{
                        Object = $null ;
                } ;
                if ($PSBoundParameters.ContainsKey('BackgroundColor')) {
                    $pltWH.add('BackgroundColor',$BackgroundColor) ;
                } ;
                if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
                    $pltWH.add('ForegroundColor',$ForegroundColor) ;
                } ;
                if ($PSBoundParameters.ContainsKey('NoNewline')) {
                    $pltWH.add('NoNewline',$NoNewline) ;
                } ;
                if($Indent){
                    if ($PSBoundParameters.ContainsKey('Separator')) {
                        $pltWH.add('Separator',$Separator) ;
                    } ;
                    write-verbose "$($CmdletName): Using `$PadChar:`'$($PadChar)`'" ;

                    #if we want to tune this to a $PID-specific variant, use:
                    if($usePID){
                        $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        $HISName = "Env:HostIndentSpaces$($PID)" ;
                    } else {
                        $HISName = "Env:HostIndentSpaces" ;
                    } ;
                    if(($smsg = Get-Item -Path "Env:HostIndentSpaces$($PID)" -erroraction SilentlyContinue).value){
                        write-verbose $smsg ;
                    } ;
                    if (-not ([int]$CurrIndent = (Get-Item -Path $HISName -erroraction SilentlyContinue).Value ) ){
                        [int]$CurrIndent = 0 ;
                    } ;
                    write-verbose "$($CmdletName): Discovered `$$($HISName):$($CurrIndent)" ;
                } ;
                if(get-command get-colorcombo -ErrorAction SilentlyContinue){$buseCC=$true} else {$buseCC=$false} ;
           
                if ($host.Name -eq 'Windows PowerShell ISE Host' -AND $host.version.major -lt 3){
                        write-verbose "PSISE under psV2 has wacky inconsistent colors - only *some* even display, others default to white`nso we choose fundementally wrong colors, to approximate the target colors" ;
                        $pltError=@{foregroundcolor='DarkYellow';backgroundcolor='Red'};
                        $pltWarn=@{foregroundcolor='DarkMagenta';backgroundcolor='DarkCyan'};
                        $pltInfo=@{foregroundcolor='Blue';backgroundcolor='darkGreen'};
                        $pltH1=@{foregroundcolor='black';backgroundcolor='darkyellow'};
                        $pltH2=@{foregroundcolor='darkblue';backgroundcolor='cyan'};
                        $pltH3=@{foregroundcolor='black';backgroundcolor='cyan'};
                        $pltH4=@{foregroundcolor='black';backgroundcolor='DarkMagenta'};
                        $pltH5=@{foregroundcolor='cyan';backgroundcolor='Green'};
                        $pltDebug=@{foregroundcolor='red';backgroundcolor='black'};
                        $pltVerbose=@{foregroundcolor='darkgray';backgroundcolor='darkred'};
                        $pltPrompt=@{foregroundcolor='White';backgroundcolor='DarkBlue'};
                        $pltSuccess=@{foregroundcolor='DarkGray';backgroundcolor='green'};
                } else {
                    $pltError=@{foregroundcolor='yellow';backgroundcolor='darkred'};
                    $pltWarn=@{foregroundcolor='DarkMagenta';backgroundcolor='yellow'};
                    $pltInfo=@{foregroundcolor='gray';backgroundcolor='darkblue'};
                    $pltH1=@{foregroundcolor='black';backgroundcolor='darkyellow'};
                    $pltH2=@{foregroundcolor='darkblue';backgroundcolor='gray'};
                    $pltH3=@{foregroundcolor='black';backgroundcolor='darkgray'};
                    $pltH4=@{foregroundcolor='gray';backgroundcolor='DarkCyan'};
                    $pltH5=@{foregroundcolor='cyan';backgroundcolor='DarkGreen'};
                    $pltDebug=@{foregroundcolor='red';backgroundcolor='black'};
                    $pltVerbose=@{foregroundcolor='darkgray';backgroundcolor='black'};
                    $pltPrompt=@{foregroundcolor='DarkMagenta';backgroundcolor='darkyellow'};
                    $pltSuccess=@{foregroundcolor='Blue';backgroundcolor='green'};
                } ; 

                if ($PSCmdlet.MyInvocation.ExpectingInput) {
                    write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
                } else {
                    #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
                    write-verbose "(non-pipeline - param - input)" ; 
                } ; 
            }  ;
            PROCESS {
                if($Demo){
                        write-host "Running demo of current settings..." @pltH1
                        $combos = "h1m;H1","h2m;H2","h3m;H3","h4m;H4","h5m;H5",
                            "whm;INFO","whp;PROMPT","whs;SUCCESS","whw;WARN","wem;ERROR","whv;VERBOSE" ;
                        $h1m =" #*======v STATUSMSG: SBNR v======" ;
                        $h2m = "`n#*------v PROCESSING : sBnrS v------" ;
                        $h3m ="`n#*~~~~~~v SUB-PROCESSING : sBnr3 v~~~~~~" ;
                        $h4m="`n#*``````v DETAIL : sBnr4 v``````" ;
                        $h5m="`n#*______v FOCUS : sBnr5 v______" ;
                        $whm = "This is typical output" ;
                        $whp = "What is your quest?" ;
                        $whs = "Successful execution!" ;
                        $whw = "THIS DIDN'T GO AS PLANNED" ;
                        $wem = "UTTER FAILURE!" ;
                        $whv = "internal comment executed" ;
                        $tmpfile = [System.IO.Path]::GetTempFileName().replace('.tmp','.txt') ;
                        foreach($cmbo in $combos){
                            $txt,$name = $cmbo.split(';') ;
                            $Level = $name ;
                            if($Level -eq 'H5'){
                                write-host "Gotcha!";
                            } ;
                            $whplt = (gv "plt$($name)").value ;
                            $text = (gv $txt).value ;
                            #$smsg="`$plt$($name):($($whplt.foregroundcolor):$($whplt.backgroundcolor)):`n`n$($text)`n`n" ;
                            $whsmsg="`$plt$($name):($($whplt.foregroundcolor):$($whplt.backgroundcolor)):`n`n" ;
                            $pltWL=@{
                                message= $text ;
                                Level=$Level ;
                                Path=$tmpfile  ;
                                useHost=$true;
                            } ;
                            if($Indent){$PltWL.add('Indent',$true)} ;
                            $whsmsg += "write-log w`n$(($pltWL|out-string).trim())`n" ;
                            write-host $whsmsg ;
                            write-log @pltWL ;
                        } ;
                        remove-item -path $tmpfile ;
                } else {

                    if($Indent){
                        # move split/flatten into per-object level (was up in BEGIN):
                        # if $object has multiple lines, split it:
                        # have to coerce the system.object to string array, to get access to a .split method (raw object doese't have it)
                        # and you have to recast the type to string array (can't assign a string[] to [system.object] type vari
                        if($Flatten){
                                if($object.gettype().name -eq 'FormatEntryData'){
                                    # this converts tostring() as the string: Microsoft.PowerShell.Commands.Internal.Format.FormatEntryData
                                    # issue is (group |  ft -a count,name)'s  that aren't put through $((|out-string).trim())
                                    write-verbose "skip split/flatten on these (should be pre-out-string'd before write-logging)" ;
                                } else {
                                    TRY{
                                        [string[]]$Object = [string[]]$Object.ToString().Split([Environment]::NewLine) ; 
                                    } CATCH{
                                        write-verbose "Workaround err: The variable cannot be validated because the value System.String[] is not a valid value for the Object variable." ; 
                                        [string[]]$Object = ($Object|out-string).trim().Split([Environment]::NewLine) ; 
                                    } ; 
                                } ;
                        } else {
                            [string[]]$Object = [string[]]$Object.ToString().Split([Environment]::NewLine)
                        } ;
                    } ; 

                    # If the file already exists and NoClobber was specified, do not write to the log.
                    if ((Test-Path $Path) -AND $NoClobber) {
                        Write-Error "Log file $Path already exists, and you specified NoClobber. Either delete the file or specify a different name."  ;
                        Return  ;
                    } elseif (!(Test-Path $Path)) {
                        Write-Verbose "Creating $Path."  ;
                        $NewLogFile = New-Item $Path -Force -ItemType File -whatif:$false -confirm:$false ;
                    } else {
                      # Nothing to see here yet.
                    }  ;

                    $FormattedDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"  ;
                    $EchoTime = "$((get-date).ToString('HH:mm:ss')): " ;

                    $pltWH.Object = $EchoTime ; 
                    $pltColors = @{} ; 
                    # Write message to error, warning, or verbose pipeline and specify $LevelText
                    # add seamless support for Write-MyVerbose|Write-MyOutput|Write-MyWarning|Write-MyError
                    switch ($Level) {
                        'Error' {
                            $LevelText = 'ERROR: ' ;
                            $pltColors = $pltError ;
                            #if ($useHost) {} else {if (-not $NoEcho) { Write-Error ($smsg + $Object) } } ;                            
                            if(get-command Write-MyError -ea 0){
                                Write-MyError $Object 
                            } elseif ($useHost) {} else {if (-not $NoEcho) { Write-Error ($smsg + $Object) } } ;                    
                        }
                        'Warn' {
                            $LevelText = 'WARNING: ' ;
                            $pltColors = $pltWarn ;
                            #if ($useHost) {} else {if (-not $NoEcho) { Write-Warning ($smsg + $Object) } } ;
                            if(get-command Write-MyWarning -ea 0){
                                Write-MyWarning $Object 
                            } elseif ($useHost) {} else {if (-not $NoEcho) { Write-Warning ($smsg + $Object) } } ;
                        }
                        'Info' {
                            $LevelText = 'INFO: ' ;
                            $pltColors = $pltInfo ;
                        }
                        'H1' {
                            $LevelText = '# ' ;
                            $pltColors = $pltH1 ;
                        }
                        'H2' {
                            $LevelText = '## ' ;
                            $pltColors = $pltH2 ;
                        }
                        'H3' {
                            $LevelText = '### ' ;
                            $pltColors = $pltH3 ;
                        }
                        'H4' {
                            $LevelText = '#### ' ;
                            $pltColors = $pltH4 ;
                        }
                        'H5' {
                            $LevelText = '##### ' ;
                            $pltColors = $pltH5 ;
                        }
                        'Debug' {
                            $LevelText = 'DEBUG: ' ;
                            $pltColors = $pltDebug ;
                            #if ($useHost) {} else {if (-not $NoEcho) { Write-Degug $smsg } }  ;
                            if(get-command Write-MyWarning -ea 0){} elseif ($useHost) {} else {if (-not $NoEcho) { Write-Degug $smsg } }  ;
                        }
                        'Verbose' {
                            $LevelText = 'VERBOSE: ' ;
                            $pltColors = $pltVerbose ;
                            #if ($useHost) {}else {if (-not $NoEcho) { Write-Verbose ($smsg) } } ;
                            if(get-command Write-MyVerbose -ea 0){
                                Write-MyVerbose $Object 
                            } elseif ($useHost) {}else {if (-not $NoEcho) { Write-Verbose ($smsg) } } ;
                        }
                        'Prompt' {
                            $LevelText = 'PROMPT: ' ;
                            $pltColors = $pltPrompt ;
                        }
                        'Success' {
                            $LevelText = 'SUCCESS: ' ;
                            $pltColors = $pltSuccess ;
                        }
                    } ;
                    # build msg string down here, once, v in ea above
                    # always defer to explicit cmdline colors
                    if($pltColors.foregroundcolor){
                        if(-not ($pltWH.keys -contains 'foregroundcolor')){
                            $pltWH.add('foregroundcolor',$pltColors.foregroundcolor) ;
                        } elseif($pltWH.foregroundcolor -eq $null){
                            $pltWH.foregroundcolor = $pltColors.foregroundcolor ;
                        } ;
                    } ;
                    if($pltColors.backgroundcolor){
                        if(-not ($pltWH.keys -contains 'backgroundcolor')){
                            $pltWH.add('backgroundcolor',$pltColors.backgroundcolor) ;
                        } elseif($pltWH.backgroundcolor -eq $null){
                            $pltWH.backgroundcolor = $pltColors.backgroundcolor ;
                        } ;
                    } ;

                    if ($useHost) {
                        if(-not $Indent){
                            if($Level -match '(Debug|Verbose)' ){
                                if(($Object|  measure).count -gt 1){
                                    $pltWH.Object += "$($LevelText) ($(($Object|out-string).trim()))" ;
                                } else {
                                    #$pltWH.Object += ($LevelText + '(' + $Object + ')') ;
                                    $pltWH.Object += "$($LevelText) ($($Object))" ;
                                } ;
                            } else {
                                if(($Object|  measure).count -gt 1){
                                    $pltWH.Object += "$($LevelText) $(($Object|out-string).trim())" ;
                                } else {
                                    #$pltWH.Object += $LevelText + $Object ;
                                    $pltWH.Object += "$($LevelText) $($Object)" ;
                                } ;
                            } ;
                            $smsg = "write-host w`n$(($pltWH|out-string).trim())" ;
                            write-verbose $smsg ;
                            #write-host @pltErr $smsg ;
                            #write-host @pltwh ;
                            if(get-command Write-MyOutput -ea 0){
                                Write-MyOutput $pltWH.Object  
                            } else { write-host @pltwh } ;

                        } else {
                            foreach ($obj in $object){
                                $pltWH.Object = $EchoTime ;
                                if($Level -match '(Debug|Verbose)' ){
                                    if($obj.length -gt 0){
                                        $pltWH.Object += "$($LevelText) ($($obj))" ;
                                    } else {
                                        $pltWH.Object += "$($LevelText)" ;
                                    } ;
                                } else {
                                    $pltWH.Object += "$($LevelText) $($obj)" ;
                                } ;
                                $smsg = "write-host w`n$(($pltWH|out-string).trim())" ;
                                write-verbose $smsg ;
                                #Write-Host -NoNewline $($PadChar * $CurrIndent)  ;
                                #write-host @pltwh ;
                                if(get-command Write-MyOutput -ea 0){
                                    write-verbose "(-indent specified with write-myOutput avail: suppressing indent support)" ; 
                                    Write-MyOutput $pltWH.Object  
                                } else { 
                                    Write-Host -NoNewline $($PadChar * $CurrIndent)  ;
                                    write-host @pltwh ;
                                } ;
                            } ;
                        } ;
                    }
                    # Write log entry to $Path                    
                    #"$FormattedDate $LevelText : $Object" | Out-File -FilePath $Path -Append -encoding UTF8 -whatif:$false -confirm:$false;
                    # add support to divert into write-my* (which have their own logging output)
                    if(get-command Write-MyOutput -ea 0){}elseif(get-command Write-MyWarning -ea 0){}elseif(get-command Write-MyError -ea 0){}elseif(get-command Write-MyVerbose -ea 0){}else{
                        "$FormattedDate $LevelText : $Object" | Out-File -FilePath $Path -Append -encoding UTF8 -whatif:$false -confirm:$false;
                    } ; 
                } ;  # if-E -Demo ; 
            }  ; # PROC-E
            END {}  ;
        }
#} ; 
#endregion WRITE_LOG ; #*------^ END write-log  ^------