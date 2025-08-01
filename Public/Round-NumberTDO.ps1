# Round-NumberTDO

#region ROUND_NUMBERTDO ; #*------v Round-NumberTDO v------
function Round-NumberTDO{
    <#
    .SYNOPSIS
    Round-NumberTDO - Simple wrapper for [math]::Round(), [math]::ceiling(), [math]::floor(), [math]::truncate(). Defaults to 2 decimal places wrap, 'Away from Zero' school rounding default. -Rounding supports 'RoundUp|RoundDown|AwayFromZero|Midpoint|Truncate'
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2025-07-30
    FileName    : Round-NumberTDO.ps1
    License     : MIT License
    Copyright   : (c) 2025 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Math,Round,Ceiling,Floor,Truncate,Number,Decimal
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 4:10 PM 7/30/2025 init
    .DESCRIPTION
    Round-NumberTDO - Simple wrapper for [math]::Round(), [math]::ceiling(), [math]::floor(), [math]::truncate(). Defaults to 2 decimal places wrap, 'Away from Zero' school rounding default. -Rounding supports 'RoundUp|RoundDown|AwayFromZero|Midpoint|Truncate'
    
    Has RndTo2, RndTo3 & RndTo4 aliases that default the places to 2,3 & 4 respectively.

    ## Reference: Rounding Foibles: 
    
    Note: - both [math]::round() and [int] type use "midpoint rounding" aka "banker's rounding, to even" rounding: 
    
    If the midpoint is 5, it will round to the nearest EVEN number.  
    
    For example, Math.Round(3.5) and Math.Round(4.5)  will both round out to 4.  This is done to avoid bias towards the higher value when rounding thousands or millions of numbers.  

    Schools teach 'away from zero rounding": "when the remainder is 5 always round up". 

    To approximate that use: (equiv items):
    result = Math.Round(number, decimal places, MidpointRounding.AwayFromZero)
    
    MidpointRounding.ToEven & MidpointRounding.AwayFromZero & 
    or 
    [midpointrounding]::ToEven & [midpointrounding]::AwayFromZero 
    
    ... are enums that represent the value 0 & 1: for use in the third Rounding parameter: for MidpointRounding or AwayFromZeroRounding
    They can be used in place of 0 or 1, to specifically indicate the rounding in effect in the call.

    ## .Net [math] class methods:
    
    # By default rounds up (if no decimal places specified)
    [Math]::round(5.123) ;  # yields 5
    Equiv to -Rounding:RoundUp

    # specifying decimal places param - round to 3 decimals (defaults to MidPointRounding)
    [math]::round(5.1234,3) ; # yields 5.123
    
    # third param is midpointrounding: 0 = MidPointRounding, 1 = AwayFromZeroRounding
    [math]::round( 12.345,2,0) ; # Midpoint default rounding, yields 12.34
    Equiv to -Rounding:MidPoint
    [math]::round(5.1234,3,1) ; # AwayFromZero rounding, yields 12.35
    Equiv to -Rounding:AwayFromZero

    # round everything up, toward positive infinity:
    [math]::ceiling( 2.2 )  ; # yields  3
    Equiv to -Rounding:RoundUp
    
    # round everything down, toward negative infinity
    [math]::floor( 2.8 )  ; # yields  2 
    Equiv to -Rounding:RoundDown

    # Truncate fraction/decimal at decimal point
    [math]::Truncate(5.5) ; # yields 5
    Equiv to -Rounding:Truncate

    .PARAMETER number
    Number to be rounded[-number 5.234]
    .PARAMETER places
    Decimal places of rounding to perform (defaults to 2)[-Places 4]
    .PARAMETER Rounding
    Mathematical rounding logic to use(RoundUp|RoundDown|AwayFromZero|Midpoint|Truncate, default:AwayFromZero)[-Rounding MidPoint]
    .EXAMPLE
    PS> RndTo2($driveSummary.sysvol.SizeRemaining/1GB)        
    Demo use of the RndTo2 alias, which defaults places to 2 (v RndTo3, RndTo4)
    .EXAMPLE
    PS> Round-NumberTDO 5.1234,3
    
    Demo use of full function name, with position params for number and places
    .EXAMPLE
    PS> Round-NumberTDO 5.1234 -Rounding Truncate
    
        5

    Demo use of full function name, with -Rounding Truncate
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('RndTo2','RndTo3','RndTo4')]
    PARAM(
        [Parameter(Mandatory = $true,Position = 0,HelpMessage="Number to be rounded[-number 5.234]")]
            [double]$number,
        [Parameter(Position = 1,HelpMessage="Decimal places of rounding to perform (defaults to 2)[-Places 4]")]
            [int]$places = 2,
        [Parameter(HelpMessage="Mathematical rounding logic to use(RoundUp|RoundDown|AwayFromZero|Midpoint|Truncate, default:AwayFromZero)[-Rounding MidPoint]")]
            [ValidateSet('RoundUp','RoundDown','AwayFromZero','Midpoint','Truncate')]
            [string]$Rounding = 'AwayFromZero'
    );
    BEGIN{
        if($Rounding -match 'RoundUp|RoundDown|Truncate'){
            $Places = 0 ; 
            write-verbose "-Rounding:'RoundUp|RoundDown|Truncate', blanking any specified/default -Places value" ; 
        } ; 
        # detect Alias v Function exec, reportedly $MyInvocation.InvocationName has invoke name, and in older PS, $MyInvocation.Line reportedly had it. Sometimes it works, sometimes not.            
        $vMyInvocation = $MyInvocation
        If ($vMyInvocation.Line -eq 'RndTo2' -OR $vMyInvocation.InvocationName -eq 'RndTo2') {
            $places = 2 ; 
            $smsg = 'Alias RndTo2 was used' ;
        }elseIf ($vMyInvocation.Line -eq 'RndTo3' -OR $vMyInvocation.InvocationName -eq 'RndTo3') {
            $places = 3 ; 
            $smsg = 'Alias RndTo3 was used' ;
        }elseIf ($vMyInvocation.Line -eq 'RndTo4' -OR $vMyInvocation.InvocationName -eq 'RndTo4') {
            $places = 4 ; 
            $smsg = 'Alias RndTo4 was used' ;
        } ElseIf ($vMyInvocation.Line -eq 'Round-NumberTDO') {
            $smsg = "Function name 'Round-NumberTDO' was used." ;
        } else {
            $smsg = "Unable to determine InvocationName/Line, defaulting to." ;
        };
        $smsg += " -places: $($places)" ;
        write-verbose $smsg ; 
    } ; 
    PROCESS{
        switch($Rounding){
            'RoundUp' {
                # always round up (to next higher integer)
                [system.math]::ceiling($number) | write-output  ;                 
            }
            'RoundDown' {
                # always round down (to next lower integer)
                [system.math]::floor($number) | write-output  ; 
            }
            'AwayFromZero' {
                # traditional school rounding: 'when remainder is 5 round up'
                [system.math]::round($number,$places,1) | write-output  ; 
            }
            'Midpoint' {
                # default programatic/banker's rounding: if midpoint 5, round to the *nearest even number*'
                [system.math]::round($number,$places,0) | write-output  ; 
            }
            'Truncate' {
                # Truncate fraction/decimal at decimal point
                [system.math]::Truncate($number) | write-output  ; 
            }
        } ;
    } ; 
} ; 
#endregion ROUND_NUMBERTDO ; #*------^ END Round-NumberTDO ^------