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
    * 9:08 AM 5/19/2026 init, lifted from poshcode md archive
    .DESCRIPTION
    test-HashTDO() - Test hash value on specified file
    
    .PARAMETER SourceProfileMachine
    Source Name or IP address of the source Profile computer
    .PARAMETER MinProfile
    Switch that copies least admin-related files[-MinProfile]
    .PARAMETER ProfileBaseFiles 
    Array of profile file names that are the core essentials in every profile [-ProfileBaseFiles 'profile.ps1']
    .PARAMETER ProfileDYNFiles 
    Array of profile file with 'USERNAME' name substrings that are to be dynamically replaced w `$env:USERNAME in every profile [-ProfileDYNFiles 'profile_USERNAME.ps1']
    .PARAMETER profileCorefiles 
    Array of profile file names that are the included in every profile [-profileCorefiles 'profilex1.ps1']
    .PARAMETER profileSVCfiles 
    Array of profile file names that are the included in ServiceAccount profiles [-profileSVCfiles 'profileSvc.ps1']
    .PARAMETER profileADDLfiles 
    Array of profile file names that are the included in ServiceAccount profiles [-profileADDLfiles 'profileExtra.ps1']
    .PARAMETER ProfileUIDFiles 
    Array of profile file names that are the included in ServiceAccount profiles [-ProfileUIDFiles 'profileUID.ps1']
    .PARAMETER inclBackFill
    switch to buffer in backfill uwes\verb-xxx.ps1 module backups (source module .psm1 files renamed to .ps1)[-showDebug]
    .PARAMETER backFillDir
    Optional directory that holds backfill files (which are .ps1 named copies of installed module .psm1 files - function as loadable backups if the main module is missing/damaged; defaults to uwes) [-backFillDir c:\pathto\]
    .PARAMETER backFillFileFilter 
    Array of BackFill Leaf File filters [-backFillFileFilter @('mymodA*.ps1','mymodB*.ps1')]
    .PARAMETER backFillFileExclude 
    BackFill Leaf File Exclude Post-filter [-backFillFileExclude '-pub\.ps1$']
    Optional directory that holds backfill files (which are .ps1 named copies of installed module .psm1 files - function as loadable backups if the main module is missing/damaged; defaults to uwes) [-backFillDir c:\pathto\]
    .PARAMETER ProfileSourcePath
    Directory that holds source profile files (defaults to c`$\sc\powershell\PSProfileUID\, normally within a git source repo) [-ProfileSourcePath c:\pathto\]    
    .PARAMETER doHashes
    Switch to generate & return File hashes (via get-fileHash cmdlet)[-doHashes]
    .PARAMETER showDebug
    Show Debugging messages
    .PARAMETER whatIf
    Execute solely a test pass
    .PARAMETER Credential
    Credential object for use in accessing the computers.
    .INPUTS
    None. Doesn't accept pipeline input.
    .OUTPUTS
    System.Array returns array of matched file properties ('Name','FullName','Extension','Length','LastWriteTime','LinkType','PSParentPath','PSPath','Directory')
    .EXAMPLE
    PS> if(Test-HashTDO -FileName c:\pathto\file.ext -ExpectedHash    
    #>
    [CmdletBinding(DefaultParameterSetName="NoExpectation")]
    [Alias('test-Hash')]
    PARAM (
        [Parameter(Position=0,Mandatory=$true,HelpMessage="File to be tested")]
            [string]$FileName,
        [Parameter(Position=2,Mandatory=$true,ParameterSetName="ManualHash",HelpMessage="Expected Hash value to be tested against")]
            [string]$ExpectedHash = $(if($HashFileName){  ((Get-Content $HashFileName) -match $FileName)[0].split(" ")[0]  }),
        [Parameter(Position=1,Mandatory=$true,ParameterSetName="FromHashFile",HelpMessage="")]
            [string]$HashFileName,
        [Parameter(Position=1,Mandatory=$true,ParameterSetName="ManualHash",HelpMessage="")]
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
