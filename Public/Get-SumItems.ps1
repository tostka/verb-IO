#*------v Function Get-SumItems v------
function Get-SumItems {
    <#
    .SYNOPSIS
    Get-SumItems.ps1 - Sum input items
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
    * 12:37 PM 10/25/2021 rem'd req version
    12:29 PM 5/15/2013 revised
    17:10 1/3/2010 posted rev
    .DESCRIPTION
    Get-SumItems.ps1 - Sum input items
    .INPUTS
    stdin
    .OUTPUTS
    console/stdout System.Int32
    .EXAMPLE
    gci c:\*.* | get-SumItems
    .LINK
    http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
    #>
    ##requires -version 2
    BEGIN { $x = 0 }
    PROCESS { $x += $_ }
    END { $x }
} #*------^ END Function Get-SumItems ^------