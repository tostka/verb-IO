﻿# verb-IO.psm1

<#
.SYNOPSIS
verb-IO - Powershell Input/Output generic functions module
.NOTES
Version     : 1.0.0.0.0
Author      : Todd Kadrie
Website     :	https://www.toddomation.com
Twitter     :	@tostka
CreatedDate : 3/16/2020
FileName    : verb-IO.psm1
License     : MIT
Copyright   : (c) 3/16/2020 Todd Kadrie
Github      : https://github.com/tostka
AddedCredit : REFERENCE
AddedWebsite:	REFERENCEURL
AddedTwitter:	@HANDLE / http://twitter.com/HANDLE
REVISIONS
* 3/16/2020 - 1.0.0.0
* 5:10 PM 3/15/2020 fixed damange from public conv (ABC->tor & tol)
* 6:30 PM 2/28/2020 added ColorMatch(), extract-Icon
* 4:37 PM 2/27/2020 Added Add-PsTitleBar()/Remove-PsTitleBar()
* 6:32 PM 2/25/2020 updated get-fileencoding/get-fileencodingextended, & convert-fileencoding - set-content won't take the .net encoding type, as it's -encoding param
* 8:57 AM 2/21/2020 added trim-FileList()
* 8:48 AM 1/3/2020 transplanted from incl-desktop: Expand-ZIPFile ; Get-FileEncoding ; Convert-FileEncoding ; convertTo-Base64String ; Get-Shortcut ; Set-Shortcut ; Find-LockedFileProcess ; Get-FsoTypeObj ; Get-FsoShortName
* 12:03 PM 12/29/2019 added else wh on pswls entries
* 12:36 PM 12/28/2019 updated load block, added: remove-ItemRetry
* 12:14 PM 12/27/2019 init version
.DESCRIPTION
verb-IO - Powershell Input/Output generic functions module
.LINK
https://github.com/tostka/verb-IO
#>


$script:ModuleRoot = $PSScriptRoot ; 
$script:ModuleVersion = (Import-PowerShellDataFile -Path (get-childitem $script:moduleroot\*.psd1).fullname).moduleversion ; 



#*------v Add-PSTitleBar.ps1 v------
Function Add-PSTitleBar {
    <#
    .SYNOPSIS
    Add-PSTitleBar.ps1 - Append specified identifying Tag string to the end of the powershell console Titlebar
    .NOTES
    Version     : 1.0.1
    Author      : dsolodow
    Website     :	https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    Twitter     :	
    CreatedDate : 2014-11-12
    FileName    : 
    License     : 
    Copyright   : 
    Github      : 
    Tags        : Powershell,Console
    REVISIONS
    * 4:37 PM 2/27/2020 updated CBH
    # 8:44 AM 3/15/2017 ren Update-PSTitleBar => Add-PSTitleBar, so that we can have a Remove-PSTitleBar, to subtract
    # 8:42 AM 3/15/2017 Add-PSTitleBar for addition, before adding
    # 11/12/2014 - posted version
    .DESCRIPTION
    Add-PSTitleBar.ps1 - Append specified identifying Tag string to the end of the powershell console Titlebar
    Inspired by dsolodow's Update-PSTitleBar code
    .PARAMETER Tag
    Tag string to be added to current powershell console Titlebar
    .EXAMPLE
    Add-PSTitleBar 'EMS'
    Add the string 'EMS' to the powershell console Title Bar
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    Param ([parameter(Mandatory = $true,Position=0)][String]$Tag)
    #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
    If ($host.name -eq 'ConsoleHost') {
        # don't add if already present
        if($host.ui.RawUI.WindowTitle -like "*$($Tag)*"){}
        else{$host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle+" $Tag "} ;
    } ;
}

#*------^ Add-PSTitleBar.ps1 ^------

#*------v backup-File.ps1 v------
function backup-File {
    <#
    .SYNOPSIS
    backup-File.ps1 - Create a backup of specified script
    .NOTES
    Version     : 1.0.2
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 1:43 PM 11/16/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 9:12 AM 12/29/2019 switch output to being the backupfile name ($pltBu.destination ), or $false for fail
    * 9:34 AM 12/11/2019 added dyanamic recycle of existing ext (got out of hardcoded .ps1)
    * 1:43 PM 11/16/2019 init
    .DESCRIPTION
    backup-File.ps1 - Create a backup of specified script
    .PARAMETER  Path
    Path to script
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    $bRet = backup-File -path $oSrc.FullName -showdebug:$($showdebug) -whatif:$($whatif)
    if (!$bRet) {throw "FAILURE" } ;
    Backup specified file
    .LINK
    #>
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to script[-Path path-to\script.ps1]")]
        [ValidateScript( { Test-Path $_ })]$Path,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    if ($Path.GetType().FullName -ne 'System.IO.FileInfo') {
        $Path = get-childitem -path $Path ;
    } ;
    $pltBu = [ordered]@{
        path        = $Path.fullname ;
        destination = $Path.fullname.replace($Path.extension, "$($Path.extension)_$(get-date -format 'yyyyMMdd-HHmmtt')") ;
        ErrorAction="Stop" ;
        whatif      = $($whatif) ;
    } ;
    $smsg = "BACKUP:copy-item w`n$(($pltBu|out-string).trim())" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    $Exit = 0 ;
    Do {
        Try {
            copy-item @pltBu ;
            $Exit = $Retries ;
        }
        Catch {
            $ErrorTrapped = $Error[0] ;
            Write-Verbose "Failed to exec cmd because: $($ErrorTrapped)" ;
            Start-Sleep -Seconds $RetrySleep ;
            # reconnect-exo/reconnect-ex2010
            $Exit ++ ;
            Write-Verbose "Try #: $Exit" ;
            If ($Exit -eq $Retries) { Write-Warning "Unable to exec cmd!" } ;
        }  ;
    } Until ($Exit -eq $Retries) ;

    # validate copies *exact*
    if (!$whatif) {
        if (Compare-Object -ReferenceObject $(Get-Content $pltBu.path) -DifferenceObject $(Get-Content $pltBu.destination)) {
            $smsg = "BAD COPY!`n$pltBu.path`nIS DIFFERENT FROM`n$pltBu.destination!`nEXITING!";
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error }  #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $false | write-output ;
        }
        Else {
            if ($showDebug) {
                $smsg = "Validated Copy:`n$($pltbu.path)`n*matches*`n$($pltbu.destination)"; ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
            #$true | write-output ;
            $pltBu.destination | write-output ;
        } ;
    } else {
        #$true | write-output ;
        $pltBu.destination | write-output ;
    };
}

#*------^ backup-File.ps1 ^------

