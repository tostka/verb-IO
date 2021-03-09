
#*------v reset-ConsoleColors.ps1 v------
Function reset-ConsoleColors {
    <#
    .SYNOPSIS
    reset-ConsoleColors - reset $Host.UI.RawUI.BackgroundColor & ForegroundColor to default values
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-03-03
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Copyright   : 
    Github      : https://github.com/tostka
    Tags        : Powershell,ExchangeOnline,Exchange,RemotePowershell,Connection,MFA
    REVISIONS   :
    * 1:25 PM 3/5/2021 init ; added support for both ISE & powershell console
    .DESCRIPTION
    reset-ConsoleColors - reset $Host.UI.RawUI.BackgroundColor & ForegroundColor to default values
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    reset-ConsoleColors;
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    #[Alias('dxo')]
    Param() 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    write-verbose "(Issuing `$Host color reset...)" ; 
    # add detection for psReadLine - and version differences (v1 & v2 have fundemental param support syntax - breaaking change)
    if ($psrMod = Get-Module -name PSReadline) {
            switch -regex ($psrMod.version.major){
                "[1]" {
                    Set-PSReadlineOption -ResetTokenColors ; 
                }
                "[2-9]" {
                    # two *lost* the above ResetTokenColors param! doesn't seem to have *any* reset now
                    # you'd literally have to cache & re-assign *every*value!
                    # braindead!
                    write-host "PsReadline v2 *LOST* THE ResetTokenColors cmd. Doesn't seem to have *any* reset to default support anymore!" ; 
                }
               default {
                    throw "Unrecognized PSReadline revision:$($psrMod.version.major)" ; 
               } 
            } ;  # switch-E 

    } else { 
        switch($host.name){
            "Windows PowerShell ISE Host" {
                $psISE.Options.RestoreDefaultTokenColors()
            } 
            "ConsoleHost" {
                [console]::ResetColor()  # reset console colorscheme to default
            }
            default {
                write-warning "Unrecognized `$Host.name:$($Host.name), skipping set-ConsoleColor" ; 
            } ; 
        } ; 
    } ; 
}
#*------^ reset-ConsoleColors.ps1 ^------
