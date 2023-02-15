
#*------v Function set-HostIndent v------
function set-HostIndent {
    <#
    .SYNOPSIS
    set-HostIndent - Utility cmdlet that explicitly forces the $env:HostIndentSpaces to a known interval of 4 (or the configured `$PadIncrement)
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : set-HostIndent.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    REVISIONS
    * 2:19 PM 2/15/2023 broadly: moved $PSBoundParameters into test (ensure pop'd before trying to assign it into a new object) ; 
        typo fix, removed [ordered] from hashes (psv2 compat); fixed typo'd alias
    * 2:40 PM 2/2/2023 correct typo: alias pop-hi -> s-hi; 
    * 2:01 PM 2/1/2023 add: -PID param
    * 2:39 PM 1/31/2023 updated to work with $env:HostIndentSpaces in process scope. 
    * 9:50 AM 1/17/2023 All need to be recoded to use evari's, scoped varis aren't consistently discoverable, to have the current 'indent depth' being tweaked by pop|push|reset|set and read by write:
    * 4:39 PM 1/11/2023 init
    .DESCRIPTION
    set-HostIndent - Utility cmdlet that explicitly forces the $env:HostIndentSpaces to a known interval of 4 (or the configured `$PadIncrement)

    If it doesn't find a preexisting $IndentHostSpaces in 'private','local','script','global'
    it throws an error

    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reset-HostIndent # $env:HostIndentSpaces = 0 ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    set-HostIndent # explicit set to multiples of 4
            

    Concept inspired by L5257's printIndent() in his get-DNSspf.ps1 (which ran a simple write-host -nonewline loop, to be run prior to write-host use). 

    .PARAMETER PadIncrement
    Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]
    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .EXAMPLE
    PS> set-HostIndent ;
    PS> $env:HostIndentSpaces ; 
    Simple indented text demo
    .EXAMPLE
    PS>  $domain = 'somedomain.com' ; 
    PS>  write-verbose "Top of code, establish 0 Indent" ;
    PS>  $env:HostIndentSpaces = 0 ;
    PS>  #...
    PS>  # indent & do nested thing
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ; ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  set-HostIndent "Spf Version: $($spfElement)" -verbose ;
    PS>  # nested another level
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ; ;
    PS>  write-verbose "`$env:HostIndentSpaces: += 4 Net:$($env:HostIndentSpaces)" ;
    PS>  set-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ; ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ; ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  set-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    SAMPLEOUTPUT
    DESCRIPTION
    SAMPLEOUTPUT
    DESCRIPTION        
    #>
    [CmdletBinding()]
    [Alias('pop-hi')]
    PARAM(
        [Parameter(Position=0,
            HelpMessage="Number of spaces to set write-hostIndent current indent (`$scop:HostIndentpaces) to.[-Spaces 8]")]
            [int]$Spaces,
        [Parameter(
            HelpMessage="Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]")]
        [int]$PadIncrement = 4,
        [Parameter(
            HelpMessage="Mathematical rounding logic to use for calculating nearest multiple of PadIncrement (RoundUp|RoundDown|AwayFromZero|Midpoint, default:RoundUp)[-Rounding awayfromzero]")]
            [ValidateSet('RoundUp','RoundDown','AwayFromZero','Midpoint')]
            [string]$Rounding = 'RoundUp',
        [Parameter(
            HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
            [switch]$usePID
    ) ;
    BEGIN {
        #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
        # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if(($PSBoundParameters.keys).count -ne 0){
            $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
            write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        } ; 
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

        write-verbose "$($CmdletName): Using `$PadIncrement:`'$($PadIncrement)`'" ; 

        switch($Rounding){
            'RoundUp' {
                # always round up (to next higher multiple)
                $Spaces = ([system.math]::ceiling($Spaces/$PadIncrement))*$PadIncrement  ;
                write-verbose "Rounding:Roundup specified: Rounding to: $($Spaces)" ;
                }
            'RoundDown' {
                # always round down (to next lower multiple)
                $Spaces = ([system.math]::floor($Spaces/$PadIncrement))*$PadIncrement  ;
                write-verbose "Rounding:RoundDown specified: Rounding to: $($Spaces)" ;
                }
            'AwayFromZero' {
                # traditional school: 'when remainder is 5 round up'
                $Spaces = ([system.math]::round($_/$PadIncrement,0,1))*$PadIncrement  ;
                write-verbose "Rounding:AwayFromZero specified: Rounding to: $($Spaces)" ;
            }
            'Midpoint' {
                # default programatic/banker's rounding: if midpoint 5, round to the *nearest even number*'
                $Spaces = ([system.math]::round($_/$PadIncrement))*$PadIncrement  ;
                write-verbose "Rounding:Midpoint specified: Rounding to: $($Spaces)" ;
            }
        } ;

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
        $pltSV=@{
            Path = $HISName ;
            Value = $Spaces;
            Force = $true ;
            erroraction = 'STOP' ;
        } ;
        $smsg = "$($CmdletName): Set 1 lvl:Set-Variable w`n$(($pltSV|out-string).trim())" ;
        write-verbose $smsg  ;
        TRY{
            Set-Item @pltSV #-verbose ;
        } CATCH {
            $smsg = $_.Exception.Message ;
            write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            BREAK ;
        } ;
    } ;  
} ;
#*------^ END Function set-HostIndent ^------
