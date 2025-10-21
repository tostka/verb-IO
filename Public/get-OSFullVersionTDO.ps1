# get-OSFullVersionTDO.ps1


#region GET_OSFULLVERSIONTDO ; #*------v get-OSFullVersionTDO v------
Function get-OSFullVersionTDO {
        <#
        .SYNOPSIS
        get-OSFullVersionTDO - local OS Semantic Version number n.n.n.n, via get-cimInstance/get-WMIObject
        .NOTES
        Version     : 0.0.1
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250929-1026AM
        FileName    : get-OSFullVersionTDO.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-desktop
        Tags        : Powershell,Storage,Drive,Drivespace
        AddedCredit : 
        AddedWebsite: 
        AddedTwitter: 
        REVISIONS
        * 12:12 PM 10/6/2025 add -MajorVersion & MinorVersion to return those sub-strings (support queries for the values in isolation); updated logic for the variant outputs.
        * 11:26 AM 9/29/2025 port from install-Exchnage15-TTC.ps1 into vdesk
        .DESCRIPTION
        get-OSFullVersionTDO - local OS Semantic Version number n.n.n.n, via get-cimInstance/get-WMIObject
       .PARAMETER MajorVersion
       Switch to return solely the MajorVersion value
       .PARAMETER MinorVersion        
        Switch to return solely the MinorVersion value
        .INPUTS
        None, no piped input.
        .OUTPUTS
        String Semantic Version
        .EXAMPLE
        PS> $OSSemVers = get-OSFullVersionTDO; 
        PS> $OSSemVers ; 
        
            10.0.19045          
        
        Demo call
        .EXAMPLE
        PS> if(get-variable -name State){
        PS>     $State['MajorSetupVersion'] = get-OSFullVersionTDO -MajorVersion ;
        PS>     $State['MinorSetupVersion'] = get-OSFullVersionTDO -MinorVersion ;
        PS> } else{
        PS>     #$SetupVersion = Get-FileVersionTDO $CabExSetup.fullname ;
        PS>     $MajorSetupVersion = get-OSFullVersionTDO -MajorVersion ;
        PS>     $MinorSetupVersion = get-OSFullVersionTDO -MinorVersion ;
        PS> } ; 
        Demo use of the -MajorVersion & -MinorVersion params
        .LINK
        https://github.org/tostka/verb-desktop/
        #>
        [CmdletBinding()]
        [alias('get-OSFullVersion')]
        PARAM(
            [Parameter(HelpMessage = "Switch to return solely the MajorVersion value[-MajorVersion]")]
                [switch]$MajorVersion,
            [Parameter(HelpMessage = "Switch to return solely the MinorVersion value[-MinorVersion]")]
                [switch]$MinorVersion
        ) ; 
        if($MajorVersion -AND $MinorVersion){
            $smsg = "*BOTH* -MajorVersion & -MinorVersion SPECIFIED: SPECIFY ONE OR THE OTHER!" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            BREAK ; 
        } ; 
        if (get-command get-ciminstance -ea 0) {
            $OS = Get-ciminstance -class  Win32_OperatingSystem ; 
        } else {
            $OS = Get-WmiObject Win32_OperatingSystem ; 
        } ;
        $MajorOSVersion= [string]($OS| Select-Object @{n="Major";e={($_.Version.Split(".")[0]+"."+$_.Version.Split(".")[1])}}).Major ; 
        $MinorOSVersion= [string]($OS| Select-Object @{n="Minor";e={($_.Version.Split(".")[2])}}).Minor ; 
        $FullOSVersion= ('{0}.{1}' -f $MajorOSVersion, $MinorOSVersion) ;
        if($MajorVersion){
            $smsg = "-MajorVersion: returning to pipeline $($MajorVersion)" ;
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            $MajorVersion | write-output 
        } elseif($MinorVersion){
            $MinorOSVersion | write-output ; 
            $smsg = "-MinorOSVersion: returning to pipeline $($MinorOSVersion)" ;
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
        }else{ 
            $smsg = "Returning FullOSVersionto pipeline $($FullOSVersion)" ;
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
                if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            } ;
            $FullOSVersion | write-output  ;
        }
    }
#endregion GET_OSFULLVERSIONTDO ; #*------^ END get-OSFullVersionTDO ^------

