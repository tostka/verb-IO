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
    * 7:24 AM 11/24/2020 expanded no -Task echo to include get-scheduledtasks syntax, added it to CBH example
    * 1:59 PM 10/14/2020 switched Exit to Break ; init
    .DESCRIPTION
    get-TaskReport.ps1 - Collect and report on specified Scheduled Tasks
    .PARAMETER  TaskName
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
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Array of Tasknames to be reported upon[-TaskName get-taskreport -TaskName 'monitor-ADAccountLock','choco-cleaner']")]
        $TaskName,
        [switch] $showDebug
    ) ;
    BEGIN {
        If(!$TaskName){
            $smsg = "No -TaskName specified`navailable tasks on $($env:computername) include the following:"
            $smsg += "`nsyntax:`n# root tasks`nget-scheduledtask|?{$_.taskpath -eq '\'} | ft -a "
            $smsg += "`n# all tasks:`nget-scheduledtask | fl taskname" ; 
            $smsg += "`n$((get-scheduledtask|?{$_.taskpath -eq '\'} | ft -auto |out-string).trim())" ; 
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
        } ; 
    } ;  # PROC-E
} ; 
#*------^ END Function  ^------