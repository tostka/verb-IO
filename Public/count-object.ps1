#*------v Function Count-Object v------
function Count-Object {
    <#
    .SYNOPSIS
    Count-Object.ps1 - functionalized '($Input | Measure-Object).Count' 
    .NOTES
    Version     : 1.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-13
    FileName    : Count-Object.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,FileSystem,Pipeline
    AddedCredit : tonymcgee
    AddedWebsite: https://www.tonymcgee.net/2013/11/powershell-profile-snippets/
    REVISIONS
    * 8:20 AM 5/4/2021 had in xxx-prof.ps1, wasn't replicated out to other admin profiles, so stick it in verb-io    
    * 11/2013 tonymcgee's posted vers
    .DESCRIPTION
    Count-Object.ps1 - functionalized 'Select-Object -last $n' 
    .PARAMETER  n
    count of pipline items to be returned
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    PSCustomObject
    .EXAMPLE
    PS > $object | Count-Object ; 
    Example using default settings (returns last object from pipeline)
    .EXAMPLE
    PS > $object | Count-Object -n 5; 
    Example returning last 5 objects from pipeline
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://www.tonymcgee.net/2013/11/powershell-profile-snippets/
    #>
    # cmdletbinding breaks default pipeline, and causes err:' The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or the input and its properties do not match any of the parameters that take pipeline input'
    #[CmdletBinding()]
    PARAM($Input) ;
    ($Input | Measure-Object).Count ;
}
#*------^ END Function Count-Object ^------