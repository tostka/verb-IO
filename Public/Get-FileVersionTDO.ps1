# Get-FileVersionTDO.ps1


#region GET_FILEVERSIONTDO ; #*------v Get-FileVersionTDO v------
Function Get-FileVersionTDO {
        <#
        .SYNOPSIS
        Get-FileVersionTDO - Returns the (get-command `$File).FileVersionInfo.ProductVersion property for versioned leaf file objects
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : Get-FileVersionTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)

        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL
        REVISIONS
        * 2:35 PM 2/17/2026 add missing base alias
        * 9:31 AM 10/2/2025 add alias: 'Get-DetectedFileVersionTDO'
        * 9:13 AM 9/24/2025 moved vx10->vxio
        * 10:26 AM 9/22/2025 ren Get-DetectedFileVersionTDO -> Get-FileVersionTDO (better descriptive name for what it does, better mnemomic) ; port to vio from xopBuildLibrary; add CBH, and Adv Function specs
            added CBH; init; aliased orig name
        .DESCRIPTION
        Get-FileVersionTDO - Returns the (get-command `$File).FileVersionInfo.ProductVersion property for versioned leaf file objects
        
        Advantage of using gcm: if it's in path, raw .exe's work
        but fully path'd works as well, anywhere. 
        .PARAMETER File
        Path to leaf versioned file object to be checked[-File 'c:\pathto\ExSetup.exe']
        .INPUTS
        None, no piped input.
        .OUTPUTS
        System.Object summary of Exchange server descriptors, and service statuses.
        .EXAMPLE
        PS> $SourcePath = 'D:\cab\ExchangeServer2016-x64-CU23-ISO\unpacked'  ; 
        PS> $SetupVersion= Get-FileVersionTDO "$($SourcePath)\Setup\ServerRoles\Common\ExSetup.exe" ; 
        PS> $SetupVersionText= Get-SetupTextVersion $SetupVersion ; 
        Demo resolving cab ExSetup.exe to semantic version number
        .EXAMPLE
        PS> $ExBinSetupVersion = Get-DetectedFileVersion ExSetup.exe ; 
        PS> if($ExBinSetupVersionText = Resolve-xopBuildSemVersToTextNameTDO -FileVersion $ExBinSetupVersion | select -expand ProductName){
        PS>     write-host -object ('{0} (build {1})' -f $ExBinSetupVersionText, $ExBinSetupVersion)
        PS> }else{
        PS>     write-warning "unable to resolve -FileVersion:$($ExBinSetupVersion) to a functional version ProductName" ; 
        PS> }
        Demo Resolving discovered installed Exchange bin ExSetup.exe revision semantic version number.
        .LINK
        https://github.org/tostka/verb-io/
        #>
        [CmdletBinding()]
        [alias('Get-DetectedFileVersion','Get-DetectedFileVersionTDO','Get-FileVersion')]
        PARAM(
            [Parameter(Mandatory=$true,HelpMessage = "Path to leaf versioned file object to be checked[-File 'c:\pathto\ExSetup.exe']")]
                [string]$File
        ) ;
        $res= 0 ; 
        If( Test-Path $File) {
            $res= (Get-Command $File).FileVersionInfo.ProductVersion ; 
        } Else {
            write-verbose "failed inital test-path:$($file)`nretrying raw gcm (will auto-resolve in-path targets)"
            if($gcm= (Get-Command $File -ea 0)){
                write-verbose "resolved gcm:$($file) to:$($gcm.source)"
                $res = $gcm.FileVersionInfo.ProductVersion
            }else{
                write-verbose "failed:(Get-Command $($File))" ; 
                $res= 0
            } ; 
        } ; 
        return $res 
    } #endregion GET_FILEVERSIONTDO ; #*------^ END Get-FileVersionTDO ^------

