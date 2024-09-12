#*----------------v Function copy-ProfileTDO v------
function copy-ProfileTDO {
    <#
    .SYNOPSIS
    copy-ProfileTDO() - Copies $SourceProfileMachine WindowsPowershell profile dir to the specified machine(s)
    .NOTES
    Author: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 4:51 PM 9/12/2024 add -force, to recopy everything regardless of update/sync status; move into verb-io
    * 8:46 AM 9/11/2024 set $doHashes default $false; 
        added processing grouping brackets ; 
        added 'Directory' (parent dir leaf folder name) to $prpFiles; 
        coded the non $doHashes blocks to process $targetset filtered on $profilefiles names, & Compare-Object -Ref $profilefiles  -Dif $targetset -Property Name,Length,LastWriteTime ;  ; 
        updated all of the CATCH blocks to latest ; 
        added timers ($swM,$sw); flip all to the $prpfiles prop subset, don't need all the extra overhead, which means,
         always use an [array], not [system.io.fileinfo[] or [string[]]
    * 2:33 PM 9/10/2024 jb debugging updates: sub'd out unreachable test-connection validatescripts (can't ismp from jb to admin devbox) ; 
        conditionally flip the type of return: [array] for hash inclusion, and [system.io.fileinfo[]] for stock object, if returning a subset, just do array; 
        added timers for comparing hash use etc to copy everything; added the html related profile files to the mix; 
        simplified the backdown, to use gci -path \* -incl ($profilefiles.name | select -unique), to autoresolve and pull the pendant hashes, wo sublooping
        expanded all gci -> get-childitem ; flipped return to array of fullnames, to returning the object, and then to returning key properties of the full object
    * 3:43 PM 9/9/2024 coded in hash checking, and run from 7330, trying to speed 
        up outcopy: they have icmp cmpltely blocked in to admin laptops, and clientsvcs 
        also doesn't have them registered in internal dns; so had to recode to use 
        \\tsclient 
        unfort, speed accessing down into vpn is even slower, than speed copying out of vpn, on every target. Hash checking also appears to be as slow as copying back and copmaring the existing files... so it's a bust too
        Prob only speed improve can make would be to buffer back target name, length, LastWriteTime , and trigger copy if they don't match the source. Moving on for now. 
        added new -dohashes param; coded in code to compare-object file hashes, to selectively copy only the differenced files ; sub'd out all Exit -> Break ; 
    * 8:21 PM 9/8/2024 save out to git
    * 12:08 PM 9/6/2024 subd out the profile file collection logic into new get-ProfileFilesTDO()
    *2:49 PM 9/5/2024 ren $pltProDir -> $pltMkDir, to make clear what it's doing; rename actual file copy-Profile.ps1 -> copy-ProfileTDO.ps1 (match revised func name)
    * 2:14 PM 8/19/2024 ren to copy-ProfileTDO, and alias copy-profile orig name
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 9:47 AM 9/24/2020 updated CBH, copied to verb-IO mod; added -MinProfile to drive admin/svcacct copying 
    * 10:41 AM 3/26/2020 rewrote, added verbose support, condensed 
    8:07 AM 6/12/2015 - functionalize copy code from the EMS block
    .DESCRIPTION
    copy-ProfileTDO() - Copies $SourceProfileMachine WindowsPowershell profile dir to the specified machine(s)
    .PARAMETER  ComputerName
    Name or IP address of the target computer
    .PARAMETER SourceProfileMachine
    Source Name or IP address of the source Profile computer
    .PARAMETER TargetProfile
    Target Account for Profile copy process [domain\logon]
    .PARAMETER showProgress
    Show Progress bar reflecting progress toward completion
    .PARAMETER doHashes
    Switch to generate & return File hashes (via get-fileHash cmdlet; *slower*)[-doHashes]
    .PARAMETER Force
    Switch to recopy *all* content, whether updated or not (trumps -doHashes, or default checks for chgs in name,length,LastWriteTime).[-force]
    .PARAMETER showDebug
    Show Debugging messages
    .PARAMETER whatIf
    Execute solely a test pass
    .PARAMETER Credential
    Credential object for use in accessing the computers.
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns an object with uptime data to the pipeline.
    .EXAMPLE
    PS> $Exs=(get-exchangeserver | ?{(($_.IsMailboxServer) -OR ($_.IsHubTransportServer))} )
    PS> if($Exs){
    PS>     copy-ProfileTDO -ComputerName $Exs -SourceProfileMachine $SourceProfileMachine -TargetProfile $TargetProfileAcct -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    PS> } else {write-verbose -verbose:$true "$((get-date).ToString('HH:mm:ss')):No Mbx or HT servers found)"} ;
    Copy targetprofile to all Exchange servers (leveraging ExchMgmtShell cmd)
    .EXAMPLE
    PS> if($AdminJumpBox ){
    PS>     write-verbose -verbose:$true "$((get-date).ToString('HH:mm:ss')):AdminJumpBox..."
    PS>     copy-ProfileTDO -ComputerName $AdminJumpBox -SourceProfileMachine $SourceProfileMachine -TargetProfile $TargetProfileAcct -JumpBox -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    PS> } ; 
    Perform a full 'admin' profile copy into target jumpbox (specifies -JumpBox param)
    .EXAMPLE
    PS> copy-ProfileTDO -ComputerName $JumpBox -SourceProfileMachine $SourceProfileMachine -TargetProfile $SvcAcctProf -JumpBox -MinProfile -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    # Copy the minimum profile to specified Service Account Profile on jumpboxes
    #>
    [CmdletBinding()]
    [Alias('copy-Profile')]
    PARAM (
        [parameter(ValueFromPipeline=$true,Mandatory=$True,HelpMessage="Specify Target Computer for Profile Copy[-ComputerName SERVER]")]
            [Alias('__ServerName','Server','Computer','Name','IPAddress','CN')]   
            [string[]]$ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory=$True,HelpMessage="Source Profile Machine [-SourceProfileMachine CLIENT]")]
            [ValidateNotNullOrEmpty()]
            [string]$SourceProfileMachine,    
        [parameter(Mandatory=$True,HelpMessage="Target Account for Profile copy process (alt specify a path to cache a full profile copy) [-TargetProfile DOMAIN\LOGON]")]
            [ValidatePattern('^\w*\\[A-Za-z0-9-]*$')]
            [string]$TargetProfile,      
        [parameter(HelpMessage="Credential object for use in accessing the computers")]
            [System.Management.Automation.PSCredential]$Credential,
        [Parameter(HelpMessage='-JumpBox  Flag [-JumpBox]')]
            [switch] $JumpBox ,
        [Parameter(HelpMessage='-MinProfile  Flag (copies least admin-related files)[-JumpBox]')]
            [switch] $MinProfile ,
        [Parameter(HelpMessage='Switch to generate & return File hashes (via get-fileHash cmdlet; *slower*)[-doHashes]')]
            [switch] $doHashes,
        [Parameter(HelpMessage='Switch to recopy *all* content, whether updated or not (trumps -doHashes, or default checks for chgs in name,length,LastWriteTime).[-force]')]
            [switch]$Force,
        [Parameter(HelpMessage='Debugging Flag [-showDebug]')]
            [switch] $showDebug,
        [Parameter(HelpMessage='Whatif Flag  [-whatif]')]
            [switch] $whatIf
    ) ;  # PARAM-E
    BEGIN {
        $verbose = ($VerbosePreference -eq 'Continue') ; 
        If ($whatIf){write-host "`$whatIf is $true" ; $bWhatif=$true}; 
        
        # master timer
        $swM = [Diagnostics.Stopwatch]::StartNew();

        $AdminLogon=$TargetProfile.split("\")[1] ;
        #"SAMACCOUNTNAME" ; 
        $AdminDomain=$TargetProfile.split("\")[0] ;
        #"DOMAIN" ; 
        $TargetProfileAcct=$TargetProfile ;
        #"$($AdminDomain)\$($AdminLogon)";
        
        $iProcd=0; 

        # copy the same profile files to all dests, resolve the set once, not each loop

        $gPFTDO=[ordered]@{
            SourceProfileMachine = $null ; #$mybox[0] ;
            targetProfileName = $AdminLogon ;
            MinProfile = $null ; #$true ;
            inclBackFill = $null ; #$true ;
            #backFillDir = 'c:\usr\work\exch\scripts\' ;
            #ProfileSourcePath = "c`$\sc\powershell\PSProfileUID\" ;
            Verbose = $($PSBoundParameters['Verbose'] -eq $true) ;
            #Credential = $Credential     
        } ;
        if($SourceProfileMachine){
            $gPFTDO.SourceProfileMachine = $SourceProfileMachine ; 
        } ; 
        if($MinProfile){
            $gPFTDO.MinProfile = $MinProfile ; 
        } ;
        if($doHashes){
            $gPFTDO.add('doHashes',$dohashes) ; 
        } 
        $gPFTDO.inclBackFill = $true ; 
        $smsg = "get-ProfileFilesTDO w`n$(($gPFTDO|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        [array]$masterprofilefiles = get-ProfileFilesTDO @gPFTDO

    }  # BEG-E
    PROCESS {
        $ttl = $Computername |  measure | select -expand count ; 
        $procNo = 0 ; 
        
        $whBnr5 =@{BackgroundColor = 'White' ; ForegroundColor = 'DarkRed' } ;
        foreach ($Computer in $Computername) {
            $procNo++ ; 
            $continue = $true
            $error.clear() ;
            TRY { 
                $ErrorActionPreference = "Stop" ;

                $sBnr5="`n#*______v PROCESSING : $($Computer) v______" ; 
                write-host @whBnr5 -obj "$((get-date).ToString('HH:mm:ss')):$($sBnr5)" ;

                $pltMkdir=[ordered]@{
                    path="\\$Computer\c$\Users\$AdminLogon\Documents\WindowsPowerShell" ;
                    itemtype="directory" ;
                    Force=$true ;
                    whatif=$($whatif) ;
                } ; 
                if(!(test-path "\\$Computer\c$\Users\$AdminLogon\Documents\WindowsPowerShell")) {
                    $smsg = "new-item w`n$(($pltMkdir|out-string).trim())" ; 
                    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    new-item @pltMkdir ; 
                };

                #[array]$profileFiles = "\\$SourceProfileMachine\c$\usr\work\exch\scripts\profile.ps1","\\$SourceProfileMachine\c$\usr\work\exch\scripts\Microsoft.PowerShellISE_profile.ps1" ; 
                # 12:07 PM 9/6/2024 moved the logic into get-ProfileFilesTDO()
                # 2:22 PM 8/19/2024 these should source in primaries, not 2ndary out of band's (long out of date when checked)
                #[array]$profileFiles = "\\$SourceProfileMachine\c$\sc\powershell\PSProfileUID\profile.ps1","\\$SourceProfileMachine\c$\sc\powershell\PSProfileUID\Microsoft.PowerShellISE_profile.ps1" ; 

                $pltGPF=[ordered]@{
                    path="\\$Computer\c$\Users\$AdminLogon\Documents\WindowsPowerShell" ;
                    itemtype="directory" ;
                    Force=$true ;
                    whatif=$($whatif) ;
                } ; 
                if(!(test-path "\\$Computer\c$\Users\$AdminLogon\Documents\WindowsPowerShell")) {
                    $smsg = "new-item w`n$(($pltGPF|out-string).trim())" ; 
                    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    new-item @pltGPF ; 
                };

                <# disabled - we have a set, don't need to re-resolve, outside of adminjumpboxes
                $gPFTDO=[ordered]@{
                    SourceProfileMachine = $null ; #$mybox[0] ;
                    targetProfileName = $AdminLogon ;
                    MinProfile = $null ; #$true ;
                    inclBackFill = $null ; #$true ;
                    #backFillDir = 'c:\usr\work\exch\scripts\' ;
                    #ProfileSourcePath = "c`$\sc\powershell\PSProfileUID\" ;
                    Verbose = $($PSBoundParameters['Verbose'] -eq $true) ;
                    #Credential = $Credential     
                } ;
                if($SourceProfileMachine){
                    $gPFTDO.SourceProfileMachine = $SourceProfileMachine ; 
                } ; 
                if($MinProfile){
                    $gPFTDO.MinProfile = $MinProfile ; 
                } ;
                if($doHashes){
                    $gPFTDO.add('doHashes',$dohashes) ; 
                } 
                $smsg = "get-ProfileFilesTDO w`n$(($gPFTDO|out-string).trim())" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                $profilefiles = get-ProfileFilesTDO @gPFTDO ; 
                #>

                if($JumpBox -OR ($Computer -match $rgxAdminJumpBoxes)){
                
                    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):-JumpBox specified: Adding full remote profile.." ; 
                    # 3:27 PM 6/22/2020 update to cover admin files
                    if(-not $MinProfile){
                        #$rgxJumpboxFiles = '^((tor|tsk|admin|(tsk|admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                        # sources from hard-coded git repo root path (fr a dev box)
                        #$profileFiles += gci -path "\\$SourceProfileMachine\c$\sc\powershell\PSProfileUID\*" |?{$_.name -match $rgxJumpboxFiles} | select -expand fullname  ; 
                        #[array]$profileFiles = get-ProfileFilesTDO -inclBackFill:$true -verbose ;
                        $gPFTDO.inclBackFill = $true 
                    } else { 
                        # minprofile drop tsk-related items
                        $rgxJumpboxAdminFiles = '^((tor|admin|(admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                        # sources from hard-coded git repo root path (fr a dev box)
                        #$profileFiles += gci -path "\\$SourceProfileMachine\c$\sc\powershell\PSProfileUID\*" |?{$_.name -match $rgxJumpboxAdminFiles} | select -expand fullname  ; 
                        #[array]$profileFiles = get-ProfileFilesTDO -MinProfile -verbose ;
                        $gPFTDO.MinProfile = $true 
                    } ; 

                    $smsg = "get-ProfileFilesTDO w`n$(($gPFTDO|out-string).trim())" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    [array]$profilefiles = get-ProfileFilesTDO @gPFTDO

                } else {
                    # 2:31 PM 8/19/2024 above was only copying in the profile.ps1 & the ise profile, nothing else being updated, so we need to use the Minprofile option for any non-jumpbox, non SID acct
                    # should always copy the full set, if not -minprofile
                    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):no -MinProfile specified: Adding full remote profile.." ; 
                    if(-not $MinProfile){
                        #$rgxJumpboxFiles = '^((tor|tsk|admin|(tsk|admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                        # sources from hard-coded git repo root path (fr a dev box)
                        #$profileFiles += gci -path "\\$SourceProfileMachine\c$\sc\powershell\PSProfileUID\*" |?{$_.name -match $rgxJumpboxFiles} | select -expand fullname  ; 
                        #[array]$profileFiles = get-ProfileFilesTDO -inclBackFill:$true -verbose ;
                        $gPFTDO.inclBackFill = $true 
                    } else { 
                        # minprofile drop tsk-related items
                        $rgxJumpboxAdminFiles = '^((tor|admin|(admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                        # sources from hard-coded git repo root path (fr a dev box)
                        #$profileFiles += gci -path "\\$SourceProfileMachine\c$\sc\powershell\PSProfileUID\*" |?{$_.name -match $rgxJumpboxAdminFiles} | select -expand fullname  ; 
                        #[array]$profileFiles = get-ProfileFilesTDO -MinProfile -verbose ;
                        $gPFTDO.MinProfile = $true 
                    } ; 
                    $profilefiles = $masterprofilefiles ; 
                } ;  

                if($profilefiles){
                    $sw = [Diagnostics.Stopwatch]::StartNew();
                    $pltCopy = [ordered]@{
                        path= $null ; #$profileFiles ; 
                        destination=$pltMkdir.path ;
                        force=$true ;
                        verbose = $true ; 
                        whatif=$($whatif) ;
                    } ; 
                    if($dohashes){
                        $prpFiles = 'Name','FullName','Extension','Length','LastWriteTime','LinkType','PSParentPath','PSPath','Directory',
                                @{name="Hash";expression={(Get-FileHash $_.FullName -Algorithm MD5).hash}}  ; 
                        $targetset = get-childitem "$($pltCopy.destination)\*" -Include $profilefiles.name | 
                            Select-Object -Property $prpFiles ; 
                        $nomatch = Compare-Object -Ref $profilefiles  -Dif $targetset -Property Name,Hash ; 
                        if($toCopy = $profilefiles |?{$nomatch.name -contains $_.name} | select -expand fullname ){
                            $pltCopy.Path = $toCopy  ; 
                        } else {
                            $smsg = "(all files match by name & hash)" ; 
                            write-host -foregroundcolor green $smsg ;
                        } ; 
                    }elseif($force){
                        write-host -foregroundcolor yellow "-force specified:re-copying *all* files, regardless of update status" ; 
                        $pltCopy.path = $profileFiles.fullname ; 
                    } else { 
                        # # condintional update copy: attribute level compare-object
                        $prpFiles = 'Name','FullName','Extension','Length','LastWriteTime','LinkType','PSParentPath','PSPath','Directory' ;
                        $targetset = get-childitem "$($pltCopy.destination)\*" -Include $profilefiles.name | 
                            Select-Object -Property $prpFiles ; 
                        $nomatch = Compare-Object -Ref $profilefiles  -Dif $targetset -Property Name,Length,LastWriteTime ; 
                        #$pltCopy.path = $profileFiles.fullname ; 
                        if($toCopy = $profilefiles |?{$nomatch.name -contains $_.name} | select -expand fullname ){
                            $pltCopy.Path = $toCopy  ; 
                        } else {
                            $smsg = "(all files match by Name,Length,LastWriteTime)" ;
                            write-host -foregroundcolor green $smsg ;
                        } ; 
                    } ; 
                    if($pltCopy.path){
                        $smsg = "copy-item w`n$(($pltCopy|out-string).trim())`n`$pltCopy.path:`n$(($pltCopy.path|out-string).trim())" ; 
                        if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                        copy-item @pltCopy ; 
                        $iProcd++
                    } else {
                        write-verbose "(nothing out of sync to copy)" ; 
                    } ;
                    #write-verbose "Timer Stop" ;
                    $sw.Stop() ;
                    $smsg =  "Elapsed Time: " ;
                    #$smsg = "$($iProcd) items converted in: " ;
                    if($host.version.major -ge 3){
                        $smsg =  ("$($smsg) {0:dd}d {0:hh}h {0:mm}m {0:ss}s {0:fff}ms" -f $sw.Elapsed) ; #outputs: Elapsed Time: 0d 0h 0m 10s 101ms
                    } else {
                        $smsg = "$($smsg) $($sw.Elapsed.ToString()))" ; # outputs: Elapsed Time: (HH:MM:SS.ms) 00:00:15.8418655
                    } ;
                    write-host -foregroundcolor gray "$((get-date).ToString('HH:mm:ss')):$($smsg)" ; 
                    
                } ; 
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Continue ; 
            } ; 
            
            write-host @whBnr5 -obj "$((get-date).ToString('HH:mm:ss')):$($sBnr5.replace('_v','_^').replace('v_','^_'))`n" ;
        } # loop-E
    } # PROC-E
    END {
        $smsg = "PROCESSED $($iProcd) machines" ; 
        if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        $iProcd | write-output ; 
        # master timer reporting
        #write-verbose "Timer Stop:Master" ;
        $swM.Stop() ;
        $smsg =  $smsg =  "$($pscmdlet.MyInvocation.InvocationName):Elapsed Time: " ; 
        #$smsg = "$($iProcd) items converted in: " ;
        if($host.version.major -ge 3){
            $smsg =  ("$($smsg) {0:dd}d {0:hh}h {0:mm}m {0:ss}s {0:fff}ms" -f $swM.Elapsed) ; #outputs: Elapsed Time: 0d 0h 0m 10s 101ms
        } else {
            $smsg = "$($smsg) $($swM.Elapsed.ToString()))" ; # outputs: Elapsed Time: (HH:MM:SS.ms) 00:00:15.8418655
        } ;
        write-host -foregroundcolor gray "$((get-date).ToString('HH:mm:ss')):$($smsg)" ; 
    } ; 
} #*----------------^ END Function copy-ProfileTDO ^--------
