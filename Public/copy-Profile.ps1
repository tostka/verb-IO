#*----------------v Function copy-Profile v------
function copy-Profile {
    <#
    .SYNOPSIS
    copy-Profile() - Copies $SourceProfileMachine WindowsPowershell profile dir to the specified machine(s)
    .NOTES
    Author: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 9:47 AM 9/24/2020 updated CBH, copied to verb-IO mod; added -MinProfile to drive admin/svcacct copying 
    * 10:41 AM 3/26/2020 rewrote, added verbose support, condensed 
    8:07 AM 6/12/2015 - functionalize copy code from the EMS block
    .DESCRIPTION
    copy-Profile() - Copies $SourceProfileMachine WindowsPowershell profile dir to the specified machine(s)
    .PARAMETER  ComputerName
    Name or IP address of the target computer
    .PARAMETER SourceProfileMachine
    Source Name or IP address of the source Profile computer
    .PARAMETER TargetProfile
    Target Account for Profile copy process [domain\logon]
    .PARAMETER showProgress
    Show Progress bar reflecting progress toward completion
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
    PS>     copy-Profile -ComputerName $Exs -SourceProfileMachine $SourceProfileMachine -TargetProfile $TargetProfileAcct -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    PS> } else {write-verbose -verbose:$true "$((get-date).ToString('HH:mm:ss')):No Mbx or HT servers found)"} ;
    Copy targetprofile to all Exchange servers (leveraging ExchMgmtShell cmd)
    .EXAMPLE
    PS> if($AdminJumpBox ){
    PS>     write-verbose -verbose:$true "$((get-date).ToString('HH:mm:ss')):AdminJumpBox..."
    PS>     copy-Profile -ComputerName $AdminJumpBox -SourceProfileMachine $SourceProfileMachine -TargetProfile $TargetProfileAcct -JumpBox -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    PS> } ; 
    Perform a full 'admin' profile copy into target jumpbox (specifies -JumpBox param)
    .EXAMPLE
    PS> copy-Profile -ComputerName $JumpBox -SourceProfileMachine $SourceProfileMachine -TargetProfile $SvcAcctProf -JumpBox -MinProfile -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    # Copy the minimum profile to specified Service Account Profile on jumpboxes
    #>
    [CmdletBinding()]
    PARAM (
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
        Mandatory=$True,HelpMessage="Specify Target Computer for Profile Copy[-ComputerName SERVER]")]
        [Alias('__ServerName','Server','Computer','Name','IPAddress','CN')]   
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory=$True,HelpMessage="Source Profile Machine [-SourceProfileMachine CLIENT]")]
        [ValidateNotNullOrEmpty()]
        [string]$SourceProfileMachine,    
        [parameter(Mandatory=$True,HelpMessage="Target Account for Profile copy process [-TargetProfile DOMAIN\LOGON]")]
        [ValidatePattern('^\w*\\[A-Za-z0-9-]*$')]
        [string]$TargetProfile,      
        [parameter(HelpMessage="Credential object for use in accessing the computers")]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(HelpMessage='-JumpBox  Flag [-JumpBox]')]
        [switch] $JumpBox ,
        [Parameter(HelpMessage='-MinProfile  Flag (copies least admin-related files)[-JumpBox]')]
        [switch] $MinProfile ,
        [Parameter(HelpMessage='Debugging Flag [-showDebug]')]
        [switch] $showDebug,
        [Parameter(HelpMessage='Whatif Flag  [-whatif]')]
        [switch] $whatIf
    ) ;  # PARAM-E
    BEGIN {
        $verbose = ($VerbosePreference -eq 'Continue') ; 
        If ($whatIf){write-host "`$whatIf is $true" ; $bWhatif=$true}; 
        $AdminLogon=$TargetProfile.split("\")[1] ;
        #"SAMACCOUNTNAME" ; 
        $AdminDomain=$TargetProfile.split("\")[0] ;
        #"DOMAIN" ; 
        $TargetProfileAcct=$TargetProfile ;
        #"$($AdminDomain)\$($AdminLogon)";
        $iProcd=0; 
    }  # BEG-E
    PROCESS {
        foreach ($Computer in $Computername) {
            $continue = $true
            $error.clear() ;
            TRY { 
                $ErrorActionPreference = "Stop" ;

                write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):Processing: $($Computer)..." ; 

                $pltProDir=[ordered]@{
                    path="\\$Computer\c$\Users\$AdminLogon\Documents\WindowsPowerShell" ;itemtype="directory" ;Force=$true ;whatif=$($whatif) ; 
                } ; 
                if(!(test-path "\\$Computer\c$\Users\$AdminLogon\Documents\WindowsPowerShell")) {
                    $smsg = "new-item w`n$(($pltProDir|out-string).trim())" ; 
                    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    new-item @pltProDir ; 
                };

                [array]$profileFiles = "\\$SourceProfileMachine\c$\usr\work\exch\scripts\profile.ps1","\\$SourceProfileMachine\c$\usr\work\exch\scripts\Microsoft.PowerShellISE_profile.ps1" ; 
                
                if($JumpBox -OR ($env:COMPUTERNAME -match $rgxAdminJumpBoxes)){
                    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):-JumpBox specified: Adding full remote profile.." ; 
                    # 3:27 PM 6/22/2020 update to cover admin files
                    if(!$MinProfile){
                        $rgxJumpboxFiles = '^((tor|tsk|admin|(tsk|admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                        # sources from hard-coded git repo root path (fr a dev box)
                        $profileFiles += gci -path "\\$SourceProfileMachine\c$\sc\powershell\PSProfileUID\*" |?{$_.name -match $rgxJumpboxFiles} | select -expand fullname  ; 
                    } else { 
                        # minprofile drop tsk-related items
                        $rgxJumpboxAdminFiles = '^((tor|admin|(admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                        # sources from hard-coded git repo root path (fr a dev box)
                        $profileFiles += gci -path "\\$SourceProfileMachine\c$\sc\powershell\PSProfileUID\*" |?{$_.name -match $rgxJumpboxAdminFiles} | select -expand fullname  ; 

                    } ; 
                } ; 
                $pltCopy = [ordered]@{
                    path=$profileFiles ; 
                    destination=$pltProDir.path ;
                    force=$true ;
                    whatif=$($whatif) ;
                } ; 
                $smsg = "copy-item w`n$(($pltCopy|out-string).trim())`n`$pltCopy.path:`n$(($pltCopy.path|out-string).trim())" ; 
                if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                copy-item @pltCopy ; 
                $iProcd++
            } CATCH { 
              Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ; 
              Exit #Opts: STOP(debug)|EXIT(close)|Continue(move on in loop cycle) 
            } ; 
        } # loop-E
    } # PROC-E
    END {
        $smsg = "PROCESSED $($iProcd) machines" ; 
        if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        $iProcd | write-output ; 
    } ; 
} #*----------------^ END Function copy-Profile ^--------