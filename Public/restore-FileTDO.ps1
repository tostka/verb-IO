#*------v Function restore-FileTDO v------
function restore-FileTDO {
    <#
    .SYNOPSIS
    restore-FileTDO.ps1 - Restore file from prior backup
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2:23 PM 12/29/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    REVISIONS
    * 11:52 AM 5/19/2022 typo fix
    * 8:51 AM 5/16/2022 ren revert-File -> restore-file (stock verb, add my uniquing suffix); add orig to alias; added pipeline handling;
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 2:23 PM 12/29/2019 init
    .DESCRIPTION
    restore-FileTDO.ps1 - Revert a file to a prior backup of the file
    .PARAMETER  Path
    Path to backup file to be restored
    .PARAMETER Destination
    Optional explicit fullpath file specified as 'source' should be copied to (default behavior is to trim the extension of the trailing time stamp, previously appended via use of backup-FileTDO())[-Dest path-to\script.ps1]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS> $bRet = restore-FileTDO -Source "C:\sc\verb-dev\verb-dev\verb-dev.psm1_20191229-0904AM" -Destination "C:\sc\verb-dev\verb-dev\verb-dev.psm1" -showdebug:$($showdebug) -whatif:$($whatif)
    PS> if (!$bRet) {throw "FAILURE" } ;
    Restore file to prior revision.
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('revert-File','restore-file')]
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to script[-Source path-to\script.ps1]")]
        [ValidateScript( { Test-Path $_ })]
        [Alias('Source')]$Path,
        [Parameter(Position = 0, Mandatory = $False, HelpMessage = "Optional explicit fullpath file specified as 'source' should be copied to (default behavior i8s to trim the extension of the trailing time stamp)[-Dest path-to\script.ps1]")]
        $Destination,
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
        $rgxExtensionTimeStamp = '(_\d{8}-\d{4}(A|P)M)$' ;
        $smsg = $sBnr="#*======v $(${CmdletName}): v======" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

        if ($Destination -AND ($path -is [system.array])){
            $smsg = "An Array of paths was used, with explicit -Destination:" ;
            $smsg += "`nThis command *does not support explicit -Destination* when processing Path arrays!" ;
            $smsg += "`nIn Array mode, only default 'extension-timestamp-stripping' behavior is permitted. " ;
            $smsg += "`n(Please retry without an explicit -Destination, to use the default behavior)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else { write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            throw $smsg ;
            break ;
        }
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
            $fnparts = @() ; $ExtTstamp = $null ; 
            Try {
                if ($item.GetType().FullName -ne 'System.IO.FileInfo') {
                    $item = get-childitem -path $item ;
                } ;
                $sBnrS = "`n#*------v ($($Procd)):$($item.fullname) v------" ;
                $smsg = "$($sBnrS)" ;
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;

                $pltCpy = [ordered]@{
                    path        = $item.fullname ;
                    destination = $null ;
                    ErrorAction="Stop" ;
                    whatif      = $($whatif) ;
                } ;
                if(-not $Destination){
                    $fnparts += $item.BaseName ; 
                    if($item.extension){
                        if($ExtTstamp = [regex]::match($item.Extension, $rgxExtensionTimeStamp).captures[0].groups[0].value){
                            $smsg = "(No -Destination specified: Trimming Timestamp $($ExtTstamp) (from existing Extension:$($item.extension))" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

                            if($item.extension.split('_')[0] -eq '.'){
                                $smsg = "(original file was extensionless: restoring basename to 'name')" ; 
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } else {
                                if($item.extension.replace($ExtTstamp,'') -eq '.'){
                                    $smsg = "(net extension would be blank: dropping extension)" ; 
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                                } else { 
                                    #$fnparts += "." ; 
                                    $fnparts += $item.extension.replace($ExtTstamp,'') ;
                                } ; 
                            } ; 
                        
                            $pltCpy.destination = join-path -path (split-path $item.fullname) -ChildPath ($fnparts -join '') ; 
                        } else {
                                $smsg = "UNABLE TO RESOLVE TIMESTAMP FROM EXTENSION, AND NO -Destination SPECIFIED!" ;
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
                                else{ WRITE-WARNING  "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                throw $smsg;
                                break ;
                        } ;
                    } else { 
                        $smsg = "Invalid restore -path specified:`n'($item.name)' has NO EXTENSION!" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
                        else{ WRITE-WARNING  "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        throw $smsg;
                        break ;
                    } ; 
                } else {
                    $pltCpy.destination = $Destination
                    $smsg = "-Destination specified: $($pltCpy.destination)" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            } Catch {
                $ErrorTrapped = $Error[0] ;
                Write-Verbose "Failed to exec cmd because: $($ErrorTrapped)" ;
                Break ; 
            }  ;

            $smsg = "RESTORE:copy-item w`n$(($pltCpy|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $Exit = 0 ;
            Do {
                $error.clear() ;
                Try {
                    copy-item @pltCpy ;
                    $Exit = $Retries ;
                } Catch {
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
            if (-not $whatif) {
                $smsg = "(Compare-Object restored obj to source)" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;  
                if (Compare-Object -ReferenceObject $(Get-Content $pltCpy.path) -DifferenceObject $(Get-Content $pltCpy.destination)) {
                    $smsg = "BAD COPY!`n$pltCpy.path`nIS DIFFERENT FROM`n$pltCpy.destination!`nEXITING!";
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error }  #Error|Warn|Debug
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $false | write-output ;
                } Else {
                    $smsg = "Validated Copy:`n$($pltCpy.path)`n*matches*`n$($pltCpy.destination)"; ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                    else{ write-verbose  "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $pltCpy.destination | write-output ;
                } ;
            } else {
                #$true | write-output ;
                $pltCpy.destination | write-output ;
            };
            $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
        }   # loop-E
    } ;  # E PROC
    END{
         $smsg = $sBnr.replace('=v','=^').replace('v=','^=') ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    }
} ;
#*------^ END Function restore-FileTDO ^------