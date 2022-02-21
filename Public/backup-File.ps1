function backup-File {
    <#
    .SYNOPSIS
    backup-File.ps1 - Create a backup of specified script
    .NOTES
    Version     : 1.0.2
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 1:43 PM 11/16/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 9:12 AM 12/29/2019 switch output to being the backupfile name ($pltBu.destination ), or $false for fail
    * 9:34 AM 12/11/2019 added dyanamic recycle of existing ext (got out of hardcoded .ps1)
    * 1:43 PM 11/16/2019 init
    .DESCRIPTION
    backup-File.ps1 - Create a backup of specified script
    .PARAMETER  Path
    Path to script
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS> $bRet = backup-File -path $oSrc.FullName -showdebug:$($showdebug) -whatif:$($whatif)
    PS> if (!$bRet) {throw "FAILURE" } ;
    Backup specified file
    .LINK
    #>
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to script[-Path path-to\script.ps1]")]
        [ValidateScript( { Test-Path $_ })]$Path,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    if ($Path.GetType().FullName -ne 'System.IO.FileInfo') {
        $Path = get-childitem -path $Path ;
    } ;
    $pltBu = [ordered]@{
        path        = $Path.fullname ;
        destination = $Path.fullname.replace($Path.extension, "$($Path.extension)_$(get-date -format 'yyyyMMdd-HHmmtt')") ;
        ErrorAction="Stop" ;
        whatif      = $($whatif) ;
    } ;
    $smsg = "BACKUP:copy-item w`n$(($pltBu|out-string).trim())" ;
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
