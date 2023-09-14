# Get-PermutationTDO.ps1

#*------v Function Get-PermutationTDO  v------
function Get-PermutationTDO {
    <#
    .SYNOPSIS
    Get-PermutationTDO.ps1 - Calculate the range of Permutations of the specified group
    .NOTES
    Version     : 0.0.2
    Author      : Doug Finke (dfinke)
    Website     : https://github.com/dfinke
    Twitter     : @dfinke / http://twitter.com/dfinke
    CreatedDate : 2020-04-30
    FileName    : Get-PermutationTDO.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell, Algorithm, Permutation, Math
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    * 2:21 PM 9/14/2023 add: CBH demo that shows use of this to run fancy rgx select-string searches ; -asObject param (returns customobj rather than space-delimited text) ; renamed to distinctive 'TDO' to avoid clashes ; moved class PermutationTDO into main function, to make it selfcontained wo the full .psm1 (to add to my verb-io .psm1); minor OTB reformatting, tighted up whitespace
    - 11/8/2017 Dfinke's posted version
    .DESCRIPTION
    Get-PermutationTDO.ps1 - Calculate the range of Permutations of the specified group

    [GitHub - dfinke/PowerShellCombinations: Using PowerShell Classes & Script to generate and manipulate combinations and permutations](https://github.com/dfinke/PowerShellCombinations)

    ## Permutations

    A permutation is a way of selecting to members from a grouping, such that (unlike combinations) the order of selection matters.

    It you have the three items

        ```text
        Adam John Jane
        ```

    then, the six permutations of these items are

        ```text
        Adam John Jane
        Adam Jane John
        John Adam Jane
        John Jane Adam
        Jane Adam John
        Jane John Adam
        ```

    
    > I ported this from James McCaffrey's book [.NET Test Automation Recipes](http://www.apress.com/9781590596630)

    .PARAMETER  Target
    Array of strings to be permutated[-target 'ant','bug,'cat','dog','elk' ]
    .PARAMETER AsObject
    Switch that causes the output to be a PSCustomObject containing Item1...ItemX entries (vs default simple string of all elements space-delimted sent to pipeline)[-AsObject]
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    .EXAMPLE
    PS> $people = echo Adam John Jane ; 
    PS> Get-PermutationTDO $people ;
    .EXAMPLE
    PS> $kwords = 'quota','mailboxfolderstatistics' ; 
    PS> $perms = get-permutationTDO $kwords  ; 
    PS> [array]$rgxString = $() ; 
    PS> foreach($p in $perms){
    PS>     $rgxString += "($($p.split(' ') -join '.*'))" ; 
    PS> } ; 
    PS> [string]$rgxString = $rgxString -join '|' ; 
    PS> [regex]$rgxString = $rgxString ;
    PS> write-host "running search with rgx:$($rgxString.Tostring())..." ; 
    PS> gci c:\usr\work\incid\*.txt | sort LastWriteTime | sls -pattern $rgxString.Tostring() ;   
    
        running search with rgx:(quota.*mailboxfolderstatistics)|(mailboxfolderstatistics.*quota)...
          
    Demo that leverages get-permutationTDO() to produce all possible word order variants, and then creates a regex .* wildcard mis-pair, 'OR'd in the various word orders". This lets you run select-string -pattern searches that accomodate any order of the target keywords in subject files.
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://github.com/dfinke/PowerShellCombinations
    #>
    [OutputType("Object[]")]
    [CmdletBinding()]
    PARAM(
        #[Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="HELPMSG[-PARAM SAMPLEINPUT]")]
        [Parameter(Position=0,Mandatory=$true,HelpMessage="Array of strings to be permutated[-target 'ant','bug,'cat','dog','elk' ]")]
            $target,
        [Parameter(Position=1,HelpMessage="Switch that causes the output to be a PSCustomObject containing Item1...ItemX entries (vs default simple string of all elements space-delimted sent to pipeline)[-AsObject]")]
            [switch]$AsObject
    ) ;
    #*------v class Permutation v------
    class Permutation {
        hidden [int[]] $data ; 
        hidden [int] $order ; 

        Permutation([int]$n){
            $this.data = New-Object int[] $n ; 
            for ($i = 0; $i -lt $n; ++$i) {
                $this.data[$i] = $i ; 
            } ; 
            $this.order = $n ; 
        }

        Permutation([int[]]$a){
            $this.data = New-Object int[] $a.Count ; 
            for ($i = 0; $i -lt $a.count ; ++$i){
                $this.data[$i] = $a[$i] ; 
            }
            $this.order = $a.Count ; 
        }

        [Permutation] Successor() {
            [Permutation]$result = [Permutation]::new($this.order)
            [int]$left=0 ; 
            [int]$right=0 ; 
            for ($k = 0; $k -lt $result.order; ++$k){
                $result.data[$k] = $this.data[$k] ; 
            } ; 
            $left = $result.order - 2 ;
            while (($result.data[$left] -gt $result.data[$left+1]) -And ($left -ge 1)) {
                --$left ; 
            } ; 
            if (($left -eq 0) -And ($this.data[$left] -gt $this.data[$left+1])) {return $null} ; 
            $right = $result.order - 1 ;
            while ($result.data[$left] -gt $result.data[$right]) {
                --$right ; 
            }
            [int]$temp = $result.data[$left] ; 
            $result.data[$left] = $result.data[$right] ; 
            $result.data[$right] = $temp ; 
            [int]$i = $left + 1 ; 
            [int]$j = $result.order - 1 ; 
            while ($i -lt $j) {
                $temp = $result.data[$i] ; 
                $result.data[$i++] = $result.data[$j] ; 
                $result.data[$j--] = $temp ; 
            } ; 
            return $result ; 
        }

        static [object] Factorial([int]$n){
            $answer = 1 ; 
            for ($i = 1; $i -le $n; ++$i){
                $answer *= $i ; 
            } ;         
            return $answer ; 
        }

        [string[]] ApplyTo([string[]] $sa){
            if ($sa.Length -ne $this.order) { throw "Bad array size in ApplyTo()" } ; 
            [string[]]$result = New-Object string[] $this.order ; 
            for ($i = 0; $i -lt $result.Length; ++$i) {
                $result[$i] = $sa[$this.data[$i]] ; 
            } ; 
            return $result ; 
        }

        [string]ToString() { return "% "+ $this.data + " %" }
    }
    #*------^ END class Permutation ^------

    $p=[Permutation]::new($target.Count) ;
    while ($p) {
        if(-not $AsObject){
            # this dumps raw string of x elements into pipe
            "$($p.ApplyTo($target))" | write-output ;
        } else { 
            # we want pscustomobject with each element as a property, not requiring post split and parsing
            $h=[ordered]@{} ; 
            $idx=1 ;
            #"$($p.ApplyTo($target))"  | foreach-object {
            $p.ApplyTo($target)  | foreach-object {
			    $h."Item$($idx)"=$_ ; 
			    ++$idx ; 
		    } ; 
		    [PSCustomObject]$h | write-output ;
        } ; 
        $p=$p.Successor() ;
    } ;
} ;
#*------^ END Function Get-PermutationTDO ^------

