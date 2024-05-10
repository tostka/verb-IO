# Read-FolderBrowserDialog.ps1

#*------v Function Read-FolderBrowserDialog v------
function Read-FolderBrowserDialog {
    <#
    .SYNOPSIS
    Read-FolderBrowserDialog - Show an Open Folder Dialog and return the directory selected by the user.
    .NOTES
    Version     : 0.0.1
    Author      : Daniel Schroeder
    Website     : https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/
    Twitter     : @deadlydog / https://twitter.com/deadlydog
    CreatedDate : 2024-05-10
    FileName    : Read-FolderBrowserDialog.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-Network
    Tags        : Powershell,Input,Prompt
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS   :
    * 4:45 PM 5/10/2024 add CBH; add param valid; pushed params into explicit block; added param Validation; shifted to OTB syntax; pretested type load; moved the examples into CBH 
    * 5/2/2013 - Daniel Schroeder posted vers
    .DESCRIPTION
    Read-FolderBrowserDialog - Show an Open Folder Dialog and return the directory selected by the user.
    This is based on [a post the Scripting Guy made](http://blogs.technet.com/b/heyscriptingguy/archive/2009/09/01/hey-scripting-guy-september-1.aspx)
    .PARAMETER Message
    Prompt text shown above textbox and below title box[-Message 'Strings']
    .PARAMETER InitialDirectory
    Initial directory from which to browse[-InitialDirectory 'C:\']
    .PARAMETER NoNewFolderButton
    Switch to suppress display of the New Folder creation button[-NoNewFolderButton]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> $directoryPath = Read-FolderBrowserDialog -Message "Please select a directory" -InitialDirectory 'C:\' -NoNewFolderButton ; 
    PS> if (![string]::IsNullOrEmpty($directoryPath)) { Write-Host "You selected the directory: $directoryPath" }
    PS> else { "You did not select a directory." } ; 
    .LINK
    https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/  
    https://github.com/tostka/verb-IO
    #>
    # [Alias('gclr')]
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = "Prompt text shown above textbox and below title box[-Message 'Strings']")]
            [string]$Message,
        [Parameter(HelpMessage = "Initial directory from which to browse[-InitialDirectory 'C:\']")]
            [ValidateScript({Test-Path $_ -PathType 'Container'})]
            [string]$InitialDirectory, 
        [Parameter(HelpMessage = "Switch to suppress display of the New Folder creation button[-NoNewFolderButton]")]
            [switch]$NoNewFolderButton
    )
    $browseForFolderOptions = 0 ; 
    if ($NoNewFolderButton) { $browseForFolderOptions += 512 } ; 
    $app = New-Object -ComObject Shell.Application ; 
    $folder = $app.BrowseForFolder(0, $Message, $browseForFolderOptions, $InitialDirectory) ; 
    if ($folder) { $selectedDirectory = $folder.Self.Path } else { $selectedDirectory = '' } ; 
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($app) > $null ; 
    return $selectedDirectory ;   
} ;
#*------^ END Function Read-FolderBrowserDialog ^------
