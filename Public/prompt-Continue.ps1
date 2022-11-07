#------v Function prompt-Continue v------
Function prompt-Continue {
    <#
    .SYNOPSIS
    prompt-Continue - Prompted wait for "YYY" confirmation
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    9:55 AM 2/4/2015 - updated TOR
    9:54 AM 2/4/2015 TOR port, update
    20090731 - set the prompt to reverse video (write-warning, vs. write-host)
    .DESCRIPTION
    prompt-Continue - Prompted wait for "YYY" confirmation
    throws up a continue-prompt.
    .PARAMETER  MsgText
    Prompt text [text]
    .PARAMETER  Type
    Specify WARN message [Type: WARN]
    .EXAMPLE
    prompt-Continue "hello"
    .EXAMPLE
    prompt-Continue "hello" WARN
    (warning prompt)
    .LINK
     #>
    Param(
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Enter prompt text [text]")]
        [ValidateNotNullOrEmpty()]
        [string]$MsgText
        ,
        [Parameter(Position = 1, HelpMessage = "Specify if WARN message [Type: WARN]")]
        [ValidateSet("WARN")]
        [string]$Type
    ) # PARAM BLOCK END
    #$MsgText ;
    If (($MsgText -eq $null) -OR ($MsgText -eq "")) { write-warning "No `$MsgText specified" ; break } ;
    If (($Type -ne $null) -AND ($Type.ToUpper() -eq "WARN")) {
        write-warning $MsgText  ;
        #"This script will " $sAppDesc " ON " $targservr
        write-warning "DO NOT CONTINUE UNLESS YOU KNOW WHAT YOU'RE DOING AND WHAT THIS SCRIPT DOES!!!" ;
        # beep
        write-host "`a"; ;
    }
    else {
        write-host -foregroundcolor yellow ($MsgText) ;
        #"This script will " $sAppDesc " ON " $targservr
        write-host -foregroundcolor yellow ("DO NOT CONTINUE UNLESS YOU KNOW WHAT YOU'RE DOING AND WHAT THIS SCRIPT DOES!!!") ;
    } ; # if-E
    $bRet = read-host "Enter YYY to continue:" ;
    if ($bRet.ToUpper() -eq "YYY") {
        "continuing..." ;
    }
    else {
        write-warning "Invalid response. Exiting..." ;
        # exit <asserted exit error #>
        exit 1 ;
    } ;
} ##*------^ END Function prompt-Continue ^------
