#*------v Function Authenticate-File v------
function Authenticate-File {
    <#
    .SYNOPSIS
    Authenticate-File - verifies Authenticode signature on any file that supports Subject Interface Package (SIP).
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
    8:56 AM 1/8/2015 - ported from sign-file
    8:54 AM 1/8/2015 - added play-beep to end
    10:01 AM 12/30/2014
    .PARAMETER file
    The file name(s) to retrieve the authenticode signature info from.
    .INPUTS
    Accepts piped input (computername).
    .OUTPUTS
    Outputs CustomObject to pipeline
    .DESCRIPTION
    Authenticate-File - verifies Authenticode signature on any file that supports Subject Interface Package (SIP).
    .EXAMPLE
    Authenticate-File C:\usr\work\lync\scripts\enable-luser.ps1
    .EXAMPLE
    Authenticate-File C:\usr\work\lync\scripts\*-luser.ps1
    .EXAMPLE
    get-childitem C:\usr\work\lync\scripts\*-luser.ps1 | %{Authenticate-File $_}
    .EXAMPLE
    ls *.ps1,*.psm1,*.psd1 | Get-AuthenticodeSignature | Where {!(Test-AuthenticodeSignature $_ -Valid)} | gci | Set-AuthenticodeSignature ;
     Above sets sigs on all ps files with invalid sigs.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True, HelpMessage = 'What file(s) would you like to sign?')]
        $file
    ) ;
    # just use the simplest option:
    #$cert = @(get-childitem cert:\currentuser\my -codesigning)[0]
    foreach ($f in $file) {
        get-AuthenticodeSignature -filepath $f | select Path, Status | format-table -auto ; #-Certificate $cert
    }
    play-beep;
} #*------^ END Function Authenticate-File ^------