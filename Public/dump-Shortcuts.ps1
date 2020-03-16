function dump-Shortcuts {
    <# 
    .SYNOPSIS
    dump-Shortcuts.ps1 - Summarize a lnk file or folder of lnk files (COM wscript.shell object).
    .NOTES
    Author: Todd Kadrie (based on sample by MattG)
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 10:21 AM 3/11/2020 recoded again, renamed Summarize-Shortcuts -> dump-Shortcuts, added -xml/-csv/-json export, quicklaunch param, and verbose support, -Path defaults to desktop 
    8:29 AM 4/28/2016 rewrote and expanded, based on MattG's orig concept
    2013-02-13 18:38:52 MattG posted version
    .DESCRIPTION
    .PARAMETER Path
    Path [c:\path-to\]
    .PARAMETER QL
    QuickLaunch folder Flag [-QL]
    .PARAMETER CSV
    Export results to CSV[-CSV]
    .PARAMETER XML
    Export results to XML[-XML]
    .PARAMETER JSON
    Export results to JSON[-JSON]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns objects to the pipeline, outputs to XML or CSV
    .EXAMPLE
    $Output = dump-Shortcuts -path "C:\test" ; $Output | out-string ; 
    Summarize a folder of .lnk files. 
    .EXAMPLE
    $Output = dump-Shortcuts -path "C:\test\Pale Moon PubProf -safe-mode.lnk" ;
    Summarize a single .lnk file.
    .EXAMPLE
    write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):Desktop .lnks:" ;
    $Output = dump-Shortcuts -path [Environment]::GetFolderPath('Desktop') ;
    $Output | out-string ;
    Summarize Desktop .lnk files.
    .EXAMPLE
    $Output = dump-Shortcuts -QL  ;
    Summarize QuickLaunch (IE) folder of .lnk files. 
    .EXAMPLE
    $Output = dump-Shortcuts -QL -XML ;
    Summarize QuickLaunch (IE) folder of .lnk files, export results to XML. 
    .LINK
    https://powershell.org/wp/forums/topic/find-shortcut-targets/
    #>
    #[CmdletBinding(DefaultParameterSetName='noexport')]
    [CmdletBinding()]
    Param(
        [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage='Path [c:\path-to\]')]
        [string]$Path,
        [Parameter(HelpMessage="QuickLaunch folder Flag [-QL]")]
        [switch]$QL,
        [Parameter(ParameterSetName='CSV',HelpMessage="Export results to CSV[-CSV]")]
        [switch]$CSV,
        [Parameter(ParameterSetName='XML',HelpMessage="Export results to XML[-XML]")]
        [switch]$XML,
        [Parameter(ParameterSetName='JSON',HelpMessage="Export results to JSON[-JSON]")]
        [switch]$JSON
    ) ;    
    $Verbose=($VerbosePreference -eq 'Continue') ; 

    write-verbose -verbose:$verbose "ParameterSetName:$($PSCmdlet.ParameterSetName)" ; 
    write-verbose -verbose:$verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ; 


    if($QL -AND !$Path){
        $Path = "$([Environment]::GetFolderPath('ApplicationData'))\Microsoft\Internet Explorer\Quick Launch\" 
    } elseif($QL -AND $Path){
        throw "-QL & -Path specified: Choose one or the other" ; 
        Exit ; 
    } ; 
    If(!$Path){ 
        $Path = [Environment]::GetFolderPath("Desktop") 
        write-verbose -verbose:$true  "(No -Path specified, defaulting to Desktop folder)" ;
    };

    if(test-path $Path -pathtype Container){        
        # get all #lnks
        $Lnks = @(Get-ChildItem -Recurse -path $Path -Include *.lnk) ; 
    } elseif(test-path $Path -pathtype Leaf){    
        # get single .lnk
        $Lnks = @(Get-ChildItem -path $Path -Include *.lnk) ; 
    } else {
        write-error "$((get-date).ToString("HH:mm:ss")):INVALID -PATH: NON-FILESYSTEM CONTAINER OR FILE OBJECT";
        break ; 
    } 
    
    $Shell = New-Object -ComObject WScript.Shell ; 
    <# exposed props/methods of the $shell:
        $shell.CreateShortcut($lnk) | select *
        FullName         : [pathto]\Firefox PrivProf.lnk
        Arguments        : -no-remote -P "ToddPriv"
        Description      :
        Hotkey           :
        IconLocation     : C:\usr\home\grfx\icons\tin_omen\guy_fawkes_mask.ico,0
        RelativePath     :
        TargetPath       : C:\Program Files (x86)\Mozilla Firefox\firefox.exe
        WindowStyle      : 1
        WorkingDirectory : C:\Program Files (x86)\Mozilla Firefox
    #>
    if($host.version.major -lt 3){$Props = @{ShortcutName = $null ; } ; } 
    else { $Props = [ordered]@{ShortcutName = $null ; } ;} ; 
    $Props.Add("TargetPath",$null) ;
    $Props.Add("Arguments",$null) ;
    $Props.Add("WorkingDirectory",$null) ;
    $Props.Add("IconLocation",$null) ;
    
    if($CSV -OR $XML){$Output = @() ; } ; 
    
    foreach ($Lnk in $Lnks) {
        $Props.ShortcutName = $Lnk.Name ; 
        $Props.TargetPath = $Shell.CreateShortcut($Lnk).targetpath ; 
        $Props.Arguments = $Shell.CreateShortcut($Lnk).Arguments ;
        $Props.WorkingDirectory= $Shell.CreateShortcut($Lnk).WorkingDirectory;
        $Props.IconLocation= $Shell.CreateShortcut($Lnk).IconLocation;
        $obj = New-Object PSObject -Property $Props ;
        $obj | write-output ; 
        if($CSV -OR $XML){$Output += $obj } ; 
    } ;
    
    if($CSV -OR $XML -OR $JSON){
        $Pwd = get-location ; 
        $ofilename = "Shortcut-Summary-$(split-path -Path $Path -leaf)"
        $ofilename = [RegEx]::Replace($ofilename, "[{0}]" -f ([RegEx]::Escape(-join [System.IO.Path]::GetInvalidFileNameChars())), '') ;
        $ofile = join-path -path $pwd -childpath $ofilename ;
        if($CSV){ $ofile += ".csv" } 
        if($XML){$ofile += ".xml" }
        if($JSON){$ofile += ".json" }
        write-host -foregroundcolor green "`nExporting to: $($ofile)" ; 
    } ;     
    if($CSV){$Output| Export-Csv -Path $ofile -NoTypeInformation ; } ; 
    if($XML){$Output| Export-CLIXML -Path $ofile} ; 
    if($JSON){$Output | ConvertTo-Json | Out-File -FilePath $ofile } ; 
    
    # unload the Wscript.shell obj
    [Runtime.InteropServices.Marshal]::ReleaseComObject($Shell) | Out-Null ;
    
}
