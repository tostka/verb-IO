# resolve-EnvironmentTDO.ps1

#region RESOLVE_ENVIRONMENTTDO ; #*------v resolve-EnvironmentTDO v------
#if(-not(gi function:resolve-EnvironmentTDO -ea 0)){
    function resolve-EnvironmentTDO {
        <#
            .SYNOPSIS
            resolve-EnvironmentTDO.ps1 - Resolves local environment into usable Script or Function-descriptive values (for reuse in logging and i/o access)
            .NOTES
            Version     : 0.0.2
            Author      : Todd Kadrie
            Website     : http://www.toddomation.com
            Twitter     : @tostka / http://twitter.com/tostka
            CreatedDate : 2025-04-04
            FileName    : resolve-EnvironmentTDO.ps1
            License     : (non asserted)
            Copyright   : (non asserted)
            Github      : https://github.com/tostka/verb-ex2010
            Tags        : Powershell,ExchangeServer,Version
            AddedCredit : theSysadminChannel
            AddedWebsite: https://thesysadminchannel.com/get-exchange-cumulative-update-version-and-build-numbers-using-powershell/
            AddedTwitter: URL
            REVISION
            * 4:13 PM 4/4/2025 init
            .EXAMPLE
            PS> write-verbose "Typically from the BEGIN{} block of an Advanced Function, or immediately after PARAM() block" ; 
            PS> $Verbose = [boolean]($VerbosePreference -eq 'Continue') ;
            PS> $rPSCmdlet = $PSCmdlet ;
            PS> $rPSScriptRoot = $PSScriptRoot ;
            PS> $rPSCommandPath = $PSCommandPath ;
            PS> $rMyInvocation = $MyInvocation ;
            PS> $rPSBoundParameters = $PSBoundParameters ;
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
            PS> $rvEnv = resolve-EnvironmentTDO @pltRVEnv ;  
            PS> write-host "Returned `$rvEnv:`n$(($rvEnv|out-string).trim())" ; 
        #>
        [Alias('resolve-Environment')]
        [CmdletBinding()]
        PARAM(
            [Parameter(HelpMessage="Proxied Powershell Automatic Variable object that represents the cmdlet or advanced function that’s being run. (passed by external assignment to a variable, which is then passed to this function)")] 
                $PSCmdletproxy,        
            [Parameter(HelpMessage="Proxied Powershell Automatic Variable that contains the full path to the script that invoked the current command. The value of this property is populated only when the caller is a script. (passed by external assignment to a variable, which is then passed to this function).")] 
                $PSScriptRootproxy,
            [Parameter(HelpMessage="Proxied Powershell Automatic Variable that contains the full path and file name of the script that’s being run. This variable is valid in all scripts. (passed by external assignment to a variable, which is then passed to this function).")] 
                $PSCommandPathproxy,
            [Parameter(HelpMessage="Proxied Powershell Automatic Variable that contains information about the current command, such as the name, parameters, parameter values, and information about how the command was started, called, or invoked, such as the name of the script that called the current command. (passed by external assignment to a variable, which is then passed to this function).")]
                $MyInvocationproxy,
            [Parameter(HelpMessage="Proxied Powershell Automatic Variable that contains a dictionary of the parameters that are passed to a script or function and their current values. This variable has a value only in a scope where parameters are declared, such as a script or function. You can use it to display or change the current values of parameters or to pass parameter values to another script or function. (passed by external assignment to a variable, which is then passed to this function).")]
                $PSBoundParametersproxy
        ) ; 
        BEGIN {
            $Verbose = [boolean]($VerbosePreference -eq 'Continue') ; 
            <#
            $PSCmdletproxy = $PSCmdlet ; # an object that represents the cmdlet or advanced function that's being run. Available on functions w CmdletBinding (& $args will not be available). (Blank on non-CmdletBinding/Non-Adv funcs).
            $PSScriptRootproxy = $PSScriptRoot ; # the full path of the executing script's parent directory., PS2: valid only in script modules (.psm1). PS3+:it's valid in all scripts. (Funcs: ParentDir of the file that hosts the func)
            $PSCommandPathproxy = $PSCommandPath ; # the full path and filename of the script that's being run, or file hosting the funct. Valid in all scripts.
            $MyInvocationproxy = $MyInvocation ; # populated only for scripts, function, and script blocks.
            #>
            # - $MyInvocation.MyCommand.Name returns name of a function, to identify the current command,  name of the current script (pop'd w func name, on Advfuncs)
            # - Ps3+:$MyInvocation.PSScriptRoot : full path to the script that invoked the current command. The value of this property is populated only when the caller is a script (blank on funcs & Advfuncs)
            # - Ps3+:$MyInvocation.PSCommandPath : full path and filename of the script that invoked the current command. The value of this property is populated only when the caller is a script (blank on funcs & Advfuncs)
            #     ** note: above pair contain information about the _invoker or calling script_, not the current script
            #$PSBoundParametersproxy = $PSBoundParameters ; 

            if($host.version.major -ge 3){$hshOutput=[ordered]@{Dummy = $null ;} }
            else {$hshOutput = New-Object Collections.Specialized.OrderedDictionary} ;
            If($hshOutput.Contains("Dummy")){$hshOutput.remove("Dummy")} ;
            $tv = 'PSCmdletproxy','PSScriptRootproxy','PSCommandPathproxy','MyInvocationproxy','PSBoundParametersproxy'
            # stock the autovaris, if populated
            $tv | % { 
                $hshOutput.add($_, (get-variable -name $_ -ea 0).Value) 
            } ;
            write-verbose "`$hshOutputn$(($hshOutput|out-string).trim())" ; 
            $fieldsnull = 'runSource','CmdletName','PSParameters','ParamsNonDefault' 
            if([boolean]($hshOutput.MyInvocationproxy.MyCommand.commandtype -eq 'Function' -AND $hshOutput.MyInvocationproxy.MyCommand.Name)){
                #$tv+= @('isFunc','funcname','isFuncAdv') ; 
                $fieldsnull = $(@($fieldsnull);@(@('isFunc','funcname','isFuncAdv'))) ; 
                #$tv+= @('FuncDir') ; 
                $fieldsnull = $(@($fieldsnull);@(@('FuncDir'))) ; 
            } ; 
            if([boolean]($hshOutput.MyInvocationproxy.MyCommand.commandtype -eq 'ExternalScript' -OR $hshOutput.PSCmdletproxy.MyInvocation.InvocationName -match '\.ps1$')){
                #$tv += @('isScript','ScriptName','ScriptBaseName','ScriptNameNoExt','ScriptDir','isScriptUnpathed') ; 
                $fieldsnull = $(@($fieldsnull);@('isScript','ScriptName','ScriptBaseName','ScriptNameNoExt','ScriptDir','isScriptUnpathed')) ; 
            } ; 
            $tv = $(@($tv);@($fieldsnull)) ; 
            # append resolved elements to the hash as $null 
            $fieldsnull  | % { $hshOutput.add($_,$null) } ;
            write-verbose "`$hshOutputn$(($hshOutput|out-string).trim())" ; 

            if($hshOutput.isFunc = [boolean]($hshOutput.MyInvocationproxy.MyCommand.commandtype -eq 'Function' -AND $hshOutput.MyInvocationproxy.MyCommand.Name)){
                $hshOutput.FuncName = $hshOutput.MyInvocationproxy.MyCommand.Name ; write-verbose "`$hshOutput.FuncName: $($hshOutput.FuncName)" ; 
            } ;
            if($hshOutput.isFunc -AND (gv PSCmdletproxy -ea 0).value -eq $null){
                $hshOutput.isFuncAdv = $false 
            }elseif($hshOutput.isFunc){
                $hshOutput.isFuncAdv = [boolean]($hshOutput.isFunc -AND $hshOutput.PSCmdletproxy.MyInvocation.InvocationName -AND ($hshOutput.FuncName -eq $hshOutput.PSCmdletproxy.MyInvocation.InvocationName)) ; 
            } ; 
            if($hshOutput.isFunc -AND $hshOutput.PSScriptRootproxy){
                $hshOutput.FuncDir = $hshOutput.PSScriptRootproxy ; 
            } ; 
            $hshOutput.isScript = [boolean]($hshOutput.MyInvocationproxy.MyCommand.commandtype -eq 'ExternalScript' -OR $hshOutput.PSCmdletproxy.MyInvocation.InvocationName -match '\.ps1$') ; 
            $hshOutput.isScriptUnpathed = [boolean]($hshOutput.PSCmdletproxy.MyInvocation.InvocationName  -match '^\.') ; # dot-sourced invocation, no paths will be stored in `$MyInvocation objects 
            [array]$score = @() ; 
            if($hshOutput.PSCmdletproxy.MyInvocation.InvocationName){ 
                # blank on basic funcs, popd on AdvFuncs
                if($hshOutput.PSCmdletproxy.MyInvocation.InvocationName -match '\.ps1$'){$score+= 'ExternalScript' 
                }elseif($hshOutput.PSCmdletproxy.MyInvocation.InvocationName  -match '^\.'){
                    write-warning "dot-sourced invocation detected!:$($hshOutput.PSCmdletproxy.MyInvocation.InvocationName)`n(will be unable to leverage script path etc from `$MyInvocation objects)" ; 
                    write-verbose "(dot sourcing is implicit script exec)" ; 
                    $score+= 'ExternalScript' ; 
                } else {$score+= 'Function' }; # blank under function exec, has func name under AdvFuncs
            } ; 
            if($hshOutput.PSCmdletproxy.CommandRuntime){
                # blank on nonAdvfuncs, 
                if($hshOutput.PSCmdletproxy.CommandRuntime.tostring() -match '\.ps1$'){$score+= 'ExternalScript' } else {$score+= 'Function' } ; # blank under function exec, func name on AdvFuncs
            } ; 
            $score+= $hshOutput.MyInvocationproxy.MyCommand.commandtype.tostring() ; # returns 'Function' for basic & Adv funcs
            $grpSrc = $score | group-object -NoElement | sort count ;
            if( ($grpSrc |  measure | select -expand count) -gt 1){
                write-warning  "$score mixed results:$(($grpSrc| ft -a count,name | out-string).trim())" ;
                if($grpSrc[-1].count -eq $grpSrc[-2].count){
                    write-warning "Deadlocked non-majority results!" ;
                } else {
                    $hshOutput.runSource = $grpSrc | select -last 1 | select -expand name ;
                } ;
            } else {
                write-verbose "consistent results" ;
                $hshOutput.runSource = $grpSrc | select -last 1 | select -expand name ;
            };
            if($hshOutput.runSource -eq 'Function'){
                if($hshOutput.isFuncAdv){
                    $smsg = "Calculated `$hshOutput.runSource:Advanced $($hshOutput.runSource)"
                } else { 
                    $smsg = "Calculated `$hshOutput.runSource: Basic $($hshOutput.runSource)"
                } ; 
            }elseif($hshOutput.runSource -eq 'ExternalScript'){
                $smsg =  "Calculated `$hshOutput.runSource:$($hshOutput.runSource)" ;
            } ; 
            write-verbose $smsg ;
            'score','grpSrc' | get-variable | remove-variable ; # cleanup temp varis
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
            write-verbose "`$hshOutput.PSBoundParametersproxy:`n$(($hshOutput.PSBoundParametersproxy|out-string).trim())" ;
            # pre psv2, no $hshOutput.PSBoundParametersproxy autovari to check, so back them out:
            if($hshOutput.PSCmdletproxy.MyInvocation.InvocationName){
                # has func name under AdvFuncs
                if($hshOutput.PSCmdletproxy.MyInvocation.InvocationName  -match '^\.'){
                    $smsg = "detected dot-sourced invocation: Skipping `$PSCmdlet.MyInvocation.InvocationName-tied cmds..." ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    #Levels:Error|Warn|Info|H1|H2|H3|H4|H5|Debug|Verbose|Prompt|Success
                } else { 
                    write-verbose 'Collect all non-default Params (works back to psv2 w CmdletBinding)'
                    $hshOutput.ParamsNonDefault = (Get-Command $hshOutput.PSCmdletproxy.MyInvocation.InvocationName).parameters | 
                        Select-Object -expand keys | 
                        Where-Object{$_ -notmatch '(Verbose|Debug|ErrorAction|WarningAction|ErrorVariable|WarningVariable|OutVariable|OutBuffer)'} ;
                } ; 
            } else { 
                $smsg = "(blank `$hshOutput.PSCmdletproxy.MyInvocation.InvocationName, skipping Parameters collection)" ; 
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            } ; 
            if($hshOutput.isScript){
                $hshOutput.ScriptDir = $scriptName = '' ;     
                if($hshOutput.isScript){
                    $hshOutput.ScriptDir = $hshOutput.PSScriptRootproxy; 
                    $hshOutput.ScriptName = $hshOutput.PSCommandPathproxy ; 
                    if($hshOutput.ScriptDir -eq '' -AND $hshOutput.runSource -eq 'ExternalScript'){$hshOutput.ScriptDir = (Split-Path -Path $hshOutput.MyInvocationproxy.MyCommand.Source -Parent)} # Running from File
                };

                if($hshOutput.ScriptDir -eq '' -AND (Test-Path variable:psEditor)) {
                    write-verbose "Running from VSCode|VS" ; 
                    $hshOutput.ScriptDir = (Split-Path -Path $psEditor.GetEditorContext().CurrentFile.Path -Parent) ; 
                        if($hshOutput.ScriptName -eq ''){$hshOutput.ScriptName = $psEditor.GetEditorContext().CurrentFile.Path }; 
                } ;
                if ($hshOutput.ScriptDir -eq '' -AND $host.version.major -lt 3 -AND $hshOutput.MyInvocationproxy.MyCommand.Path.length -gt 0){
                    $hshOutput.ScriptDir = $hshOutput.MyInvocationproxy.MyCommand.Path ; 
                    write-verbose "(backrev emulating `$hshOutput.PSScriptRootproxy, `$hshOutput.PSCommandPathproxy)"
                    $hshOutput.ScriptName = split-path $hshOutput.MyInvocationproxy.MyCommand.Path -leaf ;
                    $hshOutput.PSScriptRootproxy = Split-Path $hshOutput.ScriptName -Parent ;
                    $hshOutput.PSCommandPathproxy = $hshOutput.ScriptName ;
                } ;
                if ($hshOutput.ScriptDir -eq '' -AND $hshOutput.MyInvocationproxy.MyCommand.Path.length){
                    if($hshOutput.ScriptName -eq ''){$hshOutput.ScriptName = $hshOutput.MyInvocationproxy.MyCommand.Path} ;
                    $hshOutput.ScriptDir = $hshOutput.PSScriptRootproxy = Split-Path $hshOutput.MyInvocationproxy.MyCommand.Path -Parent ;
                }
                if ($hshOutput.ScriptDir -eq ''){throw "UNABLE TO POPULATE SCRIPT PATH, EVEN `$hshOutput.MyInvocationproxy IS BLANK!" } ;
                if($hshOutput.ScriptName){
                    if(-not $hshOutput.ScriptDir ){$hshOutput.ScriptDir = Split-Path -Parent $hshOutput.ScriptName} ; 
                    $hshOutput.ScriptBaseName = split-path -leaf $hshOutput.ScriptName ;
                    $hshOutput.ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($hshOutput.ScriptName) ;
                } ; 
                # blank $cmdlet name comming through, patch it for Scripts:
                if(-not $hshOutput.CmdletName -AND $hshOutput.ScriptBaseName){
                    $hshOutput.CmdletName = $hshOutput.ScriptBaseName
                }
                # last ditch patch the values in if you've got a $hshOutput.ScriptName
                if($hshOutput.PSScriptRootproxy.Length -ne 0){}else{ 
                    if($hshOutput.ScriptName){$hshOutput.PSScriptRootproxy = Split-Path $hshOutput.ScriptName -Parent }
                    else{ throw "Unpopulated, `$hshOutput.PSScriptRootproxy, and no populated `$hshOutput.ScriptName from which to emulate the value!" } ; 
                } ; 
                if($hshOutput.PSCommandPathproxy.Length -ne 0){}else{ 
                    if($hshOutput.ScriptName){$hshOutput.PSCommandPathproxy = $hshOutput.ScriptName }
                    else{ throw "Unpopulated, `$hshOutput.PSCommandPathproxy, and no populated `$hshOutput.ScriptName from which to emulate the value!" } ; 
                } ; 
                if(-not ($hshOutput.ScriptDir -AND $hshOutput.ScriptBaseName -AND $hshOutput.ScriptNameNoExt  -AND $hshOutput.PSScriptRootproxy  -AND $hshOutput.PSCommandPathproxy )){ 
                    throw "Invalid Invocation. Blank `$hshOutput.ScriptDir/`$hshOutput.ScriptBaseName/`$hshOutput.ScriptBaseName" ; 
                    BREAK ; 
                } ; 
            } ; 
            if($hshOutput.isFunc){
                if($hshOutput.isFuncAdv){
                    # AdvFunc-specific cmds
                }else {
                    # Basic Func-specific cmds
                } ; 
                if($hshOutput.PSCommandPathproxy -match '\.psm1$'){
                    write-host "MODULE-HOMED FUNCTION:Use `$hshOutput.CmdletName to reference the running function name for transcripts etc (under a .psm1 `$hshOutput.ScriptName will reflect the .psm1 file  fullname)"
                    if(-not $hshOutput.CmdletName){write-warning "MODULE-HOMED FUNCTION with BLANK `$CmdletNam:$($CmdletNam)" } ;
                } # Running from .psm1 module
                if(-not $hshOutput.CmdletName -AND $hshOutput.FuncName){
                    $hshOutput.CmdletName = $hshOutput.FuncName
                } ; 
            } ; 
            $smsg = "`$hshOutput  w`n$(($hshOutput|out-string).trim())" ; 
            #write-host $smsg ; 
            write-verbose $smsg ; 
        } ;  # BEG-E
        PROCESS {};  # PROC-E
        END {
            if($hshOutput){
                write-verbose "(return `$hshOutput to pipeline)" ; 
                New-Object PSObject -Property $hshOutput | write-output 
            } ; 
        }
    } ; 
#} ;
#endregion RESOLVE_ENVIRONMENTTDO ; #*------^ END resolve-EnvironmentTDO ^------
