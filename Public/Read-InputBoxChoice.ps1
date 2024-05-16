# Read-InputBoxChoice.ps1

#*------v Function Read-InputBoxChoice v------
function Read-InputBoxChoice {
    <#
    .SYNOPSIS
    Read-InputBoxChoice - Prompt offering multiple selection options to users (uses `$host.ui). 
    .NOTES
    Version     : 0.0.1
    Author      : Dirk/DBremen
    Website     : https://powershellone.wordpress.com/
    Twitter     : 
    CreatedDate : 2024-05-11
    FileName    : Read-InputBoxChoice.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-Network
    Tags        : Powershell,Input,Prompt
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS   :
    * 4:47 PM 5/16/2024 add: CBH, param HelpMessages; added explicit return, but otherwise it's intact as posted.
    * 9/10/15 Dirk (powershellone.wordpress.com) posted Get-Choice()
    .DESCRIPTION
    Read-InputBoxChoice - Prompt offering multiple selection options to users (uses `$host.ui)

    Preceding a Choicelabel with an underscore will create a keyboard accelerator (_Undo will accelerate via Alt+U)

    .PARAMETER WindowTitle
    Title of the prompt window[-WindowTitle 'Title']
    .PARAMETER ChoiceLabels
    Label strings to be used on each choice (specify string array, one per desired label)[-ChoiceLabels 'Spring','Summer','Fall','Winter']
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object
    .EXAMPLE
    PS> $picked = Read-InputBoxChoice -WindowTitle 'Travel Planning' -ChoiceLabels 'Spring','Summer','Fall','Winter' ; 
    PS> write-host "Chose: $($picked)" ; 
    .LINK
    https://powershellone.wordpress.com/2015/09/10/a-nicer-promptforchoice-for-the-powershell-console-host/comment-page-1/
    https://gist.github.com/DBremen/73d7999094e7ac342ad6#file-get-choice-ps1
    https://github.com/tostka/verb-IO
    #>
    # [Alias('gclr')]
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,Position=0,HelpMessage = "Title of the prompt window[-WindowTitle 'Title']")]
            $WindowTitle,
        [Parameter(Mandatory=$true,Position=1,HelpMessage = "Label strings to be used on each choice (specify string array, one per desired label)[-ChoiceLabels 'Spring','Summer','Fall','Winter']")]
            [String[]]$ChoiceLabels,
        [Parameter(Position=2,HelpMessage = "ChoiceLabel to be selected by default[-DefaultChoice 1]")]
            $DefaultChoice = -1
    ) ;
    $assy = [System.AppDomain]::CurrentDomain.GetAssemblies(); 
    if($assy | ?{$_.ManifestModule -like 'System.Drawing*'}){} else { 
        Add-Type -AssemblyName System.Drawing
    } ; 
    if($assy | ?{$_.ManifestModule -like 'System.Windows.Forms*'}){} else { 
        Add-Type -AssemblyName System.Windows.Forms
    } ; 

    [System.Windows.Forms.Application]::EnableVisualStyles()   ; 
    $script:result = ""   ; 
    $form = New-Object System.Windows.Forms.Form ; 
    $form.FormBorderStyle = [Windows.Forms.FormBorderStyle]::FixedDialog   ;
    $form.BackColor = [Drawing.Color]::White   ;
    $form.TopMost = $True   ;
    $form.Text = $WindowTitle   ;
    $form.ControlBox = $False   ;
    $form.StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen   ;
    #calculate width required based on longest option text and form title
    $minFormWidth = 100   ;
    $formHeight = 44   ;
    $minButtonWidth = 70   ;
    $buttonHeight = 23   ;
    $buttonY = 12   ;
    $spacing = 10   ;
    $buttonWidth = [Windows.Forms.TextRenderer]::MeasureText((($ChoiceLabels | sort Length)[-1]),$form.Font).Width + 1   ;
    $buttonWidth = [Math]::Max($minButtonWidth, $buttonWidth)   ;
    $formWidth =  [Windows.Forms.TextRenderer]::MeasureText($WindowTitle,$form.Font).Width ;
    $spaceWidth = ($ChoiceLabels.Count+1) * $spacing   ;
    $formWidth = ($formWidth, $minFormWidth, ($buttonWidth * $ChoiceLabels.Count + $spaceWidth) | Measure-Object -Maximum).Maximum ;
    $form.ClientSize = New-Object System.Drawing.Size($formWidth,$formHeight)   ;
    $index = 0   ;
    #create the buttons dynamically based on the ChoiceLabels
    foreach ($option in $ChoiceLabels){
        Set-Variable "button$index" -Value (New-Object System.Windows.Forms.Button)   ; 
        $temp = Get-Variable "button$index" -ValueOnly   ; 
        $temp.Size = New-Object System.Drawing.Size($buttonWidth,$buttonHeight)   ; 
        $temp.UseVisualStyleBackColor = $True   ; 
        $temp.Text = $option   ; 
        $buttonX = ($index + 1) * $spacing + $index * $buttonWidth   ; 
        $temp.Add_Click({
            $script:result = $this.Text 
            $form.Close()   ; 
        })   ; 
        $temp.Location = New-Object System.Drawing.Point($buttonX,$buttonY)   ; 
        $form.Controls.Add($temp)   ; 
        $index++   ; 
    }   ; 
    $shownString = '$this.Activate()'   ; 
    if ($DefaultChoice -ne -1){
        $shownString += '(Get-Variable "button$($DefaultChoice-1)" -ValueOnly).Focus()'   ; 
    }   ; 
    $shownSB = [ScriptBlock]::Create($shownString)   ; 
    $form.Add_Shown($shownSB)   ; 
    [void]$form.ShowDialog()   ; 
    Return $result ; 
} ;
#*------^ END Function Read-InputBoxChoice ^------
