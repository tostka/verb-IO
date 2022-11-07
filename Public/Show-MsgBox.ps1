    #*------v Function Show-MsgBox v------
    function Show-MsgBox {
        <#
        .SYNOPSIS
        Show-MsgBox.ps1 - Shows a graphical message box, with various prompt types available.
        .NOTES
        Version     : 1.0.0
        Author      : BigTeddy
        Website     :	http://social.technet.microsoft.com/profile/bigteddy/.
        Twitter     :	@tostka / http://twitter.com/tostka
        CreatedDate : 2020-
        FileName    : 
        License     : MIT License
        Copyright   : (c) 2020 Todd Kadrie
        Github      : https://github.com/tostka
        Tags        : Powershell,Dialogs,GUI,UI,VisualBasic
        REVISIONS
        * 11:49 AM 4/17/2020 updated cbh
        * 12:18 PM 2/20/2015 ported/tweaked
        * August 23, 2011 10:40 PM posted version
        .DESCRIPTION
        Emulates the Visual Basic MsgBox function. It takes four parameters, of which only the prompt is mandatory
        .PARAMETER  Prompt
        Text string that you wish to display
        .PARAMETER  Title
        The title that appears on the message box
        .PARAMETER  Icon
        Available options are:Information, Question, Critical, Exclamation (not case sensitive)
        .PARAMETER  BoxType
        Available options are: OKOnly, OkCancel, AbortRetryIgnore, YesNoCancel, YesNo, RetryCancel (not case sensitive)
        .PARAMETER  DefaultButton 
        Available options are:1, 2, 3
        .EXAMPLE
        Show-MsgBox Hello
        Shows a popup message with the text "Hello", and the default box, icon and defaultbutton settings.
        .EXAMPLE
        Show-MsgBox -Prompt "This is the prompt" -Title "This Is The Title" -Icon Critical -BoxType YesNo -DefaultButton 2
        Shows a popup with the parameter as supplied.
        .LINK
        http://msdn.microsoft.com/en-us/library/microsoft.visualbasic.msgboxresult.aspx
        .LINK
        http://msdn.microsoft.com/en-us/library/microsoft.visualbasic.msgboxstyle.aspx
        #>
        [CmdletBinding()]
        param(
            [Parameter(Position = 0, Mandatory = $true)]
            [string]$Prompt,
            [Parameter(Position = 1, Mandatory = $false)]
            [string]$Title = "",
            [Parameter(Position = 2, Mandatory = $false)] [ValidateSet("Information", "Question", "Critical", "Exclamation")]
            [string]$Icon = "Information",
            [Parameter(Position = 3, Mandatory = $false)] [ValidateSet("OKOnly", "OKCancel", "AbortRetryIgnore", "YesNoCancel", "YesNo", "RetryCancel")]
            [string]$BoxType = "OkOnly",
            [Parameter(Position = 4, Mandatory = $false)] [ValidateSet(1, 2, 3)]
            [int]$DefaultButton = 1
        )
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        switch ($Icon) {
            "Question" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Question }
            "Critical" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Critical }
            "Exclamation" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Exclamation }
            "Information" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Information }
        }
        switch ($BoxType) {
            "OKOnly" { $vb_box = [microsoft.visualbasic.msgboxstyle]::OKOnly }
            "OKCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::OkCancel }
            "AbortRetryIgnore" { $vb_box = [microsoft.visualbasic.msgboxstyle]::AbortRetryIgnore }
            "YesNoCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNoCancel }
            "YesNo" { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNo }
            "RetryCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::RetryCancel }
        }
        switch ($Defaultbutton) {
            1 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton1 }
            2 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton2 }
            3 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton3 }
        }
        $popuptype = $vb_icon -bor $vb_box -bor $vb_defaultbutton
        $ans = [Microsoft.VisualBasic.Interaction]::MsgBox($prompt, $popuptype, $title)
        return $ans
    } #*------^ END Function Show-MsgBox ^------
