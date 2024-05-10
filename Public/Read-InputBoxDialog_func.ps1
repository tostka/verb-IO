# Read-InputBoxDialog.ps1

#*------v Function Read-InputBoxDialog v------
function Read-InputBoxDialog {
    <#
    .SYNOPSIS
    Read-InputBoxDialog - Prompt for single-line user input
    .NOTES
    Version     : 0.0.1
    Author      : Daniel Schroeder
    Website     : https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/
    Twitter     : @deadlydog / https://twitter.com/deadlydog
    CreatedDate : 2024-05-10
    FileName    : Read-InputBoxDialog.ps1
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
    Read-InputBoxDialog - Prompt for single-line user input
    .PARAMETER WindowTitle
    Title of the prompt window[-WindowTitle 'Title']
    .PARAMETER Message
    Prompt text shown above textbox and below title box[-Message 'Strings']
    .PARAMETER DefaultText
    Optional semple text to be pre-populated into the input box[-DefaultText 'Apple']
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> $textEntered = Read-InputBoxDialog -Message "Please enter the word 'Banana'" -WindowTitle "Input Box Example" -DefaultText "Apple"
    PS> if ($textEntered -eq $null) { Write-Host "You clicked Cancel" }
    PS> elseif ($textEntered -eq "Banana") { Write-Host "Thanks for typing Banana" }
    PS> else { Write-Host "You entered $textEntered" }    
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
        [Parameter(HelpMessage = "Optional semple text to be pre-populated into the input box[-DefaultText 'Apple']")]
            [string]$DefaultText
    )
    $assy = [System.AppDomain]::CurrentDomain.GetAssemblies(); 
    if($assy | ?{$_.ManifestModule -like 'Microsoft.VisualBasic*'}){} else { 
        Add-Type -AssemblyName Microsoft.VisualBasic
    } ; 
    return [Microsoft.VisualBasic.Interaction]::InputBox($Message, $WindowTitle, $DefaultText) 
} ;
#*------^ END Function Read-InputBoxDialog ^------
