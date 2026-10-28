# show-FolderTreeTDO.ps1
 
#*------v Function show-FolderTreeTDO v------
function show-FolderTreeTDO {
    <#
    .SYNOPSIS
    show-FolderTreeTDO - Display Folder/File tree using native Powershell (no module required, demi alt to PSTree module)
    .NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2026-10-15
    FileName    : show-FolderTreeTDO.ps1
    License     : MIT License
    Copyright   : (c) 2026 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Authenticode,Signature,CodeSigning,Developoment
    REVISIONS   :
    * 10:32 AM 10/28/2026 init
    .PARAMETER Path
    Path to be examined (defaults to . current location)[-Path c:\pathto]
    .PARAMETER Depth
    Recursive depth to report upon (defaults to integer maxvalue, applies to each sub item's expansion as well)[-Depth]
    .PARAMETER Files
    switch to include reporting on File objects[-Files]
    .PARAMETER Indent
    Indent string to use
    .PARAMETER FileMark
    String to be added to mark File objects in output[-FileMark F]
    .INPUTS
    Does not accept piped input.
    .OUTPUTS
    System.Object[] Outputs CustomObject to pipeline
    .DESCRIPTION
    show-FolderTreeTDO - Display Folder/File tree using native Powershell (no module required, demi alt to PSTree module)        
    .EXAMPLE
    PS> show-FolderTreeTDO C:\path -Files -Depth 2 ; 
    
        ├── _blind
        ├── cert
        ├── FaveLinks
        │   ├── AAA-9A9AAA9
        │   └── AAAAA9999
        ...

    Demo With full 2-level display of folders and leaf files
    .EXAMPLE
    PS> $return = show-FolderTreeTDO -depth 1 -path c:\cab\
    PS> $return ; 

        ── sysconfig
        ├── W11
        ├── winmerge-2.16.58.2-exe
        └── WinMergePortable(portable apps)
    
    If you capture the returned output, you have a System Object 
    .EXAMPLE
    PS> show-FolderTreeTDO -depth 1 -path c:\cab\ -Files
        ├── sysconfig
        ├── W11
        ├── winmerge-2.16.58.2-exe
        ├── WinMergePortable(portable apps)
        ├── ADMS-Portable.zip
        ...
        └── WinMergePortable_2.16.56.2.paf.exe
    Demo the way folders and files are output in same format, without differentiation, by default.
    .EXAMPLE
    PS> $return = show-FolderTreeTDO -depth 1 -path c:\cab\ -Files -filemark 'F' ; 
    PS> $return ; 

    Demo use of the -FileMark & -Files param to clearly mark and differentiate Files from folders in the output.
    #>
    [CmdletBinding()]
    [Alias('get-FolderTreeTDO')]
    Param(        
        [Parameter(Mandatory = $True,Position=0,HelpMessage = "Path to be examined (defaults to . current location)[-Path c:\pathto]")]
            [string]$Path = '.',
        [Parameter(HelpMessage = "Recursive depth to report upon (defaults to integer maxvalue, applies to each sub item's expansion as well)[-Depth]")]
            [int]$Depth = [int]::MaxValue,
        [Parameter(HelpMessage = "switch to include reporting on File objects[-Files]")]
            [switch]$Files,
        [Parameter(HelpMessage = "Indent string to use")]
            [string]$Indent = '',
        [Parameter(HelpMessage = "String to be added to mark File objects in output[-FileMark F]")]
            [string]$FileMark
    ) ;
    if ($Depth -lt 1) { return }
    foreach($pth in $Path){
        $items = Get-ChildItem -LiteralPath $pth -Force -ErrorAction SilentlyContinue |
            Where-Object { $Files -or $_.PSIsContainer } |
            Sort-Object { -not $_.PSIsContainer }, Name  
        for ($i = 0; $i -lt $items.Count; $i++) {
            $last   = $i -eq $items.Count - 1   ; 
            $branch = if ($last) { '└── ' } else { '├── ' }   ; 
            if (-not $items[$i].PSIsContainer -AND $Files -AND $Filemark) {
                "$Indent$branch$($items[$i].Name) [$($FileMark)]" | write-output  ; 
            }else{
                "$Indent$branch$($items[$i].Name)" | write-output ; 
            }
            if ($items[$i].PSIsContainer) {
                $next = $Indent + $(if ($last) { '    ' } else { '│   ' }) ; 
                show-FolderTreeTDO -Path $items[$i].FullName -Depth ($Depth - 1) -Files:$Files -Indent $next ; 
            } ; 
        } ; 
    } ;  # loop-E
    
} #*------^ END Function show-FolderTreeTDO ^------
