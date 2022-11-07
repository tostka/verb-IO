#*------v Function Pop-LocationFirst v------
function Pop-LocationFirst {
    <#
    .SYNOPSIS
    Pop-LocationFirst - Pop-Location to the 'first'/'oldest'/'original' item in the stack (which in a normal (Get-Location -stack).path, is actually the _bottom_ entry in the stack ;P)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-05-06
    FileName    : Pop-LocationFirst.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,File,FileSystem
    REVISIONS   :
    * 10:13 AM 5/20/2022 updated the logic, added write-host  dot crawl, vs verbose detailed echos.
    * 3:20 PM 5/6/2022 init
    .PARAMETER PassThru <System.Management.Automation.SwitchParameter>
    Passes an object that represents the location to the pipeline. By default, this cmdlet does not generate any output.
    .INPUTS
    Does not accept piped input.
    .OUTPUTS
    None or System.Object
    .DESCRIPTION
    Pop-LocationFirst - Pop-Location to the 'first'/'oldest'/'original' item in the stack (which in a normal (Get-Location -stack).path, is actually the _bottom_ entry in the stack ;P)
    Usefull for when doing a lot of debugging, and use of pushd in code, with bug/aborts failure to exec tailing bracketing popd to restore to origin pwd (results in deeply nested pwd, when you want to be back at the stack top for fresh debugging passes).
    .EXAMPLE
    PS> pushd c:\usr\local\bin\ ; pushd c:\usr\sbin\ ; pushd C:\temp\ ; 
    PS> Pop-LocationFirst -verbose ;
    Push-location three locations into the stack, then Set-Location to the first/lowest location in the stack
    .EXAMPLE
    $finalPwd = popd1 -verbose -passthru ;
    Set-Location to the first/lowest location in the stack, and assign the resulting location system.object to the $currDir variable; with verbose output (emulates pop-location/popd -passthru behavior)
    .LINK
    https://github.com/tostka/verb-io
    #>    
    [CmdletBinding()]
    [Alias('popd1')]
    Param(
        [Parameter(HelpMessage = 'Passes an object that represents the location to the pipeline. By default, this cmdlet does not generate any output.[-PassThru]')]
        [switch]$PassThru
    ) ;
    $stk = get-location -stack ; 
    if($stk.count){
        $nwd = ((get-location -stack).path)[-1] ; 
        write-verbose "pop-location to first/bottom stack entry:$($nwd)" ;
        # could directly cd to the target dir
        # set-location $nwd ; 
        # but if you want to increment the pointer to the matching location (esp if depicting the depth in prompt), you need to popd your way back out.
        #1..((get-location -stack).path.count + 1) | foreach-object {write-verbose 'pop-location' ; Pop-Location  } ; 
        if($n = (get-location -Stack).count){ 
            1..$($n) |foreach-object {
                if($VerbosePreference -eq "Continue"){write-verbose 'pop-location'}
                else {write-host '.' -nonewline } ; 
                Pop-Location  ; 
            } 
        } ;
    } else { 
        write-verbose '(no current locations in the stack)' ; 
    } ; 
    if($PassThru){
        write-verbose "(returning pwd object to pipeline)" ; 
        Get-Location |write-output ; 
    } ; 
} ;
#*------^ END Function Pop-LocationFirst ^------
