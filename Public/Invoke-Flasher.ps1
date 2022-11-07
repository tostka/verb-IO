#*------v Function Invoke-Flasher v------
Function Invoke-Flasher {
    <#
    .SYNOPSIS
    Display a flashing message.
    .NOTES
    Version     : 1.0.0
    Author      : Jeff Hicks
    Website     :	http://jdhitsolutions.com/blog/2014/08/look-at-me
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : Invoke-Flasher.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Prompt
    REVISIONS
    Version     : 0.9 August 10, 2014
    .DESCRIPTION
    This command will present a flashing message that you can use at the end of a script or command to signal the user. By default the command will write a message to the console that alternates the background color between the current console color and a red. You can press any key to end the function and restore the original background color.
    You can also use the -FullScreen switch which will alternate the background color of the entire PowerShell console. Be aware that you will lose any script output that was displayed on the screen.
    This command will NOT work in the PowerShell ISE.
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    PS C:\> Get-Process | Sort WS -Descending | select -first 5 ; Invoke-Flasher
    This is a command line example of what a basic script would look like.
    .EXAMPLE
    PS C:\> $data = get-eventlog Security ; Invoke-Flasher "Security logs retrieved." -fullscreen ; $data
    This example uses the fullscreen parameter because the command output was saved to a variable.
    .LINK
    http://jdhitsolutions.com/blog/2014/08/look-at-me
    .LINK
    Write-Host
    #>
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0)]
        [string]$Text = "The command has completed.",
        [string]$Color = "red",
        [Switch]$FullScreen
    )
    $bg = $host.ui.RawUI.BackgroundColor ;
    $Running = $True ;
    #set cursor position
    $Coordinate = $host.ui.RawUI.CursorPosition ;
    While ($Running) {
        if ($host.ui.RawUI.BackgroundColor -eq $bg) {
            $host.ui.RawUI.BackgroundColor = $color ;
            if ($FullScreen) { Clear-Host } ;
        }
        else {
            $host.ui.RawUI.BackgroundColor = $bg ;
            if ($FullScreen) { Clear-Host } ;
        }  # if-block end;
        #set the cursor position ;
        $host.ui.rawui.CursorPosition = $Coordinate ;
        Write-Host "`n$Text Press any key to continue . . ." ;
        #see if a key has been pushed
        if ($host.ui.RawUi.KeyAvailable) {
            $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown") ;
            if ($key) {
                $Running = $False ;
            }  # if-block end ;
        } #if key available ;
        start-sleep -Milliseconds 500 ;
    }  # while-loop end ;
    $host.ui.RawUI.BackgroundColor = $bg ;
    if ($FullScreen) { Clear-Host } ;
} #*------------^ END Invoke-Flasher Function  ^------------
