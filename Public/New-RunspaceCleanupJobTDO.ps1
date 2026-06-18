# New-RunspaceCleanupJob.ps1

#region NEW_RUNSPACECLEANUPJOB ; #*------v New-RunspaceCleanupJobTDO v------
if(-not (gcm New-RunspaceCleanupJobTDO -ea 0)){
    Function New-RunspaceCleanupJobTDO {            
        <#
        You use this function like this:
        $newrunspace = <code>
        $pscmd = [powershell]::create()

        add commands to $pscmd
        $pscmd.runspace = $newrunspace
        $handle = $pscmd.beginInvoke()

        Start a thread job to test if runspace is being used and close it if it is finished
        New-RunspaceCleanupJobTDO -handle $handle -powershell $pscmd -sleepinterval 30

        * 10:51 AM 6/18/2026 PSScriptTools component, ported to verb-dev, to support ConvertTo-WPFGridTDO()
        #>
        <#
        .SYNOPSIS
        New-RunspaceCleanupJobTDO - test if runspace is being used and close it if it is finished.
        .NOTES
        Version     : 3.0.0
        Author: Jeff Hicks
        Website     :	https://github.com/jdhitsolutions
        Twitter     :	
        CreatedDate : 2026-06-15
        FileName    : New-RunspaceCleanupJobTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/jdhitsolutions/PSScriptTools/blob/main/functions/New-RunspaceCleanupJobTDO.ps1
        Tags        : Powershell,Certificate,Developoment,output,grid
        AddedCredit : 
        AddedWebsite:	
        AddedTwitter:	
        REVISIONS   :
        * 3/3/2023 JH posted vers v3.0.0
        .PARAMETER Handle
        This should be the System.Management.Automation.Runspaces.AsyncResult object from the BeginInvoke() method.
        .PARAMETER PowerShell
                
        .PARAMETER SleepInterval
        Specify a sleep interval in seconds
        .PARAMETER Handle
        This should be the System.Management.Automation.Runspaces.AsyncResult object from the BeginInvoke() method.
        .PARAMETER PassThru
        Pass the thread job object to the pipeline
        .INPUTS
        PSObject
        .OUTPUT
        None,ThreadJob
        .DESCRIPTION
        New-RunspaceCleanupJobTDO - test if runspace is being used and close it if it is finished.

        .EXAMPLE
        PS> $newrunspace = <code> ; 
        PS> $pscmd = [powershell]::create() ; 
        PS> write-verbose "add commands to $pscmd" ; 
        PS> $pscmd.runspace = $newrunspace ; 
        PS> $handle = $pscmd.beginInvoke() ; 
        PS> write-verbose "Start a thread job to test if runspace is being used and close it if it is finished" ; 
        PS> New-RunspaceCleanupJobTDO -handle $handle -powershell $pscmd -sleepinterval 30; 
        Typical usage demo
        .LINK
        https://github.com/jdhitsolutions/PSScriptTools/blob/main/docs/New-RunspaceCleanupJobTDO.md
        #>
        [cmdletbinding()]
        [Alias('New-RunspaceCleanupJob')]
        [OutputType("None", "ThreadJob")]
        Param(
            [Parameter(Mandatory, HelpMessage = "This should be the System.Management.Automation.Runspaces.AsyncResult object from the BeginInvoke() method.")]
                [ValidateNotNullOrEmpty()]
                [object]$Handle,
            [Parameter(Mandatory, HelpMessage = ".")]
                [ValidateNotNullOrEmpty()]
                [System.Management.Automation.PowerShell]$PowerShell,
            [Parameter(HelpMessage = "Specify a sleep interval in seconds")]
                [ValidateRange(5, 600)]
                [int32]$SleepInterval = 10,
            [Parameter(HelpMessage = "Pass the thread job object to the pipeline")]
                [switch]$PassThru
        )
        $job = Start-ThreadJob -ScriptBlock {
            param($handle, $ps, $sleep)
            #the Write-Host lines are so that if you look at the results of  the thread job
            #you'll see something you can use for debugging or troubleshooting.
            Write-Host "[$(Get-Date)] Sleeping in $sleep second loops"
            Write-Host "Watching this runspace"
            Write-Host ($ps.runspace | Select-Object -property * | Out-String)
            #loop until the handle shows as completed, sleeping the the specified
            #number of seconds
            do {
                Start-Sleep -Seconds $sleep
            } Until ($handle.IsCompleted)
            Write-Host "[$(Get-Date)] Closing runspace"
            $ps.runspace.close()
            Write-Host "[$(Get-Date)] Disposing runspace"
            $ps.runspace.Dispose()
            Write-Host "[$(Get-Date)] Disposing PowerShell"
            $ps.dispose()
            Write-Host "[$(Get-Date)] Ending job"
        } -ArgumentList $Handle, $PowerShell, $SleepInterval
        if ($PassThru) {
            #Write the ThreadJob object to the pipeline
            $job
        }
    }
}
#endregion NEW_RUNSPACECLEANUPJOB ; #*------^ END  ^------
            