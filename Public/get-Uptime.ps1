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
    vers: 12:15 PM 2/3/2015 functional
    Vers: 7:26 AM 2/3/2015 port to function
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

    # 9:03 AM 2/3/2015 added aliases, permits piping the output of WMI query etc, using Get-WMIObject into a function and it would grab the __Server property of the object and use it in the pipeline of the function.

    [CmdletBinding()]
    param (
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
    }  # BEG-E
    PROCESS {
        foreach ($Computer in $Computername) {
            $iProcd++
            $continue = $true
            try {
                $ErrorActionPreference = "Stop" ;
                $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer #-ErrorAction stop
                $oRet = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime) #-ErrorAction stop
            }
            catch {
                Write "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
                Continue
            } # try/cat-E
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
                    'UptimeStr'    = ("$($Computer):$($oRet.Days)d:$($oRet.Hours)h:$($oRet.Minutes)m:$($oRet.Seconds)s")
                } ;
                $obj = New-Object -Type PSObject -Property $property
                Write-Output $obj
            } # if-E
        } 
    }  # PROC-E
} #*------^ END Function get-Uptime ^------
