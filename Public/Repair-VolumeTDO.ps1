# Repair-VolumeTDO.ps1


#region REPAIR_VOLUMETDO ; #*------v Repair-VolumeTDO v------
function Repair-VolumeTDO{
        <#
        .SYNOPSIS
        Repair-VolumeTDO.ps1 - Wrapper for repair-volume/checkdsk
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-
        FileName    : Repair-VolumeTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-IO
        Tags        : Powershell
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 11:10 AM 7/30/2025 init, sub func for test-xop15LocalInstallDrivesTDO
        .DESCRIPTION
        Repair-VolumeTDO.ps1 - Wrapper for repair-volume/checkdsk
        .PARAMETER  DriveLetter
        Drive Letter to be checked[-DriveLetter D]]
        .INPUTS
        None. Does not accepted piped input.(.NET types, can add description)
        .OUTPUTS
        System.Integer OperationalStatus [0|1]
        .EXAMPLE
        PS> $tVols = get-volume ; 
        PS> $driveSummary = [ordered]@{
        PS>     Drives = @() ;
        PS>     DriveHealthIssues = $null ;
        PS>     ValidAll = $false ;
        PS> } ; 
        PS> $BadDrives = $tVols | ?{$_.DriveType  -eq 'Fixed' -AND ($_.HealthStatus -ne 'Healthy' -OR $_.OperationalStatus -ne 'OK')} ; 
        PS> $BadDrives | foreach-object{
        PS>     if($_.HealthStatus -ne 'Healthy'){
        PS>         $smsg = "drive HealthStatus: $($_.DriveLetter): $($_.HealthStatus)!" ;
        PS>         $driveSummary.DriveHealthIssues += @($smsg)
        PS>         write-warning $smsg ; 
        PS>     }else{Write-Host @whPASS} ;
        PS>     if($_.OperationalStatus -ne 'OK'){
        PS>         write-host @whFAIL ;
        PS>         $smsg = "SysVol drive OperationalStatus: $($_.DriveLetter): $($_.OperationalStatus)!" ;
        PS>         $driveSummary.DriveHealthIssues += @($smsg)
        PS>         write-warning $smsg ; 
        PS>     }else{Write-Host @whPASS} ;
        PS> } ;
        .LINK
        https://github.com/tostka/verb-IO
        #>
        [CmdletBinding()]
        PARAM(
            [Parameter(Mandatory = $true, HelpMessage = "Drive Letter to be checked[-DriveLetter D]]")]
                [string]$DriveLetter
        )
        BEGIN{
            $rgxDriveLetter = '([A-Za-z])\:' ; 
            if($DriveLetter -match $rgxDriveLetter){                
                $DriveLetter = [regex]::match('c:',$rgxDriveLetter).groups[1] ; 
            }
        }
        PROCESS{
            foreach($bd in $DriveLetter){
                $bd = get-volume -driveletter $bd -ea Stop ; 
                $resRvol = repair-volume -DriveLetter $bd.driveletter -scan ; 
                if($resRvol -eq 'NoErrorsFound'){
                    $smsg = "Result:repair-volume -DriveLetter $($bd.driveletter) -scan:$($resRvol)" ; 
                    $smsg = "=> Moving on to Chkdsk" ; 
                    if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    } ;
                    #chkdsk D: /f
                    $resChkD = Invoke-DriveChkDskTDO -DriveLetter $bd.driveletter ; 
                    if($resChkD -eq 0){
                        $smsg = "=> Chkdsk: clean exit (status:0)" ; 
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                    } else {
                        $smsg = "Chkdsk non-0 results:$($resChkD)" ; 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                    } ;                     
                }else {
                    $resChkD = Invoke-DriveChkDskTDO -DriveLetter $bd.driveletter ; 
                    if($resChkD -eq 0){
                        $smsg = "=> Chkdsk: clean exit (status:0)" ; 
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                    } else {
                        $smsg = "Chkdsk non-0 results:$($resChkD)" ; 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                    } ;            
                } ; 
                switch ((get-volume -DriveLetter $bd.driveletter).OperationalStatus){
                    'OK'{
                        $smsg = "CLEAR results: get-volume -DriveLetter $($bd.driveletter).OperationalStatus: OK" ; 
                        if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 }
                            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                        } ;
                        0 | write-output                             
                    }
                    default {
                        $smsg = "NON-CLEAR results: get-volume -DriveLetter $($bd.driveletter).OperationalStatus: " ;                                 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;  
                        1 | WRITE-OUTPUT ; 
                    }
                } ;                
            } ; 
        } # PROC-E
    }
#endregion REPAIR_VOLUMETDO ; #*------^ END Repair-VolumeTDO ^------

