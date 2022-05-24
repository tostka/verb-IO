#*------v remove-UnneededFileVariants.ps1 v------
function remove-UnneededFileVariants {
    <#
    .SYNOPSIS
    remove-UnneededFileVariants.ps1 - Collect a set of files at -path & -include (filename), then post-filter matching -pattern, and keep the most recent -Keep generations of the files, as sorted and filtered on CreationTime|LastWriteTime (as specified by FilterOn specification)
    .NOTES
    Version     : 1.0.
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 1:43 PM 11/16/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 12:52 PM 5/23/2022 flip rm catch to Continue, and add ea continue to the splat, Break aborts what is really only a maint task, not a critical path step ; added variant catch for perms/read-only error: catch[System.IO.IOException]{
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 7:28 PM 11/6/2021 added missing $population = $population reassign post filtering (prevented filter reduction form occuring at all)
    * 9:58 AM 9/21/2021 rem'd retry loop
    * 12:34 PM 9/20/2021  init
    .DESCRIPTION
    remove-UnneededFileVariants.ps1 - Collect a set of files at -path & -include (filename), then post-filter matching -pattern, and keep the most recent -Keep generations of the files, as sorted and filtered on CreationTime|LastWriteTime (as specified by FilterOn specification)
    .PARAMETER  Path
    Path to script
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS> $whatif=$true ;
    PS> $pltRGens =[ordered]@{
            Path = 'C:\sc\verb-auth\' ;
            Include ='process-NewModule-verb-auth-LOG-BATCH-EXEC-*-log.txt' ;
            Pattern = 'verb-\w*\.ps(m|d)1_\d{8}-\d{3,4}(A|P)M' ;
            FilterOn = 'CreationTime' ;
            Keep = 2 ;
            KeepToday = $true ;
            verbose=$true ;
            whatif=$($whatif) ;
        } ; 
    PS> write-host -foregroundcolor green "remove-UnneededFileVariants w`n$(($pltRGens|out-string).trim())" ; 
    PS> remove-UnneededFileVariants @pltRGens ;
    Splatted call example: remove all variant -include-named files in -Path, post-filtered matching -Pattern, retaining items with CreationTime after midnight today, and then retain most recent 2 files (net of prior filtering), as sorted on CreationTime.
    .LINK
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Path to directory[-Path path-to\]")]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]$Path,
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "File Name include wildcard filter to match files [-Include  'process-NewModule-verb-auth-LOG-BATCH-EXEC-*-log.txt']")]
        [string]$include,
        [Parameter(Position = 1, HelpMessage = "File Name Regex to post-filter match files [-Pattern  'verb-\w*\.ps(m|d)1_\d{8}-\d{3,4}(A|P)M']")]
        [string]$Pattern,
        [Parameter(Position = 1, HelpMessage = "Specifies whether sorts & filtering target CreationTime or LastWriteTime of target files (defaults to CreationTime)[-FilterOn  'CreationTime']")]
        [ValidateSet('CreationTime','LastWriteTime')]
        [string]$FilterOn='CreationTime',
        [Parameter(Position = 2, Mandatory = $True, HelpMessage = "Generations to Keep[-Keep 2]")]
        [int] $Keep,
        [Parameter(HelpMessage = "Datetime that enforce retention of files with CreationTime or LastWriteTime (as specified by FilterOn), after specified datetime [-KeepAfter [datetime]::today]")]
        [datetime] $KeepAfter,
        [Parameter(HelpMessage = "Switch that enforce retention of files with CreationTime or LastWriteTime (as specified by FilterOn), after midnight today [-KeepToday]")]
        [switch] $KeepToday,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    $verbose = ($VerbosePreference -eq "Continue") ; 
    $pltGci = [ordered]@{
        path = "$(join-path -path $Path -childpath '*')" ; # include relies on trailing * on path (or -Recurse, which returns subdirs)
        #Recurse = $true ;
        include = $include ; 
        ErrorAction="Stop" ;
    } ;
    $smsg = "gci w`n$(($pltGci|out-string).trim())" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    $Exit = 0 ;
    if($KeepToday){
        $cuttime = [datetime]::today ; # midnight today
    } elseif($KeepAfter){
        $cuttime = (get-date $KeepAfter) # specific time specified - if a date is spec'd it comes through as 12:00 AM that day 
    } ; 
    if($cuttime){
        write-verbose "`$cuttime:$($cuttime)" ; 
    } ; 
    TRY {
        $initialpop = $population = get-childitem @pltGci ; # our pool of files to purge (cached original & working set)
        if($pattern){
            $smsg = "post-filtering on pattern:$($pattern)" ;
            $smsg += "`n($(($population|measure).count) in set *before* filtering)"
            $population = $population | ?{$_.name -match $pattern} 
            $smsg += "`n($(($population|measure).count) in set *after* filtering)"
            write-verbose $smsg ;
        } ; 
        if($cuttime){
            $smsg = "filtering on files prior to `$cuttime:$((get-date $cuttime).tostring('MM/dd/yyyy HH:mm:ss tt')), on $($FilterOn) property" ;
            $smsg += "`n($(($population|measure).count) in set *before* filtering)"

            switch($FilterOn){
                'CreationTime'{
                    $population = $population | ?{$_.CreationTime -lt $cuttime } | 
                        sort-object CreationTime -Descending  ;
                }
                'LastWriteTime' {
                    $population = $population | ?{$_.LastWriteTime -lt $cuttime  } | 
                        sort-object LastWriteTime -Descending  ;
                } ; 
            } ;
            $smsg += "`n($(($population|measure).count) in set *after* filtering)"
            write-verbose $smsg ;
            
        } ; 
        $smsg = "attempting to retain remaining $($Keep) generations net of prior filtering" ;
        $smsg += "`n($(($population|measure).count) in set *before* filtering)"
        $population = $population | select-object -skip $Keep ; 
        $smsg += "`n($(($population|measure).count) in set *after* filtering)"
        if(($population|measure).count -lt $Keep){
            $smsg += "`n(Note:net population is *below* target -Keep:$($Keep) spec - insufficient older files available)" ; 
        } ; 
        write-verbose $smsg ;
        
        
        # $initialpop = $population
        $smsg = "Reducing matched population from $(($initialpop|measure).count) to $(($population|measure).count) files via:" ; 
        if($pattern){
            $smsg += "`npost-filtered files with regex pattern:$($pattern)" ; 
        } ;
        if($cuttime){
            $smsg += "`nfiltered files on $($filteron) prior to $((get-date $cuttime).tostring('MM/dd/yyyy HH:mm:ss tt'))" ; 
        } ; 
        
        
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

      
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #-=-record a STATUSWARN=-=-=-=-=-=-=
        $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
        if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
        if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
        #-=-=-=-=-=-=-=-=
        $smsg = "FULL ERROR TRAPPED (EXPLICIT CATCH BLOCK WOULD LOOK LIKE): } catch[$($ErrTrapd.Exception.GetType().FullName)]{" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level ERROR } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
    } ; 
    

    if($population){
    
        # add ea cont, to permit it to survive read-only files wo errors.
        $pltRItm = [ordered]@{
            path=$population.fullname ; 
            #ErrorAction =  'Continue' ; 
            ErrorAction =  'STOP' ; 
            whatif=$($whatif) ;
        } ; 
        
        $smsg = "Remove-Item w `n$(($pltRItm|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY {
            Remove-Item @pltRItm ;
            $true | write-output ; 
        } CATCH [System.IO.IOException]{
            $ErrTrapd=$Error[0] ;
            $smsg = "File permissions/read-only issue (SKIPPING:$pltRItm.path)..."
            $smsg += "`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #-=-record a STATUSWARN=-=-=-=-=-=-=
            $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
            if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
            if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
            #-=-=-=-=-=-=-=-=
            $false | write-output ; 

            Continue  ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #-=-record a STATUSWARN=-=-=-=-=-=-=
            $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
            if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
            if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
            #-=-=-=-=-=-=-=-=
            $smsg = "FULL ERROR TRAPPED (EXPLICIT CATCH BLOCK WOULD LOOK LIKE): } catch[$($ErrTrapd.Exception.GetType().FullName)]{" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level ERROR } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

            $false | write-output ; 
            # flip it to Continue, Break aborts what is really only a maint task, not a critical path step
            Continue #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ; 
    } else { 
        $smsg = "There are *no* files to be removed, as per the specified inputs. (`$population:$(($population|measure).count))" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 

    $Exit = $Retries ;

}

#*------^ remove-UnneededFileVariants.ps1 ^------