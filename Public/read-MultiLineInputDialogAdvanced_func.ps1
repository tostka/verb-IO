#*------v read-MultiLineInputDialogAdvanced.ps1 v------

#*------v Function read-MultiLineInputDialogAdvanced v------
function read-MultiLineInputDialogAdvanced {
    <#
    .SYNOPSIS
    read-MultiLineInputDialogAdvanced - Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.
    .NOTES
    Version     : 0.0.2
    Author      : iAvoe
    Website     : https://github.com/iAvoe
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2024-05-10
    FileName    : read-MultiLineInputDialogAdvanced.ps1
    License     : Mozilla Public License 2.0
    Copyright   : (c) 2024 Todd Kadrie
    Github      : https://github.com/tostka/verb-Network
    Tags        : Powershell,Input,Prompt
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS   :
    * 4:45 PM 5/10/2024 add CBH; add param valid; pushed params into explicit block; added param Validation; shifted to OTB syntax; moved the examples into CBH (refactored as more readable splats); consolidated param test code into simpler -match comparisons; 
    * 10/16/23 - iAvoe posted vers
    .DESCRIPTION
    read-MultiLineInputDialogAdvanced - Prompts the user with a multi-line input box and returns the text they enter, or null if they cancelled the prompt.

    Note: 
    - Appears to be a DPI-aware extension of Daniel Schroeder's original 5/2/2013 Read-MultiLineInputBoxDialog() (his name appears in the first comment). 
        from: [PowerShell Multi-Line Input Box Dialog, Open File Dialog, Folder Browser Dialog, Input Box, and Message Box - Daniel Schroeder’s Programming Blog](https://blog.danskingdom.com/powershell-multi-line-input-box-dialog-open-file-dialog-folder-browser-dialog-input-box-and-message-box/)
    (Cites C#, but visibly, what it's doing on that front is leveaging common system API calls)

    Supports a couple of input modes: InboxType:
        str (alias '1') : Default MultiLine Input Dialog; 
        dnd (alias '2') : Drag & Drop (files selection) MultiLine Path Input Dialog
    And a couple of data return formats:ReturnType:
        str (alias '1') :Return a single multi-line string of the inputs, empty lines are scrubbed; 
        ary (alias '2') :Return the input split into an array of lines, empty array items are scrubbed

    
    - Displays correctly on both Low & high DPI display
    - Built-in empty-line scrubbing feature, only return valid lines
    - Automatically scales window size according to monitor resolution
    - Automatically compensates rendering error inbetween PowerShell Console & ISE
    - -FixSquareBrkts Option to escape square brackes (\``[, \``]) so permits cmdlets that have issues with [] charas in path names, can function (get-childitem, get-item)
     
    - ESC key → Cancel key binding
    - (List-Box Mode) DEL key → Remove selected item feature

    .PARAMETER WindowTitle
    Title of the prompt window[-WindowTitle 'Title']
    .PARAMETER Message
    Prompt text shown above textbox and below title box[-Message 'Strings']
    .PARAMETER InboxType
    InboxType (str|1: Default MultiLine Input Dialog; dnd|2:Drag & Drop MultiLine Path Input Dialog)[-InboxType txt]
    .PARAMETER FontSize
    Default textbox font size[-FontSize 12]
    .PARAMETER ReturnType
    ReturnType (str|1:Return a multi-line string of items, empty lines are scrubbed; ary|2:Return an array of items, empty array items are scrubbed)[-ReturnType str]
    .PARAMETER ShowDebug
    ShowDebug[-ShowDebug `$true]
    .PARAMETER FixSquareBrkts
    Escapes square brackes (\``[, \``]) to permit cmdlets that won't accomodate path '[]' chars, to function[-FixSquareBrkts `$true]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Collections.Hashtable
    .EXAMPLE
PS> write-verbose 'Always pre-Enable DPI-Aware Windows Forms' ; 
PS> TRY{[ProcessDPI] | out-null }catch{
PS>     Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public class ProcessDPI {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SetProcessDPIAware();      
}
'@ 
    PS> } ; 
    PS> $null = [ProcessDPI]::SetProcessDPIAware() ; 
    PS> write-verbose "Normal Prompting (allows empty output) - Textbox mode - String output" ; 
    PS> $pltRdMLIDA=[ordered]@{
    PS>     Message = "Put your text items here, separated by line breaks`nThis box allows up to 2 lines of text for extra notes" ;
    PS>     WindowTitle = "Prompt: (Textbox: String return)" ;
    PS>     InboxType = "txt" ;
    PS>     ReturnType = "str" ;
    PS>     ShowDebug = $true ;
    PS> } ;
    PS> $smsg = "read-MultiLineInputDialogAdvanced w`n$(($pltRdMLIDA|out-string).trim())" ; 
    PS> write-host -foregroundcolor green $smsg  ;
    PS> $mLineVarStrA = read-MultiLineInputDialogAdvanced @pltRdMLIDA ; 
    PS> write-host "`r`n-----Return-String:`r`n"+$mLineVarStrA+"`r`n-----End of Return" ; 
    Demo spawning a text box form, with string return ; 

    .EXAMPLE
    PS> write-verbose 'Always pre-Enable DPI-Aware Windows Forms' ; 
    PS> TRY{[ProcessDPI] | out-null }catch{
    PS>     Add-Type -TypeDefinition @'
    using System.Runtime.InteropServices;
    public class ProcessDPI {
        [DllImport("user32.dll", SetLastError=true)]
        public static extern bool SetProcessDPIAware();      
    }
    '@ 
    PS> } ; 
    PS> $null = [ProcessDPI]::SetProcessDPIAware() ; 
    PS> write-verbose "Normal Prompting (allows empty output) - Textbox mode - String output; escape any square brackets returned" ; 
    PS> $pltRdMLIDA=[ordered]@{
    PS>     Message = "Put your text items here, separated by line breaks`nThis box allows up to 2 lines of text for extra notes" ;
    PS>     WindowTitle = "Prompt:" ;
    PS>     InboxType = "txt" ;
    PS>     ReturnType = "str" ;
    PS>     FixSquareBrkts = $true ; 
    PS>     ShowDebug = $true ;
    PS> } ;
    PS> $smsg = "read-MultiLineInputDialogAdvanced w`n$(($pltRdMLIDA|out-string).trim())" ; 
    PS> write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)"  ;
    PS> $mLineVarStrB = read-MultiLineInputDialogAdvanced @pltRdMLIDA ; 
    PS> write-host "`r`n-----Return-String:`r`n"+$mLineVarStrB+"`r`n-----End of Return" ; 
    Demo spawning a text box form, with string return, and any square brackets in the return are escaped ; 

    .EXAMPLE
    PS> write-verbose 'Always pre-Enable DPI-Aware Windows Forms' ; 
    PS> TRY{[ProcessDPI] | out-null }catch{
    PS>     Add-Type -TypeDefinition @'
    using System.Runtime.InteropServices;
    public class ProcessDPI {
        [DllImport("user32.dll", SetLastError=true)]
        public static extern bool SetProcessDPIAware();      
    }
    '@ 
    PS> } ; 
    PS> $null = [ProcessDPI]::SetProcessDPIAware() ; 
    PS> write-verbose "Normal Prompting (allows empty output) - Drag & drop mode - String output" ; 
    PS> $pltRdMLIDA=[ordered]@{
    PS>     Message = "Drag each of your file items here`nThis box allows up to 2 lines of text for extra notes" ;
    PS>     WindowTitle = "Prompt: (Drag&drop mode)" ;
    PS>     InboxType = "dnd" ;
    PS>     ReturnType = "str" ;
    PS>     ShowDebug = $true ;
    PS> } ;
    PS> $smsg = "read-MultiLineInputDialogAdvanced w`n$(($pltRdMLIDA|out-string).trim())" ; 
    PS> write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)"  ;
    PS> $dDropVarStr = read-MultiLineInputDialogAdvanced @pltRdMLIDA ; 
    PS> write-host "`r`n-----Return-String:`r`n"+$dDropVarStr+"`r`n-----End of Return" ; 
    Demo drag & drop file prompt, with string output

    .EXAMPLE
    PS> write-verbose 'Always pre-Enable DPI-Aware Windows Forms' ; 
    PS> TRY{[ProcessDPI] | out-null }catch{
    PS>     Add-Type -TypeDefinition @'
    using System.Runtime.InteropServices;
    public class ProcessDPI {
        [DllImport("user32.dll", SetLastError=true)]
        public static extern bool SetProcessDPIAware();      
    }
    '@ 
    PS> } ; 
    PS> $null = [ProcessDPI]::SetProcessDPIAware() ; 
    PS> write-verbose "Normal Prompting (allows empty output) - Drag & drop mode - Array output" ; 
    PS> $pltRdMLIDA=[ordered]@{
    PS>     Message = "Drag each of your file items here`nThis box allows up to 2 lines of text for extra notes" ;
    PS>     WindowTitle = "Prompt: (Drag&drop mode)" ;
    PS>     InboxType = "dnd" ;
    PS>     ReturnType = "2" ;
    PS>     ShowDebug = $true ;
    PS> } ;
    PS> $smsg = "read-MultiLineInputDialogAdvanced w`n$(($pltRdMLIDA|out-string).trim())" ; 
    PS> write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)"  ;
    PS> $dDropVarAry = read-MultiLineInputDialogAdvanced @pltRdMLIDA ; 
    PS> 
    PS> if($dDropVarAry.Count -lt 25){
    PS>     $smsg = "Return-Array:`r`n"
    PS>     $smsg += "`n$(($dDropVarAry|out-string).trim())" ; 
    PS>     $smsg += "`nEnd of return" ; 
    PS> } else { 
    PS>     $smsg = "`r`n-----First item of array:"
    PS>     if ($dDropVarAry.Count -gt 0) {
    PS>         $smsg += "`n$($dDropVarAry[0])" ; 
    PS>     }  else {
    PS>         $smsg += "`n× Array length == 0, skipped" ; 
    PS>     }
    PS>     $smsg += "`n-----Last item of array:" ; 
    PS>     if ($dDropVarAry.Count -gt 0) {
    PS>         $smsg += "`n$($dDropVarAry[-1])" ; 
    PS>     } else {
    PS>         $smsg += "`r`n× Array length == 0, skipped";
    PS>     };
    PS>     $smsg += "`n`-----Counting items of array: $($dDropVarAry.Count)" ; 
    PS> } ; 
    PS> write-host $smsg ; 
    PS> 
    Demo drag & drop file prompt, with array output    
    .LINK
    https://github.com/iAvoe/Multi-Line-Input-Dialog-Advanced/blob/main/MultiLine-Input-Dialog-Advanced.ps1    
    https://github.com/tostka/verb-IO
    #>
    # [Alias('gclr')]
    [CmdletBinding()]
    Param(
        [Parameter(HelpMessage = "Title of the prompt window[-WindowTitle 'Title']")]
            [string]$WindowTitle,
        [Parameter(HelpMessage = "Prompt text shown above textbox and below title box[-Message 'Strings']")]
            [string]$Message,
        [Parameter(HelpMessage = "InboxType (str|1: Default MultiLine Input Dialog; dnd|2:Drag & Drop MultiLine Path Input Dialog)[-InboxType txt]")]
            [ValidateSet("1","2","txt","dnd")]
            [string]$InboxType="txt",
        [Parameter(HelpMessage = "Default textbox font size[-FontSize 12]")] 
            [int]$FontSize=12, 
        [Parameter(HelpMessage = "ReturnType (str|1:Return a multi-line string of items, empty lines are scrubbed; ary|2:Return an array of items, empty array items are scrubbed)[-ReturnType str]")]
            [ValidateSet("1","2","str","ary")]
            [string]$ReturnType="str", 
        [Parameter(HelpMessage = "ShowDebug[-ShowDebug `$true]")]
            [switch]$ShowDebug=$false, 
        [Parameter(HelpMessage = "Escapes square brackes (\``[, \``]) to permit cmdlets that won't accomodate path '[]' chars, to function[-FixSquareBrkts `$true]")]
            [switch]$FixSquareBrkts
    )
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    #「@Daniel Schroeder」
    $DebugPreference = 'Continue'
    if (($host.name -match 'consolehost')) {
        if ($ShowDebug -eq $true) {Write-Debug "Running inside PowerShell Console, using resolution data from GWMI"}
        $oWidth  = gwmi win32_videocontroller | select-object CurrentHorizontalResolution -first 1
        $oHeight = gwmi win32_videocontroller | select-object CurrentVerticalResolution -first 1
        [int]$mWidth  = [Convert]::ToInt32($oWidth.CurrentHorizontalResolution)
        [int]$mHeight = [Convert]::ToInt32($oHeight.CurrentVerticalResolution)
        #Write-Debug "$mWidth x $mHeight"
    } else {
        if ($ShowDebug -eq $true) {Write-Debug "Running inside PowerShell ISE, using resolution data from SysInfo"}
        [int]$mWidth  = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width
        [int]$mHeight = [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height
    }

    $assy = [System.AppDomain]::CurrentDomain.GetAssemblies(); 
    if($assy | ?{$_.ManifestModule -like 'System.Drawing*'}){} else { 
        Add-Type -AssemblyName System.Drawing
    } ; 
    if($assy | ?{$_.ManifestModule -like 'System.Windows.Forms*'}){} else { 
        Add-Type -AssemblyName System.Windows.Forms
    } ; 

    #Converting from monitor resolution: position of window label text
    [int]$LBStartX = [math]::Round($mWidth /192)
    [int]$LBStartY = [math]::Round($mHeight/108)
    [int]$LblSizeX = [math]::Round($mWidth /19)
    [int]$LblSizeY = [math]::Round($mHeight/54)
    #Label text under the GUI title, with content from $Message
    $label = New-Object System.Windows.Forms.Label -Property @{
        AutoSize = $true
        Text     = $Message
        Location = New-Object System.Drawing.Size($LBStartX,$LBStartY) #Label text starting position
        Size     = New-Object System.Drawing.Size($LblSizeX,$LblSizeY) #Label text box size
    }
    #Converting from monitor resolution: position & size of input textbox & listbox
    [int]$LBStartX = [int]$TBStartX = [math]::Round($mWidth /192)
    [int]$LBStartY = [int]$TBStartY = [math]::Round($mHeight/27)
    [int]$TblSizeX = [math]::Round($mWidth /3.728)
    [int]$LblSizeX = [math]::Round($mWidth /3.792)
    [int]$LblSizeY = [int]$TblSizeY = [math]::Round($mHeight/2.6)
    if (($host.name -match 'consolehost')) {$TblSizeX-=3; $LblSizeX-=3} #Compensate width rendering difference in PowerShell Console
    
    #Drawing textbox 1 / listbox 2
    if     (($InboxType -eq "txt") -or ($InboxType -eq "1")) {
        $textBox          = New-Object System.Windows.Forms.TextBox -Property @{
            Location      = New-Object System.Drawing.Size($TBStartX,$TBStartY) #Draw starting postiton
            Size          = New-Object System.Drawing.Size($TblSizeX,$TblSizeY) #Size of textbox
            Font          = New-Object System.Drawing.Font((New-Object System.Windows.Forms.Form).font.Name,$FontSize)
            AcceptsReturn = $true
            AcceptsTab    = $false
            Multiline     = $true
            ScrollBars    = 'Both'
            Text          = "" #Leave default text blank in order to check if user has typed / pasted nothing and (accidentally) clicks OK, which can mitigated userby Do-While loop checking and prevents a script startover of frustration
        }
    } elseif (($InboxType -eq "dnd") -or ($InboxType -eq "2")) {
        $listBox = New-Object Windows.Forms.ListBox -Property @{
            Location            = New-Object System.Drawing.Size($LBStartX,$LBStartY) #Draw starting postiton
            Size                = New-Object System.Drawing.Size($LblSizeX,$LblSizeY) #Size of textbox
            Font                = New-Object System.Drawing.Font((New-Object System.Windows.Forms.Form).font.Name,$FontSize)
            Anchor              = ([System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Top)
            AutoSize            = $true
            IntegralHeight      = $false
            AllowDrop           = $true
            ScrollAlwaysVisible = $false
        }
        #Create Drag-&-Drop events with effects to actually get the GUI working, not the copy-to-CLI side
        $listBox_DragOver = [System.Windows.Forms.DragEventHandler]{
	        if ($_.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) {$_.Effect = 'Copy'}                       #$_=[System.Windows.Forms.DragEventArgs]
	        else                                                               {$_.Effect = 'None'}
        }
        $listBox_DragDrop = [System.Windows.Forms.DragEventHandler]{
	        foreach ($filename in $_.Data.GetData([Windows.Forms.DataFormats]::FileDrop)) {$listBox.Items.Add($filename)} #$_=[System.Windows.Forms.DragEventArgs]
        }
        #Create "Delete" keydown event to delete selected items in listBox mode
        $listBox.Add_KeyDown({
            if (($PSItem.KeyCode -eq "Delete") -and ($listBox.Items.Count -gt 0)) {$listBox.Items.Remove($listBox.SelectedItems[0])}
        })
    }
    #Converting from monitor resolution: OK button's starting position & size
    [int]$OKStartX = [math]::Round($mWidth /4.7)
    [int]$OKStartY = [math]::Round($mHeight/108)
    [int]$OKbSizeX = [math]::Round($mWidth /34.92)
    [int]$OKbSizeY = [math]::Round($mHeight/47)
    if (($host.name -match 'consolehost')) {$OKStartX-=3} #Compensate width rendering difference in PowerShell Console
    #Drawing the OK button
    $okButton = New-Object System.Windows.Forms.Button -Property @{
        Location     = New-Object System.Drawing.Size($OKStartX,$OKStartY) #OK button position
        Size         = New-Object System.Drawing.Size($OKbSizeX,$OKbSizeY) #OK button size
        DialogResult = [System.Windows.Forms.DialogResult]::OK
        Text         = "OK"
    }
    if     (($InboxType -eq "txt") -or ($InboxType -eq "1")) {$okButton.Add_Click({$form.Tag = $textBox.Text;  $form.Close()})}
    elseif (($InboxType -eq "dnd") -or ($InboxType -eq "2")) {$okButton.Add_Click({$form.Tag = $listBox.Items; $form.Close()})}

    #Converting from monitor resolution: Cancel button's starting position
    [int]$ClStartX = [math]::Round($mWidth /4.08)
    [int]$ClStartY = $OKStartY #Same Height as the OK button
    [int]$ClbSizeX = $OKbSizeX #Same size as the OK button
    [int]$ClbSizeY = $OKbSizeY #Same size as the OK button
    if (($host.name -match 'consolehost')) {$ClStartX-=3} #Compensate width rendering difference in PowerShell Console
    #Drawing the Cancel / Clear button
    $cancelButton = New-Object System.Windows.Forms.Button -Property @{
        Location     = New-Object System.Drawing.Size($ClStartX,$ClStartY)
        Size         = New-Object System.Drawing.Size($ClbSizeX,$ClbSizeY)
        Text         = "Cancel"
        DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    }
    $cancelButton.Add_Click({$form.Tag = $null; Try{$listBox.Items.Clear()}Catch [Exception]{}; $form.Close()})

    #Converting from monitor resolution: size of the prompt/form window
    [int]$formSizeX = [math]::Round($mWidth /3.56)
    [int]$formSizeY = [math]::Round($mHeight/2.18)
    if (($host.name -match 'consolehost')) {$formSizeX+=2} #Compensate width rendering difference in PowerShell Console
    #Draw the form window
    $form = New-Object System.Windows.Forms.Form -Property @{
        Text = $WindowTitle
        Size = New-Object System.Drawing.Size($formSizeX,$formSizeY) #Form window size
        FormBorderStyle = 'FixedSingle'
        StartPosition = 'CenterScreen'
        AutoSizeMode = 'GrowAndShrink'
        Topmost = $false
        AcceptButton = $okButton
        CancelButton = $cancelButton
        ShowInTaskbar = $true
    }
    #Add control elements to the prompt/form window
    $form.Controls.Add($label); $form.Controls.Add($okButton); $form.Controls.Add($cancelButton)
    if     ($InboxType -match "txt|1") {
        if ($ShowDebug -eq $true) {Write-Debug "! Mode == MultiLine textBox Form"}
        $form.Controls.Add($textBox)
    } elseif ($InboxType -match "dnd|2") {
        if ($ShowDebug -eq $true) {Write-Debug "! Mode == Drag&Drop listBox From"}
        $form.Controls.Add($listBox)
        #Add form Closing events for drag-&-drop events only, basically to remove data from listBox
        $form_FormClosed = {
	        TRY {
                $listBox.remove_Click($button_Click)
		        $listBox.remove_DragOver($listBox_DragOver)
		        $listBox.remove_DragDrop($listBox_DragDrop)
                $listBox.remove_DragDrop($listBox_DragDrop)
		        $form.remove_FormClosed($Form_Cleanup_FormClosed)
	        }
	        catch [Exception] {}
        }
        #Load Drag-&-Drop events into the form
        $listBox.Add_DragOver($listBox_DragOver)
        $listBox.Add_DragDrop($listBox_DragDrop)
        $form.Add_FormClosed($form_FormClosed)
    }
    #Load Add_Shown event used by both textbox & drag-&-drop events into form
    $form.Add_Shown({$form.Activate()})
    #Load Key_Down event for closing with ESC button
    $form.Add_KeyDown({
        if ($PSItem.KeyCode -eq "Escape") {$cancelButton.PerformClick()}
    })
    #Normal prompting, user can proceed with $null return by clicking Cancel or ×, or empty string by clicking OK
    $form.ShowDialog() | Out-Null #Supress "OK/Cancel" text from returned in Dialog

    #An early-skip to prevent an empty listBox from not come with all of available methods
    if     ( ($InboxType -match "txt|1") -and ($textBox.Text -eq "") )       {
        if ($ReturnType -match "str|1") {return ""}
        if ($ReturnType -match "ary|2") {return $null}
    }elseif  ( ($InboxType -match "dnd|2") -and ($listBox.Items.Count -eq 0)) {
        if ($ReturnType -match "str|1") {return ""}
        if ($ReturnType -match "ary|2") {return $null}
    }

    #Scrub Empty lines & DialogResult (OK) from returning
    if     ($FixSquareBrkts -eq $true) {
        [array]$ScrbDiagRslt = ($form.Tag.Split("`r`n").Trim()).replace('[','``[').replace(']','``]').replace('``][','``]``[') | 
            where {$_ -ne ""} #Where filtering is very important here because otherwise each line would be followed by an empty line
    }
    elseif ($FixSquareBrkts -eq $false){
        [array]$ScrbDiagRslt = ($form.Tag.Split("`r`n").Trim()) | 
            where {$_ -ne ""} #Where filtering is very important here because otherwise each line would be followed by an empty line
    }

    #Format result into multi-line string / array based on user definition
    if     ($ReturnType -match "str|1") {return ($ScrbDiagRslt | Out-String).TrimEnd()} #String out, TrimEnd is very important as output would otherwise have an empty line in the end
    elseif ($ReturnType -match "ary|2") {return  $ScrbDiagRslt }                        #Array out
} ;
#*------^ END Function read-MultiLineInputDialogAdvanced ^------
