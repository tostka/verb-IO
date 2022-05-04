#*------v Test-PendingReboot.ps1 v------
function Test-PendingReboot {
    <#
    .SYNOPSIS
    Test-PendingReboot.ps1 - Check specified Server(s) registry for telltale PendingReboot registry keys. Returns a hashtable with IsPendingREboot and ComputerName for each machine checked. Requires localadmin permissions.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : Adam Bertram
    AddedWebsite:	https://adamtheautomator.com/pending-reboot-registry-windows/
    AddedTwitter:	@adambertram
    CreatedDate : 20201014-0826AM
    FileName    : Test-PendingReboot.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,System,Reboot
    REVISIONS
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
    * 9:52 AM 2/11/2021 pulled spurios trailing fire of the cmd below func, updated CBH
    * 5:03 PM 1/14/2021 init, minor CBH mods
    * 7/29/19 AB's posted version
    .DESCRIPTION
    Test-PendingReboot.ps1 - Check specified Server(s) registry for telltale PendingReboot registry keys. Returns a hashtable with IsPendingREboot and ComputerName for each machine checked. Requires localadmin permissions.
    .PARAMETER  ComputerName
    Array of computernames to be tested for pending reboot
    .PARAMETER  Credential
    windows Credential [-credential (get-credential)]
    .OUTPUT
    System.Collections.Hashtable
    .EXAMPLE
    if((Test-PendingReboot -ComputerName $env:Computername).IsPendingReboot){write-warning "$env:computername is PENDING REBOOT!"} ;
    Test for pending reboot.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    #[Alias('get-ScheduledTaskReport')]
    PARAM(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential
    ) ;
    $ErrorActionPreference = 'Stop'

    $scriptBlock = {

        $VerbosePreference = $using:VerbosePreference

        <# try to pull in local modules into the scriptblock (rather than expliciting a copy in the block) - didn't work, module load threw
        Error Message: A Using variable cannot be retrieved. A Using variable can be used only with Invoke-Command, Start-Job, or InlineScript in the script workflow. When it is used with Invoke-Command, the Using variable is valid only if the script block is invoked on a remote computer
        #>
        function Test-RegistryKey {
            [OutputType('bool')]
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                [string]$Key
            )
            $ErrorActionPreference = 'Stop'
            if (Get-Item -Path $Key -ErrorAction Ignore) {
                $true
            }
        }
        function Test-RegistryValue {
            [OutputType('bool')]
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                [string]$Key,
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                [string]$Value
            )
            $ErrorActionPreference = 'Stop'
            if (Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) {
                $true
            }
        }
        function Test-RegistryValueNotNull {
            [OutputType('bool')]
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                [string]$Key,
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                [string]$Value
            )
            $ErrorActionPreference = 'Stop'
            if (($regVal = Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) -and $regVal.($Value)) {
                $true
            }
        }

        # Added "test-path" to each test that did not leverage a custom function from above since
        # an exception is thrown when Get-ItemProperty or Get-ChildItem are passed a nonexistant key path
        # $tests is an array of scriptblocks, to be executed in a stack
        $tests = @(
            { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' }
            { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress' }
            { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' }
            { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending' }
            { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting' }
            { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations' }
            { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations2' }
            {
                # Added test to check first if key exists, using "ErrorAction ignore" will incorrectly return $true
                'HKLM:\SOFTWARE\Microsoft\Updates' | Where-Object { test-path $_ -PathType Container } | ForEach-Object {
                    (Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' | Select-Object -ExpandProperty UpdateExeVolatile) -ne 0
                }
            }
            { Test-RegistryValue -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Value 'DVDRebootSignal' }
            { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttemps' }
            { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'JoinDomain' }
            { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'AvoidSpnSet' }
            {
                # Added test to check first if keys exists, if not each group will return $Null
                # May need to evaluate what it means if one or both of these keys do not exist
                ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' | Where-Object { test-path $_ } | %{ (Get-ItemProperty -Path $_ ).ComputerName } ) -ne
                ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' | Where-Object { Test-Path $_ } | %{ (Get-ItemProperty -Path $_ ).ComputerName } )
            }
            {
                # Added test to check first if key exists
                'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending' | Where-Object {
                    (Test-Path $_) -and (Get-ChildItem -Path $_) } | ForEach-Object { $true }
            }
        ) ; # scriptblock-E
        # cycle the list and break on first match
        foreach ($test in $tests) {
            Write-Verbose "Running scriptblock: [$($test.ToString())]"
            if (& $test) {
                $true
                break
            }
        }
    } # scriptblock-E

    foreach ($computer in $ComputerName) {
        try {
            $connParams = @{'ComputerName' = $computer} ;
            if ($PSBoundParameters.ContainsKey('Credential')) {
                $connParams.Credential = $Credential ;
            } ;
            $output = @{
                ComputerName    = $computer ;
                IsPendingReboot = $false ;
            } ;
            $psRemotingSession = New-PSSession @connParams ;
            if (-not ($output.IsPendingReboot = Invoke-Command -Session $psRemotingSession -ScriptBlock $scriptBlock)) {
                $output.IsPendingReboot = $false ;
            } ;
            [pscustomobject]$output | write-output ;
        } catch {
            Write-Error -Message $_.Exception.Message
        } finally {
            if (Get-Variable -Name 'psRemotingSession' -ErrorAction Ignore) {
                $psRemotingSession | Remove-PSSession
            }
        } # TRY-E
    } ;
}

#*------^ Test-PendingReboot.ps1 ^------