#*------v ColorMatch.ps1 v------
function ColorMatch {
    <#
    .SYNOPSIS
    ColorMatch.ps1 - Write-Host variant: Accepts piped input, with a regex as a parameter, and highlights any text matching the regex
    .NOTES
    Author: latkin
    Website:	https://stackoverflow.com/users/1366219/latkin
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	URL
    Twitter:	URL
    REVISIONS   :
    * 9/26/2012 - Posted version
    .DESCRIPTION
    Write-Host variant: Accepts piped input, with a regex as a parameter, and highlights any text matching the regex
    .PARAMETER  InputObject
    Object to be highlit & write-host'd
    .PARAMETER  Pattern
    Regex for the text to be highlit
    .PARAMETER  Color
    Write-host -foregroundcolor to be used for the highlight
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Write-hosts highlit content to console
    .EXAMPLE
    "$mailbox" | ColorMatch "Item count: [0-9]*" ;
    Highlight the $mailbox object with portion matching the regex (Position 0 is pattern)
    .LINK
    https://stackoverflow.com/questions/12609760
    #>
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $InputObject,

        [Parameter(Mandatory = $true, Position = 0)]
        [string] $Pattern,

        [Parameter(Mandatory = $false, Position = 1)]
        [string] $Color='Red'
    )
    begin{ $r = [regex]$Pattern }
    process {
        $ms = $r.matches($inputObject) ;
        $startIndex = 0 ;
        foreach($m in $ms) {
            $nonMatchLength = $m.Index - $startIndex ;
            Write-Host $inputObject.Substring($startIndex, $nonMatchLength) -NoNew ;
            Write-Host $m.Value -Fore $Color -NoNew ;
            $startIndex = $m.Index + $m.Length ;
        } ;
        if($startIndex -lt $inputObject.Length) {
            Write-Host $inputObject.Substring($startIndex) -NoNew ;
        } ;
        Write-Host ;
    }
}

#*------^ ColorMatch.ps1 ^------

#*------v Convert-FileEncoding.ps1 v------
function Convert-FileEncoding {
    <#
    .SYNOPSIS
    Convert-FileEncoding.ps1 - Converts files to the given encoding.
    .NOTES
    Author: jpoehls
    Website:	https://gist.github.com/jpoehls/2406504
    REVISIONS   :
    *  3:08 PM 6/16/2017 added more pshelp, added functional -whatif support
    * Apr 17, 2012 posted vers
    .DESCRIPTION
    Convert-FileEncoding.ps1 - Converts files to the given encoding.
    Matches the include pattern recursively under the given path.
    .PARAMETER Include
    File filter  [-include *.ps1]
    .PARAMETER Path
    Path [-path c:\path-to\]
    .PARAMETER Encoding
    Encoding [-encoding 'UTF8']
    Out-file Supports: unicode,bigendianunicode,utf8,utf7,utf32,ascii,default,oem
    .PARAMETER showDebug
    Debugging Flag [-showDebug]
    .PARAMETER whatIf
    Whatif Flag  [-whatIf]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    Convert-FileEncoding -Include *.js -Path scripts -Encoding UTF8 ;
    .EXAMPLE
    .LINK
    https://gist.github.com/jpoehls/2406504
    #>
    # switch -Path from required container, to something that can be resolved
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "File filter  [*.ps1]")]
        [string]$Include,
        [Parameter(HelpMessage = "Path [-path c:\path-to\]")]
        [ValidateScript( { Test-Path $_ -PathType 'Container' })][string]$Path,
        [Parameter(HelpMessage = "Encoding [-encoding 'UTF8']")]
        [string]$Encoding = 'UTF8',
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    )  ;
    BEGIN { $count = 0 } ; 
    PROCESS {
        Get-ChildItem -Include $Pattern -Recurse -Path $Path |
        select FullName, @{n = 'Encoding'; e = { Get-FileEncoding $_.FullName } } |
        where-object { $_.Encoding -ne $Encoding } | % {
            (Get-Content $_.FullName) |
            Out-File $_.FullName -Encoding $Encoding -whatif:$($whatif); $count++;
        } ;
    } ; 
    END {write-verbose -verbose:$true "$count $Pattern file(s) converted to $Encoding in $Path." } ; 
}

#*------^ Convert-FileEncoding.ps1 ^------

#*------v convertTo-Base64String.ps1 v------
function convertTo-Base64String {
    <#
    .SYNOPSIS
    convertTo-Base64String - Convert specified file to Base64 encoded string and return to pipeline
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2019-12-13
    FileName    : convertTo-Base64String.ps1
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 8:26 AM 12/13/2019 convertTo-Base64String:init
    .DESCRIPTION
    convertTo-Base64String - Convert specified file to Base64 encoded string and return to pipeline
    .PARAMETER  path
    File to be Base64 encoded (image, text, whatever)[-path path-to-file]
    .EXAMPLE
    .\convertTo-Base64String.ps1 C:\Path\To\Image.png >> base64.txt ; 
    .EXAMPLE
    .\convertTo-Base64String.ps1
    .LINK
    #>
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="File to be Base64 encoded (image, text, whatever)[-path path-to-file]")]
        [ValidateScript({Test-Path $_})][String]$path
    ) ;
    [convert]::ToBase64String((get-content $path -encoding byte)) | write-output ; 
}

#*------^ convertTo-Base64String.ps1 ^------

#*------v dump-Shortcuts.ps1 v------
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

#*------^ dump-Shortcuts.ps1 ^------

#*------v Expand-ZIPFile.ps1 v------
function Expand-ZIPFile {
    <#
    .SYNOPSIS
    VERB-NOUN.ps1 - 1LINEDESC
    .NOTES
    Author: Taylor Gibb
    Website:	https://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Additional Credits:
    REVISIONS   :
    * 7:28 AM 3/14/2017 updated tsk: pshelp, param() block, OTB format
    * 06/13/13 (posted version)
    .DESCRIPTION
    .PARAMETER  Destination
    Destination for zip file contents [-Destination c:\path-to\]
    .PARAMETER  File
    File [-file c:\path-to\file.zip]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    Expand-ZIPFile -File "C:\pathto\file.zip" -Destination "c:\pathdest\" ;
    .LINK
    https://www.howtogeek.com/tips/how-to-extract-zip-files-using-powershell/
    #>

    # ($file, $destination)
    Param(
        [Parameter(HelpMessage = "Path [-Destination c:\path-to\]")]
        [ValidateScript( { Test-Path $_ -PathType 'Container' })][string]$Destination,
        [Parameter(HelpMessage = "File [-file c:\path-to\file.ext]")]
        [ValidateScript( { Test-Path $_ })][string]$File,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) # PARAM BLOCK END
    $shell = new-object -com shell.application ;
    $zip = $shell.NameSpace($file) ;
    foreach ($item in $zip.items()) {
        $shell.Namespace($destination).copyhere($item) ;
    } ;
}

