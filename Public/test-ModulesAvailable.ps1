# test-ModulesAvailable

#region TEST_MODS ; #*------v test-ModulesAvailable v------
#if(-not(gi function:test-ModulesAvailable -ea 0)){
    function test-ModulesAvailable {        
        <#
        .SYNOPSIS
        test-ModulesAvailable - Validate dependent modules & cmdlets are available
        .NOTES
        Version     : 0.0.
        Author      : Todd Kadrie
        Website     : http://www.toddomation.com
        Twitter     : @tostka / http://twitter.com/tostka
        CreatedDate : 2025-
        FileName    : test-ModulesAvailable.ps1
        License     : MIT License
        Copyright   : (c) 2025 Todd Kadrie
        Github      : https://github.com/tostka/verb-IO
        Tags        : Powershell
        AddedCredit : REFERENCE
        AddedWebsite: URL
        AddedTwitter: URL
        REVISIONS
        * 9:05 AM 6/2/2025 expanded CBH, copied over current call from psparamt
        * 5:10 PM 5/29/2025 init (replace scriptblock in psparamt); park it in verb-io: verb-mods isn't installed anywhere but devboxes, and verb-dev is also not on servers; verb-io is on everything.
        .DESCRIPTION
        test-ModulesAvailable - Validate dependent modules & cmdlets are available
        .PARAMETER ModuleSpecifications
        Array of semicolon-delimited module test specifications in format 'modulename;moduleurl;testcmdlet'[-ModuleSpecifications 'verb-logging;localRepo;write-log'
        .INPUTS
        None. Does not accepted piped input.
        .OUTPUTS
        System.Object array of boolean test results
        .EXAMPLE
        PS> #region TEST_MODS ; #*------v TEST_MODS v------
        PS> if($tDepModules){
        PS>     if( (test-ModulesAvailable -ModuleSpecifications $tDepModules) -contains $false ){
        PS>         $smsg += "MISSING DEPENDANT MODULE!(see errors above)" ;
        PS>         $smsg += "`n(may require provisioning internal function versions for this niche)" ;
        PS>         if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
        PS>         else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        PS>     } ; 
        PS> } ;
        PS> #endregion TEST_MODS ; #*------^ END TEST_MODS ^------        
        .LINK
        https://github.com/tostka/verb-IO        
        #>
        [CmdletBinding()]
        PARAM(
            [Parameter(Mandatory=$false,HelpMessage="Array of semicolon-delimited module test specifications in format 'modulename;moduleurl;testcmdlet'[-ModuleSpecifications 'verb-logging;localRepo;write-log'")]
            [string[]]$ModuleSpecifications      
        ) ; 
        BEGIN { $testPass = @() } ; 
        PROCESS{
            foreach($tmod in $ModuleSpecifications){
                $tmodName,$tmodURL,$tCmdlet = $tmod.split(';') ;
                if (-not(Get-Module $tmodName -ListAvailable)) {
                    $smsg = "This script requires a recent version of the $($tmodName) PowerShell module." ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn }
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                    switch -regex ($tmodurl) {
                        '^https://' {
                            $smsg += "`nDownload & install it from:`n$($tmodURL )"
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        }
                        '^localRepo$' {
                            if($localrepo = get-psrepository | ?{$_.SourceLocation -match '\\\\.*\\sc'} | select -first 1 ){
                                if($localcopy = find-module -Name $tmodName -Repository $localRepo.name ){
                                    $smsg += "`nA local copy is available and installable via:" ;
                                    $smsg += "`nInstall-Module  -Name $($tmodName) -Repository $($localRepo.name)" ;
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                }else {
                                    $smsg += "`nNO LOCAL COPY FOUND!:" ;
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                } ;
                            } else{
                                $smsg += "`nUnable to locate a locally registered repo:`nget-psrepository | ?{$_.SourceLocation -match '\\\\.*\\sc'}" ;
                                $smsg += "`n(may require provisioning internal function versions for this niche)" ;
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            };
                        }
                    } ;
                    $testPass += $false ;
                } else {
                    $testPass += $true ; 
                    write-verbose "$tModName confirmed available" ;
                    if(get-command -module $tModName -name $tCmdlet -ea 0){
                        write-verbose "$($tModName)\$($tCmdlet) confirmed available" ;
                    }else{
                        $smsg = "UNABLE TO GCM: $($tModName)\$($tCmdlet) !" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    }
                } ;
            } ;
        } ; 
        END{
            $testPass | write-output ; 
        } ; 
    } ; 
#}; 
#endregion TEST_MODS ; #*------^ END test-ModulesAvailable ^------