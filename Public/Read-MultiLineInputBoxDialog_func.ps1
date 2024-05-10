# Read-MultiLineInputBoxDialog.ps1

#*------v Function Read-MultiLineInputBoxDialog v------
function Read-MultiLineInputBoxDialog {
    <#
    .SYNOPSIS
    Read-MultiLineInputBoxDialog - Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.
    .NOTES
    Version     : 0.0.1
    Author      : Daniel Schroeder
    Website     : https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/
    Twitter     : @deadlydog / https://twitter.com/deadlydog
    CreatedDate : 2024-05-10
    FileName    : Read-MultiLineInputBoxDialog.ps1
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
    Read-MultiLineInputBoxDialog - Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.
    (originally based on the code shown at http://technet.microsoft.com/en-us/library/ff730941.aspx)
    .PARAMETER Message
    The message to display to the user explaining what text we are asking them to enter.
    .PARAMETER WindowTitle
    The text to display on the prompt window's title.
    .PARAMETER DefaultText
    The default text to show in the input box.    
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object

    .EXAMPLE
    PS> $userText = Read-MultiLineInputDialog "Input some text please:" "Get User's Input"
    Shows how to create a simple prompt to get mutli-line input from a user.
    .EXAMPLE
    write-verbose 'Setup the default multi-line address to fill the input box with.' ; 
    PS> $defaultAddress = @'
    John Doe
    123 St.
    Some Town, SK, Canada
    A1B 2C3
    '@ ; 
    PS> $address = Read-MultiLineInputDialog "Please enter your full address, including name, street, city, and postal code:" "Get User's Address" $defaultAddress ; 
    if ($address -eq $null){Write-Error "You pressed the Cancel button on the multi-line input box."} ;
    Prompts the user for their address and stores it in a variable, pre-filling the input box with a default multi-line address.
    If the user pressed the Cancel button an error is written to the console.

    .EXAMPLE
    PS> $inputText = Read-MultiLineInputDialog -Message "If you have a really long message you can break it apart`nover two lines with the powershell newline character:" -WindowTitle "Window Title" -DefaultText "Default text for the input box."
    Shows how to break the second parameter (Message) up onto two lines using the powershell newline character (`n).
    If you break the message up into more than two lines the extra lines will be hidden behind or show ontop of the TextBox.    

    .EXAMPLE
    PS> $multiLineText = Read-MultiLineInputBoxDialog -Message "Please enter some text. It can be multiple lines" -WindowTitle "Multi Line Example" -DefaultText "Enter some text here..." ; 
    PS> if ($multiLineText -eq $null) { Write-Host "You clicked Cancel" }
    PS> else { Write-Host "You entered the following text: $multiLineText" }    
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
            [string]$DefaultText
    )
    $assy = [System.AppDomain]::CurrentDomain.GetAssemblies(); 
    if($assy | ?{$_.ManifestModule -like 'System.Drawing*'}){} else { 
        Add-Type -AssemblyName System.Drawing
    } ; 
    if($assy | ?{$_.ManifestModule -like 'System.Windows.Forms*'}){} else { 
        Add-Type -AssemblyName System.Windows.Forms
    } ; 
    
# Create the Label.
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Size(10,10) ; 
    $label.Size = New-Object System.Drawing.Size(280,20) ; 
    $label.AutoSize = $true ; 
    $label.Text = $Message ; 

    # Create the TextBox used to capture the user's text.
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Location = New-Object System.Drawing.Size(10,40) ; 
    $textBox.Size = New-Object System.Drawing.Size(575,200) ; 
    $textBox.AcceptsReturn = $true ; 
    $textBox.AcceptsTab = $false ; 
    $textBox.Multiline = $true ; 
    $textBox.ScrollBars = 'Both' ; 
    $textBox.Text = $DefaultText ; 

    # Create the OK button.
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Size(415,250) ; 
    $okButton.Size = New-Object System.Drawing.Size(75,25) ; 
    $okButton.Text = "OK" ; 
    $okButton.Add_Click({ $form.Tag = $textBox.Text; $form.Close() }) ; 

    # Create the Cancel button.
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Size(510,250) ; 
    $cancelButton.Size = New-Object System.Drawing.Size(75,25) ; 
    $cancelButton.Text = "Cancel" ; 
    $cancelButton.Add_Click({ $form.Tag = $null; $form.Close() }) ; 

    # Create the form.
    $form = New-Object System.Windows.Forms.Form ; 
    $form.Text = $WindowTitle ; 
    $form.Size = New-Object System.Drawing.Size(610,320) ; 
    $form.FormBorderStyle = 'FixedSingle' ; 
    $form.StartPosition = "CenterScreen" ; 
    $form.AutoSizeMode = 'GrowAndShrink' ; 
    $form.Topmost = $True ; 
    $form.AcceptButton = $okButton ; 
    $form.CancelButton = $cancelButton ; 
    $form.ShowInTaskbar = $true ; 

    # Add all of the controls to the form.
    $form.Controls.Add($label) ; 
    $form.Controls.Add($textBox) ; 
    $form.Controls.Add($okButton) ; 
    $form.Controls.Add($cancelButton) ; 

    # Initialize and show the form.
    $form.Add_Shown({$form.Activate()}) ; 
    $form.ShowDialog() > $null  # Trash the text of the button that was clicked.

    # Return the text that the user entered.
    return $form.Tag ; 
} ;
#*------^ END Function Read-MultiLineInputBoxDialog ^------
