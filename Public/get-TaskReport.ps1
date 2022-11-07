#*------v Function get-TaskReport v------
function get-TaskReport {
    <#
    .SYNOPSIS
    get-TaskReport.ps1 - Collect and report on specified Scheduled Tasks
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 20201014-0826AM
    FileName    : get-TaskReport.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 10:49 AM 1/8/2021 added extended get-scheduledtask examples to CBH ; repl wh's with a herestring at top ; fixed typo in initial !$Taskname output (extraneous `) 
    * 8:08 AM 12/2/2020 added function alias: get-ScheduledTaskReport (couldn't remember this vers didn't use 'sched', had to hunt it up in the module, by name)
    * 7:24 AM 11/24/2020 expanded no -Task echo to include get-scheduledtasks syntax, added it to CBH example
    * 1:59 PM 10/14/2020 switched Exit to Break ; init
    .DESCRIPTION
    get-TaskReport.ps1 - Collect and report on specified Scheduled Tasks
    .PARAMETER  TaskName
    Array of Tasknames to be reported upon[-TaskName get-taskreport -TaskName 'monitor-ADAccountLock','choco-cleaner']
    .PARAMETER TaskName
    Array of Tasknames to be reported upon[-TaskName get-taskreport -TaskName 'monitor-ADAccountLock','choco-cleaner']
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .EXAMPLE
    get-TaskReport -TaskName 'monitor-ADAccountLock'
    Report on a single Scheduled Task
    .EXAMPLE
    # review task names
    get-scheduledtask | fl taskname ; 
    # report on an array of tasks
    get-taskreport -TaskName 'monitor-ADAccountLock',"choco-cleaner","maintain-ExoUsrMbxFreeBusyDetails.ps1"
    .EXAMPLE
    PS> $task = get-scheduledtask choco-cleaner
    # Return Triggers
    PS> $task.triggers ;
    PS> $task.actions ; 
    
        Id               :
        Arguments        : /c powershell -NoProfile -ExecutionPolicy Bypass -Command
                           %ChocolateyToolsLocation%\BCURRAN3\choco-cleaner.ps1
        Execute          : cmd
        WorkingDirectory :
        PSComputerName   :
    
        # Return Actions 
        Id               :
        Arguments        : /c powershell -NoProfile -ExecutionPolicy Bypass -Command
                       %ChocolateyToolsLocation%\BCURRAN3\choco-cleaner.ps1
        Execute          : cmd
        WorkingDirectory :
        PSComputerName   :
    Examples for use of ScheduledTask module get-ScheduledTasks cmdlet to work with Tasks as objects (Psv3+)
    .EXAMPLE
    PS> get-scheduledtask|?{$_.taskpath -eq '\'} | 
        %{"`nTASK:`t$($_.taskname)`nEXEC:`t$($_.actions.execute)`nARGS: `t$($_.actions.Arguments)`n" } ; 
    
        TASK:   choco-cleaner
        EXEC:   cmd
        ARGS:   /c powershell -NoProfile -ExecutionPolicy Bypass -Command %ChocolateyToolsLocation%\BCURRAN3\choco-cleaner.ps1
        
    Return Summary Name, Execute and Arguments of each root Task:
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('get-ScheduledTaskReport')]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Array of Tasknames to be reported upon[-TaskName get-taskreport -TaskName 'monitor-ADAccountLock','choco-cleaner']")]
        $TaskName,
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Switch to return a summary data object[-Return]")]
        $Return,
        [switch] $showDebug
    ) ;
    BEGIN {
        If(!$TaskName){
            $smsg =@"
No -TaskName specified
available tasks on $($env:computername) include the following:
syntax:
# root tasks
get-scheduledtask|?{`$_.taskpath -eq '\'} | ft -a  ; 
# all tasks:
get-scheduledtask | fl taskname ; 

$((get-scheduledtask|?{$_.taskpath -eq '\'} | ft -auto |out-string).trim()) ; 

"@ ; 
            write-warning $smsg ; 
            Break ; 
        } ; 
    } ;# PROC-E
    PROCESS {
        foreach($TName in $TaskName){
            $error.clear() ;
            TRY {
                $task = get-scheduledtask -TaskName $TName ;
            } CATCH {
                Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
                STOP ;
            } ; 
            if(!$Report){
                $sBnr="#*======v $($task.taskname): v======" ; 
                write-host -foregroundcolor yellow "$($sBnr)" ;
                write-host -foregroundcolor green "==get-TaskReport $($TName):`n$(($task | fl * |out-string).trim())" ; 
                $sBnrS="`n#*------v Triggers : v------" ; 
                write-host -foregroundcolor white "$($sBnrS)" ;
                write-host -foregroundcolor green "n$(($task.triggers|out-string).trim())" ; 
                write-host -foregroundcolor white "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
                $sBnrS="`n#*------v Actions : v------" ; 
                write-host -foregroundcolor white "$($sBnrS)" ;
                write-host -foregroundcolor green "`n$(($task.actions|out-string).trim())" ; 
                write-host -foregroundcolor white "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
                write-host -foregroundcolor green "----Principal:`n$((($task | Select-Object TaskName,Principal,Actions -ExpandProperty "Actions" | Select-Object TaskName,Principal,Execute -ExpandProperty Principal).userid|out-string).trim())" ; 
                $sBnrS="`n#*------v Run History : v------" ; 
                write-host -foregroundcolor white "$($sBnrS)" ;
                write-host -foregroundcolor green "`n$(($task | Get-ScheduledTaskInfo | fl Last*,Next*,Num* |out-string).trim())" ; 
                write-host -foregroundcolor white "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
                write-host -foregroundcolor yellow "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
            } else { 
                if($host.version.major -ge 3){
                    $Hash=[ordered]@{Dummy = $null} ;
                } else {
                    # psv2 Ordered obj (can't use with new-object -properites)
                    $Hash = New-Object Collections.Specialized.OrderedDictionary ; 
                } ;
                # then immediately remove the dummy value (blank & null variants too):
                If($Hash.Contains("Dummy")){$Hash.remove("Dummy")} ; 
                # Populate the $hash with fields, post creation 
                $Hash.Add("NewField",$($NewValue)) ; 
                $Hash.Add("NewField",$($null)) ; 
                $Hash.Add("NewField","") ; 
            } ;
        } ; 
    } ;  # PROC-E
} ; 
#*------^ END Function  ^------
