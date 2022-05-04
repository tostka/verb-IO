#*------v Function Remove-AuthenticodeSignature v------
function Remove-AuthenticodeSignature {
    <#
    .SYNOPSIS
    Remove-AuthenticodeSignature - removes an Authenticode signature from any file that supports Subject Interface Package (SIP).
    .NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : Remove-AuthenticodeSignature.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Certificate,Developoment
    AddedCredit : Adrian Rodriguez
    AddedWebsite:	https://psrdrgz.github.io/RemoveAuthenticodeSignature/
    AddedTwitter:	@psrdgz
    REVISIONS   :
    * 4:54 PM 5/3/2022 init vers
    .PARAMETER Path
    file name(s) to appl authenticode signature into.
    .INPUTS
    system.io.fileinfo[]
    .DESCRIPTION
    Remove-AuthenticodeSignature - removes an Authenticode signature from any file that supports Subject Interface Package (SIP).
    .EXAMPLE
      get-childitem *.ps1,*.psm1,*.psd1,*.psd1,*.ps1xml | Get-AuthenticodeSignature | ? {($_.status -eq 'Valid')} | remove-AuthenticodeSignature
      Remove sigs on all ps files with valid sigs (for ps, it's: ps1, psm1, psd1, dll, exe, and ps1xml files)
    .EXAMPLE
    Remove-AuthenticodeSignature C:\usr\work\lync\scripts\enable-luser.ps1
    Parameter removal
    .EXAMPLE
    get-childitem c:\usr\local\bin\*.ps1 | Remove-AuthenticodeSignature
    Pipeline example
    #>
    #Requires -Modules verb-Text, verb-logging
    [CmdletBinding()]
    ###[Alias('Alias','Alias2')]
    Param(
        [Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True, HelpMessage = 'Files to have signature removed [-file c:\pathto\script.ps1]')]
        [Alias('PsPath','File')]
        [system.io.fileinfo[]]$Path,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN {
        $rgxSignFiles='\.(CAT|MSI|JAR,OCX|PS1|PSM1|PSD1|PS1XML|PSC1|MSP|CMD|BAT|VBS)$' ;
        $rgxSigStart = '^#\sSIG\s#\sBegin\ssignature\sblock' ;
        $rgxSigEnd = '^#\sSIG\s#\sEnd\ssignature\sblock' ;
        $verbose = ($VerbosePreference -eq "Continue") ;
    } ;
    PROCESS {
        $Path | ForEach-Object -Process {
            $Item = $_ ; 
			If($Item.Extension -match $rgxSignFiles){
                # sls for sig marker, (plan to dump large numbers at it from modules, to strip sigs, when rebuilding into monolithic .psm1s)
                if(select-string -Path  $Item -Pattern $rgxSigStart){
                    $smsg = "(Remove-Sig:$($Item.FullName))" ;
                    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;

                    Try{
                        $rawSourceLines = get-content -path $Item.FullName -ErrorAction Stop ;
                        $SrcLineTtl = ($rawSourceLines | Measure-Object).count ;
                        $sigOpenLn = ($rawSourceLines | select-string -Pattern $rgxSigStart).linenumber ;
                        $sigCloseLn = ($rawSourceLines | select-string -Pattern $rgxSigEnd).linenumber ;
                        if(!$sigOpenLn){$sigCloseLn = 0 } ;
                        $updatedContent = @() ; $DropContent=@() ;
                        $updatedContent = $rawSourceLines[0..($sigOpenLn-2)] |out-string ;
                        #$DropContent = $rawsourcelines[$sigOpenLn..$sigCloseLn] |out-string ;

                        if(get-command set-ContentFixEncoding){
                            $pltSCFE=[ordered]@{  Path =$Item.FullName  ;  Value = $updatedContent ;  verbose =$($verbose) ;  errorAction = 'STOP' ;  whatif=$($whatif) } ; 
                            $smsg = "Set-ContentFixEncoding  w`n$(($pltSCFE|out-string).trim())" ; 
                            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            Set-ContentFixEncoding @pltSCFE ; 
                        } else { 
                            # encoding mgmt/coerce
                            $enc=$null ; $enc=get-FileEncoding -path $Item.FullName ;
                            if($enc -eq 'ASCII') {
                                $enc = 'UTF8' ;
                                $smsg = "(ASCI encoding detected, converting to UTF8)" ;
                                if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ; # force damaged/ascii to UTF8
                            $pltSetCon=[ordered]@{ Path=$Item.FullName ; whatif=$($whatif) ;  } ;
                            if($enc){$pltSetCon.add('encoding',$enc) } ;
                            Set-Content @pltSetCon -Value $updatedContent ;
                        } ; 
                    }Catch{
                        #Write-Error -Message $_.Exception.Message ;
                        $ErrTrapd=$Error[0] ;
                        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #-=-record a STATUSWARN=-=-=-=-=-=-=
                        $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
                        if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
                        if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
                        Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
                    } ;
                } else { 
                    $smsg = "($($item):has no existing Authenticode signature)" ; 
                    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                };
            } ;
        } # loop-E
    } # Proc-E
} ;
#*------^ END Function Remove-AuthenticodeSignature ^------
