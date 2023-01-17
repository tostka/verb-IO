# Convert-NumbertoWords.ps1

#*------v Function Convert-NumbertoWords v------
function Convert-NumbertoWords {
    <#
    .SYNOPSIS
    Convert-NumbertoWords - Converts any number up to the octillions to its word equivilent. Example: 1,234,567 = one million two hundred thirty-four thousand five hundred sixty-seven.
    .NOTES
    Version     : 0.0.5
    Author      : smithcbp
    Website     : https://github.com/smithcbp
    Twitter     : 
    CreatedDate : 2023-01-06
    FileName    : Convert-NumbertoWords
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Text
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    * 11:01 AM 1/9/2023 _convert-3DigitNumberToWords():TSK: fixed bug: wasn't pretesting number places, to ensure enough digits to support 10s & hundreds.
        add: CBH example, and _-prefixed internal func; flip output from string of both comma & text to object w both as props, trim() text output (has trailing space)
    * 5:06 PM 1/6/2023 TSK fixed a bug - it didn't properly accomdate '000' sets - which aren't pronounced, but are part of bumping the setting up a level; 
    added CBH ; 
    added pipeline support on the IPAddress input ; simplfied compound stmts ; added to verb-Network.
    * Apr 17, 2018 smithcbp posted github version from: https://github.com/smithcbp/Powershell-Convert-NumbertoWords/blob/main/Convert-NumbertoWords.ps1
    .DESCRIPTION
    Convert-NumbertoWords - Converts any number up to the octillions to its word equivilent. Example: 1,234,567 = one million two hundred thirty-four thousand five hundred sixty-seven.

    Convert a Number to Words

    Converts any number up to the octillions to its word equivilent. Example: 1,234,567 = one million two hundred thirty-four thousand five hundred sixty-seven

    .PARAMETER number
    Number to be represented as a spoken sentance[-Numnber 123456
    .INPUTS
    Does not accepted piped input
    .OUTPUTS
    System.string
    .EXAMPLE
    PS> if(get-command -name Convert-NumberToWords -ea 0){
    PS>     $textNum = Convert-NumbertoWords -number ($subnet.HostAddressCount+1) ; 
    PS>     $smsg += "(`nThat's $($textNum.text) ip addresses" ; 
    PS> } ; 
    PS> write-host $smsg ; 
    .LINK
    https://github.com/tostka/verb-IO
    https://github.com/smithcbp/Powershell-Convert-NumbertoWords/blob/main/Convert-NumbertoWords.ps1
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("US","GB","AU")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)]#positiveInt:[ValidateRange(0,[int]::MaxValue)]#negativeInt:[ValidateRange([int]::MinValue,0)][ValidateCount(1,3)]
    [outputtype([System.String])]
    [CmdletBinding()]
    PARAM(
        [parameter(Mandatory=$true, Position=0,ValueFromPipeline = $True,HelpMessage="Number to be represented as a spoken sentance[-Numnber 123456")]
        $number
    ) ; 
    $verbose = ($VerbosePreference -eq "Continue") ;

    #$ErrorActionPreference = "SilentlyContinue"
    $numbercommas = [string]::Format('{0:N0}',$number)
    $numbergroups = $numbercommas -split ',' ; # (e.g. split into 'thousands, millions' groups)
    
    #*======v FUNCTIONS v======

    #*------v Function _convert-3DigitNumberToWords v------
    Function _convert-3DigitNumberToWords {
        <# .NOTES
            REVISIONS
            * 11:01 AM 1/9/2023 _convert-3DigitNumberToWords():TSK: fixed bug: wasn't pretesting number places, to ensure enough digits to support 10s & hundreds.
        #> 
        Param([int]$number)
        $wordarray = @{
            1 = 'one';
            2 = 'two';
            3 = 'three';
            4 = 'four';
            5 = 'five';
            6 = 'six';
            7 = 'seven';
            8 = 'eight';
            9 = 'nine';
            10 = 'ten';
            11 = 'eleven';
            12 = 'twelve';
            13 = 'thirteen';
            14 = 'fourteen';
            15 = 'fifteen';
            16 = 'sixteen';
            17 = 'seventeen';
            18 = 'eighteen';
            19 = 'nineteen';
            20 = 'twenty';
            30 = 'thirty';
            40 = 'forty';
            50 = 'fifty';
            60 = 'sixty';
            70 = 'seventy';
            80 = 'eighty';
            90 = 'ninety';
        } ; 
        
        if ($number -le 19){
            $word = $wordarray.$($number) ; 
        } ; 
            
        $Ones = $number.ToString().ToCharArray()[-1].ToString().ToInt32($null) ; 
        # pre-test char count before taking -gt 1:
        if(($number.ToString().ToCharArray().count -gt 1)){
            $Tens = $number.ToString().ToCharArray()[-2].ToString().ToInt32($null) ; 
        } ; 
        if(($number.ToString().ToCharArray().count -gt 2)){
            $Hundreds = $number.ToString().ToCharArray()[-3].ToString().ToInt32($null) ; 
        } ;
        $OnesTens = (-join ($number.ToString().ToCharArray()[-2..-1])).ToInt32($null) ; 

        if ($Hundreds -ge 1) {
            $HundredsWord = "$($wordarray.($hundreds)) hundred" ; 
        } ; 
        if ($OnesTens -le 19) {
            $OneTensWord = $wordarray.($OnesTens) ; 
        } ; 
        if ($Tens -ge 2 ) {
            $Tensword = $wordarray.($Tens * 10) ; 
            $Onesword = $wordarray.($Ones)  ; 
            if ($onestens % 10 -eq 0){$OneTensWord = $Tensword}
            else {$OneTensWord = $Tensword + '-' + $Onesword} ; 
        } ; 

        $finalwordarray = @($hundredsword,$OneTensword) ; 
        $finalwordarray = $finalwordarray | where-Object {$_} ; 
        $finalwordarray -join " " ; 
    }
    #*------^ END Function _convert-3DigitNumberToWords ^------
    #*======^ END FUNCTIONS ^======

    #*======v SUB MAIN v======
    $groupwordarray = foreach ($numbergroup in $numbergroups) {
        if($numbergroup -eq '000'){
            write-verbose "c3dntw uses [int] numbers, 000 isn't an integer (other than 0, but comes in as a string)..." ; 
            # drop a marker in to ensure gorup bump occurs at the right place
            '000'
        } else { 
            _convert-3DigitNumberToWords -number $numbergroup ; 
        } ; 
    } ; 

    $thouwordhash = @{
        1 = '' ;
        2 = 'thousand' ;
        3 = 'million' ;
        4 = 'billion' ;
        5 = 'trillion' ;
        6 = 'quadrillion' ;
        7 = 'quintillion' ;
        8 = 'sextillion' ;
        9 = 'septillion' ;
        10 = 'octillion'    ;        
    } ; 

    [array]::reverse($groupwordarray) ; 

    $i = 0 ; 
    $modifiedgroups = foreach($group in $groupwordarray){
        $i++ ; 
        if ($group -eq '000'){
             write-verbose 'suppress zeros, not pronounced, bump position' ; 
        }elseif ($group){ 
            Write-Output "$group $($thouwordhash.$i)" 
        } ; 
    } ; 
    
    [array]::reverse($modifiedgroups) ; 
    
    <# 
    if($VerbosePreference -eq "Continue"){
        $numbercommas ; 
    } ; 
    $modifiedgroups -join ' ' ; 
    #>
    #emit an object with both, not a string ; 
    New-Object PSObject -Property @{
        Number = $numbercommas ;
        Text = ($modifiedgroups -join ' ').Trim() ; 
    } | write-output ; 

    #*======^ END SUB MAIN ^======
} ; 
#*------^ END Function Convert-NumbertoWords ^------