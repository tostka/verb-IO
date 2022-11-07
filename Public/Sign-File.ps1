#*------v Function Sign-File v------
function Sign-File {
    <#
    .SYNOPSIS
    Sign-File - adds an Authenticode signature to any file that supports Subject Interface Package (SIP).
    .NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Certificate,Developoment
    REVISIONS   :
    10:45 AM 10/14/2020 added cert hunting into cert:\LocalMachine\my -codesigning as well as currentuser
    7:56 AM 6/19/2018 added -whatif & -showdebug params
    10:46 AM 1/16/2015 corrected $oReg|$oRet typo that broke status attrib
    10:20 AM 1/15/2015 rewrote into pipeline format
    9:50 AM 1/15/2015 added a $f.name echo to see if it's doing anything
    8:54 AM 1/8/2015 - added play-beep to end
    10:01 AM 12/30/2014
    .PARAMETER file
    file name(s) to appl authenticode signature into.
    .PARAMETER cert
    The path and filename of a text file where failed computers will be logged. Defaults to c:\retries.txt.
    .INPUTS
    Accepts piped input (computername).
    .OUTPUTS
    Outputs CustomObject to pipeline
    .DESCRIPTION
    Sign-File - adds an Authenticode signature to any file that supports Subject Interface Package (SIP).
    .EXAMPLE
      get-childitem *.ps1,*.psm1,*.psd1,*.psd1,*.ps1xml | Get-AuthenticodeSignature | Where {!(Test-AuthenticodeSignature $_ -Valid)} | gci | Set-AuthenticodeSignature
      Set sigs on all ps files with invalid sigs (for ps, it's: ps1, psm1, psd1, dll, exe, and ps1xml files)
    .EXAMPLE
    Get-ADComputer -filter * | Select @{label='computername';expression={$_.name}} | Get-Info
    .EXAMPLE
    Get-Info -computername SERVER2,SERVER3
    .EXAMPLE
    sign-file C:\usr\work\lync\scripts\enable-luser.ps1
    .EXAMPLE
    sign-file C:\usr\work\lync\scripts\*-luser.ps1
    .EXAMPLE
    get-childitem C:\usr\work\lync\scripts\*-luser.ps1 | %{sign-file $_}
    .EXAMPLE
    get-childitem c:\usr\local\bin\*.ps1 | sign-file
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True, HelpMessage = 'What file(s) would you like to sign?')]
        $file,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    # alt: the simplest option:
    # $cert = @(get-childitem cert:\currentuser\my -codesigning)[0] ; Set-AuthenticodeSignature -filepath c:\usr\work\ps\scripts\authenticate-profile.ps1 -Certificate $cert
    BEGIN {
        $error.clear() ;
        TRY {
            if($cert = @(get-childitem cert:\currentuser\my -codesigning -ea 0 )[0]){
            
            } elseif($cert = @(get-childitem cert:\LocalMachine\my -codesigning -ea 0 )[0]){
            
            } else { 
                throw "Unable to locate a Signing Cert in either`ncert:\currentuser\my -codesigning`nor cert:\LocalMachine\my -codesigning. ABORTING!" ; 
            } 
        } CATCH {
            Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
            Exit #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ; 
    }  # BEG-E
    PROCESS {
        foreach ($f in $file) {
            $continue = $true
            try {
                #$f.name
                $oRet = Set-AuthenticodeSignature -filepath $f -Certificate $cert -whatif:$($whatif) ;
            }
            catch {
                Write "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
            } # try/cat-E
            if ($continue) {
                $sig = Get-AuthenticodeSignature -filepath $f
                # create a hashtable with your output info
                $info = @{
                    'file'       = $oRet.Path;
                    'Thumbprint' = $oRet.SignerCertificate.Thumbprint;
                    'Subject'    = $oRet.SignerCertificate.Subject;
                    'status'     = $oRet.Status.Status
                } ;
                Write-Output $oRet
            } 
        } # loop-E
    } # Proc-E
} #*------^ END Function Sign-File ^------
