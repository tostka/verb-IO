#*------v Function Get-ProductItems v------
function Get-ProductItems {
    <#
    .SYNOPSIS
    get-ProductItems.ps1 - Calculate Product of input items
    .NOTES
    Version     : 1.0.0
    Author      : Raoul Supercopter
    Website     :	https://stackoverflow.com/users/57123/raoul-supercopter
    CreatedDate : 2020-01-03
    FileName    : 
    License     : (none specified)
    Copyright   : (none specified)
    Github      : 
    Tags        : Powershell,Math
    REVISIONS
    17:10 1/3/2010 posted rev
    .DESCRIPTION
    get-ProductItems.ps1 - Calculate Product of input items
    .OUTPUTS
    System.Int32
    .EXAMPLE
    PS C:\> gci c:\*.* | get-ProductItems
    .LINK
    http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
    #>
    BEGIN { $x = 1 }
    PROCESS { $x *= $_ }
    END { $x }
}#*------^ END Function Get-ProductItems ^------