#*------^ Expand-ZIPFile.ps1 ^------

#*------v extract-Icon.ps1 v------
Function extract-Icon {
    <#
    .SYNOPSIS
    extract-Icon - Exports an ico from a given source to a given destination (file, if OutputIconFilename specified, to pipeline, if not)
        .Description
    .NOTES
    Version     : 1.1.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    :
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    AddedCredit : Chrissy LeMaire (IconExport.psm1 DLL extract code)
    AddedWebsite: https://social.technet.microsoft.com/profile/chrissy%20lemaire/
    AddedTwitter: @cl / http://twitter.com/cl
    AddedCredit : MS Docs - Icon.ExtractAssociatedIcon(String) Method (System.Drawing ... docs.microsoft.com
    AddedWebsite: https://docs.microsoft.com/en-us/dotnet/api/system.drawing.icon.extractassociatedicon
    AddedTwitter:
    REVISIONS
    * 8:17 AM 2/28/2020 updated CBH, made AdvFunc, added verbose
    * 10:03 AM 3/10/2016: MyAccount: retooled ; substantially expanded. Added      It also will either hand back an Icon-type variable, or if you spec an OutputIconfFileName, it writes the extracted icon file out and returns the $OutputIconFileName to confirm success.
    * 1.1 2012.03.8 posted version
    .DESCRIPTION
    extract-Icon.ps1 - Exports an ico from a given source to a given destination (file, if OutputIconFilename specified, to pipeline, if not)
    Grab the shell32.dll's 238'th iconinto a pointer that can be reassigned to a Traytip:
    $TrayIcon=extract-Icon -SourceFilePath (join-path -path $($env:WINDIR) "System32\shell32.dll") -IconIndex 238 -ExportIconResolution 16 ;
    extract-Icon -SourceFilePath (join-path -path $($env:WINDIR) "System32\shell32.dll") -IconIndex 238  ;
    dll's contain arrays of icons, need to pick one.
    Uses DLL extract code from Chrissy LeMaire & and stock docs.MS [System.Drawing.Icon]::ExtractAssociatedIcon EXE-extract code.
    .PARAMETER Path
    Source Exe/DLL to extract Icon from
    .PARAMETER Index
    Optional Icon Index Number (only used for DLL's)
    .PARAMETER OutputPath
    Optional Output path for extracted .ico file (if blank, returns the extracted Icon object)[c:\path-to\test.ico]
    .PARAMETER Resolution
    Optional Icon Output Resolution [264|128|48|32|16]
    .OUTPUT
    Creates a suitable .ico file at the OutputPath, returns the path to the created file to the pipeline.
    .EXAMPLE
    $TrayIcon = extract-Icon -Path C:\WINDOWS\system32\calc.exe -Index 0 -Resolution 48 ;
    .EXAMPLE
    $TrayIcon=extract-Icon -Path $env:WINDIR\System32\shell32.dll -Index 238 -Resolution 16 ;
    Grab the shell32.dll's 238'th icon into a variable that can be reassigned to a Traytip icon:
    .LINK
    https://gallery.technet.microsoft.com/scriptcenter/Export-Icon-from-DLL-and-9d309047
    #>
    [CmdletBinding()]
    Param (
        [parameter(Mandatory = $true,HelpMessage="Source Exe/DLL to extract Icon from")]
        [Alias('SourceFilePath')]
        [ValidateScript({Test-Path $_ | ?{-not $_.PSIsContainer}})]
        [string]$Path,
        [parameter(Mandatory = $false,HelpMessage="Optional Output path for extracted .ico file (if blank, returns the extracted Icon object)[c:\path-to\test.ico]")]
        [Alias('OutputIconFileName')]
        [string]$OutputPath,
        [parameter(HelpMessage="Optional Icon Index Number (Required for DLL's) [-Index 2]")]
        [Alias('IconIndex')]
        [int]$Index,
        [parameter(HelpMessage="Optional Icon Output Resolution [264|128|48|32|16]")]
        [ValidateSet(256,128,48,32,16)]
        [Alias('ExportIconResolution')]
        [int]$Resolution
    ) ;
    BEGIN{
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        # code that provides the DLL-extracting functions
        $code = @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;
namespace System
{
public class IconExtractor
{
 public static Icon Extract(string file, int number, bool largeIcon)
 {
  IntPtr large;
  IntPtr small;
  ExtractIconEx(file, number, out large, out small, 1);
  try
  {
   return Icon.FromHandle(largeIcon ? large : small);
  }
  catch
  {
   return null;
  }
 }
 [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
 private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);
}
}
"@ ;
    } ;
    PROCESS{

        $error.clear() ;
        TRY {
            if(test-path -path $Path){
                If ( $Path.tolower().Contains(".dll") ) {
                    If(!($Index)){$Index = Read-Host "Missing Index param: Enter the target icon index: " } ;
                    # load the DLL extract code from the here string
                    Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing ;
                    $Icon = [System.IconExtractor]::Extract($Path, $Index, $true)  ;
                } ElseIf ( $Path.tolower().Contains(".exe") ) {
                    [void][Reflection.Assembly]::LoadWithPartialName("System.Drawing") ;
                    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") ;
                    $Image = [System.Drawing.Icon]::ExtractAssociatedIcon("$($Path)").ToBitmap() ;
                    # image needs to be converted to bitmap and then into icon
                    $Bitmap = new-object System.Drawing.Bitmap $image ;
                    $Bitmap.SetResolution($Resolution ,$Resolution ) ;
                    $Icon = [System.Drawing.Icon]::FromHandle($Bitmap.GetHicon()) ;
                } else {
                    throw "Unsupported icon source Path:$($Path)`nonly .dll & .exe file types are supported" ;
                } ;
                if($OutputPath){
                     write-verbose -verbose:$verbose "Exporting Source File Icon..." ;
                    $stream = [System.IO.File]::OpenWrite("$($OutputPath)") ;
                    $Icon.save($stream) ;
                    $stream.close() ;
                    write-verbose -verbose:$verbose "Icon file can be found at $OutputPath" ;
                    $OutputPath | write-output ;
                } else {
                    # extract & reuse command
                    # or return the actual icon object
                    $Icon | write-output ;
                }  # if-E
            } else {
              write-error "$((get-date).ToString('HH:mm:ss')):Non-existent `$Path:$Path. Aborting!";
            } # if-E ;
        } CATCH {
            Write-Error "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)"
            Exit #Opts: STOP(debug)|EXIT(close)|Continue(move on in loop cycle)
        } ;
    } ;
    END {} ;
}

#*------^ extract-Icon.ps1 ^------

#*------v Find-LockedFileProcess.ps1 v------
function Find-LockedFileProcess {
    <#
    .SYNOPSIS
    Find-LockedFileProcess.ps1 - Find locking process on a file
    .NOTES
    Author: Adam Bertram
    Website:	https://www.adamtheautomator.com/file-cannot-accessed-fix-handle-exe/
    REVISIONS   :
    * 7:53 AM 8/27/2018 Find-LockedFileProces:added, added pshelp, tightened a little, defaulted to choco handle.exe loc
    * Mar 26, 2018 posted version
    Req's sysinternals handle.exe (bundled in choco, otherwise):
    #-=-=-=-=-=-=-=-=
    Invoke-WebRequest -Uri 'https://download.sysinternals.com/files/Handle.zip' -OutFile C:\handle.zip
    Expand-Archive -Path C:\handle.zip
    #-=-=-=-=-=-=-=-=
    .DESCRIPTION
    .PARAMETER  FileName
    File [-FileName c:\path-to\file.ext]
    .PARAMETER  HandleFilePath
    File [-HandleFilePath c:\path-to\file.ext]
    .INPUTS
    None
    .OUTPUTS
    Outputs to pipeline
    .EXAMPLE
    Find-LockedFileProcess -FileName TestWordDoc.docx
    .EXAMPLE
    .LINK
    https://www.adamtheautomator.com/file-cannot-accessed-fix-handle-exe/
    #>
    param(
        [Parameter(Mandatory)][string]$FileName,
        [Parameter()][string]$HandleFilePath = 'C:\ProgramData\chocolatey\bin\handle.exe'
    ) ;
    $splitter = '------------------------------------------------------------------------------' ;
    $handleProcess = ((& $HandleFilePath) -join "`n") -split $splitter | Where-Object { $_ -match [regex]::Escape($FileName) } ;
    (($handleProcess -split "`n")[2] -split ' ')[0] ;
}

#*------^ Find-LockedFileProcess.ps1 ^------

#*------v Get-FileEncoding.ps1 v------
function Get-FileEncoding {
    <#
    .SYNOPSIS
    Get-FileEncoding.ps1 - Gets Simple subset file encoding (compatible with Set-Content -encoding param)
    .NOTES
    Version     : 1.0.1
    Author:     : Andy Arismendi
    Website     : https://stackoverflow.com/questions/9121579/powershell-out-file-prevent-encoding-changes
    CreatedDate : 2012-2-2
    FileName    : 
    License     : 
    Copyright   : 
    Github      : 
    Tags        : Powershell,Filesystem,Encoding
    REVISIONS
    * 3:08 PM 2/25/2020 re-implemented orig code, need values that can be fed back into set-content -encoding, and .net encoding class doesn't map cleanly (needs endian etc, and there're a raft that aren't supported). Spliced in UTF8BOM byte entries from https://superuser.com/questions/418515/how-to-find-all-files-in-directory-that-contain-utf-8-bom-byte-order-mark/914116
    * 2/12/2012 posted vers
    .DESCRIPTION
    Get-FileEncoding() - Gets file encoding..
    The Get-FileEncoding function determines encoding by looking at Byte Order Mark (BOM).
    http://unicode.org/faq/utf_bom.html
    http://en.wikipedia.org/wiki/Byte_order_mark
    Missing: 
    UTF8BOM: Encodes in UTF-8 format with Byte Order Mark (BOM)
    UTF8NoBOM: Encodes in UTF-8 format without Byte Order Mark (BOM)
    UTF32: Encodes in UTF-32 format.
    OEM: Uses the default encoding for MS-DOS and console programs.
    # code to dump first 9 bytes of each:
    #-=-=-=-=-=-=-=-=
    $encodingS = "unicode","bigendianunicode","utf8","utf7","utf32","ascii","default","oem" ;foreach($encoding in $encodings){    "`n==$($encoding):" ;    Get-Date | Out-File date.txt -Encoding $encoding ;    [byte[]] $x = get-content -encoding byte -path .\date.txt -totalcount 9 ;    $x | format-hex ;} ; 
    #-=-=-=-=-=-=-=-=
    .PARAMETER Path
    The Path of the file that we want to check.
    .PARAMETER DefaultEncoding
    The Encoding to return if one cannot be inferred.
    You may prefer to use the System's default encoding:  [System.Text.Encoding]::Default
    List of available Encodings is available here: http://goo.gl/GDtzj7
    One's commonly seen dumping uwes:
    System.Text.ASCIIEncoding
    System.Text.UTF8Encoding
    System.Text.UnicodeEncoding
    System.Text.UTF32Encoding
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Text.Encoding
    .EXAMPLE
    Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'} ;
    This command gets ps1 files in current directory where encoding is not ASCII ;
    .EXAMPLE
    Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'} | foreach {(get-content $_.FullName) | set-content $_.FullName -Encoding ASCII} ;
    Same as previous example but fixes encoding using set-content ;
    .LINK
    http://franckrichard.blogspot.com/2010/08/powershell-get-encoding-file-type.html
    .LINK
    https://gist.github.com/jpoehls/2406504
    .LINK
    http://goo.gl/XQNeuc
    .LINK
    http://poshcode.org/5724
    #>
    [CmdletBinding()]
    Param ([Alias("PSPath")][Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)][string]$Path) ;
    process {
        [byte[]] $byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path ; 
        if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )
            { $encoding = 'UTF8' }  
        elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
            { $encoding = 'BigEndianUnicode' }
        elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe)
             { $encoding = 'Unicode' } # AKA UTF-16LE/Little-endian-Unicode
        elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
            { $encoding = 'UTF32' }
        elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76)
            { $encoding = 'UTF7'}
        elseif ($byte[0] -eq 0xEF -and $byte[1] -eq 0xBB -and $byte[2] -eq 0xBF)
            { $encoding = 'UTF8BOM'} 
        else
            { $encoding = 'ASCII' } # ascii/default/oem are identical first 9 bytes
        return $encoding
    } ;
}

