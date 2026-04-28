# set-RDPFileSignatureTDO.ps1

#region SET_RDPFILESIGNATURETDO ; #*------v set-RDPFileSignatureTDO v------
function set-RDPFileSignatureTDO {
    <#
    .SYNOPSIS
    set-RDPFileSignatureTDO - Digitally sign .rdp TermServ connection files with specified local certificate (wrapper for rdpsign.exe)
    .NOTES
    Author: Taylor Gibb
    Website:	https://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Additional Credits:
    REVISIONS   :
    * 12:59 PM 4/28/2026 init
    .DESCRIPTION
    
    set-RDPFileSignatureTDO - Digitally sign .rdp TermServ connection files with specified local certificate (wrapper for rdpsign.exe)

    [Signing .rdp files with Signotaurbr / (and surviving the April - www.finalbuilder.com/](https://www.finalbuilder.com/resources/blogs/signing-rdp-files-with-signotaur-and-surviving-the-april-windows-update)

    ## What Microsoft changed

    The April cumulative addresses [CVE-2026-26151](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2026-26151). Two user-visible things came with it:

    1. The Remote Desktop Connection warning dialog was redesigned. It now 
        lists every resource the connection can redirect (drives, printers, clipboard, 
        USB, etc.) with individual checkboxes, and **every box is off by default**. 
        Users have to opt in to each one on every connection, every time. 
    2. The trust criteria for signed `.rdp` files tightened. Pre-April, a file 
        signed by an untrusted cert got a yellow "Verify the publisher" banner. 
        Post-April, the same file gets an orange "Caution: Unknown remote connection" 
        banner — visually indistinguishable from an unsigned file

 
    Here's what the new per-launch dialog looks like. For an unsigned file:

    [The RDP security warning dialog for an unsigned file: an orange 'Caution: Unknown remote connection' banner, 'Unknown publisher', and per-redirection checkboxes all off by default.]

    And for a file signed by a publisher Windows can verify:

    [The RDP security warning dialog for a signed file: a yellow 'Verify the publisher of this remote connection' banner with the publisher name, and the same per-redirection checkboxes.]

    Separately, the first time any user opens an `.rdp` file after installing the update, Windows shows a one-time educational dialog explaining what `.rdp` files are and why they can be dangerous:

    [The first-launch educational dialog shown once per user account after installing KB5083769, explaining what RDP files are and the associated phishing risks.]

    Once dismissed, it doesn't reappear for that account.


    Here's what recipient machines need for a signed `.rdp` file to open with no warning dialog at all:

    1.  The signing certificate's chain must terminate in a root the client machine trusts.
        Commercial code-signing certs (DigiCert, Sectigo, etc.) chain to roots 
        Windows already trusts. For an internal CA or self-signed cert, the root has to 
        be imported into `Cert:\*\Root` on each client. 
    2.  A Remote Desktop trust policy must be in place that whitelists your 
        signing certificate's SHA-1 thumbprint. This lives at either 
        `HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services` (machine-wide, requires admin) 
        or `HKCU\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services` (per-user, no admin required), and needs two values: 
        -   `AllowSignedFiles` — REG\_DWORD, set to `1`
        -   `TrustedCertThumbprints` — REG\_SZ, the SHA-1 thumbprint of your signing cert, uppercase, no spaces (semicolon-separated if you have more than one)

    A word of warning about one trap we hit: `TrustedCertThumbprints` is a 
    whitelist on top of normal chain validation, not a replacement for it. Dropping 
    a self-signed cert's thumbprint into the list without also importing the cert 
    into a trusted root store does nothing. If you've tried this and wondered why 
    it didn't work, that's why. 

    .PARAMETER Path
    .Rdp File paths[-path c:\pathto\file.rdp]
    .PARAMETER Thumbprint
    Signing certificate thumbprint (locally installed)[-Thumbprint 9A9A999A999A9A9999999A9A9AAA99AAA99AA9A9]    
    .INPUTS
    Accepts piped input Path.
    .OUTPUTS
    Returns a path to signed object on a successful signing
    .EXAMPLE
    PS> $results = set-RDPFileSignatureTDO -path 'C:\Users\aaaaaAAA\Desktop\rdp-faves\AAAAAAAAAAA-AAA-Ex16-Mbx1-1024x768-SID.RDP: confirmed' -Thumbprint 9A9A999A999A9A9999999A9A9AAA99AAA99AA9A9 ;
    PS> $results ; 

    Report on results of signing file   
    .EXAMPLE
    PS> gci "$($env:USERPROFILE)\Desktop\rdp-faves*.rdp" | select -first 1  | set-RDPFileSignatureTDO -verbose ;
    Demo signing all .rdp files in the specified dir, with pipeline input.
    .EXAMPLE
    PS> $Thumbprint = "9A9A999A999A9A9999999A9A9AAA99AAA99AA9A9"
    PS> $RegPath = 'HKCU:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
    PS> write-verbose "Create the key path if it does not exist" ; 
    PS> if (-not (Test-Path $RegPath)) {New-Item -Path $RegPath -Force | Out-Null} ; 
    PS> New-ItemProperty  -Path $RegPath  -Name 'AllowSignedFiles'  -PropertyType DWord  -Value 1  -Force | Out-Null ; 
    PS> New-ItemProperty -Path $RegPath -Name 'TrustedCertThumbprints' -PropertyType String -Value '$($Thumbprint)' -Force | Out-Null ; 
    Code to configure HKCU required keys and values to register the signing certificate used, to be trusted to load signed .rdp files without prompts
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('sign-RdpFile','sign-RdpFileTDO')]
    PARAM(
        [Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True, HelpMessage = '.Rdp File paths[-path c:\pathto\file.rdp]')]
            [Alias('PsPath')]
            [ValidateScript({Test-Path $_.fullname})]
            [ValidateScript({ if([IO.Path]::GetExtension($_) -ne ".rdp") { throw "Path must point to an .rdp file" } $true })]
            [system.io.fileinfo[]]$Path,
        [Parameter(Mandatory = $false,HelpMessage = 'Signing certificate thumbprint (locally installed)[-Thumbprint 9A9A999A999A9A9999999A9A9AAA99AAA99AA9A9]')]
            [ValidateNotNullOrEmpty()]
            [ValidatePattern("[0-9a-fA-F]{40}")]           
            [string]$Thumbprint = $TORMeta['SignCertThumb']
    ) ; 
    BEGIN {
        TRY{
            $prpCert = 'Thumbprint','Subject','NotAfter','NotBefore' ; 
            ($RDPSignExec = get-command rdpsign.exe -ea STOP).source ; 
            $cleanThumbprint = $Thumbprint -replace '\s','' ; 
            if($Cert = Get-ChildItem "Cert:\*\My\$($cleanThumbprint)" -ea STOP | 
                Where-Object { $_.EnhancedKeyUsageList -match "Code Signing" } | 
                    sort pspath | select -last 1
            ){
                $smsg = "Matched Certificate:" ; 
                $smsg += "`n`n$(($Cert | ft -a $prpCert|out-string).trim())" ; 
                write-verbose $smsg ; 
            }else{
                $smsg = "UNABLE TO LOCATE CERT IN LOCAL OR CURRENTUSER\MY\$($THUMBPRINT)!" ; 
                write-warning $smsg ; 
                throw $smsg ; 
            }
            
        } CATCH {
            $ErrTrapd=$Error[0] ;
            write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            return ; 
        } ;

        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;

        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 
    } ;  # BEGIN-E
    PROCESS {
        $Error.Clear() ; 
        foreach ($item in $Path){
            TRY{
                Write-Verbose "Signing RDP file: $($item.fullname)" ; 
                #& rdpsign.exe /sha256 $cleanThumbprint $RdpFilePath ; 
                $ret = & $RDPSignExec /sha256 $cleanThumbprint $item.fullname; 
                if(gc $item.fullname | Where-Object { $_ -match "^signature" -or $_ -match "^signscope" }){
                    $smsg = $ret ; 
                    $smsg += "`n$($item.fullname): confirmed '^(signature|signscope) applied" ; 
                    write-verbose $smsg ; 
                    $item.fullname | write-output 
                }else{
                    $smsg = "$($item.fullname): MISSING '^(signature|signscope)!" ; 
                    write-warning $smsg ; 
                }
            } CATCH {$ErrTrapd=$Error[0] ;
                write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            } ;
        } ;  # loop-E
    }  # if-E PROC
    END{} ; 
} ; 
#endregion SET_RDPFILESIGNATURETDO ; #*------^ END set-RDPFileSignatureTDO ^------