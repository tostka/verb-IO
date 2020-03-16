function revert-File {
    <#
    .SYNOPSIS
    revert-File.ps1 - Restore file from prior backup
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2:23 PM 12/29/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    REVISIONS
    * 2:23 PM 12/29/2019 init
    .DESCRIPTION
    revert-File.ps1 - Revert a file to a prior backup of the file
    .PARAMETER  Source
    Path to backup file to be restored
    .PARAMETER Destination
    Path & name Source file should be copied to
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    $bRet = revert-File -Source "C:\sc\verb-dev\verb-dev\verb-dev.psm1_20191229-0904AM" -Destination "C:\sc\verb-dev\verb-dev\verb-dev.psm1" -showdebug:$($showdebug) -whatif:$($whatif)
    if (!$bRet) {throw "FAILURE" } ;
    Backup specified file
    .LINK
    #>
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to script[-Source path-to\script.ps1]")]
        [ValidateScript( { Test-Path $_ })]$Source,
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path & name Source file should be copied to[-Dest path-to\script.ps1]")]
        $Destination,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    if ($Source.GetType().FullName -ne 'System.IO.FileInfo') {
        $Source = get-childitem -path $Source ;
    } ;
    $pltBu = [ordered]@{
        path        = $Source.fullname ;
        destination = $Destination ;
        ErrorAction="Stop" ;
        whatif      = $($whatif) ;
    } ;
    $smsg = "REVERT:copy-item w`n$(($pltBu|out-string).trim())" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    $Exit = 0 ;
    Do {
        Try {
            copy-item @pltBu ;
            $Exit = $Retries ;
        }
        Catch {
            $ErrorTrapped = $Error[0] ;
            Write-Verbose "Failed to exec cmd because: $($ErrorTrapped)" ;
            Start-Sleep -Seconds $RetrySleep ;
            # reconnect-exo/reconnect-ex2010
            $Exit ++ ;
            Write-Verbose "Try #: $Exit" ;
            If ($Exit -eq $Retries) { Write-Warning "Unable to exec cmd!" } ;
        }  ;
    } Until ($Exit -eq $Retries) ;

    # validate copies *exact*
    if (!$whatif) {
        if (Compare-Object -ReferenceObject $(Get-Content $pltBu.path) -DifferenceObject $(Get-Content $pltBu.destination)) {
            $smsg = "BAD COPY!`n$pltBu.path`nIS DIFFERENT FROM`n$pltBu.destination!`nEXITING!";
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error }  #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $false | write-output ;
        }
        Else {
            if ($showDebug) {
                $smsg = "Validated Copy:`n$($pltbu.path)`n*matches*`n$($pltbu.destination)"; ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
            #$true | write-output ;
            $pltBu.destination | write-output ;
        } ;
    } else {
        #$true | write-output ;
        $pltBu.destination | write-output ;
    };
}
