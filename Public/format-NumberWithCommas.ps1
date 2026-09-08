# format-NumberWithCommas.ps1


#region FORMAT_NUMBERWITHCOMMAS ; #*------v format-NumberWithCommas v------
function format-NumberWithCommas {
    <#
    .SYNOPSIS
    Convert-TimeToIso8601DateString - Converts an [int], [long], [double] or [decimal] value to a string with appropriate hundreds/thousands/millions etc comma-places 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2026-09-08
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    REVISIONS
    * 12:12 PM 9/8/2026 ported internal function from vio\Convertj-NumbertoWords()
    .DESCRIPTION
    Convert-TimeToIso8601DateString - Converts an [int], [long], [double] or [decimal] value to a string with appropriate hundreds/thousands/millions etc comma-places 
    
    .PARAMETER Value
        Value to convert to place-marker string
    .INPUTS
    [int]
    [long]
    [double]
    [decimal]    
    .OUTPUTS
    [system.string] with asserted comma places markers.

    .EXAMPLE
    PS> $numbercommas = _format-NumberWithCommas -Value '100587.283' -verbose:($VerbosePreference -eq "Continue") ;
    PS> $numbercommas

        '100,587.283'
        
    demo    
    .LINK
    https://github.com/tostka/verb-io
    #>    
    PARAM(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Value to convert to place-marker string[-Value '100587.283']")]
            [object]$Value
    )            
    if ($Value -is [int] -OR $Value -is [long] -OR $Value -is [double] -OR $Value -is [decimal]) {
        return $Value.ToString('N0') ; 
    } ; 
    if ($Value -is [string]) {
        # To use a .NET TryParse method in PowerShell, you must pass the second argument by reference using the [ref] type accelerator. 
        # Because PowerShell maps both C# ref and out keywords to [ref], you must initialize the variable before passing it. 
        # 1. Initialize the output variable first
        $n = 0
        # 2. Call TryParse and cast the output variable with [ref]
        #if ([int]::TryParse("15", [ref]$n)) {
        if ([long]::TryParse($Value, [ref]$n)){
            return $n.ToString('N0')
        }
        if ([double]::TryParse($Value, [ref]$n)){
            #return $n.ToString('N2')
            # above asserts explit 2 decimal places, and 'N' does 1. use the -f function to assesrt variable number of decimal places
            # dyn the # of dec places
            $decplaces = ($n -split '\.')[1].length                    
            return ("{0:N$($decplaces)}" -f $n ); 
        }
    }
    throw "Value '$Value' is not a valid integer."
}
#endregion FORMAT_NUMBERWITHCOMMAS ; #*------^ END format-NumberWithCommas ^------

