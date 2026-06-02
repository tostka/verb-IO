# get-RemainderTDO.ps1

#region GET_REMAINDERTDO ; #*------v get-RemainderTDO v------
function get-RemainderTDO {
    <#
    .SYNOPSIS
    get-RemainderTDO() - Calculate the Remainder of Number/Divisor (e.g. Modulus/Mod)
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2026-
    FileName    : get-RemainderTDO.ps1
    License     : MIT License
    Copyright   : (c) 2026 Todd Kadrie
    Github      : https://github.com/tostka/verb-dev
    Tags        : Powershell,Git,SourceControl,Diff,format
    AddedCredit : 
    AddedWebsite: 
    AddedTwitter: URL
    REVISIONS
    * 5:38 PM 6/2/2026init
    .DESCRIPTION
    get-RemainderTDO() - Calculate the Remainder of Number/Divisor (e.g. return the Modulus/Mod)    
    
    Simple wrapper of the [math]::ieeeremainder( $number,$devisor) function
    
    Although the moduls operator '%' : ($number % $divisor) should work, I find the ieeeremainder() to be more dependable. 
    Unfortunately it's an ugly/long command to contruct. 
    So wrap it with get-reminder -number 20 -divisor 5, 
    or even better use the gRmdr alias with positional params:
    
    if((gRmdr $xdots $dcLen) -eq 0){write-host -fore yellow "`n."}
    
    .PARAMETER number
    The number to be divided by the divisor
    .PARAMETER divisor
    The number to divide the number by
    .INPUTS
    Does not accept pipeline input.
    .OUTPUTS
    returns the calculated remainder of the number divided by the divisor 
    .EXAMPLE
    PS> if((grmdr $xdots $dcLen) -eq 0){
    PS>     write-host -fore yellow "`n."
    PS> }elseif((grmdr $xdots $dcInterv) -eq 0){
    PS>     write-host -fore yellow $xdots -nonewline
    PS> }else{
    PS>     write-host -nonewline -fore yellow "."
    PS> } ;
    Demo that enables git default pager interface (one page at a time, vs streamed)
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('gRmdr')]
    Param(
        [Parameter(Position=0,Helpmessage="The number to be divided by the divisor")]
            [int]$number,
        [Parameter(Position=1,Helpmessage="The number to divide the number by")]
            $divisor
    )
    [math]::ieeeremainder( $number,$divisor) | write-output  ; 
}
#endregion GET_REMAINDERTDO ; #*------^ END get-RemainderTDO ^------
