#*------v out-Clipboard.ps1 v------
Function out-Clipboard {
    <#
    .SYNOPSIS
    out-Clipboard.ps1 - cross-version emulation of the older pre-psv3 out-clipboard 'clip.exe' use (for pre psv3); or emulates the `n-appending bahavior of clip.exe, when using it for psv3+. This differentiates from the native set-clipboard, which appends no trailing `n.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : out-Clipboard.ps1
    License     : (none-asserted)
    Copyright   : (none-asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Hashtable,PSCustomObject,Conversion
    AddedCredit : https://community.idera.com/members/tobias-weltner
    AddedWebsite:	https://community.idera.com/members/tobias-weltner
    AddedTwitter:	URL
    REVISIONS
    * 10:59 AM 11/29/2021 fixed - shift to adv func broke the $input a-vari (only present w simple funcs): Added declared $content pipeline vari; added -NoLegacy switch to suppress the default 'append-`n to each line' clip.exe behavior emulation. 
    * 3:17 PM 11/8/2021 init vers, flip profile alias & clip.exe to holistic function for either
    .DESCRIPTION
    out-Clipboard.ps1 - cross-version emulation of the older pre-psv3 out-clipboard 'clip.exe' use (for pre psv3); or emulates the `n-appending bahavior of clip.exe, when using it for psv3+. This differentiates from the native set-clipboard, which appends no trailing `n.
    Set-clipboard supports pipeline support, like the older | clip.exe approach. 
    But, there are differences between set-clipboard & clip.exe: 
    - clip.exe appends `n to every item added. 
    - set-clipboard does not.
    if you have code in place using the prior clip.exe support, and want an emulation of the prior behavior, this fakes it by appending `n to the input, before set-clipboarding the value. 
    .OUTPUT
    None. places specified input onto the clipboard.
    .EXAMPLE
    "some text" | out-clipboard ; 
    .LINK
    https://github.com/tostka/verb-IO
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Content to be copied to clipboard [-Content `$object]")]
        [ValidateNotNullOrEmpty()]$Content,
        [Parameter(HelpMessage="Switch to suppress the default 'append `n' clip.exe-emulating behavior[-NoLegacy]")]
        [switch]$NoLegacy
    ) ;
    PROCESS {
        if($host.version.major -lt 3){
            # provide clipfunction downrev
            if(-not (get-command out-clipboard)){
                # build the alias if not pre-existing
                $tClip = "$((Resolve-Path $env:SystemRoot\System32\clip.exe).path)" ;
                #$input | "($tClip)" ; 
                #$content | ($tClip) ; 
                Set-Alias -Name 'Out-Clipboard' -Value $tClip -scope script ;
            } ;
            # input only works in simple functions, in adv funcs declare a suitable vari
            #$input | out-clipboard 
            $content | out-clipboard ;
        } else {
            # emulate clip.exe's `n-append behavior on ps3+
            <#$input = $input | foreach-object {"$($_)$([Environment]::NewLine)"} ; 
            $input | set-clipboard ; 
            #>
            if(-not $NoLegacy){
                $content = $content | foreach-object {"$($_)$([Environment]::NewLine)"} ; 
            } ; 
            $content | set-clipboard ;
        } ; 
    } ; 
}

#*------^ out-Clipboard.ps1 ^------
