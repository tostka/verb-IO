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
    * 9:27 AM 2/2/2022 added -topipeline switch & post-split code (pipeline return returns text block, not lines, and os-agnostic split pads with spaces between lines unless explicitly supressed); fixed output: was just dumping console text to pipeline (and back into console buffer), piped it into set-clipboard ; minor tweaks OTB fmt, added CBH ; added else clause to echo non-support of VsCode.
    * 6/5/2019 posted AutomatedLab revision (non-functional, doesn't copy to cb)
    .DESCRIPTION
    get-ConsoleText.ps1 - Copies current powershell console buffer to the clipboard
    .PARAMETER toPipeline
    switch to return the text to the pipeline (rather than default 'copy to clipboard' behavior)[-toPipeline]
    .OUTPUT
    None. Outputs console text to clipboard.
    .EXAMPLE
    get-ConsoleText ;
    get-clipboard |  measure | select -expand count ;
    Copy console text to clipboard, then output the number of lines returned.
    .EXAMPLE
    $content = get-ConsoleText -toPipeline ;
    $content.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) |  measure | select -expand count ; 
    $content.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)) | select -first 15 ; 
    Demonstrate assign console text to a variable, and resplit (suppressing empty lines), and output the first 15 lines returned.
    .LINK
    https://github.com/AutomatedLab/AutomatedLab.Common/blob/develop/AutomatedLab.Common/Common/Public/Get-ConsoleText.ps1
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('tmf')]
    PARAM(
        [Parameter(HelpMessage="switch to return the text to the pipeline (rather than default 'copy to clipboard' behavior)[-toPipeline]")]
        [switch] $toPipeline
    ) ;
    
    # Check the host name and exit if the host is not the Windows PowerShell console host.
    if ($host.Name -eq 'Windows PowerShell ISE Host') {
        write-verbose "(`$host.Name:Windows PowerShell ISE Host detected)" ;
        write-verbose "(copying to cb...)" ;
        $return = $psISE.CurrentPowerShellTab.ConsolePane.Text ; 
    } elseif ($host.Name -eq 'ConsoleHost') {
        write-verbose "(`$host.Name:ConsoleHost detected)" ;
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
        write-verbose  "(processing buffer)" ; 
        for ($i = 0; $i -lt $bufferHeight; $i++) {
            for ($j = 0; $j -lt $bufferWidth; $j++) {
                $cell = $buffer[$i, $j]  ;
                $null = $textBuilderLine.Append($cell.Character) ;
            } ;
            $null = $textBuilderConsole.AppendLine($textBuilderLine.ToString().TrimEnd()) ;
            $textBuilderLine = New-Object System.Text.StringBuilder ;
        } ;
        # original code was dropping into pipeline, not copying to clipboard (as per echos). 
        $return = $textBuilderConsole.ToString() ;
        Write-Verbose "$bufferHeight lines have been processed" ;
    } elseif( $env:TERM_PROGRAM -eq 'vscode' ){
        write-warning "(VSCode detected: unsupported)" ; 
        BREAK ;
    } else {
        write-warning "(unrecognized `$host.Name:$($host.name))" ; 
        BREAK ;
    } ; 
    if($return -AND -not $toPipeline){
        write-verbose "(copied content to clipboard)" ; 
        # $content 
        $return | set-clipboard
    } else { 
        write-verbose "(returning content to pipeline)" ; 
        # this writes everyting as a single text block, unsplit
        #$return | write-output ; 
        # split before returning - this natively suppresses emtpy lines
        #$return.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) | write-output ; 
        # variant, OS agnostic, requires removeemptyentries or it leaves gaps (inflates a 3k line console to 6k lines). 
        $return.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) ;
    } ; 
} ;
#*------^ get-ConsoleText.ps1 ^------