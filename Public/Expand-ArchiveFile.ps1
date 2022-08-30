#*------v Function Expand-ArchiveFile v------
function Expand-ArchiveFile {
    <#
    .SYNOPSIS
    Expand-ArchiveFile.ps1 - Decompress all files in an archive file to a destination directory (wraps Psv5+ native cmdlets and matching legacy .net ZipFile & Shell.Application calls)
    .NOTES
    Author: Taylor Gibb
    Website:	https://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Additional Credits:
    REVISIONS   :
    * 4:23 PM 8/30/2022 simplified CATCH's; updated CBH; ren -Destination -> -DestinationPath (matches expand-archive, and compress-archivefile params)
    * 1:28 PM 8/29/2022 ren Expand-ZIPFile -> Expand-ArchiveFile (alias orig name); ren source parameter File -> Path; add code to use native expand-archive on psv5+ ; 
        added try/catch support; debugged on psv51 on mybox, pipeline & useshell (older revs untested).
    * 7:28 AM 3/14/2017 updated tsk: pshelp, param() block, OTB format
    .DESCRIPTION
    Expand-ArchiveFile.ps1 - Decompress all files in an archive file to a destination directory (wraps Psv5+ native cmdlets, and matching legacy .net calls)
    
    Wrote to provide broadest support, switches bewtween:
    - PSv5+ native expand-archive 
    - .net 4.5 zipfile class support, 
    - and even oldest legacy Shell.Application Object that can work on all versions of PowerShell starting from v2 (and has no dependencies on .Net Framework)
    Note:, but this approach can be a little slower on when enumerating and copying a large number of files. 
    .PARAMETER  Path
    Source archive full path [-Path c:\path-to\Path.ext]
    .PARAMETER  DestinationPath
    Destination folder in which to expand all compressed files in the source archive [-DestinationPath c:\path-to\]
    .PARAMETER  useShell
    Switch to use shell.application COM object (broadest legacy compatibility, slower for large number of files) [-useShell]
    .PARAMETER  Overwrite
    Overwrite switch (only used pre-psv5 when not using -useShell)[-Overwrite]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    Expand-ArchiveFile -Path "C:\pathto\file.zip" -DestinationPath "c:\pathdest\" ;
    Expand content of specified file to DestinationPath
    .EXAMPLE
    Expand-ArchiveFile -Path "C:\pathto\file.zip" -DestinationPath "c:\pathdest\" -useShell ;
    Expand content of specified file to DestinationPath, fall back to legacy Shell.application support.
    .EXAMPLE
    'c:\tmp\test3.zip','c:\tmp\test2.zip' | Expand-ArchiveFile -DestinationPath "c:\pathdest\" -verbose ;
    Pipeline example: Expand content of specified file to DestinationPath
    .LINK
    https://github.com/tostka/verb-XXX
    #>
    [CmdletBinding()]
    [Alias('Expand-ZipFile')]
    Param(
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True,HelpMessage = "Source archive full path [-Path c:\path-to\Path.ext]")]
        [ValidateScript( { Test-Path $_ })]
        [Alias('File')]
        [string[]]$Path,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = "Destination folder in which to expand all compressed files in the source archive [-DestinationPath c:\path-to\]")]
        #[ValidateScript( { Test-Path $_ -PathType 'Container' })]
        [string]$DestinationPath,
        [Parameter(HelpMessage = "Overwrite switch (only used pre-psv5 when not using -useShell)[-Overwrite]")]
        [switch]$Overwrite,
        [Parameter(HelpMessage = "Switch to use shell.application COM object (broadest legacy compatibility, slower for large number of files) [-useShell]")]
        [switch]$useShell
    ) ; 
    BEGIN { 
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
         if ($PSCmdlet.MyInvocation.ExpectingInput) {
                write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
            } else {
                #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
                write-verbose "(non-pipeline - param - input)" ; 
            } ; 
    } ;  # BEGIN-E
    PROCESS {
        $Error.Clear() ; 
        foreach ($item in $Path){
                if( ($host.version.major -lt 5) -OR $useShell ){
                    TRY{
                        if($useShell){
                            write-verbose "(-useShell:Using legacy native shell.application COM object support...)" ; 
                            $shell = new-object -com shell.application ;
                            $archive = $shell.NameSpace($item) ;
                        } else { 
                          write-verbose "(Using .Net class [System.IO.Compression.ZipFile]...)" ; 
                          TRY{[System.IO.Compression.FileSystem]| out-null} CATCH{Add-Type -AssemblyName System.IO.Compression.FileSystem} ; 
                          $item = get-childitem -path $item ; 
                        } ; 
                        if(-not (test-path -path $DestinationPath)){
                            write-host "(atempting creation of missing -DestinationPath specified folder...)" ; 
                            New-Item -Path (split-path $DestinationPath) -Name (split-path $DestinationPath -leaf) -ItemType "directory" -whatif:$($whatif) ; 
                        } ; 
                    }CATCH{
                        Write-Warning -Message $_.Exception.Message; 
                        BREAK ; 
                    } ; 
                    if($useShell){
                        foreach ($item in $archive.items()) {
                            TRY{  
                                $shell.Namespace($DestinationPath).copyhere($item) ;
                            }CATCH{
                                Write-Warning -Message $_.Exception.Message ; 
                                CONTINUE ; 
                            } ;     
                        } ;  # loop-E
                    } else { 
                        TRY{
                            $entries = [IO.Compression.ZipFile]::OpenRead($item.FullName).Entries ; 
                            $entries | ForEach-Object -Process {
                                [IO.Compression.ZipFileExtensions]::ExtractToFile($_,"$($DestinationPath)\$($_)",$Overwrite) ; 
                            } ; 
                        }CATCH{
                            Write-Warning -Message $_.Exception.Message ; 
                        } ; 
                    } ; 
                } else { 
                    write-verbose "(PSv5+: using native Expand-Archive)" ; 
                    $pltEA=[ordered]@{
                        DestinationPath = $DestinationPath ; 
                        erroraction = 'STOP' ;
                        #whatif = $($whatif) ;
                    } ;
                    if ($item -match "(\[|\])") {
                        write-verbose "(angle bracket chars detected in -Path:switching to -LiteralPath support)" ; 
                        $pltEA.Add('LiteralPath',$item) ; 
                    } else {
                        $pltEA.Add('Path',$item) ; 
                    } ; 
                    $smsg = "Expand-Archive w`n$(($pltEA|out-string).trim())" ; 
                    write-host $smsg ;
                    TRY{
                        Expand-Archive @pltEA ; 
                    }CATCH{
                        Write-Warning -Message $_.Exception.Message
                    } ; 
                } ;  # if-E psv5
        } ;  # loop-E
    }  # E PROC
} ; 
#*------^ END Function  ^------
