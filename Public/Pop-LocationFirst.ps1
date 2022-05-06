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
    * 3:20 PM 5/6/2022 init
    .PARAMETER PassThru <System.Management.Automation.SwitchParameter>
    Passes an object that represents the location to the pipeline. By default, this cmdlet does not generate any output.
    .INPUTS
    Does not accept piped input.
    .OUTPUTS
    None or System.Object
    .DESCRIPTION
    Pop-LocationFirst - Pop-Location to the 'first'/'oldest'/'original' item in the stack (which in a normal (Get-Location -stack).path, is actually the _bottom_ entry in the stack ;P)
    .EXAMPLE
    PS> Pop-LocationFirst -verbose ;
    Set-Location to the first/lowest location in the stack
    .EXAMPLE
    $currdir = popd1 -verbose -passthru ;
    Set-Location to the first/lowest location in the stack, and assign the resulting location system.object to the $currDir variable; with verbose output.
    .LINK
    https://github.com/tostka/verb-io
    #>    
    [CmdletBinding()]
    [Alias('popd1')]
    Param(
        [Parameter(HelpMessage = 'Passes an object that represents the location to the pipeline. By default, this cmdlet does not generate any output.[-PassThru]')]
        [switch]$PassThru
    ) ;
    $nwd = ((get-location -stack).path)[-1] ; 
    write-verbose "pop-location to first/bottom stack entry:$($nwd)" ;
    # could directly cd to the target dir
    # set-location $nwd ; 
    # but if you want to increment the pointer to the matching location (esp if depicting the depth in primpt), you need to popd your way back out.
    1..((get-location -stack).path.count + 1) | foreach-object {write-verbose 'pop-location' ; popd } ; 
    if($PassThru){
        write-verbose "(returning pwd object to pipeline)" ; 
        Get-Location |write-output ; 
    } ; 
} ;
#*------^ END Function Pop-LocationFirst ^------
