# Read-OpenFileDialog.ps1

#*------v Function Read-OpenFileDialog v------
function Read-OpenFileDialog {
    <#
    .SYNOPSIS
    Read-OpenFileDialog - Show an Open File Dialog and return the file selected by the user.
    .NOTES
    Version     : 0.0.1
    Author      : Daniel Schroeder
    Website     : https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/
    Twitter     : @deadlydog / https://twitter.com/deadlydog
    CreatedDate : 2024-05-10
    FileName    : Read-OpenFileDialog.ps1
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
    Read-OpenFileDialog - Show an Open File Dialog and return the file selected by the user.
    This is based on [a post the Scripting Guy made](http://blogs.technet.com/b/heyscriptingguy/archive/2009/09/01/hey-scripting-guy-september-1.aspx)
    .PARAMETER WindowTitle
    Title of the prompt window[-WindowTitle 'Title']
    .PARAMETER InitialDirectory
    Initial directory from which to browse[-InitialDirectory 'C:\']
    .PARAMETER Filter
    File filter[-Filter 'Text files (*.txt)|*.txt']
    .PARAMETER AllowMultiSelect
    Switch to permit selection of multiple files[-AllowMultiSelect]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> $filePath = Read-OpenFileDialog -WindowTitle "Select Text File Example" -InitialDirectory 'C:\' -Filter "Text files (*.txt)|*.txt" ; 
    PS> if (![string]::IsNullOrEmpty($filePath)) { Write-Host "You selected the file: $filePath" }
    PS> else { "You did not select a file." } ; 
    .LINK
    https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/  
    https://github.com/tostka/verb-IO
    #>
    # [Alias('gclr')]
    [CmdletBinding()]
    Param(
        <#
        [string]$InitialDirectory, 
        [string]$Filter = "All files (*.*)|*.*", 
        [switch]$AllowMultiSelect
        #>
        [Parameter(HelpMessage = "Title of the prompt window[-WindowTitle 'Title']")]
            [string]$WindowTitle,
        [Parameter(HelpMessage = "Initial directory from which to browse[-InitialDirectory 'C:\']")]
            [ValidateScript({Test-Path $_ -PathType 'Container'})]
            [string]$InitialDirectory, 
        [Parameter(HelpMessage = "File filter[-Filter 'Text files (*.txt)|*.txt']")]
            [string]$Filter = "All files (*.*)|*.*", 
        [Parameter(HelpMessage = "Switch to permit selection of multiple files[-AllowMultiSelect]")]
            [switch]$AllowMultiSelect
    )
    $assy = [System.AppDomain]::CurrentDomain.GetAssemblies(); 
    if($assy | ?{$_.ManifestModule -like 'System.Windows.Forms*'}){} else { 
        Add-Type -AssemblyName System.Windows.Forms
    } ; 
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog ; 
    $openFileDialog.Title = $WindowTitle ; 
    if (![string]::IsNullOrWhiteSpace($InitialDirectory)) { $openFileDialog.InitialDirectory = $InitialDirectory } ; 
    $openFileDialog.Filter = $Filter ; 
    if ($AllowMultiSelect) { $openFileDialog.MultiSelect = $true } ; 
    $openFileDialog.ShowHelp = $true    # Without this line the ShowDialog() function may hang depending on system configuration and running from console vs. ISE.
    $openFileDialog.ShowDialog() > $null ; 
    if ($AllowMultiSelect) { return $openFileDialog.Filenames } else { return $openFileDialog.Filename }    
} ;
#*------^ END Function Read-OpenFileDialog ^------
