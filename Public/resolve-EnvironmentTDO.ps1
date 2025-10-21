# resolve-EnvironmentTDO.ps1

#region RESOLVE_ENVIRONMENTTDO ; #*------v resolve-EnvironmentTDO v------
if (-not(gi function:resolve-EnvironmentTDO -ea 0)) {
    function resolve-EnvironmentTDO {
        <#
            .SYNOPSIS
            resolve-EnvironmentTDO.ps1 - Resolves local environment into usable Script or Function-descriptive values (for reuse in logging and i/o access)
            .NOTES
            Version     : 0.0.3
            Author      : Todd Kadrie
            Website     : http://www.toddomation.com
            Twitter     : @tostka / http://twitter.com/tostka
            CreatedDate : 2025-04-04
            FileName    : resolve-EnvironmentTDO.ps1
            License     : MIT License
            Copyright   : (c) 2025 Todd Kadrie
            Github      : https://github.com/tostka/verb-IO
            Tags        : Powershell,System,OS,Environment
            AddedCredit : 
            AddedWebsite: 
            AddedTwitter: URL
            REVISION
            * 11:20 AM 9/17/2025 removed write-my* calls: implemented support in vio\write-log() instead (avoids all this manual updating)
            * 2:39 PM 7/17/2025 removed commented code; updated CBH to restore removed details, and to provide demo outputs; added series of examples for common usage
            * 4:44 PM 5/23/2025 updated the splats to psv2/psv3 support (dyn build; prev was psv3 only)
            * 4:13 PM 4/4/2025 init
            .DESCRIPTION
            resolve-EnvironmentTDO.ps1 - Resolves local environment into usable Script or Function-descriptive values (for reuse in logging and i/o access)
                
            Requires inputs of the range of Descriptive Environtment Variables, which due to encapsulation effects, require pre-assignment to variables to properly capture the values for submission as resolve-EnvironmentTDO input paramneters: 
                
            PS> $rPSCmdlet = $PSCmdlet ;
            PS> $rPSScriptRoot = $PSScriptRoot ;
            PS> $rPSCommandPath = $PSCommandPath ;
            PS> $rMyInvocation = $MyInvocation ;
            PS> $rPSBoundParameters = $PSBoundParameters ;  
                
            resolve-EnvironmentTDO then resolves the material into standardized values for use to drive logic in scripts & functions. 
                
                
            ## Properties returned for a module-hosted function:
                
            ```powershell
            14:23:27:resolve-EnvironmentTDO w
            Name                           Value
            ----                           -----
            PSCmdletproxy                  System.Management.Automation.PSScriptCmdlet
            PSScriptRootproxy              D:\cab
            PSCommandPathproxy             D:\cab\xopBuildLibrary.ps1
            MyInvocationproxy              System.Management.Automation.InvocationInfo
            PSBoundParametersproxy         {[Summary, True]}
            verbose                        False
            $rvEnv |out-string

            PSCmdletproxy          : System.Management.Automation.PSScriptCmdlet
            PSScriptRootproxy      : D:\cab
            PSCommandPathproxy     : D:\cab\xopBuildLibrary.ps1
            MyInvocationproxy      : System.Management.Automation.InvocationInfo
            PSBoundParametersproxy : {[Summary, True]}
            runSource              : Function
            CmdletName             : show-ExchangeSetupLogSummary
            PSParameters           : @{Summary=True}
            ParamsNonDefault       : {Path, Summary, Errors, Number...}
            isFunc                 : True
            FuncName               : show-ExchangeSetupLogSummary
            isFuncAdv              : True
            FuncDir                : D:\cab
            isScript               : False
            isScriptUnpathed       : False

            ```
                
            ## Properties returned for a script:
                
            ```powershell
            14:35:27:resolve-EnvironmentTDO w
            Name                           Value
            ----                           -----
            PSCmdletproxy                  System.Management.Automation.PSScriptCmdlet
            PSScriptRootproxy              C:\tmp
            PSCommandPathproxy             C:\tmp\tmp20250717-0230PM.ps1
            MyInvocationproxy              System.Management.Automation.InvocationInfo
            PSBoundParametersproxy         {}
            verbose                        False
                
            $rvEnv returned:
            PSCmdletproxy          : System.Management.Automation.PSScriptCmdlet
            PSScriptRootproxy      : C:\tmp
            PSCommandPathproxy     : C:\tmp\tmp20250717-0230PM.ps1
            MyInvocationproxy      : System.Management.Automation.InvocationInfo
            PSBoundParametersproxy : {}
            runSource              : ExternalScript
            CmdletName             : tmp20250717-0230PM.ps1
            PSParameters           :
            ParamsNonDefault       :
            isScript               : True
            ScriptName             : C:\tmp\tmp20250717-0230PM.ps1
            ScriptBaseName         : tmp20250717-0230PM.ps1
            ScriptNameNoExt        : tmp20250717-0230PM
            ScriptDir              : C:\tmp
            isScriptUnpathed       : True
            isFunc                 : False
            ```

            ## Built-in Environment Descriptor variables:
            - $MyInvocation.MyCommand.Name returns name of a function, to identify the current command,  name of the current script (pop'd w func name, on Advfuncs)
            - Ps3+:$MyInvocation.PSScriptRoot : full path to the script that invoked the current command. The value of this property is populated only when the caller is a script (blank on funcs & Advfuncs)
            - Ps3+:$MyInvocation.PSCommandPath : full path and filename of the script that invoked the current command. The value of this property is populated only when the caller is a script (blank on funcs & Advfuncs)
            #     ** note: above pair contain information about the _invoker or calling script_, not the current script

            .PARAMETER PSCmdletproxy
            Proxied Powershell Automatic Variable object that represents the cmdlet or advanced function thatâ€™s being run. (passed by external assignment to a variable, which is then passed to this function)
            .PARAMETER PSScriptRootproxy
            Proxied Powershell Automatic Variable that contains the full path to the script that invoked the current command. The value of this property is populated only when the caller is a script. (passed by external assignment to a variable, which is then passed to this function).
            .PARAMETER PSCommandPathproxy
            Proxied Powershell Automatic Variable that contains the full path and file name of the script thatâ€™s being run. This variable is valid in all scripts. (passed by external assignment to a variable, which is then passed to this function).
            .PARAMETER MyInvocationproxy
            Proxied Powershell Automatic Variable that contains information about the current command, such as the name, parameters, parameter values, and information about how the command was started, called, or invoked, such as the name of the script that called the current command. (passed by external assignment to a variable, which is then passed to this function).
            .PARAMETER PSBoundParametersproxy
            Proxied Powershell Automatic Variable that contains a dictionary of the parameters that are passed to a script or function and their current values. This variable has a value only in a scope where parameters are declared, such as a script or function. You can use it to display or change the current values of parameters or to pass parameter values to another script or function. (passed by external assignment to a variable, which is then passed to this function).
            .EXAMPLE
            PS> write-verbose "Typically from the BEGIN{} block of an Advanced Function, or immediately after PARAM() block" ; 
            PS> $Verbose = [boolean]($VerbosePreference -eq 'Continue') ;
            PS> $rPSCmdlet = $PSCmdlet ;
            PS> $rPSScriptRoot = $PSScriptRoot ;
            PS> $rPSCommandPath = $PSCommandPath ;
            PS> $rMyInvocation = $MyInvocation ;
            PS> $rPSBoundParameters = $PSBoundParameters ;
            PS> #region RV_ENVIRO ; #*------v RV_ENVIRO v------
            PS> $pltRvEnv=[ordered]@{
            PS>     PSCmdletproxy = $rPSCmdlet ; 
            PS>     PSScriptRootproxy = $rPSScriptRoot ; 
            PS>     PSCommandPathproxy = $rPSCommandPath ; 
            PS>     MyInvocationproxy = $rMyInvocation ;
            PS>     PSBoundParametersproxy = $rPSBoundParameters
            PS>     verbose = [boolean]($PSBoundParameters['Verbose'] -eq $true) ; 
            PS> } ;
            PS> write-verbose "(Purge no value keys from splat)" ; 
            PS> $mts = $pltRVEnv.GetEnumerator() |?{$_.value -eq $null} ; $mts |%{$pltRVEnv.remove($_.Name)} ; rv mts -ea 0 -whatif:$false -confirm:$false; 
            PS> $smsg = "resolve-EnvironmentTDO w`n$(($pltRVEnv|out-string).trim())" ; 
            PS> if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            PS> if(get-command resolve-EnvironmentTDO -ea STOP){}ELSE{
            PS>     $smsg = "UNABLE TO gcm resolve-EnvironmentTDO!" ; 
            PS>     if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
            PS>     else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            PS>     BREAK ; 
            PS> } ; 
            PS> $rvEnv = resolve-EnvironmentTDO @pltRVEnv ; 
            PS> $smsg = "`$rvEnv returned:`n$(($rvEnv |out-string).trim())" ; 
            PS> if($VerbosePreference -eq 'Continue'){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            PS> else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            PS> #endregion RV_ENVIRO ; #*------^ END RV_ENVIRO ^------
            Demo load and invocation, capturing & feeding the local environment descriptors in to reseolve-EnvironmentTDO()
            .EXAMPLE
            PS> #region BANNER ; #*------v BANNER v------
            PS> $sBnr="#*======v " ; 
            PS> if($rvEnv.isScript){                
            PS>     if($rvEnv.PSCommandPathproxy){ $sBnr += $(split-path $rvEnv.PSCommandPathproxy -leaf) }
            PS>     elseif($script:PSCommandPath){$sBnr += $(split-path $script:PSCommandPath -leaf)}
            PS>     elseif($rPSCommandPath){$sBnr += $(split-path $rPSCommandPath -leaf)} ; 
            PS> }elseif($rvEnv.isFunc){
            PS>     if($rvEnv.FuncDir -AND $rvEnv.FuncName){$sBnr += $rvEnv.FuncName } ; 
            PS> } elseif($CmdletName){$sBnr += $rvEnv.CmdletName}; 
            PS> $sBnr += ": v======" ;
            PS> $smsg = $sBnr ;
            PS> if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } #Error|Warn|Debug
            PS> else{ write-host -foregroundcolor green "$((get-date).ToS                
            Demo evaluation of the returned $rvEnv to drive the Banner 'CmdletName'
            .EXAMPLE
            PS> if($rvEnv.isScript){
            PS>     $smtpFrom =  ($rvEnv.ScriptBaseName.replace(".","-") + "@$($Meta.value.o365_OPDomain)")  ; 
            PS>     $smtpSubj += "$($rvEnv.ScriptBaseName.replace(".","-")):$(get-date -format 'yyyyMMdd-HHmmtt')"   ;
            PS> }elseif($rvEnv.isFunc){
            PS>     $smtpFrom =  ($rvEnv.FuncName.replace(".","-") + "@$($Meta.value.o365_OPDomain)") ; 
            PS>     $smtpSubj += "$($rvEnv.FuncName.replace(".","-")):$(get-date -format 'yyyyMMdd-HHmmtt')"   ;
            PS> } ;                    
            Demo construction of a notification From: smtp address from $rvEnv return. 
            .EXAMPLE
            PS> if(-not (get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
            PS> foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
            PS> if(-not (get-variable rgxPSAllUsersScope -ea 0)){$rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;} ;
            PS> if(-not (get-variable rgxPSCurrUserScope -ea 0)){$rgxPSCurrUserScope="^$([regex]::escape([Environment]::GetFolderPath('MyDocuments')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps((d|m)*)1|dll)$" ;} ;                
            PS> if($rvEnv.isScript){
            PS>     write-host "`$script:PSCommandPath:$($script:PSCommandPath)" ;
            PS>     write-host "`$PSCommandPath:$($PSCommandPath)" ;
            PS>     if($rvEnv.PSCommandPathproxy){ $prxPath = $rvEnv.PSCommandPathproxy }
            PS>     elseif($script:PSCommandPath){$prxPath = $script:PSCommandPath}
            PS>     elseif($rPSCommandPath){$prxPath = $rPSCommandPath} ; 
            PS> } ; 
            PS> if($rvEnv.isFunc){
            PS>     if($rvEnv.FuncDir -AND $rvEnv.FuncName){
            PS>            $prxPath = join-path -path $rvEnv.FuncDir -ChildPath $rvEnv.FuncName ; 
            PS>     } ; 
            PS> } ; 
            PS> if(-not $rvEnv.isFunc){
            PS>     # under funcs, this is the scriptblock of the func, not a path
            PS>     if($rvEnv.MyInvocationproxy.MyCommand.Definition){$prxPath2 = $rvEnv.MyInvocationproxy.MyCommand.Definition }
            PS>     elseif($rvEnv.MyInvocationproxy.MyCommand.Definition){$prxPath2 = $rvEnv.MyInvocationproxy.MyCommand.Definition } ; 
            PS> } ; 
            PS> if($prxPath){
            PS>     if(($prxPath -match $rgxPSAllUsersScope) -OR ($prxPath -match $rgxPSCurrUserScope)){
            PS>         $bDivertLog = $true ; 
            PS>         switch -regex ($prxPath){
            PS>             $rgxPSAllUsersScope{$smsg = "AllUsers"} 
            PS>             $rgxPSCurrUserScope{$smsg = "CurrentUser"}
            PS>         } ;
            PS>         $smsg += " context script/module, divert logging into [$budrv]:\scripts" 
            PS>         write-verbose $smsg  ;
            PS>         if($bDivertLog){
            PS>             if((split-path $prxPath -leaf) -ne $rvEnv.CmdletName){
            PS>                 # function in a module/script installed to allusers|cu - defer name to Cmdlet/Function name
            PS>                 $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($rvEnv.CmdletName).ps1") ;
            PS>             } else {
            PS>                 # installed allusers|CU script, use the hosting script name
            PS>                 $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $prxPath -leaf)) ;
            PS>             } ; 
            PS>         } ;
            PS>     } else {
            PS>         $pltSL.Path = $prxPath ;
            PS>     } ;
            PS> }elseif($prxPath2){
            PS>     if(($prxPath2 -match $rgxPSAllUsersScope) -OR ($prxPath2 -match $rgxPSCurrUserScope) ){
            PS>             $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $prxPath2 -leaf)) ;
            PS>     } elseif(test-path $prxPath2) {
            PS>         $pltSL.Path = $prxPath2 ;
            PS>     } elseif($rvEnv.CmdletName){
            PS>         $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($rvEnv.CmdletName).ps1") ;
            PS>     } else {
            PS>         $smsg = "UNABLE TO RESOLVE A FUNCTIONAL `$rvEnv.CmdletName, FROM WHICH TO BUILD A START-LOG.PATH!" ; 
            PS>         if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } #Error|Warn|Debug 
            PS>         else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            PS>         BREAK ;
            PS>     } ; 
            PS> } else{
            PS>     $smsg = "UNABLE TO RESOLVE A FUNCTIONAL `$rvEnv.CmdletName, FROM WHICH TO BUILD A START-LOG.PATH!" ; 
            PS>     if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } #Error|Warn|Debug 
            PS>     else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            PS>     BREAK ;
            PS> }  ;
            Demo construction of a transcript/logfile name using returned $rvEnv (from START_LOG_HOLISTIC)
            .EXAMPLE
            PS> $script:prefVaris = @{
            PS>     whatifIsPresent = $whatif.IsPresent
            PS>     whatifPSBoundParametersContains = $rPSBoundParameters.ContainsKey('WhatIf') ; 
            PS>     whatifPSBoundParameters = $rPSBoundParameters['WhatIf'] ;
            PS>     WhatIfPreferenceIsPresent = $WhatIfPreference.IsPresent ; # -eq $true
            PS>     WhatIfPreferenceValue = $WhatIfPreference;
            PS>     WhatIfPreferenceParentScopeValue = (Get-Variable WhatIfPreference -Scope 1).Value ;
            PS>     ConfirmPSBoundParametersContains = $rPSBoundParameters.ContainsKey('Confirm') ; 
            PS>     ConfirmPSBoundParameters = $rPSBoundParameters['Confirm'];
            PS>     ConfirmPreferenceIsPresent = $ConfirmPreference.IsPresent ; # -eq $true
            PS>     ConfirmPreferenceValue = $ConfirmPreference ;
            PS>     ConfirmPreferenceParentScopeValue = (Get-Variable ConfirmPreference -Scope 1).Value ; 
            PS>     VerbosePSBoundParametersContains = $rPSBoundParameters.ContainsKey('Confirm') ; 
            PS>     VerbosePSBoundParameters = $rPSBoundParameters['Verbose'] ;
            PS>     VerbosePreferenceIsPresent = $VerbosePreference.IsPresent ; # -eq $true
            PS>     VerbosePreferenceValue = $VerbosePreference ;
            PS>     VerbosePreferenceParentScopeValue = (Get-Variable VerbosePreference -Scope 1).Value;
            PS>     VerboseMyInvContains = '-Verbose' -in $rPSBoundParameters.UnboundArguments ; 
            PS>     VerbosePSBoundParametersUnboundArgumentContains = '-Verbose' -in $rPSBoundParameters.UnboundArguments 
            PS> } ;
            PS> write-verbose "`n$(($script:prefVaris.GetEnumerator() | Sort-Object Key | Format-Table Key,Value -AutoSize|out-string).trim())`n" ;                 
            Code to create a hastable of keys evaluating the various Preference Variables
            .LINK
            https://github.com/tostka/verb-XXX
        #>
        [Alias('resolve-Environment')]
        [CmdletBinding()]
        PARAM(
            [Parameter(HelpMessage = "Proxied Powershell Automatic Variable object that represents the cmdlet or advanced function thatâ€™s being run. (passed by external assignment to a variable, which is then passed to this function)")]
            $PSCmdletproxy,
            [Parameter(HelpMessage = "Proxied Powershell Automatic Variable that contains the full path to the script that invoked the current command. The value of this property is populated only when the caller is a script. (passed by external assignment to a variable, which is then passed to this function).")]
            $PSScriptRootproxy,
            [Parameter(HelpMessage = "Proxied Powershell Automatic Variable that contains the full path and file name of the script thatâ€™s being run. This variable is valid in all scripts. (passed by external assignment to a variable, which is then passed to this function).")]
            $PSCommandPathproxy,
            [Parameter(HelpMessage = "Proxied Powershell Automatic Variable that contains information about the current command, such as the name, parameters, parameter values, and information about how the command was started, called, or invoked, such as the name of the script that called the current command. (passed by external assignment to a variable, which is then passed to this function).")]
            $MyInvocationproxy,
            [Parameter(HelpMessage = "Proxied Powershell Automatic Variable that contains a dictionary of the parameters that are passed to a script or function and their current values. This variable has a value only in a scope where parameters are declared, such as a script or function. You can use it to display or change the current values of parameters or to pass parameter values to another script or function. (passed by external assignment to a variable, which is then passed to this function).")]
            $PSBoundParametersproxy
        ) ;
        BEGIN {
            $Verbose = [boolean]($VerbosePreference -eq 'Continue') ;                
            if ($host.version.major -ge 3) { $hshOutput = [ordered]@{Dummy = $null ; } }
            else { $hshOutput = New-Object Collections.Specialized.OrderedDictionary } ;
            If ($hshOutput.Contains("Dummy")) { $hshOutput.remove("Dummy") } ;
            $tv = 'PSCmdletproxy', 'PSScriptRootproxy', 'PSCommandPathproxy', 'MyInvocationproxy', 'PSBoundParametersproxy'
            # stock the autovaris, if populated
            $tv | foreach-object {
                $hshOutput.add($_, (get-variable -name $_ -ea 0).Value)
            } ;
            $smsg = "`$hshOutputn$(($hshOutput|out-string).trim())" ;
            if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            $fieldsnull = 'runSource', 'CmdletName', 'PSParameters', 'ParamsNonDefault'
            if ([boolean]($hshOutput.MyInvocationproxy.MyCommand.commandtype -eq 'Function' -AND $hshOutput.MyInvocationproxy.MyCommand.Name)) {
                $fieldsnull = $(@($fieldsnull); @(@('isFunc', 'funcname', 'isFuncAdv'))) ;
                $fieldsnull = $(@($fieldsnull); @(@('FuncDir'))) ;
            } ;
            if ([boolean]($hshOutput.MyInvocationproxy.MyCommand.commandtype -eq 'ExternalScript' -OR $hshOutput.PSCmdletproxy.MyInvocation.InvocationName -match '\.ps1$')) {
                $fieldsnull = $(@($fieldsnull); @('isScript', 'ScriptName', 'ScriptBaseName', 'ScriptNameNoExt', 'ScriptDir', 'isScriptUnpathed')) ;
            } ;
            $tv = $(@($tv); @($fieldsnull)) ;
            # append resolved elements to the hash as $null
            $fieldsnull  | foreach-object { $hshOutput.add($_, $null) } ;
            $smsg = "`$hshOutputn$(($hshOutput|out-string).trim())" ;
            if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 

            if ($hshOutput.isFunc = [boolean]($hshOutput.MyInvocationproxy.MyCommand.commandtype -eq 'Function' -AND $hshOutput.MyInvocationproxy.MyCommand.Name)) {
                $hshOutput.FuncName = $hshOutput.MyInvocationproxy.MyCommand.Name ; 
                $smsg = "`$hshOutput.FuncName: $($hshOutput.FuncName)" ;
                if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            } ;
            if ($hshOutput.isFunc -AND (gv PSCmdletproxy -ea 0).value -eq $null) {
                $hshOutput.isFuncAdv = $false
            } elseif ($hshOutput.isFunc) {
                $hshOutput.isFuncAdv = [boolean]($hshOutput.isFunc -AND $hshOutput.PSCmdletproxy.MyInvocation.InvocationName -AND ($hshOutput.FuncName -eq $hshOutput.PSCmdletproxy.MyInvocation.InvocationName)) ;
            } ;
            if ($hshOutput.isFunc -AND $hshOutput.PSScriptRootproxy) {
                $hshOutput.FuncDir = $hshOutput.PSScriptRootproxy ;
            } ;
            $hshOutput.isScript = [boolean]($hshOutput.MyInvocationproxy.MyCommand.commandtype -eq 'ExternalScript' -OR $hshOutput.PSCmdletproxy.MyInvocation.InvocationName -match '\.ps1$') ;
            $hshOutput.isScriptUnpathed = [boolean]($hshOutput.PSCmdletproxy.MyInvocation.InvocationName -match '^\.') ; # dot-sourced invocation, no paths will be stored in `$MyInvocation objects
            [array]$score = @() ;
            if ($hshOutput.PSCmdletproxy.MyInvocation.InvocationName) {
                # blank on basic funcs, popd on AdvFuncs
                if ($hshOutput.PSCmdletproxy.MyInvocation.InvocationName -match '\.ps1$') {
                    $score += 'ExternalScript'
                } elseif ($hshOutput.PSCmdletproxy.MyInvocation.InvocationName -match '^\.') {
                    write-warning "dot-sourced invocation detected!:$($hshOutput.PSCmdletproxy.MyInvocation.InvocationName)`n(will be unable to leverage script path etc from `$MyInvocation objects)" ;
                    $smsg = "(dot sourcing is implicit script exec)" ;
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    $score += 'ExternalScript' ;
                } else { $score += 'Function' }; # blank under function exec, has func name under AdvFuncs
            } ;
            if ($hshOutput.PSCmdletproxy.CommandRuntime) {
                # blank on nonAdvfuncs,
                if ($hshOutput.PSCmdletproxy.CommandRuntime.tostring() -match '\.ps1$') { $score += 'ExternalScript' } else { $score += 'Function' } ; # blank under function exec, func name on AdvFuncs
            } ;
            $score += $hshOutput.MyInvocationproxy.MyCommand.commandtype.tostring() ; # returns 'Function' for basic & Adv funcs
            $grpSrc = $score | group-object -NoElement | sort count ;
            if ( ($grpSrc |  measure | select -expand count) -gt 1) {
                write-warning  "$score mixed results:$(($grpSrc| ft -a count,name | out-string).trim())" ;
                if ($grpSrc[-1].count -eq $grpSrc[-2].count) {
                    write-warning "Deadlocked non-majority results!" ;
                } else {
                    $hshOutput.runSource = $grpSrc | select -last 1 | select -expand name ;
                } ;
            } else {
                $smsg = "consistent results" ;
                if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                $hshOutput.runSource = $grpSrc | select -last 1 | select -expand name ;
            };
            if ($hshOutput.runSource -eq 'Function') {
                if ($hshOutput.isFuncAdv) {
                    $smsg = "Calculated `$hshOutput.runSource:Advanced $($hshOutput.runSource)"
                } else {
                    $smsg = "Calculated `$hshOutput.runSource: Basic $($hshOutput.runSource)"
                } ;
            } elseif ($hshOutput.runSource -eq 'ExternalScript') {
                $smsg = "Calculated `$hshOutput.runSource:$($hshOutput.runSource)" ;
            } ;
            if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            'score', 'grpSrc' | get-variable | remove-variable ; # cleanup temp varis
            $hshOutput.CmdletName = $hshOutput.PSCmdletproxy.MyInvocation.MyCommand.Name ; # function self-name (equiv to script's: $MyInvocation.MyCommand.Path), pop'd on AdvFunc
            #region PsParams ; #*------v PSPARAMS v------
            $hshOutput.PSParameters = New-Object -TypeName PSObject -Property $hshOutput.PSBoundParametersproxy ;
            # DIFFERENCES $hshOutput.PSParameters vs $PSBoundParameters:
            # - $PSBoundParameters: System.Management.Automation.PSBoundParametersDictionary (native obj)
            # test/access: ($PSBoundParameters['Verbose'] -eq $true) ; $PSBoundParameters.ContainsKey('Referrer') #hash syntax
            # CAN use as a @PSBoundParameters splat to push through (make sure populated, can fail if wrong type of wrapping code)
            # - $hshOutput.PSParameters: System.Management.Automation.PSCustomObject (created obj)
            # test/access: ($hshOutput.PSParameters.verbose -eq $true) ; $hshOutput.PSParameters.psobject.Properties.name -contains 'SenderAddress' ; # cobj syntax
            # CANNOT use as a @splat to push through (it's a cobj)
            $smsg = "`$hshOutput.PSBoundParametersproxy:`n$(($hshOutput.PSBoundParametersproxy|out-string).trim())" ;
            if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            # pre psv2, no $hshOutput.PSBoundParametersproxy autovari to check, so back them out:
            if ($hshOutput.PSCmdletproxy.MyInvocation.InvocationName) {
                # has func name under AdvFuncs
                if ($hshOutput.PSCmdletproxy.MyInvocation.InvocationName -match '^\.') {
                    $smsg = "detected dot-sourced invocation: Skipping `$PSCmdlet.MyInvocation.InvocationName-tied cmds..." ;
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;                       
                } else {
                    $smsg = "Collect all non-default Params (works back to psv2 w CmdletBinding)"
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    $hshOutput.ParamsNonDefault = (Get-Command $hshOutput.PSCmdletproxy.MyInvocation.InvocationName).parameters |
                    Select-Object -expand keys |
                    Where-Object { $_ -notmatch '(Verbose|Debug|ErrorAction|WarningAction|ErrorVariable|WarningVariable|OutVariable|OutBuffer)' } ;
                } ;
            } else {
                $smsg = "(blank `$hshOutput.PSCmdletproxy.MyInvocation.InvocationName, skipping Parameters collection)" ;
                if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            } ;
            if ($hshOutput.isScript) {
                $hshOutput.ScriptDir = $scriptName = '' ;
                if ($hshOutput.isScript) {
                    $hshOutput.ScriptDir = $hshOutput.PSScriptRootproxy;
                    $hshOutput.ScriptName = $hshOutput.PSCommandPathproxy ;
                    if ($hshOutput.ScriptDir -eq '' -AND $hshOutput.runSource -eq 'ExternalScript') { $hshOutput.ScriptDir = (Split-Path -Path $hshOutput.MyInvocationproxy.MyCommand.Source -Parent) } # Running from File
                };

                if ($hshOutput.ScriptDir -eq '' -AND (Test-Path variable:psEditor)) {
                    $smsg = "Running from VSCode|VS" ;
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    $hshOutput.ScriptDir = (Split-Path -Path $psEditor.GetEditorContext().CurrentFile.Path -Parent) ;
                    if ($hshOutput.ScriptName -eq '') { $hshOutput.ScriptName = $psEditor.GetEditorContext().CurrentFile.Path };
                } ;
                if ($hshOutput.ScriptDir -eq '' -AND $host.version.major -lt 3 -AND $hshOutput.MyInvocationproxy.MyCommand.Path.length -gt 0) {
                    $hshOutput.ScriptDir = $hshOutput.MyInvocationproxy.MyCommand.Path ;
                    $smsg = "(backrev emulating `$hshOutput.PSScriptRootproxy, `$hshOutput.PSCommandPathproxy)"
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    $hshOutput.ScriptName = split-path $hshOutput.MyInvocationproxy.MyCommand.Path -leaf ;
                    $hshOutput.PSScriptRootproxy = Split-Path $hshOutput.ScriptName -Parent ;
                    $hshOutput.PSCommandPathproxy = $hshOutput.ScriptName ;
                } ;
                if ($hshOutput.ScriptDir -eq '' -AND $hshOutput.MyInvocationproxy.MyCommand.Path.length) {
                    if ($hshOutput.ScriptName -eq '') { $hshOutput.ScriptName = $hshOutput.MyInvocationproxy.MyCommand.Path } ;
                    $hshOutput.ScriptDir = $hshOutput.PSScriptRootproxy = Split-Path $hshOutput.MyInvocationproxy.MyCommand.Path -Parent ;
                }
                if ($hshOutput.ScriptDir -eq '') { throw "UNABLE TO POPULATE SCRIPT PATH, EVEN `$hshOutput.MyInvocationproxy IS BLANK!" } ;
                if ($hshOutput.ScriptName) {
                    if (-not $hshOutput.ScriptDir ) { $hshOutput.ScriptDir = Split-Path -Parent $hshOutput.ScriptName } ;
                    $hshOutput.ScriptBaseName = split-path -leaf $hshOutput.ScriptName ;
                    $hshOutput.ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($hshOutput.ScriptName) ;
                } ;
                # blank $cmdlet name comming through, patch it for Scripts:
                if (-not $hshOutput.CmdletName -AND $hshOutput.ScriptBaseName) {
                    $hshOutput.CmdletName = $hshOutput.ScriptBaseName
                }
                # last ditch patch the values in if you've got a $hshOutput.ScriptName
                if ($hshOutput.PSScriptRootproxy.Length -ne 0) {}else {
                    if ($hshOutput.ScriptName) { $hshOutput.PSScriptRootproxy = Split-Path $hshOutput.ScriptName -Parent }
                    else { throw "Unpopulated, `$hshOutput.PSScriptRootproxy, and no populated `$hshOutput.ScriptName from which to emulate the value!" } ;
                } ;
                if ($hshOutput.PSCommandPathproxy.Length -ne 0) {}else {
                    if ($hshOutput.ScriptName) { $hshOutput.PSCommandPathproxy = $hshOutput.ScriptName }
                    else { throw "Unpopulated, `$hshOutput.PSCommandPathproxy, and no populated `$hshOutput.ScriptName from which to emulate the value!" } ;
                } ;
                if (-not ($hshOutput.ScriptDir -AND $hshOutput.ScriptBaseName -AND $hshOutput.ScriptNameNoExt -AND $hshOutput.PSScriptRootproxy -AND $hshOutput.PSCommandPathproxy )) {
                    throw "Invalid Invocation. Blank `$hshOutput.ScriptDir/`$hshOutput.ScriptBaseName/`$hshOutput.ScriptBaseName" ;
                    BREAK ;
                } ;
            } ;
            if ($hshOutput.isFunc) {
                if ($hshOutput.isFuncAdv) {
                    # AdvFunc-specific cmds
                } else {
                    # Basic Func-specific cmds
                } ;
                if ($hshOutput.PSCommandPathproxy -match '\.psm1$') {
                    $smsg = "MODULE-HOMED FUNCTION:Use `$hshOutput.CmdletName to reference the running function name for transcripts etc (under a .psm1 `$hshOutput.ScriptName will reflect the .psm1 file  fullname)"
                    write-host -foregroundcolor yellow $smsg ; 
                    if (-not $hshOutput.CmdletName) { 
                        write-warning "MODULE-HOMED FUNCTION with BLANK `$CmdletNam:$($CmdletNam)" 
                    } ;
                } # Running from .psm1 module
                if (-not $hshOutput.CmdletName -AND $hshOutput.FuncName) {
                    $hshOutput.CmdletName = $hshOutput.FuncName
                } ;
            } ;
            $smsg = "`$hshOutput  w`n$(($hshOutput|out-string).trim())" ;
            #write-host $smsg ;
            write-verbose $smsg ;
        } ;  # BEG-E
        PROCESS {};  # PROC-E
        END {
            if ($hshOutput) {
                $smsg = "(return `$hshOutput to pipeline)" ;
                    if($VerbosePreference -eq "Continue"){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                New-Object PSObject -Property $hshOutput | write-output
            } ;
        }
    } ;
} ;
#endregion RESOLVE_ENVIRONMENTTDO ; #*------^ END resolve-EnvironmentTDO ^------