#*------v Function Run-ScheduledTaskLegacy v------
Function Run-ScheduledTaskLegacy {
    <#
    .SYNOPSIS
    Run-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Based-on code by: Hugo @ peeetersonline
    Website:	http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    REVISIONS   :
    * 7:27 AM 12/2/2020 re-rename '*-ScheduledTaskCmd' -> '*-ScheduledTaskLegacy', L13 copy still had it, it's more descriptive as well.
    * 8:13 AM 11/24/2020 renamed to '*-ScheduledTaskCmd', to remove overlap with ScheduledTasks module
    * 8:15 AM 4/18/2017 write my own run- variant
    * 8:06 AM 4/18/2017 comment: Invoke-Expression is unnecessary. You can simply state: schtasks.exe /query /s $ComputerName
    * 7:42 AM 4/18/2017 tweaked, added pshelp, comments etc
    * June 4, 2009 posted version
    .DESCRIPTION
    Run-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    .PARAMETER  ComputerName
    Computer Name [-ComputerName server]
    .PARAMETER TaskName
    Name of Task being targeted
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns object summary of matched task(s)
    .EXAMPLE
    Run-ScheduledTaskLegacy -ComputerName Server01 -TaskName MyTask
    .LINK
    http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    #>
    param(
        [string]$ComputerName = "localhost",
        [string]$TaskName = "blank"
    ) ;
    If ((Get-ScheduledTaskLegacy -ComputerName $ComputerName) -match $TaskName) {
        #If ((Read-Host "Are you sure you want to remove task $TaskName from $ComputerName(y/n)") -eq "y") {
        #$Command = "schtasks.exe /delete /s $ComputerName /tn $TaskName /F" ;
        #Invoke-Expression $Command ;
        #Clear-Variable Command -ErrorAction SilentlyContinue ;
        # SCHTASKS /Run /S system /U user /P password /I /TN "Backup and Restore"
        schtasks.exe /Run /s $ComputerName /tn $TaskName ;
        #} ;
    }
    else {
        Write-Warning "Task $TaskName not found on $ComputerName" ;
    } ;
}
#*------^ END Function Run-ScheduledTaskLegacy ^------
