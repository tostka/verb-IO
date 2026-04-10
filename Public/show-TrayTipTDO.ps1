# show-TrayTipTDO.ps1

#region SHOW_TRAYTIPTDO ; #*------v show-TrayTipTDO v------
#*----------------v Function show-TrayTipTDO v----------------
function show-TrayTipTDO {
    <#
    .SYNOPSIS
    show-TrayTipTDO() - Display popup System Tray Tooltip
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    :
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell
    AddedCredit : Pat Richard (pat@innervation.com)
    AddedWebsite: http://www.ehloworld.com/1038
    AddedTwitter:
    REVISIONS
    * 8:06 AM 4/10/2026 ren: show-TrayTip -> show-TrayTipTDO (conflict avoid); moved verb-desktop -> verb-io (where show-MsgBox and the read-[input] fcts are).
    * 2:23 PM 3/10/2016 reworked the $TrayIcon validation, to permit either a valid path to an .ico, or a variable of Icon type (of the type pulled from shell32.dll by Extract-Icon()); debugged and functional in check-kpconflict.ps1 ; added some concepts from the src Pat used: Dr. Tobias Weltner, http://www.powertheshell.com/balloontip/ (Pat was in the comments asking questions on the subject) ; added some concepts from Pat Richard http://www.ehloworld.com/1038
    * 11:19 AM 3/6/2016 - unknown original, updating with formatting, pshelp and updated params
    .DESCRIPTION
    show-TrayTipTDO() - Display popup System Tray Tooltip
    .PARAMETER Type
    Tip Icon type [Error|Info|Warning|None]
    .PARAMETER Text
    Tip Text to be displayed [string]
    .PARAMETER title
    Tip Title [string]
    .PARAMETER ShowTime
    Tip Display Time (secs, default:2)[int]
    .PARAMETER TrayIcon
    Specify variant Systray icon (defaults per type)
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    show-TrayTipTDO -type "error" -text "$computer is still ONLINE; Check that reboot is initiated properly" -title "Computer is not rebooting"
    Show TrayTip with default (powershell) Systray Icon, Error-type balloon icon, and balloon title & text specified, for 30 seconds
    .EXAMPLE
    show-TrayTipTDO -type "error" -title "CONFLICT!" -text "CONFLICTED KEEPASS DB FOUND!" -ShowTime 30 -TrayIcon $TrayIcon ;
    Show TrayTip with custom Systray Icon, Error-type balloon icon, and balloon title & text specified, for 30 seconds
    .EXAMPLE
    show-TrayTipTDO -type info -text "PowerShell script has finished processing" -title "Completed"
    Basic Example using parameter names (rest defaults)
    .EXAMPLE
    show-TrayTipTDO info "PowerShell script has finished processing" "Completed"
    Basic Example using positional parameters
    .EXAMPLE
    if($script:TrayTip) { $script:TrayTip.Dispose() ; Remove-Variable -Scope script -Name TrayTip ; }
    Cleanup code that should be used at script-end to cleanup the objects
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias('show-TrayTip')]
    Param(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Tip Icon type [Error|Info|Warning|None]")][ValidateSet("Error","Info","Warning","None")]
        [string]$Type
        ,[Parameter(Position=1,Mandatory=$True,HelpMessage="Tip Text to be displayed [string]")][ValidateNotNullOrEmpty()]
        [string]$Text
        ,[Parameter(Position=2,Mandatory=$True,HelpMessage="Tip Title [string]")]
        [string]$Title
        ,[Parameter(HelpMessage="Tip Display Time (secs, default:2)[int]")][ValidateRange(1,30)]
        [int]$ShowTime=2
        ,[parameter(HelpMessage = "Specify variant Systray icon (defaults to Powershell)")]
        $TrayIcon
    )  ;
    BEGIN {
        if($TrayIcon){
            if( (test-path $TrayIcon) -OR ($TrayIcon.gettype().name -eq 'Icon') ){ }
            else {
                write-warning "Invalid TrayIcon, resetting to Default Icon" ;
                $TrayIcon =$null ;
            } ;
        } ;
    } ;
    PROCESS {
        if(!($NoTray)){
            #load Windows Forms and drawing assemblies
            [reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null ; # used for TrayTip tips
            [reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null ; # used for icon extraction
            #define an icon image pulled from PowerShell.exe
            #$icon=[system.drawing.icon]::ExtractAssociatedIcon((join-path $pshome powershell.exe)) ;
            # load the TrayTip
            if ($script:TrayTip -eq $null) {  $script:TrayTip = New-Object System.Windows.Forms.NotifyIcon } ;
            <# TrayIcon (BalloonTip): configurable property's:
              # the systray icon to be displayed (extracted from the PS path here)
              $path                    = Get-Process -id $pid | Select-Object -ExpandProperty Path ;
              $TrayTip.Icon            = [System.Drawing.Icon]::ExtractAssociatedIcon($path) ;
              # the following configure settings _within_ the balloon popup
              $TrayTip.BalloonTipIcon  = $Icon ;
              $TrayTip.BalloonTipText  = $Text ;
              $TrayTip.BalloonTipTitle = $Title ;
              # finally show the BalloonTip, with a specified timeout.
              $TrayTip.Visible         = $true ;
              $TrayTip.ShowBalloonTip($Timeout) ;
            #>
            if ($TrayIcon) { $TrayTip.Icon = $TrayIcon  }
            else {
                # use the extracted Powershell process icon
                $Path = Get-Process -id $pid | Select-Object -ExpandProperty Path ;
                $TrayTip.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path) ;
            }
            $TrayTip.BalloonTipIcon  = $Type ;
            $TrayTip.BalloonTipText  = $Text ;
            $TrayTip.BalloonTipTitle = $Title ;
            $TrayTip.Visible         = $true ;
            # set timeout (in ms)
            $TrayTip.ShowBalloonTip($ShowTime*1000) ;
            write-verbose -verbose:$verbose "`$TrayTip:`n$(($TrayTip | fl * |out-string).trim())" ;
        } ;# if-E $NoTray ;
    } ;
    END {
        <# Cleanup code that should be used at script-end to cleanup the objects
            if($script:TrayTip) { $script:TrayTip.Dispose() ; Remove-Variable -Scope script -Name TrayTip ; }
        #>
    } ;
} 
#endregion SHOW_TRAYTIPTDO ; #*------^ END show-TrayTipTDO ^------