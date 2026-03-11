#*------v Function get-Uptime v------
function get-Uptime {
    <#
    .SYNOPSIS
    get-Uptime() - retrieves time since last bootup, on the specified/local machine(s)
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 9:58 AM 3/11/2026 psv2 isn't doing alt catch, spliced the evtlog  call under an if block in the catch ; 
        retooled to cover WMI qry fails (high uptime/wmi svc issues?, fail through to use get-WinEvent to pull Event log startup event: 6005 The Event log service was started
    vers: 12:15 PM 2/3/2015 functional
    # 9:03 AM 2/3/2015 added aliases, permits piping the output of WMI query etc, using Get-WMIObject into a function and it would grab the __Server property of the object and use it in the pipeline of the function.; port to function
    Vers: 8:35 AM 9/16/2013 added timestamp to console for ref
    vers: 11:02 AM 8/19/2013 - works, with pipeline support, but I removed the computerlist param - pipe in a list if you want one
    vers: 9:19 AM 8/19/2013 - initial version
    .DESCRIPTION
    get-Uptime - retrieves time since last bootup, on the specified/local machine
    Works for single system, and a list on cmdline, but try to pipline Exchservers into it, and it throws up
    .PARAMETER  ComputerName
    Name or IP address of the target computer
    .PARAMETER Credential
    Credential object for use in accessing the computers.
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns an object with uptime data to the pipeline.
    .EXAMPLE
    get-Uptime USEA-MAILEXP | select Computername,Uptime
    .EXAMPLE
    (get-uptime "LYN-3V6KSY1","localhost").uptimestr
    .EXAMPLE
    get-exchangeserver usea-nahubcas1 | get-Uptime
    .EXAMPLE
    get-exchangeserver  | get-Uptime
    .EXAMPLE
    "usea-nahubcas1","usea-fdhubcas1" | foreach {get-uptime $_}
    .EXAMPLE
    get-exchangeserver | sort Site,AdminDisplayVersion.major,Role,Name | foreach {get-uptime $_}
    .EXAMPLE
    Get-ADComputer -filter * | Select @{label='computername';expression={$_.name}} | Get-Uptime
    .LINK
     #>    
    [CmdletBinding()]
    PARAM (
        [parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [Alias('__ServerName', 'Server', 'Computer', 'Name', 'IPAddress', 'CN')]
        [string[]]$ComputerName = $env:COMPUTERNAME
        ,
        [parameter(Position = 1)]
        [System.Management.Automation.PSCredential]$Credential
    ) ;
    BEGIN {
        $Info = @()
        $iProcd = 0;
        #region FUNCTIONS_INTERNAL ; #*======v FUNCTIONS_INTERNAL v======
        function get-uptimeEvent {
            [CmdletBinding()]
            PARAM (
                [parameter(
                    ValueFromPipeline = $true,
                    ValueFromPipelineByPropertyName = $true,
                    Position = 0)]
                [Alias('__ServerName', 'Server', 'Computer', 'Name', 'IPAddress', 'CN')]
                [string]$ComputerName = $env:COMPUTERNAME
                ,
                [parameter(Position = 1)]
                [System.Management.Automation.PSCredential]$Credential
            ) ;     
            TRY{
                [datetime]$boottime = Get-WinEvent -FilterHashtable @{logname = 'System'; id = 6005} -ComputerName $ComputerName -ERRORACTION STOP| sort timecreated | select -last 1 | select -expand timecreated
;                if($tsuptime = New-TimeSpan -Start $boottime -End (get-date )){ 
                    $tsUptime | write-output ;
                }else{
                    $smsg = "UNABLE TO RESOLVE UPTIME VIA BACKUP GET-WINEVENT CALL!" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                }
            } CATCH {$ErrTrapd=$Error[0] ;
                write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            } ;
            
        }
        #endregion FUNCTIONS_INTERNAL ; #*======^ END FUNCTIONS_INTERNAL ^======
    }  # BEG-E
    PROCESS {
        foreach ($Computer in $Computername) {
            $iProcd++
            $continue = $true
            try {
                $ErrorActionPreference = "Stop" ;
                $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer #-ErrorAction stop
                $oRet = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime) #-ErrorAction stop
            } CATCH [System.Management.ManagementException]{
                $smsg = "WMI QRY FAIL (POSSIBLE WMI SVC/UPTIME ISSUE?)" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                $smsg = "RETRYING via get-uptimeEvent (Get-WinEvent -FilterHashtable @{logname = 'System'; id = 6005) " ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                $oRet = get-uptimeEvent -ComputerName $Computer ; 
            } CATCH {
                # or just do idiotproof: Write-Warning -Message $_.Exception.Message ;
                $ErrTrapd=$Error[0] ;
                # psv3 ex10 boxes aren't picking up the alt catch above, do it manually:
                if($($host.Version.Major -eq 2 -AND $ErrTrapd.Exception.GetType().FullName) -eq 'System.Management.ManagementException'){
                    $smsg = "WMI QRY FAIL (POSSIBLE WMI SVC/UPTIME ISSUE?)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    $smsg = "RETRYING via get-uptimeEvent (Get-WinEvent -FilterHashtable @{logname = 'System'; id = 6005) " ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $oRet = get-uptimeEvent -ComputerName $Computer ; 
                } else{ 
                    $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
                    else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $smsg = $ErrTrapd.Exception.Message ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
                    else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #-=-record a STATUSWARN=-=-=-=-=-=-=
                    $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
                    if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
                    if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ;
                    #-=-=-=-=-=-=-=-=
                    $smsg = "FULL ERROR TRAPPED (EXPLICIT CATCH BLOCK WOULD LOOK LIKE): } CATCH[$($ErrTrapd.Exception.GetType().FullName)]{" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level ERROR } #Error|Warn|Debug
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    CONTINUE #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
                } ; 
            } ; 
            if ($continue) {
                # hashtable of the single system's properties
                # asserted property sort order is on property name
                $property = @{
                    'Computername' = $Computer;
                    'Days'         = $oRet.Days;
                    'Hours'        = $oRet.Hours;
                    'Minutes'      = $oRet.Minutes;
                    'Seconds'      = $oRet.Seconds;
                    'Uptime'       = $oRet -f $oRet.Hours, $oRet.Minutes, $oRet.Seconds;
                    'UptimeStr'    = ("$($Computer.toupper()):$($oRet.Days)d:$($oRet.Hours)h:$($oRet.Minutes)m:$($oRet.Seconds)s")
                } ;
                $obj = New-Object -Type PSObject -Property $property
                Write-Output $obj
            } # if-E
        } 
    }  # PROC-E
} #*------^ END Function get-Uptime ^------
