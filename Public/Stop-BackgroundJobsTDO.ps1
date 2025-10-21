# Stop-BackgroundJobsTDO.ps1

    #region STOP_BACKGROUNDJOBSTDO ; #*------v Stop-BackgroundJobsTDO v------
    Function Stop-BackgroundJobsTDO {
        <#
        .SYNOPSIS
        Stop-BackgroundJobsTDO - Receive-Job & Stop-Job pre-configured `$Global:BackgroundJobs (which are accumulated Start-Job's from other proceses), normally a manual fire, and as a Register-EngineEvent -SourceIdentifier PowerShell.Exiting binding.
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 20250711-0423PM
        FileName    : Stop-BackgroundJobsTDO.ps1
        License     : (none asserted)
        Copyright   : (none asserted)
        Github      : https://github.com/tostka/verb-ex2010
        Tags        : Powershell,Exchange,ExchangeServer,Install,Patch,Maintenance
        AddedCredit : Michel de Rooij / michel@eightwone.com
        AddedWebsite: http://eightwone.com
        AddedTwitter: URL
        REVISIONS
        * 10:17 AM 9/29/2025 reflects 4.20 github vers update:  port to vio from xopBuildLibrary; add CBH, and Adv Function specs; config defer of w-My to native wlt
        .DESCRIPTION
        Stop-BackgroundJobsTDO - Receive-Job & Stop-Job pre-configured `$Global:BackgroundJobs (which are accumulated Start-Job's from other proceses), normally a manual fire, and as a Register-EngineEvent -SourceIdentifier PowerShell.Exiting binding.
                
        .INPUTS
        None, no piped input.
        .OUTPUTS
        None.
        .EXAMPLE
        PS> Stop-BackgroundJobs -Name $ENV:COMPUTERNAME -Wait
        Demo pulling setup CAB version
        .EXAMPLE
        PS> write-verbose "pre-configure backgroundjobs and auto-cleanup via separate xopBuildLibrary\Stop-BackgroundJobs() on exit trap" ; 
        PS> $BackgroundJobs= @() ; 
        PS> Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
        PS>     Stop-BackgroundJobs 
        PS> } | Out-Null ; 
        PS> TRAP {
        PS>     Write-MyWarning 'Script termination detected, cleaning up background jobs...'
        PS>     Stop-BackgroundJobs
        PS>     break
        PS> } ; 
        PS> if (-not $Global:BackgroundJobs) {
        PS>     $Global:BackgroundJobs = @()
        PS> }
        PS> $Job = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $Name, $ConfigNC -Name ('Clear-AutodiscoverSCP-{0}' -f $Name)
        PS> $Global:BackgroundJobs += $Job
        PS> Write-MyVerbose ('Started background job to clear AutodiscoverServiceConnectionPoint for {0} (Job ID: {1})' -f $Name, $Job.Id)        
        PS> write-verbose "Then Cleanup any background jobs" ; 
        PS> Stop-BackgroundJobs ; 
        Demo preconfiguring backgroundjobs cleanup, run SCP config pass, run install pass, and then post-cleanup backgroundjobs
        .LINK
        https://github.org/tostka/powershellBB/
        #>
        [CmdletBinding()]
        [alias('Stop-BackgroundJobs')]
        PARAM()
        if ($Global:BackgroundJobs -and $Global:BackgroundJobs.Count -gt 0) {
            $smsg = "Cleaning up $($Global:BackgroundJobs.Count) background job(s)..."
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {                
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            } ;
            foreach ($Job in $Global:BackgroundJobs) {
                if ($Job.State -eq 'Running') {
                    Stop-Job -Job $Job -ErrorAction SilentlyContinue
                }
                $JobOutput= Receive-Job -Job $Job
                $smsg =  ('Cleanup background job: {0} (ID {1}), Output {2}' -f $Job.Name, $Job.Id, $JobOutput) ; 
                if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {                
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                } ;
                Remove-Job -Job $Job -Force -ErrorAction SilentlyContinue
            }
            $Global:BackgroundJobs = @()
            $smsg = "Background job cleanup completed."
            if(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {                
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent} 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            } ;
        } ; 
    } ; 
    #endregion STOP_BACKGROUNDJOBSTDO ; #*------^ END Stop-BackgroundJobsTDO ^------