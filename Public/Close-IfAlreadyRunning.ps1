#*------v Function Close-IfAlreadyRunning v------
Function Close-IfAlreadyRunning {
    <#
    .SYNOPSIS
    Close-IfAlreadyRunning.ps1 - Kills CURRENT instance of specified powershell script, if another instance already running.
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : Mr. Annoyed
    AddedWebsite: https://stackoverflow.com/users/4995131/mr-annoyed
    REVISIONS
    * 7:25 AM 10/27/2020 revised cbh, tightened up ; ren Test-IfAlreadyRunning->close-IfAlreadyRunning
    * 11/6/15 Mr Annoyed posted vers
    .DESCRIPTION
    Close-IfAlreadyRunning.ps1 - Kills CURRENT instance of specified powershell script, if another instance already running.
    (orig code Mr. Annoyed)
    .PARAMETER  ScriptName
    ScriptName to be checked[-ScriptName script.ps1]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    .EXAMPLE
    if($MyInvocation.MyCommand.Name){Close-IfAlreadyRunning -ScriptName $MyInvocation.MyCommand.Name }; 
    Close running powershell instance, if another instance is running the same script. 
    .LINK
    https://stackoverflow.com/questions/15969662/assure-only-1-instance-of-powershell-script-is-running-at-any-given-time
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,HelpMessage="ScriptName to be checked[-ScriptName script.ps1]")]
        [ValidateNotNullorEmpty()][String]$ScriptName 
    ) ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    #note: Can't self-discover calling script: $MyInvocation.MyCommand.Name gets name of *this function*
    Foreach ($PsCmdLine in (get-wmiobject win32_process | where{$_.processname -eq 'powershell.exe'} | select-object commandline,ProcessId )){
        [Int32]$OtherPID = $PsCmdLine.ProcessId ; 
        # $PID is a Autovariable for the current script''s Process ID number ; 
        write-verbose "checking PID:$($PsCmdLine.ProcessId):CmdLine:$($PsCmdLine.commandline)" ; 
        If ( ([String]$PsCmdLine.commandline -match $ScriptName) -And ($OtherPID -ne $PID) ){
            Write-host "PID [$OtherPID] is already running this script [$ScriptName]" ; 
            Write-host "Exiting this instance. (PID=[$PID])..." ; 
            Start-Sleep -Second 7 ; 
            Stop-Process -id $PID -Force ; # kill ps hosting this instance
            Exit ; # exit if the kill didn't work
        } ; 
    } ; 
} ; #*------^ END Function Close-IfAlreadyRunning ^------
