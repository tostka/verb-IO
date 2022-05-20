function backup-FileTDO {
    <#
    .SYNOPSIS
    backup-FileTDO.ps1 - Create a backup of specified script. Simply replaces specified file's extension with a date-stamped variant: '[prior-extension]_yyyyMMdd-HHmmtt'
    .NOTES
    Version     : 1.0.2
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 1:43 PM 11/16/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 1:35 PM 5/20/2022 flipped echos w-h -> w-v
    * 11:53 AM 5/19/2022 ren: $pltBU -> $pltCpy
    * 8:58 AM 5/16/2022 added pipeline handling; ren backup-file -> backup-fileTDO (and alias orig name)
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 9:12 AM 12/29/2019 switch output to being the backupfile name ($pltBu.destination ), or $false for fail
    * 9:34 AM 12/11/2019 added dyanamic recycle of existing ext (got out of hardcoded .ps1)
    * 1:43 PM 11/16/2019 init
    .DESCRIPTION
    backup-FileTDO.ps1 - Create a backup of specified script. Simply replaces specified file's extension with a date-stamped variant: '[prior-extension]_yyyyMMdd-HHmmtt'
    .PARAMETER  Path
    Path to script
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    System.String, system.io.fileinfo
    .OUTPUTS
    System.String reflecting backup file fullname.

    .EXAMPLE
    PS> $bRet = backup-FileTDO -path $oSrc.FullName -showdebug:$($showdebug) -whatif:$($whatif)
    PS> if (!$bRet) {throw "FAILURE" } ;
    Backup specified file
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('backup-File')]
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = "Path to script[-Path path-to\script.ps1]")]
        [ValidateScript( { Test-Path $_ })]$Path,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN{
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        #$PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        $smsg = $sBnr = "#*======v $(${CmdletName}): v======" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else { write-verbose $smsg } ;

        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ;
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ;
            write-verbose "(non-pipeline - param - input)" ;
        } ;

        $Procd = 0 ; 
    } # BEG-E
    PROCESS{
        foreach($item in $path) {
            $Procd++ ;
            $fnparts = @() ; 
            $error.clear() ;
            Try {
                if ($item.GetType().FullName -ne 'System.IO.FileInfo') {
                    $item = get-childitem -path $item ;
                } ;
                $sBnrS = "`n#*------v ($($Procd)):$($item.fullname) v------" ;
                $smsg = "$($sBnrS)" ;
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-verbose $smsg } ; } ;

                $pltCpy = [ordered]@{
                    path        = $item.fullname ;
                    destination = $null ;
                    ErrorAction="Stop" ;
                    whatif      = $($whatif) ;
                } ;

                $fnparts = $item.BaseName ; 

                if($item.extension){
                    $pltCpy.destination = $item.fullname.replace($item.extension, "$($item.extension)_$(get-date -format 'yyyyMMdd-HHmmtt')") ;
                } ELSE { 
                    $fnparts += "." ; 
                    $fnparts += "_$(get-date -format 'yyyyMMdd-HHmmtt')" ; 
                    $pltCpy.destination = join-path (split-path $item.fullname) -childpath ($fnparts -join '') ; 
                } ; 
            } Catch {
                $ErrorTrapped = $Error[0] ;
                Write-WARNING "Failed to exec cmd because: $($ErrorTrapped)" ;
            }  ;

            $smsg = "BACKUP:copy-item w`n$(($pltCpy|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
            else{ write-verbose $smsg } ;
            $Exit = 0 ;
            Do {
                Try {
                    copy-item @pltCpy ;
                    $Exit = $Retries ;
                } Catch {
                    $ErrorTrapped = $Error[0] ;
                    Write-WARNING "Failed to exec cmd because: $($ErrorTrapped)" ;
                    Start-Sleep -Seconds $RetrySleep ;
                    $Exit ++ ;
                    Write-WARNING "Try #: $Exit" ;
                    If ($Exit -eq $Retries) { Write-Warning "Unable to exec cmd!" } ;
                }  ;
            } Until ($Exit -eq $Retries) ;

            # validate copies *exact*
            if (!$whatif) {
                if (Compare-Object -ReferenceObject $(Get-Content $pltCpy.path) -DifferenceObject $(Get-Content $pltCpy.destination)) {
                    $smsg = "BAD COPY!`n$pltCpy.path`nIS DIFFERENT FROM`n$pltCpy.destination!`nEXITING!";
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error }  #Error|Warn|Debug
                    else{ write-verbose $smsg } ;
                    $false | write-output ;
                } Else {
                    if ($showDebug) {
                        $smsg = "Validated Copy:`n$($pltCpy.path)`n*matches*`n$($pltCpy.destination)"; ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                        else{ write-verbose $smsg } ;
                    } ;
                    #$true | write-output ;
                    $pltCpy.destination | write-output ;
                } ;
            } else {
                #$true | write-output ;
                $pltCpy.destination | write-output ;
            };
            $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-verbose $smsg } ; } ;
        }  # loop-E
    } ;  # E PROC
    END{
        $smsg = $sBnr.replace('=v','=^').replace('v=','^=') ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-verbose $smsg } ;
    }
} ;
#*------^ END Function backup-FileTDO ^------
