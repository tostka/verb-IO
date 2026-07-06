#*----------------v Function test-HashTDO v------
function test-HashTDO {
    <#
    .SYNOPSIS
    test-HashTDO() - Test hash value on specified file
    .NOTES
    Author: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 1:42 PM 7/6/2026 fixed borked cbh specs, 
    * 9:08 AM 5/19/2026 init, lifted from poshcode md archive
    .DESCRIPTION
    test-HashTDO() - Test hash value on specified file
    
    .PARAMETER FileName
    File to be tested
    .PARAMETER ExpectedHash
    Expected Hash value to be tested against
    .PARAMETER HashFileName
    FileName (from which to auto-derive TypeOfHash)
    .PARAMETER TypeOfHash
    .INPUTS
    None. Doesn't accept pipeline input.
    .OUTPUTS
    None, console echo's hash value comparison
    .EXAMPLE
    PS> if(Test-HashTDO -FileName c:\pathto\file.ext -ExpectedHash){$true}else{$false}    
    #>
    [CmdletBinding(DefaultParameterSetName="NoExpectation")]
    [Alias('test-Hash')]
    PARAM (
        [Parameter(Position=0,Mandatory=$true,HelpMessage="File to be tested")]
            [string]$FileName,
        [Parameter(Position=2,Mandatory=$true,ParameterSetName="ManualHash",HelpMessage="Expected Hash value to be tested against")]
            [string]$ExpectedHash = $(if($HashFileName){  ((Get-Content $HashFileName) -match $FileName)[0].split(" ")[0]  }),
        [Parameter(Position=1,Mandatory=$true,ParameterSetName="FromHashFile",HelpMessage="FileName (from which to auto-derive TypeOfHash)")]
            [string]$HashFileName,
        [Parameter(Position=1,Mandatory=$true,ParameterSetName="ManualHash",HelpMessage="Type of Hash to be calculated (MD5|SHA1|SHA256|SHA384|SHA512|RIPEMD160")]
            [string[]]$TypeOfHash = $(if($HashFileName){
               [IO.Path]::GetExtension((Convert-Path $HashFileName)).Substring(1)
            } else { "MD5","SHA1","SHA256","SHA384","SHA512","RIPEMD160" })
    ) ;  
    $ofs=""
    $hashes = @{}
    foreach($Type in $TypeOfHash) {
      [string]$hash = [Security.Cryptography.HashAlgorithm]::Create(
          $Type
      ).ComputeHash( 
          [IO.File]::ReadAllBytes( (Convert-Path $FileName) )
      ) | ForEach { "{0:x2}" -f $_ }
      $hashes.$Type = $hash
    }

    if($ExpectedHash) {
        ($hashes.Values -eq $hash).Count -ge 1
    } else {
       foreach($hash in $hashes.GetEnumerator()) {
          "{0,-8}{1}" -f $hash.Name, $hash.Value
       }        
    }
} #*----------------^ END Function test-HashTDO ^--------
