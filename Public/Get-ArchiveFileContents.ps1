# 

#region GET_ARCHIVEFILECONTENTS ; #*------v Get-ArchiveFileContents v------
function Get-ArchiveFileContents {
    <#
    .SYNOPSIS
    Get-ArchiveFileContents.ps1 - Report on contents of a given archive file (wraps Psv5+ native cmdlets, and matching legacy .net calls).
    .NOTES
    Author: Taylor Gibb
    Website:	https://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Additional Credits:
    REVISIONS   :
    * 8:27 AM 4/14/2026 init: segmented the output report from compress-ArchiveFile()
    .DESCRIPTION
    Get-ArchiveFileContents.ps1 - Report on contents of a given archive file (wraps Psv5+ native cmdlets, and matching legacy .net calls).
    
    Returns a summary object with the Path as a file system object, and the Contents 
    Uses .net System.IO.Compression.FileSystem for legacy pre-PSv5 compression, and for all output reporting (as PSv5's native compress|expand-Archive commands don't
    support dumping back reports of contents). 

    .PARAMETER Path
    Specifies the path or paths to the files that you want to add to the archive zipped file. To specify multiple paths, and include files in multiple locations, use commas to separate the paths. [-Path c:\path-to\file.ext,c:\pathto\file2.ext]
    .PARAMETER useDotNet
    Switch to use .dotNet call (force pre-Psv5 legacy support) [-useDotNet]
    .PARAMETER Raw
    Output raw Contents, without Object (which normally contains Path & Contents properties)
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns a PSCustomObject with the following properties:
    - resolved Path as a System.IO.FileInfo object
    - Contents as a System.Array object
    .EXAMPLE
    PS> $report = Get-ArchiveFileContents -path 'c:\tmp\20170411-0706AM.zip' ;
    PS> $report.Contents| ft -a ;

        FullName            Length LastWriteTime              
        --------            ------ -------------              
        20170411-0706AM.ps1    846 4/11/2017 7:08:12 AM -05:00
        24SbP1B9.ics          1514 4/6/2015 11:55:06 AM -05:00

    Report on contents of specified file
    .EXAMPLE
    PS> $report = 'c:\tmp\20170411-0706AM.ps1','c:\tmp\24SbP1B9.ics' | Get-ArchiveFileContents -verbose ;
    Pipeline example: Report content of specified file
    .EXAMPLE
    PS> Get-ArchiveFileContents -Path C:\cab\ADMS-Portable.zip  -raw ; 

            FullName                                                                           Length LastWriteTime
            --------                                                                           ------ -------------
            ActiveDirectory\ActiveDirectory.Format.ps1xml                                        5191 4/2/2020 11:56:52 AM -05:00
            ...
            
    Demo -Raw output of contents without reporting object    
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('Get-ZipFileContents','gZipFile')]
    Param(
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True,HelpMessage = "Specifies the path or paths to the files that you want to report contents of. To specify multiple paths, and include files in multiple locations, use commas to separate the paths. [-Path c:\path-to\file.ext,c:\pathto\file2.ext]")]
            [ValidateScript( { Test-Path $_ })]
            [Alias('File')]
            [string[]]$Path,
        [Parameter(HelpMessage = "Switch to use .dotNet call (force pre-Psv5 legacy support) [-useDotNet]")]
            [switch]$useDotNet,
        [Parameter(HelpMessage = "Output raw Contents, without Object (which normally contains Path & Contents properties)[-Raw]")]
            [switch]$Raw
    ) ; 
    BEGIN { 
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;

        write-verbose "(ensure System.IO.Compression.FileSystem is loaded...)" ; 
        TRY{[System.IO.Compression.ZipArchiveMode]| out-null} CATCH{Add-Type -AssemblyName System.IO.Compression} ; 
        TRY{[IO.Compression.ZipFile] | out-null} CATCH{Add-Type -AssemblyName System.IO.Compression.FileSystem} ; 

        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 
    } ;  # BEGIN-E
    PROCESS {
        $Error.Clear() ; 
                
        if($host.version.major -lt 5 -or $useDotNet){
            # check for non-compatible params
            
            TRY{
                write-verbose "(Using .Net class [System.IO.Compression.FileSystem]...)" ; 
                #Load the .NET 4.5 zip-assembly & the System.IO.Compression assembly too Note: Only necessary in *Windows PowerShell* (are automatically loaded on demand in PowerShell (Core) 7+.)
                Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

                # Verify that types from both assemblies were loaded (with TRY, these will catch out).
                [System.IO.Compression.ZipArchiveMode]| out-null; 
                [IO.Compression.ZipFile] | out-null ; 
            }CATCH{
                Write-Warning -Message $_.Exception.Message ; 
                BREAK ; 
            } ; 
        };         
                
        foreach ($item in $Path){            
            write-verbose "(preclose any open archive)" ; 
            if($ziparchive){$ziparchive.Dispose() } ;  
            write-verbose "(poll contents of -DestinationPath:$($destinationpath)...)" ;
            $contents = [System.IO.Compression.ZipFile]::OpenRead($item).Entries ; 
            $oReport = @{
                Path = $item | get-childitem ; 
                Contents = $contents | select fullname,length,lastwritetime ; 
            } ; 
            write-verbose "(returning summary object to pipeline)" ; 
            if($Raw){
                write-verbose "-raw: returning raw contents to pipeline" ; 
                New-Object PSObject -Property $oReport | select -expand Contents | write-output ; 
            }else{
                write-verbose "returning summary object to pipeline" ; 
                New-Object PSObject -Property $oReport | write-output ; 
            } ; 
        } ;  # loop-E
    }  # if-E PROC
    END{
        
    } ; 
} ; 
#endregion GET_ARCHIVEFILECONTENTS ; #*------^ END Get-ArchiveFileContents ^------