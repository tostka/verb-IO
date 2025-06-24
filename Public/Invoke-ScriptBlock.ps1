# Invoke-ScriptBlock.ps1

#region Invoke_ScriptBlock ; #*------v function Invoke-ScriptBlock v------
#if (-not (get-item function:Invoke-ScriptBlock)){
    function Invoke-ScriptBlock {
        <#
        .SYNOPSIS
        Invoke-ScriptBlock - invoke a script block, provides valid return codes (-1 for a timeout; 0 for success) and doesn't leave any redundant processes running (ends process after Timeout)
        .NOTES
        Version     : 0.0.1
        Author      : Kae
        Website     : https://www.alkanesolutions.co.uk/author/kae/
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2023-12-22
        FileName    : Invoke-ScriptBlock
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      :
        Tags        : Powershell
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 8:32 AM 6/24/2025 functionalize into vio; added defer block; works fine, runs DiskCleanup CLEANMGR.exe, from schedtask, haven't seen it persist beyond run completion, but it def will close it in testing if you spec a timeout less than the run time requirements of the wizard (esp on initial pass, may want to use a longer timeout, and a short for subsequent runs)
        * 12:25 PM 6/23/202512/22/23 Kae posted sample/demo
        .DESCRIPTION
        Invoke-ScriptBlock - invoke a script block, provides valid return codes (-1 for a timeout; 0 for success) and doesn't leave any redundant processes running (ends process after Timeout)
        .PARAMETER scriptBlock
        ScriptBlock to be executed [-scriptBlock {'notepad.exe'}]
        .PARAMETER TimeOut
        Timeout in seconds, after which running process should be killed [-TimeOut '300']
        .INPUTS
        None. Does not accepted piped input.
        .OUTPUTS
        Returns integer exitcode status (-1 timeout/killed; 0 normal execution with exit)
        .EXAMPLE
        PS> Invoke-ScriptBlock -whatif -verbose
        PS> $sb = {
        PS>         exit (start-process msiexec.exe -passthru -wait).ExitCode
        PS> } ;
        PS> $exitCode = Invoke-ScriptBlock $sb 5 ;
        PS> write-host "Exit code was $exitCode" ;
        Spawning a process:Launch msiexec.exe.  If we close it within 5 seconds it will return a 1639 exit code. If we leave the dialog open, it will time out and return -1
        .EXAMPLE
        PS> $sb = {
        PS>     try {
        PS>         start-sleep -seconds 6 ;
        PS>         exit 0 ;
        PS>     } catch {
        PS>         exit -999 ;
        PS>     } ;
        PS> } ;
        Running a cmdlet:change timeout to 5 seconds (less than sleep duration) to return -1 and a timeout change timeout to 7 seconds (more than the sleep duration) to return 0 and a success
        .EXAMPLE
        PS> $first = "Alkane" ;
        PS> $last = "Solutions" ;
        PS> $params = -join ("Param(",
        PS> "[string]`$first = '$first',",
        PS> "[string]`$last = '$last'",
        PS> ")") ;
        PS> $sb = $params + {
        PS>     try {
        PS>         "$first $last" | Out-File c:\Alkane\Alkane.txt
        PS>         exit 0 ;
        PS>     } catch {
        PS>         exit -999 ;
        PS>     } ;
        PS> } ;
        PS> $exitCode = Invoke-ScriptBlock $sb 5 ;
        PS> write-host "Exit code was $exitCode" ;
        Pass parameters to script block, Check output in c:\Alkane\Alkane.txt
        .LINK
        https://www.alkanesolutions.co.uk/2023/12/22/setting-a-timeout-in-powershell-scripts-to-prevent-hanging/
        #>
        PARAM(
            [Parameter(Mandatory = $True, HelpMessage = "ScriptBlock to be executed [-scriptBlock {'notepad.exe'}]")]
                [string]$scriptBlock,
            [Parameter(Mandatory = $True, HelpMessage = "Timeout in seconds, after which running process should be killed [-TimeOut '300']")]
                [int]$TimeOut
        ) ;
        #encode script to obfuscate
        $encodedScriptBlock = [convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($scriptBlock)) ;
        $Arguments = "-Noexit", "-NoLogo", "-NoProfile", "-ExecutionPolicy Bypass", "-EncodedCommand $encodedScriptBlock"    ;
        $ProcessStartInfoParam = [ordered]@{
            Arguments       = $Arguments -join " " ;
            FileName        = "powershell.exe" ;
            LoadUserProfile = $false ;
            UseShellExecute = $false    ;
            CreateNoWindow  = $true ;
        } ;
        $ProcessStartInfo = New-Object -TypeName "System.Diagnostics.ProcessStartInfo" -Property $ProcessStartInfoParam ;
        $proc = New-Object "System.Diagnostics.Process" ;
        $proc.StartInfo = $ProcessStartInfo ;
        $proc.Start() | Out-Null ;
        $timedOut = $null ;
        $proc | Wait-Process -Timeout $TimeOut -ErrorAction SilentlyContinue -ErrorVariable timedOut ;
        if ($timedOut) {
            #timed out
            $parentProcessId = $proc.Id ;
            $parentProcessName = $proc.Name ;
            foreach ($childProcess in (Get-WmiObject win32_process -Filter "ParentProcessId='$parentProcessId'")) {
                $childProcessId = $childprocess.processid ;
                $childProcessName = $childProcess.Name ;
                & taskkill /PID $childProcessId /f /t /fi "STATUS eq RUNNING" 2>&1>$null ;
            } ;
            return -1 ;
        } else {
            return $proc.ExitCode ;
        } ;
    } ;
#} ;
#endregion Invoke_ScriptBlock ; #*------^ END Invoke-ScriptBlock ^------