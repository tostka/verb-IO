#*------v Function Save-ConsoleOutputToClipBoard v------
function Save-ConsoleOutputToClipBoard {
    <#
    .SYNOPSIS
    Save-ConsoleOutputToClipBoard.ps1 - 1LINEDESC
    .NOTES
    Author: Adam Bertrand
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	http://www.adamtheautomator.com/
    Twitter:	@adbertram
    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 5/14/2019 posted version
    .DESCRIPTION
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    Save-ConsoleOutputToClipBoard.ps1 
    Save current console output to clipboard.
    .LINK
    https://gist.github.com/adbertram/4e4bf0ba5f876ed474f90534520cf2e2
    #>

    [OutputType('string')]
    [CmdletBinding()]
    param () ;
    <#if ($host.Name -ne -ConsoleHost-) {
        write-host -ForegroundColor Red "This script runs only in the console host. You cannot run this script in $($host.Name)." ;
    } ;#>

    # Initialize string builder.
    $textBuilder = new-object system.text.stringbuilder ;

    # Grab the console screen buffer contents using the Host console API.
    $bufferWidth = $host.ui.rawui.BufferSize.Width
    $bufferHeight = $host.ui.rawui.CursorPosition.Y

    $rec = new-object System.Management.Automation.Host.Rectangle 0, 0, ($bufferWidth - 1), $bufferHeight ;
    $buffer = $host.ui.rawui.GetBufferContents($rec) ;

    # Iterate through the lines in the console buffer.
    for ($i = 0; $i -lt $bufferHeight; $i++) {
        for ($j = 0; $j -lt $bufferWidth; $j++) {
            $cell = $buffer[$i, $j] ;
            $null = $textBuilder.Append($cell.Character) ;
        } ;
        $null = $textBuilder.Append("`r`n") ;
    } ;

    ## Ensure the PS prompt is always just PS>
    $out = $textBuilder.ToString() -replace 'PS .*\>', 'PS>' ;

    ## Remove the line that actually invoked this function
    $out -replace "PS> $($MyInvocation.MyCommand.Name)" | Set-Clipboard ;
} ; #*------^ END Function Save-ConsoleOutputToClipBoard ^------
