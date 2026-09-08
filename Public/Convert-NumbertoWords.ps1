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
    * 12:02 PM 9/8/2026 added code to handle decimals (_convert-DecimalDigitToWord), and better internal function to force solid comma-assertion (_convert-DecimalDigitToWord); 
        revised some logic handling
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
    BEGIN{
        $verbose = ($VerbosePreference -eq "Continue") ;
        #$ErrorActionPreference = "SilentlyContinue"
    
        #*======v INTERNAL_FUNCTIONS v======

        #*------v Function _convert-3DigitNumberToWords v------
        Function _convert-3DigitNumberToWords {
            <# .NOTES
                REVISIONS
                * 11:01 AM 1/9/2023 _convert-3DigitNumberToWords():TSK: fixed bug: wasn't pretesting number places, to ensure enough digits to support 10s & hundreds.
            #> 
            Param(
                [Parameter(Mandatory=$True,HelpMessage="Numbers group to be converted to words[-digits '587']")]
                    [int]$digits
            )
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
        
            if ($digits -le 19){
                $word = $wordarray.$($digits) ; 
            } ; 
            
            $Ones = $digits.ToString().ToCharArray()[-1].ToString().ToInt32($null) ; 
            # pre-test char count before taking -gt 1:
            if(($digits.ToString().ToCharArray().count -gt 1)){
                $Tens = $digits.ToString().ToCharArray()[-2].ToString().ToInt32($null) ; 
            } ; 
            if(($digits.ToString().ToCharArray().count -gt 2)){
                $Hundreds = $digits.ToString().ToCharArray()[-3].ToString().ToInt32($null) ; 
            } ;
            $OnesTens = (-join ($digits.ToString().ToCharArray()[-2..-1])).ToInt32($null) ; 

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
            $finalwordarray -join " " | write-output ; 
        }
        #*------^ END Function __convert-3DigitNumberToWord ^------
        
        #region _CONVERT_DECIMALDIGITTOWORD ; #*------v _convert-DecimalDigitToWord v------
        Function _convert-DecimalDigitToWord {
            <# .NOTES
                REVISIONS
                * 11:01 AM 1/9/2023 _convert-DecimalDigitToWord():TSK: fixed bug: wasn't pretesting number places, to ensure enough digits to support 10s & hundreds.
            #> 
            Param(
                [Parameter(Mandatory=$True,HelpMessage="Numbers group to be converted to words[-digits '587']")]
                    [ValidateRange(0,9)]
                    [int]$digit
            )
            write-verbose "Converting -digit: $($digit) to word..." ; 
            $wordarray = @{
                0 = 'zero' ; 
                1 = 'one';
                2 = 'two';
                3 = 'three';
                4 = 'four';
                5 = 'five';
                6 = 'six';
                7 = 'seven';
                8 = 'eight';
                9 = 'nine';                
            } ; 
            TRY{
                $word = $wordarray.$($digit) ; 
                $word | write-output ; 
            }CATCH{
                THROW "$($digit) isn't an integer between 0 and 9!" ;
            }
        }        
        #endregion _CONVERT_DECIMALDIGITTOWORD ; #*------^ END _convert-DecimalDigitToWord ^------

        #region _FORMAT_NUMBERWITHCOMMAS ; #*------v _format-NumberWithCommas v------
        function _format-NumberWithCommas {
            param(
                [Parameter(Mandatory)]
                    [object]$Value
            )            
            if ($Value -is [int] -OR $Value -is [long] -OR $Value -is [double] -OR $Value -is [decimal]) {
                return $Value.ToString('N0') ; 
            } ; 
            if ($Value -is [string]) {
                # To use a .NET TryParse method in PowerShell, you must pass the second argument by reference using the [ref] type accelerator. 
                # Because PowerShell maps both C# ref and out keywords to [ref], you must initialize the variable before passing it. 
                # 1. Initialize the output variable first
                $n = 0
                # 2. Call TryParse and cast the output variable with [ref]
                #if ([int]::TryParse("15", [ref]$n)) {
                if ([long]::TryParse($Value, [ref]$n)){
                    return $n.ToString('N0')
                }
                if ([double]::TryParse($Value, [ref]$n)){
                    #return $n.ToString('N2')
                    # above asserts explit 2 decimal places, and 'N' does 1. use the -f function to assesrt variable number of decimal places
                    # dyn the # of dec places
                    $decplaces = ($n -split '\.')[1].length                    
                    return ("{0:N$($decplaces)}" -f $n ); 
                }
            }
            throw "Value '$Value' is not a valid integer."
        }
        #endregion _FORMAT_NUMBERWITHCOMMAS ; #*------^ END _format-NumberWithCommas ^------

        #*======^ END INTERNAL_FUNCTIONS ^======
    } ;  # BEG-E
    PROCESS{
        #*======v SUB MAIN v======
        # relies on comma-places to split into groups: this should be doing the place-comma assertion, but fails, so we use the full _format-NumberWithCommas to do the job
        #$numbercommas = [string]::Format('{0:N0}',$number)
        if($number -match '^\d{1,3}(,\d{3})*$'){
            write-verbose "$($number) validates as comma-delimited" ; 
        }else{
            write-verbose "Number lacks place commas: asserting..." ; 
            $numbercommas = _format-NumberWithCommas -Value $number -verbose:($VerbosePreference -eq "Continue") ;
        }
        if($number -match '\.'){
            $numberint,$numberdecimals = ($numbercommas -split '\.') ; 
        } ; 
        if($numberint){
            $numbergroups = $numberint -split ',' ; # (e.g. split into 'thousands, millions' groups)
        }else{
            $numbergroups = $numbercommas -split ',' ; # (e.g. split into 'thousands, millions' groups)
        }
        $groupwordarray = foreach ($numbergroup in $numbergroups) {
            if($numbergroup -eq '000'){
                write-verbose "c3dntw uses [int] numbers, 000 isn't an integer (other than 0, but comes in as a string)..." ; 
                # drop a marker in to ensure gorup bump occurs at the right place
                '000'
            } else { 
                _convert-3DigitNumberToWords -digits $numbergroup ; 
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
        
        if($numberdecimals){
            # run the decimals through conversion one char at a tim
            #$numberdecimals.ToCharArray()
            $decwordarray = @() ; 
            $decwordarray += 'point'
            foreach ($decimal in $numberdecimals.ToCharArray()) {
                write-verbose "converting $($decimal) to word" ; 
                $decwordarray += _convert-DecimalDigitToWord -digit $decimal.tostring() ;                 
            } ; 
            $modifiedgroups =  $(@($modifiedgroups);@($decwordarray)) ;
        } 
        #emit an object with both, not a string ; 
        New-Object PSObject -Property @{
            Number = $numbercommas ;
            Text = ($modifiedgroups -join ' ').Trim() ; 
        } | write-output ; 

        #*======^ END SUB MAIN ^======
    } ;  # PROC-E
} ; 
#*------^ END Function Convert-NumbertoWords ^------