#*------v Function test-IsUncPath v------
function test-IsUncPath {
    <#
    .SYNOPSIS
    test-IsUncPath.ps1 - Checks specified path is in UNC format
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-04-21
    FileName    : test-IsUncPath.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Filesystem
    REVISIONS
    * 10:28 AM 4/21/2022 init
    .DESCRIPTION
    test-IsUncPath.ps1 - Checks specified path is in UNC format
    .PARAMETER  Path
    Full registPath to be tested [-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending']
    .EXAMPLE
    test-IsUncPath -Path "L:\somepath\file.txt" ;  ; 
    Tests one of the Pending Reboot keys
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [OutputType('bool')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory,Position=0,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    ) ;
    BEGIN {
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 
    } ;  
    PROCESS {
        $Error.Clear() ; 
        foreach($item in $path) {
            $PathInfo=[System.Uri]$item ; 
            if($PathInfo.IsUnc){ 
                write-verbose "$Path is UNC Path..." ;
                $true | write-output ;
            } else { 
                write-verbose "$Path is Local Path..." ;
                $false | write-output ;
            } ; 
        } ; 
    } ;  
} ; 
#*------^ END Function test-IsUncPath ^------
