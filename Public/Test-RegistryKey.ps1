
    #region TEST_REGISTRYKEY ; #*------v Test-RegistryKey v------    
    function Test-RegistryKey {
        <#
        .SYNOPSIS
        Test-RegistryKey.ps1 - Checks specified registry key for presence (gi)
        .NOTES
        Version     : 1.0.0
        Author      : Todd Kadrie
        Website     :	http://www.toddomation.com
        Twitter     :	@tostka / http://twitter.com/tostka
        AddedCredit : Adam Bertram
        AddedWebsite:	https://adamtheautomator.com/pending-reboot-registry-windows/
        AddedTwitter:	@adambertram
        CreatedDate : 20201014-0826AM
        FileName    : Test-RegistryKey.ps1
        License     : MIT License
        Copyright   : (c) 2020 Todd Kadrie
        Github      : https://github.com/tostka/verb-XXX
        Tags        : Powershell,System,Reboot
        REVISIONS
        * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
        * 5:03 PM 1/14/2021 init, minor CBH mods
        * 7/29/19 AB's posted version
        .DESCRIPTION
        Test-RegistryKey.ps1 - Checks specified registry key for presence (gi)
        .PARAMETER  Key
        Full registkey to be tested [-Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending']
        .EXAMPLE
        Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' ;
        Tests one of the Pending Reboot keys
        .LINK
        https://github.com/tostka/verb-IO
        #>
        [OutputType('bool')]
        [CmdletBinding()]
        #[Alias('get-ScheduledTaskReport')]
        PARAM(
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]$Key
        ) ;
        $ErrorActionPreference = 'Stop' ;
        if (Get-Item -Path $Key -ErrorAction Ignore) {
            $true | write-output ;
        } ;
    }
    #endregion TEST_REGISTRYKEY ; #*------^ END Test-RegistryKey ^------