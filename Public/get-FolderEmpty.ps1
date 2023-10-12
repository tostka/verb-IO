#*------v get-FolderEmpty.ps1 v------
Function get-FolderEmpty {
    <#
    .SYNOPSIS
    get-FolderEmpty.ps1 - Returns empty subfolders below specified folder (has Recusive param as well).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-21
    FileName    : get-FolderEmpty.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Markdown,Input,Conversion
    REVISION
    * 1:02 PM 10/12/2023 fix typo in proc: $folder -> $item
    * 3:22 PM 10/11/2023 init
    .DESCRIPTION
    get-FolderEmpty.ps1 - Returns empty subfolders below specified folder (has Recusive param as well)
    
    .PARAMETER Folder
	Directory from which to find empty subdirectories[-Folder c:\tmp\]
	PARAMETER Recurse
	Recurse directory switch[-Recurse]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.IO.DirectoryInfo[] Array of folder objects
    .EXAMPLE
    PS> get-FolderEmpty -folder $folder -recurse -verbose ' 
    Locate and remove empty subdirs, recursively below the specified directory (single pass, doesn't remove parent folders, see below for looping recursive).
   .EXAMPLE
	PS > $folder = 'C:\tmp\test' ;
	PS > Do {
	PS > 	write-host -nonewline "." ;
	PS > 	if($mtdirs = get-FolderEmpty -folder $folder -recurse -verbose){
	PS > 		$mtdirs | remove-item -ea 0 -verbose;
	PS > 	} ;
	PS > } Until (-not(get-FolderEmpty -folder $folder -recurse  -verbose)) ;
	Locate and remove empty subdirs, recursively below the specified directory, repeat pass until all empty subdirs are removed.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Directory from which to find empty subdirectories[-Folder c:\tmp\]")]
            [System.IO.DirectoryInfo[]]$Folder,
        [Parameter(HelpMessage="Recurse directory switch[-Recurse]")]
            [switch]$Recurse
    )  ; 
    PROCESS {
        foreach($item in $folder){
			$sBnrS="`n#*------v PROCESSING : v------" ; 
			write-verbose $sBnrS ;
			$pltGCI=[ordered]@{
				Path = $item ; 
				Directory = $true ;
				Recurse=$($Recurse) ; 
				erroraction = 'STOP' ;
			} ;
			$smsg = "get-childitem w`n$(($pltGCI|out-string).trim())" ; 
			if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
			else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
			Get-ChildItem @pltGCI | Where-Object { $_.GetFileSystemInfos().Count -eq 0 } | write-output ; 
			write-verbose $sBnrS.replace('-v','-^').replace('v-','^-') ;
        } ; 
    } ;  
} ; 
#*------^ get-FolderEmpty.ps1 ^------
