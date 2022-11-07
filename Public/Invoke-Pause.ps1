#*------v Invoke-Pause.ps1 v------
Function Invoke-Pause() {
    <#
    .SYNOPSIS
    Invoke-Pause.ps1 - Press any key to continue prompting function
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 11:04 AM 11/6/2013
    .DESCRIPTION
    Invoke-Pause.ps1 - Press any key to continue prompting function
    .PARAMETER  DisplayMessage
    Switch that specifies message is to be displayed (defaults True)
    .PARAMETER  Content
    Text prompt message to be displayed
    .EXAMPLE
    Invoke-Pause
    Display default prompt & text
    .EXAMPLE
    Invoke-Pause -DisplayMessage $FALSE
    Display a prompt, with no message text
    .EXAMPLE
    Invoke-Pause -Content "Message"
    Display a prompt with a custom message text
    .LINK
    #>
    PARAM(
        [Parameter(HelpMessage="Switch that specifies message is to be displayed (defaults True) [-DisplayMessage `$False]")]
        $DisplayMessage = $TRUE,
        [Parameter(HelpMessage="Text prompt message to be displayed [-Content 'displayed message']")]
        $Content = "Press any key to continue . . ."
    ) ;
    If (($DisplayMessage -ne $TRUE)) { write-host $DisplayMessage.ToString() }
    $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
    $HOST.UI.RawUI.Flushinputbuffer()
}

#*------^ Invoke-Pause.ps1 ^------
