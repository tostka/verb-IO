# Invoke-DriveChkDskTDO.ps1


#region INVOKE_DRIVECHKDSKTDO ; #*------v Invoke-DriveChkDskTDO v------
function Invoke-DriveChkDskTDO{
         <#
        .SYNOPSIS
        Invoke-DriveChkDskTDO.ps1 - Wrapper for checkdsk
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-
        FileName    : Invoke-DriveChkDskTDO.ps1
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
        Invoke-DriveChkDskTDO.ps1 - Wrapper for checkdsk
        .PARAMETER  DriveLetter
        Drive Letter to be checked[-DriveLetter D]]
        .INPUTS
        None. Does not accepted piped input.(.NET types, can add description)
        .OUTPUTS
        System.Integer OperationalStatus [0|1]
        .EXAMPLE
        PS> $bd = get-volume -driveletter $bd -ea Stop ; 
        PS> $resRvol = repair-volume -DriveLetter $bd.driveletter -scan ; 
        PS> $resChkD = Invoke-DriveChkDskTDO -DriveLetter $bd.driveletter ; 
        PS> if($resChkD -eq 0){
        PS>     $smsg = "=> Chkdsk: clean exit (status:0)" ; 
        PS>     if(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
        PS>         if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
        PS>         else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        PS>         #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
        PS>     } ;
        PS> } else {
        PS>     $smsg = "Chkdsk non-0 results:$($resChkD)" ; 
        PS>     if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
        PS>         if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
        PS>         else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        PS>     } ;
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
                
                    #chkdsk D: /f
                    $resChkD = Invoke-ProcessTDO -FilePath (split-path (gcm chkdsk.exe).source -parent) -FileName 'chkdsk.exe' -ArgumentList @("$($bd.driveletter):",'/f') ; 
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
                    if($chkevts = Get-WinEvent -FilterHashTable @{LogName="Application"; ProviderName="chkdsk"} | select -last 1 ){
                        # Get-WinEvent -FilterHashTable @{LogName="Application"; ProviderName="chkdsk"} | select -last 1 ;| Format-List TimeCreated, Message
                        $smsg = "Chkdsk results:`n$(($chkevts | Format-List TimeCreated, Message |out-string).trim())" ; 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;
                        if($chkevts.message.Split([Environment]::NewLine)| sls -patt 'No\sfurther\saction\sis\srequired\.'){
                            $smsg = "CLEAR results:`n$(($chkevts.message.Split([Environment]::NewLine)| sls -patt 'No\sfurther\saction\sis\srequired\.'|out-string).trim())" ; 
                            if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            } ;    
                        } ; 
                    } else { 
                        $smsg = "Chkdsk FAILED TO LOG RESULTS TO LogName=Application; ProviderName=chkdsk!" ;
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
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
                    }
                    default {
                        $smsg = "CLEAR results: get-volume -DriveLetter $($bd.driveletter).OperationalStatus: OK" ;                                 
                        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        } ;  
                    }
                } ; 
                if($resChkD){
                    $smsg = "A CHKDSK HAS BEEN RUN!: LIKELY DISMOUNTED DRIVE!" ;                                 
                    $smsg += "`nRUN A REFRESH REBOOT TO PROPERLY ENSURE FULL MOUNT(S) ARE BACK IN PLACE, AND RERUN THIS PASS!" ;
                    if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ;                              
                    Exit 'CHKDSKRUN' ;  
                } ; 
            } ; 
        } # PROC-E
        END{
            $resChkD | write-output ; 
        }
    }
#endregion INVOKE_DRIVECHKDSKTDO ; #*------^ END Invoke-DriveChkDskTDO ^------

