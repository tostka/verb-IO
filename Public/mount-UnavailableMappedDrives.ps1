*------v mount-UnavailableMappedDrives.ps1 v------
Function mount-UnavailableMappedDrives{
    <#
    .SYNOPSIS
    mount-UnavailableMappedDrives.ps1 - Check mapped shell drives (via Get-SMBMapping) for 'Unavailable' status, and create temp PSDrive mounts for each, to make the PS profile completely functional. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-11-08
    FileName    : mount-UnavailableMappedDrives.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Development,Parser
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 11:07 AM 1/19/2022 swapped in $hommeta.rgxMapsUNCs for hard-coded rgx ; added test for value, pre-run
    *2:51 PM 12/5/2021 init
    .DESCRIPTION
    mount-UnavailableMappedDrives.ps1 - Check mapped shell drives (via Get-SMBMapping) for 'Unavailable' status, and create temp PSDrive mounts for each, to make the PS profile completely functional. 
    .PARAMETER rgxRemoteHosts
    Regex of RemotePath 'hosts' to be re-mounted in session[-rgxRemoteHosts '(Host1|host2)']
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS>  mount-UnavailableMappedDrives -rgxRemoteHOsts $homMeta.rgxMapsUNCs -verbose ;
    Run a pass with verbose output, and a regex UNC root path filter passed as a hash variable
    .LINK
    https://github.com/tostka/verb-io
    #>
    #Requires -Version 5
    #Requires -Modules SmbShare
    PARAM(
        [Parameter(HelpMessage="Regex of RemotePath 'hosts' to be re-mounted in session[-rgxRemoteHosts '(Host1|host2)']")]
        [string]$rgxRemoteHosts=$HOMMeta.rgxMapsUNCs,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    $propsSDrv = 'Status','LocalPath','RemotePath' ; 
    $error.clear() ;
    TRY {
        if(-not($rgxRemoteHosts){
            $smsg = "`$rgxRemoteHosts is not configured!`nspecify a value and rerun" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            throw $smsg ;
        } ; 
        $unavdrvs = Get-SMBMapping -verbose:$($VerbosePreference -eq "Continue") | ?{$_.RemotePath -match $rgxRemoteHosts -AND $_.status -eq 'Unavailable'} ; 
        $psdrvs = Get-psdrive -verbose:$($VerbosePreference -eq "Continue") | ?{$_.remotepath -match $rgxRemoteHosts } ; 
        if($unavdrvs){
            $smsg = "Unavailable mapped drives:`n$(($unavdrvs|ft -a $propsSDrv | out-string).trim())" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ; 
        $pltNPSD=[ordered]@{
          Name = $null ; 
          Root = $null ; 
          PSProvider = 'FileSystem' ; 
          Scope = "Global" ; 
          ErrorAction = 'STOP' ; 
          Verbose = $($VerbosePreference -eq "Continue") ; 
          whatif = $($whatif) ; 
        } ; 
        # New-PSDrive -Name "S" -Root "\\Server01\Scripts" -Persist -PSProvider "FileSystem" -Credential $cred ;      
        $netDrvs = @() ;    
        foreach($drv in $unavdrvs){
            $pltNPSD.Name = [regex]::match($drv.localpath.tostring(),"([A-Z]):").captures[0].groups[1].value; 
            $pltNPSD.Root = $drv.remotepath; 
            if($psdrvs |?{($_.Root -eq $drv.remotepath) -AND $_.name -eq $pltNPSD.Name}){
                $smsg = "(existing psDrive for " ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            } else { 
                write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):Fix:Unavail Map: New-PSDrive w`n$(($pltNPSD|out-string).trim())" ; 
                $netDrvs += New-PsDrive @pltNPSD ; 
                if(-not $whatif){
                    if(test-path -path "$($netDrvs[-1].Name):" -ea continue){
                        $smsg = "(confirmed drive available)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } else { 
                        $smsg = "drive fails availability test!" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} #Error|Warn|Debug 
                        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } ; 
           


                } else { 
                    $smsg = "(-whatif: skipping confirmation)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                } ;
            } ; 
        } ; 
        $smsg = "Post Status:`n$(($netDrvs|ft -a | out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        #$results = Get-SMBMapping -verbose:$($VerbosePreference -eq "Continue") | ?{$_.remotepath -like '*synnas*'} ;     
        # no above still reflects unavail, do the psd's off of the $netdrv output

        <#$smsg = "Post Status w`n$((Get-SMBMapping  | ?{$_.remotepath -like '*synnas*'}|  ft -a $propsSDrv |out-string).trim())" ;     
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        #>
        $results | write-output ; 
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #-=-record a STATUSWARN=-=-=-=-=-=-=
        $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
        if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
        if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
        #-=-=-=-=-=-=-=-=
        $smsg = "FULL ERROR TRAPPED (EXPLICIT CATCH BLOCK WOULD LOOK LIKE): } catch[$($ErrTrapd.Exception.GetType().FullName)]{" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level ERROR } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        $false | write-output ; 
        Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
    } ; 
}

#*------^ mount-UnavailableMappedDrives.ps1 ^------