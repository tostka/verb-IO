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
    * 9:00 AM 12/12/2022 fixed broken added logging (spliced over holistic intact, w looping timestamp exempt)
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
    #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
    # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    write-verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    #if ($PSScriptRoot -eq "") {
    if( -not (get-variable -name PSScriptRoot -ea 0) -OR ($PSScriptRoot -eq '')){
        if ($psISE) { $ScriptName = $psISE.CurrentFile.FullPath } 
        elseif($psEditor){
            if ($context = $psEditor.GetEditorContext()) {$ScriptName = $context.CurrentFile.Path } 
        } elseif ($host.version.major -lt 3) {
            $ScriptName = $MyInvocation.MyCommand.Path ;
            $PSScriptRoot = Split-Path $ScriptName -Parent ;
            $PSCommandPath = $ScriptName ;
        } else {
            if ($MyInvocation.MyCommand.Path) {
                $ScriptName = $MyInvocation.MyCommand.Path ;
                $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent ;
            } else {throw "UNABLE TO POPULATE SCRIPT PATH, EVEN `$MyInvocation IS BLANK!" } ;
        };
        if($ScriptName){
            $ScriptDir = Split-Path -Parent $ScriptName ;
            $ScriptBaseName = split-path -leaf $ScriptName ;
            $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($ScriptName) ;
        } ; 
    } else {
        if($PSScriptRoot){$ScriptDir = $PSScriptRoot ;}
        else{
            write-warning "Unpopulated `$PSScriptRoot!" ; 
            $ScriptDir=(Split-Path -parent $MyInvocation.MyCommand.Definition) + "\" ;
        }
        if ($PSCommandPath) {$ScriptName = $PSCommandPath } 
        else {
            $ScriptName = $myInvocation.ScriptName
            $PSCommandPath = $ScriptName ;
        } ;
        $ScriptBaseName = (Split-Path -Leaf ((& { $myInvocation }).ScriptName))  ;
        $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;
    } ;
    if(!$ScriptDir){
        write-host "Failed `$ScriptDir resolution on PSv$($host.version.major): Falling back to $MyInvocation parsing..." ; 
        $ScriptDir=(Split-Path -parent $MyInvocation.MyCommand.Definition) + "\" ;
        $ScriptBaseName = (Split-Path -Leaf ((&{$myInvocation}).ScriptName))  ; 
        $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;     
    } else {
        if(-not $PSCommandPath ){
            $PSCommandPath  = $ScriptName ; 
            if($PSCommandPath){ write-host "(Derived missing `$PSCommandPath from `$ScriptName)" ; } ;
        } ; 
        if(-not $PSScriptRoot  ){
            $PSScriptRoot   = $ScriptDir ; 
            if($PSScriptRoot){ write-host "(Derived missing `$PSScriptRoot from `$ScriptDir)" ; } ;
        } ; 
    } ; 
    if(-not ($ScriptDir -AND $ScriptBaseName -AND $ScriptNameNoExt)){ 
        throw "Invalid Invocation. Blank `$ScriptDir/`$ScriptBaseName/`ScriptNameNoExt" ; 
        BREAK ; 
    } ; 

    $smsg = "`$ScriptDir:$($ScriptDir)" ;
    $smsg += "`n`$ScriptBaseName:$($ScriptBaseName)" ;
    $smsg += "`n`$ScriptNameNoExt:$($ScriptNameNoExt)" ;
    $smsg += "`n`$PSScriptRoot:$($PSScriptRoot)" ;
    $smsg += "`n`$PSCommandPath:$($PSCommandPath)" ;  ;
    write-host $smsg ; 
    
    $ComputerName = $env:COMPUTERNAME ;
    $NoProf = [bool]([Environment]::GetCommandLineArgs() -like '-noprofile'); # if($NoProf){# do this};
    #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

    #region START-LOG #*======v START-LOG OPTIONS v======
    #region START-LOG-HOLISTIC #*------v START-LOG-HOLISTIC v------
    # Single log for script/function example that accomodates detect/redirect from AllUsers scope'd installed code, and hunts a series of drive letters to find an alternate logging dir (defers to profile variables)
    #${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    if(!(get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
    foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
    if(!(get-variable rgxPSAllUsersScope -ea 0)){
        $rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;
    } ;
    if(!(get-variable rgxPSCurrUserScope -ea 0)){
        $rgxPSCurrUserScope="^$([regex]::escape([Environment]::GetFolderPath('MyDocuments')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps((d|m)*)1|dll)$" ;
    } ;
    $pltSL=[ordered]@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($whatif) ;} ;
    #$pltSL.Tag = $ModuleName ; 
    if($NoLoop){
        $pltSL.NoTimestamp = $true ;
        $smsg = "-NoLoop specified:"
    } else { 
        $smsg = "(Looping...):" ; 
        $pltSL.NoTimestamp = $false ; 
    } ; 
    if($script:PSCommandPath){
        if(($script:PSCommandPath -match $rgxPSAllUsersScope) -OR ($script:PSCommandPath -match $rgxPSCurrUserScope)){
            $bDivertLog = $true ; 
            switch -regex ($script:PSCommandPath){
                $rgxPSAllUsersScope{$smsg = "AllUsers"} 
                $rgxPSCurrUserScope{$smsg = "CurrentUser"}
            } ;
            $smsg += " context script/module, divert logging into [$budrv]:\scripts" 
            write-verbose $smsg  ;
            if($bDivertLog){
                if((split-path $script:PSCommandPath -leaf) -ne $cmdletname){
                    # function in a module/script installed to allusers|cu - defer name to Cmdlet/Function name
                    $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
                } else {
                    # installed allusers|CU script, use the hosting script name
                    $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
                }
            } ;
        } else {
            $pltSL.Path = $script:PSCommandPath ;
        } ;
    } else {
        if(($MyInvocation.MyCommand.Definition -match $rgxPSAllUsersScope) -OR ($MyInvocation.MyCommand.Definition -match $rgxPSCurrUserScope) ){
             $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
        } elseif(test-path $MyInvocation.MyCommand.Definition) {
            $pltSL.Path = $MyInvocation.MyCommand.Definition ;
        } elseif($cmdletname){
            $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
        } else {
            $smsg = "UNABLE TO RESOLVE A FUNCTIONAL `$CMDLETNAME, FROM WHICH TO BUILD A START-LOG.PATH!" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } #Error|Warn|Debug 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            BREAK ;
        } ; 
    } ;
    write-verbose "start-Log w`n$(($pltSL|out-string).trim())" ; 
    $logspec = start-Log @pltSL ;
    $error.clear() ;
    TRY {
        if($logspec){
            $logging=$logspec.logging ;
            $logfile=$logspec.logfile ;
            $transcript=$logspec.transcript ;
            $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
            if($stopResults){
                $smsg = "Stop-transcript:$($stopResults)" ; 
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            } ; 
            $startResults = start-Transcript -path $transcript ;
            if($startResults){
                $smsg = "start-transcript:$($startResults)" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ; 
        } else {throw "Unable to configure logging!" } ;
    } CATCH [System.Management.Automation.PSNotSupportedException]{
        if($host.name -eq 'Windows PowerShell ISE Host'){
            $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
        } else { 
            $smsg = "This host does *not* support native (start-)transcription" ; 
        } ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ;
    #endregion START-LOG-HOLISTIC #*------^ END START-LOG-HOLISTIC ^------
    #-=-=-=-=-=-=-=-=

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
