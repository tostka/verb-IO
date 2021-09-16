
#*------v Function set-ConsoleColors v------
Function set-ConsoleColors {
    <#
    .SYNOPSIS
    set-ConsoleColors.ps1 - Converts a PowerShell object to a Markdown table.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-01-20
    FileName    : set-ConsoleColors.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Markdown,Output
    REVISION
    * 11:41 AM 9/16/2021 string
    * 1:25 PM 3/5/2021 init ; added support for both ISE & powershell console
    .DESCRIPTION
    set-ConsoleColors.ps1 - Converts a PowerShell object to a Markdown table.
    Use reset-ConsoleColors to reset colors to the configured $host/Console defaults
    Use 
    .PARAMETER BackgroundColor
    Powershell Host colorname to be set as BackgroundColor
    .PARAMETER ForegroundColor
    Powershell Host colorname to be set as ForegroundColor
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    String
    .EXAMPLE
    set-ConsoleColors -BackgroundColor DarkMagenta -ForegroundColor DarkYellow
    Set console/host color scheme to match the default Powershell colors
    .EXAMPLE
    $colors = get-colorcombo -Combo 69 ; 
    set-ConsoleColors @colors -verbose ; 
    Leverage the verb-IO:get-colorcombo() to pull & set the default scheme
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('set-ConsColor')]
    Param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage="Powershell Host colorname to be set as BackgroundColor[-BackgroundColor darkgray]")]
        [ValidateSet('Black','DarkBlue','DarkGreen','DarkCyan','DarkRed','DarkMagenta','DarkYellow','Gray','DarkGray','Blue','Green','Cyan','Red','Magenta','Yellow','White')]
        [string]$BackgroundColor,
        [Parameter(Mandatory = $true, Position = 1, HelpMessage="Powershell Host colorname to be set as ForegroundColor[-ForegroundColor darkgray]")]
        [ValidateSet('Black','DarkBlue','DarkGreen','DarkCyan','DarkRed','DarkMagenta','DarkYellow','Gray','DarkGray','Blue','Green','Cyan','Red','Magenta','Yellow','White')]
        [string] $ForegroundColor
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
    } ;
    PROCESS {
        write-verbose "(setting console colors:BackgroundColor:$($BackgroundColor),ForegroundColor:$($ForegroundColor))" ; 
        if ($psrMod = Get-Module -name PSReadline) {
            switch -regex ($psrMod.version.major){
                "[1]" {
                    <# 
                        -BackgroundColor <ConsoleColor>     Specifies the background color for the token kind that is specified by the TokenKind parameter.
                        -ForegroundColor <ConsoleColor>     Specifies the foreground color for the token kind that is specified by the TokenKind parameter.
                        -ResetTokenColors [<SwitchParameter>] Indicates that this cmdlet restores token colors to default settings.
                        -ContinuationPrompt <String>     Specifies the string displayed at the start of the second and subsequent lines when multi-line input is being entered. The default value is '>>>'. The empty string is valid.
                        -ContinuationPromptBackgroundColor <ConsoleColor>     Specifies the background color of the continuation prompt.
                        -ContinuationPromptForegroundColor
                        -EmphasisBackgroundColor <ConsoleColor>     Specifies the background color that is used for emphasis, such as to highlight search text.      The acceptable values for this parameter are: the same values as for BackgroundColor .         
                        -EmphasisForegroundColor <ConsoleColor>
                        -ErrorBackgroundColor
                        -ResetTokenColors [<SwitchParameter>]     Indicates that this cmdlet restores token colors to default settings.
                        -TokenKind Specifies the kind of token when you are setting token coloring options with the ForegroundColor and BackgroundColor parameters. The acceptable values for this parameter are: [None|Comment|Keyword|String|Operator|Variable|Command|Parameter|Type|Number|Member]
                        # use of BackgroundColor,ForegroundColor w TokenKind
                        Set-PSReadlineOption -TokenKind Comment -ForegroundColor Green -BackgroundColor Gray
                        # gonna take a stack of repeated Set-PSReadlineOption, clearly can't hybrid everything in a single hash like v2
                        get-PSReadLineOption | fl *
                        EditMode                               : Windows
                        ContinuationPrompt                     : >>
                        ContinuationPromptForegroundColor      : DarkYellow
                        ContinuationPromptBackgroundColor      : DarkMagenta
                        ExtraPromptLineCount                   : 0
                        AddToHistoryHandler                    :
                        CommandValidationHandler               :
                        CommandsToValidateScriptBlockArguments : {ForEach-Object, %, Invoke-Command, icm...}
                        HistoryNoDuplicates                    : False
                        MaximumHistoryCount                    : 4096
                        MaximumKillRingCount                   : 10
                        HistorySearchCursorMovesToEnd          : False
                        ShowToolTips                           : False
                        DingTone                               : 1221
                        CompletionQueryItems                   : 100
                        WordDelimiters                         : ;:,.[]{}()/\|^&*-=+'"–—―
                        DingDuration                           : 50
                        BellStyle                              : Audible
                        HistorySearchCaseSensitive             : False
                        ViModeIndicator                        : None
                        HistorySavePath                        : $($ENV:USERPROFILE)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
                        HistorySaveStyle                       : SaveIncrementally
                        DefaultTokenForegroundColor            : DarkYellow
                        CommentForegroundColor                 : DarkGreen
                        KeywordForegroundColor                 : Green
                        StringForegroundColor                  : DarkCyan
                        OperatorForegroundColor                : DarkGray
                        VariableForegroundColor                : Green
                        CommandForegroundColor                 : Yellow
                        ParameterForegroundColor               : DarkGray
                        TypeForegroundColor                    : Gray
                        NumberForegroundColor                  : White
                        MemberForegroundColor                  : White
                        DefaultTokenBackgroundColor            : DarkMagenta
                        CommentBackgroundColor                 : DarkMagenta
                        KeywordBackgroundColor                 : DarkMagenta
                        StringBackgroundColor                  : DarkMagenta
                        OperatorBackgroundColor                : DarkMagenta
                        VariableBackgroundColor                : DarkMagenta
                        CommandBackgroundColor                 : DarkMagenta
                        ParameterBackgroundColor               : DarkMagenta
                        TypeBackgroundColor                    : DarkMagenta
                        NumberBackgroundColor                  : DarkMagenta
                        MemberBackgroundColor                  : DarkMagenta
                        EmphasisForegroundColor                : Cyan
                        EmphasisBackgroundColor                : DarkMagenta
                        ErrorForegroundColor                   : Red
                        ErrorBackgroundColor                   : DarkMagenta
                    #>
                    # bgs
                    Set-PSReadlineOption -TokenKind ContinuationPromptBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind DefaultTokenBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind CommentBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind KeywordBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind StringBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind OperatorBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind VariableBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind CommandBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind ParameterBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind TypeBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind NumberBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind MemberBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind EmphasisBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind ErrorBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    # fgs
                    Set-PSReadlineOption -TokenKind ContinuationPromptForegroundColor -ForegroundColor [ConsoleColor]::$($ForegroundColor)
                    Set-PSReadlineOption -TokenKind DefaultTokenForegroundColor -ForegroundColor [ConsoleColor]::$($ForegroundColor)
                }
                "[2-9]" {
                    # vers2 refactored, got rid of tokenKind and added explicit bgcolor/bgcolor params for every component
                    <# V2 supports 24bit colors, over orig 16 colors:
                    Set-PSReadLineOption -Colors @{ "Comment"="$([char]0x1b)[32;47m" } 
                    https://docs.microsoft.com/en-us/powershell/module/psreadline/set-psreadlineoption?view=powershell-5.1
                    Colors can be either a value from ConsoleColor, for example [ConsoleColor]::Red, or a valid ANSI escape sequence. Valid escape sequences depend on your terminal. In PowerShell 5.0, an example escape sequence for red text is $([char]0x1b)[91m. In PowerShell 6 and above, the same escape sequence is `e[91m. You can specify other escape sequences including the following types:
                    256 color
                    24-bit color
                    Foreground, background, or both
                    Inverse, bold

                    #>
                    $colors = @{
                      # bgs
                      "ContinuationPromptBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "DefaultTokenBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "CommentBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "KeywordBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "StringBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "OperatorBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "VariableBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "CommandBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "ParameterBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "TypeBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "NumberBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "MemberBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "EmphasisBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "ErrorBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      # fgs
                      "ContinuationPromptForegroundColor" = [ConsoleColor]::$($ForegroundColor)
                      "DefaultTokenForegroundColor" = [ConsoleColor]::$($ForegroundColor)

                      # ConsoleColor enum has all the old colors
                      #"Error" = [ConsoleColor]::DarkRed

                      # A mustardy 24 bit color escape sequence
                      #"String" = "$([char]0x1b)[38;5;100m"

                      # A light slate blue RGB value
                      #"Command" = "#8470FF"
                    } ; 
                    write-verbose "PSReadLineOption detected:Set-PSReadLineOption -Colors`n$(($colors|out-string).trim())" ; 
                    Set-PSReadLineOption -Colors @colors ; 
                }
               default {
               
               } 
           } ;  # switch-E 
            
        } else { 
            switch($host.name){
                "Windows PowerShell ISE Host" {
                    #write-verbose "ISE detected:`$psise.Options.ConsolePaneBackgroundColor`n`$psISE.Options.ConsolePaneTextBackgroundColor`n`$psISE.Options.ConsolePaneForegroundColor"
                    # ise includes an extra TextBackgroundColor variant
                    <# the colors are abberant, don't match the real console colors
                    # and now, doesn't like either raw colornames or [consolecolor] converted codes
                    $psise.Options.ConsolePaneBackgroundColor = [ConsoleColor]::$($BackgroundColor) ;
                    $psISE.Options.ConsolePaneTextBackgroundColor = [ConsoleColor]::$($BackgroundColor) ;
                    $psISE.Options.ConsolePaneForegroundColor =  [ConsoleColor]::$($ForegroundColor) ; 
                    #>
                } 
                "ConsoleHost" {
                    write-verbose "ConsoleHost detected:`$Host.UI.RawUI.BackgroundColor`n`$Host.UI.RawUI.ForegroundColor"
                    $Host.UI.RawUI.BackgroundColor = [ConsoleColor]::$($BackgroundColor) ;
                    $Host.UI.RawUI.ForegroundColor =  [ConsoleColor]::$($ForegroundColor) ; 
                    # legacy admin-color tagging script
                    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent() ;
                    $p = New-Object system.security.principal.windowsprincipal($id) ;
                    # Find out if we're running as admin (IsInRole), If we are, set $Admin = $True. 
                    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)){$Admin = $True } else {    $Admin = $False } ;
                    if ($Admin) {
                        $effectivename = "Administrator";
                        $host.UI.RawUI.Backgroundcolor="DarkRed";
                        $host.UI.RawUI.Foregroundcolor="White" ;
                        clear-host ; 
                    } else {
                        $effectivename = $id.name ;
                        $host.UI.RawUI.Backgroundcolor="White" ;
                        $host.UI.RawUI.Foregroundcolor="DarkBlue" ;
                        clear-host ;
                    } ; 
                }
                
                <# early win10: variant
                $pData = (Get-Host).PrivateData ;
                $curForeground = [console]::ForegroundColor ;
                $curBackground = [console]::BackgroundColor ;
                # PowerShell v5 uses PSReadLineOptions to do syntax highlighting. 
                # Base the color scheme on the background color 
                If ( $curBackground -eq "White" ) {
                    Set-PSReadLineOption -TokenKind None      -ForegroundColor DarkBlue  -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Comment   -ForegroundColor DarkGray  -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Keyword   -ForegroundColor DarkGreen -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind String    -ForegroundColor Blue      -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Operator  -ForegroundColor Black ;
                    -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Variable  -ForegroundColor DarkCyan  -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Command   -ForegroundColor DarkRed   -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Parameter -ForegroundColor DarkGray  -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Type      -ForegroundColor DarkGray  -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Number    -ForegroundColor Red       -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Member    -ForegroundColor DarkBlue  -BackgroundColor White ;
                    $pData.ErrorForegroundColor   = "Red" ;
                    $pData.ErrorBackgroundColor   = "Gray" ;
                    $pData.WarningForegroundColor = "DarkMagenta" ;
                    $pData.WarningBackgroundColor = "White" ;
                    $pData.VerboseForegroundColor = "DarkYellow" ;
                    $pData.VerboseBackgroundColor = "DarkCyan"    
                } elseif ($curBackground -eq "DarkRed") {
                    Set-PSReadLineOption -TokenKind None      -ForegroundColor White    -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Comment   -ForegroundColor Gray     -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Keyword   -ForegroundColor Yellow   -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind String    -ForegroundColor Cyan     -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Operator  -ForegroundColor White    -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Variable  -ForegroundColor Green    -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Command   -ForegroundColor White    -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Parameter -ForegroundColor Gray     -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Type      -ForegroundColor Magenta  -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Number    -ForegroundColor Yellow   -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Member    -ForegroundColor White    -BackgroundColor DarkRed ;
                    $pData.ErrorForegroundColor   = "Yellow" ;
                    $pData.ErrorBackgroundColor   = "DarkRed" ;
                    $pData.WarningForegroundColor = "Magenta" ;
                    $pData.WarningBackgroundColor = "DarkRed" ;
                    $pData.VerboseForegroundColor = "Cyan" ;
                    $pData.VerboseBackgroundColor = "DarkRed" ;  
                } ; 
                #>
 
                default {
                    write-warning "Unrecognized `$Host.name:$($Host.name), skipping set-ConsoleColor" ; 
                } 
            } ; 
        } ; 
    } ;  # PROC-E
    END {} ;
} ;
#*------^ END Function set-ConsoleColors ^------
