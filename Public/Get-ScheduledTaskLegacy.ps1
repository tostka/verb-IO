#*------v Function Get-ScheduledTaskLegacy v------
Function Get-ScheduledTaskLegacy {
    <#
    .SYNOPSIS
    Get-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    .NOTES
    Author: Hugo @ peeetersonline
    Website:	http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 7:27 AM 12/2/2020 re-rename '*-ScheduledTaskCmd' -> '*-ScheduledTaskLegacy', L13 copy still had it, it's more descriptive as well.
    * 8:13 AM 11/24/2020 renamed to '*-ScheduledTaskCmd', to remove overlap with ScheduledTasks module
    * 8:06 AM 4/18/2017 comment: Invoke-Expression is unnecessary. You can simply state: schtasks.exe /query /s $ComputerName
    * 7:42 AM 4/18/2017 tweaked, added pshelp, comments etc
    * June 4, 2009 posted version
    .DESCRIPTION
    Get-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    Allows you to manage queryingscheduled tasks on one or more computers remotely.
    The functions use schtasks.exe, which is included in Windows. Unlike the Win32_ScheduledJob WMI class, the schtasks.exe commandline tool will show manually created tasks, as well as script-created ones. The examples show some, but not all parameters in action. I think the parameter names are descriptive enough to figure it out, really. If not, take a look at schtasks.exe /?. One tip: try piping a list of computer names to foreach-object and into this function.
    .PARAMETER  ComputerName
    Computer Name [-ComputerName server]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns object summary of matched task(s)
    .EXAMPLE
    Get-ScheduledTaskLegacy -ComputerName Server01
    Get all tasks on server01
    .EXAMPLE
    Get-ScheduledTaskLegacy -ComputerName bccms641 |?{$_.taskname -like '*drive*'} ;
    Post-filter tasks for name substring.
    .LINK
    http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    #>
    param([string]$ComputerName = "localhost") ;
    Write-Host "Computer: $ComputerName" ;
    # 8:05 AM 4/18/2017 add Axel's object-output filter (otherwise it just returns text)
    #$Command = "schtasks.exe /query /s $ComputerName" ;
    #$Command = schtasks.exe /query /s $ComputerName /FO List | ConvertFrom-CmdList ;
    #Invoke-Expression $Command ;
    schtasks.exe /query /s $ComputerName /FO List | ConvertFrom-CmdList
    #Clear-Variable Command -ErrorAction SilentlyContinue ;
    Write-Host "`n" ;
}
#*------^ END Function Get-ScheduledTaskLegacy ^------