#*------^ Get-FileEncoding.ps1 ^------

#*------v Get-FileEncodingExtended.ps1 v------
function Get-FileEncodingExtended {
    <#
    .SYNOPSIS
    Get-FileEncodingExtended.ps1 - Gets file encoding..
    .NOTES
    Version     : 1.0.1
    Author: jpoehls
    Website:	https://gist.github.com/jpoehls/2406504
    CreatedDate : 2012-
    FileName    : 
    License     : 
    Copyright   : 
    Github      : https://gist.github.com/jpoehls/2406504
    Tags        : Powershell,Filesystem,Encoding
    REVISIONS
    * 3:08 PM 2/25/2020 tightened up, updated CBH, purged old rem'd codeblock
    * 8:21 AM 10/23/2017 Get-FileEncodingExtended: updated help pointers
    * 6:55 PM 6/18/2017 Get-FileEncodingExtended: spliced in: 2015/02/03, VertigoRay - Adjusted to use .NET's [System.Text.Encoding Class](http://goo.gl/XQNeuc). (http://poshcode.org/5724)
    * 6:25 PM 6/18/2017 tsk: fixed a few typos/vscode conversion encoding errors
    * 3:08 PM 6/16/2017 added more pshelp, OTB fmt
    * Apr 17, 2012 posted vers
    .DESCRIPTION
    Get-FileEncodingExtended() - Gets file encoding..
    The Get-FileEncodingExtended function determines encoding by looking at Byte Order Mark (BOM).
    Based on port of C# code from http://www.west-wind.com/Weblog/posts/197245.aspx
    Convert-FileEncoding.ps1 - Converts files to the given encoding.
    Matches the include pattern recursively under the given path.
    Modified by F.RICHARD August 2010
    add comment + more BOM
    http://unicode.org/faq/utf_bom.html
    http://en.wikipedia.org/wiki/Byte_order_mark
    .PARAMETER Path
    The Path of the file that we want to check.
    .PARAMETER DefaultEncoding
    The Encoding to return if one cannot be inferred.
    You may prefer to use the System's default encoding:  [System.Text.Encoding]::Default
    List of available Encodings is available here: http://goo.gl/GDtzj7
    One's commonly seen dumping uwes:
    System.Text.ASCIIEncoding
    System.Text.UTF8Encoding
    System.Text.UnicodeEncoding
    System.Text.UTF32Encoding
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Text.Encoding
    .EXAMPLE
    Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncodingExtended $_.FullName}} | where {$_.Encoding -ne 'ASCII'} ;
    This command gets ps1 files in current directory where encoding is not ASCII ;
    .EXAMPLE
    Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncodingExtended $_.FullName}} | where {$_.Encoding -ne 'ASCII'} | foreach {(get-content $_.FullName) | set-content $_.FullName -Encoding ASCII} ;
    Same as previous example but fixes encoding using set-content ;
    .LINK
    http://franckrichard.blogspot.com/2010/08/powershell-get-encoding-file-type.html
    .LINK
    https://gist.github.com/jpoehls/2406504
    .LINK
    http://goo.gl/XQNeuc
    .LINK
    http://poshcode.org/5724
