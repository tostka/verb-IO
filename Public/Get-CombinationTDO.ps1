# Get-CombinationTDO.ps1

#*------v Function Get-CombinationTDO v------
function Get-CombinationTDO {
    <#
    .SYNOPSIS
    Get-CombinationTDO - Select Combinations from the group specified
    .NOTES
    Version     : 0.0.2
    Author      : Doug Finke (dfinke)
    Website     : https://github.com/dfinke
    Twitter     : @dfinke / http://twitter.com/dfinke
    CreatedDate : 2020-04-30
    FileName    : Get-CombinationTDO.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell, Algorithm, Permutation, Math
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    * 10:01 AM 9/14/2023 renamed to distinctive 'TDO' to avoid clashes ; moved class Combination into main function, to make it selfcontained wo the full .psm1 (to add to my verb-io .psm1); minor OTB reformatting, tighted up whitespace
    * 4/30/2020 Dfinke's posted version
    - 11/8/2017 Dfinke's prior rev
    .DESCRIPTION
    Get-CombinationTDO - Select Combinations from the group specified

    [GitHub - dfinke/PowerShellCombinations: Using PowerShell Classes & Script to generate and manipulate combinations and permutations](https://github.com/dfinke/PowerShellCombinations)

    ## Combinations

    A combination is a way of selecting to members from a grouping, such that (unlike permutations) the order of selection does not matter.

    For example, if you have the 5 items

        ```text
        ant bug cat dog elk
        ```

    then the 10 possible combinations of size 3 are

        ```text
        ant   bug   cat  
        ant   bug   dog  
        ant   bug   elk  
        ant   cat   dog  
        ant   cat   elk  
        ant   dog   elk  
        bug   cat   dog  
        bug   cat   elk  
        bug   dog   elk  
        cat   dog   elk  
        ```
    
    > I ported this from James McCaffrey's book [.NET Test Automation Recipes](http://www.apress.com/9781590596630)

    Dfinke's accompanying script that leverages the [combination] class to draw a hand from a 52 card deck of cards.

    ```powershell
    write-verbose "this leverages/loads dfinke's original Combination module, assumed to be locally stored (to mount the Combination class)" ; 
    $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    $scriptBody = "using module $here\Combination.psm1" ; 
    $script = [ScriptBlock]::Create($scriptBody) ; 
    . $script ; 
    write-verbose "... and then obtains a 5 card combination" ; 
    $possibilities = [Combination]::Choose(52,5) ; 
    $c = [Combination]::new(52,5) ; 

    $deck = $(
        echo As Ks Qs Js Ts 9s 8s 7s 6s 5s 4s 3s 2s ; 
        echo Ac Kc Qc Jc Tc 9c 8c 7c 6c 5c 4c 3c 2c ; 
        echo Ad Kd Qd Jd Td 9d 8d 7d 6d 5d 4d 3d 2d ; 
        echo Ah Kh Qh Jh Th 9h 8h 7h 6h 5h 4h 3h 2h ; 
    ) ; 

    "$($c.Element((Get-Random $possibilities)).ApplyTo($deck))" ; 

    ```

    .PARAMETER  Data
    Array of strings to be Combinationed[-target 'ant','bug,'cat','dog','elk']
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    System.Boolean
    [| get-member the output to see what .NET obj TypeName is returned, to use here]
    .EXAMPLE
    PS> $animals = echo ant bug cat dog elk ;
    PS> Get-CombinationTDO $animals 3 | Format-Table -AutoSize ;

        Item1 Item2 Item3
        ----- ----- -----
        ant   bug   cat  
        ant   bug   dog  
        ant   bug   elk  
        ant   cat   dog  
        ant   cat   elk  
        ant   dog   elk  
        bug   cat   dog  
        bug   cat   elk  
        bug   dog   elk  
        cat   dog   elk  
    
    Calculate combinations of three of the specified array.
     .EXAMPLE
    PS> $animals = echo ant bug cat dog elk ;
    PS> Get-CombinationTDO $animals | Format-Table -AutoSize ;

        Item1 Item2 Item3 Item4 Item5
        ----- ----- ----- ----- -----
        ant   bug   cat   dog   elk  
        ant   bug   cat   dog        
        ant   bug   cat   elk        
        ant   bug   dog   elk        
        ant   cat   dog   elk        
        bug   cat   dog   elk        
        ant   bug   cat              
        ant   bug   dog              
        ant   bug   elk              
        ant   cat   dog              
        ant   cat   elk              
        ant   dog   elk              
        bug   cat   dog              
        bug   cat   elk              
        bug   dog   elk              
        cat   dog   elk              
        ant   bug                    
        ant   cat                    
        ant   dog                    
        ant   elk                    
        bug   cat                    
        bug   dog                    
        bug   elk                    
        cat   dog                    
        cat   elk                    
        dog   elk                    
        ant                          
        bug                          
        cat                          
        dog                          
        elk       
    
    Calculate unlimited combinations of the full array of the five elements
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://github.com/dfinke/PowerShellCombinations
    #>
    [OutputType("Object[]")]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Array of strings to have Combinations run[-Data 'ant bug cat dog elk']")]
            [string[]]$Data,
        [Parameter(Position=1,HelpMessage="Size limit of combinations to run (defaults to 0==Unlimited; 3 == if there are 5 elements, calculate variant Combinations of 3 elements)[-TakeXAtAtime 'ant','bug','cat','dog','elk']")]
            [int]$TakeXAtAtime = 0
    ) ; 
    $targetVersion = [version]"5.0.9883.0"
    if($PSVersionTable.PSVersion -lt $targetVersion) {
        Write-Error "Sorry, you need PowerShell version $targetVersion or newer"
        break
    }

    #*------v class Combination v------
    class Combination {
        hidden [long]$n ; 
        hidden [long]$k ; 
        hidden [long[]]$data ; 
    
        Combination([long]$n, [long]$k) {
            $this.n=$n ;
            $this.k=$k ;
            if($n -lt 0 -Or $k -lt 0) {throw "Negative argument in constructor"} ;
            $this.data=New-Object long[] $k ;
            for ($i = 0; $i -lt $k; ++$i){
                $this.data[$i]=$i ;
            } ;
        }
    
        Combination([long]$n, [long]$k, [long[]]$a) {
            if($k -ne $a.Count) {throw "Bad array size in constructor"} ; 
            $this.n=$n ; 
            $this.k=$k ; 
            $this.data=New-Object long[] $k ; 
            for ($i = 0; $i -lt $k; ++$i){
                $this.data[$i]=$a[$i] ; 
            } ; 

        }

        [string]ToString() { return "{ "+ $this.data + " }" } 

        static [long] Choose([long]$n, [long]$k) {
            [long]$delta=0 ; 
            [long]$iMax=0 ; 
            if($n -lt $k) { return 0 } ; 
            if($n -eq $k) { return 1 } ; 
            if($k -lt $n -$k) {
                $delta=$n-$k ; 
                $iMax=$k ; 
            } else {
                $delta=$k ; 
                $iMax=$n-$k ; 
            } ; 
            [long]$answer = $delta + 1 ; 
            for ($i = 2; $i -le $iMax; ++$i){
                $answer = ($answer * ($delta + $i)) / $i
            } ; 
            return $answer ; 
        }

        [Combination] Successor() {
            if($this.data[0] -eq $this.n - $this.k) { return $null } ; 
            [Combination]$ans = [Combination]::new($this.n, $this.k) ; 
            for ($i = 0; $i -lt $this.k; ++$i){
                $ans.data[$i]=$this.data[$i] ; 
            } ; 
            for ($x = $this.k - 1; $x -gt 0 -and $ans.data[$x]  -eq $this.n-$this.k+$x; --$x) {} ; 
            ++$ans.data[$x] ; 
            for ($j = $x; $j -lt $this.k - 1; ++$j){
                $ans.data[$j+1]=$ans.data[$j]+1 ; 
            } ; 
            return $ans ; 
        }
 
        [Combination] Element([long]$m) {
            [long[]] $ans = New-Object long[] $this.k
            [long]$a = $this.n;
            [long]$b = $this.k;
            [long]$x = ([Combination]::Choose($this.n, $this.k) - 1) - $m
            for ($i = 0; $i -lt $this.k; ++$i){
                $ans[$i] = [Combination]::LargestV($a,$b,$x) ; 
                $x = $x - [Combination]::Choose($ans[$i],$b) ; 
                $a = $ans[$i] ; 
                $b = $b-1 ; 
            } ; 
            for ($i = 0; $i -lt $this.k; ++$i){
                $ans[$i] = ($this.n-1) - $ans[$i] ; 
            } ; 
            return [Combination]::new($this.n, $this.k, $ans) ; 
        }

        hidden static [long] LargestV([long]$a, [long]$b, [long]$x) {
            $v = $a-1 ; 
            while([Combination]::Choose($v, $b) -gt $x) { --$v }  ;
            return $v ; 
        }

        #[string[]] ApplyTo([string[]]$sa) {
        [string[]] ApplyTo2([string[]]$sa) {
            [string[]]$result=New-Object string[] $this.k ; 
            for ($i = 0; $i -lt $result.Count; ++$i){
                $result[$i] = $sa[$this.data[$i]] ; 
            } ; 
            return $result ; 
        }[string[]] ApplyTo([string[]]$sa) {
            [string[]]$result=New-Object string[] $this.k ; 
            for ($i = 0; $i -lt $result.Count; ++$i){
                $result[$i] = $sa[$this.data[$i]] ; 
            }
            return $result ; 
        }
    } ; 
    #*------^ END class Combination ^------

	# Allow variable width combinations
	if ($TakeXAtAtime -eq 0)
    {$TakeAtLeast = 1 ; $TakeAtMost = $Data.Count} 
    else {$TakeAtLeast = $TakeAtMost = $TakeXAtAtime } ; 
	
	for ($i = $TakeAtMost; $i -ge $TakeAtLeast; $i--){
		$c = [Combination]::new($data.count, $i) ; 
		while ($c) {
			$h=[ordered]@{} ; 
			$idx=1 ; 
			#$c.ApplyTo($data) | foreach-object {
            # clashing in the loaded perm class, rename variant for now (identical function)
            $c.ApplyTo2($data) | foreach-object {
				$h."Item$($idx)"=$_ ; 
				++$idx ; 
			} ; 
			[PSCustomObject]$h ; 
			$c=$c.Successor()  ; 
		} ; 
	} ; 
} ; 
#*------^ END Function Get-CombinationTDO ^------
