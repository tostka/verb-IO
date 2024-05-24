#*------v Function Compress-ArchiveFile v------
function Compress-ArchiveFile {
    <#
    .SYNOPSIS
    Compress-ArchiveFile.ps1 - Creates a compressed archive, or zipped file, from specified files and directories (wraps Psv5+ native cmdlets, and matching legacy .net calls).
    .NOTES
    Author: Taylor Gibb
    Website:	https://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Additional Credits:
    REVISIONS   :
    * 9:01 AM 5/23/20 24 added fully rounded out example
    * 12:36 PM 12/15/2022: add: BH example wrapping up a ticket's output files.
    * 1:54 PM 8/30/2022 looks functionally equiv compress-archive & .net calls, at least in the three use cases in the example: they produce substantially similar content in the resultant zip; expanded echos;
         emulated verbose 'splat' echos before the .net calls (aids spotting bad params); added boolean:false includerootdir on the createfromdir (avoids error if not spec'd at all); simplified all CATCH; 
         added Psv5 -force support; added psColor BP & w-h use; ren prop in output from destination -> DestinationPath; fix CBH params
    .DESCRIPTION
    Compress-ArchiveFile.ps1 - Creates a compressed archive, or zipped file, from specified files and directories (wraps Psv5+ native cmdlets, and matching legacy .net calls).
    Wrote to provide broadest support, switches bewtween:
    - PSv5+ native expand-archive 
    - .net 4.5 zipfile class support
    Returns a summary object with the DestinationPath as a file system object, and the Contents 
    Uses .net System.IO.Compression.FileSystem for legacy pre-PSv5 compression, and for all output reporting (as PSv5's native compress|expand-Archive commands don't
    support dumping back reports of contents). 

    -Path: Using wildcards with a root directory affects the archive's contents:

        - To create an archive that includes the root directory, and all its files and subdirectories,  specify the root directory in the Path without wildcards. 
            For example: `-Path C:\Reference` 
        - To create an archive that excludes the root directory, but zips all its files and subdirectories, use the asterisk (*) wildcard. 
            For example: `-Path C:\Reference\*
        - To create an archive that only zips the files in the root directory, use the star-dot-star (*.*) wildcard. Subdirectories of the root aren't included in
        the archive. 
            For example:   -Path C:\Reference\*.*
    .PARAMETER Path
    Specifies the path or paths to the files that you want to add to the archive zipped file. To specify multiple paths, and include files in multiple locations, use commas to separate the paths. [-Path c:\path-to\file.ext,c:\pathto\file2.ext]
    .PARAMETER DestinationPath
    This parameter is required and specifies the path to the archive output file. The DestinationPath should include the name of the zipped file, and either the absolute or relative path to the zipped file. [-DestinationPath c:\path-to\targetfile.zip]
    .PARAMETER CompressionLevel
    Specifies how much compression to apply when you're creating the archive file. Faster compression requires less time to create the file, but can result in larger file sizes. If this parameter isn't specified, the command uses the default value, Optimal (Fastest|NoCompression|Optimal)(only applies to PSv5+)[-CompressionLevel Optimal]
    .PARAMETER Force
    Force (overwrite existing) switch (only used with native psv5 cmdlets)[-force]
    .PARAMETER useDotNet
    Switch to use .dotNet call (force pre-Psv5 legacy support) [-useDotNet]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns a PSCustomObject with the following properties:
    - resolved DestinationPath as a System.IO.FileInfo object
    - Contents as a System.Array object
    .EXAMPLE
    PS> $zipped = Compress-ArchiveFile -path 'c:\tmp\20170411-0706AM.ps1','c:\tmp\24SbP1B9.ics' -DestinationPath "c:\tmp\test$((get-date -format 'yyyyMMdd-HHmmtt')).zip" -verbose  ;
    PS> $zipped.Contents| ft -a ;

        FullName            Length LastWriteTime              
        --------            ------ -------------              
        20170411-0706AM.ps1    846 4/11/2017 7:08:12 AM -05:00
        24SbP1B9.ics          1514 4/6/2015 11:55:06 AM -05:00

    Compress array of files to specified file (with a dynamic timestamped name)
    .EXAMPLE
    PS> $zipped = 'c:\tmp\20170411-0706AM.ps1','c:\tmp\24SbP1B9.ics' | Compress-ArchiveFile -DestinationPath "c:\tmp\test$((get-date -format 'yyyyMMdd-HHmmtt')).zip"  -verbose ;
    Pipeline example: Expand content of specified file to DestinationPath
    .EXAMPLE
    PS> $zipped = Compress-ArchiveFile -path C:\tmp\tmp\* -DestinationPath "c:\tmp\test$((get-date -format 'yyyyMMdd-HHmmtt')).zip" -verbose  ;
    PS> $zipped.DestinationPath ; 
            Directory: C:\tmp

        Mode                LastWriteTime         Length Name                                                                                                                                                         
        ----                -------------         ------ ----                                                                                                                                                         
        -a----        8/29/2022   4:24 PM           1763 test20220829-1624PM.zip            
    PS> $zipped.contents | ft -a ; 
        FullName               Length LastWriteTime                
        --------               ------ -------------                
        testsub\subfile1.txt        0 8/29/2022 3:56:46 PM -05:00  
        testsub\subfile2.txt        0 8/29/2022 3:56:54 PM -05:00  
        RDP Links mnu,expl.lnk   2252 11/18/2015 10:35:42 AM -06:00
        txt.txt                   845 7/13/2017 6:37:26 PM -05:00  

    Create archive that *excludes* the root directory, but zips all its files and subedirectories, 
    by specifying -Path with trailing asterisk (*).
    .EXAMPLE
    PS> $zipped = Compress-ArchiveFile -Path C:\tmp\tmp\ -DestinationPath "c:\tmp\test$((get-date -format 'yyyyMMdd-HHmmtt')).zip" -verbose  ;
    PS> $zipped.DestinationPath ; 
            Directory: C:\tmp
            
        Mode                LastWriteTime         Length Name                                                                                                                                                         
        ----                -------------         ------ ----                                                                                                                                                         
        -a----        8/29/2022   4:18 PM           1795 test20220829-1618PM.zip     
    PS> $zipped.contents | ft -a ;
    
        FullName                   Length LastWriteTime                
        --------                   ------ -------------                
        tmp\RDP Links mnu,expl.lnk   2252 11/18/2015 10:35:42 AM -06:00
        tmp\txt.txt                   845 7/13/2017 6:37:26 PM -05:00  
        tmp\testsub\subfile1.txt        0 8/29/2022 3:56:46 PM -05:00  
        tmp\testsub\subfile2.txt        0 8/29/2022 3:56:54 PM -05:00  

    Create that *includes* root dir & all files and subdirs, by specifying root dir path *wo wildcard*.
    .EXAMPLE
    PS> $zipped = Compress-ArchiveFile -Path C:\tmp\tmp\*.* -DestinationPath "c:\tmp\test$((get-date -format 'yyyyMMdd-HHmmtt')).zip" -verbose  ;
    PS> $zipped.DestinationPath ; 
            Directory: C:\tmp

        Mode                LastWriteTime         Length Name                                                                                                                                                         
        ----                -------------         ------ ----                                                                                                                                                         
        -a----        8/29/2022   4:28 PM           1531 test20220829-1628PM.zip 

    PS> $zipped.contents | ft -a ;
        FullName               Length LastWriteTime                
        --------               ------ -------------                
        RDP Links mnu,expl.lnk   2252 11/18/2015 10:35:42 AM -06:00
        txt.txt                   845 7/13/2017 6:37:26 PM -05:00  
    Create an archive that only zips the files in the root directory, by specifying path with star-dot-start (*.*).
    .EXAMPLE
    PS>  $ticket = '733043' ; 
    PS>  gci "d:\scripts\logs\$($ticket)*" | 
    PS>      Compress-ArchiveFile -DestinationPath "d:\scripts\$($ticket)-work-files-$(get-date -format 'yyyyMMdd-HHmmtt').zip" ; 

      -DestinationPath: *exists* (and -force not specified): using -Update, to add specified -path to existing file
      ...
      DestinationPath                                  Contents
      ---------------                                  --------
      D:\scripts\733043-work-files-20221215-1228PM.zip {@{FullName=733043-MsgTrkDetail-08dad667e195-20221206-1733PM.csv; Length=2705; LastWriteTime=12/6/2022 5:33:16 PM -06:00}, @{Fu...
    
    Demo grabbing all files in a dir with prefix, and zip down the content in a prefix-named, and timestamped zip file (wrap up ticket handling). 
    .EXAMPLE
    PS> if(test-path $outfile){
    PS>     $smsg = "Report file written" ; 
    PS>     $smsg += "`ncontains $((get-content $outfile|  measure | select -expand count |out-string).trim()) lines" ; 
    PS>     if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
    PS>     else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    PS>     $zipped = $null ; 
    PS>     $pltCmArch=[ordered]@{
    PS>         Path=$outfile ;
    PS>         DestinationPath=$outfile.replace('.csv','zip') ;
    PS>         verbose=$($VerbosePreference -eq "Continue") ;
    PS>         erroraction = 'STOP' ;
    PS>     } ;
    PS>     $smsg = "Compress-ArchiveFile w`n$(($pltCmArch|out-string).trim())" ; 
    PS>     if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;                        
    PS>     $zipped = Compress-ArchiveFile @pltCmArch ; 
    PS>     if(test-path $zipped.DestinationPath.fullname){
    PS>         $smsg = "(confirmed `$zipped present, adding to `$SmtpAttachment)" ; 
    PS>         if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
    PS>         else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
    PS>         $SmtpAttachment += $zipped.DestinationPath.fullname ; 
    PS>     } ; 
    PS> } ;
    PS> Rounded out demo (from get-HTTrafficSendersNonPrimaryAddress.ps1) that has testing, and wlt echoes  
    PS> 
    .LINK
    https://github.com/tostka/verb-XXX
    #>
    [CmdletBinding()]
    [Alias('Compress-ZipFile')]
    Param(
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True,HelpMessage = "Specifies the path or paths to the files that you want to add to the archive zipped file. To specify multiple paths, and include files in multiple locations, use commas to separate the paths. [-Path c:\path-to\file.ext,c:\pathto\file2.ext]")]
        [ValidateScript( { Test-Path $_ })]
        [Alias('File')]
        [string[]]$Path,
        [Parameter(Mandatory = $true,Position = 1,HelpMessage = "This parameter is required and specifies the path to the archive output file. The DestinationPath should include the name of the zipped file, and either the absolute or relative path to the zipped file. [-DestinationPath c:\path-to\targetfile.zip]")]
        [string]$DestinationPath,
        [Parameter(HelpMessage="Specifies how much compression to apply when you're creating the archive file. Faster compression requires less time to create the file, but can result in larger file sizes. If this parameter isn't specified, the command uses the default value, Optimal (Fastest|NoCompression|Optimal)(only applies to PSv5+)[-CompressionLevel Optimal]")]
        #[ValidateNotNullOrEmpty()]
        [ValidateSet("Fastest", "NoCompression", "Optimal", ignorecase=$True)]
        [string]$CompressionLevel='Optimal',
        [Parameter(HelpMessage = "Force (overwrite existing) switch (only used with native psv5 cmdlets)[-force]")]
        [switch]$Force,        
        [Parameter(HelpMessage = "Switch to use .dotNet call (force pre-Psv5 legacy support) [-useDotNet]")]
        [switch]$useDotNet
    ) ; 
    BEGIN { 
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        $whWarn =@{BackgroundColor = 'Yellow' ; ForegroundColor = 'Black' } ;
        $whErr =@{BackgroundColor = 'Red' ; ForegroundColor = 'White' } ;
        $whGood =@{BackgroundColor = 'DarkGreen' ; ForegroundColor = 'White' } ;
        $whNote =@{BackgroundColor = 'White' ; ForegroundColor = 'Black' } ;
        $whComment =@{BackgroundColor = 'Black' ; ForegroundColor = 'Gray' } ;
        $whBnr =@{BackgroundColor = 'Magenta' ; ForegroundColor = 'Black' } ;
        $whBnrS =@{BackgroundColor = 'Blue' ; ForegroundColor = 'Cyan' } ;

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
            
            if($PSBoundParameters.ContainsKey('Force')){
                write-host "Note: -Force specified, but will not be used with legacy dotNet cmds (which do not support it)" @whWarn ; 
            } ;

            TRY{
                write-verbose "(Using .Net class [System.IO.Compression.FileSystem]...)" ; 
                #Load the .NET 4.5 zip-assembly & the System.IO.Compression assembly too Note: Only necessary in *Windows PowerShell* (are automatically loaded on demand in PowerShell (Core) 7+.)
                Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem

                # Verify that types from both assemblies were loaded (with TRY, these will catch out).
                [System.IO.Compression.ZipArchiveMode]| out-null; 
                [IO.Compression.ZipFile] | out-null ; 
                write-verbose "(convert compression level string to [System.IO.Compression.CompressionLevel])" ; 
                [System.IO.Compression.CompressionLevel]$CompressionLevel = $CompressionLevel ;   
            }CATCH{
                Write-Warning -Message $_.Exception.Message ; 
                BREAK ; 
            } ; 
        };         
                
        foreach ($item in $Path){
                #if( ($host.version.major -lt 5) -OR $useShell ){
                if($host.version.major -lt 5 -or $useDotNet){
                    
                    TRY{
                        <# - To create an archive that includes the root directory, and all its files and subdirectories,  specify the root directory in the Path without wildcards. 
                        For example: `-Path C:\Reference` 
                        - To create an archive that excludes the root directory, but zips all its files and subdirectories, use the asterisk (*) wildcard. 
                        For example: `-Path C:\Reference\*
                        - To create an archive that only zips the files in the root directory, use the star-dot-star (*.*) wildcard. Subdirectories of the root aren't included in
                        the archive. 
                        For example:   -Path C:\Reference\*.*
                        #>
                        
                        #detect & 'fake' the variants that compress-archive natively does as determined by input -Path spec:
                        $Recurse = $InclRoot = $false ; 
                        switch -regex ($item){
                            #-Path C:\tmp\tmp\*.*
                            '\\\*\.\*$' {
                                $smsg = "(`n$($item):Create archive that only zips the files in the root directory" ; 
                                $smsg += "`nget-childitem $($item)`n)" ; 
                                write-verbose $smsg ; 
                                $item = (get-childitem -path $item -ErrorAction STOP); 
                            }  
                            #-Path C:\tmp\tmp\ 
                            '\\$' {
                                $smsg = "(`n$($item):Create archive that *includes* root dir & all files and subdirs" ; 
                                $smsg += "CreateFromDirectory($srcDir, $DestinationPath, $CompressionLevel,$includeBaseDir)`n)" ; 
                                write-verbose $smsg ; 
                                $Recurse  = $true ; 
                                $InclRoot = $true ; 
                                #$item = (get-childitem -path $item -recurse -ErrorAction STOP); 
                            } 
                            #-Path C:\tmp\tmp\*
                            '\\\*$' {
                                $smsg = "(`n$($item):Create archive that *excludes* the root directory, but zips all its files and subdirectories" ; 
                                $smsg += "CreateFromDirectory($srcDir, $DestinationPath, $CompressionLevel)`n)" ; 
                                write-verbose $smsg ; 
                                $Recurse  = $true ; 
                                $InclRoot = $false ; 
                                #$item = (get-childitem -path $item -recurse -ErrorAction STOP); 
                            } 
                            default {
                                $smsg = "(`n$($item):Create archive from specified file(s)`n" ; 
                                $smsg += "get-childitem specified `$ite)`n)" ; 
                                write-verbose $smsg ; 
                                $item = (get-childitem -path $item -ErrorAction STOP); 
                            }
                        } ; 

                        if($Recurse){
                            write-verbose "(CreateFromDirectory:resolve `$srcDir absolute source directory)" ; 
                            if($InclRoot){
                                # x:\xx\
                                $srcDir = (get-item -path $item -ErrorAction STOP).fullname; 
                            } else { 
                                # x:\xx\*
                                $srcDir = (split-path $item -ErrorAction STOP); 
                            } ; 
                            if(test-path -path $DestinationPath){
                                write-host "(removing conflicting existing file:`n$($DestinationPath)`n(CreateFromDirectory doesn't support 'Update', only 'Create')" @pltWarn ;  
                                remove-item -path $DestinationPath -force ; 
                            } ; 
                        } ; 
                        if($Recurse -AND $InclRoot ){
                            # Create that *includes* root dir & all files and subdirs
                            # $null = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($ziparchive,$addFile,$entryName,$compressionLevel) ; 
                            <# [ZipFile.CreateFromDirectory Method (System.IO.Compression) | Microsoft Docs - docs.microsoft.com/](https://docs.microsoft.com/en-us/dotnet/api/system.io.compression.zipfile.createfromdirectory?view=net-6.0)
                                Parameters
                                    sourceDirectoryName,String
                                    The path to the directory to be archived, specified as a relative or absolute path. A relative path is interpreted as relative to the current working directory.
                                    destinationArchiveFileName,String
                                    The path of the archive to be created, specified as a relative or absolute path. A relative path is interpreted as relative to the current working directory.
                                    compressionLevel,CompressionLevel
                                    One of the enumeration values that indicates whether to emphasize speed or compression effectiveness when creating the entry.
                                    includeBaseDirectory,Boolean
                                    true to include the directory name from sourceDirectoryName at the root of the archive; false to include only the contents of the directory.
                                public static void CreateFromDirectory (string sourceDirectoryName, string destinationArchiveFileName, System.IO.Compression.CompressionLevel compressionLevel, bool includeBaseDirectory);
                            #>
                            $includeBaseDir = $inclRoot ; 
                            #$null = [System.IO.Compression.ZipFile]::CreateFromDirectory($Item, $DestinationPath, $CompressionLevel,$includeBaseDir)
                            $smsg = "CreateFromDirectory w" ;
                            $smsg += "`nsourceDirectoryName:$($srcDir)" ; 
                            $smsg += "`ndestinationArchiveFileName:$($DestinationPath)" ;
                            $smsg += "`ncompressionLevel:$($CompressionLevel)" ;
                            $smsg += "`nincludeBaseDir:$($includeBaseDir)" ;
                            write-verbose $smsg 
                            $null = [System.IO.Compression.ZipFile]::CreateFromDirectory($srcDir, $DestinationPath, $CompressionLevel,$includeBaseDir) ; 
                            # dest file can't prexist: throws: "The file 'c:\tmp\test20220829-1806PM.zip' already exists."
                        }elseif($Recurse -AND -not($InclRoot) ){
                            # Create archive that excludes the root directory, but zips all its files and subdirectories
                            $includeBaseDir = $inclRoot ; 
                            $smsg = "CreateFromDirectory w" ;
                            $smsg += "`nsourceDirectoryName:$($srcDir)" ; 
                            $smsg += "`ndestinationArchiveFileName:$($DestinationPath)" ;
                            $smsg += "`ncompressionLevel:$($CompressionLevel)" ;
                            $smsg += "`nincludeBaseDir:$($includeBaseDir)" ;
                            write-verbose $smsg 
                            #$null = [System.IO.Compression.ZipFile]::CreateFromDirectory($srcDir, $DestinationPath, $CompressionLevel) ; 
                            # err: Cannot find an overload for "CreateFromDirectory" and the argument count: "3". add includeBaseDir (which is false)
                            $null = [System.IO.Compression.ZipFile]::CreateFromDirectory($srcDir, $DestinationPath, $CompressionLevel,$includeBaseDir) ; 
                        } else { 
                            write-verbose "(create empty zipfile)" ; 
                            if(-not (test-path -path $DestinationPath)){
                                # create empty
                                $smsg = "ZipFile::Open w" ;
                                $smsg += "`narchiveFileName:$($DestinationPath)" ;
                                $smsg += "`nmode:[System.IO.Compression.ZipArchiveMode]::Create)" ;
                                write-verbose $smsg 
                                [System.IO.Compression.ZipArchive]$ziparchive = [System.IO.Compression.ZipFile]::Open($DestinationPath,([System.IO.Compression.ZipArchiveMode]::Create)) ; 
                                $ziparchive.dispose() ; # have to close or the open below fails "because it is being used by another process."
                            } ;  
                            write-verbose "(Access archive for Update)" ; 
                            $smsg = "ZipFile::Open w" ;
                            $smsg += "`narchiveFileName:$($DestinationPath)" ;
                            $smsg += "`nmode:Update" ;
                            write-verbose $smsg 
                            $ziparchive = [System.IO.Compression.ZipFile]::Open( $DestinationPath, "Update" ) ; 
                            write-verbose "add file:$($item.fullname -join ', ')" ; 
                            # The compression function likes relative file paths...
                            # $relativefilepath = (Resolve-Path $item.fullname -Relative).TrimStart(".\") ; 
                            #[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($ziparchive, $item.fullname, (Split-Path $item.fullname -Leaf), $compressionLevel)
                            #[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($ziparchive, $item.fullname, $relativefilepath, $compressionLevel)
                            # loop the item if it's an array (acommodates singletons as well)
                            $item | ForEach-Object {
                                
                                $addFile = $_.fullName ; 
                                # typically would use releative paths... 
                                # it's not equivelent: compress-archive doesn't use relative paths as the EntryNames, it uses the leafname
                                $entryName = (Split-Path $addFile -Leaf) ; 
                                    
                                $smsg = "ZipFileExtensions::CreateEntryFromFile w" ;
                                $smsg += "`ndestination:$($ziparchive)" ;
                                $smsg += "`nsourceFileName:$($addFile)" ;
                                $smsg += "`nentryName:$($entryName)" ;
                                $smsg += "`ncompressionLevel:$($CompressionLevel)" ;
                                write-verbose $smsg 
                                $null = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($ziparchive,$addFile,$entryName,$compressionLevel) ; 
                            } ; 
                        } ; 
                        # createdir doesn't have a pre-loaded $ziparchive, only close if populated
                        if($ziparchive){
                            write-verbose "(dispose `$ziparchive object before moving on)" ; 
                            $ziparchive.Dispose() ;
                        } ;  
                    }CATCH{
                        Write-Warning -Message $_.Exception.Message ; 
                    } ; 
                    
                } else { 
                    write-verbose "(PSv5+ detected: using native Compress-Archive cmdlet)" ; 
                    
                    $pltCA=[ordered]@{
                        Destination = $destinationpath ; 
                        CompressionLevel = $CompressionLevel ; 
                        erroraction = 'STOP' ;
                        #whatif = $($whatif) ;
                        verbose = $($VerbosePreference -eq "Continue") ;
                    } ;
                    if((test-path -path $DestinationPath) -AND -not($Force)){
                        write-host "-DestinationPath: *exists* (and -force not specified): using -Update, to add specified -path to existing file" @whNote ; 
                        $pltCA.Add('Update',$true) ; 
                    } elseif((test-path -path $DestinationPath) -and $force){
                        write-host "-DestinationPath: *exists*, and -force specified: Forcing overwrite of existing file" @whNote ; 
                        $pltCA.Add('Force',$true) ; 
                    } ; 
                    if ($item -match '[*]+') {
                        # literalpath doesn't support wildcard *. use -path
                        $pltCA.Add('Path',$item) ; 
                    }elseif ($item -match '[\[\]]+') {
                        write-verbose "(angle bracket chars detected in -Path:switching to -LiteralPath support)" ; 
                        $pltCA.Add('LiteralPath',$item) ; 
                    } else {
                        $pltCA.Add('LiteralPath',$item) ;
                    } ; 
                    $smsg = "Compress-Archive w`n$(($pltCA|out-string).trim())" ; 
                    write-verbose $smsg ;
                    TRY{
                        Compress-Archive @pltCA
                    }CATCH{
                        Write-Warning -Message $_.Exception.Message
                    } ; 
                } ;  # if-E psv5
        } ;  # loop-E
    }  # if-E PROC
    END{
        write-verbose "(ensure System.IO.Compression.FileSystem is loaded...)" ; 
        TRY{[System.IO.Compression.ZipArchiveMode]| out-null} CATCH{Add-Type -AssemblyName System.IO.Compression} ; 
        TRY{[IO.Compression.ZipFile] | out-null} CATCH{Add-Type -AssemblyName System.IO.Compression.FileSystem} ; 
        write-verbose "(preclose any open archive)" ; 
        if($ziparchive){$ziparchive.Dispose() } ;  
        write-verbose "(poll contents of -DestinationPath:$($destinationpath)...)" ;
        $contents = [System.IO.Compression.ZipFile]::OpenRead($destinationpath).Entries ; 
        $oReport = @{
            DestinationPath = $DestinationPath | get-childitem ; 
            Contents = $contents | select fullname,length,lastwritetime ; 
        } ; 
        write-verbose "(returning summary object to pipeline)" ; 
        New-Object PSObject -Property $oReport | write-output ; 
    } ; 
} ; 
#*------^ END Function  ^------