#>
    [CmdletBinding()]
    Param (
        [Alias("PSPath")]
        [Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
        [string]$Path,
        [Parameter(Mandatory = $False)]
        [System.Text.Encoding]$DefaultEncoding = [System.Text.Encoding]::ASCII
    ) ;
    # 6:50 PM 6/18/2017 orig byte code, supplanted by use of .NET's [System.Text.Encoding Class]
    process {
        [Byte[]]$bom = Get-Content -Encoding Byte -ReadCount 4 -TotalCount 4 -Path $Path ;
        $encoding_found = $false ;
        foreach ($encoding in [System.Text.Encoding]::GetEncodings().GetEncoding()) {
            $preamble = $encoding.GetPreamble() ;
            if ($preamble) {
                foreach ($i in 0..$preamble.Length) {
                    if ($preamble[$i] -ne $bom[$i]) {
                        break ;
                    }
                    elseif ($i -eq $preable.Length) {
                        $encoding_found = $encoding ;
                    } ;
                } ;
            } ;
        } ;
        if (!$encoding_found) {
            $encoding_found = $DefaultEncoding ;
        } ;
        $encoding_found ;
    } ;
}

#*------^ Get-FileEncodingExtended.ps1 ^------

#*------v Get-FsoShortName.ps1 v------
Function Get-FsoShortName {
    <#
    .SYNOPSIS
    Get-FsoShortName - Return ShortName (8.3) for specified Filesystem object
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 7:40 AM 3/29/2016 - added string->path conversion
    * 2:16 PM 3/28/2016 - functional version, no param block
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns Shortname for specified FSO('s) to the pipeline
    .EXAMPLE
    get-childitem "C:\Program Files\DellTPad\Dell.Framework.Library.dll" | get-fsoshortname ;
    # Retrieve ShortName for a file
    .EXAMPLE
    get-childitem ${env:ProgramFiles(x86)} | get-fsoshortname ;
    Retrieve Shortname for contents of the folder specified by the 'Program Files(x86)' environment variable
    .EXAMPLE
    $blah="C:\Program Files (x86)\Log Parser 2.2","C:\Program Files (x86)\Log Parser 2.2\SyntaxerHighlightControl.dll" ;
    $blah | get-fsoshortname ;
    Resolve path specification(s) into ShortNames
    .LINK
    https://blogs.technet.microsoft.com/heyscriptingguy/2013/08/01/use-powershell-to-display-short-file-and-folder-names/
    #>
    BEGIN { $fso = New-Object -ComObject Scripting.FileSystemObject } ;
    PROCESS {
        if($_){
            $fo=$_;
            # 7:25 AM 3/29/2016 add string-path support
            switch ($fo.gettype().fullname){
                "System.IO.FileInfo" {write-output $fso.getfile($fo.fullname).ShortName}
                "System.IO.DirectoryInfo" {write-output $fso.getfolder($fo.fullname).ShortName}
                "System.String" {
                    # if it's a gci'able path, convert to fso object and then recurse back through
                    if($fio=get-childitem -Path $fo -ea 0){$fio | Get-FsoShortName }
                    else{write-error "$($fo) is a string variable, but does not reflect the location of a filesystem object"}
                }
                default { write-error "$($fo) is not a filesystem object" }
            } ;
        } else { write-error "$($fo) is not a filesystem object" } ;
    }  ;
}

#*------^ Get-FsoShortName.ps1 ^------

#*------v Get-FsoTypeObj.ps1 v------
Function Get-FsoTypeObj {
    <#
    .SYNOPSIS
    Get-FsoTypeObj()- convert file/dir object or path string to an fso obj
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Website:	URL
    Twitter:	URL
    REVISIONS   :
    * 1:37 PM 10/23/2017 Get-FsoTypeObj: simple reworking of get-fsoshortpath() to convert file/dir object or path string to an fso obj
    .DESCRIPTION
    .PARAMETER  PARAMNAME
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Resolves Dir/File/path string into an fso object
    .EXAMPLE
    Get-FsoTypeObj "C:\usr\work\exch\scripts\get-dbmbxsinfo.ps1"
    Resolve a path string into an fso file object
    .EXAMPLE
    Get-FsoTypeObj "C:\usr\work\exch\scripts\"
    Resolve a path string into an fso container object
    .EXAMPLE
    gci "C:\usr\work\exch\scripts\" | Get-FsoTypeObj ;
    Validates and returns an fso container object
    .EXAMPLE
    gci "C:\usr\work\exch\scripts\_.txt" | Get-FsoTypeObj ;
    Validates input is fso and returns an fso file object
    .LINK
    #>
    Param([Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Path or object to be resoved to fso")]$path) ;
    BEGIN {  } ;
    PROCESS {
        if($path){
            $fo=$path;
            switch ($fo.gettype().fullname){
                "System.IO.FileInfo" {$fo | write-output ; } ;
                "System.IO.DirectoryInfo" {$fo | write-output ; } ;
                "System.String" {
                    # if it's a gci'able path, convert to fso object and then recurse back through
                    if($fio=get-childitem -Path $fo -ea 0){$fio | Get-FsoTypeObj }
                    else{write-error "$($fo) is a string variable, but does not reflect the location of a filesystem object"} ;
                } ;
                default { write-error "$($fo) is not a filesystem object" } ;
            } ;
        } else { write-error "$($fo) is not a filesystem object" } ;
    }  ; # PROC-E
}

#*------^ Get-FsoTypeObj.ps1 ^------

#*------v Get-Shortcut.ps1 v------
function Get-Shortcut {
    <#
    .SYNOPSIS
    Get-Shortcut() - Reads the attributes of a shortcut
    .NOTES
    Author: Kevin Marquette
    Website:	https://github.com/KevinMarquette/PesterInAction/blob/master/4%20Module/Demo/functions/Get-Shortcut.ps1
    REVISIONS   :
    * 9:05 AM 8/29/2017 updated pshelp, put into OTB format
    *  Nov 8, 2015 posted version
    .DESCRIPTION
    Get-Shortcut() - Reads the attributes of a shortcut
    PARAMETER Path
    Path to a target .lnk file
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns an objects summarizing each processed .lnk file, to the pipeline
    .EXAMPLE
    Get-Shortcut -Path .\shortcut.lnk ;
    Pull attribs of .lnk file
    .EXAMPLE
    ls *.lnk | Get-Shortcut ;
    Demos pipeline support for bulk processing
    .EXAMPLE
    gci "$($env:appdata)\Microsoft\Internet Explorer\Quick Launch\*.lnk" -recur | get-shortcut |?{$_.TargetPath -like 'C:\sc\batch\BatScripts\*'} | fl fullname,targetpath ;
    Search all .lnk files in QuickLaunch tree, for TargetPath in specific dir, and return the FullName of the .lnk file
    .LINK
    https://github.com/kmarquette/PesterInAction/blob/master/4%20Module/Demo/functions/Get-Shortcut.ps1
    #>
    [cmdletbinding()]
    param([Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]$Path) ;
    begin {
        $WScriptShell = New-Object -ComObject WScript.Shell
    } ;
    process {
        foreach ($node in $Path) {
            if (Test-Path $node) {
                $Shortcut = $WScriptShell.CreateShortcut((Resolve-Path $node)) ;
                Write-Output $Shortcut ;
            } ;
        } ;
    } ;
}

#*------^ Get-Shortcut.ps1 ^------

#*------v remove-ItemRetry.ps1 v------
function remove-ItemRetry {
    <#
    .SYNOPSIS
    remove-ItemRetry - Write output string to specified File
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     : https://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 8:28 PM 11/17/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit :
    AddedWebsite:
    AddedTwitter:
    REVISIONS
    * 1:37 PM 12/28/2019 removed spurious mand $Text param
    * 10:59 AM 12/28/2019 INIT
    .DESCRIPTION
    remove-ItemRetry - Write output string to specified File
    .PARAMETER  Path
    Path to target file/directory [-Path path-to\file.ext]
    .PARAMETER  Recurse
    Recursive removal [-Recurse]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    $bRet = remove-ItemRetry -Path "$($env:userprofile)\Documents\WindowsPowerShell\Modules\$($ModuleName)\*.*" -Recurse -showdebug:$($showdebug) -whatif:$($whatif) ;
    if (!$bRet) {throw "FAILURE" ; EXIT ; } ;
    Recursively remove content specified, failures result in retry with -Force
    .LINK
    #>

    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to target file/directory [-Path path-to\file.ext]")]
        [ValidateNotNullOrEmpty()]$Path,
        [Parameter(HelpMessage = "Recursive removal [-Recurse]")]
        [switch] $Recurse,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;

    $pltRemoveItem=[ordered]@{
        Path=$Path ;
        Recurse=$($Recurse) ;
        ErrorAction="Stop" ;
        whatif=$($whatif);
    } ;
    if(test-path -path $pltRemoveItem.Path){
        $smsg= "remove-item w`n$(($pltRemoveItem|out-string).trim())" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        $bRetry=$false ;
        TRY {
            remove-item @pltRemoveItem;
            $true | write-output ;
        } CATCH {
            $ErrorTrapped=$Error[0] ;
            $bRetry=$true ;
            write-warning  "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
        } ;
        if($bRetry){
            $pltRemoveItem.add('force',$true) ;
            $smsg= "RETRY with -FORCE: remove-item w`n$(($pltRemoveItem|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            TRY {
                remove-item @pltRemoveItem;
                $true | write-output ;
            } CATCH {
                $ErrorTrapped=$Error[0] ;
                write-warning  "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
                $bRetry=$false ;
                #Exit ;
                $false | write-output ;
            } ;
        } ;
    } else {
        # no match, ret true
        $smsg= "No existing Match:test-path -path $($pltRemoveItem.Path)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        $true | write-output ;
    } ; ;
}

#*------^ remove-ItemRetry.ps1 ^------

#*------v Remove-PSTitleBar.ps1 v------
Function Remove-PSTitleBar {
    <#
    .SYNOPSIS
    Remove-PSTitleBar.ps1 - Remove specified string from the Powershell console Titlebar
    .NOTES
    Version     : 1.0.1
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : dsolodow
    AddedWebsite:	https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    AddedTwitter:	URL
    Twitter     :	
    CreatedDate : 2014-11-12
    FileName    : 
    License     : 
    Copyright   : 
    Github      : 
    Tags        : Powershell,Console
    REVISIONS
    * 4:37 PM 2/27/2020 updated CBH
    # 8:46 AM 3/15/2017 Remove-PSTitleBar: initial version
    # 11/12/2014 - posted version
    .DESCRIPTION
    Remove-PSTitleBar.ps1 - Append specified string to the end of the powershell console Titlebar
    Inspired by dsolodow's Update-PSTitleBar code
    .PARAMETER Tag
    Tag string to be added to current powershell console Titlebar
    .EXAMPLE
    Remove-PSTitleBar 'EMS'
    Add the string 'EMS' to the powershell console Title Bar
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    
    Param ([parameter(Mandatory = $true,Position=0)][String]$Tag)
    #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
    If ($host.name -eq 'ConsoleHost') {
        if($host.ui.RawUI.WindowTitle -like "*$($Tag)*"){
                $host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle.replace(" $Tag ","") ;
        }else{} ;
    } ;
}

#*------^ Remove-PSTitleBar.ps1 ^------

#*------v revert-File.ps1 v------
function revert-File {
    <#
    .SYNOPSIS
    revert-File.ps1 - Restore file from prior backup
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2:23 PM 12/29/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    REVISIONS
    * 2:23 PM 12/29/2019 init
    .DESCRIPTION
    revert-File.ps1 - Revert a file to a prior backup of the file
    .PARAMETER  Source
    Path to backup file to be restored
    .PARAMETER Destination
    Path & name Source file should be copied to
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    $bRet = revert-File -Source "C:\sc\verb-dev\verb-dev\verb-dev.psm1_20191229-0904AM" -Destination "C:\sc\verb-dev\verb-dev\verb-dev.psm1" -showdebug:$($showdebug) -whatif:$($whatif)
    if (!$bRet) {throw "FAILURE" } ;
    Backup specified file
    .LINK
    #>
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to script[-Source path-to\script.ps1]")]
        [ValidateScript( { Test-Path $_ })]$Source,
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path & name Source file should be copied to[-Dest path-to\script.ps1]")]
        $Destination,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    if ($Source.GetType().FullName -ne 'System.IO.FileInfo') {
        $Source = get-childitem -path $Source ;
    } ;
    $pltBu = [ordered]@{
        path        = $Source.fullname ;
        destination = $Destination ;
        ErrorAction="Stop" ;
        whatif      = $($whatif) ;
    } ;
    $smsg = "REVERT:copy-item w`n$(($pltBu|out-string).trim())" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    $Exit = 0 ;
    Do {
        Try {
            copy-item @pltBu ;
            $Exit = $Retries ;
        }
        Catch {
            $ErrorTrapped = $Error[0] ;
            Write-Verbose "Failed to exec cmd because: $($ErrorTrapped)" ;
            Start-Sleep -Seconds $RetrySleep ;
            # reconnect-exo/reconnect-ex2010
            $Exit ++ ;
            Write-Verbose "Try #: $Exit" ;
            If ($Exit -eq $Retries) { Write-Warning "Unable to exec cmd!" } ;
        }  ;
    } Until ($Exit -eq $Retries) ;

    # validate copies *exact*
    if (!$whatif) {
        if (Compare-Object -ReferenceObject $(Get-Content $pltBu.path) -DifferenceObject $(Get-Content $pltBu.destination)) {
            $smsg = "BAD COPY!`n$pltBu.path`nIS DIFFERENT FROM`n$pltBu.destination!`nEXITING!";
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error }  #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $false | write-output ;
        }
        Else {
            if ($showDebug) {
                $smsg = "Validated Copy:`n$($pltbu.path)`n*matches*`n$($pltbu.destination)"; ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
            #$true | write-output ;
            $pltBu.destination | write-output ;
        } ;
    } else {
        #$true | write-output ;
        $pltBu.destination | write-output ;
    };
}

#*------^ revert-File.ps1 ^------

#*------v Set-FileContent.ps1 v------
function Set-FileContent {
    <#
    .SYNOPSIS
    Set-FileContent - Write output string to specified File
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     : https://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 8:28 PM 11/17/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    AddedCredit :
    AddedWebsite:
    AddedTwitter:
    REVISIONS
    * 10:44 AM 12/11/2019 updated example
    * 8:28 PM 11/17/2019 INIT
    .DESCRIPTION
    Set-FileContent - Write output string to specified File
    .PARAMETER  Text
    Text to be written to specified file
    .PARAMETER  Path
    Path to target output file
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    $bRet = Set-FileContent -Text $updatedContent -Path $outfile -showdebug:$($showdebug) -whatif:$($whatif) ;
    if (!$bRet) {throw "FAILURE" } ;
    .LINK
    #>

    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Text to be written to specified file [-Path path-to\file.ext]")]
        [ValidateNotNullOrEmpty()]$Text,
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to script[-Path path-to\script.ps1]")]
        [ValidateNotNullOrEmpty()]$Path,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;

    $Exit = 0 ;
    $pltSetContent=[ordered]@{
        Path = $Path ;
        whatif = $($whatif) ;
        ErrorAction="Stop" ;
    } ;
    Do {
        Try {
            $text | set-Content @pltSetContent ;
            $true | write-output
            $Exit = $Retries ;
        }
        Catch {
            $ErrorTrapped = $Error[0] ;
            Write-Verbose "Failed to exec cmd because: $($ErrorTrapped)" ;
            $pltSetContent.add('force',$true) ;
            Start-Sleep -Seconds $RetrySleep ;
            # reconnect-exo/reconnect-ex2010
            $Exit ++ ;
            Write-Verbose "Adding -force. Try #: $Exit" ;
            If ($Exit -eq $Retries) {
                Write-Warning "Unable to exec cmd!" ;
                $false | write-output ;
            } ;
        }  ;
    } Until ($Exit -eq $Retries) ;
}

#*------^ Set-FileContent.ps1 ^------

#*------v Set-Shortcut.ps1 v------
function Set-Shortcut {
    <#
    .SYNOPSIS
    Set-Shortcut.ps1 - writes changes to target .lnk files
    .NOTES
    Author: Tim Lewis
    REVISIONS   :
    * added pshelp and put into otb format, tightened up layout.
    * Feb 23 '14 at 11:24 posted vers
    .DESCRIPTION
    Set-Shortcut.ps1 - writes changes to target .lnk files
    .PARAMETER  LinkPath
    Path to target .lnk file
    .PARAMETER  Hotkey
    Hotkey specification for target .lnk file
    .PARAMETER  IconLocation
    Icon path specification for target .lnk file
    .PARAMETER  Arguments
    Args specification for target .lnk file
    .PARAMETER  TargetPath
    TargetPath specification for target .lnk file
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    set-shortcut -linkpath "C:\Users\kadrits\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\SU\Iexplore Kadrits.lnk" -TargetPath 'C:\sc\batch\BatScripts\runas-UID-IE.cmd' ;
    .EXAMPLE
    
    .LINK
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]$LinkPath,
        $Hotkey, 
        $WorkingDirectory, 
        $IconLocation, 
        $Arguments, 
        [Parameter(Mandatory=$True)]$TargetPath,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    begin {
        $Verbose = ($PSBoundParameters['Verbose'] -eq $true) ; 
        $shell = New-Object -ComObject WScript.Shell 
    } ;
    process {
        $link = $shell.CreateShortcut($LinkPath) ;
        $PSCmdlet.MyInvocation.BoundParameters.GetEnumerator() | 
            Where-Object { $_.key -ne 'LinkPath' } |
              ForEach-Object { $link.$($_.key) = $_.value } ;
        if($whatif){
            write-verbose -verbose:$verbose  'What if: Performing the operation "CreateShortcut" on target "$($LinkPath)".' ;
        } else { 
            $link.Save() ;
        } ; 
    } ;
    END{
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($link) ; 
        Remove-Variable link ; 
    } ; 
}

#*------^ Set-Shortcut.ps1 ^------

#*------v trim-FileList.ps1 v------
function trim-FileList {
    <#
    .SYNOPSIS
    trim-FileList.ps1 - Sort and unique a file containing a list of items
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 20200221
    FileName    : trim-FileList.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    REVISIONS
    * 6:53 AM 2/21/2020 init
    .DESCRIPTION
    .PARAMETER  Files
    Files listing items, to be sorted & uniqued [-file x:\path-to\file.txt]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    .EXAMPLE
    $tfiles = @(gci C:\sc\powershell\_key-admin-scripts-*.txt -recur |select -expand fullname )  ;
    trim-FileList.ps1 -files $tfiles -verbose -whatif ; 
    Process all targeted files in the tree, verbose output, whatif pass
    .EXAMPLE
    trim-FileList -files x:\path-to\somefile.txt -verbose -whatif
    .LINK
    #>
    #[ValidateScript({Test-Path $_})]
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Files listing items, to be sorted & uniqued [-files x:\path-to\file.txt]")]
        [array]$Files,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag (defaults TRUE)[-whatIf]")]
        [switch] $whatIf=$true 
    ) ;
    BEGIN {
        $Procd= 0 ;
        $Verbose = ($VerbosePreference -eq 'Continue') ; # if using explicit write-verbose -verbose, this converts the vPref into a usable vari in those lines
        $sBnr="#*---===v Function: $($MyInvocation.MyCommand) v===---" ;
        $smsg= "$($sBnr)" ;
        if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    }  # BEG-E ;
    PROCESS {
        $ttl = ($Files | measure).count
        $Procd=0 ;
        foreach ($File in $Files) {
            $Procd++ ;
            $sBnrS="`n#*------v ($($Procd)/$($ttl)):$($File): v------" ;
            $smsg= $sBnrS ;
            if($showdebug -OR $Verbose){
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ;
            $error.clear() ;
            $continue = $true ;
            $PriorEAPref = $ErrorActionPreference ;
            TRY {
                $ErrorActionPreference = "Stop" ;
                if($tf = gci $file){
                    write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):PROC ($((gc $tf.fullname).count) lines):$($tf.fullname)" ;
                    gc $tf | sort | select -unique | set-content $tf.fullname -whatif:$($whatif) ;
                    write-verbose -verbose:$verbose  "$((get-date).ToString('HH:mm:ss')):POST ($((gc $tf.fullname).count) lines):$($tf.fullname)" ;
                } ;
                $true | write-output ;
            } CATCH {
                $smsg = "Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } #Error|Warn|Debug
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                Exit #STOP(debug)|EXIT(close)|Continue(move on in loop cycle) ;
            } ;
            $ErrorActionPreference = $PriorEAPref ;
            $smsg= "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } #  # loop-E ;
    } # PROC-E ;
    END {
        $smsg= "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
        if($showdebug -OR $Verbose){
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;
    } ; # END-E
}

#*------^ trim-FileList.ps1 ^------

#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function Add-PSTitleBar,backup-File,ColorMatch,Convert-FileEncoding,convertTo-Base64String,dump-Shortcuts,Expand-ZIPFile,extract-Icon,Find-LockedFileProcess,Get-FileEncoding,Get-FileEncodingExtended,Get-FsoShortName,Get-FsoTypeObj,Get-Shortcut,remove-ItemRetry,Remove-PSTitleBar,revert-File,Set-FileContent,Set-Shortcut,trim-FileList -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFdZmi9qQQesJ20Mb/4Gr9lQ/
# UcigggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDEyMjkxNzA3MzNaFw0zOTEyMzEyMzU5NTlaMBUxEzARBgNVBAMTClRvZGRT
# ZWxmSUkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALqRVt7uNweTkZZ+16QG
# a+NnFYNRPPa8Bnm071ohGe27jNWKPVUbDfd0OY2sqCBQCEFVb5pqcIECRRnlhN5H
# +EEJmm2x9AU0uS7IHxHeUo8fkW4vm49adkat5gAoOZOwbuNntBOAJy9LCyNs4F1I
# KKphP3TyDwe8XqsEVwB2m9FPAgMBAAGjdjB0MBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MF0GA1UdAQRWMFSAEL95r+Rh65kgqZl+tgchMuKhLjAsMSowKAYDVQQDEyFQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEGwiXbeZNci7Rxiz/r43gVsw
# CQYFKw4DAh0FAAOBgQB6ECSnXHUs7/bCr6Z556K6IDJNWsccjcV89fHA/zKMX0w0
# 6NefCtxas/QHUA9mS87HRHLzKjFqweA3BnQ5lr5mPDlho8U90Nvtpj58G9I5SPUg
# CspNr5jEHOL5EdJFBIv3zI2jQ8TPbFGC0Cz72+4oYzSxWpftNX41MmEsZkMaADGC
# AWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZp
# Y2F0ZSBSb290AhBaydK0VS5IhU1Hy6E1KUTpMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSOo0p9
# wELu/pYSBF+FwJT/AnMRvjANBgkqhkiG9w0BAQEFAASBgKdTo0HFZ9z8Tz5nqFsv
# vixlBPTl8+aBEN0REpY6CZnlF6x5KhF6NKDjtYt2U+ESmT4QYKO6EoPNYjCo9nZr
# H0odKljfTVpI+xr1XM52+P1UJqgxguuT0jwbHrjSiuKCjeOA08ZzPRGpRhPr6jnx
# +kCtbD33CdheDfTgSwROXB4B
# SIG # End signature block
