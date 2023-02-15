
#*------v Function write-HostIndent v------
function write-HostIndent {
    <#
    .SYNOPSIS
    write-HostIndent - write-host wrapper that adds a stock $env:HostIndentSpaces to the left of each line of text sent (splits lines prior to indenting
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : write-HostIndent.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 2:19 PM 2/15/2023 broadly: moved $PSBoundParameters into test (ensure pop'd before trying to assign it into a new object) ; 
        typo fix, removed [ordered] from hashes (psv2 compat); 
    * 3:02 PM 2/2/2023 rolled back overwrite with w-l() code ; updated CBH
    * 2:01 PM 2/1/2023 add: -PID param
    * 2:39 PM 1/31/2023 updated to work with $env:HostIndentSpaces in process scope.
    * 9:50 AM 1/17/2023 All need to be recoded to use evari's, scoped varis aren't consistently discoverable, to have the current 'indent depth' being tweaked by pop|push|reset|set and read by write:
    * 11:50 AM 1/11/2023 ren $indentNum -> $HostIndentSpaces -> $env:HostIndentSpaces
    * 4:15 PM 1/10/2023 ren printIndent -> write-HostIndent ; expanded CBH example, Heart of this is in the example, not the simple write-host loop; 
        added to verb-io.
    * 2:06 PM 1/9/2023 add: CBH, $indentname driving this is is a parent funciton variable, tweak it on the fly to move cursor left or right.
    .DESCRIPTION

    write-HostIndent - write-host wrapper that adds a stock $env:HostIndentSpaces to the left of each line of text sent (splits lines prior to indenting

    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reset-HostIndent # $env:HostIndentSpaces = 0 ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    set-HostIndent # explicit set to multiples of 4
            
    .PARAMETER BackgroundColor
    Specifies the background color. There is no default. The acceptable values for this parameter are:
    (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)
    .PARAMETER ForegroundColor <System.ConsoleColor>
    Specifies the text color. There is no default. The acceptable values for this parameter are:
    (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)
    .PARAMETER NoNewline <System.Management.Automation.SwitchParameter>
    The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
    the output strings. No newline is added after the last output string.
    .PARAMETER Object <System.Object>
    Objects to display in the host.
    .PARAMETER Separator <System.Object>
    Specifies a separator string to insert between objects displayed by the host.
    .PARAMETER PadChar
    Character to use for padding (defaults to a space).[-PadChar '-']
    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .EXAMPLE
    PS> $env:HostIndentSpaces = 4 ; 
    PS> write-HostIndent 'indented message'
    Simple indented text demo
    .EXAMPLE
    PS>  write-verbose 'set to baseline' ; 
    PS>  reset-HostIndent ; 
    PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
    PS>  write-verbose 'write an H1 banner'
    PS>  $sBnr="#*======v  H1 Banner: v======" ;
    PS>  $smsg = $sBnr ;
    PS>  Write-HostIndent -ForegroundColor yellow $smsg ;
    PS>  write-verbose 'push indent level+1' ; 
    PS>  push-HostIndent ; 
    PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
    PS>  $smsg = "This is information (indented)" ; 
    PS>  Write-HostIndent -ForegroundColor Gray $smsg ;
    PS>  write-verbose 'push indent level+2' ; 
    PS>  push-HostIndent ; 
    PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
    PS>  write-verbose 'write a PROMPT entry with -Indent specified' ; 
    PS>  $smsg = "This is a subset of information (indented)" ; 
    PS>  Write-HostIndent -ForegroundColor Gray $smsg ;
    PS>  write-verbose 'pop indent level out one -1' ; 
    PS>  pop-HostIndent ; 
    PS>  write-verbose 'write a Success entry with -Indent specified' ; 
    PS>  $smsg = "This is a Successful information (indented)" ; 
    PS>  PS>  Write-HostIndent -ForegroundColor green $smsg ; ;
    PS>  write-verbose 'reset to baseline for trailing banner'
    PS>  reset-HostIndent ; 
    PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
    PS>  write-verbose 'write the trailing H1 banner'
    PS>  $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
    PS>  Write-HostIndent -ForegroundColor yellow $smsg ;
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
    PS>  $domain = 'somedomain.com' ; 
    PS>  write-verbose "Top of code, establish 0 Indent" ;
    PS>  $env:HostIndentSpaces = 0 ;
    PS>  #...
    PS>  # indent & do nested thing
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  Write-HostIndent "Spf Version: $($spfElement)" -verbose ;
    PS>  # nested another level
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: += 4 Net:$($env:HostIndentSpaces)" ;
    PS>  Write-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  Write-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
                Spf Version:
                    (somedomain.com)
            (somedomain.com)            
    Demo push/popping $env:HostIndentSpaces and using write-hostIndent
    #>
    [CmdletBinding()]
    [Alias('w-hi')]
    PARAM(
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
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
            HelpMessage="Objects to display in the host")]
            [System.Object]$Object,
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
            HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
            [switch]$usePID
    ) ; 
    BEGIN {
        #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if(($PSBoundParameters.keys).count -ne 0){
            $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
            write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        } ; 
        $Verbose = ($VerbosePreference -eq 'Continue') ;   
        #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

        $pltWH = @{} ; 
        if ($PSBoundParameters.ContainsKey('BackgroundColor')) {
            $pltWH.add('BackgroundColor',$BackgroundColor) ; 
        } ;
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
            $pltWH.add('ForegroundColor',$ForegroundColor) ; 
        } ;
        if ($PSBoundParameters.ContainsKey('NoNewline')) {
            $pltWH.add('NoNewline',$NoNewline) ; 
        } ;
        if ($PSBoundParameters.ContainsKey('Separator')) {
            $pltWH.add('Separator',$Separator) ; 
        } ;
        write-verbose "$($CmdletName): Using `$PadChar:`'$($PadChar)`'" ; 

        #if we want to tune this to a $PID-specific variant, use:
        if($usePID){
            $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
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

        <# some methods to left pad console output: Most add padding within the obj written by write- host: youend up with a big block of color, if you use fore/back w w-h:

            [Indentation the Write-host output in Powershell - Stack Overflow - stackoverflow.com/](https://stackoverflow.com/questions/70895830/indentation-the-write-host-output-in-powershell)
                    
            $padding = "       "
            'test', 'test', 'test' | ForEach-Object { Write-Host ${padding}$_ }

            $padding = ' ' * 20; $padding + ('test', 'test', 'test' -join "`r`n$padding")

            'test', 'test', 'test' | ForEach-Object { $_.PadLeft(20) }

            'test', 'test', 'test' | ForEach-Object { '{0,10}' -f $_ }
            # OR
            'test', 'test', 'test' | ForEach-Object { [string]::Format('{0,10}', $_) }

            'test', 'test', 'test' | ForEach-Object { $_ -replace '^', (' ' * 20) }

            'test', 'test', 'test' -replace '(?m)^(.{0,20})',{" " * (20 - $_.Length) + $_.Groups[0].Value}

            Trick is, you want to use non-color w-h -nonewline, the number of indent spaces you need
            And then you write-host with colors etc specd.
        #>

        # if $object has multiple lines, split it:
        $Object = $Object.Split([Environment]::NewLine) ; 
                
        <# Issue with most above: if you use:
        $padding = "-" * 4 ; # to *see* the spaces
        $whdgy = @{ 'BackgroundColor' = 'Yellow' 'ForegroundColor' = 'DarkGreen' }; 
        $smsg.Split([Environment]::NewLine) | %{write-host -obj ${padding}$_ @whdgy}
        ```
        Output:
        ----Fail on prior TXT qry
        ----Retrying TXT qry:-Name .
        ----Resolve-DnsName -Type TXT -Name 
            you get highlights/color the *entire length of the line*, including the whitespace, padchars
            #>

        # you need to do the w-h -nonewline separately, before using w-h per line of object, with colors:
        <# works, even recog's muiltiline object outputs and splits them at the lines, indenting them cleanly.
        foreach ($obj in $object){
            for ($n=0; $n -lt [int]$env:HostIndentSpaces; $n++) {
		        Write-Host -NoNewline $PadChar ; 
	        } ; 
            write-host @pltWH -object $obj ; 
        } ; 
        #>
        # works, is equiv to the above, just collapses down the silly -nonewline loop
        foreach ($obj in $object){
            Write-Host -NoNewline $($PadChar * $CurrIndent)  ; 
            write-host @pltWH -object $obj ; 
        } ; 
    } ;  # BEG-E
} ; 
#*------^ END Function write-HostIndent ^------
