#*------v Function Get-FolderSize2 v------
Function Get-FolderSize2 {
    <#
    .SYNOPSIS
    Get-FolderSize2.ps1 - Aggregate size of specified folder
    .NOTES
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    REVISIONS
    1:39 PM 6/18/2020 updated CBH
    .DESCRIPTION
    Get-FolderSize2.ps1 - Aggregate size of specified folder
    .PARAMETER Path
    Folder path to be aggregated
    .EXAMPLE
    PS C:\> gci c:\*.* | Get-FolderSize2
    .LINK
    http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
    #>
    Param ($Path) ;
    $Sizes = 0 ;
    ForEach ($Item in (Get-ChildItem $Path)) {
        If ($Item.PSIsContainer) { Get-FolderSize2 $Item.FullName }
        Else { $Sizes += $Item.Length } ;
    } ;
    [PSCustomObject]@{'Name' = $path; 'Size' = "{0:N2}" -f ($sizes / 1gb) };

} ;
#*------^ END Function Get-FolderSize2 ^------
