#*------v Function Get-CountItems v------
function Get-CountItems {
    <#
    .SYNOPSIS
    Get-CountItems.ps1 - Count input items
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
    Get-CountItems.ps1 - Count input items
    .OUTPUTS
    System.Int32
    .EXAMPLE
    PS C:\> gci c:\*.* | get-CountItems
    .LINK
    http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
    #>
    BEGIN { $x = 0 }
    PROCESS { $x += 1 }
    END { $x }

} #*------^ END Function Get-CountItems ^------
