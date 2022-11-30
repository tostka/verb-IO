#*----------v Function stop-driveburn() v----------
Function stop-driveburn {
    <#
    .SYNOPSIS
    stop-driveburn - stop drive high IO processes that lag down workstation
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-10-05
    FileName    : stop-driveburn.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Performance,Workstation
    REVISIONS
    * 10:50 AM 11/29/2022 added logging, to track how often landesk processes are impeding productive work.
    7:35 AM 10/5/2020 ported to verb-IO, updated tsksid/admin-incl-ServerCore.ps1
    * 8:48 AM 10/22/2019 added ldesk gatherproducts
    *11:34 AM 4/16/2019 rearranging cmd order
    * 11:46 AM 3/12/2019 rewrote/internalized the wsearch stop, updated the output to be write-hosts with timestamps
    *7:57 AM 2/27/2018 #36, was getting obj as output, tried out-string/out-default to see if we could clean it to just the id & name properties as string
    *9:04 AM 10/18/2017 found it picking up $whatif from ps, so added it as an explicit param (don't want a whatif, want them dead), added sig, added passthrough -whatif on the stop-indexing call
    *9:47 AM 5/5/2017 broke out, had it echo on matches, added pshelps, added process echos & results
    *7:01 AM 3/31/2017 added call to stop-indexing-win7.ps1
    *7:35 AM 3/20/2017 initial vers
    .DESCRIPTION
    stop-driveburn - stop drive high IO processes that lag down workstation
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    .EXAMPLE
    stop-driveburn
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    #>
    [CmdletBinding()]
    [Alias('sdb')]
    Param([Parameter(HelpMessage="Whatif Flag  [-whatIf]")][switch] $whatIf) ; 
    
    #*======v SUB MAIN v======
    # add logging support
    #region INIT; # ------
    # Get the name of this function
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    # Get parameters this function was invoked with
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    $verbose = ($VerbosePreference -eq "Continue") ; 
    $NoLoop = $true ; 
    # SETUP CROSS-VERSION-COMPAT. $PS* VARIABLES
    if($showDebug){write-debug -verbose:$true "`SHOWDEBUG: `$PSScriptRoot:$($PSScriptRoot)`n`$PSCommandPath:$($PSCommandPath)"} ;
    if ($PSScriptRoot -eq "") {
        if ($psISE){
            $ScriptName = $psISE.CurrentFile.FullPath ;
        } elseif ($context = $psEditor.GetEditorContext()) {
            $ScriptName = $context.CurrentFile.Path ;
        } elseif($host.version.major -lt 3){
            $ScriptName = $MyInvocation.MyCommand.Path ;
            $PSScriptRoot = Split-Path $ScriptName -Parent ;
            $PSCommandPath = $ScriptName ;
        } else {
            if($MyInvocation.MyCommand.Path) {
                $ScriptName = $MyInvocation.MyCommand.Path ;
                $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent ;
            } else {
                throw "UNABLE TO POPULATE SCRIPT PATH, EVEN `$MyInvocation IS BLANK!" ;
            } ;
        };
        $ScriptDir = Split-Path -Parent $ScriptName ;
        $ScriptBaseName = split-path -leaf $ScriptName ;
        $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($ScriptName) ;
    } else {
        $ScriptDir = $PSScriptRoot ;
        if($PSCommandPath){
            $ScriptName = $PSCommandPath ;
        } else {
            $ScriptName = $myInvocation.ScriptName
            $PSCommandPath = $ScriptName ;
        } ;
        $ScriptBaseName = (Split-Path -Leaf ((&{$myInvocation}).ScriptName))  ;
        $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;
    } ; 
    if($showDebug){write-debug -verbose:$true "`$ScriptDir:$($ScriptDir)`n`$ScriptBaseName:$($ScriptBaseName)`n`$ScriptNameNoExt:$($ScriptNameNoExt)`n`$PSScriptRoot:$($PSScriptRoot)`n`$PSCommandPath:$($PSCommandPath)" ; } ;
    #-=-=-=-=-=-=-=-=

    $ParentPath = $MyInvocation.MyCommand.Definition ; 
    if($ParentPath){
        $rgxProfilePaths='(\\Documents\\WindowsPowerShell\\scripts|\\Program\sFiles\\windowspowershell\\scripts)' ; 
        if($ParentPath -match $rgxProfilePaths){
            $ParentPath = "$(join-path -path 'c:\scripts\' -ChildPath (split-path $ParentPath -leaf))" ; 
        } ; 
        if($NoLoop){
            $logspec = start-Log -Path ($ParentPath) -showdebug:$($showdebug) -whatif:$($whatif) -NoTimestamp ;
            $smsg = "-NoLoop specified:`$logspec returned:$(($logspec|out-string).trim())" ; 
            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('yyyyMMdd-HHmm')):$($smsg)" } ; } ; 
        } else { 
            $logspec = start-Log -Path ($ParentPath) -showdebug:$($showdebug) -whatif:$($whatif) ;
            $smsg = "(Looping...):`$logspec returned:$(($logspec|out-string).trim())" ; 
            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('yyyyMMdd-HHmm')):$($smsg)" } ; } ; 

        } ; 
        if($logspec){
            $logging=$logspec.logging ;
            $logfile=$logspec.logfile ;
            $transcript=$logspec.transcript ;
        } else {$smsg = "Unable to configure logging!" ; write-warning "$((get-date).ToString('yyyyMMdd-HHmm')):$($sMsg)" ; Exit ;} ;
    } else {$smsg = "No functional `$ParentPath found!" ; write-warning "$((get-date).ToString('yyyyMMdd-HHmm')):$($sMsg)" ;  Exit ;} ;

    $smtpFrom = (($scriptBaseName.replace(".","-")) + "@toro.com") ; 

    #endregion INIT; # ------
    
    $smsg = "$((get-date).ToString('HH:mm:ss')):KILLING DRIVE SUCKERS!`nQUIT READING BY THE HARDDRIVE LIGHT!" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
    "LDIScn32","Cagent32","gatherproducts" | foreach {
        #"==Checking for $($_)" ;
        if($gp=get-process "$($_)" -ea 0 ){
            $smsg = "$((get-date).ToString('HH:mm:ss')):PROCMATCH:Stopping proc:`n$(($gp | ft -auto ID,ProcessName|out-string).trim())" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $gp | stop-process -force -whatif:$($whatif)
        } else {
            $smsg = "$((get-date).ToString('HH:mm:ss')):(no $($_) processes found)" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ; 
    } ; 

    #  tack index stop in here too
    $stat=(Get-Service -Name wsearch).status ; 
    $smsg = "$((get-date).ToString('HH:mm:ss')):===Windows Search:Status:$($stat)" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    if ($stat -eq 'Running') {
        $smsg = "$((get-date).ToString('HH:mm:ss')):STOPPING WSEARCH SVC" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        stop-Service -Name wsearch ; 
    } else { 
        write-verbose "$((get-date).ToString('HH:mm:ss')):(wsearch is *not* running)" ; 
    } ; 
    write-verbose "$((get-date).ToString('HH:mm:ss')):(waiting 5secs to close)" ; 
    #start-sleep -s 5 ; 
} ;
#*------^ END Function stop-driveburn ^------
