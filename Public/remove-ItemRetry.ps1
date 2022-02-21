function remove-ItemRetry {
    <#
    .SYNOPSIS
    remove-ItemRetry - Write output string to specified File
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : https://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 8:28 PM 11/17/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit :
    AddedWebsite:
    AddedTwitter:
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 2:23 PM 4/21/2021 added -GracefulFail, to permit process-newmodule to process past failed existing content removals, to get the mod built (better than hard fails)
    * 1:37 PM 12/28/2019 removed spurious mand $Text param
    * 10:59 AM 12/28/2019 INIT
    .DESCRIPTION
    remove-ItemRetry - Write output string to specified File
    .PARAMETER  Path
    Path to target file/directory [-Path path-to\file.ext]
    .PARAMETER  Recurse
    Recursive removal [-Recurse]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS> $bRet = remove-ItemRetry -Path "$($env:userprofile)\Documents\WindowsPowerShell\Modules\$($ModuleName)\*.*" -Recurse -showdebug:$($showdebug) -whatif:$($whatif) ;
    PS> if (!$bRet) {throw "FAILURE" ; EXIT ; } ;
    Recursively remove content specified, failures result in retry with -Force
    .LINK
    #>

    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to target file/directory [-Path path-to\file.ext]")]
        [ValidateNotNullOrEmpty()]$Path,
        [Parameter(HelpMessage = "Recursive removal [-Recurse]")]
        [switch] $Recurse,
        [Parameter(HelpMessage = "Graceful fail recovery Flag (-ea:'continue', rather than 'Stop' on inability to remove)[-GracefulFail]")]
        [switch] $GracefulFail,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;

    $pltRemoveItem=[ordered]@{
        Path=$Path ;
        Recurse=$($Recurse) ;
        ErrorAction="Stop" ;
        whatif=$($whatif);
    } ;
    if($GracefulFail){
        $pltRemoveItem.ErrorAction = 'Continue' ; 
        $smsg= "-GracefulFail specified, using EA:'Continue'" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 
    if(test-path -path $pltRemoveItem.Path){
        $smsg= "remove-item w`n$(($pltRemoveItem|out-string).trim())" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        $bRetry=$false ;
        TRY {
            remove-item @pltRemoveItem;
            $true | write-output ;
        } CATCH {
            $ErrorTrapped=$Error[0] ;
            $bRetry=$true ;
            write-warning  "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
        } ;
        if($bRetry){
            $pltRemoveItem.add('force',$true) ;
            $smsg= "RETRY with -FORCE: remove-item w`n$(($pltRemoveItem|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            TRY {
                remove-item @pltRemoveItem;
                $true | write-output ;
            } CATCH {
                $ErrorTrapped=$Error[0] ;
                write-warning  "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
                $bRetry=$false ;
                #Exit ;
                $false | write-output ;
            } ;
        } ;
    } else {
        # no match, ret true
        $smsg= "No existing Match:test-path -path $($pltRemoveItem.Path)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        $true | write-output ;
    } ; ;
}
