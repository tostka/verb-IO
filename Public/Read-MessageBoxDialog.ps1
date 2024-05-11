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
    * 3:34 PM 5/11/2024 documented the -icon & -buttons enums, add validateset's for avail values
    * 4:45 PM 5/10/2024 add CBH; add param valid; pushed params into explicit block; added param Validation; shifted to OTB syntax; pretested type load; moved the examples into CBH 
    * 5/2/2013 - Daniel Schroeder posted vers
    .DESCRIPTION
    Read-MessageBoxDialog - Show message box popup and return the button clicked by the user.

    -Buttons param supports following options: 

    |Type | Enum | Desc |  
    |---|---|---|
    |AbortRetryIgnore |2|The message box contains Abort, Retry, and Ignore buttons.|
    |CancelTryContinue |6|Specifies that the message box contains Cancel, Try Again, and Continue buttons.|
    |OK |0|The message box contains an OK button.|
    |OKCancel |1|The message box contains OK and Cancel buttons.|
    |RetryCancel |5|The message box contains Retry and Cancel buttons.|
    |YesNo |4|The message box contains Yes and No buttons.|
    |YesNoCancel |3|The message box contains Yes, No, and Cancel buttons.|

    [MessageBoxButtons Enum (System.Windows.Forms) | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.messageboxbuttons?view=windowsdesktop-8.0)

    -Icon param supports following options: 

    |Type | Enum | Desc |
    |---|---|---|
    |Asterisk |64|The message box contains a symbol consisting of a lowercase letter i in a circle.|
    |Error |16|The message box contains a symbol consisting of white X in a circle with a red background.|
    |Exclamation |48|The message box contains a symbol consisting of an exclamation point in a triangle with a yellow background.|
    |Hand |16|The message box contains a symbol consisting of a white X in a circle with a red background.|
    |Information |64|The message box contains a symbol consisting of a lowercase letter i in a circle.|
    |None |0|The message box contains no symbols.|
    |Question |32|The message box contains a symbol consisting of a question mark in a circle. The question mark message icon is no longer recommended because it does not clearly represent a specific type of message and because the phrasing of a message as a question could apply to any message type. In addition, users can confuse the question mark symbol with a help information symbol. Therefore, do not use this question mark symbol in your message boxes. The system continues to support its inclusion only for backward compatibility.|
    |Stop |16|The message box contains a symbol consisting of white X in a circle with a red background.|
    |Warning |48|The message box contains a symbol consisting of an exclamation point in a triangle with a yellow background.| 

    [MessageBoxIcon Enum (System.Windows.Forms) | Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.messageboxicon?view=windowsdesktop-8.0)   

    .PARAMETER WindowTitle
    Title of the prompt window[-WindowTitle 'Title']
    .PARAMETER Message
    Prompt text shown above textbox and below title box[-Message 'Strings']
    .PARAMETER Buttons
    Specifies Button combo to display (AbortRetryIgnore|CancelTryContinue|OK|OKCancel|RetryCancel|YesNo|YesNoCancel)[-Buttons 'OKCancel']
    .PARAMETER Icon
    Specifies Form Icon to display (Asterisk|Exclamation|Hand|Information|Question|Warning|None*) [-Icon Exclamation]
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
        [Parameter(HelpMessage = "Specifies Button combo to display (AbortRetryIgnore|CancelTryContinue|OK|OKCancel|RetryCancel|YesNo|YesNoCancel)[-Buttons 'OKCancel']")]
            [ValidateSet('AbortRetryIgnore','CancelTryContinue','OK','OKCancel','RetryCancel','YesNo','YesNoCancel')]
            [System.Windows.Forms.MessageBoxButtons]$Buttons = [System.Windows.Forms.MessageBoxButtons]::OK,
        [Parameter(HelpMessage = "Specifies Form Icon to display (Asterisk|Exclamation|Hand|Information|Question|Warning|None*) [-Icon Exclamation]")]
            [ValidateSet('Asterisk','Exclamation','Hand','Information','Question','Warning')]
            [System.Windows.Forms.MessageBoxIcon]$Icon = [System.Windows.Forms.MessageBoxIcon]::None
    )
    $assy = [System.AppDomain]::CurrentDomain.GetAssemblies(); 
    if($assy | ?{$_.ManifestModule -like 'System.Windows.Forms*'}){} else { 
        Add-Type -AssemblyName System.Windows.Forms
    } ; 
    Return [System.Windows.Forms.MessageBox]::Show($Message, $WindowTitle, $Buttons, $Icon) ; 
} ;
#*------^ END Function Read-MessageBoxDialog ^------
