#*------v get-ConsoleText.ps1 v------
Function get-ConsoleText {
    <#
    .SYNOPSIS
    get-ConsoleText.ps1 - Copies current powershell console buffer to the clipboard
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : AutomatedLab:Raimund Andrée [MSFT],Jan-Hendrik Peters [MSFT] 
    AddedWebsite:	https://github.com/AutomatedLab/AutomatedLab.Common/blob/develop/AutomatedLab.Common/Common/Public/Get-ConsoleText.ps1
    AddedGithub : https://github.com/AutomatedLab/AutomatedLab
    AddedTwitter:	@raimundandree,@nyanhp
    CreatedDate : 2022-02-02
    FileName    : get-ConsoleText.ps1
    License     : https://github.com/AutomatedLab/AutomatedLab/blob/develop/LICENSE
    Copyright   : Copyright (c) 2022 Raimund Andrée, Jan-Hendrik Peters
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Clipboard,Text
    REVISIONS
    * 8:01 AM 2/2/2022 fixed output: was just dumping console text to pipeline (and back into console buffer), piped it into set-clipboard ; minor tweaks OTB fmt, added CBH ; 
    * 6/5/2019 posted revision
    .DESCRIPTION
    get-ConsoleText.ps1 - Copies current powershell console buffer to the clipboard
    .OUTPUT
    None. Outputs console text to clipboard. 
    .EXAMPLE
    get-ConsoleText ; 
    get-clipboard |  measure | select -expand count ; 
    Copy console text to clipboard, then output the number of lines returned.
    .LINK
    https://github.com/AutomatedLab/AutomatedLab.Common/blob/develop/AutomatedLab.Common/Common/Public/Get-ConsoleText.ps1
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('tmf')]
    PARAM() ;
    # Check the host name and exit if the host is not the Windows PowerShell console host. 
    if ($host.Name -eq 'Windows PowerShell ISE Host') { 
        $psISE.CurrentPowerShellTab.ConsolePane.Text ; 
    } elseif ($host.Name -eq 'ConsoleHost') {
        $textBuilderConsole = New-Object System.Text.StringBuilder ; 
        $textBuilderLine = New-Object System.Text.StringBuilder ; 

        # Grab the console screen buffer contents using the Host console API.
        $bufferWidth = $host.UI.RawUI.BufferSize.Width ; 
        $bufferHeight = $host.UI.RawUI.CursorPosition.Y  ; 
        $rec = New-Object System.Management.Automation.Host.Rectangle(0, 0, ($bufferWidth), $bufferHeight) ; 
        $buffer = $host.UI.RawUI.GetBufferContents($rec)  ; 
        
        #Console buffer actually stores console formatting, along with characters
        # getting text out requires some processing of the raw content
        # Iterate through the lines in the console buffer. 
        for ($i = 0; $i -lt $bufferHeight; $i++) { 
            for ($j = 0; $j -lt $bufferWidth; $j++) { 
                $cell = $buffer[$i, $j]  ; 
                $null = $textBuilderLine.Append($cell.Character) ; 
            } ; 
            $null = $textBuilderConsole.AppendLine($textBuilderLine.ToString().TrimEnd()) ; 
            $textBuilderLine = New-Object System.Text.StringBuilder ; 
        } ; 
        # erm, below wasn't copying to console, it was dumping to pipeline! (effectively dumping same text back into console)
        #$textBuilderConsole.ToString() ; 
        $textBuilderConsole.ToString() | set-clipboard ; 
        Write-Verbose "$bufferHeight lines have been copied to the clipboard" ; 
    } ;     
} ; 
#*------^ get-ConsoleText.ps1 ^------