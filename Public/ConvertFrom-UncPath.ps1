#*------v Function ConvertFrom-UncPath v------
Function ConvertFrom-UncPath {

  <#
    .SYNOPSIS
    ConvertFrom-UncPath - Converts local UNC path to local path. Note it only works if the UNC path points to a local folder. By default validates that the converted share existins on the specified host.
    .NOTES
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-07-26
    FileName    : ConvertFrom-UncPath.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Tags        : Powershell,FileSystem,Network
    REVISIONS   :
    * 12:20 PM 8/4/2022 spliced in support for cim/smbshare, and rudimentary legacy net /use share checks ; added -NoValidate, just does a rote replace of :->$ on share segment. 
    * 9:48 AM 8/3/2022 init
    .DESCRIPTION
    ConvertFrom-UncPath - Converts local UNC path to local path. Note it only works if the UNC path points to a local folder. By default validates that the converted share existins on the specified host.
    .PARAMETER Path
    UNC path to map. 
    .PARAMETER NoValidate
    Switch to suppress explicit resolution of share (e.g. wrote conversion wo validation converted share exists on host)[-NoValidate]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.String
    .EXAMPLE
    PS> gci "$env:userprofile\documents" -file | 
    PS>     select -first 1 | select -expand fullname |
    PS>     ConvertTo-uncpath -verbose | 
    PS>     ConvertFrom-UncPath -verbose ;
    Get and convert a file (1st file in user profile documents folder), and Convert specified path to UNC, and back again.
    .EXAMPLE
    PS>  convertfrom-uncpath -Path '\\SERVER\C$\scripts\get-DAG-FreeSpace-Report.ps1' -verbose ;
    Demo remote host conversion, verbose output
    .LINK
    https://github.com/tostka/verb-IO\
    #>
    [CmdletBinding()]
    [OutputType([string])]
    #[Alias('')]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage = 'Path string to be converted [-Path c:\pathto\file]   ')]
        [ValidateNotNullOrEmpty()]
        [String]$Path,
        [Parameter(HelpMessage = 'Switch to suppress explicit resolution of share (e.g. wrote conversion wo validation converted share exists on host)[-NoValidate]')]
        [switch] $NoValidate
    )
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
        
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 

    } ;  # BEGIN-E
    PROCESS {
        foreach($item in $Path) {
            if (-not (([uri]$item).IsUnc)) {
                $smsg = "Path:$($item) is not a valid UNC path" ; 
                throw $smsg ; 
            } ; 
            $UncElems = ([uri]$item).AbsolutePath -split '/' ; 
            if ( ($UncElems.Length -lt 2) -OR -not ($UncElems[1])) {
                $smsg = "Unable to map UNC path $($item) to a local path: `nUNC path must contain two or more components (\\SERVER\SHARE)" ; 
                write-warning $smsg ; 
                throw $smsg ; 
            }
            if(-not $NoValidate){
                $ComputerName  = ([uri]$item).Host ; 
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

            $shareName = $UncElems[1] ; 

            if(-not $NoValidate){
                if($lshares){
                    $tShare = $lshares | ? { $_.Name.tolower() -eq $shareName.tolower() } ; 
                } elseif($rshares){
                    $tShare = $rshares | ? { $_.Name.tolower() -eq $shareName.tolower() }
                } elseif($rnshares){
                    # legacy net /view support, doesn't include path etc, have to interpolate
                    $tshare = ($rnshares | ?{$_ -like $shareName.toupper()}).replace('$',':') ; 
                } else { 
                    $smsg = "Unable to resolve a suitable shares list!" ; 
                    write-warning $smsg ; 
                    throw $smsg ; 
                } ; 
            } else { 
                write-verbose "(-NoValidate:doing rote $->: conversion on the specified path Share segment)" ; 
                $tshare = $sharename.toupper().replace('$',':') ; 
            } ; 

            # resolve sharename to local shares
            #$tShare = $lshares | ? { $_.Name.tolower() -eq $shareName.tolower() }
            if($tShare){
                if($tShare.Path){
                    $UncElems[1] = $tShare.Path ; # use local existing share path
                } else { 
                    $UncElems[1] = $tShare ; # use local existing share path
                } ; 
                $localPath = (($uncElems[1..$($UncElems.Length-1)]) -join '\') -replace '\\\\','\' ; # append remaining elements, joined with \, and replace unc backslashes with singles
                write-verbose "(returning converted local Path to pipeline:`n$($localPath)" ; 
                $localPath | write-output ;    
            } else { 
                $smsg = "Unable to map UNC path $($item) to a local path: `ncould not match $($shareName) to local shares: {0}" -f (($lshares.name -join ',')) ; 
                write-warning $smsg ; 
                throw $smsg ; 
            } ; 
        } ; 
    } ;  # PROC-E
} ; 
#*------^ END Function ConvertFrom-UncPath ^------ ;
