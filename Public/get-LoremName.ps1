#*----------v Function get-LoremName() v----------
function get-LoremName {
    <#
    .SYNOPSIS
    get-LoremName.ps1 - Return a name based on Lorem Ipsum.
    .NOTES
    Version     : 1.0.0
    Author      : JoeGasper@hotmail.com
    Website     :	https://gist.github.com/joegasper/3fafa5750261d96d5e6edf112414ae18
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-12-15
    FileName    : 
    License     : (not specified)
    Copyright   : (not specified)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,ActiveDirectory,DistinguishedName,CanonicalName,Conversion
    AddedCredit : Todd Kadrie
    AddedWebsite:	http://www.toddomation.com
    AddedTwitter:	@tostka / http://twitter.com/tostka
    Inspired to create by: https://twitter.com/MichaelBender/status/1101921078350413825?s=20
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 4:30 PM 12/15/2020 TSK: expanded CBH, 
    * 2019-03-03 
    .DESCRIPTION
    Calls public Loren Ipsum API and returns name and account name if requested.
    .INPUTS
    Count: Number of names to return
    WithAccount: Return an account name.
    .PARAMETER Count 
    Number of names to be returned
    .PARAMETER WithAccount
    Specifies to return a username with the fname/lname combo
    .EXAMPLE
    PS> Get-LoremName
        FirstName LastName
        --------- --------
        Plane     Gloriosam
    Return a name.
    .EXAMPLE
    PS> Get-LoremName -Quantity 4
        FirstName LastName
        --------- --------
        Obrutum   Peccata
        Inermis   Uti
        Epicuro   Quoddam
        Quodam    Congruens
    Return 4 names.
    .EXAMPLE
    PS> Get-LoremName -Quantity 2 -WithAccount
        FirstName  LastName UserName
        ---------  -------- --------
        Vitam      Saluto   Vitam.Saluto56
        Intellegit Hoc      Intellegit.Hoc18
    Return 2 names with account name.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding(PositionalBinding = $false)]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Number of Names to return
        [Parameter(
            ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true,ValueFromRemainingArguments = $false,Position = 0)]
        [Alias("Quantity")]
        [int]$Count = 1,
        [Parameter()][Switch]$WithAccount
    )
    Begin {
        $loremApi = 'https://loripsum.net/api/5/verylong/plaintext'
        $FirstText = 'FirstName'
        $LastText = 'LastName'
        $AccountText = 'UserName'
        $li = (Invoke-RestMethod -Uri $loremApi) -replace "\?|,|-|\.|;|:|\n", '' -split ' ' | ForEach-Object { if ($_.Length -ge 3) {(Get-Culture).TextInfo.ToTitleCase($_)}}  | Sort-Object -Unique
        $MaxNames = $li.Count - 1
    }
    Process {
        if ($WithAccount) {
            for ($i = 0; $i -lt $Count; $i++) {
                $First = $li[(Get-Random -Maximum $MaxNames)]
                $Last = $li[(Get-Random -Maximum $MaxNames)]
                $Account = "$First.$Last$(Get-Random -Maximum 99)"
                [pscustomobject](ConvertFrom-StringData "$($AccountText) = $Account `n $($LastText) = $Last `n $($FirstText) = $First" ) | Select-Object $($FirstText), $($LastText), $($AccountText)
            }
        }
        else {
            for ($i = 0; $i -lt $Count; $i++) {
                $First = $li[(Get-Random -Maximum $MaxNames)]
                $Last = $li[(Get-Random -Maximum $MaxNames)]
                [pscustomobject](ConvertFrom-StringData "$($LastText) = $Last `n $($FirstText) = $First" ) | Select-Object $($FirstText), $($LastText), $($AccountText)
            }
        }
    }
    End {
    }
}
#*------^ END Function get-LoremName ^------
