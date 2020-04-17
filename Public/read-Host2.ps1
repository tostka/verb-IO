##*------v Function Read-Host2 v------
Function Read-Host2 {
    <#
    .SYNOPSIS
    An alternative to Read-Host
    .NOTES
    Author      : Jeff Hicks
    Website     :	http://jdhitsolutions.com/blog/2014/08/more-flashing-fun
    CreatedDate : 2020-04-17
    FileName    : Read-Host2.ps1
    REVISIONS   :
    Version     : 0.9 August 18, 2014
    .DESCRIPTION
    This is an alternative to Read-Host which works almost the same as the original cmdlet. You can use this to prompt the user for input. They can either enter text or have the text converted to a secure string. The only difference is that the prompt will display in a flashing colors until you start typing.
    requires -version 3.0
    This command will NOT work properly in the PowerShell ISE.
    .PARAMETER Prompt
    The text to be displayed. A colon will be appended.
    .PARAMETER AsSecureString
    The entered text will be treated as a secure string. This parameter has an alias of 'ss'.
    .PARAMETER UseForeground
    Flash the text color instead of the background. This parameter has aliases of 'fg' and 'foreground'.
    .EXAMPLE
    PS C:\> $user = Read-Host2 "Enter a username" -color DarkGreen ;$user;
    Prompt for user name using a dark green background
    .EXAMPLE
    PS C:\> $pass = Read-Host2 "Enter a password" -color darkred -foreground -asSecureString
    Prompt for a password using DarkRed as the foreground color.
    .EXAMPLE
    PS C:\> $s={ $l = get-eventlog -list ; Read-host2 "Press enter to continue" ; $l}
    PS C:\> &$s
    Press enter to continue :
      Max(K) Retain OverflowAction        Entries Log
      ------ ------ --------------        ------- ---
      20,480      0 OverwriteAsNeeded      30,829 Application
      20,480      0 OverwriteAsNeeded           0 HardwareEvents
         512      7 OverwriteOlder              0 Internet Explorer
      20,480      0 OverwriteAsNeeded           0 Key Management Service
      20,480      0 OverwriteAsNeeded          12 Lenovo-Customer Feedback
         128      0 OverwriteAsNeeded         455 OAlerts
         512      7 OverwriteOlder              0 PreEmptive
      20,480      0 OverwriteAsNeeded      32,013 Security
      20,480      0 OverwriteAsNeeded      26,475 System
      15,360      0 OverwriteAsNeeded      17,715 Windows PowerShell
     This is an example of how you might use the command in a script. The prompt will keep flashing until you press Enter.
    .LINK
    http://jdhitsolutions.com/blog/2014/08/more-flashing-fun
    .LINK
    Read-Host
    ConvertTo-SecureString
    #>
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Enter a prompt message")]
        [string]$Prompt,
        [Alias('ss')]
        [switch]$AsSecureString,
        [System.ConsoleColor]$Color = "Red",
        [Alias("fg", "Foreground")]
        [switch]$UseForeground
    )
    #this will be the array of entered characters
    $text = @() ;
    #save current background and foreground colors
    $bg = $host.ui.RawUI.BackgroundColor ;
    $fg = $host.ui.RawUI.ForegroundColor ;
    #set a variable to be used in a While loop
    $Running = $True ;
    #set a variable to determine if the user is typing something
    $Typing = $False ;
    #get current cursor position
    $Coordinate = $host.ui.RawUI.CursorPosition ;
    $msg = "`r$Prompt : " ;
    While ($Running) {
        ;
        if (-Not $Typing) {
            ;
            #don't toggle or pause if the user is typing
            if ($UseForeground) {
                ;
                if ($host.ui.RawUI.ForegroundColor -eq $fg) {
                    $host.ui.RawUI.ForegroundColor = $color ;
                }
                else {
                    $host.ui.RawUI.ForegroundColor = $fg ;
                } ;
            }  # if-block end;
            else {
                ;
                if ($host.ui.RawUI.BackgroundColor -eq $bg) {
                    $host.ui.RawUI.BackgroundColor = $color ;
                }
                else {
                    ;
                    $host.ui.RawUI.BackgroundColor = $bg ;
                }  # if-block end;
            }  # if-block end;
            Start-Sleep -Milliseconds 350 ;
        } #if not typing ;
        #set the cursor position
        $host.ui.rawui.CursorPosition = $Coordinate ;
        #write the message on a new line
        Write-Host $msg ;
        #see if a key has been pushed
        if ($host.ui.RawUi.KeyAvailable) {
            #user is typing
            $Typing = $True ;
            #filter out shift key
            $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")  ;
            Switch ($key.virtualKeyCode) {
                13 { $Running = $False ; Break } ;
                16 {
                    #Shift key so don't do anything ;
                    Break ;
                }  # switch entry end;
                Default {
                    #add the key to the array
                    $text += $key ;
                    #display the entered text
                    if ($AsSecureString) {
                        #mask the character if asking for a secure string
                        $out = "*" ;
                    }
                    else {
                        $out = $key.character ;
                    } ;
                    #append the character to the prompt
                    $msg += $out ;
                }  # switch entry end;
            }  # switch block end ;
        }  # if-block end;
    }  # while-loop end;
    #reset the original background color
    $host.ui.RawUI.BackgroundColor = $bg ;
    $host.ui.RawUI.ForegroundColor = $fg ;
    #write the input to the pipeline
    #removing any leading or trailing spaces
    $data = (-join $text.Character).Trim() ;
    #convert to SecureString if specified
    if ($AsSecureString) {
        ConvertTo-SecureString -String $data -AsPlainText -Force ;
    }
    else {
        #write the read data to the pipeline
        $data ;
    }  # if-block end;

} #*------^ END Function Read-Host2 ^------