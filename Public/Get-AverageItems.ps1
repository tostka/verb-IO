#*------v Function Get-AverageItems v------
function Get-AverageItems {
    <#
    .SYNOPSIS
    Get-AverageItems.ps1 - Avg input items
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
    12:29 PM 5/15/2013 revised
    17:10 1/3/2010 posted rev
    .DESCRIPTION
    Get-AverageItems.ps1 - Avg input items
    .INPUTS
    stdin
    .OUTPUTS
    System.Int32
    .EXAMPLE
    PS C:\> gci c:\*.* | get-AverageItems
    .LINK
    http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
    #>
    BEGIN { $max = 0; $curr = 0 }
    PROCESS { $max += $_; $curr += 1 }
    END { $max / $curr }
} #*------^ END Function Get-AverageItems ^------
