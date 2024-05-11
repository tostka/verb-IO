# Read-PasswordInputBoxDialog.ps1

#*------v Function Read-PasswordInputBoxDialog v------
function Read-PasswordInputBoxDialog {
    <#
    .SYNOPSIS
    Read-PasswordInputBoxDialog - Prompts the user with a secure Password input box and returns the entered string as a SecureString
    .NOTES
    Version     : 0.0.1
    Author      : Iris K
    Website     : https://techadviz.com/author/iriskim000/
    Twitter     : 
    CreatedDate : 2024-05-11
    FileName    : Read-PasswordInputBoxDialog.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-Network
    Tags        : Powershell,Input,Prompt
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS   :
    * 4:14 PM 5/11/2024 Tweaked version of Iris K's original: Added CBH, converted to full func with defaulted input parameters ; 
        added test & load missing Types; onclick close, conversion to [securestring], and return of the obj; try catch conversion, blank inputs before exit
    * * 1/29/22 Iris K posted demo
    .DESCRIPTION
    Read-PasswordInputBoxDialog - Prompts the user with a secure Password input box and returns the entered string as a SecureString
    .PARAMETER Message
    The message to display to the user explaining what text we are asking them to enter.
    .PARAMETER WindowTitle
    The text to display on the prompt window's title.
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object

    .EXAMPLE
    PS> $pw = Read-PasswordInputBoxDialog ; 
    PS> $smsg = "$($pw.length) character Password entered" ; 
    PS> $smsg += "`nPlainText: $([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pw)))" ;  
    PS> write-host $smsg ; 
    Demo obtaining password from user, returned as a securestring, and converting the SecureString back to plain text.
    .LINK
    https://techadviz.com/author/iriskim000/
    https://github.com/tostka/verb-IO
    #>
    # [Alias('gclr')]
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = "Title of the prompt window (defaults to 'Validate')[-WindowTitle 'Title']")]
            [string]$WindowTitle = 'Password request',
        [Parameter(HelpMessage = "Prompt text shown above textbox and below title box[-Message 'Strings']")]
            [string]$Message = 'Enter Password :'
    )
    $assy = [System.AppDomain]::CurrentDomain.GetAssemblies(); 
    if($assy | ?{$_.ManifestModule -like 'System.Drawing*'}){} else { 
        Add-Type -AssemblyName System.Drawing
    } ; 
    if($assy | ?{$_.ManifestModule -like 'System.Windows.Forms*'}){} else { 
        Add-Type -AssemblyName System.Windows.Forms
    } ; 
    
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(50,50)
    $label.Size = New-Object System.Drawing.Size(200,20)
    $label.Text = $Message ; 

    # Password Input
    $password = New-Object Windows.Forms.MaskedTextBox
    $password.Size = New-Object System.Drawing.Size(200,20)
    $password.PasswordChar = '*'
    $password.Top  = 50
    $password.Left = 200

    # OK Button
    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Size = New-Object System.Drawing.Size(100,30)
    $OKButton.Top  = 100
    $OKButton.Left = 250
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $okButton.Add_Click({ $form.Tag = $password.Text; $form.Close() }) ; 
    
    # Create the form.
    
    $form = New-Object System.Windows.Forms.Form
    # Title
    $form.Text = $WindowTitle
    $form.Size = New-Object System.Drawing.Size(500,200)
    $form.StartPosition = 'CenterScreen'
    $form.AutoSize = $true

    # Add all of the controls to the form.
    $form.Controls.Add($label)
    $form.Controls.Add($password)
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)


    # Initialize and show the form.
    #$form.Add_Shown({$form.Activate()}) ; 
    #$form.ShowDialog() > $null  # Trash the text of the button that was clicked.

    # Show Form
    $form.Add_Shown({$form.Activate()}) ; 
    $res = $form.ShowDialog()

    if ($res -eq 'OK' -AND $form.Tag ){
        TRY{ 
            # convert entered masked text to [securestring], clear the plaintext entry fields, & return the securestring.
            $SecurePassword = $form.Tag  | ConvertTo-SecureString -AsPlainText -Force -ErrorAction STOP ;
            $password.text = $form.Tag = $null ; 
            Write-Host "$($SecurePassword.length) character Password Entered"
            #$Form.Tag can be used for validation logic
            Return $SecurePassword
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            write-warning $smsg ;
        } ; 
    } ; 
} ;
#*------^ END Function Read-PasswordInputBoxDialog ^------
