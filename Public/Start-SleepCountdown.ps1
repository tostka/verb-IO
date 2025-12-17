# Start-SleepCountdown

#region START_SLEEPCOUNTDOWN ; #*------v Start-SleepCountdown v------
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
    * 12:49 PM 12/5/2025 added regions
    * 4:34 PM 3/18/2025 fixed cbh helpmsg on -useMins; added inplace counter via -Rolling; added CBH expls for same.
    * 10:44 AM 10/15/2024 add -useMins to make it do a minutes countdown (still requires seconds input)
    * 1:19 PM 12/14/2023 init
    .DESCRIPTION
    Start-SleepCountdown - Countdown variant of start-sleep: Counts down seconds to finish.

    Though there's not a lot of point, if you pipeline in an integer array, it will run a pass for each value.

    .PARAMETER Seconds
    Specifies how long the resource sleeps in seconds. You can omit the parameter name ( Seconds ), or you can abbreviate it as s
    .PARAMETER useMins
    Specifies to perform a count down in minutes (still requires total -seconds input)
    .PARAMETER Rolling
    Specifies to do an in place countdown (no history count)
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
    PS> Start-SleepCountdown -Seconds (2*60) -useMins ;

        Waiting 2 Minutes...
        START[2.1.0]DONE

    Demo use of -useMins, to perform a minute-at-a-time coundown (still requires raw -Seconds input)
    .EXAMPLE
    PS> start-sleepcountdown -s 12 -rolling ;

        Waiting 12 seconds...
        START[=12=>]DONE

    Demo rolling non-incrementing digits display (rewrites the count between [ ] every interval, replacing with arrow at finish)
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Specifies how long the resource sleeps in seconds. You can omit the parameter name ( Seconds ), or you can abbreviate it as s")]
            [Alias('s')]
            [System.Int32]$Seconds,
        [Parameter(HelpMessage="Specifies to perform a count down in minutes (still requires total -seconds input)")]
            [switch]$useMins,
        [Parameter(HelpMessage = "Specifies to do an in place countdown (no history count)")]
            [switch]$Rolling
    ) ;

    PROCESS{
        if($useMins){
            $smsg += "`nWaiting $($Seconds/60) Minutes...`nSTART[" ;
        } else {
            $smsg +="`nWaiting $($Seconds) seconds...`nSTART[" ;
        } ;
        write-host -foregroundcolor yellow -NoNewline $smsg ;
        $a = 1 ; $thisMin = 60 ; $ttlMins = [int]($Seconds / 60) ;
        if($Rolling){
            $CurStart = $host.UI.RawUI.CursorPosition ;
            For ($i = $seconds; $i -ge 0 ; $i--) {
                $thisMin-- ;
                if ($useMins) {
                    if ($i -eq ($seconds - 1)) {
                        write-host -NoNewline "$([int]($Seconds/60))" ;
                    }elseif ($thisMin -eq 0) {
                        write-host -NoNewline "$([int]($Seconds/60))" ;
                        $thisMin = 60 ;
                    }
                } else {
                    write-host -NoNewline " " ;
                    if (($seconds.tostring().length - $i.tostring().length) -gt 0) {
                        for ($pad = 0; $pad -lt $seconds.tostring().length - $i.tostring().length; $pad++) {
                            write-host -NoNewline "0" ;
                        } ;
                    } ;
                    write-host -nonewline "$($i)s" ;
                } ;
                start-sleep -s 1 ;
                [console]::setcursorposition($CurStart.x, $CurStart.y) ;
            } ;
            if ($useMins) {
                write-host -foregroundcolor yellow "=$([int]($Seconds/60))=>]DONE" ;
            } else {
                write-host -foregroundcolor yellow "=$($seconds)=>]DONE" ;
            } ;
        } else {
            $init = $seconds ;
            Do {
                <#Var – Is $a a multiple of $b?
                Using the % modulus (remainder of a division) operator.
                Tests if ($a % $b) returns zero ($b divides evenly into $a, with no remainder)
                $a=100; $b=5 ; if(!($a % $b)){"$a is a multiple of $b "}else{"$a is not a multiple of $b "};
                #>
                $thisMin-- ;
                if($useMins){
                    if ($init -eq $seconds) {
                        write-host -NoNewline "$([int]($Seconds/60))" ;
                    }elseif($thisMin -eq 0){
                    #if(60 % $Seconds -eq 0){ # mod "works", but outputs spurious 0's for the trailing seconds past
                        $ttlMins--
                        #write-host -NoNewline ".$([int]($Seconds/60))" ;
                        write-host -NoNewline ".$($ttlMins)" ;
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
    } ; # PROC-E
} ;
#endregion START_SLEEPCOUNTDOWN ; #*------^ END Start-SleepCountdown ^------