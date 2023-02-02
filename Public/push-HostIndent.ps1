
#*------v Function push-HostIndent v------
function push-HostIndent {
    <#
    .SYNOPSIS
    push-HostIndent - Utility cmdlet that increments/pushes the $env:HostIndentSpaces by 4 (or the configured `$PadIncrement)
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : push-HostIndent.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 2:01 PM 2/1/2023 add: -PID param
    * 2:39 PM 1/31/2023 updated to work with $env:HostIndentSpaces in process scope. 
    * 9:50 AM 1/17/2023 All need to be recoded to use evari's, scoped varis aren't consistently discoverable, to have the current 'indent depth' being tweaked by pop|push|reset|set and read by write:
    * 4:39 PM 1/11/2023 init
    .DESCRIPTION
    push-HostIndent - Utility cmdlet that increments/pushes the $env:HostIndentSpaces by 4 (or the configured `$PadIncrement)

    If it doesn't find a preexisting $IndentHostSpaces in 'private','local','script','global'
    it throws an error

    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reset-HostIndent # $env:HostIndentSpaces = 0 ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    set-HostIndent # explicit set to multiples of 4
            
    .PARAMETER PadIncrement
    Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]
    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .EXAMPLE
    PS> push-HostIndent ;
    PS> $env:HostIndentSpaces ; 
    Simple indented text demo
    .EXAMPLE
    PS>  $domain = 'somedomain.com' ; 
    PS>  write-verbose "Top of code, establish 0 Indent" ;
    PS>  $env:HostIndentSpaces = 0 ;
    PS>  #...
    PS>  # indent & do nested thing
    PS>  $env:HostIndentSpaces += 4 ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  push-HostIndent "Spf Version: $($spfElement)" -verbose ;
    PS>  # nested another level
    PS>  $env:HostIndentSpaces += 4 ;
    PS>  write-verbose "`$env:HostIndentSpaces: += 4 Net:$($env:HostIndentSpaces)" ;
    PS>  push-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces -= 4 ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces -= 4 ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  push-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    SAMPLEOUTPUT
    DESCRIPTION
    SAMPLEOUTPUT
    DESCRIPTION        
    #>
    [CmdletBinding()]
    [Alias('push-hi')]
    PARAM(
        [Parameter(
            HelpMessage="Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]")]
        [int]$PadIncrement = 4,
        [Parameter(
            HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
            [switch]$usePID
    ) ; 
    BEGIN {
        #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
        # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;     
        #$VerbosePreference = "SilentlyContinue" ;
        #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

        write-verbose "$($CmdletName): Using `$PadIncrement:`'$($PadIncrement)`'" ; 

        #if we want to tune this to a $PID-specific variant, could use:
        if($usePID){
            $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            $HISName = "Env:HostIndentSpaces$($PID)" ;
        } else {
            $HISName = "Env:HostIndentSpaces" ;
        } ;
        #(Get-Item -Path "$HISName$($PID)" -erroraction SilentlyContinue).value

        if (-not ([int]$CurrIndent = (Get-Item -Path $HISName -erroraction SilentlyContinue).Value ) ){
            [int]$CurrIndent = 0 ; 
        } ; 
        write-verbose "$($CmdletName): Discovered `$$($HISName):$($CurrIndent)" ; 
        $pltSV=[ordered]@{
            Path = $HISName ;  
            Value = [int](Get-Item -Path $HISName -erroraction SilentlyContinue).Value + $PadIncrement; 
            Force = $true ; 
            erroraction = 'STOP' ;
        } ;
        $smsg = "$($CmdletName): Set 1 lvl:Set-Variable w`n$(($pltSV|out-string).trim())" ; 
        write-verbose $smsg  ;
        TRY{
            #Set-Variable @pltSV -verbose ; 
            Set-Item @pltSV #-verbose ; 
        } CATCH {
            $smsg = $_.Exception.Message ;
            write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            BREAK ;
        } ;
    } ;  # BEG-E
} ; 
#*------^ END Function push-HostIndent ^------
