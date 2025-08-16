# Invoke-ProcessTDO.ps1

#region INVOKE_PROCESSTDO ; #*------v Invoke-ProcessTDO v------
Function Invoke-ProcessTDO {
    <#
    .SYNOPSIS
    Invoke-ProcessTDO - Start-Process wrapper that runs 'MSU|MSI|MSP|EXE' etc files with command line parameters, and returns Exitcode (and captured stdOut/stdErr, with -Passthru parameter)
    .NOTES
    Version     : 0.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2025-08-14
    FileName    : Invoke-ProcessTDO
    License     : MIT License
    Copyright   : (c) 2025 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,FileSystem,Backup,Development,Build,Staging
    AddedCredit :  Michel de Rooij / michel@eightwone.com
    AddedWebsite: eightwone.com
    AddedTwitter: URL
    REVISIONS
    * 9:24 AM 8/15/2025 updated wlt to support wlty's; added to xopBuildLibrary.ps1, set xopBuildLibarary\Invoke-Process821() to defer to this if pre-loaded.
    * 3:37 PM 8/14/2025 ren Invoke-Process821 -> Invoke-ProcessTDO (substantial upgraded code), aliased orig name ; 
        added updated CBH demo; add: -silent param;  
        add: CBH; -PassThru param (make it return output of underlying cmd), which returns a SytstemObject summary with ExitCode, StdOut, StdErr & process Handle.
    * MdR's posted Version 4.13, July 17th, 2025 of install-Exchange15.ps1
    .DESCRIPTION
    Invoke-ProcessTDO - Start-Process wrapper that runs 'MSU|MSI|MSP|EXE' etc files with command line parameters, and returns Exitcode (and captured stdOut/stdErr, with -Passthru parameter)
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    System.Boolean
    [| get-member the output to see what .NET obj TypeName is returned, to use here]
    .EXAMPLE
    PS> Invoke-ProcessTDO -whatif -verbose
    EXSAMPLEOUTPUT
    Run with whatif & verbose
    .EXAMPLE
    PS> Invoke-ProcessTDO
    EXSAMPLEOUTPUT
    EXDESCRIPTION
    .LINK
    https://github.com/tostka/verb-dev
    .LINK
    https://github.com/tostka/powershellbb/
    .PARAMETER FilePath
    Parent directory path containing target .msu|.msi|.msp|.exe etc [-FilePath c:\pathto\]
    .PARAMETER FileName
    Filename of target .msu|.msi|.msp|.exe etc [-FileName 'some.exe']
    .PARAMETER ArgumentList
    Array of arguments to used with target file [-ArgumentList @('/mode:RecoverServer', '/DoNotStartTransport', '/InstallWindowsComponents')]
    .PARAMETER PassThru
    Switch parameter to capture and return output & StdErr (rather than ErrorCode returned)
    .PARAMETER Silent
    Switch parameter to suppress all output but StdErr        
    .EXAMPLE
    PS> $Params= '/mode:RecoverServer', $State['IAcceptSwitch'], '/DoNotStartTransport', '/InstallWindowsComponents'
    PS> $Params+= "/TargetDir:`"$($State['TargetPath'])`""
    PS> $res= Invoke-ProcessTDO $State['SourcePath'] 'setup.exe' $Params
    PS> If( $res -ne 0 -or -not( Get-ItemProperty -Path $PresenceKey -Name InstallDate -ErrorAction SilentlyContinue)){
    PS>     Write-MyError 'Exchange Setup exited with non-zero value or Install info missing from registry: Please consult the Exchange setup log, i.e. C:\ExchangeSetupLogs\ExchangeSetup.log'
    PS>     Exit $ERR_PROBLEMEXCHANGESETUP
    PS> }
    Demo running an Exchange Setup.exe pass.
    .EXAMPLE
    PS> $RunFrom= Split-Path -Path $OnlineURL -Parent
    PS> Write-MyVerbose "Will run $FileName straight from $RunFrom"
    PS> Write-MyOutput "Installing $Package from $RunFrom"
    PS> $rval= Invoke-ProcessTDO $RunFrom $FileName $Arguments
    Demos executing a URL to run a package from download
    .EXAMPLE
    PS> $xCopyEXE = (get-command xcopy.exe -EA STOP).source ; 
    PS> write-verbose "Params below specify: /D: copy newer files only; /Y: suppress overrwrite prompt; /F echoes full source & dest path while copying
    PS> $xCopyParams= @('/D','/Y','/F') ; 
    PS> $sourceFile = (Join-Path $sourceDir $fileName )
    PS> $destFile = (Join-Path $destDir $fileName ) ;
    PS> $Params = @() ; 
    PS> $Params = @($sQot + $sourceFile + $sQot) ;
    PS> write-verbose "xcopy foible: prompts 'directory or file?', unless destination file spec ends in '*' char" ;      
    PS> $Params += @($sQot + "$($destFile)*" + $sQot) ; 
    PS> $Params = $(@($Params);@($xCopyParams)) ; 
    PS> if($whatif){$Params += @('/L')} ; 
    PS> $res= Invoke-ProcessTDO -FilePath (split-path $xCopyEXE) -FileName (split-path $xCopyEXE -Leaf) -ArgumentList $Params -PassThru; 
    PS> if($res.stdOut -match "0\sFile\(s\)"){
    PS>     $smsg = "(ExitCode:$($res.exitCode): no-updated copy:$($sourceFile):stdOut: $($res.stdOut))" ;
    PS>     write-verbose $smsg ;
    PS> } else {
    PS>     $smsg = "ExitCode:$($res.exitCode): UPDATED COPY: $($sourceFile) => $($destFile):stdOut: $($res.stdOut)" ;
    PS>     write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" 
    PS> } ; 
    PS> if($res.StdErr){
    PS>     $smsg = "A StandardError output was returned:`nSTDERR:$($res.StdErr)" ;
    PS>     write-WARNING $smsg ; 
    PS> } ; 
    Demo using this to execute an xcopy copy process and return results 
    #>
    [CmdletBinding()]
    [Alias('Invoke-Process821')]
    PARAM(
            [Parameter(HelpMessage="Parent directory path containing target .msu|.msi|.msp|.exe etc [-FilePath c:\pathto\]")]
                $FilePath,
            [Parameter(HelpMessage="Filename of target .msu|.msi|.msp|.exe etc [-FileName 'some.exe']")]
                $FileName,
            [Parameter(HelpMessage="Array of arguments to used with target file [-ArgumentList @('/mode:RecoverServer', '/DoNotStartTransport', '/InstallWindowsComponents')]")]
                $ArgumentList,
            [Parameter(HelpMessage="Switch parameter to capture and return output & StdErr (rather than ErrorCode returned)")]
                [switch]$PassThru,
            [Parameter(HelpMessage="Switch parameter to suppress all output but StdErr")]
                [switch]$Silent
    )
    $rval= 0
    $FullName= Join-Path $FilePath $FileName
    If( Test-Path $FullName) {
        Switch( ([io.fileinfo]$Filename).extension.ToUpper()) {
            '.MSU' {
                $ArgumentList+= @( $FullName)
                $ArgumentList+= @( '/f')
                $Cmd= "$env:SystemRoot\System32\WUSA.EXE"
            }
            '.MSI' {
                $ArgumentList+= @( '/i')
                $ArgumentList+= @( $FullName)
                $Cmd= "MSIEXEC.EXE"
            }
            '.MSP' {
                $ArgumentList+= @( '/update')
                $ArgumentList+= @( $FullName)
                $Cmd= 'MSIEXEC.EXE'
            }
            default {
                $Cmd= $FullName
            }
        }
        $smsg = "Executing $Cmd $($ArgumentList -Join ' ')"
        if($Silent){}elseif(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
        } ;
        if($PassThru){
            $soutf= [System.IO.Path]::GetTempFileName()
            $serrf= [System.IO.Path]::GetTempFileName() 
            $process = Start-Process -FilePath $Cmd -ArgumentList $ArgumentList -NoNewWindow -PassThru -Wait  -RedirectStandardOutput $soutf -RedirectStandardError $serrf  ; 
            $oRet = [ordered]@{
                handle = $process.handle 
                ExitCode = $process.ExitCode ; 
                StdOut = $null ; 
                StdErr = $null ; 
            } ; 
            if((get-childitem $soutf).length) { 
                $oRet.stdOut = (gc $soutf) | out-string ; 
                remove-item $soutf ;
            } ;
            if((get-childitem $serrf).length) { 
                $oRet.StdErr = (gc $serrf) | out-string ; 
                remove-item $serrf ;
            } ;
            $smsg = "Process exited with code $($oRet.ExitCode)" ; 
            if($Silent){}elseif(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ;                         
            $rval = $oRet ; 
        }else{
            $rval=( Start-Process -FilePath $Cmd -ArgumentList $ArgumentList -NoNewWindow -PassThru -Wait).Exitcode
            $smsg = "Process exited with code $rval"
            if($Silent){}elseif(gcm Write-MyOutput -ea 0){Write-MyOutput $smsg } else {
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
            } ; 
            #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success       
        } ; 
        if($Silent){}elseif(gcm Write-MyVerbose -ea 0){Write-MyVerbose $smsg } else {
            if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
        } ;
    } Else {
        $smsg = "$FullName not found"
        if(gcm Write-MyWarning -ea 0){Write-MyWarning $smsg } else {
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN -Indent}
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;
        $rval= -1
    }
    switch ($rval.gettype().fullname){
        'System.Int32'{
            return $rval
        }
        'System.String'{
            return $rval
        }
        'System.Collections.Specialized.OrderedDictionary'{
            return [pscustomobject]$rval 
        }
    }
}
#endregion INVOKE_PROCESSTDO ; #*------^ END Invoke-ProcessTDO ^------