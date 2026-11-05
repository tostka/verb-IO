# test-AuthenticodeSignatureTDO.ps1
 
#*------v test-AuthenticodeSignatureTDO.ps1 v------
function test-AuthenticodeSignatureTDO {
    <#
    .SYNOPSIS
    test-AuthenticodeSignatureTDO - wrapper for get-AuthenticodeSignature & vio\Test-XmlSignatureTDO, tests Authenticode signature to any file that supports Subject Interface Package (SIP). Tests xml sig for the xml variant. Discovers & validates usablility of installed local codesigning certificate in CU\my or LM\my
    .NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2026-10-15
    FileName    : test-AuthenticodeSignatureTDO.ps1
    License     : MIT License
    Copyright   : (c) 2026 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Authenticode,Signature,CodeSigning,Developoment
    REVISIONS   :
    * 1:24 PM 11/5/2026 reworked fail logic to skip throw (which can't be properly caught for handling)
    * 12:55 PM 11/4/2026 fixed typo in rgx match
    * 9:05 AM 10/15/2026 init
    .PARAMETER file
    file name(s) to appl authenticode signature into.
    .INPUTS
    Accepts piped input (computername).
    .OUTPUTS
    Outputs CustomObject to pipeline
    .DESCRIPTION
    test-AuthenticodeSignatureTDO - wrapper for get-AuthenticodeSignature & vio\Test-XmlSignatureTDO, tests Authenticode signature to any file that supports Subject Interface Package (SIP). Tests xml sig for the xml variant. Discovers & validates usablility of installed local codesigning certificate in CU\my or LM\my
    .EXAMPLE
    PS> $rgxfiles='\.(CAT|MSI|JAR,OCX|PS1|PSM1|PSD1|XML|PS1XML|PSC1|MSP|CMD|BAT|VBS)`$' ;
    PS> $files = gci c:\pathto* -recur |?{`$_.extension -match `$rgxfiles}  ;
    PS> verb-IO\test-AuthenticodeSignatureTDO -file `$files.fullname ;
    Sign signable file types extentions in checked tree
    .EXAMPLE
    PS> get-childitem *.ps1,*.psm1,*.psd1,*.psd1,*.ps1xml | Get-AuthenticodeSignature | Where {!(Test-AuthenticodeSignature $_ -Valid)} | gci | Set-AuthenticodeSignature
    Set sigs on all ps files with invalid sigs (for ps, it's: ps1, psm1, psd1, dll, exe, and ps1xml files)
    .EXAMPLE
    PS> test-AuthenticodeSignatureTDO C:\usr\work\lync\scripts\*-luser.ps1
    .EXAMPLE
    PS> get-childitem C:\usr\work\lync\scripts\*-luser.ps1 | %{test-AuthenticodeSignatureTDO $_}
    .EXAMPLE
    PS> get-childitem c:\usr\local\bin\*.ps1 | test-AuthenticodeSignatureTDO ; 
    Pipeline demo
    .EXAMPLE
    PS> $ModDirPath = "C:\sc\xopBuildLibrary" ; 
    PS> $rgxfiles='\.(CAT|MSI|JAR,OCX|PS1|PSM1|PSD1|PS1XML|PSC1|MSP|CMD|BAT|VBS)$' ;
    PS> $files = gci "$($ModDirPath)\*" -recur |?{$_.extension -match $rgxfiles} 
    PS> verb-IO\test-AuthenticodeSignatureTDO -file $files.fullname ;    
    Demo signing all suitable files in a dyn-include module. All files regarldess of location below module root.
    .EXAMPLE
    PS> $ModDirPath = "C:\sc\xopBuildLibrary" ; 
    PS> $rgxfiles='\.(CAT|MSI|JAR,OCX|PS1|PSM1|PSD1|PS1XML|PSC1|MSP|CMD|BAT|VBS)$' ;
    PS> $rgxIncludeDirs='\\(Public|Internal|Classes)\\' ;
    PS> $files = gci "$($ModDirPath)\*" -recur |?{$_.extension -match $rgxfiles} | ?{$_.fullname -notmatch $rgxIncludeDirs} ;
    PS> verb-IO\test-AuthenticodeSignatureTDO -file $files.fullname ;    
    Demo signing all suitable files in a monolithic all-in-one module (postfilter excludes include dir files encapsulated in the signed main .psm1 file)
    #>
    [CmdletBinding()]
    [Alias('sign-file')]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, HelpMessage = 'What file(s) would you like to sign?')]
            [system.io.fileinfo[]]$file, 
        [Parameter(Mandatory=$false,HelpMessage="(optional) Certificate to verify signature against[-Certificate `$certobj]")]
            [System.Security.Cryptography.X509Certificates.X509Certificate2]$certificate,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
            [switch] $whatIf
    ) ;
    # alt: the simplest option:
    # $cert = @(get-childitem cert:\currentuser\my -codesigning)[0] ; Set-AuthenticodeSignature -filepath c:\usr\work\ps\scripts\authenticate-profile.ps1 -Certificate $cert
    BEGIN {
        TRY {Add-Type -AssemblyName System.Security -ErrorAction Stop} CATCH {write-verbose "Add-Type already loaded (error suppress)"} ; 
        #region FUNCTIONS_INTERNAL ; #*======v FUNCTIONS_INTERNAL v======
        
        #region TEST_XMLSIGNATURETDO ; #*------v Test-XmlSignatureTDO v------
        if(-not(get-command Test-XmlSignatureTDO -ea 0)){
            function Test-XmlSignatureTDO {
                <#                                                                                                                                                                                                                                                <#
                .SYNOPSIS
                Test-XmlSignatureTDO.ps1 - Verify the digital signature on an XML document signed via sign-xmlTDO
                .NOTES
                Version     : 0.0.
                Author      : Todd Kadrie
                Website     : http://www.toddomation.com
                Twitter     : @tostka / http://twitter.com/tostka
                CreatedDate : 2026-
                FileName    : Test-XmlSignatureTDO.ps1
                License     : MIT License
                Copyright   : (non-asserted)
                Github      : https://github.com/tostka/verb-io
                Tags        : Powershell
                REVISIONS
                * 3:08 PM 11/4/2026 rev'd to trap non-signed and return $false, vs throw error
                * 8:10 AM 10/15/2026 claude fixes:sign-xmlTDO's File parameterset now embeds KeyInfo/X509Data too (was
                  SigningKey-only), so both parametersets self-verify; -Certificate is now optional in both
                  cases - updated docs below accordingly ;
                  ren Verify-XmlSignature -> Test-XmlSignatureTDO
                4:38 PM 10/12/2026 claude updates/fixes; initial build, paired to sign-xmlTDO() in same module
                .DESCRIPTION
                Test-XmlSignatureTDO.ps1 - Verify the digital signature on an XML document signed via sign-xmlTDO

                Both of sign-xmlTDO's parametersets ('File' and 'Xml') embed a KeyInfoX509Data clause (the
                signing cert's public key) into the resulting <Signature> block, so either variant can
                self-verify here with no -Certificate needed; CheckSignature() pulls the public key out of
                the embedded KeyInfo. You can still pass -Certificate to force verification against a
                specific trusted cert instead of whatever's embedded in the file/xml.
                .PARAMETER xml
                Previously-signed Xml to be verified[-Xml `$xmlObj]
                .PARAMETER XmlPath
                Path to previously-signed XML file to be verified[-XmlPath c:\pathto\file.xml]
                .PARAMETER certificate
                (optional) Certificate to verify signature against (public key alone is sufficient)[-Certificate `$certobj]
                Optional for xml signed via either of sign-xmlTDO's parametersets, since both now embed
                KeyInfo/X509Data; omit to self-verify, or pass a specific cert to verify against that instead
                of whatever's embedded in the file/xml.
                .PARAMETER ValidateCertificateChain
                Switch: in addition to the cryptographic signature match, also validate the -Certificate's
                chain of trust (revocation/trusted root etc)[-ValidateCertificateChain]
                Only applies when -Certificate is specified; defaults off (signature-only check), as self-signed
                or otherwise untrusted-chain code-signing certs are a common/expected use case here.
                .INPUTS
                None. Does not accepted piped input.(.NET types, can add description)
                .OUTPUTS
                System.Boolean
                Returns $true if the signature is valid, $false if invalid.
                .EXAMPLE
                PS> $valid = Test-XmlSignatureTDO -XmlPath 'C:\sc\powershell\PSScripts\build\cert\certsigningfiles-spec.xml' -verbose ;
                PS> $valid ;

                Demo self-verifying a file-signed xml (embedded KeyInfo/X509Data) with no -Certificate specified.
                .EXAMPLE
                PS> $xml = [xml](gc 'C:\sc\powershell\PSScripts\build\cert\certsigningfiles-spec.xml') ;
                PS> $valid = Test-XmlSignatureTDO -xml $xml -verbose ;
                PS> $valid ;

                Demo self-verifying an xml-object-signed xml (embedded KeyInfo/X509Data) with no -Certificate specified.
                .LINK
                https://github.com/tostka/verb-XXX
                .LINK
                https://github.com/tostka/powershellbb/
                #>
                [CmdletBinding(DefaultParameterSetName='File')]
                Param(
                    [Parameter(ParameterSetName='Xml',Mandatory=$true,HelpMessage="Previously-signed Xml to be verified[-Xml `$xmlObj]")]
                        [xml]$xml,
                    [Parameter(ParameterSetName='File',Mandatory=$true,Position=0,ValueFromPipeline=$True,HelpMessage='Path to previously-signed XML file to be verified[-XmlPath c:\pathto\file.xml]')]
                        [AllowNull()]
                        [AllowEmptyCollection()]
                        [ValidateScript({Test-Path $_})]
                        [system.io.fileinfo[]]$XmlPath,
                    [Parameter(Mandatory=$false,HelpMessage="(optional) Certificate to verify signature against[-Certificate `$certobj]")]
                        [System.Security.Cryptography.X509Certificates.X509Certificate2]$certificate,
                    [Parameter(Mandatory=$false,HelpMessage="Switch: also validate -Certificate's chain of trust[-ValidateCertificateChain]")]
                        [switch]$ValidateCertificateChain
                ) ;
                TRY {Add-Type -AssemblyName System.Security -ErrorAction Stop} CATCH {write-verbose "Add-Type already loaded (error suppress)"} ;

                [boolean]$isValid = $false ;
                TRY {
                    # --- resolve the XmlDocument to check, from whichever parameterset was used ---
                    if ($PSCmdlet.ParameterSetName -eq 'File') {
                        write-verbose "Loading XmlDocument from:`n$($XmlPath.FullName)" ;
                        $XmlDoc = New-Object System.Xml.XmlDocument
                        $XmlDoc.PreserveWhitespace = $true  # match sign-xmlTDO's load behavior, so c14n digest lines up
                        $XmlDoc.Load($XmlPath.FullName)
                    } else {
                        # 'Xml' parameterset: caller already supplied a loaded [xml] doc
                        $XmlDoc = $xml
                    }

                    # --- locate the ds:Signature node appended by sign-xmlTDO ---
                    $SignatureNodes = $XmlDoc.GetElementsByTagName('Signature','http://www.w3.org/2000/09/xmldsig#') ;
                    if (-not $SignatureNodes -or $SignatureNodes.Count -eq 0) {
                        #Throw "No <Signature> element (http://www.w3.org/2000/09/xmldsig# namespace) found in specified xml - nothing to verify" ;
                        write-verbose "No <Signature> element (http://www.w3.org/2000/09/xmldsig# namespace) found in specified xml - nothing to verify" ;
                        $false | write-output ;
                    } else {
                        if ($SignatureNodes.Count -gt 1) {
                            write-warning "Multiple <Signature> elements found ($($SignatureNodes.Count)); verifying only the first" ;
                        } ;

                        # --- load it into a SignedXml for verification ---
                        $SignedXml = New-Object System.Security.Cryptography.Xml.SignedXml -ArgumentList $XmlDoc
                        $SignedXml.LoadXml([System.Xml.XmlElement]$SignatureNodes[0])

                        if ($certificate) {
                            # explicit cert supplied: verifySignatureOnly = -not $ValidateCertificateChain
                            # (ie by default skip chain/trust/revocation checks - just confirm the math; many
                            # code-signing certs here are self-signed and would otherwise always fail chain validation)
                            $VerifySignatureOnly = -not $ValidateCertificateChain.IsPresent ;
                            write-verbose "Verifying signature against supplied -Certificate (Thumbprint:$($certificate.Thumbprint)); VerifySignatureOnly:$($VerifySignatureOnly)" ;
                            $isValid = $SignedXml.CheckSignature($certificate, $VerifySignatureOnly)
                        } else {
                            # no cert supplied: rely on embedded KeyInfo (eg the 'Xml' parameterset's KeyInfoX509Data)
                            write-verbose "No -Certificate supplied; verifying against embedded KeyInfo (if any)" ;
                            $isValid = $SignedXml.CheckSignature()
                        } ;

                        if ($isValid) {
                            write-host -foregroundcolor green "Signature VALID" ;
                        } else {
                            write-host -foregroundcolor red "Signature INVALID" ;
                        } ;
                        $isValid | write-output ;
                    } ; 
                } CATCH [System.Management.Automation.RuntimeException] {
                    $ErrTrapd=$Error[0] ;
                    if($ErrTrapd.Exception -match 'No\s<Signature>\selement\s\(http://www\.w3\.org/2000/09/xmldsig#\snamespace\)\sfound\sin\sspecified\sxml\s-\snothing\sto\sverify'){
                        write-verbose "No <Signature> element (http://www.w3.org/2000/09/xmldsig# namespace) found in specified xml - nothing to verify" ; 
                        $false | write-output ;
                    }else{
                        throw $ErrTrapd
                    }
                } CATCH {
                    $ErrTrapd=$Error[0] ;
                    write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
                    $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                    write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                    $false | write-output ;
                } ;
            }
        }
        #endregion TEST_XMLSIGNATURETDO ; #*------^ END Test-XmlSignatureTDO ^------

        #endregion FUNCTIONS_INTERNAL ; #*======^ END FUNCTIONS_INTERNAL ^======

        $error.clear() ;
        TRY {
            if(-not $certificate){
                if($certificate = @(get-childitem cert:\currentuser\my -codesigning -ea 0 )[0]){
                    write-verbose "found matching -codesigning CU\My cert:`n$(($certificate|out-string).trim())" ; 
                } elseif($certificate = @(get-childitem cert:\LocalMachine\my -codesigning -ea 0 )[0]){
                    write-verbose "found -codesigning  matching LM\My cert:`n$(($certificate|out-string).trim())" ; 
                } else { 
                    throw "Unable to locate a Signing Cert in either`ncert:\currentuser\my -codesigning`nor cert:\LocalMachine\my -codesigning. ABORTING!" ; 
                } 
            } ; 
            # if( gci Cert:\CurrentUser\My -CodeSigningCert | Test-CertificateTDO -CRLMode NoCheck -CRLFlag EntireChain |  ?{$_.valid -AND $_.Usage -contains 'Code Signing'} ){
            # Signing cert currently used is a locally-signed private cert, which won't pass public CRL checks, so we suppress the CRL check, but have the full chain validated
            $pltTCT=[ordered]@{
                Certificate = $certificate ;
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
                #if($file.Extension -match '\.(xml|psxml'){
                if($f.Extension -match '\.(xml|psxml)'){
                    write-host ".xml file detected: Not supported by get-AuthenticodeSignature, requires different signature approach: using verb-io\Test-XmlSignatureTDO" ; 
                    #if (-not (($tRet = Test-XmlSignatureTDO -XmlPath $f.fullname).status -eq 'Valid') ){
                    if (-not (Test-XmlSignatureTDO -XmlPath $f.fullname) ){
                        #$oRet = sign-xmlTDO -XmlPath $f -Certificate $certificate -whatif:$($whatif) ;
                        $false | write-output 
                    }else{
                        write-verbose "($($f.fullname) has a valid existing AuthenticodeSignature)" ; 
                        $true | write-output  ; 
                    } ; 
                }else{
                    if (-not ((Get-AuthenticodeSignature -FilePath $f.fullname).status -eq 'Valid') ){
                        $false | write-output ; 
                    }else{
                        write-verbose "($($f.fullname) has a valid existing AuthenticodeSignature)" ; 
                        $true | write-output ; 
                    } ; 
                }
            } CATCH {
                $ErrTrapd=$Error[0] ;
                write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            } ;           
        } # loop-E
    } # Proc-E
}
#*------^ test-AuthenticodeSignatureTDO.ps1 ^------