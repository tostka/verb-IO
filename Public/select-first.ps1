#*------v Function select-first v------
function select-first {
    <#
    .SYNOPSIS
    select-first.ps1 - functionalized 'Select-Object -first $n' 
    .NOTES
    Version     : 1.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-13
    FileName    : select-first.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,FileSystem,Shortcut,Link
    AddedCredit : tonymcgee
    AddedWebsite: https://www.tonymcgee.net/2013/11/powershell-profile-snippets/
    REVISIONS
    * 8:20 AM 5/4/2021 had in xxx-prof.ps1, wasn't replicated out to other admin profiles, so stick it in verb-io    
    * 11/2013 tonymcgee's posted vers
    .DESCRIPTION
    select-first.ps1 - functionalized 'Select-Object -first $n' 
    .PARAMETER  n
    count of pipline items to be returned
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    PSCustomObject
    .EXAMPLE
    PS > $object | select-first ; 
    Example using default settings (returns first object from pipeline)
    .EXAMPLE
    PS > $object | select-first -n 5; 
    Example returning first 5 objects from pipeline
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://www.tonymcgee.net/2013/11/powershell-profile-snippets/
    #>
    # cmdletbinding breaks default pipeline, and causes err:' The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or the input and its properties do not match any of the parameters that take pipeline input'
    #[CmdletBinding()]
    PARAM([int] $n=1) ;
    $Input | Select-Object -first $n ; 
}
#*------^ END Function select-first ^------
