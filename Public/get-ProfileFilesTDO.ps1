#*----------------v Function get-ProfileFilesTDO v------
function get-ProfileFilesTDO {
    <#
    .SYNOPSIS
    get-ProfileFilesTDO() - Gather source $SourceProfileMachine WindowsPowershell profile dir contents for copying to other machine(s), from local git Repository directory (C:\sc\powershell\PSProfileUID\)
    .NOTES
    Author: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 4:51 PM 9/12/2024 add -force, to recopy everything regardless of update/sync status; move into verb-io
    * 8:46 AM 9/11/2024 set $doHashes default $false; added 'Directory' (parent dir leaf folder name) to $prpFiles; 
        added timers ($swM,$sw); flip all to the $prpfiles prop subset, don't need all the extra overhead, which means, always use an [array], not [system.io.fileinfo[] or [string[]]
        flip all [system.io.fileinfo[]] -> [array], as we're now returning key subset of file obj properties, slim down data size, and fileinfo doesn't support hashes;
    * 10:17 AM 9/9/2024 added -doHashes and calc'd hash prop return on files ; flipped return from array of UNC paths, to the full details including hash
    * 8:25 PM 9/8/2024 buffer out chgs to git
    * 4:21 PM 9/6/2024 debuged the updated logic on targetprofilename, working, need to build the calls into copy-profiletdo() ; 
       init, created to break out copy-ProfileTDO()'s file collecting logic into a portable separate function
    *2:49 PM 9/5/2024 ren $pltProDir -> $pltMkDir, to make clear what it's doing
    * 2:14 PM 8/19/2024 ren to get-ProfileFilesTDO, and alias copy-profile orig name
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 9:47 AM 9/24/2020 updated CBH, copied to verb-IO mod; added -MinProfile to drive admin/svcacct copying 
    * 10:41 AM 3/26/2020 rewrote, added verbose support, condensed 
    8:07 AM 6/12/2015 - functionalize copy code from the EMS block
    .DESCRIPTION
    get-ProfileFilesTDO() - Gather source $SourceProfileMachine WindowsPowershell profile dir contents for copying to other machine(s), from local git Repository directory (C:\sc\powershell\PSProfileUID\)

    Intent is to can-up and segregate the logic that assembles the profile files, to recycle them for both copying entire profile to remote machines, and for copying them to cached access paths.
    .PARAMETER SourceProfileMachine
    Source Name or IP address of the source Profile computer
    .PARAMETER MinProfile
    Switch that copies least admin-related files[-MinProfile]
    .PARAMETER inclBackFill
    switch to buffer in backfill uwes\verb-xxx.ps1 module backups (source module .psm1 files renamed to .ps1)[-showDebug]
    .PARAMETER backFillDir
    Optional directory that holds backfill files (which are .ps1 named copies of installed module .psm1 files - function as loadable backups if the main module is missing/damaged; defaults to uwes) [-backFillDir c:\pathto\]
    .PARAMETER ProfileSourcePath
    Directory that holds source profile files (defaults to c`$\sc\powershell\PSProfileUID\, normally within a git source repo) [-ProfileSourcePath c:\pathto\]    
    .PARAMETER doHashes
    Switch to generate & return File hashes (via get-fileHash cmdlet)[-doHashes]
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
    PS> $tpfiles = get-ProfileFilesTDO -inclBackFill -verbose ;
    PS> $tpfiles | cp -Destination c:\tmp\test -verbose ; 
    Demo collecting profile files with -inclBackfill, verbose and issuing a copy on the results.
    .EXAMPLE
    PS> $tpfiles = get-ProfileFilesTDO -MinProfile -verbose ;
    PS> $tpfiles | cp -Destination c:\tmp\test -verbose ; 
    Demo collecting -MinProfile profile files, verbose, and issuing a copy on the results.
    Perform a full 'admin' profile copy into target jumpbox (specifies -JumpBox param)
    .EXAMPLE
    PS> get-ProfileFilesTDO -SourceProfileMachine $SourceProfileMachine -TargetProfile $SvcAcctProf -JumpBox -MinProfile -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    # Copy the minimum profile to specified Service Account Profile on jumpboxes
    .EXAMPLE
    PS> $gPFTDO=[ordered]@{
    PS>     SourceProfileMachine = $mybox[0] ;
    PS>     targetProfileName = $SIDuid.split('\')[1] ;
    PS>     MinProfile = $true ;
    PS>     inclBackFill = $true ;
    PS>     backFillDir = 'c:\usr\work\exch\scripts\' ;
    PS>     ProfileSourcePath = "c`$\sc\powershell\PSProfileUID\" ;
    PS>     Verbose = $($PSBoundParameters['Verbose'] -eq $true) ;
    PS>     Credential = $Credential     
    PS> } ;
    PS> $smsg = "get-ProfileFilesTDO w`n$(($gPFTDO|out-string).trim())" ; 
    PS> if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    PS> $profilefiles = get-ProfileFilesTDO @gPFTDO ; 
    Splatted demo
    #>
    [CmdletBinding()]
    [Alias('Get-ProfileFiles')]
    PARAM (
        [Parameter(HelpMessage="Source Profile Machine [-SourceProfileMachine CLIENT]")]
            # default a value but ensure user doesn't override with null/empty value, don't use Mandetory, but use [ValidateNotNullOrEmpty()]
            [ValidateNotNullOrEmpty()]
            #isPingable
            #[validatescript({Test-Connection -ComputerName $_ -Quiet -Count 2})] 
            # disable, blocked validate - [redacted] in network/sec have blocked icmp to vpn'd admin workstations, and desktop have laptops not registering themselves properly in internal DNS!
            [string]$SourceProfileMachine = $mybox[0],    
        [Parameter(HelpMessage="UserProfile destation to use for filtering profile files [-targetProfileName domain\logon]")]
            [string]$targetProfileName,   
        [parameter(HelpMessage="Credential object for use in accessing the computers")]
            [System.Management.Automation.PSCredential]$Credential,
        [Parameter(HelpMessage='Switch that copies least admin-related files[-MinProfile]')]
            [switch] $MinProfile ,
        [Parameter(HelpMessage='switch to buffer in backfill uwes\verb-xxx.ps1 module backups (source module .psm1 files renamed to .ps1)[-showDebug]')]
            [switch] $inclBackFill,
        [Parameter(Mandatory=$False,HelpMessage="Optional directory that holds backfill files (which are .ps1 named copies of installed module .psm1 files - function as loadable backups if the main module is missing/damaged; defaults to uwes) [-backFillDir c:\pathto\]")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({Test-Path $_ -PathType 'Container'})]
            [System.IO.DirectoryInfo]$backFillDir = 'c:\usr\work\exch\scripts\',
        [Parameter(Mandatory=$False,HelpMessage="Directory that holds source profile files (defaults to c`$\sc\powershell\PSProfileUID\, normally within a git source repo) [-ProfileSourcePath c:\pathto\]")]
            [ValidateNotNullOrEmpty()]
            [ValidateScript({Test-Path $_ -PathType 'Container'})]
            [System.IO.DirectoryInfo]$ProfileSourcePath = "c:\sc\powershell\PSProfileUID\",
        [Parameter(HelpMessage='Switch to generate & return File hashes (via get-fileHash cmdlet)[-doHashes]')]
            [switch] $doHashes,
        [Parameter(HelpMessage='Debugging Flag [-showDebug]')]
            [switch] $showDebug,
        [Parameter(HelpMessage='Whatif Flag  [-whatif]')]
            [switch] $whatIf
    ) ;  # PARAM-E
    BEGIN {
        $verbose = ($VerbosePreference -eq 'Continue') ; 
        $rgxJumpboxFiles =      '^((tor|tsk|admin|(tsk|admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
        $rgxJumpboxAdminFiles = '^((tor|admin|(admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
        $rgxSamAcctNameTOR = "^[-A-Za-z0-9]{2,20}$"
        $rgxSamAcctName = "^(?![\.-])(?:[a-zA-Z0-9-.](?!\.$)){1,21}$"
        $rgxDomainSamAcctName = "^[a-zA-Z][a-zA-Z0-9\-\.]{0,61}[a-zA-Z]\\(?![\.-])(?:[a-zA-Z0-9-.](?!\.$)){1,21}$" ; 
        # updated for 2-63 .tlds in email addr spec
        $rgxUPN = "^([0-9a-zA-Z]+[-._+&'])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,63}$J" ; 
        $prpFTA = 'name','length','lastwritetime' ; 
        # master timer
        $swM = [Diagnostics.Stopwatch]::StartNew();

        #*------v Function _get-BackFileFiles v------
        function _get-BackFileFiles {
            [CmdletBinding()]
            PARAM(
                [Parameter(Mandatory=$true,HelpMessage="Source Profile Machine [-SourceProfileMachine CLIENT]")]
                    [ValidateNotNullOrEmpty()]
                    #isPingable
                    #[validatescript({Test-Connection -ComputerName $_ -Quiet -Count 2})]
                    [string]$SourceProfileMachine,
                [Parameter(Mandatory=$true,HelpMessage="Optional directory that holds backfill files (which are .ps1 named copies of installed module .psm1 files - function as loadable backups if the main module is missing/damaged; defaults to uwes) [-backFillDir c:\pathto\]")]
                    [ValidateNotNullOrEmpty()]
                    #[ValidateScript({Test-Path $_ -PathType 'Container'})]
                    [System.IO.DirectoryInfo]$backFillDir,
                [Parameter(HelpMessage='Switch to generate & return File hashes (via get-fileHash cmdlet)[-doHashes]')]
                    [switch] $doHashes
            ) ; 
            #$backFillDir = 'c:\usr\work\exch\scripts\'
            #if(-not (Test-Connection -ComputerName $SourceProfileMachine -Quiet -Count 2)){
            #    write-warning "hostname $($SourceProfileMachine) isn't ICMP-able, retrying via \\tsclient\..." ; 
            if($SourceProfileMachine -eq 'tsclient'){
                $SourcePath = "\\$(join-path -path $SourceProfileMachine -ChildPath $backFillDir.fullname.replace(':',''))" ; 
            } else { 
                $SourcePath = "\\$(join-path -path $SourceProfileMachine -ChildPath $backFillDir.fullname.replace(':','$'))" ; 
            } ; 
            if(test-path $SourcePath -PathType Container){
                write-verbose "Resolved `$SourcePath:$($SourcePath)" ; 
            }else{
                $smsg = "`$SourcePath does *NOT* resolve to an accessible UNC path!"
                write-warning $smsg ;
                throw $smsg ;
            } ; 
            $sw = [Diagnostics.Stopwatch]::StartNew();
            write-verbose "-inclBackFill: resolve backfill dir uwes\verb-*.ps1 files into those with actual modules installed locally" ; 
            # get-childitem c:\usr\work\exch\scripts\verb-*.ps1 |?{$_.name -notmatch '-pub\.ps1$'}
            #$backfillfiles = get-childitem (join-path -path $backFillDir.fullname -childpath 'verb-*.ps1') -ea STOP |?{$_.name -notmatch '-pub\.ps1$'}  ; 
            if($doHashes){
                $prpFiles = 'Name','FullName','Extension','Length','LastWriteTime','LinkType','PSParentPath','PSPath','Directory',
                    @{name="Hash";expression={(Get-FileHash $_.FullName -Algorithm MD5).hash}}  ; 
                $backfillfiles = get-childitem  (join-path -path $SourcePath -ChildPath 'verb-*.ps1') |
                    ?{$_.name -notmatch '-pub\.ps1$'} | 
                    Select-Object -Property $prpFiles ; 
            } else {
                $prpFiles = 'Name','FullName','Extension','Length','LastWriteTime','LinkType','PSParentPath','PSPath','Directory' ; 
                $backfillfiles = get-childitem  (join-path -path $SourcePath -ChildPath 'verb-*.ps1') |
                    ?{$_.name -notmatch '-pub\.ps1$'} | 
                    Select-Object -Property $prpFiles ;
            } ; 
            write-verbose "gather installed verb-* modules" ; 
            $gmols = gmo verb-* -list -ea STOP ;
            write-verbose "test backfillfiles for matching installed modules" ; 
            $hasmods = @() ; 
            $backfillfiles.name.replace('.ps1','') |foreach-object{
                $name = $_ ;
                write-verbose "==$($name)" ;
                if($gmols.name -contains $name){
                    write-verbose "Y:$($name)";
                    $hasmods+=@("$($name).ps1") ; 
                }else {write-verbose "N:$($name)"}  
            } ; 
            if($doHashes){
                # cant use fileinfo, if we add a hash prop
                [array]$rBackFileFiles = @() ; 
            } else { 
                #[system.io.fileinfo[]]$rBackFileFiles = @() ; 
                # always use array, to support varying properties in the schema
                [array]$rBackFileFiles = @() ; 
            } ; 
            foreach($bkfile in $backfillfiles){
                if($hasmods -contains $bkfile.name){
                    write-verbose "Add:`$BackFileFiles += $($bkfile.fullname)" ; 
                    $rBackFileFiles += $bkfile #.fullname ; 
                } ; 
            } ; 
            #$smsg = "Resolved base Profile Files + additional -inclBackFill:" ; 
            #$smsg += " $(($BackFileFiles |  measure | select -expand count |out-string).trim()) files" ; 
            $smsg = "Resolved Backfiles: $(($rBackFileFiles |  measure | select -expand count |out-string).trim()) files" ; 
            $smsg += "`nTypes:`n$(($rBackFileFiles | group extension | ft -a count,name |out-string).trim()) files" ; 
            write-host -foregroundcolor green $smsg ; 
            $smsg = "`$rBackFileFiles:`n$(($rBackFileFiles | sort LastWriteTime | ft -a $prpFTA|out-string).trim())" ; 
            write-verbose $smsg ;
            $rBackFileFiles | write-output ; 
            #$prpFiles = 'Name','FullName','Extension','Length','LastWriteTime','Hash','LinkType','PSParentPath','PSPath','Directory' ; 
            #$rBackFileFiles | select $prpFiles | write-output ; 

            write-verbose "Timer Stop" ;
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
        #*------^ END Function _get-BackFileFiles ^------
        
    }  # BEG-E
    PROCESS {
            $continue = $true
            $error.clear() ;
            TRY { 
                $ErrorActionPreference = "Stop" ;

                switch ($targetProfileName){
                    # with hyphen support (SIDs use them in later rev)
                    $rgxSamAcctName {
                        $smsg = "(-targetProfileName matches a SamAccountname)" ; 
                        write-verbose $smsg ; 
                    }
                    $rgxDomainSamAcctName {
                        $smsg = "Domain\SamAccountName matched: trimming to user SamAccountName" ; 
                        write-warning $smsg ; 
                        $targetProfileName = $targetProfileName.split('\')[-1] ; 
                    }
                    $rgxUPN {
                        $smsg = "-targetProfileName matches a UserPrincipalName/SmtpAddress, please specify a DOMAIN\samaccountname string" ; 
                        write-warning $smsg ; 
                        throw $smsg ;
                        break ; 
                    } ; 
                } ; 
                
                if(-not (Test-Connection -ComputerName $SourceProfileMachine -Quiet -Count 2)){
                    write-warning "hostname $($SourceProfileMachine) isn't ICMP-able, retrying via \\tsclient\..." ; 
                    if(test-path $(join-path -path "\\tsclient" -ChildPath $ProfileSourcePath.fullname.replace(':',''))){
                        $SourceProfileMachine = 'tsclient' ; 
                    }else {
                        $smsg = "UNABLE TO CONNECT TO DESIGATED $(join-path -path "\\tsclient" -ChildPath $ProfileSourcePath.fullname.replace(':',''))!" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ; 
                } ; 
                if($SourceProfileMachine -eq 'tsclient'){
                    $SourcePath = "\\$(join-path -path $SourceProfileMachine -ChildPath $ProfileSourcePath.fullname.replace(':',''))" ; 
                } else { 
                    $SourcePath = "\\$(join-path -path $SourceProfileMachine -ChildPath $ProfileSourcePath.fullname.replace(':','$'))" ; 
                } ; 
                if(test-path $SourcePath -PathType Container){
                    write-verbose "Resolved `$SourcePath:$($SourcePath)" ; 
                }else{
                    $smsg = "`$SourcePath does *NOT* resolve to an accessible UNC path!"
                    write-warning $smsg ;
                    throw $smsg ;
                } ; 


                [string[]]$profileFiles = @() ; 
                $profilefiles += @('profile.ps1','Microsoft.PowerShellISE_profile.ps1','tor-incl-infrastrings.ps1') 

                if($targetProfileName){
                    write-host "-targetProfileName: $($targetProfileName)" ; 
                } else {
                    $targetProfileName = 'ALL' ; 
                } ; 

                switch ($targetProfileName){
                    'All' {
                        if(-not $MinProfile){
                            
                            write-host -foregroundcolor green "Adding full remote profile.." ; 
                            #$rgxJumpboxFiles = '^((tor|tsk|admin|(tsk|admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                            # sources from hard-coded git repo root path (fr a dev box)
                            #$profileFiles += get-childitem -path (join-path -path $SourcePath -childpath "*") -ea STOP |?{$_.name -match $rgxJumpboxFiles} | select -expand name ; # | select -expand fullname  ; 
                            # add the full stack for work related
                            $profilefiles += @("tor-incl-infrastrings_$($env:USERNAME).ps1") ;  
                            $profilefiles += @('tsk-prof.ps1','tsksid-incl-ServerCore.ps1','tsksid-incl-ServerApp.ps1') ; 
                            $profilefiles += @('admin-prof.ps1','adminsid-incl-ServerCore.ps1','adminsid-incl-ServerApp.ps1') ;
                            # 4:25 PM 9/8/2024: add common html foramtting/reporting support files:
                            $profilefiles += @('tor-incl-html-TOR-logo-graybar.ps1','tor-incl-html.ps1') ;
                            # is this being executed on a non-work machine?
                            if( !($env:computername -match $rgxProdServers) -AND !($env:computername -match $rgxLabServers) -AND !($env:computername -match $rgxWorkstation) -AND !($env:computername -match $rgxJumpBoxes) ) {
                                $profilefiles += @('home-incl-infrastrings.ps1') ; 
                            } ; 
                        } else { 
                            write-host -foregroundcolor green "-MinProfile: use reduced minimum remote profile.." ; 
                            # minprofile drop tsk-related items
                            #$rgxJumpboxAdminFiles = '^((tor|admin|(admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                            # sources from hard-coded git repo root path (fr a dev box)
                            $profileFiles += get-childitem -path (join-path -path $SourcePath -childpath "*") -ea STOP  |?{$_.name -match $rgxJumpboxAdminFiles} | select -expand name ;  # | select -expand fullname  ; 
                        } ;                           
                    }

                    default {
                        # explicit account specified
                        write-verbose "add:tor-incl-infrastrings_USERNAME.ps1"
                        $profilefiles += @("tor-incl-infrastrings_$($env:USERNAME).ps1") ;  
                        if( ($targetProfileName.split('\')[-1] -match $rgxAcctNameAnySID) -OR ($targetProfileName.split('\')[-1] -match $rgxAcctNameAnyUID)){
                            $profilefiles += @('tsk-prof.ps1','tsksid-incl-ServerCore.ps1','tsksid-incl-ServerApp.ps1') ; 
                        } else {
                            $profilefiles += @('admin-prof.ps1','adminsid-incl-ServerCore.ps1','adminsid-incl-ServerApp.ps1') ;
                        } ; 
                        # 2a. is it a known UID acct?
                        if($targetProfileName -match $rgxAcctNameAnyUID){
                            $profilefiles += @('tsk-incl-Desktop.ps1','tsk-incl-Toys.ps1','tsk-incl-Home.ps1') ; 
                        } ; 
                        # is this being executed on a non-work machine
                        if( !($env:computername -match $rgxProdServers) -AND !($env:computername -match $rgxLabServers) -AND !($env:computername -match $rgxWorkstation) -AND !($env:computername -match $rgxJumpBoxes) ) {
                            $profilefiles += @('home-incl-infrastrings.ps1') ; 
                        } ; 
                        # 4:25 PM 9/8/2024: add common html foramtting/reporting support files:
                        $profilefiles += @('tor-incl-html-TOR-logo-graybar.ps1','tor-incl-html.ps1') ;
                    } ; 
                } ; 

                # resolve them out into full unc paths
                # 3:05 PM 9/10/2024 flip all to the $prpfiles prop subset, don't need all the extra overhead, which means, always use an [array], not [system.io.fileinfo[] or [string[]]
                if($doHashes){
                    write-verbose "(calculating and including hashes on each file)" ; 
                    # can't use [system.io.fileinfo[]] if we add hash property
                    [array]$rProfilefiles = @() ; 
                    $prpFiles = 'Name','FullName','Extension','Length','LastWriteTime','LinkType','PSParentPath','PSPath','Directory',
                        @{name="Hash";expression={(Get-FileHash $_.FullName -Algorithm MD5).hash}}  ;
                } else { 
                    #[system.io.fileinfo[]]$rProfilefiles = @() ; 
                    # 3:05 PM 9/10/2024 flip all to the $prpfiles prop subset, don't need all the extra overhead, which means, always use an [array], not [system.io.fileinfo[] or [string[]]
                    [array]$rProfilefiles = @() ; 
                    $prpFiles = 'Name','FullName','Extension','Length','LastWriteTime','LinkType','PSParentPath','PSPath','Directory' ; 
                } ; 
                
                $sw = [Diagnostics.Stopwatch]::StartNew();
                <#
                $profilefiles | select -unique | foreach-object{
                    if($doHashes){
                        if($rfile = get-childitem -path (join-path -path $SourcePath -childpath $_) | 
                                Select-Object -Property *,@{name="Hash";expression={(Get-FileHash $_.FullName -Algorithm MD5).hash}}){                 
                            $rProfilefiles += @($rfile)
                        } else { 
                            throw "Unable to get-childitem -path $(join-path -path $SourcePath -childpath $_)" ; 
                        } ; 
                    }else{
                        if($rfile = get-childitem -path (join-path -path $SourcePath -childpath $_)){                 
                            $rProfilefiles += @($rfile)
                        } else { 
                            throw "Unable to get-childitem -path $(join-path -path $SourcePath -childpath $_)" ; 
                        } ; 
                    } ; 

                } ; 
                #>
                # use -include skip the loop: $profilefiles | select -unique ; seamlessly includes hashes if they're defined in $prpFiles, skips them if not
                $rProfilefiles = @(
                    get-childitem -path "$($SourcePath)\*" -Include ($profilefiles | select -unique ) | 
                        select-object -property $prpFiles
                ) ; 
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

                <#
                #[array]$profileFiles = "\\$SourceProfileMachine\c$\usr\work\exch\scripts\profile.ps1","\\$SourceProfileMachine\c$\usr\work\exch\scripts\Microsoft.PowerShellISE_profile.ps1" ; 
                # 2:22 PM 8/19/2024 these should source in primaries, not 2ndary out of band's (long out of date when checked)
                #[array]$profileFiles = @( [system.io.fileinfo[]](join-path -path $SourcePath -childpath "profile.ps1"),[system.io.fileinfo[]](join-path -path $SourcePath -childpath "Microsoft.PowerShellISE_profile.ps1")) ; 
                [system.io.fileinfo[]]$profileFiles = @( (join-path -path $SourcePath -childpath "profile.ps1"),(join-path -path $SourcePath -childpath "Microsoft.PowerShellISE_profile.ps1")) ; 
                
                # 3:27 PM 6/22/2020 update to cover admin files
                if(-not $MinProfile){
                    write-host -foregroundcolor green "Adding full remote profile.." ; 
                    #$rgxJumpboxFiles = '^((tor|tsk|admin|(tsk|admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                    # sources from hard-coded git repo root path (fr a dev box)
                    $profileFiles += get-childitem -path (join-path -path $SourcePath -childpath "*") -ea STOP |?{$_.name -match $rgxJumpboxFiles} # | select -expand fullname  ; 
                } else { 
                    write-host -foregroundcolor green "-MinProfile: use reduced minimum remote profile.." ; 
                    # minprofile drop tsk-related items
                    #$rgxJumpboxAdminFiles = '^((tor|admin|(admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                    # sources from hard-coded git repo root path (fr a dev box)
                    $profileFiles += get-childitem -path (join-path -path $SourcePath -childpath "*") -ea STOP  |?{$_.name -match $rgxJumpboxAdminFiles} # | select -expand fullname  ; 
                } ; 
                #>

                $smsg = "Resolved base Profile Files:" ; 
                $smsg += " $(($rProfilefiles |  measure | select -expand count |out-string).trim()) files" ; 
                $smsg += "`nTypes:`n$(($rProfilefiles | group extension | ft -a count,name |out-string).trim()) files" ; 
                write-host -foregroundcolor green $smsg ; 
                $smsg = "`$rProfilefiles:`n$(($rProfilefiles | sort LastWriteTime | ft -a $prpFTA|out-string).trim())" ; 
                write-verbose $smsg ;
                if($inclBackFill -AND -not $MinProfile){
                    write-verbose "-inclBackFill: resolve backfill dir uwes\verb-*.ps1 files into those with actual modules installed locally" ; 
                    # get-childitem c:\usr\work\exch\scripts\verb-*.ps1 |?{$_.name -notmatch '-pub\.ps1$'}
                    #$backfillfiles = get-childitem (join-path -path $backFillDir.fullname -childpath 'verb-*.ps1') -ea STOP |?{$_.name -notmatch '-pub\.ps1$'}  ; 
                    <#
                    $backfillfiles = get-childitem  (join-path -path ("\\$(join-path -path $SourceProfileMachine -ChildPath $backFillDir.fullname.replace(':','$'))") -ChildPath 'verb-*.ps1') |?{$_.name -notmatch '-pub\.ps1$'} ; 
                    write-verbose "gather installed verb-* modules" ; 
                    $gmols = gmo verb-* -list -ea STOP ;
                    write-verbose "test backfillfiles for matching installed modules" ; 
                    $hasmods = @() ; 
                    $backfillfiles.name.replace('.ps1','') |foreach-object{
                        $name = $_ ;
                        write-verbose "==$($name)" ;
                        if($gmols.name -contains $name){
                            write-verbose "Y:$($name)";
                            $hasmods+=@("$($name).ps1") ; 
                        }else {write-verbose "N:$($name)"}  
                    } ; 
                    foreach($bkfile in $backfillfiles){
                        if($hasmods -contains $bkfile.name){
                            write-verbose "Add:`$profileFiles += $($bkfile.fullname)" ; 
                            $profileFiles += $bkfile #.fullname ; 
                        } ; 
                    } ; 
                    #>
                    $backfillfiles = _get-BackFileFiles -SourceProfileMachine $SourceProfileMachine -backFillDir $backFillDir.fullname -Verbose:($PSBoundParameters['Verbose'] -eq $true)
                    $rProfilefiles = $(@($rProfilefiles;$backfillfiles)) ; 
                    $smsg = "Resolved base Profile Files + additional -inclBackFill:" ; 
                    $smsg += " $(($rProfilefiles |  measure | select -expand count |out-string).trim()) files" ; 
                    $smsg += "`nTypes:`n$(($rProfilefiles | group extension | ft -a count,name |out-string).trim()) files" ; 
                    write-host -foregroundcolor green $smsg ; 
                    $smsg = "`$rProfilefiles:`n$(($rProfilefiles | sort LastWriteTime | ft -a $prpFTA|out-string).trim())" ; 
                    write-verbose $smsg ;
                } ; 
               
            } CATCH {
                $ErrTrapd=$Error[0] ;
                $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Break ;
            } ; 
        
    } # PROC-E
    END {
        #$rProfilefiles.fullname | write-output ;
        #$prpFiles = 'Name','FullName','Extension','Length','LastWriteTime','Hash','LinkType','PSParentPath','PSPath','Directory' ; 
        #$rProfilefiles | select $prpFiles | write-output ;
        $rProfilefiles | write-output ;
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
} #*----------------^ END Function get-ProfileFilesTDO ^--------
