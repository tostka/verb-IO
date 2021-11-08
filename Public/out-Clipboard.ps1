#*------v Function out-Clipboard v------
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
    https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/converting-hash-tables-to-objects
    .LINK
    https://github.com/tostka/verb-IO
    #>

    [CmdletBinding()]
    Param ()
    PROCESS {
        if($host.version.major -lt 3){
            # provide clipfunction downrev
            $tClip = "$((Resolve-Path $env:SystemRoot\System32\clip.exe).path)" ;
            #$input | "($tClip)" ; 
            Set-Alias -Name 'Out-Clipboard' -Value $tClip -scope script ;
            $input | out-clipboard 
        } else {
            # emulate clip.exe's `n-append behavior on ps3+
            $input = $input | foreach-object {"$($_)$([Environment]::NewLine)"} ; 
            $input | set-clipboard ; 
        } ; 
    } ; 
} ; 
#*------^ END Function out-Clipboard ^------