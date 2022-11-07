#*------v Function Create-ScheduledTaskLegacy v------
Function Create-ScheduledTaskLegacy {
    <#
    .SYNOPSIS
    Remove-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
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
    * 7:42 AM 4/18/2017 tweaked, added pshelp, comments etc, put into OTB
    * June 4, 2009 posted version
    .DESCRIPTION
    Get-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    Allows you to manage queryingscheduled tasks on one or more computers remotely.
    The functions use schtasks.exe, which is included in Windows. Unlike the Win32_ScheduledJob WMI class, the schtasks.exe commandline tool will show manually created tasks, as well as script-created ones. The examples show some, but not all parameters in action. I think the parameter names are descriptive enough to figure it out, really. If not, take a look at schtasks.exe /?. One tip: try piping a list of computer names to foreach-object and into this function.
    .PARAMETER  ComputerName
    Computer Name (defaults to localhost)[-ComputerName server]
    .PARAMETER TaskName
    Name of Task being targeted [-TaskName "Mytask"]
    .PARAMETER RunAsUser
    Account to be used to run the task [-RunAsUser "Toro\ExchangeAdmin"]
    .PARAMETER TaskRun
    Action Target for the Task [-TaskRun "c:\scripts\script.cmd"]
    .PARAMETER Schedule
    Recurrring Time specification [-Schedule Monthly]
    .PARAMETER Modifier
    Recurring schedule ordinal spec [-Modifier "second"]
    .PARAMETER Days
    Recurring schedule DOW spec [-Days "SUN"]
    .PARAMETER Months
    Recurring schedule Months spec [-Modifier "MAR,JUN,SEP,DEC"]
    .PARAMETER StartTime = "13:00",
    Recurring schedule StartTime spec [-StartTime "13:00"]
    .PARAMETER EndTime = "17:00",
     Recurring schedule EndTime spec [-EndTime "17:00"]
    .PARAMETER Interval = "60"
    Recurring schedule repeat interval spec [-Interval "60"]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns object summary of matched task(s)
    .EXAMPLE
    Create-ScheduledTaskLegacy -ComputerName MyServer -TaskName MyTask02 -TaskRun "D:\scripts\script2.vbs"
    .LINK
    http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    #>
    param(
        [string]$ComputerName = "localhost",
        [string]$RunAsUser = "System",
        [string]$TaskName = "MyTask",
        [string]$TaskRun = '"C:\Program Files\Scripts\Script.vbs"',
        [string]$Schedule = "Monthly",
        [string]$Modifier = "second",
        [string]$Days = "SUN",
        [string]$Months = '"MAR,JUN,SEP,DEC"',
        [string]$StartTime = "13:00",
        [string]$EndTime = "17:00",
        [string]$Interval = "60"
    ) ;
    Write-Host "Computer: $ComputerName"
    #$Command = "schtasks.exe /create /s $ComputerName /ru $RunAsUser /tn $TaskName /tr $TaskRun /sc $Schedule /mo $Modifier /d $Days /m $Months /st $StartTime /et $EndTime /ri $Interval /F"
    #Invoke-Expression $Command
    #Clear-Variable Command -ErrorAction SilentlyContinue
    schtasks.exe /create /s $ComputerName /ru $RunAsUser /tn $TaskName /tr $TaskRun /sc $Schedule /mo $Modifier /d $Days /m $Months /st $StartTime /et $EndTime /ri $Interval /F
    Write-Host "`n"
} ; #*------^ END Function Create-ScheduledTaskLegacy ^------
