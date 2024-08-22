# 
#*------v Function set-AuthenticodeSignatureTDO v------
function set-AuthenticodeSignatureTDO {
    <#
    .SYNOPSIS
    set-AuthenticodeSignatureTDO - wrapper for Set-AuthenticodeSignature, adds an Authenticode signature to any file that supports Subject Interface Package (SIP). Discovers & validates usablility of installed local codesigning certificate in CU\my or LM\my
    .NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : set-AuthenticodeSignatureTDO.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Authenticode,Signature,CodeSigning,Developoment
    REVISIONS   :
    * 8:57 AM 8/22/2024 Make it ones fully tooled up solution for all code signing; ren to proper verb set-AuthenticodeSignatureTDO() -> set-AuthenticodeSignatureTDO set orig as alias; added call to new Test-CertificateTDO; add test Authenticode prior to signing; 
    10:45 AM 10/14/2020 added cert hunting into cert:\LocalMachine\my -codesigning as well as currentuser
    7:56 AM 6/19/2018 added -whatif & -showdebug params
    10:46 AM 1/16/2015 corrected $oReg|$oRet typo that broke status attrib
    10:20 AM 1/15/2015 rewrote into pipeline format
    9:50 AM 1/15/2015 added a $f.name echo to see if it's doing anything
    8:54 AM 1/8/2015 - added play-beep to end
    10:01 AM 12/30/2014
    .PARAMETER file
    file name(s) to appl authenticode signature into.
    .PARAMETER whatIf
    Whatif Flag  [-whatIf]
    .INPUTS
    Accepts piped input (computername).
    .OUTPUTS
    Outputs CustomObject to pipeline
    .DESCRIPTION
    set-AuthenticodeSignatureTDO - wrapper for Set-AuthenticodeSignature, adds an Authenticode signature to any file that supports Subject Interface Package (SIP). Discovers & validates usablility of installed local codesigning certificate in CU\my or LM\my
    .EXAMPLE
    PS> $rgxfiles='\.(CAT|MSI|JAR,OCX|PS1|PSM1|PSD1|PS1XML|PSC1|MSP|CMD|BAT|VBS)`$' ;
    PS> $files = gci c:\pathto* -recur |?{`$_.extension -match `$rgxfiles}  ;
    PS> verb-IO\set-AuthenticodeSignatureTDO -file `$files.fullname ;
    Sign signable file types extentions in checked tree
    .EXAMPLE
    PS> get-childitem *.ps1,*.psm1,*.psd1,*.psd1,*.ps1xml | Get-AuthenticodeSignature | Where {!(Test-AuthenticodeSignature $_ -Valid)} | gci | Set-AuthenticodeSignature
    Set sigs on all ps files with invalid sigs (for ps, it's: ps1, psm1, psd1, dll, exe, and ps1xml files)
    .EXAMPLE
    PS> set-AuthenticodeSignatureTDO C:\usr\work\lync\scripts\*-luser.ps1
    .EXAMPLE
    PS> get-childitem C:\usr\work\lync\scripts\*-luser.ps1 | %{set-AuthenticodeSignatureTDO $_}
    .EXAMPLE
    PS> get-childitem c:\usr\local\bin\*.ps1 | set-AuthenticodeSignatureTDO ; 
    Pipeline demo
    #>
    [CmdletBinding()]
    [Alias('sign-file')]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, HelpMessage = 'What file(s) would you like to sign?')]
            [system.io.fileinfo[]]$file, 
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
            [switch] $whatIf
    ) ;
    # alt: the simplest option:
    # $cert = @(get-childitem cert:\currentuser\my -codesigning)[0] ; Set-AuthenticodeSignature -filepath c:\usr\work\ps\scripts\authenticate-profile.ps1 -Certificate $cert
    BEGIN {
        if(-not(get-command Test-CertificateTDO)){
            #*------v Function test-CertificateTDO v------
            function test-CertificateTDO {
                <#
                .SYNOPSIS
                test-CertificateTDO -  Tests specified certificate for certificate chain and revocation
                .NOTES
                Version     : 0.63
                Author      : Vadims Podans
                Website     : http://www.sysadmins.lv/
                Twitter     : 
                CreatedDate : 2024-08-22
                FileName    : test-CertificateTDO.ps1
                License     : (none asserted)
                Copyright   : Vadims Podans (c) 2009
                Github      : https://github.com/tostka/verb-IO
                Tags        : Powershell,FileSystem,File,Lock
                AddedCredit : Todd Kadrie
                AddedWebsite: http://www.toddomation.com
                AddedTwitter: @tostka / http://twitter.com/tostka
                REVISIONS
                * 2:29 PM 8/22/2024 fixed process looping (lacked foreach); added to verb-Network; retoololed to return a testable summary report object (summarizes Subject,Issuer,Not* dates,thumbprint,Usage (FriendlyName),isSelfSigned,Status,isValid,and the full TrustChain); 
                    added param valid on [ValidateSet, CRLMode, CRLFlag, VerificationFlags ; updated CBH; added support for .p12 files (OpenSSL pfx variant ext), rewrite to return a status object
                * 9:34 AM 8/22/2024 Vadims Podans posted poshcode.org copy from web.archive.org, grabbed 11/2016 (orig dates from 2009, undated beyond copyright line)
                .DESCRIPTION
                test-CertificateTDO -  Tests specified certificate for certificate chain and revocation status for each certificate in chain
                    exluding Root certificates
    
                    Based on Vadim Podan's 2009-era Test-Certificate function, expanded/reworked to return a testable summary report object (summarizes Subject,Issuer,NotBefore|After dates,thumbprint,Usage(FriendlyName),isSelfSigned,Status,isValid


                    ## Note:Powershell v4+ includes a native Test-Certificate cmdlet that returns a boolean, and supports -DNSName to test a given fqdn against the CN/SANs list on the certificate. 
                    Limitations of that alternate, for non-public certs, include that it lacks the ability to suppress CRL-testing to evaluate *private/internal-CA-issued certs, which lack a publcly resolvable CRL url. 
                    Those certs, will always fail the bundled Certificate Revocation List checks. 

                    This code does not have that issue: test-CertificateTDO used with -CRLMode NoCheck & -CRLFlag EntireChain validates a given internal Cert is...
                    - in daterange, 
                    - and has a locally trusted chain, 
                    ...where psv4+ test-certificate will always fail a non-CRL-accessible cert.

                    ### Examples of use of that cmdlet:
    
                    Demo 1:

                    PS C:\>Get-ChildItem -Path Cert:\localMachine\My | Test-Certificate -Policy SSL -DNSName "dns=contoso.com"

                    This example verifies each certificate in the MY store of the local machine and verifies that it is valid for SSL
                    with the DNS name specified.


                    Demo 2:

                    PS C:\>Test-Certificate –Cert cert:\currentuser\my\191c46f680f08a9e6ef3f6783140f60a979c7d3b -AllowUntrustedRoot
                    -EKU "1.3.6.1.5.5.7.3.1" –User

                    This example verifies that the provided EKU is valid for the specified certificate and its chain. Revocation
                    checking is not performed.
        
                .PARAMETER Certificate
                Specifies the certificate to test certificate chain. This parameter may accept X509Certificate, X509Certificate2 objects or physical file path. this paramter accept pipeline input
                .PARAMETER Password
                Specifies PFX file password. Password must be passed as SecureString.
                .PARAMETER CRLMode
                Sets revocation check mode. May contain on of the following values:
       
                    - Online - perform revocation check downloading CRL from CDP extension ignoring cached CRLs. Default value
                    - Offline - perform revocation check using cached CRLs if they are already downloaded
                    - NoCheck - specified certificate will not checked for revocation status (not recommended)
                .PARAMETER CRLFlag
                Sets revocation flags for chain elements. May contain one of the following values:
       
                    - ExcludeRoot - perform revocation check for each certificate in chain exluding root. Default value
                    - EntireChain - perform revocation check for each certificate in chain including root. (not recommended)
                    - EndCertificateOnly - perform revocation check for specified certificate only.
                .PARAMETER VerificationFlags
                Sets verification checks that will bypassed performed during certificate chaining engine
                check. You may specify one of the following values:
       
                - NoFlag - No flags pertaining to verification are included (default).
                - IgnoreNotTimeValid - Ignore certificates in the chain that are not valid either because they have expired or they are not yet in effect when determining certificate validity.
                - IgnoreCtlNotTimeValid - Ignore that the certificate trust list (CTL) is not valid, for reasons such as the CTL has expired, when determining certificate verification.
                - IgnoreNotTimeNested - Ignore that the CA (certificate authority) certificate and the issued certificate have validity periods that are not nested when verifying the certificate. For example, the CA cert can be valid from January 1 to December 1 and the issued certificate from January 2 to December 2, which would mean the validity periods are not nested.
                - IgnoreInvalidBasicConstraints - Ignore that the basic constraints are not valid when determining certificate verification.
                - AllowUnknownCertificateAuthority - Ignore that the chain cannot be verified due to an unknown certificate authority (CA).
                - IgnoreWrongUsage - Ignore that the certificate was not issued for the current use when determining certificate verification.
                - IgnoreInvalidName - Ignore that the certificate has an invalid name when determining certificate verification.
                - IgnoreInvalidPolicy - Ignore that the certificate has invalid policy when determining certificate verification.
                - IgnoreEndRevocationUnknown - Ignore that the end certificate (the user certificate) revocation is unknown when determining     certificate verification.
                - IgnoreCtlSignerRevocationUnknown - Ignore that the certificate trust list (CTL) signer revocation is unknown when determining certificate verification.
                - IgnoreCertificateAuthorityRevocationUnknown - Ignore that the certificate authority revocation is unknown when determining certificate verification.
                - IgnoreRootRevocationUnknown - Ignore that the root revocation is unknown when determining certificate verification.
                - AllFlags - All flags pertaining to verification are included.   
                .INPUTS
                None. Does not accepted piped input.
                .OUTPUTS
                This script return general info about certificate chain status 
                .EXAMPLE
                PS> Get-ChilItem cert:\CurrentUser\My | test-CertificateTDO -CRLMode "NoCheck"
                Will check certificate chain for each certificate in current user Personal container.
                Specifies certificates will not be checked for revocation status.
                .EXAMPLE
                PS> $output = test-CertificateTDO C:\Certs\certificate.cer -CRLFlag "EndCertificateOnly"
                Will check certificate chain for certificate that is located in C:\Certs and named
                as Certificate.cer and revocation checking will be performed for specified certificate oject
                .EXAMPLE
                PS> $output = gci Cert:\CurrentUser\My -CodeSigningCert | Test-CertificateTDO -CRLMode NoCheck -CRLFlag EntireChain -verbose ;
                Demo Self-signed codesigning tests from CU\My, skips CRL revocation checks (which self-signed wouldn't have); validates that the entire chain is trusted.
                .EXAMPLE
                PS> if( gci Cert:\CurrentUser\My -CodeSigningCert | Test-CertificateTDO -CRLMode NoCheck -CRLFlag EntireChain |  ?{$_.valid -AND $_.Usage -contains 'Code Signing'} ){
                PS>         write-host "A-OK for code signing!"
                PS> } else { write-warning 'Bad Cert for code signing!'} ; 
                Demo conditional branching on basis of output valid value.
                .LINK
                https://web.archive.org/web/20160715110022/poshcode.org/1633
                .LINK
                https://github.com/tostka/verb-io
                #>
                #requires -Version 2.0
                [CmdletBinding()]
                [Alias('rol','restart-Outlook')]
                PARAM(
                    #[Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to file[-path 'c:\pathto\file.txt']")]
                    #[Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0,HelpMessage="Specifies the certificate to test certificate chain. This parameter may accept X509Certificate, X509Certificate2 objects or physical file path. this paramter accept pipeline input)"]
                    [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Specifies the certificate to test certificate chain. This parameter may accept X509Certificate, X509Certificate2 objects or physical file path. this paramter accepts pipeline input")]
                        $Certificate,
                    [Parameter(HelpMessage="Specifies PFX|P12 file password. Password must be passed as SecureString.")]
                        [System.Security.SecureString]$Password,
                    [Parameter(HelpMessage="Sets revocation check mode (Online|Offline|NoCheck)")]
                        [ValidateSet('Online','Offline','NoCheck')]
                        [System.Security.Cryptography.X509Certificates.X509RevocationMode]$CRLMode = "Online",
                    [Parameter(HelpMessage="Sets revocation flags for chain elements ('ExcludeRoot|EntireChain|EndCertificateOnly')")]
                        [ValidateSet('ExcludeRoot','EntireChain','EndCertificateOnly')]
                        [System.Security.Cryptography.X509Certificates.X509RevocationFlag]$CRLFlag = "ExcludeRoot",
                    [Parameter(HelpMessage="Sets verification checks that will bypassed performed during certificate chaining engine check (NoFlag|IgnoreNotTimeValid|IgnoreCtlNotTimeValid|IgnoreNotTimeNested|IgnoreInvalidBasicConstraints|AllowUnknownCertificateAuthority|IgnoreWrongUsage|IgnoreInvalidName|IgnoreInvalidPolicy|IgnoreEndRevocationUnknown|IgnoreCtlSignerRevocationUnknown|IgnoreCertificateAuthorityRevocationUnknown|IgnoreRootRevocationUnknown|AllFlags)")]
                        [validateset('NoFlag','IgnoreNotTimeValid','IgnoreCtlNotTimeValid','IgnoreNotTimeNested','IgnoreInvalidBasicConstraints','AllowUnknownCertificateAuthority','IgnoreWrongUsage','IgnoreInvalidName','IgnoreInvalidPolicy','IgnoreEndRevocationUnknown','IgnoreCtlSignerRevocationUnknown','IgnoreCertificateAuthorityRevocationUnknown','IgnoreRootRevocationUnknown','AllFlags')]
                        [System.Security.Cryptography.X509Certificates.X509VerificationFlags]$VerificationFlags = "NoFlag"
                ) ;
                BEGIN { 
                    $Verbose = ($VerbosePreference -eq 'Continue') 
                    $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 ; 
                    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain ; 
                    $chain.ChainPolicy.RevocationFlag = $CRLFlag ; 
                    $chain.ChainPolicy.RevocationMode = $CRLMode ; 
                    $chain.ChainPolicy.VerificationFlags = $VerificationFlags ; 
                    #*------v Function _getstatus_ v------
                    function _getstatus_ ($status, $chain, $cert){
                        # add a returnable output object
                        if($host.version.major -ge 3){$oReport=[ordered]@{Dummy = $null ;} }
                        else {$oReport=@{Dummy = $null ;}} ;
                        If($oReport.Contains("Dummy")){$oReport.remove("Dummy")} ;
                        $oReport.add('Subject',$cert.Subject); 
                        $oReport.add('Issuer',$cert.Issuer); 
                        $oReport.add('NotBefore',$cert.NotBefore); 
                        $oReport.add('NotAfter',$cert.NotAfter);
                        $oReport.add('Thumbprint',$cert.Thumbprint); 
                        $oReport.add('Usage',$cert.EnhancedKeyUsageList.FriendlyName) ; 
                        $oReport.add('isSelfSigned',$false) ; 
                        $oReport.add('Status',$status); 
                        $oReport.add('Valid',$false); 
                        if($cert.Issuer -eq $cert.Subject){
                            $oReport.SelfSigned = $true ;
                            write-host -foregroundcolor yellow "NOTE⚠️:Current certificate $($cert.SerialNumber) APPEARS TO BE *SELF-SIGNED* (SUBJECT==ISSUER)" ; 
                        } ; 
                        # Return the list of certificates in the chain (the root will be the last one)
                        $oReport.add('TrustChain',($chain.ChainElements | ForEach-Object {$_.Certificate})) ; 
                        write-verbose "Certificate Trust Chain`n$(($chain.ChainElements | ForEach-Object {$_.Certificate}|out-string).trim())" ; 
                        if ($status) {
                            $smsg = "Current certificate $($cert.SerialNumber) chain and revocation status is valid" ; 
                            if($CRLMode -eq 'NoCheck'){
                                $smsg += "`n(NOTE:-CRLMode:'NoCheck', no Certificate Revocation Check performed)" ; 
                            } ; 
                            write-host -foregroundcolor green $smsg;
                            $oReport.valid = $true ; 
                        } else {
                            Write-Warning "Current certificate $($cert.SerialNumber) chain is invalid due of the following errors:" ; 
                            $chain.ChainStatus | foreach-object{Write-Host $_.StatusInformation.trim() -ForegroundColor Red} ; 
                            $oReport.valid = $false ; 
                        } ; 
                        New-Object PSObject -Property $oReport | write-output ;
                    } ; 
                    #*------^ END Function _getstatus_ ^------
                } ;
                PROCESS {
                    foreach($item in $Certificate){
                        if ($item -is [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
                            $status = $chain.Build($item)   ; 
                            $report = _getstatus_ $status $chain $item   ; 
                            return $report ;
                        } else {
                            if (!(Test-Path $item)) {
                                Write-Warning "Specified path is invalid" #return
                                $valid = $false ; 
                                return $false ; 
                            } else {
                                if ((Resolve-Path $item).Provider.Name -ne "FileSystem") {
                                    Write-Warning "Spicifed path is not recognized as filesystem path. Try again" ; #return   ; 
                                    return $false ; 
                                } else {
                                    $item = get-item $(Resolve-Path $item)   ; 
                                    switch -regex ($item.Extension) {
                                        "\.CER|\.DER|\.CRT" {$cert.Import($item.FullName)}  
                                        "\.PFX|\.P12" {
                                                if (!$Password) {$Password = Read-Host "Enter password for PFX file $($item)" -AsSecureString}
                                                        $cert.Import($item.FullName, $password, "UserKeySet")  ;  
                                        }  
                                        "\.P7B|\.SST" {
                                                $cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection ; 
                                                $cert.Import([System.IO.File]::ReadAllBytes($item.FullName))   ; 
                                        }  
                                        default {
                                            Write-Warning "Looks like your specified file is not a certificate file" #return
                                            return $false ; 
                                        }  
                                    }  
                                    $cert | foreach-object{
                                            $status = $chain.Build($_)  
                                            $report = _getstatus_ $status $chain $_   ; 
                                            return $report ;
                                    }  
                                    $cert.Reset()  
                                    $chain.Reset()  
                                } ; 
                            } ; 
                        }   ; 
                    } ;  # loop-E $Certificate
                } ;  # PROC-E
                END {} ; 
            } ; 
            #*------^ END Function test-CertificateTDO ^------
        } ;         
        $error.clear() ;
        TRY {
            if($cert = @(get-childitem cert:\currentuser\my -codesigning -ea 0 )[0]){
                write-verbose "found matching -codesigning CU\My cert:`n$(($cert|out-string).trim())" ; 
            } elseif($cert = @(get-childitem cert:\LocalMachine\my -codesigning -ea 0 )[0]){
                write-verbose "found -codesigning  matching LM\My cert:`n$(($cert|out-string).trim())" ; 
            } else { 
                throw "Unable to locate a Signing Cert in either`ncert:\currentuser\my -codesigning`nor cert:\LocalMachine\my -codesigning. ABORTING!" ; 
            } 
            # if( gci Cert:\CurrentUser\My -CodeSigningCert | Test-CertificateTDO -CRLMode NoCheck -CRLFlag EntireChain |  ?{$_.valid -AND $_.Usage -contains 'Code Signing'} ){
            # Signing cert currently used is a locally-signed private cert, which won't pass public CRL checks, so we suppress the CRL check, but have the full chain validated
            $pltTCT=[ordered]@{
                Certificate = $cert ;
                CRLMode = 'NoCheck' ;
                CRLFlag = 'EntireChain' ;
            } ;
            $smsg = "test-CertificateTDO w`n$(($pltTCT|out-string).trim())" ; 
            write-verbose $smsg ; 
            if($bRet = test-CertificateTDO @pltTCT |  ?{$_.valid -AND $_.Usage -contains 'Code Signing'} ){
                write-verbose "Certificate...`n`n$(($bret.TrustChain | %{$_| ft -a subject,notbefore,notafter,issuer}|out-string).trim())`n`n... is valid for CodeSigning" ; 
            } else { 
                $smsg = "Unable to locate a usable -codesigning certificate in either CU\My or LM\My! ABORTING!" ; 
                write-warning $smsg ; 
                throw $smsg ;
                break ; 
            } ; 
        } CATCH {
            Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
            Exit #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ; 

        # check if using Pipeline input or explicit params:
        if ($rPSCmdlet.MyInvocation.ExpectingInput) {
            $smsg = "Data received from pipeline input: '$($InputObject)'" ;
            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        } else {
            # doesn't actually return an obj in the echo
            #$smsg = "Data received from parameter input: '$($InputObject)'" ;
            #if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            #else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        } ;
    }  # BEG-E
    PROCESS {
        foreach ($f in $file) {
            #$continue = $true
            $oRet = $null ; 
            TRY {
                if (-not ((Get-AuthenticodeSignature -FilePath $f.fullname).status -eq 'Valid') ){
                    $oRet = Set-AuthenticodeSignature -filepath $f -Certificate $cert -whatif:$($whatif) ;
                }else{
                    write-host "($($f.fullname) has a valid existing AuthenticodeSignature, skipping)" ; 
                } ; 
            }CATCH {
                Write "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
            } # try/cat-E
            if ($oRet) {
                #write-verbose "returning updated Sig to pipeline" ; 
                #Write-Output $oRet
                write-host "`n$(($oRet|ft -a |out-string).trim())" ; 
            } 
        } # loop-E
    } # Proc-E
} #*------^ END Function set-AuthenticodeSignatureTDO ^------
