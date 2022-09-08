# test-FileSysAutomaticVariables.ps1
# rem'd function c
#*------v Function test-FileSysAutomaticVariables.ps1 v------
function test-FileSysAutomaticVariables {
    <#
    .SYNOPSIS
    test-FileSysAutomaticVariables.ps1 - Simply echos a report on current values within key Filesystem/Script/Function-related AutomaticVariables (Useful for determinging the extent to which you can depend on and *leverage* a given AVari, under a given specific OS/Host). 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2022-
    FileName    : test-FileSysAutomaticVariables.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell
    REVISIONS
    * 10:13 AM 7/28/2022 init
    .DESCRIPTION
    test-FileSysAutomaticVariables.ps1 - Simply echos a report on current values within key Filesystem/Script/Function-related AutomaticVariables (Useful for determinging the extent to which you can depend on and *leverage* a given AVari, under a given specific OS/Host). 
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)    
    .EXAMPLE
    PS> .\test-FileSysAutomaticVariablesPS1.ps1
    # psv2 ISE output from .ps1:
        :==(20220729-0525AM)=Computername:SERVERNAME:PS1-CHECK
        $host.version:	2.0
        $IsCoreCLR:
        $IsLinux:
        $IsMacOS:
        $IsWindows:
        $PSCmdlet.MyInvocation.MyCommand.Name:decommission-Ex10Server.ps1
        $PSScriptRoot:	
        $PSCommandPath:	
        (&{$myInvocation}).ScriptName):	C:\scripts\decommission-Ex10Server.ps1
        $MyInvocation.InvocationName:	.\decommission-Ex10Server.ps1
        $MyInvocation.PSScriptRoot (populated when called fr a script & is *caller*):

        $MyInvocation.PSCommandPath (populated when called fr a script & is *caller*):

        --Legacy Path resolutions:
        $ScriptDir (fr $MyInvocation):	C:\scripts\
        $ScriptBaseName (fr &{System.Management.Automation.InvocationInfo}).ScriptName):	decommission-Ex10Server.ps1
        $ScriptNameNoExt (fr $MyInvocation.InvocationName):	decommission-Ex10Server
        $MyInvocation.MyCommand.Path:	C:\scripts
    Example run as a .ps1 script file. 
    .LINK
    https://github.com/tostka/verb-XXX
    #>
    [CmdletBinding()]
    ###[Alias('Alias','Alias2')]
    PARAM() ;
    
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;


    Try {
        $ScriptRoot = Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction Stop
    }Catch{
        $ScriptRoot = Split-Path $script:MyInvocation.MyCommand.Path
    }

    # legacy resolution methods: 
    switch($pscmdlet.myinvocation.mycommand.CommandType){
        'Function' {
            $smsg = "CommandType:Function:Running context does not support populated `$MyInvocation.MyCommand.Definition|Path" ; 
            $smsg += "(interpolating values from other configured sources)" ; 
            write-host $smsg ; 
            $ScriptDir= $ScriptRoot ; 
            $ScriptBaseName = $pscmdlet.myinvocation.mycommand.Name ; 
            $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($pscmdlet.myinvocation.mycommand.Name ) ; 
            $smsg += "`n--Legacy Path resolutions:" ; 
            $slmsg += "`n`$ScriptDir (fr `$PSScriptRoot):`t$($ScriptDir)" ; 
            $slmsg += "`n`$ScriptBaseName (fr `$pscmdlet.myinvocation.mycommand.Name):`t$($ScriptBaseName)" ; 
            $slmsg += "`n`$ScriptNameNoExt (fr `$pscmdlet.myinvocation.mycommand.Name):`t$($ScriptNameNoExt)" ;
        }
        'ExternalScript' {
            $smsg = "CommandType:ExternalScript:.ps1" ; 
            $smsg += "(determining values from legacy sources)" ;
            write-host $smsg ; 
            #$ScriptDir=(Split-Path -parent $MyInvocation.MyCommand.Definition) + "\" ;
            TRY{
                $ScriptDir=((Split-Path -parent $MyInvocation.MyCommand.Definition -ErrorAction STOP) + "\");
                $ScriptBaseName = (Split-Path -Leaf ((&{$myInvocation}).ScriptName))  ; 
                $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ; 

                $smsg += "`n--Legacy Path resolutions:" ; 
                $slmsg += "`n`$ScriptDir (fr `$MyInvocation):`t$($ScriptDir)" ; 
                $slmsg += "`n`$ScriptBaseName (fr &{$myInvocation}).ScriptName):`t$($ScriptBaseName)" ; 
                $slmsg += "`n`$ScriptNameNoExt (fr `$MyInvocation.InvocationName):`t$($ScriptNameNoExt)" ; 
                $slmsg += "`n`$MyInvocation.MyCommand.Path:`t$((Split-Path -parent $MyInvocation.MyCommand.Path))" ; 
            } CATCH {
                $smsg = "Running context does not support populated `$MyInvocation.MyCommand.Definition|Path" ; 
                $smsg += "(interpolating values from other configured sources)" ; 


            } ; 
        }
        default {
            write-warning "Unrecognized `$pscmdlet.myinvocation.mycommand.CommandType:$($pscmdlet.myinvocation.mycommand.CommandType)!" ; 

        } ; 
    } ; 

     # patch in older non-supporting ISE
    if(-not $ScriptDir -AND $psise){
        write-host "Empty `$ScriptDir with ISE:Failing through to $PSISE obj space" ; 
        $ScriptDir = Split-Path $psise.CurrentFile.FullPath ;
        $ScriptBaseName = Split-Path $psise.CurrentFile.FullPath -leaf ; 
        $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($ScriptBaseName ) ; 
    } ; 
            
    <# Quibble with a potentially interesting aside: The closer v2- approximation of 
    $PSScriptRoot is (Split-Path -Parent applied to) $MyInvocation.MyCommand.Path, 
    not $MyInvocation.MyCommand.Definition, though in the top-level scope of a 
    script they behave the same (which is the only sensible place to call from for 
    this purpose). When called inside a function or script block, the former 
    returns the empty string, whereas the latter returns the function body's / 
    script block's definition as a string (a piece of PowerShell source code). �"  
    mklement0
    Sep 4, 2019 at 14:24
    #>
              
    $smsg = "==($(get-date -format 'yyyyMMdd-HHmmtt'))=Computername:$($env:computername):" ; 
    switch($pscmdlet.myinvocation.mycommand.CommandType){
        'Function' {
            $smsg += "FUNCTION-CHECK" ;
        }
        'ExternalScript' {
            $smsg += "PS1-CHECK" ;
        }
        default {
            $smsg += "(UNKNOWN)" ;

        } ; 
    } ; 
    $smsg += "`n`n`$host.version:`t$($host.version)" ; 
    $smsg += "`n`$IsCoreCLR:$($IsCoreCLR)" ; 
    $smsg += "`n`$IsLinux:$($IsLinux)" ; 
    $smsg += "`n`$IsMacOS:$($IsMacOS)" ; 
    $smsg += "`n`$IsWindows:$($IsWindows)" ; 
    $smsg += "`n`$PSCmdlet.MyInvocation.MyCommand.Name:$($PSCmdlet.MyInvocation.MyCommand.Name)" ; 
    #$smsg += "`nSplit-Path -parent $MyInvocation.MyCommand.Definition:$(Split-Path -parent $MyInvocation.MyCommand.Definition)" ;  
    $smsg += "`n`$PSScriptRoot:`t$($PSScriptRoot)" ;
    $smsg += "`n`$PSCommandPath:`t$($PSCommandPath)" ;
    # def dumps back the source code, not much else useful. 
    #$smsg += "`n`$MyInvocation.MyCommand.Definition:`t$($MyInvocation.MyCommand.Definition)" ;
    $smsg += "`n`(&{`$myInvocation}).ScriptName):`t$((&{$myInvocation}).ScriptName)" ;
    $smsg += "`n`$MyInvocation.InvocationName:`t$($MyInvocation.InvocationName)" ;
    $smsg += "`n`$MyInvocation.PSScriptRoot (populated when called fr a script & is *caller*):`n$($MyInvocation.PSScriptRoot)" ; 
    $smsg += "`n`$MyInvocation.PSCommandPath (populated when called fr a script & is *caller*):`n$($MyInvocation.PSCommandPath)" ; 
    $smsg += "`n--Legacy Path resolutions:" ; 
    $smsg += $slmsg ; 

    write-host $smsg ; 
} ; # disabled function brackets
#*------^ END Function test-FileSysAutomaticVariables.ps1 ^------
