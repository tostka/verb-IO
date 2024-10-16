#*------v Function Start-SleepCountdown v------
function start-sleepcountdown {
    <#
    .SYNOPSIS
    Start-SleepCountdown - Countdown variant of start-sleep: Counts down seconds to finish.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-12-12
    FileName    : Start-SleepCountdown.ps1
    License     : MIT License
    Copyright   : (c) 2024 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Time
    REVISION
    * 10:44 AM 10/15/2024 add -useMins to make it do a minutes countdown (still requires seconds input)
    * 1:19 PM 12/14/2023 init
    .DESCRIPTION
    Start-SleepCountdown - Countdown variant of start-sleep: Counts down seconds to finish.

    Though there's not a lot of point, if you pipeline in an integer array, it will run a pass for each value.

    .PARAMETER Seconds
    Specifies how long the resource sleeps in seconds. You can omit the parameter name ( Seconds ), or you can abbreviate it as s
    .INPUTS
    Accepts pipeline input
    .OUTPUTS
    No output.
    .EXAMPLE
    PS> '5' | Start-SleepCountdown ;

        Waiting 5 seconds...
        START[.5.4.3.2.1]DONE

    Wait 5 seconds with a countdown in seconds
    .EXAMPLE
    PS> Start-SleepCountdown -Seconds 13020 -useMins ; 
    Demo use of -useMins, to perform a minute-at-a-time coundown (still requires raw -Seconds input)
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Specifies how long the resource sleeps in seconds. You can omit the parameter name ( Seconds ), or you can abbreviate it as s")]
            [Alias('s')]
            [System.Int32]$Seconds,
        [Parameter(Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Specifies how long the resource sleeps in seconds. You can omit the parameter name ( Seconds ), or you can abbreviate it as s")]
            [switch]$useMins
    ) ;
    
    PROCESS{
        $smsg +="`nWaiting $($Seconds) seconds...`nSTART[" ; 
        write-host -foregroundcolor yellow -NoNewline $smsg ;
        $a=1 ; $thisMin = 60 ;
        Do {
            <#Var – Is $a a multiple of $b?
            Using the % modulus (remainder of a division) operator. 
            Tests if ($a % $b) returns zero ($b divides evenly into $a, with no remainder)
            $a=100; $b=5 ; if(!($a % $b)){"$a is a multiple of $b "}else{"$a is not a multiple of $b "};
            #>
            $thisMin-- ; 
            if($useMins){
                if($thisMin -eq 0){
                #if($Seconds % 60){ # mod isn't working right
                    #write-host -NoNewline ".$($Seconds)" ; 
                    write-host -NoNewline ".$([int]($Seconds/60))" ; 
                    $thisMin = 60 ;
                } ; 
            }else {
                write-host -NoNewline ".$($Seconds)" ; 
            } ; 
            start-sleep -Seconds 1 ; $Seconds--
        } 
        While ($Seconds -gt 0) ;
        write-host -foregroundcolor yellow "]DONE" ;
    } ;
}
#*------^ END Function Start-SleepCountdown ^------