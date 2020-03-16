function trim-FileList {
    <#
    .SYNOPSIS
    trim-FileList.ps1 - Sort and unique a file containing a list of items
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 20200221
    FileName    : trim-FileList.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    REVISIONS
    * 6:53 AM 2/21/2020 init
    .DESCRIPTION
    .PARAMETER  Files
    Files listing items, to be sorted & uniqued [-file x:\path-to\file.txt]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    .EXAMPLE
    $tfiles = @(gci C:\sc\powershell\_key-admin-scripts-*.txt -recur |select -expand fullname )  ;
    trim-FileList.ps1 -files $tfiles -verbose -whatif ; 
    Process all targeted files in the tree, verbose output, whatif pass
    .EXAMPLE
    trim-FileList -files x:\path-to\somefile.txt -verbose -whatif
    .LINK
    #>
    #[ValidateScript({Test-Path $_})]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Files listing items, to be sorted & uniqued [-files x:\path-to\file.txt]")]
        [array]$Files,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag (defaults TRUE)[-whatIf]")]
        [switch] $whatIf=$true 
    ) ;
    BEGIN {
        $Procd= 0 ;
        $Verbose = ($VerbosePreference -eq 'Continue') ; # if using explicit write-verbose -verbose, this converts the vPref into a usable vari in those lines
        $sBnr="#*---===v Function: $($MyInvocation.MyCommand) v===---" ;
        $smsg= "$($sBnr)" ;
        if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    }  # BEG-E ;
    PROCESS {
        $ttl = ($Files | measure).count
        $Procd=0 ;
        foreach ($File in $Files) {
            $Procd++ ;
            $sBnrS="`n#*------v ($($Procd)/$($ttl)):$($File): v------" ;
            $smsg= $sBnrS ;
            if($showdebug -OR $Verbose){
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
            $error.clear() ;
            $continue = $true ;
            $PriorEAPref = $ErrorActionPreference ;
            TRY {
                $ErrorActionPreference = "Stop" ;
                if($tf = gci $file){
                    write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):PROC ($((gc $tf.fullname).count) lines):$($tf.fullname)" ;
                    gc $tf | sort | select -unique | set-content $tf.fullname -whatif:$($whatif) ;
                    write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):POST ($((gc $tf.fullname).count) lines):$($tf.fullname)" ;
                } ;
                $true | write-output ;
            } CATCH {
                $smsg = "Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } #Error|Warn|Debug
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Exit #STOP(debug)|EXIT(close)|Continue(move on in loop cycle) ;
            } ;
            $ErrorActionPreference = $PriorEAPref ;
            $smsg= "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } #  # loop-E ;
    } # PROC-E ;
    END {
        $smsg= "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
        if($showdebug -OR $Verbose){
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;
    } ; # END-E
}
