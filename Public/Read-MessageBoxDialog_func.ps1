# Read-MessageBoxDialog.ps1

#*------v Function Read-MessageBoxDialog v------
function Read-MessageBoxDialog {
    <#
    .SYNOPSIS
    Read-MessageBoxDialog - Show message box popup and return the button clicked by the user.
    .NOTES
    Version     : 0.0.1
    Author      : Daniel Schroeder
    Website     : https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/
    Twitter     : @deadlydog / https://twitter.com/deadlydog
    CreatedDate : 2024-05-10
    FileName    : Read-MessageBoxDialog.ps1
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
    Read-MessageBoxDialog - Show message box popup and return the button clicked by the user.
    .PARAMETER WindowTitle
    Title of the prompt window[-WindowTitle 'Title']
    .PARAMETER Message
    Prompt text shown above textbox and below title box[-Message 'Strings']
    .PARAMETER Buttons
    Specifies Button combo to display (OK|OKCancel)[-Buttons 'OKCancel']
    .PARAMETER Icon
    Specifies Form Icon to display (defaults MessageBoxIcon) [-Icon]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> $buttonClicked = Read-MessageBoxDialog -Message "Please press the OK button." -WindowTitle "Message Box Example" -Buttons OKCancel -Icon Exclamation ; 
    PS> if ($buttonClicked -eq "OK") { Write-Host "Thanks for pressing OK" }
    PS> else { Write-Host "You clicked $buttonClicked" } ; 
    Demo simple OK/Cancel prompt.   
    .LINK
    https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/  
    https://github.com/tostka/verb-IO
    #>
    # [Alias('gclr')]
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = "Title of the prompt window[-WindowTitle 'Title']")]
            [string]$WindowTitle,
        [Parameter(HelpMessage = "Prompt text shown above textbox and below title box[-Message 'Strings']")]
            [string]$Message,
        [Parameter(HelpMessage = "Specifies Button combo to display (OK|OKCancel)[-Buttons 'OKCancel']")]
            [System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK,
        [Parameter(HelpMessage = "Specifies Form Icon to display (defaults MessageBoxIcon) [-Icon]")]
            [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None
    )
    $assy = [System.AppDomain]::CurrentDomain.GetAssemblies(); 
    if($assy | ?{$_.ManifestModule -like 'System.Windows.Forms*'}){} else { 
        Add-Type -AssemblyName System.Windows.Forms
    } ; 
    Return [System.Windows.Forms.MessageBox]::Show($Message, $WindowTitle, $Buttons, $Icon) ; 
} ;
#*------^ END Function Read-MessageBoxDialog ^------
