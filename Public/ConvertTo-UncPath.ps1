#*------v Function ConvertTo-UncPath v------
Function ConvertTo-UncPath {

  <#
    .SYNOPSIS
    ConvertTo-UncPath - Convert a local path to UNC format (using a matching existing share on the host, if found)
    .NOTES
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-07-26
    FileName    : ConvertTo-UncPath.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Tags        : Powershell,FileSystem,Network
    REVISIONS   :
    * 12:19 PM 8/4/2022 CBH add: object-reutnr eval ; added -Test, which validates result and returns an object with the path and a 'Valid' property;  spliced in support for cim/smbshare, and rudimentary legacy net /use share checks ; added -NoValidate, just does a rote replace of :->$ on share segment. ; added -Test to post-test functoin
    * 4:35 PM 8/3/2022 init
    .DESCRIPTION
    ConvertTo-UncPath - Convert a local path to UNC format (using a matching existing share on the host, if found)
    .PARAMETER Path
    Path string to be converted [-Path c:\pathto\file]   
    .PARAMETER ComputerName
    ComputerName to be used in constructed UNC path (defaults to local computername) [-Computer Somebox]
    .PARAMETER NoValidate
    Switch to suppress explicit resolution of share (e.g. wrote conversion wo validation converted share exists on host)[-NoValidate]
    .PARAMETER Test
    Switch to run a validation test-path on the result, prior to returning converted UNCpath to pipeline[-Test]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.String
    .EXAMPLE
    PS> gci "$env:userprofile\documents" -file | select -first 1 | select -expand fullname |
    PS>     ConvertTo-uncpath -verbose | 
    PS>     ConvertFrom-UncPath -verbose ;
    Get and convert a file (1st file in user profile documents folder), and Convert specified path to UNC, and back again to local path with verbose outputs
    .EXAMPLE
    PS>  $results = convertto-uncpath -ComputerName 'SERVER' -Path 'c:\scripts\get-DAG-FreeSpace-Report.ps1' -verbose -test ; 
    PS>  if($results.valid){write-host -foregroundcolor green "Successful UNC conversion:$($results.path)"} ;
    Successful UNC conversion:\\SERVER\C$\scripts\get-DAG-FreeSpace-Report.ps1
    Demo conversion of a remote UNC path, with -Test, and evaluate object return 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    #[Alias('')]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage = 'Path string to be converted [-Path c:\pathto\file]   ')]
        [ValidateNotNullOrEmpty()]
        [String[]]$Path,
        [Parameter(HelpMessage = 'ComputerName to be used in constructed UNC path (defaults to local computername) [-Computer Somebox]')]
        [ValidateNotNullOrEmpty()]
        [string[]] $ComputerName = $env:COMPUTERNAME,
        [Parameter(HelpMessage = 'Switch to suppress explicit resolution of share (e.g. wrote conversion wo validation converted share exists on host)[-NoValidate]')]
        [switch] $NoValidate,
        [Parameter(HelpMessage = 'Switch to run a validation test-path on the result, prior to returning converted UNCpath to pipeline[-Test]')]
        [switch] $Test
    )
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
        if(-not $NoValidate){
            if($ComputerName -ne $env:COMPUTERNAME){
                TRY{
                    write-verbose "(Attempting New-CimSession -ComputerName $($computername)...)" ;
                    $cim = New-CimSession -ComputerName $computername -ErrorAction 'STOP';
                    $rshares = Get-SmbShare -CimSession $cim -ErrorAction 'STOP';
                }CATCH{
                    write-warning "(New-CimSession/Get-SmbShare FAILED, reattempting legacy:net view \\$($computername)..."
                    $rnshares = net view \\$computername /all | select -Skip 7 | ?{$_ -match 'disk*'} | %{$_ -match '^(.+?)\s+Disk*'|out-null;$matches[1]} ; 
                } 
            } else { 
                TRY{
                    write-verbose "(Attempting local Get-SmbShare...)" ;
                    $lshares = Get-SmbShare -ErrorAction 'STOP';
                } CATCH{
                    write-warning "(Get-SmbShare FAILED, reattempting Get-WmiObject -Class win32_share..."
                    $lshares = Get-WmiObject -Class win32_share ; 
                }
            } ; 
        } else { 
            write-verbose "(-NoValidate specified: doing rote unverified substitution on path-> share conversion)" ; 
        } ; 
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 

    } ;  # BEGIN-E
    PROCESS {
        foreach($item in $Path) {
            
            [array]$uncPath = @("\\$($computername)") ; 
            # resolve a matching share
            if(-not $NoValidate){
                if($lshares){
                    $tshare = ($lshares |? path -like "$(split-path $item -Qualifier)\")[0] ; # take first if a matched array returns
                } elseif($rshares){
                    $tshare = ($rshares |? path -like "$(split-path $item -Qualifier)\")[0] ; # take first if a matched array returns 
                } elseif($rnshares){
                    # legacy net /view support, doesn't include path etc, have to interpolate
                    $tshare = $rnshares | ?{$_ -like (split-path $item -Qualifier).replace(':','$').toupper()} ; 
                } else { 
                    $smsg = "Unable to resolve a suitable shares list!" ; 
                    write-warning $smsg ; 
                    throw $smsg ; 
                } ; 
            } else { 
                write-verbose "(-NoValidate:doing rote :->$ conversion on the specified path Qualifier)" ; 
                $tshare = (split-path $item -Qualifier).replace(':','$').toupper()
            } ; 
            if($tshare){
                $smsg = "(matched to existing $($computername) share:$(($tshare | ft -a Name,Path,Description|out-string).trim()))" ; 
                write-verbose $smsg ; 
                if($tshare.name){
                    $uncPath += "$($tshare.name)" ; # add matched existing sharename
                }else{
                    $uncPath += "$($tshare)" ; # add matched existing sharename
                } ; 
                $uncPath += "$(($item | split-path -noqual ).TrimStart('\'))" ; # append path, with drive Qualifier removed, and leading \ trimmed
                $uncPath = $uncPath -join '\' ; 
                if($Test){
                    $hReturn = @{
                        Valid = $FALSE ; 
                        Path = $uncPath ; 
                    } ; 
                    if($testResult = test-path -path $uncPath){
                        $hReturn.Valid = $true ;
                        write-host -foregroundcolor green "-Test:Validated: test-path -path $($uncPath)" ; 
                    } else { 
                        write-warning "-Test:FAILED TO VALIDATE: test-path -path $($uncPath)" ; 
                        $hReturn.Valid = $false ;
                    } ; 
                    $oReturn = New-Object PSObject -Property $hReturn ; 
                    $smsg = "(returning -Test object to pipeline:`n$(($oReturn|out-string).trim()))" ; 
                    write-verbose $smsg ; 
                    $oReturn | write-output ; 
                    Break ; 
                } ; 
                write-verbose "(returning converted path to pipeline:`n$($uncPath))" ; 
                $uncPath | write-output ; 
            } else { 
                $smsg = "Unable to map local path $($item) to an existing local share: `ncould not match $(split-path $item -Qualifier)\ to local shares: {0}" -f (($lshares.name -join ', ')) ; 
                write-warning $smsg ; 
                throw $smsg ; 
            } ; 
        } ; 
    } ;  # PROC-E
} ; 
#*------^ END Function ConvertTo-UncPath ^------ ;
