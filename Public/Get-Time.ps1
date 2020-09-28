#*------v Function Get-Time v------
function Get-Time {
    <#
    .SYNOPSIS
    Ouptuts current MM/DD/YYYY HH:MM:SS [AM/PM] time
    .EXAMPLE
    PS C:\> get-time
    .OUTPUTS
    System.String
    #>
    return $(get-date | foreach { $_.ToLongTimeString() } )
}
#*------^ END Function Get-Time ^------