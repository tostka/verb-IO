#*------v Filter ConvertFrom-CmdList v------
filter ConvertFrom-CmdList {
    <#
    .SYNOPSIS
    ConvertFrom-CmdList - a filter that converts the returned data to objects (from comment on the main post)
    .NOTES
    Author: Axel Andersen
    Website:	http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 8:14 AM 11/24/2020 fixed CBH ref's to proper function
    * 8:35 AM 4/18/2017 getting null object Add-Member errors, so add a null test mid-foreach loop
    * 7:42 AM 4/18/2017 tweaked, added pshelp, comments etc, put into OTB
    * December 8, 2010 at 1:24 pmposted version
    .DESCRIPTION
    .INPUTS
    Pipeline
    .OUTPUTS
    Returns object for the matched task(s)
    .EXAMPLE
    schtasks.exe /query /s $ComputerName /FO List | ConvertFrom-CmdList
    .LINK
    http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    #>
    # 8:35 AM 4/18/2017 getting null object Add-Member errors, so add a null test mid-foreach loop
    $_ | foreach {
        if ($_ -match '^$') {
            $newobj = New-Object Object
            $obj | foreach {
                if ($_ -eq $null) {
                    # drop null properties
                }
                else {
                    $newobj | Add-Member NoteProperty $($_ -split ':')[0] "$($_ -replace '^.*:[ ]+')"
                } ;
            }
            $newobj
            $obj = @()
        }
        if ($_ -notmatch '^$') { $obj += $_ } ;
    }
}#*------^ END Filter ConvertFrom-CmdList ^------