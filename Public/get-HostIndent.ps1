
#*------v Function get-HostIndent v------
function get-HostIndent {
    <#
    .SYNOPSIS
    get-HostIndent - Utility cmdlet that retrieves the current $env:HostIndentSpaces value. 
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : get-HostIndent.ps1
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
    * 2:13 PM 2/3/2023 init
    .DESCRIPTION
    get-HostIndent - Utility cmdlet that retrieves the current $env:HostIndentSpaces value. 

    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reget-HostIndent # $env:HostIndentSpaces = 0 ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    get-HostIndent # explicit set to multiples of 4
    clear-HostIndent # remove $env:HostIndentSpaces
    get--HostIndent # return current env:HostIndentSpaces value to pipeline
            

    Concept inspired by L5257's printIndent() in his get-DNSspf.ps1 (which ran a simple write-host -nonewline loop, to be run prior to write-host use). 

    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .EXAMPLE
    PS> $CurrIndnet = get-HostIndent ;
    Simple retrieval demo    
    #>
    [CmdletBinding()]
    [Alias('s-hi')]
    PARAM(
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

    #if we want to tune this to a $PID-specific variant, use:
    if($usePID){
            $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $HISName = "Env:HostIndentSpaces$($PID)" ;
        } else {
            $HISName = "Env:HostIndentSpaces" ;
        } ;
        write-verbose "$($CmdletName): Discovered `$$($HISName):$($CurrIndent)" ;
        $smsg = "$($CmdletName): get $($HISName) value)" ;
        write-verbose $smsg  ;
        TRY{
            if (-not ([int]$CurrIndent = (Get-Item -Path $HISName -erroraction SilentlyContinue).Value ) ){
                [int]$CurrIndent = 0 ;
            } ;
            $CurrIndent | write-output ;
        } CATCH {
            $smsg = $_.Exception.Message ;
            write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            $false  | write-output ;
            BREAK ;
        } ;
    } ;
} ;
#*------^ END Function get-HostIndent ^------
