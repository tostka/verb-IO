# verb-IO.psm1


<#
.SYNOPSIS
verb-IO - Powershell Input/Output generic functions module
.NOTES
Version     : 1.8.0.0.0
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

#*======v FUNCTIONS v======



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
    * 8:15 AM 7/27/2021 sub'd in $rgxQ for duped rgx
    * 10:30 AM 7/26/2021 reworked, added whatif, showdebug, verbose echos, working on array-supp in the inputs
    * 3:11 PM 4/19/2021 added cmdletbinding/verbose supp & alias add-PSTitle
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
    [CmdletBinding()]
    [Alias('add-PSTitle')]
    Param (
        #[parameter(Mandatory = $true,Position=0)][String]$Tag
        [parameter(Mandatory = $true,Position=0)]$Tag,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    )
    $showDebug=$true ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    write-verbose "`$Tag:`n$(($Tag|out-string).trim())" ; 
    $rgxRgxOps = [regex]'[\[\]\\\{\}\+\*\?\.]+' ; 
    #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
    #If ($host.name -eq 'ConsoleHost') {
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        #if($host.ui.rawui.windowtitle -match '(PS|PSc)\s(ADMIN|Console)\s-\s(.*)\s-(.*)'){
        #    $conshost = $matches[1] ; $consrole = $matches[2] ; $consdom = $matches[3] ; $consData = ($matches[4] -split '\s\s').trim() ;
        # alt, take everything after last '-':
        if($Tag -is [system.array]){ 
            foreach ($Tg in $Tag){
                # don't add if already present
                #if($host.ui.RawUI.WindowTitle -like "*$($Tg)*"){}
                # search space delimited, mebbe regex, $env:userdomain is overlapping the TenOrg (which is a substring of the domain), plus side always has trailing \s
                if($Tg -notmatch $rgxRgxOps){
                    $rgxQ = "\s$([Regex]::Escape($Tg))\s" ; 
                } else { 
                    $rgxQ = "\s$($Tg)\s" ; # assume it's already a regex, no manual escape
                };  
                write-verbose "`$rgxQ:$($rgxQ)" ; 
                if($host.ui.RawUI.WindowTitle  -match $rgxQ){
                    write-verbose "(pre-matched '$($rgxQ)' in`n$(($host.ui.RawUI.WindowTitle|out-string).trim()))" ; 
                }else{
                    if(-not($whatif)){
                        write-verbose "Update `$host.ui.RawUI.WindowTitle to`n '$($host.ui.RawUI.WindowTitle) $($Tg) )'" ; 
                        $host.ui.RawUI.WindowTitle += " $Tg "
                    } else { 
                        write-host "whatif:Update `$host.ui.RawUI.WindowTitle to`n '$($host.ui.RawUI.WindowTitle) $($Tg) )'" ; 
                    } ;
                } ;
            } ; 
        } else { 
            if($Tag -notmatch $rgxRgxOps){
                $rgxQ = "\s$([Regex]::Escape($Tag))\s" ; 
            } else { 
                $rgxQ = "\s$($Tag)\s" ; # assume it's already a regex, no manual escape
            }; 
            write-verbose "`$rgxQ:$($rgxQ)" ; 
            if($host.ui.RawUI.WindowTitle  -match $rgxQ ){
                write-verbose "(not-matched:'$($rgxQ)' in `$host.ui.RawUI.WindowTitle`n$($host.ui.RawUI.WindowTitle))" ; 
            }else{
                if(-not($whatif)){
                    write-verbose "Update `$host.ui.RawUI.WindowTitle to`n '$($host.ui.RawUI.WindowTitle) $($Tag) )'" ; 
                    $host.ui.RawUI.WindowTitle += " $Tag "
                } else { 
                    write-host "whatif:Update `$host.ui.RawUI.WindowTitle to`n '$($host.ui.RawUI.WindowTitle) $($Tag) )'" ; 
                } ;
            } ;
        } ;
    } ;
    rebuild-PSTitleBar -verbose:$($VerbosePreference -eq "Continue") -whatif:$($whatif);
}

#*------^ Add-PSTitleBar.ps1 ^------

#*------v Authenticate-File.ps1 v------
function Authenticate-File {
    <#
    .SYNOPSIS
    Authenticate-File - verifies Authenticode signature on any file that supports Subject Interface Package (SIP).
.NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Certificate,Developoment
    REVISIONS   :
    8:56 AM 1/8/2015 - ported from sign-file
    8:54 AM 1/8/2015 - added play-beep to end
    10:01 AM 12/30/2014
    .PARAMETER file
    The file name(s) to retrieve the authenticode signature info from.
    .INPUTS
    Accepts piped input (computername).
    .OUTPUTS
    Outputs CustomObject to pipeline
    .DESCRIPTION
    Authenticate-File - verifies Authenticode signature on any file that supports Subject Interface Package (SIP).
    .EXAMPLE
    Authenticate-File C:\usr\work\lync\scripts\enable-luser.ps1
    .EXAMPLE
    Authenticate-File C:\usr\work\lync\scripts\*-luser.ps1
    .EXAMPLE
    get-childitem C:\usr\work\lync\scripts\*-luser.ps1 | %{Authenticate-File $_}
    .EXAMPLE
    ls *.ps1,*.psm1,*.psd1 | Get-AuthenticodeSignature | Where {!(Test-AuthenticodeSignature $_ -Valid)} | gci | Set-AuthenticodeSignature ;
     Above sets sigs on all ps files with invalid sigs.
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True, HelpMessage = 'What file(s) would you like to sign?')]
        $file
    ) ;
    # just use the simplest option:
    #$cert = @(get-childitem cert:\currentuser\my -codesigning)[0]
    foreach ($f in $file) {
        get-AuthenticodeSignature -filepath $f | select Path, Status | format-table -auto ; #-Certificate $cert
    }
    play-beep;
}

#*------^ Authenticate-File.ps1 ^------

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
    * 10:35 AM 2/21/2022 CBH example ps> adds 
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
    PS> $bRet = backup-File -path $oSrc.FullName -showdebug:$($showdebug) -whatif:$($whatif)
    PS> if (!$bRet) {throw "FAILURE" } ;
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

#*------v check-FileLock.ps1 v------
function check-FileLock {
    <#
    .SYNOPSIS
    check-FileLock - Check for lock status on a file
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-11-23
    FileName    : check-FileLock.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : Henri Benoit (StreamReader error on lock)
    AddedWebsite: https://benohead.com/blog/2014/12/08/powershell-check-whether-file-locked/
    REVISIONS
    * 11:30 AM 11/23/2020 minor updates, reformated into fuunc
    * 12/8/14 posted version
    .DESCRIPTION
    .PARAMETER  Path
    Path to file[-path 'c:\pathto\file.txt'
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Boolean
    .EXAMPLE
    .\check-FileLock.ps1 -path 'c:\pathto\file.txt' 
    Check lock status on specified file
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to file[-path 'c:\pathto\file.txt']")]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path $_})]
        $Path
    ) ;
    BEGIN { $Verbose = ($VerbosePreference -eq 'Continue') } ;
    PROCESS {
        $Error.Clear() ; 
        Write-verbose "(Checking lock on file: $path)" ;
        $LockedFile = $false ; 
        $file = get-item (Resolve-Path $path) -Force ;
        if ($file.exists){
            TRY{
              $stream = New-Object system.IO.StreamReader $file ;
              if ($stream) {$stream.Close()} ; 
            } catch {$LockedFile = $true } ; 
        } ;
    } ;  # PROC-E
    END { $LockedFile | write-output } ; 
}

#*------^ check-FileLock.ps1 ^------

#*------v Close-IfAlreadyRunning.ps1 v------
Function Close-IfAlreadyRunning {
    <#
    .SYNOPSIS
    Close-IfAlreadyRunning.ps1 - Kills CURRENT instance of specified powershell script, if another instance already running.
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : Mr. Annoyed
    AddedWebsite: https://stackoverflow.com/users/4995131/mr-annoyed
    REVISIONS
    * 7:25 AM 10/27/2020 revised cbh, tightened up ; ren Test-IfAlreadyRunning->close-IfAlreadyRunning
    * 11/6/15 Mr Annoyed posted vers
    .DESCRIPTION
    Close-IfAlreadyRunning.ps1 - Kills CURRENT instance of specified powershell script, if another instance already running.
    (orig code Mr. Annoyed)
    .PARAMETER  ScriptName
    ScriptName to be checked[-ScriptName script.ps1]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    .EXAMPLE
    if($MyInvocation.MyCommand.Name){Close-IfAlreadyRunning -ScriptName $MyInvocation.MyCommand.Name }; 
    Close running powershell instance, if another instance is running the same script. 
    .LINK
    https://stackoverflow.com/questions/15969662/assure-only-1-instance-of-powershell-script-is-running-at-any-given-time
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,HelpMessage="ScriptName to be checked[-ScriptName script.ps1]")]
        [ValidateNotNullorEmpty()][String]$ScriptName 
    ) ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    #note: Can't self-discover calling script: $MyInvocation.MyCommand.Name gets name of *this function*
    Foreach ($PsCmdLine in (get-wmiobject win32_process | where{$_.processname -eq 'powershell.exe'} | select-object commandline,ProcessId )){
        [Int32]$OtherPID = $PsCmdLine.ProcessId ; 
        # $PID is a Autovariable for the current script''s Process ID number ; 
        write-verbose "checking PID:$($PsCmdLine.ProcessId):CmdLine:$($PsCmdLine.commandline)" ; 
        If ( ([String]$PsCmdLine.commandline -match $ScriptName) -And ($OtherPID -ne $PID) ){
            Write-host "PID [$OtherPID] is already running this script [$ScriptName]" ; 
            Write-host "Exiting this instance. (PID=[$PID])..." ; 
            Start-Sleep -Second 7 ; 
            Stop-Process -id $PID -Force ; # kill ps hosting this instance
            Exit ; # exit if the kill didn't work
        } ; 
    } ; 
}

#*------^ Close-IfAlreadyRunning.ps1 ^------

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

#*------v Compare-ObjectsSideBySide.ps1 v------
function Compare-ObjectsSideBySide{
    <#
    .SYNOPSIS
    Compare-ObjectsSideBySide() - Displays a pair of objects side-by-side comparatively in console
    .NOTES
    Author: Richard Slater
    Website:	https://stackoverflow.com/users/74302/richard-slater
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	URL
    Twitter:	URL
    FileName    : convert-ColorHexCodeToWindowsMediaColorsName.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 10:17 AM 9/15/2021 fixed typo in params, moved to full param block, and added lhs/rhs as aliases; expanded CBH
    * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
    * 10:18 AM 11/2/2018 reformatted, tightened up, shifted params to body, added pshelp
    * May 7 '16 at 20:55 posted version
    .DESCRIPTION
    Compare-ObjectsSideBySide() - Displays a pair of objects side-by-side comparatively in console
    .PARAMETER  col1
    Object to be displayed in Left Column [-col1 $PsObject1]
    .PARAMETER  col2
    Object to be displayed in Right Column [-col2 $PsObject2]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    Acceptes piped input.
    .OUTPUTS
    Outputs specified object side-by-side on console
    .EXAMPLE
    PS> $object1 = New-Object PSObject -Property @{
          'Forename' = 'Richard';
          'Surname' = 'Slater';
          'Company' = 'Amido';
          'SelfEmployed' = $true;
        } ;
    PS> $object2 = New-Object PSObject -Property @{
          'Forename' = 'Jane';
          'Surname' = 'Smith';
          'Company' = 'Google';
          'MaidenName' = 'Jones' ;
        } ;
    PS> Compare-ObjectsSideBySide $object1 $object2 | Format-Table Property, col1, col2;
    Display $object1 & $object2 in comparative side-by-side columns
    .LINK
    https://stackoverflow.com/questions/37089766/powershell-side-by-side-objects
    .LINK
    https://github.com/tostka/verb-IO
    #>
    PARAM(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Object to compare in left/1st column[-col1 `$obj1]")]
        [Alias('lhs')]
        $col1,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Object to compare in left/1st column[-col1 `$obj2]")]
        [Alias('rhs')]        
        $col2
    ) ;
    $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $combinedMembers = ($col1Members + $col2Members) | Sort-Object -Unique ;
    $combinedMembers | ForEach-Object {
        $properties = @{'Property' = $_} ;
        if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
        if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
        New-Object PSObject -Property $properties ;
    } ;
}

#*------^ Compare-ObjectsSideBySide.ps1 ^------

#*------v Compare-ObjectsSideBySide3.ps1 v------
function Compare-ObjectsSideBySide4 {
    <#
    .SYNOPSIS
    Compare-ObjectsSideBySide4() - Displays four objects side-by-side comparatively in console
    .NOTES
    Author: Richard Slater
    Website:	https://stackoverflow.com/users/74302/richard-slater
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    FileName    : Compare-ObjectsSideBySide4.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Compare
    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 10:17 AM 9/15/2021 moved to full param block,expanded CBH
    * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
    * 10:18 AM 11/2/2018 Extension of base model, to 4 columns
    * May 7 '16 at 20:55 posted version
    .DESCRIPTION
    Compare-ObjectsSideBySide4() - Displays four objects side-by-side comparatively in console
    .PARAMETER col1
    Object to compare in 1st column[-col1 `$PsObject1]
    PARAMETER col2
    Object to compare in 2nd column[-col2 `$PsObject1]
    PARAMETER col3
    Object to compare in 3rd column[-col3 `$PsObject1]
    PARAMETER col3
    Object to compare in 4th column[-col4 `$PsObject1]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    Acceptes piped input.
    .OUTPUTS
    Outputs specified object side-by-side on console
    .EXAMPLE
    PS> $object1 = New-Object PSObject -Property @{
          'Forename' = 'Richard';
          'Surname' = 'Slater';
          'Company' = 'Amido';
          'SelfEmployed' = $true;
        } ;
    PS> $object2 = New-Object PSObject -Property @{
          'Forename' = 'Jane';
          'Surname' = 'Smith';
          'Company' = 'Google';
          'MaidenName' = 'Jones' ;
        } ;
    PS> $object3 = New-Object PSObject -Property @{
          'Forename' = 'Zhe';
          'Surname' = 'Person';
          'Company' = 'Apfel';
          'MaidenName' = 'NunaUBusiness' ;
        } ;
    PS> $object4 = New-Object PSObject -Property @{
          'Forename' = 'Zir';
          'Surname' = 'NPC';
          'Company' = 'Facemook';
          'MaidenName' = 'Not!' ;
        } ;
    PS> Compare-ObjectsSideBySide4 $object1 $object2 $object3 $object4 | Format-Table Property, col1, col2, col3, col4;
    Display $object1,2,3 & 4 in comparative side-by-side columns
    .LINK
    https://stackoverflow.com/questions/37089766/powershell-side-by-side-objects
    #>
    PARAM(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Object to compare in 1st column[-col1 `$PsObject1]")]
        #[Alias('lhs')]
        $col1,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Object to compare in 2nd column[-col1 `$PsObject1]")]
        #[Alias('rhs')]        
        $col2,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Object to compare in 3rd column[-col1 `$PsObject1]")]
        #[Alias('rhs')]        
        $col3,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Object to compare in 4th column[-col1 `$PsObject1]")]
        #[Alias('rhs')]        
        $col4
    ) ;
    $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col3Members = $col3 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col4Members = $col4 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $combinedMembers = ($col1Members + $col2Members + $col3Members + $col4Members) | Sort-Object -Unique ;
    $combinedMembers | ForEach-Object {
        $properties = @{'Property' = $_} ;
        if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
        if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
        if ($col3Members.Contains($_)) {$properties['Col3'] = $col3 | Select-Object -ExpandProperty $_} ;
        if ($col4Members.Contains($_)) {$properties['col4'] = $col4 | Select-Object -ExpandProperty $_} ;
        New-Object PSObject -Property $properties ;
    } ;
}

#*------^ Compare-ObjectsSideBySide3.ps1 ^------

#*------v Compare-ObjectsSideBySide4.ps1 v------
function Compare-ObjectsSideBySide4 {
    <#
    .SYNOPSIS
    Compare-ObjectsSideBySide4() - Displays four objects side-by-side comparatively in console
    .NOTES
    Author: Richard Slater
    Website:	https://stackoverflow.com/users/74302/richard-slater
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    FileName    : Compare-ObjectsSideBySide4.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Compare
    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 10:17 AM 9/15/2021 moved to full param block,expanded CBH
    * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
    * 10:18 AM 11/2/2018 Extension of base model, to 4 columns
    * May 7 '16 at 20:55 posted version
    .DESCRIPTION
    Compare-ObjectsSideBySide4() - Displays four objects side-by-side comparatively in console
    .PARAMETER col1
    Object to compare in 1st column[-col1 `$PsObject1]
    PARAMETER col2
    Object to compare in 2nd column[-col2 `$PsObject1]
    PARAMETER col3
    Object to compare in 3rd column[-col3 `$PsObject1]
    PARAMETER col3
    Object to compare in 4th column[-col4 `$PsObject1]
    .INPUTS
    Acceptes piped input.
    .OUTPUTS
    Outputs specified object side-by-side on console
    .EXAMPLE
    PS> $object1 = New-Object PSObject -Property @{
          'Forename' = 'Richard';
          'Surname' = 'Slater';
          'Company' = 'Amido';
          'SelfEmployed' = $true;
        } ;
    PS> $object2 = New-Object PSObject -Property @{
          'Forename' = 'Jane';
          'Surname' = 'Smith';
          'Company' = 'Google';
          'MaidenName' = 'Jones' ;
        } ;
    PS> $object3 = New-Object PSObject -Property @{
          'Forename' = 'Zhe';
          'Surname' = 'Person';
          'Company' = 'Apfel';
          'MaidenName' = 'NunaUBusiness' ;
        } ;
    PS> $object4 = New-Object PSObject -Property @{
          'Forename' = 'Zir';
          'Surname' = 'NPC';
          'Company' = 'Facemook';
          'MaidenName' = 'Not!' ;
        } ;
    PS> Compare-ObjectsSideBySide4 $object1 $object2 $object3 $object4 | Format-Table Property, col1, col2, col3, col4;
    Display $object1,2,3 & 4 in comparative side-by-side columns
    .LINK
    https://stackoverflow.com/questions/37089766/powershell-side-by-side-objects
    #>
    PARAM(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Object to compare in 1st column[-col1 `$PsObject1]")]
        #[Alias('lhs')]
        $col1,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Object to compare in 2nd column[-col1 `$PsObject1]")]
        #[Alias('rhs')]        
        $col2,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Object to compare in 3rd column[-col1 `$PsObject1]")]
        #[Alias('rhs')]        
        $col3,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Object to compare in 4th column[-col1 `$PsObject1]")]
        #[Alias('rhs')]        
        $col4
    ) ;
    $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col3Members = $col3 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col4Members = $col4 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $combinedMembers = ($col1Members + $col2Members + $col3Members + $col4Members) | Sort-Object -COque ;
    $combinedMembers | ForEach-Object {
        $properties = @{'Property' = $_} ;
        if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
        if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
        if ($col3Members.Contains($_)) {$properties['Col3'] = $col3 | Select-Object -ExpandProperty $_} ;
        if ($col4Members.Contains($_)) {$properties['col4'] = $col4 | Select-Object -ExpandProperty $_} ;
        New-Object PSObject -Property $properties ;
    } ;
}

#*------^ Compare-ObjectsSideBySide4.ps1 ^------

#*------v convert-BinaryToDecimalStorageUnits.ps1 v------
Function convert-BinaryToDecimalStorageUnits {
    <#
    .SYNOPSIS
    convert-BinaryToDecimalStorageUnits.ps1 - Convert KiB|MiB|GiB|TiB|PiB binary storage units to bytes|mb|kb|gb|tb|pb.  Rationale: 'kilo' is a prefix for base-10 or decimal numbers, which doesn't actually apply to that figure when it's a representation of a binary number (as memory etc represent). The correct prefix is instead kibi, so 1024 bits is really a kibibit.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : convert-BinaryToDecimalStorageUnits.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    REVISIONS
    * 12:48 PM 10/20/2021 updated CBH w source article link, added comments
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    convert-BinaryToDecimalStorageUnits.ps1 - Convert KiB|MiB|GiB|TiB|PiB binary storage units to bytes|mb|kb|gb|tb|pb.  Rationale: 
    [Gigabytes and Gibibytes - What you need to know - Storage - Tech Explained - HEXUS.net - hexus.net/](https://hexus.net/tech/tech-explained/storage/1376-gigabytes-gibibytes-what-need-know/) : 
    The answer lies in the correct representation of binary numbers. When talking about a binary number like computer memory or processor cache, where the memory is made up of a series of memory cells that hold single bits of information, the number of memory cells is always power of 2. For instance, 1024 bits of memory, what you'd likely usually call a kilobit, is 2^10 bits. However, kilo is a prefix for base-10 or decimal numbers, so it doesn't actually apply to that figure when it's a representation of a binary number. The correct prefix is instead kibi, so 1024 bits is really a kibibit.

That rule applies everywhere. So what you'd usually think of as 1GB, or 1 gigabyte, isn't 1,000,000,000 bytes. Giga is the decimal prefix, so when you say gigabyte it means 1,000,000,000 bytes, not the 1,073,741,824 bytes it actually is (1024 * 1024 * 1024, all binary representations). Gibibyte is the correct term, abbreviated as 1GiB. So you have 1GiB of system memory, not 1GB.

The most common exception, where it's very correct, is the hard disk, where 1GB of disk space does actually mean 1,000,000,000 bytes. That's why for every 1GB of hard disk space, you actually see around 950MiB of space in your operating system (regardless of whether the OS tells you that's MB, which it isn't!).
    
For small values, it's a rounding error difference between GB\GiB. But as the values grow they significantly diverge. 
    Specific reason I wrote this: get-MediaInfoRaw() (MediaInfo.dll)'s native storage units ('binary') output is in '[KMGTP]iB' units, which I wanted converted to common [kmgtp]b decimal units.
    .PARAMETER Value
    String representation of a numeric size and units stated in 'KiB|MiB|GiB|TiB|PiB' [-value '1.39 GiB']
    .PARAMETER To
    Desired output metric (Bytes|KB|MB|GB|TB) [-To 'GB']
    .PARAMETER Decimals
    Decimal places of rounding[-Decimals 2]
    .OUTPUT
    Decimal size in converted decimal unit.
    .EXAMPLE
    $filesizeGB = '1.39 GiB' | convert-BinaryToDecimalStorageUnits -To GB -Decimals 2;
    Example converting a binary Gibibyte value into a decimal gigabyte value, rounded to 2 decimal places.
    .LINK
    https://hexus.net/tech/tech-explained/storage/1376-gigabytes-gibibytes-what-need-know/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    #[Alias('convert-xxx')]
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="String representation of a numeric size and units stated in 'KiB|MiB|GiB|TiB|PiB' [-value '1.39 GiB']")]
        #[ValidateNotNullOrEmpty()]
        [ValidatePattern("^([\d\.]+)((\s)*)([KMGTP]iB)$")]
        [string]$Value,
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Desired output metric (Bytes|KB}MB|GB|TB) [-To 'GB']")]
        [validateset('Bytes','KB','MB','GB','TB')]
        [string]$To='MB',
        [Parameter(HelpMessage="decimal places of rounding[-Decimals 2]")]
        [int]$Decimals = 4
    )
    if($value.contains(' ')){
        $size,$unit = $value.split(' ') ;
    } else {
        if($value  -match '^([\d\.]+)((\s)*)([KMGTP]iB)$'){
            $size = $matches[1] ;
            $unit = $matches[4] ;
        } ;
    }
    $smsg = "converting"
    switch ($unit){
        'PiB' {
            $smsg += " PiB" ;
            $inBytes = [double]($size * [math]::Pow(1024,5)) ; # pb-> pib would be gb/1024^5
        }
        'TiB' {
            # Tibibyte
            $smsg += " TiB" ;
            $inBytes = [double]($size * [math]::Pow(1024,4)) ; # tb-> tib would be gb/1024^4
        }
        'GiB' {
            # gibibyte
            $smsg += " GiB" ;
            write-verbose "converting  GiB -> $($To)" ;
            $inBytes = [double]($size * [math]::Pow(1024,3)) ; # gb-> gib would be gb/1024^3
        }
        'MiB' {
            # mebibyte
            $smsg += " MiB" ; 
            write-verbose "converting  MiB -> $($To)" ;
            $inBytes = [double]($size * [math]::Pow(1024,2) ) ; # mb-> mib would be gb/1024^2
        }
        'KiB' {
            # kibibyte
            $smsg += " KiB" ;
            $inBytes = [double]($size * 1024 ) ; # kb-> kib would be gb/1024
        }
        'Bytes' {
            $smsg += " Bytes" ; 
            $inBytes = [double]($size) ; 
        }
    } ;
    $smsg += " -> $($To) (round $($Decimals) places)" ; 
    write-verbose $smsg  ;
    switch($To){
        "Bytes" {$inBytes | write-output }
        "KB" {$output = $inBytes/1KB}
        "MB" {$output = $inBytes/1MB}
        "GB" {$output = $inBytes/1GB}
        "TB" {$output = $inBytes/1TB}
    } ;
    [Math]::Round($output,$Decimals,[MidPointRounding]::AwayFromZero) | write-output ;
}

#*------^ convert-BinaryToDecimalStorageUnits.ps1 ^------

#*------v convert-ColorHexCodeToWindowsMediaColorsName.ps1 v------
Function convert-ColorHexCodeToWindowsMediaColorsName {
    <#
    .SYNOPSIS
    convert-ColorHexCodeToWindowsMediaColorsName.ps1 - Convert color hexcodes into equiv [windows.media.colors] name value (if exists)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : convert-ColorHexCodeToWindowsMediaColorsName.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    AddedCredit : mdjxkln
    AddedWebsite:	https://xkln.net/blog/putting-the-powershell-window-title-to-better-use/
    REVISIONS
       * 11:36 AM 7/29/2021 completely unfinished, added (borked) code to populate $colors, but need to debug further. Looks like an abandoned concept that must have not been needed (likely around fact that ISE/VSC & winhost each implement colors differently, and aren't cross-compatible. 
       * 3:14 PM 4/19/2021 init vers
    .DESCRIPTION
    convert-ColorHexCodeToWindowsMediaColorsName.ps1 - Convert color hexcodes into equiv [windows.media.colors] name value (if exists)
    Issues: 1)Powershell ISE $psise supports a much wider range of colors than the native windows Console
    2) The ISE colors are accessible as: 
    $psise.Options.ConsolePaneBackgroundColor 
    $psISE.Options.ConsolePaneTextBackgroundColor
    $psISE.Options.ConsolePaneForegroundColor 
    ... but the values are RGB, or if .tostring() output as hex codes #FF9ACD32
    Neither of which are compatible with the windows console's color 'names'. 
    So I want a simple function to build an indexed hash of the [windows.media.colors] colors, and permit quick lookups of the hex value to return the matching [windows.media.colors] name value
    .PARAMETER ColorCode
    Colorhex code to be converted to [windows.media.colors] name value [-colorcode '#FF9ACD32'
    .OUTPUT
    Returns either a system.string containing the resolved WMC Color, or `$false, where no match was found for the specified ColorCode
    .EXAMPLE
    convert-ColorHexCodeToWindowsMediaColorsName 'EMS'
    Set the string 'EMS' as the powershell console Title Bar
    .EXAMPLE
    if ((Get-History).Count -gt 0) {
        convert-ColorHexCodeToWindowsMediaColorsName ((Get-History)[-1].CommandLine[0..25] -join '')
    }
    mdjxkln's example to set the title to the last entered command
    .EXAMPLE
    $ColorName = convert-ColorHexCodeToWindowsMediaColorsName -colorcode $psISE.Options.ConsolePaneTextBackgroundColor.tostring() 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param ([parameter(Mandatory = $true,Position=0,HelpMessage="Colorhex code to be converted to [windows.media.colors] name value [-colorcode '#FF9ACD32'")][String]$ColorCode)
    BEGIN{
        # build indexed hash of media colors keyed on hexcodes
        Add-Type –assemblyName PresentationFramework
        $colors = [windows.media.colors] | Get-Member -static -Type Property |  Select -Expand Name ;
        $ISEColors = @{} ;
        $colors| foreach {
            $hexcolor = ([windows.media.colors]::$($_.name)).tostring() ; 
            $ISEColors[$hexcolor] = $_.name  ; 
        } ;
    } 
    PROCESS{
        # try for a lookup of specified $colorcode against the hash
        if($Colorname = $isecolors[$colorcode]){
            $Colorname | write-output ; 
        } else { 
            write-verbose "Unable to convert specified -ColorCode ($($ColorCode)) to a matching [windows.media.colors] color." ; 
            $false | write-output ; 
        } 
    } ; 
    END {} ;
}

#*------^ convert-ColorHexCodeToWindowsMediaColorsName.ps1 ^------

#*------v convert-DehydratedBytesToGB.ps1 v------
Function convert-DehydratedBytesToGB {
    <#
    .SYNOPSIS
    convert-DehydratedBytesToGB - Convert MS Dehydrated byte sizes string - NN.NN MB (nnn,nnn,nnn bytes) - into equivelent decimal gigabytes.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : convert-DehydratedBytesToGB.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Conversion,Storage,Unit
    REVISIONS
    * 1:34 PM 2/25/2022 refactored CBH (was broken, non-parsing), renamed -data -> -string, retained prior name as a parameter alias
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    convert-DehydratedBytesToGB - Convert MS Dehydrated byte sizes string - NN.NN MB (nnn,nnn,nnn bytes) - into equivelent decimal gigabytes.
    .PARAMETER String
    Array of Dehydrated byte sizes to be converted
    .PARAMETER Decimals
    Number of decimal places to return on results
    .OUTPUTS
    System.String
    .EXAMPLE
    PS> (get-mailbox -id hoffmjj | get-mailboxstatistics).totalitemsize | convert-DehydratedBytesToGB ;
    Convert a series of get-MailboxStatistics.totalitemsize.values ("102.8 MB (107,808,015 bytes)") into decimal gigabyte values.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Array of Dehydrated byte sizes to be converted[-String `$array]")]
        [ValidateNotNullOrEmpty()]
        [Alias('Data')]
        [string[]]$String,
        [Parameter(HelpMessage="Number of decimal places to return on results[-Decimals 3]")]
        [int] $Decimals=3
    )
    BEGIN{
        $FmtCode = "{0:N$($Decimals)}" ; 
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 

    } 
    PROCESS{
        $Error.Clear() ; 
        If($String -match '.*\s\(.*\sbytes\)'){ 
            foreach($item in $String){
                # replace ".*(" OR "\sbytes\).*" OR "," (with nothing, results in the raw bytes numeric value), then foreach and format to gb or mb decimal places (depending on tomb or togb variant of the function)
                $item -replace '.*\(| bytes\).*|,' |foreach-object {$FmtCode  -f ($_ / 1GB)} | write-output ;
                # sole difference between GB & MB funcs is the 1GB/1MB above
            } ; 
        } else { 
            throw "unrecoginzed String series:Does not match 'nnnnnn.n MB (nnn,nnn,nnn bytes)' text format" ; 
            Continue ; 
        } ; 
    } ; 
    END {} ;
}

#*------^ convert-DehydratedBytesToGB.ps1 ^------

#*------v convert-DehydratedBytesToMB.ps1 v------
Function convert-DehydratedBytesToMB {
    <#
    .SYNOPSIS
    convert-DehydratedBytesToMB - Convert MS Dehydrated byte sizes string - NN.NN MB (nnn,nnn,nnn bytes) - into equivelent decimal megabytes.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : convert-DehydratedBytesToMB.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Conversion,Storage,Unit
    REVISIONS
    * 1:34 PM 2/25/2022 refactored CBH (was broken, non-parsing), renamed -data -> -string, retained prior name as a parameter alias
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    convert-DehydratedBytesToMB - Convert MS Dehydrated byte sizes string - NN.NN MB (nnn,nnn,nnn bytes) - into equivelent decimal megabytes.
    .PARAMETER String
    Array of Dehydrated byte sizes to be converted
    .PARAMETER Decimals
    Number of decimal places to return on results
    .OUTPUTS
    System.String
    .EXAMPLE
    PS> (get-mailbox -id hoffmjj | get-mailboxstatistics).totalitemsize | convert-DehydratedBytesToMB ;
    Convert a series of get-MailboxStatistics.totalitemsize.values ("102.8 MB (107,808,015 bytes)") into decimal gigabyte values.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Array of Dehydrated byte sizes to be converted[-String `$array]")]
        [ValidateNotNullOrEmpty()]
        [Alias('Data')]
        [string[]]$String,
        [Parameter(HelpMessage="Number of decimal places to return on results[-Decimals 3]")]
        [int] $Decimals=3
    )
    BEGIN{
        $FmtCode = "{0:N$($Decimals)}" ; 
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 

    } 
    PROCESS{
        $Error.Clear() ; 
        If($String -match '.*\s\(.*\sbytes\)'){ 
            foreach($item in $String){
                # replace ".*(" OR "\sbytes\).*" OR "," (with nothing, results in the raw bytes numeric value), then foreach and format to gb or mb decimal places (depending on tomb or togb variant of the function)
                $item -replace '.*\(| bytes\).*|,' |foreach-object {$FmtCode  -f ($_ / 1MB)} | write-output ;
                # sole difference between GB & MB funcs is the 1GB/1MB above
            } ; 
        } else { 
            throw "unrecoginzed String series:Does not match 'nnnnnn.n MB (nnn,nnn,nnn bytes)' text format" ; 
            Continue ; 
        } ; 
    } ; 
    END {} ;
}

#*------^ convert-DehydratedBytesToMB.ps1 ^------

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

#*------v ConvertFrom-CanonicalOU.ps1 v------
function ConvertFrom-CanonicalOU {
    <#
    .SYNOPSIS
    ConvertFrom-CanonicalOU.ps1 - This function takes a canonical OU path and converts it to a distinguished name.
    .NOTES
    Version     : 1.0.0
    Author      : joegasper
    Website     :	https://gist.github.com/joegasper/3fafa5750261d96d5e6edf112414ae18
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-12-15
    FileName    : 
    License     : (not specified)
    Copyright   : (not specified)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,ActiveDirectory,DistinguishedName,CanonicalName,Conversion
    AddedCredit : Todd Kadrie
    AddedWebsite:	http://www.toddomation.com
    AddedTwitter:	@tostka / http://twitter.com/tostka
    AddedCredit : McMichael
    AddedWebsite:	https://github.com/timmcmic/DLConversion/blob/master/src/DLConversion.ps1
    REVISIONS
    * 12:26 PM 6/18/2021 added alias:ConvertTo-DNOU
    * 4:30 PM 12/15/2020 TSK: expanded CBH, 
    .DESCRIPTION
    ConvertFrom-CanonicalOU.ps1 - This function takes a canonical OU path and converts it to a distinguished name.
    .PARAMETER  CanonicalName
    CanonicalName Name
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    DistinguishedName Name
    .EXAMPLE
    PS> Get-OrganizationalUnit 'OU=Users,OU=SITE,DC=SUB,DC=SUB2,DC=DOMAIN,DC=com' | select -expand distinguishedname | ConvertTo-CanonicalName | ConvertFrom-CanonicalOU
        OU=Users,OU=SITE,DC=SUB,DC=SUB2,DC=DOMAIN,DC=com
    Convert OU distinguishedname to Canonical format, and back to OU DistinguishedName
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('ConvertTo-DNOU')]
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
        [ValidateNotNullOrEmpty()] 
        [string]$CanonicalName
    )
    process {
        $obj = $CanonicalName.Replace(',','\,').Split('/')
        [string]$DN = "OU=" + $obj[$obj.count - 1]
        for ($i = $obj.count - 2;$i -ge 1;$i--){$DN += ",OU=" + $obj[$i]}
        $obj[0].split(".") | ForEach-Object { $DN += ",DC=" + $_}
        return $DN
    }
}

#*------^ ConvertFrom-CanonicalOU.ps1 ^------

#*------v ConvertFrom-CanonicalUser.ps1 v------
function ConvertFrom-CanonicalUser {
    <#
    .SYNOPSIS
    ConvertFrom-CanonicalUser.ps1 - This function takes a canonical name and converts it to a distinguished name.
    .NOTES
    Version     : 1.0.0
    Author      : joegasper
    Website     :	https://gist.github.com/joegasper/3fafa5750261d96d5e6edf112414ae18
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-12-15
    FileName    : 
    License     : (not specified)
    Copyright   : (not specified)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,ActiveDirectory,DistinguishedName,CanonicalName,Conversion
    AddedCredit : Todd Kadrie
    AddedWebsite:	http://www.toddomation.com
    AddedTwitter:	@tostka / http://twitter.com/tostka
    AddedCredit : McMichael
    AddedWebsite:	https://github.com/timmcmic/DLConversion/blob/master/src/DLConversion.ps1
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 12:26 PM 6/18/2021 added alias:ConvertTo-DNUser
    * 4:30 PM 12/15/2020 TSK: expanded CBH, 
    .DESCRIPTION
    ConvertFrom-CanonicalUser.ps1 - This function takes a canonical name and converts it to a distinguished name.
    .PARAMETER  DistinguishedName
    CanonicalName Name
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    DistinguishedName Name
    .EXAMPLE
    PS> get-aduser SOMEUSER | select -expand distinguishedname |
        ConvertFrom-DN | ConvertFrom-CanonicalOU
            OU=FName LName,OU=SomeOU,OU=Users,OU=SITE,DC=sub,DC=ad,DC=domain,DC=com
    Convert ADuser distinguishedname string to Canonical Name format, and back to DistinguishedName
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('ConvertTo-DNUser')]
    [cmdletbinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)] 
        [ValidateNotNullOrEmpty()] 
        [string]$CanonicalName
    )
    process {
        $obj = $CanonicalName.Replace(',','\,').Split('/')
        [string]$DN = "CN=" + $obj[$obj.count - 1]
        for ($i = $obj.count - 2;$i -ge 1;$i--){$DN += ",OU=" + $obj[$i]}
        $obj[0].split(".") | ForEach-Object { $DN += ",DC=" + $_}
        return $DN
    }
}

#*------^ ConvertFrom-CanonicalUser.ps1 ^------

#*------v ConvertFrom-CmdList.ps1 v------
filter ConvertFrom-CmdList {
    <#
    .SYNOPSIS
    ConvertFrom-CmdList - a filter that converts the returned data to objects (from comment on the main post)
    .NOTES
    Author: Axel Andersen
    Website:	http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 8:14 AM 11/24/2020 fixed CBH ref's to proper function
    * 8:35 AM 4/18/2017 getting null object Add-Member errors, so add a null test mid-foreach loop
    * 7:42 AM 4/18/2017 tweaked, added pshelp, comments etc, put into OTB
    * December 8, 2010 at 1:24 pmposted version
    .DESCRIPTION
    .INPUTS
    Pipeline
    .OUTPUTS
    Returns object for the matched task(s)
    .EXAMPLE
    schtasks.exe /query /s $ComputerName /FO List | ConvertFrom-CmdList
    .LINK
    http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    #>
    # 8:35 AM 4/18/2017 getting null object Add-Member errors, so add a null test mid-foreach loop
    $_ | foreach {
        if ($_ -match '^$') {
            $newobj = New-Object Object
            $obj | foreach {
                if ($_ -eq $null) {
                    # drop null properties
                }
                else {
                    $newobj | Add-Member NoteProperty $($_ -split ':')[0] "$($_ -replace '^.*:[ ]+')"
                } ;
            }
            $newobj
            $obj = @()
        }
        if ($_ -notmatch '^$') { $obj += $_ } ;
    }
}

#*------^ ConvertFrom-CmdList.ps1 ^------

#*------v ConvertFrom-DN.ps1 v------
function ConvertFrom-DN {
    <#
    .SYNOPSIS
    ConvertFrom-DN.ps1 - This function takes a distinguished name and converts it to a cononical name.
    .NOTES
    Version     : 1.0.0
    Author      : joegasper
    Website     :	https://gist.github.com/joegasper/3fafa5750261d96d5e6edf112414ae18
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-12-15
    FileName    : 
    License     : (not specified)
    Copyright   : (not specified)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,ActiveDirectory,DistinguishedName,CanonicalName,Conversion
    AddedCredit : Todd Kadrie
    AddedWebsite:	http://www.toddomation.com
    AddedTwitter:	@tostka / http://twitter.com/tostka
    AddedCredit : McMichael
    AddedWebsite:	https://github.com/timmcmic/DLConversion/blob/master/src/DLConversion.ps1
    REVISIONS
    * 12:26 PM 6/18/2021 added alias:ConvertTo-CanonicalName
    * 4:30 PM 12/15/2020 TSK: expanded CBH, 
    .DESCRIPTION
    .PARAMETER  DistinguishedName
    Distinguished Name
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Canonical Name
    .EXAMPLE
    PS> get-aduser SOMEUSER | select -expand distinguishedname |ConvertFrom-DN
            sub.domain.com/SITE/Users/SomeOU/FName LName
    Convert ADuser distinguishedname string to Canonical Name format.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('ConvertTo-CanonicalName')]
    [cmdletbinding()]
    param(
      [Parameter(Mandatory,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
      [ValidateNotNullOrEmpty()]
      [string[]]$DistinguishedName
    )

    process 
    {
        foreach ($DN in $DistinguishedName) 
        {
            foreach ( $item in ($DN.replace('\,','~').split(","))) 
            {
                switch ($item.TrimStart().Substring(0,2)) 
                {
                    'CN' {$CN = '/' + $item.Replace("CN=","")}

                    'OU' {$OU += ,$item.Replace("OU=","");$OU += '/'}

                    'DC' {$DC += $item.Replace("DC=","");$DC += '.'}

                }
            } 

            $CanonicalName = $DC.Substring(0,$DC.length - 1)

            for ($i = $OU.count;$i -ge 0;$i -- )
            {
                $CanonicalName += $OU[$i]
            }

            if ( $DN.Substring(0,2) -eq 'CN' ) 
            {
                $CanonicalName += $CN.Replace('~','\,')
			}
            Write-Output $CanonicalName
        }
    }
}

#*------^ ConvertFrom-DN.ps1 ^------

#*------v ConvertFrom-IniFile.ps1 v------
Function ConvertFrom-IniFile {
    <#
    .Synopsis
    Convert an INI file to an object
    ConvertFrom-IniFile.ps1 - convert a legacy INI file into a PowerShell custom object. Each INI section will become a property name. Then each section setting will become a nested object. Blank lines and comments starting with ; will be ignored.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell
    AddedCredit : Jeff Hicks
    AddedWebsite: https://www.petri.com/managing-ini-files-with-powershell
    AddedTwitter: 
    Learn more about PowerShell:
    http://jdhitsolutions.com/blog/essential-powershell-resources/
    REVISIONS
    * 12:46 PM 6/29/2021 minor vervisions & syntax tightening; expanded CBH; added delimiting to unexpected line dump
    * posted rev 1/29/2015 (June 5, 2015)
    .Description
    Use this command to convert a legacy INI file into a PowerShell custom object. Each INI section will become a property name. Then each section setting will become a nested object. Blank lines and comments starting with ; will be ignored. 
    It is assumed that your ini file follows a typical layout like this:
    ```text
    ;This is a sample ini
    [General]
    Action = Start
    Directory = c:\work
    ID = 123ABC
   ;this is another comment
    [Application]
    Name = foo.exe
    Version = 1.0
    [User]
    Name = Jeff
    Company = Globomantics
    ``` ;
    .PARAMETER Path
    The path to the INI file.
    .INPUTS
    [string]
    .OUTPUTS
    [pscustomobject]
    .EXAMPLE
    PS> $sample = ConvertFrom-IniFile c:\scripts\sample.ini
    PS> $sample
        General                           Application                      User                            
        -------                           -----------                      ----                            
        @{Directory=c:\work; ID=123ABC... @{Version=1.0; Name=foo.exe}     @{Name=Jeff; Company=Globoman...
    PS> $sample.general.action
        Start
    In this example, a sample ini file is converted to an object with each section a separate property.
    .EXAMPLE
    PS> ConvertFrom-IniFile c:\windows\system.ini | export-clixml c:\work\system.ini
    Convert the System.ini file and export results to an XML format.
    .LINK
    Get-Content
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [cmdletbinding()]
    Param(
        [Parameter(Position=0,Mandatory,HelpMessage="Enter the path to an INI file",
        ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("fullname","pspath")]
        [ValidateScript({
        if (Test-Path $_) {$True}else {Throw "Cannot validate path $_"}
        })]     
        [string]$Path
    )
    Begin {
        # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        # Get parameters this function was invoked with
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        $Verbose = ($VerbosePreference -eq 'Continue') ; 
        Write-Verbose "Starting $($MyInvocation.Mycommand)" ; 
    } 
    Process {
        Write-Verbose "Getting content from $(Resolve-Path $path)"
        #strip out comments that start with ; and blank lines
        $all = Get-content -Path $path | Where {$_ -notmatch "^(\s+)?;|^\s*$"}
        $obj = New-Object -TypeName PSObject -Property @{}
        $hash = [ordered]@{}
        foreach ($line in $all) {
            Write-Verbose "Processing $line" ; 
            if ($line -match "^\[.*\]$" -AND $hash.count -gt 0) {
                #has a hash count and is the next setting
                #add the section as a property
                write-Verbose "Creating section $section" ; 
                Write-verbose ([pscustomobject]$hash | out-string) ; 
                $obj | Add-Member -MemberType Noteproperty -Name $Section -Value $([pscustomobject]$Hash) -Force ; 
                #reset hash
                Write-Verbose "Resetting hashtable" ; 
                $hash=[ordered]@{} ; 
                #define the next section
                $section = $line -replace "\[|\]","" ; 
                Write-Verbose "Next section $section" ; 
            } elseif ($line -match "^\[.*\]$") {
                #Get section name. This will only run for the first section heading
                $section = $line -replace "\[|\]","" ; 
                Write-Verbose "New section $section"
            } elseif ($line -match "=") {
                #parse data
                $data = $line.split("=").trim() ; 
                $hash.add($data[0],$data[1]) ; 
            } else {
                #this should probably never happen
                Write-Warning "Unexpected line:`n'$($line|out-string)'" ; 
            } ; 
        }  ;  # loop-E
        #get last section
        If ($hash.count -gt 0) {
            Write-Verbose "Creating final section $section" ; 
            Write-Verbose ([pscustomobject]$hash | Out-String) ; 
            #add the section as a property
            $obj | Add-Member -MemberType Noteproperty -Name $Section -Value $([pscustomobject]$Hash) -Force ; 
        }
        #write the result to the pipeline
        $obj | write-output ;
    } ;
    End {
        Write-Verbose "Ending $($MyInvocation.Mycommand)" ; 
    } ;
}

#*------^ ConvertFrom-IniFile.ps1 ^------

#*------v convertFrom-MarkdownTable.ps1 v------
Function convertFrom-MarkdownTable {
    <#
    .SYNOPSIS
    convertFrom-MarkdownTable.ps1 - Converts a Markdown table to a PowerShell object.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-06-21
    FileName    : convertFrom-MarkdownTable.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Markdown,Input,Conversion
    REVISION
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 12:42 PM 6/22/2021 bug workaround: empty fields in source md table (|data||data|) cause later (export-csv|convertto-csv) to create a csv with *missing* delimiting comma on the problem field ;  added trim of each field content, and CBH example for creation of a csv from mdtable input; added aliases
    * 5:40 PM 6/21/2021 init
    .DESCRIPTION
    convertFrom-MarkdownTable.ps1 - Converts a Markdown table to a PowerShell object.
    Also supports convesion of variant 'border' md table syntax (e.g. each line wrapped in outter pipe | chars)
    Intent is as a simpler alternative to here-stringinputs for csv building. 
    .PARAMETER markdowntext
    Markdown-formated table to be converted into an object [-markdowntext 'title text']
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.Object[]
   .EXAMPLE
   PS> $svcs = Get-Service Bits,Winrm | select status,name,displayname | 
      convertTo-MarkdownTable -border | ConvertFrom-MarkDownTable ;  
   Convert Service listing to and back from MD table, demo's working around border md table syntax (outter pipe-wrapped lines)
   PS> $mdtable = @"
|EmailAddress|DisplayName|Groups|Ticket|
|---|---|---|---|
|da.pope@vatican.org||CardinalDL@vatican.org|999999|
|bozo@clown.com|Bozo Clown|SillyDL;SmartDL|000001|
"@ ; 
      $of = ".\out-csv-$(get-date -format 'yyyyMMdd-HHmmtt').csv" ; 
      $mdtable | convertfrom-markdowntable | export-csv -path $of -notype ;
      cat $of ;

        "EmailAddress","DisplayName","Groups","Ticket"
        "da.pope@vatican.org","","CardinalDL@vatican.org","999999"
        "bozo@clown.com","Bozo Clown","SillyDL;SmartDL","000001"

    Example simpler method for building csv input files fr mdtable syntax, without PSCustomObjects, hashes, or invoked object creation.
    .EXAMPLE
    PS> $mdtable | convertFrom-MarkdownTable | convertTo-MarkdownTable -border ; 
    Example to expand and dress up a simple md table, leveraging both convertfrom-mtd and convertto-mtd (which performs space padding to align pipe columns)
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [alias('convertfrom-mdt','in-markdowntable','in-mdt')]    
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Markdown-formated table to be converted into an object [-markdowntext 'title text']")]
        $markdowntext
    ) ;
    PROCESS {
        $content = @() ; 
        if(($markdowntext|measure).count -eq 1){$markdowntext  = $markdowntext -split '\n' } ;
        # # bug, empty fields (||) when exported (export-csv|convertto-csv) -> broken csv (missing delimiting comma between 2 fields). 
        # workaround : flip empty field => \s. The $object still comes out properly $null on the field, but the change cause export-csv of the resulting obj to no longer output a broken csv.(weird)
        $markdowntext  = $markdowntext -replace '\|\|','| |' ; 
        $content = $markdowntext  | ?{$_ -notmatch "--" } ;
    } ;  
    END {
        # trim lead/trail '| from each line (borders) ; remove empty lines; foreach
        $PsObj = $content.trim('|')| where-object{$_} | ForEach-Object{ 
            $_.split('|').trim() -join '|' ; # split fields and trim leading/trailing spaces from each , then re-join with '|'
        } | ConvertFrom-Csv -Delimiter '|'; # convert to object
        $PsObj | write-output ; 
    } ; # END-E
}

#*------^ convertFrom-MarkdownTable.ps1 ^------

#*------v ConvertFrom-SourceTable.ps1 v------
Function ConvertFrom-SourceTable {
  <#
  .SYNOPSIS
  Converts a fixed column table to objects.
  .NOTES
  Version     : 0.3.11
  Author      : iRon
  Website     : https://github.com/iRon7/ConvertFrom-SourceTable/
  Twitter     : 
  CreatedDate : 2020-03-27
  FileName    : ConvertFrom-SourceTable
  License     : https://github.com/iRon7/ConvertFrom-SourceTable/LICENSE.txt
  Copyright   : (Not specified)
  AddedCredit : Todd Kadrie
  AddedWebsite:	http://www.toddomation.com
  AddedTwitter:	@tostka / http://twitter.com/tostka
  Github      : https://github.com/iRon7/ConvertFrom-SourceTable
  Tags        : Powershell,Conversion,Text
  REVISIONS
  * 10:35 AM 2/21/2022 CBH example ps> adds 
  0.3.11 2020-03-27 Added -Omit parameter (Each omitted character will be replaced with a space)
  .DESCRIPTION
  The ConvertFrom-SourceTable cmdlet creates objects from a fixed column
  source table (format-table) possibly surrounded by horizontal and/or
  vertical rulers. The ConvertFrom-SourceTable cmdlet supports most data
  types using the following formatting and alignment rules:

  Data that is left aligned will be parsed to the generic column type
  which is a string by default.

  Data that is right aligned will be evaluated.

  Data that is justified (using the full column with) is following the
  the header alignment and evaluated if the header is right aligned.

  The default column type can be set by prefixing the column name with
  a standard (PowerShell) cast operator (a data type enclosed in
  square brackets, e.g.: "[Int]ID")

  Definitions:
  The width of a source table column is outlined by the header width,
  the ruler width and the width of the data.

  Column and Data alignment (none, left, right or justified) is defined
  by the existence of a character at the start or end of a column.

  Column alignment (which is used for a default field alignment) is
  defined by the first and last character or space of the header and
  the ruler of the outlined column.

.PARAMETER InputObject
  Specifies the source table strings to be converted to objects.
  Enter a variable that contains the source table strings or type a
  command or expression that gets the source table strings.
  You can also pipe the source table strings to ConvertFrom-SourceTable.
  Note that streamed table rows are intermediately processed and
  released for the next cmdlet. In this mode, there is a higher
  possibility that floating tables or column data cannot be determined
  to be part of a specific column (as there is no overview of the table
  data that follows). To resolve this, use one of the folowing ruler or
  header specific parameters.
  .PARAMETER Header
  A string that defines the header line of an headless table or a multiple
  strings where each item represents the column name.
  In case the header contains a single string, it is used to define the
  (property) names, the size and alignment of the column, therefore it is
  key that the columns names are properly aligned with the rest of the
  column (including any table indents).
  If the header contains multiple strings, each string will be used to
  define the property names of each object. In this case, column alignment
  is based on the rest of the data and possible ruler.
  .PARAMETER Ruler
  A string that replaces any (horizontal) ruler in the input table which
  helps to define character columns in occasions where the table column
  margins are indefinable.
  .PARAMETER HorizontalDash
  This parameter (Alias -HDash) defines the horizontal ruler character.
  By default, each streamed table row (or a total raw table) will be
  searched for a ruler existing out of horizontal dash characters ("-"),
  spaces and possible vertical dashes. If the ruler is found, the prior
  line is presumed to be the header. If the ruler is not found within
  the first (two) streamed data lines, the first line is presumed the
  header line.
  If -HorizontalDash explicitly defined, all (streamed) lines will be
  searched for a matching ruler.
  If -HorizontalDash is set to `$Null`, the first data line is presumed
  the header line (unless the -VerticalDash parameter is set).
  .PARAMETER VerticalDash
  This parameter (Alias -VDash) defines the vertical ruler character.
  By default, each streamed table row (or a total raw table) will be
  searched for a header with vertical dash characters ("|"). If the
  header is not found within the first streamed data line, the first
  line is presumed the header line.
  If -VerticalDash explicitly defined, all (streamed) lines will be
  searched for a header with a vertical dash character.
  If -VerticalDash is set to `$Null`, the first data line is presumed
  the header line (unless the -HorizontalDash parameter is set).
  .PARAMETER Junction
  The -Junction parameter (default: "+") defines the character used for
  the junction between the horizontal ruler and vertical ruler.
  .PARAMETER Anchor
  The -Anchor parameter (default: ":") defines the character used for
  the alignedment anchor. If used in the header row, it will be used to
  define the default alignment, meaning that justified (full width)
  values will be evaluted.
  .PARAMETER Omit
  A string of characters to omit from the header and data. Each omitted
  character will be replaced with a space.
  .PARAMETER Literal
  The -Literal parameter will prevent any right aligned data to be
  evaluated.
  .EXAMPLE
  PS> $Colors = ConvertFrom-SourceTable '
Name       Value         RGB
----       -----         ---
Black   0x000000       0,0,0
White   0xFFFFFF 255,255,255
Red     0xFF0000     255,0,0
Lime    0x00FF00     0,255,0
Blue    0x0000FF     0,0,255
Yellow  0xFFFF00   255,255,0
Cyan    0x00FFFF   0,255,255
Magenta 0xFF00FF   255,0,255
Silver  0xC0C0C0 192,192,192
Gray    0x808080 128,128,128
Maroon  0x800000     128,0,0
Olive   0x808000   128,128,0
Green   0x008000     0,128,0
Purple  0x800080   128,0,128
Teal    0x008080   0,128,128
Navy    0x000080     0,0,128
' ;

  PS> $Colors | Where {$_.Name -eq "Red"} ; 

    Name    Value RGB
    ----    ----- ---
    Red  16711680 {255, 0, 0}

  .EXAMPLE
  PS> $Employees = ConvertFrom-SourceTable '
| Department  | Name    | Country |
| ----------- | ------- | ------- |
| Sales       | Aerts   | Belgium |
| Engineering | Bauer   | Germany |
| Sales       | Cook    | England |
| Engineering | Duval   | France  |
| Marketing   | Evans   | England |
| Engineering | Fischer | Germany |
' ;

  .EXAMPLE
  PS> $ChangeLog = ConvertFrom-SourceTable '
[Version] [DateTime]Date Author      Comments
--------- -------------- ------      --------
0.0.10    2018-05-03     Ronald Bode First design
0.0.20    2018-05-09     Ronald Bode Pester ready version
0.0.21    2018-05-09     Ronald Bode removed support for String[] types
0.0.22    2018-05-24     Ronald Bode Better "right aligned" definition
0.0.23    2018-05-25     Ronald Bode Resolved single column bug
0.0.24    2018-05-26     Ronald Bode Treating markdown table input as an option
0.0.25    2018-05-27     Ronald Bode Resolved error due to blank top lines
' ;

  .EXAMPLE
  PS> $Files = ConvertFrom-SourceTable -Literal '
Mode                LastWriteTime         Length Name
----                -------------         ------ ----
d----l       11/16/2018   8:30 PM                Archive
-a---l        5/22/2018  12:05 PM          (726) Build-Expression.ps1
-a---l       11/16/2018   7:38 PM           2143 CHANGELOG
-a---l       11/17/2018  10:42 AM          14728 ConvertFrom-SourceTable.ps1
-a---l       11/17/2018  11:04 AM          23909 ConvertFrom-SourceTable.Tests.ps1
-a---l         8/4/2018  11:04 AM         (6237) Import-SourceTable.ps1
  ' ;
  .LINK
  Online Version: https://github.com/iRon7/ConvertFrom-SourceTable
  #>
  [Alias('cfst')]
	[CmdletBinding()][OutputType([Object[]])]Param (
		[Parameter(ValueFromPipeLine = $True)][String[]]$InputObject, [String[]]$Header, [String]$Ruler,
		[Alias("HDash")][Char]$HorizontalDash = '-', [Alias("VDash")][Char]$VerticalDash = '|',
		[Char]$Junction = '+', [Char]$Anchor = ':', [String]$Omit, [Switch]$Literal
	)
	Begin {
		Enum Alignment {None; Left; Right; Justified}
		Enum Mask {All = 8; Header = 4; Ruler = 2; Data = 1}
		$Auto = !$PSBoundParameters.ContainsKey('HorizontalDash') -and !$PSBoundParameters.ContainsKey('VerticalDash')
		$HRx = If ($HorizontalDash) {'\x{0:X2}' -f [Int]$HorizontalDash}
		$VRx = If ($VerticalDash)   {'\x{0:X2}' -f [Int]$VerticalDash}
		$JNx = If ($Junction)       {'\x{0:X2}' -f [Int]$Junction}
		$ANx = If ($Anchor)         {'\x{0:X2}' -f [Int]$Anchor}
		$RulerPattern = If ($VRx) {"^[$HRx$VRx$JNx$ANx\s]*$HRx[$HRx$VRx$JNx$ANx\s]*$"} ElseIf ($HRx) {"^[$HRx\s]*$HRx[$HRx\s]*$"} Else {'\A(?!x)x'}
		If (!$PSBoundParameters.ContainsKey('Ruler') -and $HRx) {Remove-Variable 'Ruler'; $Ruler = $Null}
		If (!$Ruler -and !$HRx -and !$VRx) {$Ruler = ''}
		If ($Ruler) {$Ruler = $Ruler -Split '[\r\n]+' | Where-Object {$_.Trim()} | Select-Object -First 1}
		$HeaderLine = If (@($Header).Count -gt 1) {''} ElseIf ($Header) {$Header}
		$TopLine = If ($HeaderLine) {''}; $LastLine, $OuterLeftColumn, $OuterRightColumn, $Mask = $Null; $RowIndex = 0; $Padding = 0; $Columns = @()
		$Property = New-Object System.Collections.Specialized.OrderedDictionary								# Include support from PSv2
		Function Null {$Null}; Function True {$True}; Function False {$False};								# Wrappers
		Function Debug-Column {
			If ($VRx) {Write-Debug $Mask}
			Else {Write-Debug (($Mask | ForEach-Object {If ($_) {'{0:x}' -f $_} Else {' '}}) -Join '')}
			$CharArray = (' ' * ($Columns[-1].End + 1)).ToCharArray()
 			For ($i = 0; $i -lt $Columns.Length; $i++) {$Column = $Columns[$i]
				For ($c = $Column.Start + $Padding; $c -le $Column.End - $Padding; $c++) {$CharArray[$c] = '-'}
				$CharArray[($Column.Start + $Column.End) / 2] = "$i"[-1]
				If ($Column.Alignment -bAnd [Alignment]::Left)  {$CharArray[$Column.Start + $Padding] = ':'}
				If ($Column.Alignment -bAnd [Alignment]::Right) {$CharArray[$Column.End - $Padding]   = ':'}
			}
			Write-Debug ($CharArray -Join '')
		}
		Function Mask([String]$Line, [Byte]$Or = [Mask]::Data) {
			$Init = [Mask]::All * ($Null -eq $Mask)
			If ($Init) {([Ref]$Mask).Value = New-Object Collections.Generic.List[Byte]}
			For ($i = 0; $i -lt ([Math]::Max($Mask.Count, $Line.Length)); $i++) {
				If ($i -ge $Mask.Count) {([Ref]$Mask).Value.Add($Init)}
				$Mask[$i] = If ($Line[$i] -Match '\S') {$Mask[$i] -bOr $Or} Else {$Mask[$i] -bAnd (0xFF -bXor [Mask]::All)}
			}
		}
		Function Slice([String]$String, [Int]$Start, [Int]$End = [Int]::MaxValue) {
			If ($Start -lt 0) {$End += $Start; $Start = 0}
			If ($End -ge 0 -and $Start -lt $String.Length) {
				If ($End -lt $String.Length) {$String.Substring($Start, $End - $Start + 1)} Else {$String.Substring($Start)}
			} Else {$Null}
		}
		Function TypeName([String]$TypeName) {
			If ($Literal) {
				$Null, $TypeName.Trim()
			} Else {
				$Null = $TypeName.Trim() -Match '(\[(.*)\])?\s*(.*)'
				$Matches[2]
				If($Matches[3]) {$Matches[3]} Else {$Matches[2]}
			}
		}
		Function ErrorRecord($Line, $Start, $End, $Message) {
			$Exception = New-Object System.InvalidOperationException "
$Message
+ $($Line -Replace '[\s]', ' ')
+ $(' ' * $Start)$('~' * ($End - $Start + 1))
"
			New-Object Management.Automation.ErrorRecord $Exception,
				$_.Exception.ErrorRecord.FullyQualifiedErrorId,
				$_.Exception.ErrorRecord.CategoryInfo.Category,
				$_.Exception.ErrorRecord.TargetObject
		}
	}
	Process {
		$Lines = $InputObject -Split '[\r\n]+'
		If ($Omit) {
			$Lines = @(ForEach ($Line in $Lines) {
				ForEach ($Char in [Char[]]$Omit) {$Line = $Line.Replace($Char, ' ')}
				$Line
			})
		}
		$NextIndex, $DataIndex = $Null
		If (!$Columns) {
			For ($Index = 0; $Index -lt $Lines.Length; $Index++) {
				$Line = $Lines[$Index]
				If ($Line.Trim()) {
					If ($Null -ne $HeaderLine) {
						If ($Null -ne $Ruler) {
							If ($Line -NotMatch $RulerPattern) {$DataIndex = $Index}
						} Else {
							If ($Line -Match $RulerPattern) {$Ruler = $Line}
							Else {
								$Ruler = ''
								$DataIndex = $Index
							}
						}
					} Else {
						If ($Null -ne $Ruler) {
							If ($LastLine -and (!$VRx -or $Ruler -NotMatch $VRx -or $LastLine -Match $VRx) -and $Line -NotMatch $RulerPattern) {
								$HeaderLine = $LastLine
								$DataIndex = $Index
							}
						} Else {
							If (!$RulerPattern) {
								$HeaderLine = $Line
							} ElseIf ($LastLine -and (!$VRx -or $Line -NotMatch $VRx -or $LastLine -Match $VRx) -and $Line -Match $RulerPattern) {
								$HeaderLine = $LastLine
								If (!$Ruler) {$Ruler = $Line}
							}
						}
					}
					If ($Line -NotMatch $RulerPattern) {
						If ($VRx -and $Line -Match $VRx -and $TopLine -NotMatch $VRx) {$TopLine = $Line; $NextIndex = $Null}
						ElseIf ($Null -eq $TopLine) {$TopLine = $Line}
						ElseIf ($Null -eq $NextIndex) {$NextIndex = $Index}
						$LastLine = $Line
					}
					If ($DataIndex) {Break}
				}
			}
			If (($Auto -or ($VRx -and $TopLine -Match $VRx)) -and $Null -ne $NextIndex) {
				If ($Null -eq $HeaderLine) {
					$HeaderLine = $TopLine
					If ($Null -eq $Ruler) {$Ruler = ''}
					$DataIndex = $NextIndex
				} ElseIf ($Null -eq $Ruler) {
					$Ruler = ''
					$DataIndex = $NextIndex
				}
			}
			If ($Null -ne $DataIndex) {
				$HeaderLine = $HeaderLine.TrimEnd()
				If ($TopLine -NotMatch $VRx) {
					$VRx = ''
					If ($Ruler -NotMatch $ANx) {$ANx = ''}
				}
				If ($VRx) {
					$Index = 0; $Start = 0; $Length = $Null; $Padding = [Int]::MaxValue
					If ($Ruler) {
						$Start = $Ruler.Length - $Ruler.TrimStart().Length
						If ($Ruler.Length -gt $HeaderLine.Length) {$HeaderLine += ' ' * ($Ruler.Length - $HeaderLine.Length)}
					}
					$Mask = '?' * $Start
					ForEach ($Column in ($HeaderLine.SubString($Start) -Split $VRx)) {
						If ($Null -ne $Length) {$Mask += '?' * $Length + $VerticalDash}
						$Length = $Column.Length
						$Type, $Name = If (@($Header).Count -le 1) {TypeName $Column.Trim()}
						               ElseIf ($Index -lt @($Header).Count) {TypeName $Header[$Index]}
						If ($Name) {
							$End = $Start + $Length - 1
							$Padding = [Math]::Min($Padding, $Column.Length - $Column.TrimStart().Length)
							If ($Ruler -or $End -lt $HeaderLine.Length -1) {$Padding = [Math]::Min($Padding, $Column.Length - $Column.TrimEnd().Length)}
							$Columns += @{Index = $Index; Name = $Column; Type = $Null; Start = $Start; End = $End}
							$Property.Add($Name, $Null)
						}
						$Index++; $Start += $Column.Length + 1
					}
					$Mask += '*'
					ForEach ($Column in $Columns) {
						$Anchored = $Ruler -and $ANx -and $Ruler -Match $ANx
						If (!$Ruler) {
							If ($Column.Start -eq 0) {
								$Column.Start = [Math]::Max($HeaderLine.Length - $HeaderLine.TrimStart().Length - $Padding, 0)
								$OuterLeftColumn = $Column
							} ElseIf ($Column.End -eq $HeaderLine.Length -1) {
								$Column.End = $HeaderLine.TrimEnd().Length + $Padding
								$OuterRightColumn = $Column
							}
						}
						$Column.Type, $Column.Name = TypeName $Column.Name.Trim()
						If ($Anchored) {
							$Column.Alignment = [Alignment]::None
							If ($Ruler[$Column.Start] -Match $ANx) {$Column.Alignment = $Column.Alignment -bor [Alignment]::Left}
							If ($Ruler[$Column.End]   -Match $ANx) {$Column.Alignment = $Column.Alignment -bor [Alignment]::Right}
						} Else {
							$Column.Alignment = [Alignment]::Justified
							If ($HeaderLine[$Column.Start + $Padding] -NotMatch '\S') {$Column.Alignment = $Column.Alignment -band -bnot [Alignment]::Left}
							If ($HeaderLine[$Column.End   - $Padding] -NotMatch '\S') {$Column.Alignment = $Column.Alignment -band -bnot [Alignment]::Right}
						}
					}
				} Else {
					Mask $HeaderLine ([Mask]::Header)
					If ($Ruler) {Mask $Ruler ([Mask]::Ruler)}
				 	$Lines | Select-Object -Skip $DataIndex | Where-Object {$_.Trim()} | Foreach-Object {Mask $_}
					If (!$Ruler -and $HRx) {									# Connect (rulerless) single spaced headers where either column is empty
						$InWord = $False; $WordMask = 0
						For ($i = 0; $i -le $Mask.Count; $i++) {
							If($i -lt $Mask.Count) {$WordMask = $WordMask -bor $Mask[$i]}
							$Masked = $i -lt $Mask.Count -and $Mask[$i]
							If ($Masked -and !$InWord) {$InWord = $True; $Start = $i}
							ElseIf (!$Masked -and $InWord) {$InWord = $False; $End = $i - 1
								If ([Mask]::Header -eq $WordMask -bAnd 7) {		# only header
									If ($Start -ge 2 -and $Mask[$Start - 2] -band [Mask]::Header) {$Mask[$Start - 1] = [Mask]::Header}
									ElseIf (($End + 2) -lt $Mask.Count -and $Mask[$End + 2] -band [Mask]::Header) {$Mask[$End + 1] = [Mask]::Header}
								}
								$WordMask = 0
							}
						}
					}
					$InWord = $False; $Index = 0; $Start = $Null
					For ($i = 0; $i -le $Mask.Count; $i++) {
						$Masked = $i -lt $Mask.Count -and $Mask[$i]
						If ($Masked -and !$InWord) {$InWord = $True; $Start = $i}
						ElseIf (!$Masked -and $InWord) {$InWord = $False; $End = $i - 1
							$Type, $Name = If (@($Header).Count -le 1) {TypeName "$(Slice -String $HeaderLine -Start $Start -End $End)".Trim()}
							               ElseIf ($Index -lt @($Header).Count) {TypeName $Header[$Index]}
							If ($Name) {
								If ($Columns.Where{$_.Name -eq $Name}) {Write-Warning "Duplicate column name: $Name."}
								Else {
									If ($Type) {$Type = Try {[Type]$Type} Catch {
										Write-Error -ErrorRecord (ErrorRecord -Line $HeaderLine -Start $Start -End $End -Message (
											"Unknown type {0} in header at column '{1}'" -f $Type, $Name
										))
									}}
									$Columns += @{Index = $Index++; Name = $Name; Type = $Type; Start = $Start; End = $End; Alignment = $Null}
									$Property.Add($Name, $Null)
								}
							}
						}
					}
				}
				$RulerPattern = If ($Ruler) {'^' + ($Ruler -Replace "[^$HRx]", "[$VRx$JNx$ANx\s]" -Replace "[$HRx]", "[$HRx]")} Else {'\A(?!x)x'}
			}
		}
		If ($Columns) {
			If ($VRx) {
				ForEach ($Line in ($Lines | Where-Object {$_ -like $Mask})) {
					If ($OuterLeftColumn) {
						$Start = [Math]::Max($Line.Length - $Line.TrimStart().Length - $Padding, 0)
						If ($Start -lt $OuterLeftColumn.Start) {
							$OuterLeftColumn.Start = $Start
							$OuterLeftColumn.Alignment = $Column.Alignment -band -bnot [Alignment]::Left
						}
					} ElseIf ($OuterRightColumn) {
						$End = $Line.TrimEnd().Length + $Padding
						If ($End -gt $OuterRightColumn.End) {
							$OuterRightColumn.End = $End
							$OuterRightColumn.Alignment = $Column.Alignment -band -bnot [Alignment]::Right
						}
					}
				}
			} Else {
				$HeadMask = If ($Ruler) {[Mask]::Header -bOr [Mask]::Ruler} Else {[Mask]::Header}
				$Lines | Select-Object -Skip (0 + $DataIndex) | Where-Object {$_.Trim()} | Foreach-Object {Mask $_}
				For ($c = 0; $c -lt $Columns.Length; $c++) {$Column = $Columns[$c]
					$NextRight = If ($c -lt $Columns.Length) {$Columns[$c + 1]}
					$Margin = If ($NextRight) {$NextRight.Start - 2} Else {$Mask.Count - 1}
					$Justify = If ($NextRight) {$NextRight.Alignment -eq [Alignment]::Left} Else {$True}
					If ($Column.Alignment -ne [Alignment]::Right) {
						For ($i = $Column.End + 1; $i -le $Margin; $i++) {If ($Mask[$i]) {$Column.End  = $i} ElseIf (!$Justify) {Break}}
					}

					$NextLeft = If ($c -gt 0) {$Columns[$c - 1]}
					$Margin = If ($NextLeft) {$NextLeft.End + 2} Else {0}
					$Justify = If ($NextLeft) {$NextLeft.Alignment -eq [Alignment]::Right} Else {$True}
					If ($Column.Alignment -ne [Alignment]::Left) {
						For ($i = $Column.Start - 1; $i -ge $Margin; $i--) {If ($Mask[$i]) {$Column.Start = $i} ElseIf (!$Justify) {Break}}
					}

					If (!$Column.Alignment) {
						$MaskStart = $Mask[$Column.Start];         $MaskEnd = $Mask[$Column.End]
						$HeadStart = $MaskStart -bAnd $HeadMask;   $HeadEnd = $MaskEnd -bAnd $HeadMask
						$AllStart  = $MaskStart -bAnd [Mask]::All; $AllEnd  = $MaskEnd -bAnd [Mask]::All
						$IsLeftAligned  = ($HeadStart -eq $HeadMask -and $HeadEnd -ne $HeadMask) -Or ($AllStart -and !$AllEnd)
						$IsRightAligned = ($HeadStart -ne $HeadMask -and $HeadEnd -eq $HeadMask) -Or (!$AllStart -and $AllEnd)
						If ($IsLeftAligned)  {$Column.Alignment = $Column.Alignment -bOr [Alignment]::Left}
						If ($IsRightAligned) {$Column.Alignment = $Column.Alignment -bOr [Alignment]::Right}
						If ($Column.Alignment) {If ($c -gt 0) {$c = $c - 2}}
					}
				}
			}
			If ($DebugPreference -ne 'SilentlyContinue' -and !$RowIndex) {Write-Debug ($HeaderLine -Replace '\s', ' '); Debug-Column}
			ForEach ($Line in ($Lines | Select-Object -Skip ([Int]$DataIndex))) {
				If ($Line.Trim() -and ($Line -NotMatch $RulerPattern)) {
					$RowIndex++
					If ($DebugPreference -ne 'SilentlyContinue') {Write-Debug ($Line -Replace '\s', ' ')}
					$Fields = If ($VRx -and $Line -notlike $Mask) {$Line -Split $VRx}
					ForEach($Column in $Columns) {
						$Property[$Column.Name] = If ($Fields) {
							$Fields[$Column.Index].Trim()
						} Else {
							$Field = Slice -String $Line -Start $Column.Start -End $Column.End
							If ($Field -is [String]) {
								$Tail = $Field.TrimStart()
								$Value = $Tail.TrimEnd()
								If (!$Literal -and $Value -gt '') {
									$IsLeftAligned  = $Field.Length - $Tail.Length -eq $Padding
									$IsRightAligned = $Tail.Length - $Value.Length -eq $Padding
									$Alignment = If ($IsLeftAligned -ne $IsRightAligned) {
										 If ($IsLeftAligned) {[Alignment]::Left} Else {[Alignment]::Right}
									} Else {$Column.Alignment}
									If ($Alignment -eq [Alignment]::Right) {
										Try {&([Scriptblock]::Create($Value))}
										Catch {$Value
											Write-Error -ErrorRecord (ErrorRecord -Line $Line -Start $Column.Start -End $Column.End -Message (
												"The expression '{0}' in row {1} at column '{2}' can't be evaluated. Check the syntax or use the -Literal switch." -f $Value, $RowIndex, $Column.Name
											))
										}
									} ElseIf ($Column.Type) {
										Try {&([Scriptblock]::Create("[$($Column.Type)]`$Value"))}
										Catch {$Value
											Write-Error -ErrorRecord (ErrorRecord -Line $Line -Start $Column.Start -End $Column.End -Message (
												"The value '{0}' in row {1} at column '{2}' can't be converted to type {1}." -f $Valuee, $RowIndex, $Column.Name, $Column.Type
											))
										}
									} Else {$Value}
								} Else {$Value}
							} Else {''}
						}
					}
					New-Object PSObject -Property $Property
				}
			}
			If ($DebugPreference -ne 'SilentlyContinue' -and $RowIndex) {Debug-Column}
		}
	}
}

#*------^ ConvertFrom-SourceTable.ps1 ^------

#*------v convert-HelpToMarkdown.ps1 v------
Function convert-HelpToMarkdown {
    <#
    .SYNOPSIS
    convert-HelpToMarkdown.ps1 - Gets the comment-based help and converts to GitHub Flavored Markdown text (for separate output to .md file).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-09-14
    FileName    : convert-HelpToMarkdown.ps1
    License     : MIT License
    Copyright   : Copyright (c) 2014 Akira Sugiura
    Github      : https://github.com/tostka/verb-io
    AddedCredit : Akira Sugiura (urasandesu@gmail.com)
    AddedWebsite:	URL
    AddedTwitter:	URL
    AddedCredit : Gordon Byers (gordon.byers@microsoft.com)
    AddedWebsite:	URL
    AddedTwitter:	URL
    AddedCredit : Jason Marshall (jason@marshall.gg)    
    AddedWebsite:	URL
    AddedTwitter:	URL
    AddedCredit : [AmericanGeezus/convert-HelpToMarkdown.ps1](https://gist.github.com/AmericanGeezus/70fbb85af09ae8cdfef809bcb887d68e)
    AddedWebsite:	URL
    AddedTwitter:	URL
    AddedCredit : [opariffazman/convert-HelpToMarkdown.ps1](https://gist.github.com/opariffazman/aaa59933f6c6fb872c3c4071b197c067)
    AddedWebsite:	URL
    AddedTwitter:	URL
    Tags        : Powershell,Markdown,Input,Conversion,Help
    REVISION
    * 12:42 PM 9/14/2021 forked opariffazman fork of AmericanGeezus fork of Gordonby fork of urasandesu's original 'convert-HelpToMarkdown.ps1' Gist ; 
        ren'd Get-HelpByMarkdown => convert-HelpToMarkdown & added to verb-IO mod ; 
        updated CBH; added clarifying comments; expanded Name param to accept pipeline ; 
        prefixed internal function names with underscor ('_[name]'); 
        captured output into $outMD w explicit write-output (easier to follow through nested herestrings); 
        revised _getCode & _getRemark line splitter, to avoid returning character arrays; 
        added CBH to internal functions.
    * Sep 18, 2019 AmericanGeezus posted rev @https://gist.github.com/opariffazman/aaa59933f6c6fb872c3c4071b197c067/revisions
    .DESCRIPTION
    convert-HelpToMarkdown.ps1 - Gets the comment-based help and converts to GitHub Flavored Markdown text (for separate output to .md file).
    
    Akira Sugiura's original Comments block:
    #  This software is MIT License.
    #  
    #  Permission is hereby granted, free of charge, to any person obtaining a copy
    #  of this software and associated documentation files (the "Software"), to deal
    #  in the Software without restriction, including without limitation the rights
    #  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    #  copies of the Software, and to permit persons to whom the Software is
    #  furnished to do so, subject to the following conditions:
    #  
    #  The above copyright notice and this permission notice shall be included in
    #  all copies or substantial portions of the Software.
    #  
    #  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    #  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    #  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    #  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    #  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    #  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    #  THE SOFTWARE.
    
    .PARAMETER Name
    A command name to get comment-based help
    .INPUTS
    System.String
    .OUTPUTS
    System.String
    .EXAMPLE
    PS> convert-HelpToMarkdown Select-Object > .\Select-Object.md
    This example gets comment-based help of `Select-Object` command, and converts GitHub Flavored Markdown format, then saves it to `Select-Object.md` in current directory.
    .EXAMPLE
    "convertTo-MarkdownTable","get-childitem" |%{ $ofile="$($_).md" ; convert-HelpToMarkdown -Name $_ -verbose > $ofile ; write-host "output:$($ofile)" ;} ; 
    Pipeline example processing an array of commands, with verbose    
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://gist.github.com/tostka/32c33bdf48e4d7d5542b90a6fef09325
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
        HelpMessage="A command name to get comment-based help [-Name 'Select-Object']")]
        $Name
    ) ;

    #*======v FUNCTIONS v======

    #*------v Function _encodePartOfHtml v------
    function _encodePartOfHtml {
        <#
        .SYNOPSIS
        _encodePartOfHtml - Convert < & > to html encodes
        .NOTES
        .DESCRIPTION
        _encodePartOfHtml - Convert < & > to html encodes
        .PARAMETER  Value
        Character to be converted
        .EXAMPLE
        PS> $out = _encodePartOfHtml -value $htmlBlock ;
        #>
        param (
            [string]
            $Value
        ) ; 
        ($Value -replace '<', '&lt;') -replace '>', '&gt;' ; 
    } ; 
    #*------^ END Function _encodePartOfHtml ^------
    #*------v Function _getCode v------
    function _getCode {
        <#
        .SYNOPSIS
        _getCode - Parse Example code blocks
        .NOTES
        .DESCRIPTION
        _getCode - Parse Example code blocks
        .PARAMETER  Example
        Character to be converted
        .EXAMPLE
        PS> $out = $(_getCode $example) ;
        #>
        param (
            $Example
        )  ; 
        # revised to sys agnostic flexible line splitter (avoid char arrays from prior code)
        $codeAndRemarks = ((($Example | Out-String) -replace ($Example.title), '').Trim()).Split( @("`r`n", "`r", "`n"), [StringSplitOptions]::None) |
            foreach-object{$_.Trim()} ; 
        $code = New-Object "System.Collections.Generic.List[string]" ; 
        # if not an array of lines, just add the block (avoid char array output)
        if(-not($codeAndRemarks.GetType().FullName  -eq 'System.String')){
            for ($i = 0; $i -lt $codeAndRemarks.Length; $i++) {
                if ($codeAndRemarks[$i] -eq 'DESCRIPTION' -and $codeAndRemarks[$i + 1] -eq '-----------') {
                     break ; 
                } ; 
                if (1 -le $i -and $i -le 2) {
                    continue ; 
                } ; 
                $code.Add($codeAndRemarks[$i]) ; 
            } ; 
        } else { 
            $code.Add($codeAndRemarks) ; 
        } ; 
        $code -join "`r`n" ; 
    } ; 
    #*------^ END Function _getCode ^------
    #*------v Function _getRemark v------
    function _getRemark {
        <#
        .SYNOPSIS
        _getRemark - Parse Example remark blocks (keys off of use of DESCRIPTION)
        .NOTES
        .DESCRIPTION
        _getRemark - Parse Example remark blocks (keys off of use of DESCRIPTION)
        .PARAMETER  Example
        Character to be converted
        .EXAMPLE
        PS> $out = $(_getRemark $example) ;
        #>
        param (
            $Example
        ) ;
        # revise to sys agnostic flexible line splitter (avoid char arrays from prior code)
        $codeAndRemarks = ((($Example | Out-String) -replace ($Example.title), '').Trim()).Split( @("`r`n", "`r", "`n"), [StringSplitOptions]::None) |
            foreach-object{$_.Trim()} ; 
        $isSkipped = $false ;
        $remark = New-Object "System.Collections.Generic.List[string]" ;
        # if not an array of lines, just add the block (avoid char array output)
        if(-not($codeAndRemarks.GetType().FullName  -eq 'System.String')){
            for ($i = 0; $i -lt $codeAndRemarks.Length; $i++) {
                if (!$isSkipped -and $codeAndRemarks[$i - 2] -ne 'DESCRIPTION' -and $codeAndRemarks[$i - 1] -ne '-----------') {
                    continue ;
                }
                $isSkipped = $true ;
                $remark.Add($codeAndRemarks[$i]) ;
            } ;
        } else { 
            $remark.Add($codeAndRemarks) ;
        } ; 
        $remark -join "`r`n" ; 
    }
    #*------^ END Function _getRemark ^------
    
    #*======^ END FUNCTIONS ^======

    #*======v SUB MAIN v======
    TRY {
        if ($Host.UI.RawUI) {
            $rawUI = $Host.UI.RawUI ; 
            $oldSize = $rawUI.BufferSize  ; 
            $typeName = $oldSize.GetType().FullName; 
            $newSize = New-Object $typeName (500, $oldSize.Height) ; 
            $rawUI.BufferSize = $newSize ; 
        } ; 

        $full = Get-Help $Name -Full ; 
        Write-Verbose $full | ft ; 

        $outMD = @"
# $($full.Name.Split("\")[-1])
## SYNOPSIS
$($full.Synopsis)
## DESCRIPTION
$(($full.description | Out-String).Trim())
# PARAMETERS
`n
"@ + $(foreach ($parameter in $full.parameters.parameter) {
$mandatoryColor = if($parameter.required -eq $True){"Red"}Else{"Green"}
@"
## **-$($parameter.name)**
> ![Foo](https://img.shields.io/badge/Type-$($parameter.type.name)-Blue?) ![Foo](https://img.shields.io/badge/Mandatory-$(($parameter.required).ToUpper())-$mandatoryColor`?) $(if([String]::IsNullOrEmpty($parameter.defaultValue) -eq $false){"![Foo](https://img.shields.io/badge/DefaultValue-$($parameter.defaultValue)-Blue?color=5547a8)\"}else{"\"})
$((($parameter.description).text -replace "\n"," ").Trim())
`n 
"@ ;

        }) + @"
$(if($full.examples.example){
 $(foreach ($example in $full.examples.example) {
@"
#### $(($example.title -replace '-*', '').Trim())
``````powershell
$(_getCode $example)
``````
$(_getRemark $example)
"@
})})
"@ ;

        $outMD | write-output ; 

    } FINALLY {
        if ($Host.UI.RawUI) {
          $rawUI = $Host.UI.RawUI ; 
          $rawUI.BufferSize = $oldSize ; 
        } ; 
    } ; 
    #*======^ END SUB MAIN ^======
}

#*------^ convert-HelpToMarkdown.ps1 ^------

#*------v ConvertTo-HashIndexed.ps1 v------
Function ConvertTo-HashIndexed {
    <#
    .SYNOPSIS
    ConvertTo-HashIndexed.ps1 - Converts the inbound object/array/table into an indexed-hash on the specified key/property.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 12:49 PM 11/17/2020 init using this alot, so port it to a func()
    .DESCRIPTION
    ConvertTo-HashIndexed.ps1 - Converts the inbound object/array/table into an indexed-hash on the specified key/property.
    .PARAMETER  Object
    Object to be converted[-Object `$object]
    .PARAMETER  Key
    Key/property to be indexed upon[-Key 'propertyName]
    .PARAMETER  ShowProgress
    Switch, when ShowProgress in use, as to how many items should process between 'dots' in the crawl[-Every 50]
    .PARAMETER  Every
    ShowProgress dot crawl interval (# of processed objects each dot should represent)[-Every 50]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    .EXAMPLE
    PS> $Key = 'PrimarySmtpAddress' ; 
    PS> $Object = $AllEXOMbxs ; 
    PS> $Output  = ConvertTo-HashIndexed -Key $key -Object $Object -showprogress ;
    PS> $smsg = "ConvertTo-HashIndexed object type Changes:`n" ; 
    PS> $smsg += "original `$Object.type:$( $Object.GetType().FullName )`n" ; 
    PS> $smsg += "converted `$Output .type:$( $Output.GetType().FullName )`n" ; 
    PS> if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }     else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    Convert specified ray/CSV/etc $Object into an indexed hash and demo access, output object types, and converted properties
    .EXAMPLE
    PS> $searchvalue = 'email@domain.com' ; 
    PS> $output[$searchvalue] ;
    Demo lookup objects in the Object
    .EXAMPLE
    PS> $output.'email@domain.com' ;
    Demo alt lookup by property name
    .EXAMPLE
    PS> $output[$lookupVal] | Get-Member ;
    PS> $output.Values | Get-Member ;
    Demo orig object props are still inteact in converted indexed-hashtable
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true,HelpMessage="Object to be converted[-Object `$object]")]
        [ValidateNotNullorEmpty()]$Object,
        [Parameter(Mandatory=$true,HelpMessage="Key/property to be indexed upon[-Key 'propertyName]")]
        [ValidateNotNullorEmpty()]$Key,
        [Parameter(Mandatory=$false,HelpMessage="Switch to display dot-crawl progress[-ShowProgress 'propertyName]")]
        [switch]$ShowProgress,
        [Parameter(Mandatory=$false,HelpMessage="ShowProgress dot crawl interval (# of processed objects each dot should represent)[-Every 50]")]
        [int]$Every = 100  
    ) ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    $ttl = ($Object|measure).count ; 
    $smsg = "(converting $($ttl) items into indexed hash)..." ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    $sw = [Diagnostics.Stopwatch]::StartNew();
    $Hashtable = @{}
    $Procd = 0 ; 
    if($ShowProgress){write-host -NoNewline "`n[" ; $Procd = 0 } ; 
    Foreach ($Item in $Object){
        $Procd++ ; 
        $Hashtable[$Item.$Key.ToString()] = $Item ; 
        if($ShowProgress -AND ($Procd -eq $Every)){
            write-host -NoNewline '.' ; $Procd = 0 
        } ; 
    } ; 
    if($ShowProgress){write-host "]`n" ; $Procd = 0 } ; 
    $sw.Stop() ;
    $smsg = "($($ttl) items converted in $($sw.Elapsed.ToString()))" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    $Hashtable | write-output ; 
}

#*------^ ConvertTo-HashIndexed.ps1 ^------

#*------v convertto-MarkdownTable.ps1 v------
Function convertTo-MarkdownTable {
    <#
    .SYNOPSIS
    convertTo-MarkdownTable.ps1 - Converts a PowerShell object to a Markdown table.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-01-20
    FileName    : convertTo-MarkdownTable.ps1
    License     : (none specified, original source github site deleted)
    Copyright   : (none specified, original source github site deleted)
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Markdown,Output
    AddedCredit : alexandrm
    AddedWebsite: https://mac-blog.org.ua/powershell-convertto-markdown/
    AddedTwitter: https://twitter.com/alexandrm
    AddedCredit : Matticusau
    AddedWebsite: https://gist.github.com/Matticusau/49943eb19efd54783966449bde53e9db
    AddedTwitter: URL
    AddedCredit : GuruAnt
    AddedWebsite: https://gist.github.com/GuruAnt/4c837213d0f313715a93
    AddedTwitter: URL
    REVISION
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 4:04 PM 9/16/2021 coded around legacy code issue, when using [ordered] hash - need it or it randomizes column positions. Also added -NoDashRow param (breaks md rendering, but useful if using this to dump delimited output to console, for readability)
    * 10:51 AM 6/22/2021 added convertfrom-mdt alias
    * 4:49 PM 6/21/2021 pretest $thing.value: suppress errors when $thing.value is $null (avoids:'You cannot call a method on a null-valued expression' trying to eval it's null value len).
    * 10:49 AM 2/18/2021 added default alias: out-markdowntable & out-mdt
    8:29 AM 1/20/2021 - ren'd convertto-Markdown -> convertTo-MarkdownTable (avoid conflict with PSScriptTools cmdlet, also more descriptive as this *soley* produces md tables from objects; spliced in -Title -PreContent -PostContent params ; added detect & flip hashtables to cobj: gets them through, but end up in ft -a layout ; updated CBH, added -Border & -Tight params, integrated *some* of forked fixes by Matticusau: A couple of aliases changed to full cmdlet name for best practices;Extra Example for how I use this with PSScriptAnalyzer;
    unknown - alexandrm's revision (undated)
    unknown - Guruant's source version (undated account deleted on github)
    .DESCRIPTION
    convertTo-MarkdownTable.ps1 - Converts a PowerShell object to a Markdown table.
    .PARAMETER collection
    Powershell object to be converted to md table text output
    .PARAMETER Border
    Switch to generate L & R outter border on output [-Border]
    .PARAMETER Tight
    Switch to drop additional whitespace around border/column-delimiters [-Tight]
    .PARAMETER NoDashRow
    Switch to drop the Header-seperator row (Note:This breaks proper markdown-rendering-syntax, but useful for non-markdown use to create a tighter vertical output) [-NoDashRow]
    .PARAMETER Title
    String to be tagged as H1 [-Title 'title text']
    .PARAMETER PreContent
    String to be added above returned md table [-PreContent 'Preface']
    .PARAMETER PostContent
    String to be added below returned md table [-PostContent 'Preface']
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    String
    .EXAMPLE
    $data | convertTo-MarkdownTable ;
    .EXAMPLE
    convertTo-MarkdownTable($data) ;
    .EXAMPLE
    PS> Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable ;
        Status  | Name  | DisplayName
        ------- | ----- | -----------------------------------------
        Running | Bits  | Background Intelligent Transfer Service
        Running | Winrm | Windows Remote Management (WS-Management)
    Demo of stock use, with a select to spec properties (this cmdlet doesn't observer cmdlet default properties for display, must be manually selected)
    .EXAMPLE
    PS> Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable -border ; 
        | Status  | Name  | DisplayName                               |
        | ------- | ----- | ----------------------------------------- |
        | Running | Bits  | Background Intelligent Transfer Service   |
        | Running | Winrm | Windows Remote Management (WS-Management) |
    Demo effect of the -Border param.
    .EXAMPLE
    PS> Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable -tight ;
        Status |Name |DisplayName
        -------|-----|-----------------------------------------
        Running|Bits |Background Intelligent Transfer Service
        Running|Winrm|Windows Remote Management (WS-Management)
    Demo effect of the -Tight param.
    .EXAMPLE
    PS> Invoke-ScriptAnalyzer -Path C:\MyScript.ps1 | select RuleName,Line,Severity,Message |
        ConvertTo-Markdown | Out-File C:\MyScript.ps1.md ; 
    Converts output of PSScriptAnalyzer to a Markdown report file using selected properties
    .EXAMPLE
    PS> Get-Service Bits,Winrm | select status,name,displayname | 
        Convertto-Markdowntable -Title 'This is Title' -PreContent 'A little something *before*' -PostContent 'A little something *after*' ; 
    Demo use of -title, -precontent & -postcontent params:
    .EXAMPLE
    PS> $pltcMT=[ordered]@{
            Title='This is Title' ;
            PreContent='A little something *before*' ;
            PostContent='A little something *after*'
        } ;
    PS> Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable @pltcMT ; 
    Same as prior example, but leveraging more readable splatting
    .EXAMPLE
    PS> Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable -NoDashRow
        Status  | Name  | DisplayName                              
        Stopped | Bits  | Background Intelligent Transfer Service  
        Running | Winrm | Windows Remote Management (WS-Management)
    Demo effect of -NoDashRow param (drops header-seperator line)
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('out-markdowntable','out-mdt','convertfrom-mdt')]
    [OutputType([string])]
    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PSObject[]]$Collection,
        [Parameter(HelpMessage="Switch to generate L & R outter border on output [-Border]")]
        [switch] $Border,
        [Parameter(HelpMessage="Switch to drop additional whitespace around border/column-delimiters [-Tight]")]
        [switch] $Tight,
        [Parameter(HelpMessage="Switch to drop the Header-seperator row (Note:This breaks proper markdown-rendering-syntax, but useful for non-markdown use to create a tighter vertical output) [-NoDashRow]")]
        [switch] $NoDashRow,
        [Parameter(HelpMessage="String to be tagged as H1 [-Title 'title text']")]
        [string] $Title,
        [Parameter(HelpMessage="String to be added above returned md table [-PreContent 'Preface']")]
        [string[]] $PreContent,
        [Parameter(HelpMessage="String to be added below returned md table [-PostContent 'Preface']")]
        [string[]] $PostContent
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
        $items = @() ;
        $columns = [ordered]@{} ; 
        $output = @"

"@
        $Delimiter = ' | '
        $BorderLeft = '| '; 
        $BorderRight = ' |'; 
        if($Tight){
            $Delimiter = $Delimiter.replace(' ','') ;
            $BorderLeft = $BorderLeft.replace(' ','') ; 
            $BorderRight = $BorderRight.replace(' ','') ; 
        } ; 
        If ($title) {
            Write-Verbose "Adding Title: $Title"
            $output += "`n# $Title`n`n"
        }
        If ($precontent) {
            Write-Verbose "Adding Precontent"
            $output += $precontent + "`n`n" ; 
        }
    } ;
    PROCESS {
        ForEach($item in $collection) {
            switch($item.GetType().FullName){
                "System.Collections.Hashtable" {
                    # convert inbound hashtable to a cobj
                    # effectively ft -a's the key:values - not optimal, but at least it gets them through. 
                    $item  = [pscustomobject]$item
                }
                default {} ; 
            } ;
            $items += $item ;
            # simpler solution for $null values: (I also like explicit foreach over foreach-object)
            foreach($thing in $item.PSObject.Properties){
                #write-verbose "$($thing|out-string)" ; 
                # suppress errors when $thing.value is $null (avoids:'You cannot call a method on a null-valued expression' trying to eval it's null value len).
                if($thing.Value){$valuLen =  $thing.Value.ToString().Length }
                else {$valuLen = 0 } ;
                #if(-not $columns.ContainsKey($thing.Name) -or $columns[$thing.Name] -lt $valuLen) {
                # variant [ordered] hash syntax:
                if(-not($columns.keys -Contains $thing.Name) -or $columns[$thing.Name] -lt $valuLen) {
                    if ($null -ne $thing.Value) {
                        $columns[$thing.Name] = $thing.Value.ToString().Length
                    } else {
                        $columns[$thing.Name] = 0 ; # null's 0-length, so use it. 
                    } ; 
                } ;
            } ;  # loop-E

        } ;
    } ;  # PROC-E
    END {
        ForEach($key in $($columns.Keys)) {
            $columns[$key] = [Math]::Max($columns[$key], $key.Length) ;
        } ;
        $header = @() ;
        ForEach($key in $columns.Keys) {
            $header += ('{0,-' + $columns[$key] + '}') -f $key ;
        } ;
        if(!$Border){
            $output += ($header -join $Delimiter) + "`n" ; 
        }else{
            $output += $BorderLeft + ($header -join $Delimiter) + $BorderRight + "`n" ; 
        } ;
        $separator = @() ;
        ForEach($key in $columns.Keys) {
            $separator += '-' * $columns[$key] ;
        } ;
        if($NoDashRow){
            write-verbose "(skipping Header-separator row - violates md syntax!)" ; 
        } else { 
            if (!$Border) { 
                $output += ($separator -join $Delimiter) + "`n" ; 
            }
            else{
                $output += $BorderLeft + ($separator -join $Delimiter) + $BorderRight + "`n" ; 
            } ;
        } ; 
        ForEach($item in $items) {
            $values = @() ;
            ForEach($key in $columns.Keys) {
                $values += ('{0,-' + $columns[$key] + '}') -f $item.($key) ;
            } ;
            if (!$Border) { 
                $output += ($values -join $Delimiter) + "`n" ; 
            }else{
                $output += $BorderLeft + ($values -join $Delimiter ) + $BorderRight + "`n" ; 
            } ;
        } ;
        If ($postcontent) {
            Write-Verbose "Adding postcontent"
            $output += "`n"
            $output += $postcontent
            $output += "`n" ; 
        }
        $output | write-output ; 

    } ; # END-E
}

#*------^ convertto-MarkdownTable.ps1 ^------

#*------v convertTo-Object.ps1 v------
Function convertTo-Object {

    <#
    .SYNOPSIS
    convertTo-Object.ps1 - Pipeline filter that converts a stream of hashtables into an object, note not 3 nested objects in the Cobj, one Cobj with the single list of properties.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : convertTo-Object.ps1
    License     : (none-asserted)
    Copyright   : (none-asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Hashtable,PSCustomObject,Conversion
    AddedCredit : https://community.idera.com/members/tobias-weltner
    AddedWebsite:	https://community.idera.com/members/tobias-weltner
    AddedTwitter:	URL
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 12:26 PM 10/17/2021 init vers
    * 11/17/2008 Tobias Weltner's thread post. 
    .DESCRIPTION
    convertTo-Object.ps1 - Pipeline filter that converts a stream of hashtables into an object, note not 3 nested objects in the Cobj, one Cobj with the single list of properties.
    .PARAMETER hashtable
    String representation of an integer size and unit in 'KiB|MiB|GiB|TiB|PiB' [-value '1.39 GiB']
    .OUTPUT
    System.Object
    .EXAMPLE
    PS> $hash1 = @{name='Melzer';firstname='Tim';age=68} ;
    PS> $hash2 = @{id=12;count=100;remark='Second Hash Table'} ;
    PS> $cobj = $hash1, $hash2 | ConvertTo-Object ;  
    Combine hash1 & 2 into cobj customobject.  
    .LINK
    https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/converting-hash-tables-to-objects
    .LINK
    https://github.com/tostka/verb-IO
    #>

    #[Alias('convert-
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Hasthtable(s) to be converted into a single object[-hashtable `$hash]")]
        [string]$hashtable        
    )
    BEGIN { $object = New-Object Object } ; 
    PROCESS {
        $_.GetEnumerator() | ForEach-Object { Add-Member -inputObject $object -memberType NoteProperty -name $_.Name -value $_.Value }   ; 
    } ; 
    END { $object } ; 
}

#*------^ convertTo-Object.ps1 ^------

#*------v ConvertTo-SRT.ps1 v------
function ConvertTo-SRT {
    <#
    .SYNOPSIS
    ConvertTo-SRT.ps1 - Fast conversion of Microsoft Stream VTT subtitle file to SRT format.
    .NOTES
    Version     : 1.0.0
    Author      : joegasper
    Website     :	https://gist.github.com/joegasper/3fafa5750261d96d5e6edf112414ae18
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-12-15
    FileName    : 
    License     : (not specified)
    Copyright   : (not specified)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,ActiveDirectory,DistinguishedName,CanonicalName,Conversion
    AddedCredit : Todd Kadrie
    AddedWebsite:	http://www.toddomation.com
    AddedTwitter:	@tostka / http://twitter.com/tostka
    Inspiration from: https://gist.github.com/brianonn/455bce106bd86c9587d223acfbbe9751/
Takes a 3.5 minute process for 17K row VTT to 3.5 seconds

https://github.com/joegasper
https://gist.github.com/joegasper/e862f71b5a2658fae21fd36f7231b33c
    REVISIONS
    * 4:30 PM 12/15/2020 TSK: expanded CBH, 
    .DESCRIPTION
    Uses select-string instead of get-content to improve speed 2 magnitudes.
    .PARAMETER Path
    Specifies the path to the VTT text file (mandatory).
    .PARAMETER OutFile
    Specifies the path to the output SRT text file (defaults to input file with .srt).
    .EXAMPLE
    ConvertTo-SRT -Path .\caption.vtt
    .EXAMPLE
    ConvertTo-SRT -Path .\caption.vtt -OutFile .\SRT\caption.srt
    .EXAMPLE
    Get-Item caption*.vtt | ConvertTo-SRT
    .EXAMPLE
    ConvertTo-SRT -Path ('.\caption.vtt','.\caption.vtt','.\caption3.vtt')
    .EXAMPLE
    ('.\caption.vtt','.\caption2.vtt','.\caption3.vtt') | ConvertTo-SRT
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to VTT file.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [Object[]]$Path,

        [Parameter(Mandatory = $false,
            Position = 1,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to output SRT file.")]
        [string]$OutFile
    )

    process {
        foreach ($File in $Path) {
            $Lines = @()
            if ( $File.FullName ) {
                $VTTFile = $File.FullName
            }
            else {
                $VTTFile = $File
            }

            if ( -not($PSBoundParameters.ContainsKey('OutFile')) ) {
                $OutFile = $VTTFile -replace '(\.vtt$|\.txt$)', '.srt'
                if ( $OutFile.split('.')[-1] -ne 'srt' ) {
                    $OutFile = $OutFile + '.srt'
                }
            }

            New-Item -Path $OutFile -ItemType File -Force | Out-Null
            $Subtitles = Select-String -Path $VTTFile -Pattern '(^|\s)(\d\d):(\d\d):(\d\d)\.(\d{1,3})' -Context 0, 2

            for ($i = 0; $i -lt $Subtitles.count; $i++) {
                $Lines += $i + 1
                $Lines += $Subtitles[$i].line -replace '\.', ','
                $Lines += $Subtitles[$i].Context.DisplayPostContext
                $Lines += ''
            }

            $Lines | Out-File -FilePath $OutFile -Append -Force
        }
    }
}

#*------^ ConvertTo-SRT.ps1 ^------

#*------v convert-VideoToMp3.ps1 v------
function convert-VideoToMp3 {
    <#
    .SYNOPSIS
    convert-VideoToMp3() - convert passed video files to mp3 files in same directory
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    # 5:26 PM 10/5/2021 ren, and alias orig: convert-tomp3 -> convert-VideoToMp3 (added alias:convertto-mp3); also build into freestanding function in verb-IO
    # 12:02 PM 4/1/2017 convert-ToMp3: if it's a string, it's not going to have a fullname prop - it's a full path string
    # 7:03 PM 11/8/2016 code in exception for directory objects, ren the new instead of the original, add -ea 0 to suppress $cf test not found failures, finding that renames fail if there's an existing fn clash -> ren the clash
    * 7:01 PM 11/7/2016 set the $serrf & $soutf to -showdebug only,
    * 7:38 PM 11/6/2016 swap all uses of $inputfile => $tf, replc \ => \\ (parsing bug in vlc, when quotes & dlquotes are comboed)
    * 4:50 PM 11/6/2016 - essentially functional, but still requires a foreach outside of function/script to get through collections/arrays.
        put in inbound object type checking, as fso's have to use fullname, while strings, use base string as a path
        Also renamed convert-VLCWavToMp3.ps1 into convert-ToMp3.ps1
    * 11:44 PM 11/5/2016 - initial pass
    .DESCRIPTION
    convert-VideoToMp3() - convert passed video files to mp3 files in same directory
    .PARAMETER  InputObject
    Name or IP address of the target computer
    .PARAMETER Bitrate
    Bitrate for transcoded output (defaults to 320k)
    .PARAMETER samplerate
    Samplerate for transcoded output (defaults to 44100)
    .PARAMETER encoder
    Encoder choice [f|vlc (default)]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass, and log results [-Whatif switch]
    .PARAMETER ShowProgress
    Parameter to display progress meter [-ShowProgress switch]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns an object with uptime data to the pipeline.
    .EXAMPLE
    $bRet=convert-VideoToMp3 -InputObject "C:\video.mkv" ;
    Convert Specified video file to mp3.
    #>
    [CmdletBinding()]
    [Aliases('convert-ToMp3','convert-VideoToMp3')]
    PARAM (
        [parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, Mandatory = $True, HelpMessage = "File(s) to be transcoded")]
        $InputObject
        , [parameter(HelpMessage = "Bitrate for transcoded output (defaults to 320k)")]
        [int]$bitrate = 320
        , [parameter(HelpMessage = "Samplerate for transcoded output (defaults to 44100)")]
        [int]$samplerate = 44100
        , [Parameter(Mandatory = $false, HelpMessage = "Specify Site to analyze [-SiteName (USEA|GBMK|AUSYD]")]
        [ValidateSet("F", "VLC")]
        [string]$encoder = "VLC"
        , [Parameter(HelpMessage = 'ShowProgress [$switch]')]
        [switch] $showProgress
        , [Parameter(HelpMessage = 'Debugging Flag [$switch]')]
        [switch] $showDebug
        , [Parameter(HelpMessage = 'Whatif Flag  [$switch]')]
        [switch] $whatIf
    ) ; # PARAM-E

    <# input formats supported by VLC
        MPEG (ES,PS,TS,PVA,MP3), AVI, ASF |WMV |WMA, MP4 |MOV |3GP, OGG |OGM |Annodex, Matroska (MKV), Real, WAV (including DTS), Raw Audio: DTS, AAC, AC3/A52, Raw DV, FLAC, FLV (Flash), MXF, Nut, Standard MIDI |SMF, Creative™ Voice.
    #>

    BEGIN {
        $rgxInputExts = "(?i:^\.(MPEG|MP3|AVI|ASF|WMV|WMA|MP4|MOV|3GP|OGG|OGM|MKV|WEBM|WAV|DTS|AAC|AC3|A52|FLAC|FLV|MXF|MIDI|SMF)$)" ;
        $outputExtension = ".mp3" ;
        $audio_codec = "mp3" ;
        #"mpga"
        $channels = 2 ;
        $mux = "dummy" ; # for mp3 audio-only extracts, use the dummy mux
        #"mpeg1"
        $progInterval = 500 ; # write-progress interval in ms
        $iProcd = 0 ;
        $continue = $true ;
        $programFiles = ${env:ProgramFiles(x86)};
        if ($programFiles -eq $null) { $programFiles = $env:ProgramFiles; } ;
        switch ($encoder) {
            "VLC" { $processName = $programFiles + "\VideoLAN\VLC\vlc.exe" ; }
            "FFMPEG" { $processName = "C:\apps\ffmpeg\bin\ffmpeg.exe" }
        } ;
        if (!(test-path -path $processName)) { throw "MISSING/INVALID $($encoder) install path!:$($processName)" } ;
        write-verbose -verbose:$true  "$((get-date).ToString("HH:mm:ss")):=== v PROCESSING STARTED v ===" ;
        $progParam = @{
            CurrentOperation = "Beginning";
            Status           = "Preparing Processing...";
            PercentComplete  = 0;
        } ;
    }  # BEG-E ;

    PROCESS {

        $ttl = ($InputObject | measure).count ;
        $iProcd = 0 ; $swp = [System.Diagnostics.Stopwatch]::StartNew() ;

        # foreach, to accommodate arrays passed in
        foreach ($inputFile in $InputObject) {

            $continue = $true ;
            try {

                if ($inputfile.GetType().fullname -ne "System.IO.DirectoryInfo") {
                    switch ($inputfile.GetType().fullname) {
                        "System.IO.FileInfo" {
                            if ($tf = Get-childitem -path $inputFile.fullname -ea Stop) {
                            }
                            else {
                                write-host -ForegroundColor red "Unable to read infile: $($inputFile.fullname)" ;
                                throw "MISSING/INVALID inputfile:$($inputFile.fullname)"
                            } ;
                        } ;
                        "System.String" {
                            # 12:02 PM 4/1/2017 if it's a string, it's not going to have a fullname prop - it's a full path string
                            if ($tf = Get-childitem -path $inputFile) {

                            }
                            else {
                                write-host -ForegroundColor red "Unable to read infile: $($inputFile.fullname)" ;
                                throw "MISSING/INVALID inputfile:$($inputFile.fullname)"
                            } ;
                        };
                        default {
                            write-host -ForegroundColor red "Unable to read infile: $($inputFile.fullname)" ;
                            "inputfile.GetType().fullname:$($inputfile.GetType().fullname)" ;
                            throw "UNRECOGNIZED TYPE OBJECT inputfile:$($inputFile.fullname). ABORTING!" ;
                        } ;
                    } ;

                    if ($tf.extension -notmatch $rgxInputExts ) { throw "UNSUPPORTED INPUTFILE TYPE:$($inpuptFile)" }  ;

                    <# 7:20 PM 11/6/2016 windows docs:https://wiki.videolan.org/Transcode/
                    Note: due to command line parsing, at times, especially within single and double quote blocks, a backslash may have to be
                    escaped by using a double backslash so that a filename would be D:\\path\\to\\file.mpg)
                    Dbling \'s in all path objects used in params going into vlc.exe args and see if it fixes the issues transcodeing:
                    C:\vidtmp\OST\Steps of the Rover\Gun Thing (The Proposition) - Nick Cave, Warren Ellis-(UL20111001-MieT8cNeXJA).mp3
                    ... which comes out as an mp3 with no extension.
                    #>
                    $outputFileName = (join-path -path $tf.Directory -ChildPath "$($tf.BaseName)$($outputExtension)") ;
                    #$outputFileName=$outputFileName.replace("\","\\") ;
                    # since there's clearly an export bug in VLC, lets use a generic no-spaces file :
                    # Generate a unique filename with a specific extension (non-tmp, leverages the GUID-generating call):
                    $tempout = (join-path -path $tf.Directory -ChildPath "$([guid]::NewGuid().tostring())$($outputExtension)").replace("\", "\\")  ;
                    $inputFileName = $tf.FullName.replace("\", "\\") ;

                    if ($showDebug) { write-verbose -verbose:$true  "`$outputFileName:$outputFileName`n`$tempout:$($tempout)" } ;

                    switch ($encoder) {
                        "VLC" {
                            #  12:11 PM 11/6/2016 build args where we can see whats going on
                            # 1st spec dummy/non-GUI pass, and input filename  $($inputFileName)
                            $processArgs = "-I dummy -v `"$($inputFileName)`"" ;
                            if ($whatif) {
                                write-verbose -verbose:$true  "-whatif detected, test-transcoding only the first 30secs" ;
                                $processArgs += " --stop-time=30" ;
                            } ;
                            # build output transcode settings
                            $processArgs += " :sout=#transcode{" ;
                            $processArgs += "vcodec=none,acodec=$($audio_codec),ab=$($bitrate),channels=$($channels),samplerate=$($samplerate)" ;
                            $processArgs += "acodec=$($audio_codec),ab=$($bitrate),channels=$($channels),samplerate=$($samplerate)" ;
                            # end output transcode settings
                            $processArgs += "}" ;
                            # add the output file specs & mux
                            $processArgs += ":standard{access=`"file`",mux=$($mux),dst=`"$($tempout)`"}"
                            # tell it to exit on completion
                            $processArgs += " vlc://quit" ;
                        }
                        "FFMPEG" {
                            <# C:\apps\ffmpeg\bin\ffmpeg.exe
                            The basic command is:
                            ffmpeg -i filename.mp4 filename.mp3
                            or
                            ffmpeg -i video.mp4 -b:a 192K -vn music.mp3

                            use -q:a for variable bit rate.
                            ffmpeg -i k.mp4 -q:a 0 -map a k.mp3
                            The q option can only be used with libmp3lame and corresponds to the LAME -V option. See:

                            leaving out -vn just copies the audio stream
                            to convert whole directory (including filenames with spaces) with the above command:
                            for i in *.mp4; do ffmpeg -i "$i" -q:a 0 -map a "$(basename "${i/.mp4}").mp3"; done;
                            http://donnieknows.com/blog/mp4-video-mp3-file-using-ffmpeg-ubuntu-910-karmic-koala
                            Encoding VBR (Variable Bit Rate) mp3 audio - https://trac.ffmpeg.org/wiki/Encode/MP3
                            FFmpeg, encode mp3 - http://svnpenn.github.io/2012/08/ffmpeg-encode-mp3

                            To encode a high quality MP3 from an AVI best using -q:a for variable bit rate.
                            ffmpeg -i sample.avi -q:a 0 -map a sample.mp3
                            If you want to extract a portion of audio from a video use the -ss option to specify the starting timestamp, and the -t option to specify the encoding duration, eg from 3 minutes and 5 seconds in for 45 seconds
                            ffmpeg -i sample.avi -ss 00:03:05 -t 00:00:45.0 -q:a 0 -map a sample.mp3
                                The timestamps need to be in HH:MM:SS.xxx format or in seconds.
                                If you don't specify the -t option it will go to the end.
                            ffmpeg -formats
                            or
                            ffmpeg -codecs
                            would give sufficient information so that you know more

                            128 kbps audio (assuming the original video file had good audio!) sampled at the 44,100 sample/second rate used on a CD:
                            ffmpeg -i moviefile.mpeg -ab 128000 -ar 44100 -f mp3 audiofile.mp3
                            #>
                            $processArgs = "-i `"$($inputFileName)`"" ;
                            # $bitrate=320
                            $processArgs += " -ab $($bitrate * 1000)" ;
                            # $samplerate=44100
                            $processArgs += " -ar $($samplerate)" ;
                            $processArgs += " -f mp3" ;
                            $processArgs += " `"$($tempout)`"" ;
                        }
                    } ;

                    if ($showDebug) {
                        write-verbose -verbose:$true  "`$processName:$($processName | out-string)" ;
                        write-verbose -verbose:$true  "`$processArgs:$($processArgs | out-string)" ;
                        # optional debug: pipe it into the clipboard for cmdline testing
                        #"`"$($processName)`" $($processArgs)" | Out-Clipboard ;
                        #write-verbose -verbose:$true  "current cmdline piped to Clipboard!" ;
                    } ;
                    # launch command
                    # capture and echo back errors from robocopy.exe
                    $soutf = [System.IO.Path]::GetTempFileName() ;
                    $serrf = [System.IO.Path]::GetTempFileName()  ;
                    "Cmd:$($processName) $($processArgs)" ;
                    $process = Start-Process -FilePath $processName -ArgumentList $processArgs -NoNewWindow -PassThru -Wait -RedirectStandardOutput $soutf -RedirectStandardError $serrf ;

                    switch ($process.ExitCode) {
                        0 {
                            "ExitCode 0 returned (No Errors, File converted)"
                            # ren $tempout => $outputFileName
                            if ($rf = get-childitem -path $tempout ) {
                                # renames fail if there's an existing fn clash -> ren the clash, -ea 0 to suppress notfound errors
                                if ($cf = get-childitem -path ($outputFileName | split-path -Leaf) -ea 0 ) {
                                    Rename-Item -path $rf.fullname -NewName "$($cf.BaseName)-$((get-date).tostring('yyyyMMdd-HHmmtt'))$($cf.Extension)" ;
                                }
                                else {
                                    Rename-Item -path $rf.fullname -NewName $($outputFileName | split-path -Leaf)
                                };
                            }
                            else {
                                throw "No matching temporary output file found: $($tmpout)" ;
                            } ;
                        } ;
                        1 { "ExitCode 1 returned (fatal error)" } ;
                        default { write-host "ERROR during VLC Transcoding: Non-0/1 ExitCode returned $($process.ExitCode)" ; write-host "`a" ; } ;
                    } ;

                    if ((get-childitem $soutf).length) {
                        if ($ShowDebug) { (gc $soutf) | out-string ; } ;
                        remove-item $soutf ;
                    } ;
                    if ((get-childitem $serrf).length) {
                        if ($ShowDebug) { (gc $serrf) | out-string ; } ;
                        remove-item $serrf ;
                    } ;

                    $iProcd++ ;
                    [int]$pct = ($iProcd / $ttl) * 100 ;

                    <# SAMPLE TRANSCODE SETTINGS
                    -I dummy      Disables the graphical interface
                    vlc://quit     Quit VLC after transcoding

                    # wav to mp3
                    #$processArgs = "-I dummy -vvv `"$($inputFileName)`" --sout=#transcode{acodec=`"mp3`",ab=`"$bitrate`",`"channels=$channels`"}:standard{access=`"file`",mux=`"wav`",dst=`"$outputFileName`"} vlc://quit" ;
                    # mp4 to mp3
                    #$processArgs = "-I dummy -vvv `"$($inputFileName)`" --sout=#transcode{acodec=`"$audio_codec`",ab=`"$bitrate`",`"channels=$channels`",`"samplerate=$samplerate`"}:standard{access=`"file`",mux=`"$mux`",dst=`"$outputFileName`"} vlc://quit" ;

                    # dvd to mp3
                    # --qt-start-minimized dvd:///E:\@!Title!:%%C :sout=#transcode{vcodec=none,acodec=mp3,ab=320,channels=2,samplerate=44100}:standard{access="file",mux=dummy,dst="!CD!\!TargetFolder!\!FileNumber!.mp3"} vlc://quit

                    # flv to mp3
                    # -I dummy -v %1 :sout=#transcode{vcodec=none,acodec=mp3,ab=128,channels=2,samplerate=44100}:standard{access="file",mux=dummy,dst="%_commanm%.mp3"} vlc://quit

                    # MOV_to_MPG
                    -I dummy -vvv %1
                    --sout=#transcode{vcodec=h264,vb=10000,deinterlace=1,acodec=mp3,ab=128,channels=2,samplerate=44100}:standard{access=file,mux=ts,dst=%_new_path%} vlc://quit
                    --stop-time=30 to only encode the first 30 seconds (quick test)

                    # generic syntax:
                    -I dummy -vvv %%a --sout=#transcode{vcodec=VIDEO_CODEC,vb=VIDEO_BITRATE,scale=1,acodec=AUDIO_CODEC,ab=AUDIO_BITRATE,channels=6}:standard{access=file,mux=MUXER,dst=%%a.OUTPUT_EXT} vlc://quit

                    # audio-only options:
                    --no-sout-video     VLC will not pass on a video component to the streaming output
                    --sout-audio     VLC will, however, pass on an audio component to the streaming output

                    # Extracting audio in original format
                    --no-sout-video dvdsimple:///dev/scd0@1:1 :sout='#std{access=file,mux=raw,dst=./file.ac3}'
                    # Extracting audio in FLAC format
                    -I dummy --no-sout-video --sout-audio
                    --no-sout-rtp-sap --no-sout-standard-sap --ttl=1 --sout-keep
                    --sout "#transcode{acodec=flac}:std{mux=raw,dst=C:\User\Admin\Desktop\yourAudio.flac}"
                    Video.TS:///C:\User\Admin\Desktop\yourVideo.mp4\#0:01-3:38 vlc://quit
                    # Extracting audio in WAV format
                    -I dummy --no-sout-video --sout-audio
                    --no-sout-rtp-sap --no-sout-standard-sap --ttl=1 --sout-keep
                    --sout "#transcode{acodec=s16l,channels=2}:std{access=file,mux=wav,dst=C:\User\Admin\Desktop\yourAudio.wav}"
                    Video.TS:///C:\User\Admin\Desktop\yourVideo.mp4\#0:01-3:38 vlc://quit
                    # acodec=s16l tells VLC to use convert the audio content using the s16l codec, which is the codec for WAV format audio
                    # mux=wav tells VLC to write the s16l audio data into a file with the WAV structure.

                    # changes an asf file to an MPEG-2 file
                    vlc "C:\Movies\Your File.asf" :sout='#transcode{vcodec=mp2v,vb=4096,acodec=mp2a,ab=192,scale=1,channels=2,deinterlace,audio-sync}:std{access=file, mux=ps,dst="C:\Movies\Your File Output.ps.mpg"}'

                    # m4a files to mp3 files (512kb/s encoding with 44100 sampling frequency
                    -I dummy -vvv %1
                    --sout=#transcode{acodec="mpga",ab="512","channels=2",samplerate="44100"}:standard{access="file",mux="mpeg1",dst="%_commanm%.mp3"} vlc://quit

                    # transcode wav to mp3
                    -I dummy -vvv `"$($inputFileName)`"
                    --sout=#transcode{acodec=`"mp3`",ab=`"$bitrate`",`"channels=$channels`"}:standard{access=`"file`",mux=`"wav`",dst=`"$outputFileName`"} vlc://quit
                    #>

                }
                else {
                    # code leak to throw out directories
                    # System.IO.DirectoryInfo
                    "(Skipping $($inputfile) -- Directory)" ;
                } ;

            }
            catch {
                # BOILERPLATE ERROR-TRAP
                Write "$((get-date).ToString("HH:mm:ss") ): -- SCRIPT PROCESSING CANCELLED" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Error in $($_.InvocationInfo.ScriptName)." ;
                Write "$((get-date).ToString("HH:mm:ss") ): -- Error information" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Line Number: $($_.InvocationInfo.ScriptLineNumber)" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Offset: $($_.InvocationInfo.OffsetInLine)" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Command: $($_.InvocationInfo.MyCommand)" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Line: $($_.InvocationInfo.Line)" ;
                Write "$((get-date).ToString("HH:mm:ss") ): Error Details: $($_)" ;
                Continue ;
                # Exit; here if you want processing to die and not continue on next for-pass
            } # try/cat-E ;

        } #  # loop-E ;
    } # PROC-E ;

    END {
        write-verbose -verbose:$true  "$((get-date).ToString("HH:mm:ss")):$($iProcd) conversions processed" ;
        write-verbose -verbose:$true  "$((get-date).ToString("HH:mm:ss")):=== ^ PROCESSING COMPLETE ^ ===" ;

    } # END-E
}

#*------^ convert-VideoToMp3.ps1 ^------

#*------v copy-Profile.ps1 v------
function copy-Profile {
    <#
    .SYNOPSIS
    copy-Profile() - Copies $SourceProfileMachine WindowsPowershell profile dir to the specified machine(s)
    .NOTES
    Author: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 9:47 AM 9/24/2020 updated CBH, copied to verb-IO mod; added -MinProfile to drive admin/svcacct copying 
    * 10:41 AM 3/26/2020 rewrote, added verbose support, condensed 
    8:07 AM 6/12/2015 - functionalize copy code from the EMS block
    .DESCRIPTION
    copy-Profile() - Copies $SourceProfileMachine WindowsPowershell profile dir to the specified machine(s)
    .PARAMETER  ComputerName
    Name or IP address of the target computer
    .PARAMETER SourceProfileMachine
    Source Name or IP address of the source Profile computer
    .PARAMETER TargetProfile
    Target Account for Profile copy process [domain\logon]
    .PARAMETER showProgress
    Show Progress bar reflecting progress toward completion
    .PARAMETER showDebug
    Show Debugging messages
    .PARAMETER whatIf
    Execute solely a test pass
    .PARAMETER Credential
    Credential object for use in accessing the computers.
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns an object with uptime data to the pipeline.
    .EXAMPLE
    PS> $Exs=(get-exchangeserver | ?{(($_.IsMailboxServer) -OR ($_.IsHubTransportServer))} )
    PS> if($Exs){
    PS>     copy-Profile -ComputerName $Exs -SourceProfileMachine $SourceProfileMachine -TargetProfile $TargetProfileAcct -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    PS> } else {write-verbose -verbose:$true "$((get-date).ToString('HH:mm:ss')):No Mbx or HT servers found)"} ;
    Copy targetprofile to all Exchange servers (leveraging ExchMgmtShell cmd)
    .EXAMPLE
    PS> if($AdminJumpBox ){
    PS>     write-verbose -verbose:$true "$((get-date).ToString('HH:mm:ss')):AdminJumpBox..."
    PS>     copy-Profile -ComputerName $AdminJumpBox -SourceProfileMachine $SourceProfileMachine -TargetProfile $TargetProfileAcct -JumpBox -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    PS> } ; 
    Perform a full 'admin' profile copy into target jumpbox (specifies -JumpBox param)
    .EXAMPLE
    PS> copy-Profile -ComputerName $JumpBox -SourceProfileMachine $SourceProfileMachine -TargetProfile $SvcAcctProf -JumpBox -MinProfile -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    # Copy the minimum profile to specified Service Account Profile on jumpboxes
    #>
    [CmdletBinding()]
    PARAM (
        [parameter(ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
        Mandatory=$True,HelpMessage="Specify Target Computer for Profile Copy[-ComputerName SERVER]")]
        [Alias('__ServerName','Server','Computer','Name','IPAddress','CN')]   
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [Parameter(Mandatory=$True,HelpMessage="Source Profile Machine [-SourceProfileMachine CLIENT]")]
        [ValidateNotNullOrEmpty()]
        [string]$SourceProfileMachine,    
        [parameter(Mandatory=$True,HelpMessage="Target Account for Profile copy process [-TargetProfile DOMAIN\LOGON]")]
        [ValidatePattern('^\w*\\[A-Za-z0-9-]*$')]
        [string]$TargetProfile,      
        [parameter(HelpMessage="Credential object for use in accessing the computers")]
        [System.Management.Automation.PSCredential]$Credential,
        [Parameter(HelpMessage='-JumpBox  Flag [-JumpBox]')]
        [switch] $JumpBox ,
        [Parameter(HelpMessage='-MinProfile  Flag (copies least admin-related files)[-JumpBox]')]
        [switch] $MinProfile ,
        [Parameter(HelpMessage='Debugging Flag [-showDebug]')]
        [switch] $showDebug,
        [Parameter(HelpMessage='Whatif Flag  [-whatif]')]
        [switch] $whatIf
    ) ;  # PARAM-E
    BEGIN {
        $verbose = ($VerbosePreference -eq 'Continue') ; 
        If ($whatIf){write-host "`$whatIf is $true" ; $bWhatif=$true}; 
        $AdminLogon=$TargetProfile.split("\")[1] ;
        #"SAMACCOUNTNAME" ; 
        $AdminDomain=$TargetProfile.split("\")[0] ;
        #"DOMAIN" ; 
        $TargetProfileAcct=$TargetProfile ;
        #"$($AdminDomain)\$($AdminLogon)";
        $iProcd=0; 
    }  # BEG-E
    PROCESS {
        foreach ($Computer in $Computername) {
            $continue = $true
            $error.clear() ;
            TRY { 
                $ErrorActionPreference = "Stop" ;

                write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):Processing: $($Computer)..." ; 

                $pltProDir=[ordered]@{
                    path="\\$Computer\c$\Users\$AdminLogon\Documents\WindowsPowerShell" ;itemtype="directory" ;Force=$true ;whatif=$($whatif) ; 
                } ; 
                if(!(test-path "\\$Computer\c$\Users\$AdminLogon\Documents\WindowsPowerShell")) {
                    $smsg = "new-item w`n$(($pltProDir|out-string).trim())" ; 
                    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                    new-item @pltProDir ; 
                };

                [array]$profileFiles = "\\$SourceProfileMachine\c$\usr\work\exch\scripts\profile.ps1","\\$SourceProfileMachine\c$\usr\work\exch\scripts\Microsoft.PowerShellISE_profile.ps1" ; 
                
                if($JumpBox -OR ($env:COMPUTERNAME -match $rgxAdminJumpBoxes)){
                    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):-JumpBox specified: Adding full remote profile.." ; 
                    # 3:27 PM 6/22/2020 update to cover admin files
                    if(!$MinProfile){
                        $rgxJumpboxFiles = '^((tor|tsk|admin|(tsk|admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                        # sources from hard-coded git repo root path (fr a dev box)
                        $profileFiles += gci -path "\\$SourceProfileMachine\c$\sc\powershell\PSProfileUID\*" |?{$_.name -match $rgxJumpboxFiles} | select -expand fullname  ; 
                    } else { 
                        # minprofile drop tsk-related items
                        $rgxJumpboxAdminFiles = '^((tor|admin|(admin)sid|vscode|ISE)-|GitHub|profile_).*.(ps1|ps?1|css|html)$'
                        # sources from hard-coded git repo root path (fr a dev box)
                        $profileFiles += gci -path "\\$SourceProfileMachine\c$\sc\powershell\PSProfileUID\*" |?{$_.name -match $rgxJumpboxAdminFiles} | select -expand fullname  ; 

                    } ; 
                } ; 
                $pltCopy = [ordered]@{
                    path=$profileFiles ; 
                    destination=$pltProDir.path ;
                    force=$true ;
                    whatif=$($whatif) ;
                } ; 
                $smsg = "copy-item w`n$(($pltCopy|out-string).trim())`n`$pltCopy.path:`n$(($pltCopy.path|out-string).trim())" ; 
                if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                copy-item @pltCopy ; 
                $iProcd++
            } CATCH { 
              Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ; 
              Exit #Opts: STOP(debug)|EXIT(close)|Continue(move on in loop cycle) 
            } ; 
        } # loop-E
    } # PROC-E
    END {
        $smsg = "PROCESSED $($iProcd) machines" ; 
        if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        $iProcd | write-output ; 
    } ; 
}

#*------^ copy-Profile.ps1 ^------

#*------v count-object.ps1 v------
function Count-Object {
    <#
    .SYNOPSIS
    Count-Object.ps1 - functionalized '($Input | Measure-Object).Count' 
    .NOTES
    Version     : 1.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-13
    FileName    : Count-Object.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,FileSystem,Pipeline
    AddedCredit : tonymcgee
    AddedWebsite: https://www.tonymcgee.net/2013/11/powershell-profile-snippets/
    REVISIONS
    * 8:20 AM 5/4/2021 had in xxx-prof.ps1, wasn't replicated out to other admin profiles, so stick it in verb-io    
    * 11/2013 tonymcgee's posted vers
    .DESCRIPTION
    Count-Object.ps1 - functionalized 'Select-Object -last $n' 
    .PARAMETER  n
    count of pipline items to be returned
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    PSCustomObject
    .EXAMPLE
    PS > $object | Count-Object ; 
    Example using default settings (returns last object from pipeline)
    .EXAMPLE
    PS > $object | Count-Object -n 5; 
    Example returning last 5 objects from pipeline
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://www.tonymcgee.net/2013/11/powershell-profile-snippets/
    #>
    # cmdletbinding breaks default pipeline, and causes err:' The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or the input and its properties do not match any of the parameters that take pipeline input'
    #[CmdletBinding()]
    PARAM($Input) ;
    ($Input | Measure-Object).Count ;
}

#*------^ count-object.ps1 ^------

#*------v Create-ScheduledTaskLegacy.ps1 v------
Function Create-ScheduledTaskLegacy {
    <#
    .SYNOPSIS
    Remove-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    .NOTES
    Author: Hugo @ peeetersonline
    Website:	http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 7:27 AM 12/2/2020 re-rename '*-ScheduledTaskCmd' -> '*-ScheduledTaskLegacy', L13 copy still had it, it's more descriptive as well.
    * 8:13 AM 11/24/2020 renamed to '*-ScheduledTaskCmd', to remove overlap with ScheduledTasks module
    * 8:06 AM 4/18/2017 comment: Invoke-Expression is unnecessary. You can simply state: schtasks.exe /query /s $ComputerName
    * 7:42 AM 4/18/2017 tweaked, added pshelp, comments etc, put into OTB
    * June 4, 2009 posted version
    .DESCRIPTION
    Get-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    Allows you to manage queryingscheduled tasks on one or more computers remotely.
    The functions use schtasks.exe, which is included in Windows. Unlike the Win32_ScheduledJob WMI class, the schtasks.exe commandline tool will show manually created tasks, as well as script-created ones. The examples show some, but not all parameters in action. I think the parameter names are descriptive enough to figure it out, really. If not, take a look at schtasks.exe /?. One tip: try piping a list of computer names to foreach-object and into this function.
    .PARAMETER  ComputerName
    Computer Name (defaults to localhost)[-ComputerName server]
    .PARAMETER TaskName
    Name of Task being targeted [-TaskName "Mytask"]
    .PARAMETER RunAsUser
    Account to be used to run the task [-RunAsUser "Toro\ExchangeAdmin"]
    .PARAMETER TaskRun
    Action Target for the Task [-TaskRun "c:\scripts\script.cmd"]
    .PARAMETER Schedule
    Recurrring Time specification [-Schedule Monthly]
    .PARAMETER Modifier
    Recurring schedule ordinal spec [-Modifier "second"]
    .PARAMETER Days
    Recurring schedule DOW spec [-Days "SUN"]
    .PARAMETER Months
    Recurring schedule Months spec [-Modifier "MAR,JUN,SEP,DEC"]
    .PARAMETER StartTime = "13:00",
    Recurring schedule StartTime spec [-StartTime "13:00"]
    .PARAMETER EndTime = "17:00",
     Recurring schedule EndTime spec [-EndTime "17:00"]
    .PARAMETER Interval = "60"
    Recurring schedule repeat interval spec [-Interval "60"]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns object summary of matched task(s)
    .EXAMPLE
    Create-ScheduledTaskLegacy -ComputerName MyServer -TaskName MyTask02 -TaskRun "D:\scripts\script2.vbs"
    .LINK
    http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    #>
    param(
        [string]$ComputerName = "localhost",
        [string]$RunAsUser = "System",
        [string]$TaskName = "MyTask",
        [string]$TaskRun = '"C:\Program Files\Scripts\Script.vbs"',
        [string]$Schedule = "Monthly",
        [string]$Modifier = "second",
        [string]$Days = "SUN",
        [string]$Months = '"MAR,JUN,SEP,DEC"',
        [string]$StartTime = "13:00",
        [string]$EndTime = "17:00",
        [string]$Interval = "60"
    ) ;
    Write-Host "Computer: $ComputerName"
    #$Command = "schtasks.exe /create /s $ComputerName /ru $RunAsUser /tn $TaskName /tr $TaskRun /sc $Schedule /mo $Modifier /d $Days /m $Months /st $StartTime /et $EndTime /ri $Interval /F"
    #Invoke-Expression $Command
    #Clear-Variable Command -ErrorAction SilentlyContinue
    schtasks.exe /create /s $ComputerName /ru $RunAsUser /tn $TaskName /tr $TaskRun /sc $Schedule /mo $Modifier /d $Days /m $Months /st $StartTime /et $EndTime /ri $Interval /F
    Write-Host "`n"
}

#*------^ Create-ScheduledTaskLegacy.ps1 ^------

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
    * 10:35 AM 2/21/2022 CBH example ps> adds 
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
    PS> $Output = dump-Shortcuts -path [Environment]::GetFolderPath('Desktop') ;
    PS> $Output | out-string ;
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

#*------v Echo-Finish.ps1 v------
Function Echo-Finish {
    <#
    .SYNOPSIS
    Echo-Finish - Close Banner with Elapsed Timer (used with Echo-Finish or Echo-ScriptEnd)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    # 3:21 PM 4/17/2020 added cbh
    # 8:51 AM 10/31/2014 ren'd EchoXXX to Echo-XXX
    .DESCRIPTION
    Echo-Finish - Opening Banner with Elapsed Timer (used with Echo-Finish or Echo-ScriptEnd)
    .EXAMPLE
    PS> Echo-Finish ; 
    PS> gci c:\windows\ | out-null ; 
    Echo-Finish ; 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [cmdletbinding()]
    Param()
    Write-Host " "
    $sMsg = "Completed Time: " + (get-date).toshortdatestring() + "-" + (get-date).toshorttimestring()
    Write-Host $sMsg
    # stop .NET Stopwatch object & echo elapsed time
    if ($sw -ne $null) { $sw.Stop() ; write-host -foregroundcolor green "Elapsed Time: (HH:MM:SS.ms)" $sw.Elapsed.ToString() }
    Write-Host " "
}

#*------^ Echo-Finish.ps1 ^------

#*------v Echo-ScriptEnd.ps1 v------
Function Echo-ScriptEnd {
    <#
    .SYNOPSIS
    Echo-ScriptEnd - Close Banner with Elapsed Timer (used with Echo-ScriptEnd or Echo-ScriptEnd)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    # 8:51 AM 10/31/2014 ren'd EchoXXX to Echo-XXX
    # 11/6/2013
    .DESCRIPTION
    .EXAMPLE
    PS> Echo-ScriptEnd ; 
    PS> gci c:\windows\ | out-null ; 
    PS> Echo-ScriptEnd ; 
    Echo-ScriptEnd - Opening Banner with Elapsed Timer (used with Echo-ScriptEnd or Echo-ScriptEnd)
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [cmdletbinding()]
    Param()
    $sMsg = "Script End Time: " + (get-date).toshortdatestring() + "-" + (get-date).toshorttimestring()
    Write-Host $sMsg
    if ($sw -ne $null) { $sw.Stop() ; write-host -foregroundcolor green "Elapsed Time: (HH:MM:SS.ms)" $sw.Elapsed.ToString() }
}

#*------^ Echo-ScriptEnd.ps1 ^------

#*------v Echo-Start.ps1 v------
Function Echo-Start {
    <#
    .SYNOPSIS
    Echo-Start - Opening Banner with Elapsed Timer (used with Echo-Finish or Echo-ScriptEnd)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    # 3:21 PM 4/17/2020 added cbh
    # 8:51 AM 10/31/2014 ren'd EchoXXX to Echo-XXX
    .DESCRIPTION
    Echo-Start - Opening Banner with Elapsed Timer (used with Echo-Finish or Echo-ScriptEnd)
    .EXAMPLE
    PS> Echo-Start ; 
    PS> gci c:\windows\ | out-null ; 
    PS> Echo-Finish ; 
    Echo bracketing banners around a command
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [cmdletbinding()]
    Param()
    Write-Host " "
    # datetime stamp
    $sMsg = "Start Time: " + (get-date).toshortdatestring() + "-" + (get-date).toshorttimestring()
    # timestamp
    #$sMsg = "Time: " + (get-date).toshorttimestring()
    Write-Host $sMsg
    Write-Host " "
    # start .NET Stopwatch object
    $sw = [Diagnostics.Stopwatch]::StartNew()
}

#*------^ Echo-Start.ps1 ^------

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

#*------v Format-Json.ps1 v------
function Format-Json {
    <#
    .SYNOPSIS
    Format-Json.ps1 - Prettifies JSON output.
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : Format-Json.ps1
    License     : (none asserted)
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Json
    AddedCredit : Theo
    AddedWebsite: https://stackoverflow.com/users/9898643/theo
    AddedTwitter: 
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 9:09 AM 10/4/2021 minor reformatting, expansion of CBH
    * 5/27/2019 - Theo posted version (stackoverflow answer)
    .DESCRIPTION
    Format-Json.ps1 - Reformats a JSON string so the output looks better than what ConvertTo-Json outputs.
    In effect it can take a Minified/compressed one-long-string output (as MS AAD produces for audit logs)...
    #-=-=-=-=-=-=-=-=
    [{"id":"59b5c4e8-a576-4aff-84ab-ffd76f605500","createdDateTime":"2019-04-19T14:27:07.7126929+00:00","userDisplayName":"USER NAME","userPrincipalName":"UPN@DOMAIN.COM","userId":"[GUID]","appId":"00000002-0000-0ff1-ce00-000000000000","appDisplayName":"Office 365 Exchange Online","resourceId":"00000002-0000-0ff1-ce00-000000000000","resourceDisplayName":"office 365 exchange online","ipAddress":"192.168.1.1","status":{"signInStatus":"Success","errorCode":0,"failureReason":null,"additionalDetails<TRIMMED>},
    #-=-=-=-=-=-=-=-=
    ... and convert it to a properly indented, human-friendly array of lines arrangement:
    #-=-=-=-=-=-=-=-=
    [
        {
            "id": "59b5c4e8-a576-4aff-84ab-ffd76f605500",
            "createdDateTime": "2019-04-19T14:27:07.7126929+00:00",
            "userDisplayName": "USER NAME",
            "userPrincipalName": "UPN@DOMAIN.COM",
            "userId": "[GUID]",
            "appId": "00000002-0000-0ff1-ce00-000000000000",
            "appDisplayName": "Office 365 Exchange Online",
            "resourceId": "00000002-0000-0ff1-ce00-000000000000",
            "resourceDisplayName": "office 365 exchange online",
            "ipAddress": "192.168.1.1",
            "status": {
                "signInStatus": "Success",
                "errorCode": 0,
                "failureReason": null,
                "additionalDetails": null
            },
            <TRIMMED>
        },
    #-=-=-=-=-=-=-=-=
    .PARAMETER Json
    Required: [string] The JSON text to prettify.
    .PARAMETER Minify
    Optional: Returns the json string compressed.
    .PARAMETER Indentation
    Optional: The number of spaces (1..1024) to use for indentation. Defaults to 4.
    .PARAMETER AsArray
    Optional: If set, the output will be in the form of a string array, otherwise a single string is output.
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)
    System.Boolean
    [| get-member the output to see what .NET obj TypeName is returned, to use here]
    .EXAMPLE
    PS> $json | ConvertTo-Json  | Format-Json -Indentation 2
    .EXAMPLE
    PS> $json = Get-Content 'D:\script\test.json' -Encoding UTF8 | ConvertFrom-Json
    PS> $json.yura.ContentManager.branch = 'test'
    # recreate the object as array, and use the -Depth parameter (your json needs 3 minimum)
    PS> ConvertTo-Json @($json) -Depth 3 | Format-Json | Set-Content "D:\script\test1.json" -Encoding UTF8
    # instead of using '@($json)' you can of course also recreate the array by adding the square brackets manually:
    # '[{0}{1}{0}]' -f [Environment]::NewLine, ($json | ConvertTo-Json -Depth 3) |
    #        Format-Json | Set-Content "D:\script\test1.json" -Encoding UTF8
    .LINK
    https://stackoverflow.com/questions/56322993/proper-formating-of-json-using-powershell#56324247
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding(DefaultParameterSetName = 'Prettify')]
    PARAM(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true,HelpMessage="[string] The JSON text to prettify.[-Json `$jsontext]")]
        [string]$Json,
        [Parameter(ParameterSetName = 'Minify',HelpMessage="Returns the json string compressed.[-Minify SAMPLEINPUT]")]
        [switch]$Minify,
        [Parameter(ParameterSetName = 'Prettify',HelpMessage="The number of spaces (1..1024) to use for indentation. Defaults to 4.[-Indentation 2]")]
        [ValidateRange(1, 1024)]
        [int]$Indentation = 4,
        [Parameter(ParameterSetName = 'Prettify',HelpMessage="If set, the output will be in the form of a string array, otherwise a single string is output.[-AsArray]")]
        [switch]$AsArray
    ) ;
    if ($PSCmdlet.ParameterSetName -eq 'Minify') {
        return ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 -Compress ; 
    } ; 
    # If the input JSON text has been created with ConvertTo-Json -Compress
    # then we first need to reconvert it without compression
    if ($Json -notmatch '\r?\n') {
        $Json = ($Json | ConvertFrom-Json) | ConvertTo-Json -Depth 100 ; 
    } ; 
    $indent = 0 ; 
    $regexUnlessQuoted = '(?=([^"]*"[^"]*")*[^"]*$)' ; 
    $result = $Json -split '\r?\n' |
        ForEach-Object {
            # If the line contains a ] or } character,
            # we need to decrement the indentation level unless it is inside quotes.
            if ($_ -match "[}\]]$regexUnlessQuoted") {
                $indent = [Math]::Max($indent - $Indentation, 0) ; 
            } ; 
            # Replace all colon-space combinations by ": " unless it is inside quotes.
            $line = (' ' * $indent) + ($_.TrimStart() -replace ":\s+$regexUnlessQuoted", ': ') ; 
            # If the line contains a [ or { character,
            # we need to increment the indentation level unless it is inside quotes.
            if ($_ -match "[\{\[]$regexUnlessQuoted") {
                $indent += $Indentation ; 
            } ; 
            $line ; 
        }
    if ($AsArray) { return $result } ; 
    return $result -Join [Environment]::NewLine ; 
}

#*------^ Format-Json.ps1 ^------

#*------v Get-AverageItems.ps1 v------
function Get-AverageItems {
    <#
    .SYNOPSIS
    Get-AverageItems.ps1 - Avg input items
    .NOTES
    Version     : 1.0.0
    Author      : Raoul Supercopter
    Website     :	https://stackoverflow.com/users/57123/raoul-supercopter
    CreatedDate : 2020-01-03
    FileName    : 
    License     : (none specified)
    Copyright   : (none specified)
    Github      : 
    Tags        : Powershell,Math
    REVISIONS
    12:29 PM 5/15/2013 revised
    17:10 1/3/2010 posted rev
    .DESCRIPTION
    Get-AverageItems.ps1 - Avg input items
    .INPUTS
    stdin
    .OUTPUTS
    System.Int32
    .EXAMPLE
    PS C:\> gci c:\*.* | get-AverageItems
    .LINK
    http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
    #>
    BEGIN { $max = 0; $curr = 0 }
    PROCESS { $max += $_; $curr += 1 }
    END { $max / $curr }
}

#*------^ Get-AverageItems.ps1 ^------

#*------v get-colorcombo.ps1 v------
function get-colorcombo {
    <#
    .SYNOPSIS
    get-colorcombo - Return a readable console fg/bg color combo (commonly for use with write-host blocks to id variant datatypes across a series of tests)
    .NOTES
    Author: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 1:46 PM 3/5/2021 set DefaultParameterSetName='Random' to actually make 'no-params' default that way, also added $defaultPSCombo (DarkYellow:DarkMagenta), and added it as the 'last' combo in the combo array 
    * 3:15 PM 12/29/2020 fixed typo in scheme parse (quotes broke the hashing), pulled 4 low-contrast schemes out
    * 1:22 PM 5/10/2019 init version
    .DESCRIPTION
    .PARAMETER  Combo
    Combo Number (0-73)[-Combo 65]
    .PARAMETER Random
    Returns a random Combo [-Random]
    .PARAMETER  Demo
    Dumps a table of all combos for review[-Demo]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Collections.Hashtable
    .EXAMPLE
    PS> $plt=get-colorcombo 70 ;
    PS> write-host @plt "Combo $($a):$($plt.foregroundcolor):$($plt.backgroundcolor)" ;
    Pull and use get-colorcombo 72 in a write-host ;
    .EXAMPLE
    PS> get-colorcombo -demo ;
    Run a demo colortable output
    .EXAMPLE
    PS> write-host -foregroundcolor green "Pull & write-host a Random get-colorcombo" ;
    PS> $plt=get-colorcombo -Rand ; write-host  @plt "Combo $($a):$($plt.foregroundcolor):$($plt.backgroundcolor)" ;
    Pull a random color combo into a splat, and use it in a write-host.
    .EXAMPLE
    PS> $plt=get-colorcombo -Rand ; 
    PS> $Host.UI.RawUI.BackgroundColor = $plt.BackgroundColor ; 
    PS> $Host.UI.RawUI.ForegroundColor = $plt.ForegroundColor ; 
    Set Console/$Host to a Random get-colorcombo
    .EXAMPLE
    PS> $plt=get-colorcombo -combo 69 ; 
    PS> set-consolecolors @plt ; 
    Use verb-IO:set-consolecolors() function to set colorcombo 69.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding(DefaultParameterSetName='Random')]
    # ParameterSetName='EXCLUSIVENAME'
    Param(
        [Parameter(ParameterSetName='Combo',Position = 0, HelpMessage = "Combo Number (0-73)[-Combo 65]")][int]$Combo,
        [Parameter(ParameterSetName='Random',HelpMessage = "Returns a random Combo [-Random]")][switch]$Random,
        [Parameter(ParameterSetName='Demo',HelpMessage = "Dumps a table of all combos for review[-Demo]")][switch]$Demo
    )
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    if (-not($Demo) -AND -not($Combo) -AND -not($Random)) {
        write-host "(No -combo or -demo specified: Asserting a 'Random' scheme)" ;
        $Random=$true ; 
    } ;
    # rem'd, low-contrast removals: "DarkYellow;Green", "DarkYellow;Cyan","DarkYellow;Yellow", "DarkYellow;White", 
    $schemes = "Black;DarkYellow", "Black;Gray", "Black;Green", "Black;Cyan", "Black;Red", "Black;Yellow", "Black;White", "DarkGreen;Gray", "DarkGreen;Green", "DarkGreen;Cyan", "DarkGreen;Magenta", "DarkGreen;Yellow", "DarkGreen;White", "White;DarkGray", "DarkRed;Gray", "White;Blue", "White;DarkRed", "DarkRed;Green", "DarkRed;Cyan", "DarkRed;Magenta", "DarkRed;Yellow", "DarkRed;White", "DarkYellow;Black", "White;DarkGreen", "DarkYellow;Blue",  "Gray;Black", "Gray;DarkGreen", "Gray;DarkMagenta", "Gray;Blue", "Gray;White", "DarkGray;Black", "DarkGray;DarkBlue", "DarkGray;Gray", "DarkGray;Blue", "Yellow;DarkGreen", "DarkGray;Green", "DarkGray;Cyan", "DarkGray;Yellow", "DarkGray;White", "Blue;Gray", "Blue;Green", "Blue;Cyan", "Blue;Red", "Blue;Magenta", "Blue;Yellow", "Blue;White", "Green;Black", "Green;DarkBlue", "White;Black", "Green;Blue", "Green;DarkGray", "Yellow;DarkGray", "Yellow;Black", "Cyan;Black", "Yellow;Blue", "Cyan;Blue", "Cyan;Red", "Red;Black", "Red;DarkGreen", "Red;Blue", "Red;Yellow", "Red;White", "Magenta;Black", "Magenta;DarkGreen", "Magenta;Blue", "Magenta;DarkMagenta", "Magenta;Blue", "Magenta;Yellow", "Magenta;White" ;
    $defaultPSCombo = @{BackgroundColor = 'DarkMagenta' ; ForegroundColor = 'DarkYellow'} ;
    $colorcombo = @{ } ;
    $i = 0 ;
    # stock the colorschemes indexed-hashtable (supports fast lookups)
    foreach ($scheme in $schemes) {
        $colorcombo[$i] = @{BackgroundColor = $scheme.split(";")[0] ; ForegroundColor = $scheme.split(";")[1] ; } ;
        $i++ ;
    } ;
    $colorcombo[$i] = $defaultPSCombo ; 
    write-verbose "(colorcombo[$($i)] reflects PSDefault scheme)" ; 
    if ($Demo) {
        write-host "(-Demo specified: Dumping a table of range from Combo 0 to $($colorcombo.count-1))" ;
        $a = 00 ;
        Do {
            $plt = $colorcombo[$a].clone() ;
            write-host "Combo $($a):$($plt.foregroundcolor):$($plt.backgroundcolor)" @plt ;
            $a++ ;
        }  While ($a -lt $colorcombo.count) ;
    }
    elseif ($Random) {
        $colorcombo[(get-random -minimum 0 -maximum $colorcombo.count)] | write-output ;
    }
    else {
        write-verbose "-Combo:$($combo) specified:`n$(($colorcombo[$Combo]|out-string).trim())" ; 
        $colorcombo[$Combo] | write-output ;
    } ;
}

#*------^ get-colorcombo.ps1 ^------

#*------v get-ConsoleText.ps1 v------
Function get-ConsoleText {
    <#
    .SYNOPSIS
    get-ConsoleText.ps1 - Copies current powershell console buffer to the clipboard
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : AutomatedLab:Raimund AndrÃ©e [MSFT],Jan-Hendrik Peters [MSFT]
    AddedWebsite:	https://github.com/AutomatedLab/AutomatedLab.Common/blob/develop/AutomatedLab.Common/Common/Public/Get-ConsoleText.ps1
    AddedGithub : https://github.com/AutomatedLab/AutomatedLab
    AddedTwitter:	@raimundandree,@nyanhp
    CreatedDate : 2022-02-02
    FileName    : get-ConsoleText.ps1
    License     : https://github.com/AutomatedLab/AutomatedLab/blob/develop/LICENSE
    Copyright   : Copyright (c) 2022 Raimund AndrÃ©e, Jan-Hendrik Peters
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Clipboard,Text
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 9:27 AM 2/2/2022 added -topipeline switch & post-split code (pipeline return returns text block, not lines, and os-agnostic split pads with spaces between lines unless explicitly supressed); fixed output: was just dumping console text to pipeline (and back into console buffer), piped it into set-clipboard ; minor tweaks OTB fmt, added CBH ; added else clause to echo non-support of VsCode.
    * 6/5/2019 posted AutomatedLab revision (non-functional, doesn't copy to cb)
    .DESCRIPTION
    get-ConsoleText.ps1 - Copies current powershell console buffer to the clipboard
    .PARAMETER toPipeline
    switch to return the text to the pipeline (rather than default 'copy to clipboard' behavior)[-toPipeline]
    .OUTPUT
    None. Outputs console text to clipboard.
    .EXAMPLE
    PS> get-ConsoleText ;
    PS> get-clipboard |  measure | select -expand count ;
    Copy console text to clipboard, then output the number of lines returned.
    .EXAMPLE
    PS> $content = get-ConsoleText -toPipeline ;
    PS> $content.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) |  measure | select -expand count ; 
    PS> $content.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)) | select -first 15 ; 
    Demonstrate assign console text to a variable, and resplit (suppressing empty lines), and output the first 15 lines returned.
    .LINK
    https://github.com/AutomatedLab/AutomatedLab.Common/blob/develop/AutomatedLab.Common/Common/Public/Get-ConsoleText.ps1
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('tmf')]
    PARAM(
        [Parameter(HelpMessage="switch to return the text to the pipeline (rather than default 'copy to clipboard' behavior)[-toPipeline]")]
        [switch] $toPipeline
    ) ;
    
    # Check the host name and exit if the host is not the Windows PowerShell console host.
    if ($host.Name -eq 'Windows PowerShell ISE Host') {
        write-verbose "(`$host.Name:Windows PowerShell ISE Host detected)" ;
        write-verbose "(copying to cb...)" ;
        $return = $psISE.CurrentPowerShellTab.ConsolePane.Text ; 
    } elseif ($host.Name -eq 'ConsoleHost') {
        write-verbose "(`$host.Name:ConsoleHost detected)" ;
        $textBuilderConsole = New-Object System.Text.StringBuilder ;
        $textBuilderLine = New-Object System.Text.StringBuilder ;

        # Grab the console screen buffer contents using the Host console API.
        $bufferWidth = $host.UI.RawUI.BufferSize.Width ;
        $bufferHeight = $host.UI.RawUI.CursorPosition.Y  ;
        $rec = New-Object System.Management.Automation.Host.Rectangle(0, 0, ($bufferWidth), $bufferHeight) ;
        $buffer = $host.UI.RawUI.GetBufferContents($rec)  ;

        #Console buffer actually stores console formatting, along with characters
        # getting text out requires some processing of the raw content
        # Iterate through the lines in the console buffer.
        write-verbose  "(processing buffer)" ; 
        for ($i = 0; $i -lt $bufferHeight; $i++) {
            for ($j = 0; $j -lt $bufferWidth; $j++) {
                $cell = $buffer[$i, $j]  ;
                $null = $textBuilderLine.Append($cell.Character) ;
            } ;
            $null = $textBuilderConsole.AppendLine($textBuilderLine.ToString().TrimEnd()) ;
            $textBuilderLine = New-Object System.Text.StringBuilder ;
        } ;
        # original code was dropping into pipeline, not copying to clipboard (as per echos). 
        $return = $textBuilderConsole.ToString() ;
        Write-Verbose "$bufferHeight lines have been processed" ;
    } elseif( $env:TERM_PROGRAM -eq 'vscode' ){
        write-warning "(VSCode detected: unsupported)" ; 
        BREAK ;
    } else {
        write-warning "(unrecognized `$host.Name:$($host.name))" ; 
        BREAK ;
    } ; 
    if($return -AND -not $toPipeline){
        write-verbose "(copied content to clipboard)" ; 
        # $content 
        $return | set-clipboard
    } else { 
        write-verbose "(returning content to pipeline)" ; 
        # this writes everyting as a single text block, unsplit
        #$return | write-output ; 
        # split before returning - this natively suppresses emtpy lines
        #$return.Split(@("`r`n", "`r", "`n"),[StringSplitOptions]::None) | write-output ; 
        # variant, OS agnostic, requires removeemptyentries or it leaves gaps (inflates a 3k line console to 6k lines). 
        $return.Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries) ;
    } ; 
}

#*------^ get-ConsoleText.ps1 ^------

#*------v Get-CountItems.ps1 v------
function Get-CountItems {
    <#
    .SYNOPSIS
    Get-CountItems.ps1 - Count input items
    .NOTES
    Version     : 1.0.0
    Author      : Raoul Supercopter
    Website     :	https://stackoverflow.com/users/57123/raoul-supercopter
    CreatedDate : 2020-01-03
    FileName    : 
    License     : (none specified)
    Copyright   : (none specified)
    Github      : 
    Tags        : Powershell,Math
    REVISIONS
    17:10 1/3/2010 posted rev
    .DESCRIPTION
    Get-CountItems.ps1 - Count input items
    .OUTPUTS
    System.Int32
    .EXAMPLE
    PS C:\> gci c:\*.* | get-CountItems
    .LINK
    http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
    #>
    BEGIN { $x = 0 }
    PROCESS { $x += 1 }
    END { $x }

}

#*------^ Get-CountItems.ps1 ^------

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

#*------v Get-FolderSize.ps1 v------
function Get-FolderSize {
    <#
    .SYNOPSIS
    Gets the size of a folder.
    .NOTES
    Name: Get-FolderSize
    Author: Rich Kusak
    Versions:
    9:19 AM 9/2/2015 updated help
    Created: 2012-04-05
    2:53 PM 11/7/2014 tsk tweaked, to add SizeRaw, and pull spaces from property names
    Version: 1.0.0 2012-04-11 23:33
    .DESCRIPTION
    The Get-FolderSize function gets the size of a folder, any subfolders, and displays the number of files in each.
    .PARAMETER Folder
    Specifies the folder path.
    .PARAMETER SizeIn
    Specifies how the folder size is displayed. The Dynamic argument will display sizes in the most appropriate unit.
    Other supported arguments are B(Bytes), KB(KiloBytes), MB(MegaBytes), GB(GigaBytes), TB(TeraBytes), PB(PetaBytes).
    Default value: Dynamic
    .PARAMETER Recurse
    Gets the items in the specified locations and in all child items of the locations.
    This parameter is set to true by default.
    .PARAMETER Precision
    Specifies the folder size precision. By default the folder size is rounded to the nearest hundredth (2 decimal places).
    Changing this value slides the decimal place for more or less rounding precision. Valid arguments are 0-15.
    .PARAMETER Force
    Allows the function to get items that cannot otherwise not be accessed by the user, such as hidden or system files.
    .EXAMPLE
    Get-FolderSize
    Gets the folder size of the current location and any subfolders.
    .EXAMPLE
    Get-FolderSize -SizeIn MB
    Gets the folder size of the current location, any subfolders, and displays the size in megabytes.

    .EXAMPLE
    Get-FolderSize -SizeIn GB -Precision 5
    Gets the folder size of the current location, any subfolders, displays the size in gigabytes, and rounds the size to 5 decimal places.
    .EXAMPLE
    $env:USERPROFILE | Get-FolderSize -Recurse:$false
    Gets the folder size of the user profile location and disables recursion.
    .INPUTS
    System.String
    .OUTPUTS
    PSObject
    .LINK
    http://blogs.technet.com/b/heyscriptingguy/archive/2012/04/05/the-2012-scripting-games-advanced-event-4-determine-folder-space.aspx
    #>

    [CmdletBinding()]
    param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript( {
                if (Test-Path -LiteralPath $_ -PathType Container) { $true } else {
                    throw "The argument '$_' is not a real path to a folder."
                }
            })]
        [Alias('FullName')]
        [string]$Folder = '.',

        [Parameter()]
        [ValidateSet('Dynamic', 'B', 'KB', 'MB', 'GB', 'TB', 'PB')]
        [string]$SizeIn = 'Dynamic',

        [Parameter()]
        [switch]$Recurse = $true,

        [Parameter()]
        [int]$Precision = 2,

        [Parameter()]
        [switch]$Force
    )

    begin {

        function Convert-FileSize {
            param (
                [Parameter(Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
                [double]$FileSize,

                [Parameter()]
                [ValidateSet('Dynamic', 'B', 'KB', 'MB', 'GB', 'TB', 'PB')]
                [string]$SizeIn,

                [Parameter()]
                [ValidateRange(0, 15)]
                [int]$Precision = 2
            )

            if ($SizeIn -eq 'Dynamic') {

                switch ($FileSize) {
                    $null { "0 Bytes" }
                    { ($_ -ge 1KB) -and ($_ -lt 1MB) } { "{0} KiloBytes" -f ([math]::Round($_ / 1KB, $Precision)) ; break }
                    { ($_ -ge 1MB) -and ($_ -lt 1GB) } { "{0} MegaBytes" -f ([math]::Round($_ / 1MB, $Precision)) ; break }
                    { ($_ -ge 1GB) -and ($_ -lt 1TB) } { "{0} GigaBytes" -f ([math]::Round($_ / 1GB, $Precision)) ; break }
                    { ($_ -ge 1TB) -and ($_ -lt 1PB) } { "{0} TeraBytes" -f ([math]::Round($_ / 1TB, $Precision)) ; break	}

                    { $_ -ge 1PB } { "{0} PetaBytes" -f ([math]::Round($_ / 1PB, $Precision)) ; break }
                    default { "{0} Bytes" -f $_ }
                } # switch
            }
            else {
                if ($SizeIn -eq 'B') {
                    $FileSize
                }
                else {
                    [math]::Round($FileSize / "1$SizeIn", $Precision)
                } ;
            }
        } # function Convert-FileSize

        $properties = 'Folder', 'SizeOfFolder', 'NumberOfFiles', 'SizeRaw'

    } # begin

    process {

        [PSObject[]]$directories = Get-Item -Path $Folder
        if ( (Get-ChildItem -Path $Folder -Directory).Length -gt 0 ) {

            $directories += Get-ChildItem -Path $Folder -Directory -Recurse:$Recurse -Force:$Force
        }

        foreach ($directory in $directories) {
            $files = Get-ChildItem -Path $directory.FullName -File -Force:$Force
            $size = $files | Measure-Object -Sum Length | Select-Object -ExpandProperty Sum

            New-Object -TypeName PSObject -Property @{
                'Folder'        = $directory.FullName
                'SizeOfFolder'  = Convert-FileSize -FileSize $size -SizeIn $SizeIn -Precision $Precision
                'NumberOfFiles' = $files.Count
                'SizeRaw'       = $size
            } | Select-Object -Property $properties
        } # foreach
    } # process

}

#*------^ Get-FolderSize.ps1 ^------

#*------v Get-FolderSize2.ps1 v------
Function Get-FolderSize2 {
    <#
    .SYNOPSIS
    Get-FolderSize2.ps1 - Aggregate size of specified folder
    .NOTES
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    REVISIONS
    1:39 PM 6/18/2020 updated CBH
    .DESCRIPTION
    Get-FolderSize2.ps1 - Aggregate size of specified folder
    .PARAMETER Path
    Folder path to be aggregated
    .EXAMPLE
    PS C:\> gci c:\*.* | Get-FolderSize2
    .LINK
    http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
    #>
    Param ($Path) ;
    $Sizes = 0 ;
    ForEach ($Item in (Get-ChildItem $Path)) {
        If ($Item.PSIsContainer) { Get-FolderSize2 $Item.FullName }
        Else { $Sizes += $Item.Length } ;
    } ;
    [PSCustomObject]@{'Name' = $path; 'Size' = "{0:N2}" -f ($sizes / 1gb) };

}

#*------^ Get-FolderSize2.ps1 ^------

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
    * 10:35 AM 2/21/2022 CBH example ps> adds 
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
    PS> $blah="C:\Program Files (x86)\Log Parser 2.2","C:\Program Files (x86)\Log Parser 2.2\SyntaxerHighlightControl.dll" ;
    PS> $blah | get-fsoshortname ;
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

#*------v Get-FsoShortPath.ps1 v------
Function Get-FsoShortPath {
        <#
    .SYNOPSIS
    Get-FsoShortPath - Return ShortPath (8.3) for specified Filesystem object
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 7:40 AM 3/29/2016 - added string->path conversion
    * 7:15 AM 3/29/2016 - simple variant, returns the full path to the spec'd filesystem component in 8.3 format.
    * 2:16 PM 3/28/2016 - functional version, no param block
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns ShortPath for specified FSO('s) to the pipeline
    .EXAMPLE
    get-childitem "C:\Program Files\DellTPad\Dell.Framework.Library.dll" | get-fsoShortPath ;
    # Retrieve ShortPath for a file
    .EXAMPLE
    get-childitem ${env:ProgramFiles(x86)} | get-fsoShortPath ;
    Retrieve ShortPath for contents of the folder specified by the 'Program Files(x86)' environment variable
    .EXAMPLE
    $blah="C:\Program Files (x86)\Log Parser 2.2","C:\Program Files (x86)\Log Parser 2.2\SyntaxerHighlightControl.dll" ;
    $blah | get-fsoshortname ;
    Resolve path specification(s) into ShortPaths
    .LINK
    https://blogs.technet.microsoft.com/heyscriptingguy/2013/08/01/use-powershell-to-display-short-file-and-folder-names/
    *---^ END Comment-based Help  ^--- #>
        BEGIN { $fso = New-Object -ComObject Scripting.FileSystemObject } ;
        PROCESS {
            if ($_) {
                $fo = $_;
                switch ($fo.gettype().fullname) {
                    "System.IO.FileInfo" { write-output $fso.getfile($fo.fullname).ShortPath }
                    "System.IO.DirectoryInfo" { write-output $fso.getfolder($fo.fullname).ShortPath }
                    "System.String" {
                        # if it's a gci'able path, convert to fso object and then recurse back through
                        if ($fio = get-childitem -Path $fo -ea 0) { $fio | Get-FsoShortPath }
                        else { write-error "$($fo) is a string variable, but does not reflect the location of a filesystem object" }
                    }
                    default { write-error "$($fo) is not a filesystem object" }
                } ;
            }
            else { write-error "$fo is not a filesystem object" } ;
        }  ;
    }

#*------^ Get-FsoShortPath.ps1 ^------

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

#*------v get-InstalledApplication.ps1 v------
Function get-InstalledApplication {
    <#
    .SYNOPSIS
    get-InstalledApplication.ps1 - Check registry for Installed status of specified application (checks x86 & x64 Uninstall hives, for substring matches on Name)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : get-InstalledApplication
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
    REVISIONS
    * 9:13 AM 4/15/2021 init vers
    .DESCRIPTION
    get-InstalledApplication.ps1 - Check registry for Installed status of specified application (checks x86 & x64 Uninstall hives, for substring matches on Name)
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    if(get-InstalledApplication -name "powershell"){"yes"} else { "no"} ; 
    Default boolean test
    .EXAMPLE    
    get-InstalledApplication -name "powershell" -detail -verbose; 
    Example returning detail (DisplayName and InstallLocation)
    .LINK
    https://github.com/tostka/verb-ex2010
    .LINK
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,HelpMessage="Application Name substring[-Name Powershell]")]
        $Name,
        [Parameter(HelpMessage="Debugging Flag [-Return detailed object on match]")]
        [switch] $Detail
    ) ;
    $x86Hive = Get-ChildItem 'HKLM:Software\Microsoft\Windows\CurrentVersion\Uninstall' |
         % { Get-ItemProperty $_.PsPath } | ?{$_.displayname -like "*$($Name)*"} ;
    if(Test-Path 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'){
        #$x64Hive = ((Get-ChildItem "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        #    Where-Object { $_.'Name' -like "*$($Name)*" } ).Length -gt 0;
        $x64Hive = Get-ChildItem 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
            % { Get-ItemProperty $_.PsPath } | ?{$_.displayname -like "*$($Name)*"} ;
    }
    if(!$Detail){
        # boolean return:
        ($x86Hive -or $x64Hive) | write-output ; 
    } else { 
        $props = 'DisplayName','DisplayVersion','InstallLocation','Publisher' ;
        $x86Hive | Select $props | write-output ; 
        $x64Hive | Select $props | write-output ; 
    } ; 
}

#*------^ get-InstalledApplication.ps1 ^------

#*------v get-LoremName.ps1 v------
function get-LoremName {
    <#
    .SYNOPSIS
    get-LoremName.ps1 - Return a name based on Lorem Ipsum.
    .NOTES
    Version     : 1.0.0
    Author      : JoeGasper@hotmail.com
    Website     :	https://gist.github.com/joegasper/3fafa5750261d96d5e6edf112414ae18
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-12-15
    FileName    : 
    License     : (not specified)
    Copyright   : (not specified)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,ActiveDirectory,DistinguishedName,CanonicalName,Conversion
    AddedCredit : Todd Kadrie
    AddedWebsite:	http://www.toddomation.com
    AddedTwitter:	@tostka / http://twitter.com/tostka
    Inspired to create by: https://twitter.com/MichaelBender/status/1101921078350413825?s=20
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 4:30 PM 12/15/2020 TSK: expanded CBH, 
    * 2019-03-03 
    .DESCRIPTION
    Calls public Loren Ipsum API and returns name and account name if requested.
    .INPUTS
    Count: Number of names to return
    WithAccount: Return an account name.
    .PARAMETER Count 
    Number of names to be returned
    .PARAMETER WithAccount
    Specifies to return a username with the fname/lname combo
    .EXAMPLE
    PS> Get-LoremName
        FirstName LastName
        --------- --------
        Plane     Gloriosam
    Return a name.
    .EXAMPLE
    PS> Get-LoremName -Quantity 4
        FirstName LastName
        --------- --------
        Obrutum   Peccata
        Inermis   Uti
        Epicuro   Quoddam
        Quodam    Congruens
    Return 4 names.
    .EXAMPLE
    PS> Get-LoremName -Quantity 2 -WithAccount
        FirstName  LastName UserName
        ---------  -------- --------
        Vitam      Saluto   Vitam.Saluto56
        Intellegit Hoc      Intellegit.Hoc18
    Return 2 names with account name.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding(PositionalBinding = $false)]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # Number of Names to return
        [Parameter(
            ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true,ValueFromRemainingArguments = $false,Position = 0)]
        [Alias("Quantity")]
        [int]$Count = 1,
        [Parameter()][Switch]$WithAccount
    )
    Begin {
        $loremApi = 'https://loripsum.net/api/5/verylong/plaintext'
        $FirstText = 'FirstName'
        $LastText = 'LastName'
        $AccountText = 'UserName'
        $li = (Invoke-RestMethod -Uri $loremApi) -replace "\?|,|-|\.|;|:|\n", '' -split ' ' | ForEach-Object { if ($_.Length -ge 3) {(Get-Culture).TextInfo.ToTitleCase($_)}}  | Sort-Object -Unique
        $MaxNames = $li.Count - 1
    }
    Process {
        if ($WithAccount) {
            for ($i = 0; $i -lt $Count; $i++) {
                $First = $li[(Get-Random -Maximum $MaxNames)]
                $Last = $li[(Get-Random -Maximum $MaxNames)]
                $Account = "$First.$Last$(Get-Random -Maximum 99)"
                [pscustomobject](ConvertFrom-StringData "$($AccountText) = $Account `n $($LastText) = $Last `n $($FirstText) = $First" ) | Select-Object $($FirstText), $($LastText), $($AccountText)
            }
        }
        else {
            for ($i = 0; $i -lt $Count; $i++) {
                $First = $li[(Get-Random -Maximum $MaxNames)]
                $Last = $li[(Get-Random -Maximum $MaxNames)]
                [pscustomobject](ConvertFrom-StringData "$($LastText) = $Last `n $($FirstText) = $First" ) | Select-Object $($FirstText), $($LastText), $($AccountText)
            }
        }
    }
    End {
    }
}

#*------^ get-LoremName.ps1 ^------

#*------v Get-ProductItems.ps1 v------
function Get-ProductItems {
    <#
    .SYNOPSIS
    get-ProductItems.ps1 - Calculate Product of input items
    .NOTES
    Version     : 1.0.0
    Author      : Raoul Supercopter
    Website     :	https://stackoverflow.com/users/57123/raoul-supercopter
    CreatedDate : 2020-01-03
    FileName    : 
    License     : (none specified)
    Copyright   : (none specified)
    Github      : 
    Tags        : Powershell,Math
    REVISIONS
    17:10 1/3/2010 posted rev
    .DESCRIPTION
    get-ProductItems.ps1 - Calculate Product of input items
    .OUTPUTS
    System.Int32
    .EXAMPLE
    PS C:\> gci c:\*.* | get-ProductItems
    .LINK
    http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
    #>
    BEGIN { $x = 1 }
    PROCESS { $x *= $_ }
    END { $x }
}

#*------^ Get-ProductItems.ps1 ^------

#*------v get-RegistryProperty.ps1 v------
function get-RegistryProperty {
    <#
    .SYNOPSIS
    get-RegistryProperty - Retrieve and return a registry key
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-05-01
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Registry,Maintenance
    REVISIONS
    * 10:13 AM 5/1/2020 init vers
    .DESCRIPTION
    get-RegistryProperty - Retrieve and return a registry key
    .PARAMETER  Path
    Registry path to target key to be updated[-Path 'HKCU:\Control Panel\Desktop']
    .PARAMETER Name
    Registry property to be updated[-Name AutoColorization]
    .PARAMETER Value
    Value to be set on the specified 'Name' property [-Value 0]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .OUTPUT
    System.Object[]
    .EXAMPLE
    $RegValue = get-RegistryProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0 ; 
    Return the desktop AutoColorization property value (silent)
    .EXAMPLE
    $RegValue = get-RegistryProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0 -verbose ; 
    Return the desktop AutoColorization property value with verbose output
    .LINK
    https://github.com/tostka
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True,HelpMessage = "Registry property to be updated[-Name AutoColorization]")]
        [ValidateNotNullOrEmpty()][string]$Name,
        [Parameter(Mandatory = $True,HelpMessage = "Registry path to target key to be updated[-Path 'HKCU:\Control Panel\Desktop']")]
        [ValidateNotNullOrEmpty()][string]$Path,
        [Parameter(Mandatory = $True,HelpMessage = "Value to be set on the specified 'Name' property [-Value 0]")]
        [ValidateNotNullOrEmpty()][string]$Value,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug
    ) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    $error.clear() ;
    TRY {
        $pltReg=[ordered]@{
            Path = $Path ;
            Name = $Name ;
            Value = $Value ;
            whatif=$($whatif) ;
        } ;
        $RegValue = Get-ItemProperty -path $pltReg.path -name $pltReg.name| select -expand $pltReg.name ; 
        write-verbose -Verbose:$Verbose  "$((get-date).ToString('HH:mm:ss')):Value queried:$($pltReg.Path)\`n$($pltReg.Name):`n$(($RegValue|out-string).trim())" ;
        $RegValue | write-output ; 
    } CATCH {
        $ErrTrpd = $_ ; 
        Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrTrpd.Exception.ItemName). `nError Message: $($ErrTrpd.Exception.Message)`nError Details: $($ErrTrpd)" ;
        $false | write-output ; 
    } ; 
}

#*------^ get-RegistryProperty.ps1 ^------

#*------v Get-ScheduledTaskLegacy.ps1 v------
Function Get-ScheduledTaskLegacy {
    <#
    .SYNOPSIS
    Get-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    .NOTES
    Author: Hugo @ peeetersonline
    Website:	http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 7:27 AM 12/2/2020 re-rename '*-ScheduledTaskCmd' -> '*-ScheduledTaskLegacy', L13 copy still had it, it's more descriptive as well.
    * 8:13 AM 11/24/2020 renamed to '*-ScheduledTaskCmd', to remove overlap with ScheduledTasks module
    * 8:06 AM 4/18/2017 comment: Invoke-Expression is unnecessary. You can simply state: schtasks.exe /query /s $ComputerName
    * 7:42 AM 4/18/2017 tweaked, added pshelp, comments etc
    * June 4, 2009 posted version
    .DESCRIPTION
    Get-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    Allows you to manage queryingscheduled tasks on one or more computers remotely.
    The functions use schtasks.exe, which is included in Windows. Unlike the Win32_ScheduledJob WMI class, the schtasks.exe commandline tool will show manually created tasks, as well as script-created ones. The examples show some, but not all parameters in action. I think the parameter names are descriptive enough to figure it out, really. If not, take a look at schtasks.exe /?. One tip: try piping a list of computer names to foreach-object and into this function.
    .PARAMETER  ComputerName
    Computer Name [-ComputerName server]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns object summary of matched task(s)
    .EXAMPLE
    Get-ScheduledTaskLegacy -ComputerName Server01
    Get all tasks on server01
    .EXAMPLE
    Get-ScheduledTaskLegacy -ComputerName bccms641 |?{$_.taskname -like '*drive*'} ;
    Post-filter tasks for name substring.
    .LINK
    http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    #>
    param([string]$ComputerName = "localhost") ;
    Write-Host "Computer: $ComputerName" ;
    # 8:05 AM 4/18/2017 add Axel's object-output filter (otherwise it just returns text)
    #$Command = "schtasks.exe /query /s $ComputerName" ;
    #$Command = schtasks.exe /query /s $ComputerName /FO List | ConvertFrom-CmdList ;
    #Invoke-Expression $Command ;
    schtasks.exe /query /s $ComputerName /FO List | ConvertFrom-CmdList
    #Clear-Variable Command -ErrorAction SilentlyContinue ;
    Write-Host "`n" ;
}

#*------^ Get-ScheduledTaskLegacy.ps1 ^------

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

#*------v Get-SumItems.ps1 v------
function Get-SumItems {
    <#
    .SYNOPSIS
    Get-SumItems.ps1 - Sum input items
    .NOTES
    Version     : 1.0.0
    Author      : Raoul Supercopter
    Website     :	https://stackoverflow.com/users/57123/raoul-supercopter
    CreatedDate : 2020-01-03
    FileName    : 
    License     : (none specified)
    Copyright   : (none specified)
    Github      : 
    Tags        : Powershell,Math
    REVISIONS
    * 12:37 PM 10/25/2021 rem'd req version
    12:29 PM 5/15/2013 revised
    17:10 1/3/2010 posted rev
    .DESCRIPTION
    Get-SumItems.ps1 - Sum input items
    .INPUTS
    stdin
    .OUTPUTS
    console/stdout System.Int32
    .EXAMPLE
    gci c:\*.* | get-SumItems
    .LINK
    http://stackoverflow.com/questions/138144/whats-in-your-powershell-profile-ps1file
    #>
    ##requires -version 2
    BEGIN { $x = 0 }
    PROCESS { $x += $_ }
    END { $x }
}

#*------^ Get-SumItems.ps1 ^------

#*------v get-TaskReport.ps1 v------
function get-TaskReport {
    <#
    .SYNOPSIS
    get-TaskReport.ps1 - Collect and report on specified Scheduled Tasks
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 20201014-0826AM
    FileName    : get-TaskReport.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 10:49 AM 1/8/2021 added extended get-scheduledtask examples to CBH ; repl wh's with a herestring at top ; fixed typo in initial !$Taskname output (extraneous `) 
    * 8:08 AM 12/2/2020 added function alias: get-ScheduledTaskReport (couldn't remember this vers didn't use 'sched', had to hunt it up in the module, by name)
    * 7:24 AM 11/24/2020 expanded no -Task echo to include get-scheduledtasks syntax, added it to CBH example
    * 1:59 PM 10/14/2020 switched Exit to Break ; init
    .DESCRIPTION
    get-TaskReport.ps1 - Collect and report on specified Scheduled Tasks
    .PARAMETER  TaskName
    Array of Tasknames to be reported upon[-TaskName get-taskreport -TaskName 'monitor-ADAccountLock','choco-cleaner']
    .PARAMETER TaskName
    Array of Tasknames to be reported upon[-TaskName get-taskreport -TaskName 'monitor-ADAccountLock','choco-cleaner']
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .EXAMPLE
    get-TaskReport -TaskName 'monitor-ADAccountLock'
    Report on a single Scheduled Task
    .EXAMPLE
    # review task names
    get-scheduledtask | fl taskname ; 
    # report on an array of tasks
    get-taskreport -TaskName 'monitor-ADAccountLock',"choco-cleaner","maintain-ExoUsrMbxFreeBusyDetails.ps1"
    .EXAMPLE
    PS> $task = get-scheduledtask choco-cleaner
    # Return Triggers
    PS> $task.triggers ;
    PS> $task.actions ; 
    
        Id               :
        Arguments        : /c powershell -NoProfile -ExecutionPolicy Bypass -Command
                           %ChocolateyToolsLocation%\BCURRAN3\choco-cleaner.ps1
        Execute          : cmd
        WorkingDirectory :
        PSComputerName   :
    
        # Return Actions 
        Id               :
        Arguments        : /c powershell -NoProfile -ExecutionPolicy Bypass -Command
                       %ChocolateyToolsLocation%\BCURRAN3\choco-cleaner.ps1
        Execute          : cmd
        WorkingDirectory :
        PSComputerName   :
    Examples for use of ScheduledTask module get-ScheduledTasks cmdlet to work with Tasks as objects (Psv3+)
    .EXAMPLE
    PS> get-scheduledtask|?{$_.taskpath -eq '\'} | 
        %{"`nTASK:`t$($_.taskname)`nEXEC:`t$($_.actions.execute)`nARGS: `t$($_.actions.Arguments)`n" } ; 
    
        TASK:   choco-cleaner
        EXEC:   cmd
        ARGS:   /c powershell -NoProfile -ExecutionPolicy Bypass -Command %ChocolateyToolsLocation%\BCURRAN3\choco-cleaner.ps1
        
    Return Summary Name, Execute and Arguments of each root Task:
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('get-ScheduledTaskReport')]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Array of Tasknames to be reported upon[-TaskName get-taskreport -TaskName 'monitor-ADAccountLock','choco-cleaner']")]
        $TaskName,
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Switch to return a summary data object[-Return]")]
        $Return,
        [switch] $showDebug
    ) ;
    BEGIN {
        If(!$TaskName){
            $smsg =@"
No -TaskName specified
available tasks on $($env:computername) include the following:
syntax:
# root tasks
get-scheduledtask|?{`$_.taskpath -eq '\'} | ft -a  ; 
# all tasks:
get-scheduledtask | fl taskname ; 

$((get-scheduledtask|?{$_.taskpath -eq '\'} | ft -auto |out-string).trim()) ; 

"@ ; 
            write-warning $smsg ; 
            Break ; 
        } ; 
    } ;# PROC-E
    PROCESS {
        foreach($TName in $TaskName){
            $error.clear() ;
            TRY {
                $task = get-scheduledtask -TaskName $TName ;
            } CATCH {
                Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
                STOP ;
            } ; 
            if(!$Report){
                $sBnr="#*======v $($task.taskname): v======" ; 
                write-host -foregroundcolor yellow "$($sBnr)" ;
                write-host -foregroundcolor green "==get-TaskReport $($TName):`n$(($task | fl * |out-string).trim())" ; 
                $sBnrS="`n#*------v Triggers : v------" ; 
                write-host -foregroundcolor white "$($sBnrS)" ;
                write-host -foregroundcolor green "n$(($task.triggers|out-string).trim())" ; 
                write-host -foregroundcolor white "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
                $sBnrS="`n#*------v Actions : v------" ; 
                write-host -foregroundcolor white "$($sBnrS)" ;
                write-host -foregroundcolor green "`n$(($task.actions|out-string).trim())" ; 
                write-host -foregroundcolor white "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
                write-host -foregroundcolor green "----Principal:`n$((($task | Select-Object TaskName,Principal,Actions -ExpandProperty "Actions" | Select-Object TaskName,Principal,Execute -ExpandProperty Principal).userid|out-string).trim())" ; 
                $sBnrS="`n#*------v Run History : v------" ; 
                write-host -foregroundcolor white "$($sBnrS)" ;
                write-host -foregroundcolor green "`n$(($task | Get-ScheduledTaskInfo | fl Last*,Next*,Num* |out-string).trim())" ; 
                write-host -foregroundcolor white "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
                write-host -foregroundcolor yellow "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
            } else { 
                if($host.version.major -ge 3){
                    $Hash=[ordered]@{Dummy = $null} ;
                } else {
                    # psv2 Ordered obj (can't use with new-object -properites)
                    $Hash = New-Object Collections.Specialized.OrderedDictionary ; 
                } ;
                # then immediately remove the dummy value (blank & null variants too):
                If($Hash.Contains("Dummy")){$Hash.remove("Dummy")} ; 
                # Populate the $hash with fields, post creation 
                $Hash.Add("NewField",$($NewValue)) ; 
                $Hash.Add("NewField",$($null)) ; 
                $Hash.Add("NewField","") ; 
            } ;
        } ; 
    } ;  # PROC-E
}

#*------^ get-TaskReport.ps1 ^------

#*------v Get-Time.ps1 v------
function Get-Time {
    <#
    .SYNOPSIS
    Ouptuts current MM/DD/YYYY HH:MM:SS [AM/PM] time
    .EXAMPLE
    PS C:\> get-time
    .OUTPUTS
    System.String
    #>
    return $(get-date | foreach { $_.ToLongTimeString() } )
}

#*------^ Get-Time.ps1 ^------

#*------v Get-TimeStamp.ps1 v------
function Get-TimeStamp {
    <#
    .SYNOPSIS
    Get-TimeStamp - Generate and return to pipeline, a timestamp-format [datetime]
    .NOTES
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    Github      : https://github.com/tostka/verb-XXX
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    # 	# ren'd TimeStampNow to get-TimeStampNow
    # vers: 20091002
    .DESCRIPTION
    Get-TimeStamp - Generate and return to pipeline, a timestamp-format [datetime]
    .EXAMPLE
    PS> $timest = get-TimeStamp
    OPTSAMPLEOUTPUT
    Assign a timestamp to $timest
    .LINK
    https://github.com/tostka/verb-io
    #>
    Get-Date -Format "HH:mm:ss"
}

#*------^ Get-TimeStamp.ps1 ^------

#*------v get-TimeStampNow.ps1 v------
Function get-TimeStampNow () {
    <#
    .SYNOPSIS
    get-TimeStampNow - Generate and return to pipeline, a timestamp-format [datetime]
    .NOTES
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    Github      : https://github.com/tostka/verb-XXX
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    # 	# ren'd TimeStampNow to get-TimeStampNow
    # vers: 20091002
    .DESCRIPTION
    get-TimeStampNow.ps1 - Generate and return to pipeline, a timestamp-format [datetime]
    .EXAMPLE
    PS> $timest = get-TimeStampNow
    OPTSAMPLEOUTPUT
    Assign a timestamp to $timest
    .LINK
    https://github.com/tostka/verb-io
    #>
    $TimeStampNow = get-date -uformat "%Y%m%d-%H%M"
    return $TimeStampNow
}

#*------^ get-TimeStampNow.ps1 ^------

#*------v get-Uptime.ps1 v------
function get-Uptime {
    <#
    .SYNOPSIS
    get-Uptime() - retrieves time since last bootup, on the specified/local machine(s)
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    vers: 12:15 PM 2/3/2015 functional
    Vers: 7:26 AM 2/3/2015 port to function
    Vers: 8:35 AM 9/16/2013 added timestamp to console for ref
    vers: 11:02 AM 8/19/2013 - works, with pipeline support, but I removed the computerlist param - pipe in a list if you want one
    vers: 9:19 AM 8/19/2013 - initial version
    .DESCRIPTION
    get-Uptime - retrieves time since last bootup, on the specified/local machine
    Works for single system, and a list on cmdline, but try to pipline Exchservers into it, and it throws up
    .PARAMETER  ComputerName
    Name or IP address of the target computer
    .PARAMETER Credential
    Credential object for use in accessing the computers.
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    Returns an object with uptime data to the pipeline.
    .EXAMPLE
    get-Uptime USEA-MAILEXP | select Computername,Uptime
    .EXAMPLE
    (get-uptime "LYN-3V6KSY1","localhost").uptimestr
    .EXAMPLE
    get-exchangeserver usea-nahubcas1 | get-Uptime
    .EXAMPLE
    get-exchangeserver  | get-Uptime
    .EXAMPLE
    "usea-nahubcas1","usea-fdhubcas1" | foreach {get-uptime $_}
    .EXAMPLE
    get-exchangeserver | sort Site,AdminDisplayVersion.major,Role,Name | foreach {get-uptime $_}
    .EXAMPLE
    Get-ADComputer -filter * | Select @{label='computername';expression={$_.name}} | Get-Uptime
    .LINK
     #>

    # 9:03 AM 2/3/2015 added aliases, permits piping the output of WMI query etc, using Get-WMIObject into a function and it would grab the __Server property of the object and use it in the pipeline of the function.

    [CmdletBinding()]
    param (
        [parameter(
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [Alias('__ServerName', 'Server', 'Computer', 'Name', 'IPAddress', 'CN')]
        [string[]]$ComputerName = $env:COMPUTERNAME
        ,
        [parameter(Position = 1)]
        [System.Management.Automation.PSCredential]$Credential
    ) ;
    BEGIN {
        $Info = @()
        $iProcd = 0;
    }  # BEG-E
    PROCESS {
        foreach ($Computer in $Computername) {
            $iProcd++
            $continue = $true
            try {
                $ErrorActionPreference = "Stop" ;
                $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer #-ErrorAction stop
                $oRet = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime) #-ErrorAction stop
            }
            catch {
                Write "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
                Continue
            } # try/cat-E
            if ($continue) {
                # hashtable of the single system's properties
                # asserted property sort order is on property name
                $property = @{
                    'Computername' = $Computer;
                    'Days'         = $oRet.Days;
                    'Hours'        = $oRet.Hours;
                    'Minutes'      = $oRet.Minutes;
                    'Seconds'      = $oRet.Seconds;
                    'Uptime'       = $oRet -f $oRet.Hours, $oRet.Minutes, $oRet.Seconds;
                    'UptimeStr'    = ("$($Computer):$($oRet.Days)d:$($oRet.Hours)h:$($oRet.Minutes)m:$($oRet.Seconds)s")
                } ;
                $obj = New-Object -Type PSObject -Property $property
                Write-Output $obj
            } # if-E
        } 
    }  # PROC-E
}

#*------^ get-Uptime.ps1 ^------

#*------v Invoke-Flasher.ps1 v------
Function Invoke-Flasher {
    <#
    .SYNOPSIS
    Display a flashing message.
    .NOTES
    Version     : 1.0.0
    Author      : Jeff Hicks
    Website     :	http://jdhitsolutions.com/blog/2014/08/look-at-me
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : Invoke-Flasher.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Prompt
    REVISIONS
    Version     : 0.9 August 10, 2014
    .DESCRIPTION
    This command will present a flashing message that you can use at the end of a script or command to signal the user. By default the command will write a message to the console that alternates the background color between the current console color and a red. You can press any key to end the function and restore the original background color.
    You can also use the -FullScreen switch which will alternate the background color of the entire PowerShell console. Be aware that you will lose any script output that was displayed on the screen.
    This command will NOT work in the PowerShell ISE.
    .INPUTS
    None
    .OUTPUTS
    None
    .EXAMPLE
    PS C:\> Get-Process | Sort WS -Descending | select -first 5 ; Invoke-Flasher
    This is a command line example of what a basic script would look like.
    .EXAMPLE
    PS C:\> $data = get-eventlog Security ; Invoke-Flasher "Security logs retrieved." -fullscreen ; $data
    This example uses the fullscreen parameter because the command output was saved to a variable.
    .LINK
    http://jdhitsolutions.com/blog/2014/08/look-at-me
    .LINK
    Write-Host
    #>
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0)]
        [string]$Text = "The command has completed.",
        [string]$Color = "red",
        [Switch]$FullScreen
    )
    $bg = $host.ui.RawUI.BackgroundColor ;
    $Running = $True ;
    #set cursor position
    $Coordinate = $host.ui.RawUI.CursorPosition ;
    While ($Running) {
        if ($host.ui.RawUI.BackgroundColor -eq $bg) {
            $host.ui.RawUI.BackgroundColor = $color ;
            if ($FullScreen) { Clear-Host } ;
        }
        else {
            $host.ui.RawUI.BackgroundColor = $bg ;
            if ($FullScreen) { Clear-Host } ;
        }  # if-block end;
        #set the cursor position ;
        $host.ui.rawui.CursorPosition = $Coordinate ;
        Write-Host "`n$Text Press any key to continue . . ." ;
        #see if a key has been pushed
        if ($host.ui.RawUi.KeyAvailable) {
            $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyUp,IncludeKeyDown") ;
            if ($key) {
                $Running = $False ;
            }  # if-block end ;
        } #if key available ;
        start-sleep -Milliseconds 500 ;
    }  # while-loop end ;
    $host.ui.RawUI.BackgroundColor = $bg ;
    if ($FullScreen) { Clear-Host } ;
}

#*------^ Invoke-Flasher.ps1 ^------

#*------v Invoke-Pause.ps1 v------
Function Invoke-Pause() {
    <#
    .SYNOPSIS
    Invoke-Pause.ps1 - Press any key to continue prompting function
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 11:04 AM 11/6/2013
    .DESCRIPTION
    Invoke-Pause.ps1 - Press any key to continue prompting function
    .PARAMETER  DisplayMessage
    Switch that specifies message is to be displayed (defaults True)
    .PARAMETER  Content
    Text prompt message to be displayed
    .EXAMPLE
    Invoke-Pause
    Display default prompt & text
    .EXAMPLE
    Invoke-Pause -DisplayMessage $FALSE
    Display a prompt, with no message text
    .EXAMPLE
    Invoke-Pause -Content "Message"
    Display a prompt with a custom message text
    .LINK
    #>
    PARAM(
        [Parameter(HelpMessage="Switch that specifies message is to be displayed (defaults True) [-DisplayMessage `$False]")]
        $DisplayMessage = $TRUE,
        [Parameter(HelpMessage="Text prompt message to be displayed [-Content 'displayed message']")]
        $Content = "Press any key to continue . . ."
    ) ;
    If (($DisplayMessage -ne $TRUE)) { write-host $DisplayMessage.ToString() }
    $HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
    $HOST.UI.RawUI.Flushinputbuffer()
}

#*------^ Invoke-Pause.ps1 ^------

#*------v Invoke-Pause2.ps1 v------
Function Invoke-Pause2() {
    <#
    .SYNOPSIS
    Invoke-Pause2.ps1 - Press any key to continue prompting function
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    # vers: 10:49 AM 1/15/2015 variant that uses cmd; the ui.rawui combo ISN'T BREAKABLE IN A LOOP!
    # vers: 11:04 AM 11/6/2013
    .DESCRIPTION
    Invoke-Pause2.ps1 - Press any key to continue prompting function
    .PARAMETER  DisplayMessage
    Switch that specifies message is to be displayed (defaults True)
    .PARAMETER  Content
    Text prompt message to be displayed
    .EXAMPLE
    Invoke-Pause2
    Display default prompt & text
    .EXAMPLE
    Invoke-Pause2 -DisplayMessage $FALSE
    Display a prompt, with no message text
    .EXAMPLE
    Invoke-Pause2 -Content "Message"
    Display a prompt with a custom message text
    .LINK
    #>
    PARAM(
        [Parameter(HelpMessage="Switch that specifies message is to be displayed (defaults True) [-DisplayMessage `$False]")]
        $DisplayMessage = $TRUE,
        [Parameter(HelpMessage="Text prompt message to be displayed [-Content 'displayed message']")]
        $Content = "Press any key to continue . . ."
    ) ;
    If (($DisplayMessage -ne $TRUE)) { write-host $DisplayMessage.ToString() }
    write-host $Content.ToString()
    Cmd /c pause
}

#*------^ Invoke-Pause2.ps1 ^------

#*------v invoke-SoundCue.ps1 v------
function invoke-SoundCue{
      <#
    .SYNOPSIS
    invoke-SoundCue.ps1 - Plays a sound cue of key'd types from default windows media and SoundScheme bindings. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2022-03-04
    FileName    : invoke-SoundCue.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : from Concept by mRiston (from mwr_tools v1.20.0)
    AddedWebsite: https://www.powershellgallery.com/packages/mwr_tools/1.20.0
    REVISIONS
    * 9:48 AM 3/7/2022 rounded out: implemented full set of 
    Success|Warning|Error|Fail aliases, and full suite of SoundScheme events as 
    well ; completely rem'd mRiston's orig concept code - retained as demo for 
    b64-encoded media plays (would want *very* short files for that approach); 
    added invoke-sound & invoke-audio as function aliases 
    productively uses none of mRiston's original code at the point.  
    * 11:26 AM 3/4/2022 reimplemented mRiston's concept: a sound-playing func, but leveraging the default or current soundscheme mappings in place on windows machines
    .DESCRIPTION
    invoke-SoundCue.ps1 - Plays an audio cue (defaults to System default sounds)

    Note, Asterisk & Warning are the same binding, as are Critical & Error 
    (provides common dev event names - Success|Warn|Error to target for the stock "obtuse" win sound scheme name 
    choices - WTH thought 'Hand' was a good descriptive name for Critical Stop - OK, it's the icon displayed, but WTH?) 
    .PARAMETER Type
    Type of audio cue to play (Asterisk|Beep|Critical|Error|Exclamation|Notification|NotificationSystem|Question|Success|Warning)[-Type Fail]
    .PARAMETER System
    Switch that indicates default System sounds should be played(default behavior)[-System]
    .PARAMETER CurrentSystem
    Switch that indicates Currently-assigned System sounds should be played[-CurrentSystem]
    .OUTPUTS
    None. Returns no objects or output (.NET types)
     .EXAMPLE
    PS> invoke-SoundCue Success
    Plays a success audio cue (defaults to Default sound scheme/windows OS sounds).
    .EXAMPLE
    PS> invoke-SoundCue -Type Warning -CurrentSystem
    Plays the current-set SoundScheme's Warning audio cue
    .EXAMPLE
    PS> 'Asterisk','Beep','Critical','Error','Exclamation','Failure','Notification','NotificationSystem','Question','Success','Warning' |
    PS>  %{"=$($_):" ; "system:$($_)" ; invoke-SoundCue -Type $_ -verbose  ; cmd /c pause ; "systemcurrent:$($_)" ; invoke-SoundCue -Type $_ -curr -verbose ; cmd /c pause ;} ;
    Demo each Type variant, first as System, and then as CurrentSystem binding
    .LINK
    https://www.powershellgallery.com/packages/mwr_tools/1.20.0/Content/invoke-SoundCue.ps1
    .LINK
    https://github.com/tostka/verb-io
    #>
      [CmdletBinding(DefaultParameterSetName='Sys')]
      [Alias('invoke-sound','invoke-audio')]
      param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateSet('Asterisk','Beep','Critical','Error','Exclamation','Failure','Notification','NotificationSystem','Question','Success','Warning')]
        [System.String]$Type,
        [Parameter(ParameterSetName='Sys',HelpMessage="Switch that indicates default System sounds should be played(default behavior)[-System]")]
        [switch] $System,
        [Parameter(ParameterSetName='CurrSys',HelpMessage="Switch that indicates Currently-assigned System sounds should be played[-CurrentSystem]")]
        [switch] $CurrentSystem        
      ) ;

    if(-not $System -AND -not $CurrentSystem){
        write-verbose "defaulting -System true)" ; 
        $System=$true ; 
    } ; 
    <#Concept borrowed & reimplemented from mRiston (who borrowed it from 
    http://www.jadkin.com/?p=207) - disabled the Base64-based code, and just 
    focusted on firing simple system events or the default wavs in each niche. 
    #>
  
 
    <# [System.Media.SystemSounds]::Asterisk.Play(); sleep 1 ; # Asterisk - (jay)
    [System.Media.SystemSounds]::Beep.Play(); sleep 1 ; # Default Beep (thrush1-deet)
    [System.Media.SystemSounds]::Exclamation.Play(); sleep 1 ; # Exclamation (antlers)
    [System.Media.SystemSounds]::Hand.Play(); sleep 1 ; # Critical Stop - (chainsaw 3 pulls)
    [System.Media.SystemSounds]::Question.Play(); sleep 1 ; # Question (redtail hawk)
    # play the default Win files in given niches (most are named for task, but aren't actually bound in default soundscheme):
    (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Ding.wav").Play() ; 
    (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Default.wav").Play() ; 
    (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Error.wav").Play() ; 
    (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Exclamation.wav").Play() ; 
    (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Foreground.wav").Play() ; 
    (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows System Generic.wav").Play() ; 
    (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Notify.wav").Play() ; 

    Sys sound files on Win2016 Server:
    Alarm01.wav
    Alarm02.wav
    Alarm03.wav
    Alarm04.wav
    Alarm05.wav
    Alarm06.wav
    Alarm07.wav
    Alarm08.wav
    Alarm09.wav
    Alarm10.wav
    chimes.wav
    chord.wav
    ding.wav
    notify.wav
    recycle.wav
    Ring01.wav
    Ring02.wav
    Ring03.wav
    Ring04.wav
    Ring05.wav
    Ring06.wav
    Ring07.wav
    Ring08.wav
    Ring09.wav
    Ring10.wav
    ringout.wav
    Speech Disambiguation.wav
    Speech Misrecognition.wav
    Speech Off.wav
    Speech On.wav
    Speech Sleep.wav
    tada.wav
    Windows Background.wav
    Windows Balloon.wav
    Windows Battery Critical.wav
    Windows Battery Low.wav
    Windows Critical Stop.wav
    Windows Default.wav
    Windows Ding.wav
    Windows Error.wav
    Windows Exclamation.wav
    Windows Feed Discovered.wav
    Windows Foreground.wav
    Windows Hardware Fail.wav
    Windows Hardware Insert.wav
    Windows Hardware Remove.wav
    Windows Information Bar.wav
    Windows Logoff Sound.wav
    Windows Logon.wav
    Windows Menu Command.wav
    Windows Message Nudge.wav
    Windows Minimize.wav
    Windows Navigation Start.wav
    Windows Notify Calendar.wav
    Windows Notify Email.wav
    Windows Notify Messaging.wav
    Windows Notify System Generic.wav
    Windows Notify.wav
    Windows Pop-up Blocked.wav
    Windows Print complete.wav
    Windows Proximity Connection.wav
    Windows Proximity Notification.wav
    Windows Recycle.wav
    Windows Restore.wav
    Windows Ringin.wav
    Windows Ringout.wav
    Windows Shutdown.wav
    Windows Startup.wav
    Windows Unlock.wav
    Windows User Account Control.wav
    #>

    <# disabled original concept code - results in a *massive bloated footprint*, from 
        b64-encoding raw sound files, interesting, but not very useful in production 
        context 
    if($Base64){
        THROW "-Base64 internally-encoded Custom sounds have been disabled, in the interest of saving space in this function." 
        # trimmed out the B64-encoded sound files prev stored the original version of this function - retained for future example reference

        # mRiston's note: borrowed http://www.jadkin.com/?p=207

        #region Use this to convert a WAV to a Base64 String for playing
        #$media = [convert]::ToBase64String((Get-Content C:\Users\mriston\Music\LOZ_Fanfare.wav -Encoding Byte))
        #endregion

        switch ($AudioType) {
            Success {
                $media = 'UklGR-TRIMMED-AgIA='
      
            }
            Warning {
                $media = 'UklG-TRIMMED-AgICAAA=='
            }
            Failure {
                $media = 'UklGRs-TRIMMED-CAgIAA'        
            }    
            Critical {
                $media = 'UklGRiRSAgBXQVZFZm10IBAAAAABAAEAgD4AAAB9AAACABAAZGF0YQBSAgAAAAAAAAAAAAEA/////wIA/v8DAP3/AgD+/wIA//8AAAEA/v8CAP//AAABAP//AQD//wEA/v8EAPz/AwD+/wEAAAAAAP//AgD//wAAAAD//wIA//8AAAAA//8CAP//AAAAAAAAAAAAAAAA//8DAPz/AwD+/wAAAgD+/wEAAAD//wEAAAD//wIA/f8DAP7/AgD9/wMA/f8DAP7/AAABAP//AQD//wEA/v8DAP7/AQD//wEA//8CAP7/AQD//wEAAAD//wMA+/8EAP7/AQD//wEA//8BAAAA//8AAAIA/f8DAP////8CAP7/AQAAAAAAAAABAP7/AQAAAAAAAAAAAAAAAAAAAAAA//8CAP//AAAAAAAA//8CAP7/AwD8/wMA/v8BAAEA/v8CAP3/BAD8/wQA/P8DAP7/AQAAAAAA//8CAP3/AwD+/wEAAAD//wEAAAD//wEA//8BAAAAAAD//wAAAQD//wIA/f8CAAAA/v8DAP3/AgD//wEA/v8DAPz/BAD9/wIA/v8BAAAAAAD//wEA//8BAAAA/v8DAP7/AQD//wEA//8BAP//AQD+/wIA//8AAAEA/v8BAAEA/v8DAPz/AwD+/wIA/v8CAP7/AQAAAP//AgD+/wIA/v8BAAAAAQD+/wIA/v8CAP//AQD+/wIA/v8DAPz/BQD7/wMA//8AAAEA//8BAP3/BAD8/wQA/f8BAAAA//8CAP7/AQD//wIA/v8BAAAAAAAAAAAAAAD//wMA/f8DAPz/BAD8/wUA+/8DAP//AAABAP//AAAAAAEA/v8DAP3/AQABAP7/AgD+/wIA/v8CAP7/AQAAAAAAAAD//wEA//8BAAEA/P8FAPv/BAD+/wEA//8BAP//AQD//wIA/f8DAP7/AQAAAAAAAAAAAAAAAAD//wIA/v8CAP7/AQD//wIA///+/wMA/v8BAAAA//8AAAIA/f8DAP3/AgD//wEA//8BAP7/AgD//wEA//8AAAAAAQAAAP7/AwD8/wUA/P8CAP//AAABAP//AAABAP//AQD//wAAAQD//wEA//8AAAAAAQD//wAAAAAAAAEA//8AAAAAAAABAP7/AgD+/wIA/v8CAP7/AQAAAP//AgD+/wEA//8BAP//AQD//wEA//8BAP//AQD//wEA//8CAP3/AwD+/wAAAgD+/wEAAAD//wEAAAD//wIA/f8DAP7/AAACAP7/AQAAAP7/AwD+/wIA/v8BAP//AQAAAAAAAAD//wIA/v8BAAEA/f8EAP3/AgD+/wMA/P8EAP7///8CAP////8DAPz/BAD9/wEAAAAAAAAAAAABAP7/AQD//wEAAQD+/wEA//8CAP7/AgD+/wEAAAAAAAAAAAD//wIA/f8EAPz/AwD+/wIA/v8CAP7/AgD+/wIA/v8CAP//AAD//wIA/v8CAP////8CAP7/AgD//wAAAAAAAAAAAAAAAAAAAQD+/wEAAQD+/wIA//8AAAAAAAABAP7/AwD7/wUA/f8CAP//AAAAAAAAAAAAAAEA//8BAP7/AgD//wEA//8AAAEA/v8DAP3/AgD//wAAAQAAAP//AQD+/wIA//8BAAAA/v8CAP7/AgD//wAAAAAAAAEA/v8CAP7/AgD//wEA/v8CAP//AQD//wEA//8BAAAA//8BAP//AQAAAP//AgD8/wYA+v8FAPz/AwD+/wEAAAD//wIA/f8DAP3/BAD7/wUA+/8FAP3/AQAAAP7/AwD+/wIA/v8BAP//AQAAAAAA//8CAP3/AwD+/wIA/f8EAPv/BQD9/wAAAgD9/wQA/P8DAP3/BAD8/wMA/v8BAAAAAAD//wEAAAAAAP//AgD9/wQA/P8DAP7/AQAAAAAA//8CAP3/AwD9/wMA/v8BAP//AQD+/wMA/f8DAP3/AwD9/wIAAAD//wEA//8AAAEA//8BAP7/AgD//wAAAQD+/wIA//8AAAEA//8AAAIA/P8EAP3/AgD//wAAAAAAAAAAAAAAAAAAAQD+/wIA//8BAP//AQD//wIA/f8EAPv/BgD6/wUA/P8EAPz/AwD+/wAAAgD+/wIA/v8BAP//AgD+/wMA/P8EAPz/AwD//wAAAAAAAP//AwD8/wMA/v8CAP//AAAAAAAAAAAAAAAAAAABAP3/BAD8/wQA/f8BAAAAAAAAAAEA/v8CAP//AAABAP//AQD//wEA//8BAP//AQD+/wMA/f8CAP////8CAP//AQD//wAAAAABAP//AQD//wAAAQD//wEA//8AAAAAAQD+/wMA/f8CAP7/AQAAAAAAAAD//wIA/f8EAPv/BQD8/wMA/v8BAAAA//8CAP7/AgD+/wEAAAAAAAAAAAAAAAAA//8BAAAAAAAAAP//AQAAAP//AgD9/wMA/v8BAAAAAAD//wEA//8BAAAAAAD//wAAAQD//wEAAAD+/wQA+/8FAPz/AwD+/wIA/v8BAAAAAAAAAP//AQAAAAAAAAD//wEAAAAAAAAAAAAAAAAAAAAAAAEA/v8DAPz/BAD+////AgD//wAAAQD+/wEAAQD+/wIA//8AAAEA/v8DAP3/AwD9/wIA//8BAP//AQD+/wIA//8AAAEA/v8DAP3/AgD+/wIA//8BAP////8DAP3/AgD//wAAAQD//wAAAAAAAAEA/v8DAP3/AgD//wAAAQD//wAAAgD9/wMA/f8CAP//AgD+/wEAAAD+/wQA/P8DAP7/AQAAAP//AQAAAAAAAAD//wEA//8CAP3/AwD9/wMA/v8AAAEA//8BAAAA//8BAP//AQAAAP//AQD//wEAAAD//wAAAgD8/wUA/P8CAP//AAABAP//AQD//wAAAQD+/wMA/f8DAP3/AgD//wEA//8BAP//AQD//wEA//8BAAAA/v8DAP3/AwD+/wEA//8BAP7/AwD+/wEA//8AAAEA//8BAP//AQAAAP//AQAAAAAAAQD+/wIA/v8CAP//AAABAP//AAAAAAAAAQD//wEA//8BAP//AQD//wEA//8CAP7/AQAAAP7/BAD8/wMA/v8BAAAAAAD//wEA//8CAP7/AQD//wEA//8CAP3/AwD+/wEAAAAAAP//AgD+/wEAAAD//wIA/v8CAP7/AQAAAAAAAAABAP3/BQD6/wYA+/8EAP3/AgD//wEA//8BAP//AQAAAP//AQAAAP7/AwD9/wMA/v8BAP//AQD//wEAAAD//wIA/f8DAP7/AAABAP//AQD//wEA//8AAAEA//8BAP//AQD//wIA/f8CAP//AQD//wEA/v8CAP//AAAAAAEA/v8CAP////8CAP7/AgD+/wIA/f8DAP7/AQAAAP//AgD+/wIA/f8EAPz/BAD9/wIA/v8CAP//AQAAAP7/AwD9/wQA/P8CAAAA//8CAP7/AQD//wIA/v8CAP////8CAP//AAACAP3/AwD+/wEAAAABAP//AQAAAP//AwD9/wMA/f8CAP7/AQAAAP3/BAD7/wQA/f8BAP//AAD//wEA//8AAAAAAQAAAAAAAQAAAAEAAQAAAAEAAAACAP3/BAD+/wIA//8BAP//AgD+/wIA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of+Y/5r/of+h/5r/nf+o/6D/of+o/53/n/+j/5j/nP+n/57/nv+n/6r/o/+u/7H/s/+4/7X/t/++/7v/tf/A/8T/t/+8/8H/tv/B/8j/yf+1/7r/vv+0/6//u//D/7//tv+9/67/r/+3/77/t//C/8j/w/+9/7j/tf+4/7v/t/+0/77/wP/C/8X/x/+7/8X/wP/C/7X/vf/D/8T/w/++/8X/x//G/8//0v/K/8b/2f/P/8r/xP/T/83/xf/P/83/yP/O/87/xf/G/8b/w//A/8T/vv+6/8n/xv/B/8r/yv/C/8P/yv/K/83/0P/J/8T/wP/D/7v/wf/B/8n/yf/L/8n/xP/K/8P/w//B/77/vv/H/8L/vv/D/8f/uv+z/7//uv+1/7P/wv/C/8P/vv+x/8D/yf/F/73/y//K/8P/x//O/8j/yP/H/8j/yv/A/9v/3v/Y/9b/1v/l/93/1//G/9b/3f/e/9b/2P/c/+H/3f/X/9T/2v/U/87/0v/V/9H/0//X/9f/1//Z/9r/1f/U/9P/2P/T/9f/1f/e/+P/4f/X/87/2v/j/9//4v/i/9z/3//f/+D/1v/V/9r/3f/X/9f/2f/h/9L/0//d/9r/zf/f/+j/6f/Y/9b/4f/m/+v/7v/s/97/3//a/97/5f/t/+3/+v/x//n/AADz//f/AgD8/+P/9P/r//n/AgDx/wEAgADhANEAywDkAN8A4QDoAOgA6gDnAOkA4gDrAOgA8QDvAO0A7QDlAOMA5ADhANgA7gDuAOUA6gDrAPAA7gDzAP8A+gDmAPIA+gD3APIA9ADsAPAA7wDsAOsA8QDkAOgA7gDoAOoA8ADpAOYA8ADsAOsA8wDqAO4A6QDjAOkA7ADmAOYA9gDoAO4A5wDpAOIA5ADhAOAA5ADlAOcA9wDzAPQA4QDoAOsA4wDkAN4A3gDaAOIA1wDaANgAzgDLAM8AzQDAALkAuQDAALwAvQC8AL0AvQC8AL4AvQC8ALcAsAC5ALsAugC8AMEAvQDBAL8AwQDDAMQAwQDGAMIAvQDFAMsAvQDDAL0AwwC+AMEAtgC5ALYAsAC0AKwArgC0ALQArACsAKoAqgCmAKgApgCtAKkArQCtAK0AsACqALEAqACvAKUAqACnAKYApgCeAKUAnACoAJ0AqgChAKsAqACjAJ8AnACpAKEAoACeAKEAngCfAKEAmwCeAJ0AmACZAJ0AnQCbAJIAmgCQAJkAkQCTAJMAkwCNAJUAkACVAJQAlwCRAJUAjwCTAJEAlwCUAJQAlwCUAJEAlQCTAJMAlgCXAJAAmgCOAJcAkACXAJEAlQCWAJIAkwCSAJAAkACTAIwAiwCNAIYAiwCIAIUAhACEAH8AgAB+AH0AfAB9AHgAewB6AHoAdwB7AHkAewB4AHkAeAB4AHkAdwB5AHsAdwB9AHUAgQB5AIAAfwB+AHsAewB2AHsAdwB7AHcAfAB4AHgAeQB3AHkAdgB6AHQAfABzAHoAdQB1AHcAdgB4AHYAdgB1AHkAcwB3AHIAcgByAG8AcgBzAG8AcwBsAG8AbgBtAHMAbwBxAG8AcABsAHEAagBtAG8AaQBvAGkAbQBoAGkAagBnAG0AZQBrAGUAagBmAGoAZgBoAGEAZgBeAGQAYABeAGQAWwBgAF8AXQBfAF4AWQBhAFgAXQBcAFsAWwBaAFcAWABYAFUAWABZAFgAWgBZAFcAUwBUAFIAUwBXAFQAVABWAFQAUABWAFAAUgBSAFEAUgBUAFIAUQBUAFEATwBTAE4AUgBNAFEAUABRAFEAUABRAE8AUQBRAFAAUgBOAE0AUABNAE0AUABMAE4ATQBNAE4ATgBPAEwAUQBLAE0ASwBPAEoAUABMAFEASwBPAEgATQBIAEoASQBKAEoARwBIAEoARgBLAEQATQBAAE0APwBKAEEARgBAAEUAQABEAEEARAA/AEAAPwA/ADsAQQA4AEAAPgA5AEAAOQA7ADkAOQA6ADwANwA6ADcANwA6ADYAOwA3ADkANwA5ADoANgA8ADcAOgA5ADoAOQA6ADsANgA+ADgAPAA4AD4ANwA8ADwAOQA8ADsAOgA6AD0AOgA6AEAANwA9ADwAOgA/ADsAOwA8ADoAPgA2AEEAOQA9AD0AOgA+ADsAOwA8ADoAPQA6ADoAPQA1AD0AOAA6ADsAOwA6ADkAPQA2ADwAOQA3ADgAOgA3ADkAOQA5ADUAOwAzADgANgA2ADUANgA4ADMAOQA1ADMANwA0ADUANwA1ADAANwAxADQAMAA0ADAALwA0AC0ANAAxADEAMwAxADEAMQAxADAAMQAvADEALwAvADAALQAuACwALwApADAAKgAsACsALAArACsALQApACgALAAoACsAKgAlACsAKAAmACsAJAAsACQAKgAmACcAJwAmACYAIwAmACMAJAAmACAAJwAgACcAIgAlACEAJAAjACIAJAAhACMAIQAkACEAIgAhACQAHwAiAB8AIgAgAB8AIAAfACAAHwAeAB4AHwAeABwAHwAfABwAIQAcACEAGwAhAB0AHgAeABoAHwAcABwAGwAcABwAGwAeABoAHQAaAB0AGQAdABgAHwAYAB0AGAAcABoAHAAcABcAHwAYAB4AGAAdABkAGgAYABsAFwAbABYAGwAXABkAGAAXABkAGAAWABsAFwAbABoAFgAaABoAGQAZABkAGAAZABkAGQAWAB0AFAAeABQAHAAVABsAGQAYABkAGgAXABsAGQAWABwAFAAeABYAGgAYABgAGgAXABkAFgAYABgAFgAZABkAFwAbABUAGwAWABgAGgAWABgAFwAXABYAGQAVABYAFwAYABUAGwATABkAFgAVABoAFAAYABYAFQAYABQAGAAXABQAGAAUABkAFQAYABQAGgASABkAFgATABsAEQAZABQAFwAVABYAFAAZABIAGgASABoAFAAVABcAFQAXABYAFAAYABQAFwAVABUAGAAVABcAEwAYABYAFAAZABIAGQAUABYAFwASABkAFQAUABgAFAAZABIAGgATABgAFAAWABYAFAAUABQAGQATABMAFwAUABYAFAAVABUAFAAXABEAFQAVABEAFgASABQAEAAWABIAEwASABEAFQASABEAFAASABEAEwASABIADwAUABEAEAARABIAEAASAA0AFAAOABAAEAAPABAADQASAAwAEQALABEACwARAA0ADgAQAAkAEwAJABEACQASAAgADwANAAoADQAKAA8ACQANAAsADQAMAAwACwANAAwADAAKAA4ACQAPAAYAEAAIAA4ACQAMAAsACwANAAsACwAKAA0ACgANAAkADQAJAA0ACwAKAA0ACQANAAsADAALAAwACwAMAAkADgAJAAwACgAMAAoADQAKAAoADQALAAwADAAKAA0ADAAJAA8ABgAPAAgADQAKAAsACgALAAsACwAKAAwACwAKAA0ACgAKAAwACgAMAAkACwAKAA0ACAAMAAkACwAMAAoACwAKAAsACwAKAAoACgAKAAsACAAMAAoACQAKAAwABwANAAkACgALAAkACgALAAYADQAIAAgACwAJAAkACQAJAAsACQAJAAkACQAMAAcACQAKAAgACAAJAAkABwAKAAYADQAEAAsABgAJAAoABwAIAAYACgAGAAcACQAEAAoABwAGAAoABAALAAUACgAGAAcACAAIAAcABgAIAAcABwAFAAoABAAJAAcABwAIAAYACQAFAAkABQAIAAcABwADAAkABQAHAAYABQAHAAgAAwAKAAMABwAGAAQACQACAAcABgAGAAQABAAJAAMACQABAAoAAgAJAAQABgAFAAUABgAEAAYABQAEAAUABQAFAAMABgAGAAMABwADAAcABAADAAYABgABAAcABAADAAQABQAGAAEABQADAAYABQACAAUABQABAAgAAgAFAAIABgADAAYAAAAGAAIABgACAAQABQABAAcAAAAFAAQAAgADAAMABAABAAUAAwADAAIABgAAAAYAAgAFAAEABQAAAAYAAAAEAAMAAgADAAIABAACAAIABAADAAIABAADAAEABQAAAAYA/v8EAAIAAwAAAAMAAgADAAEABAACAAEAAwADAAIAAgABAAIAAQADAAAABAAAAAQA//8GAP7/BQAAAAMA//8GAP7/AgABAAIAAAADAP//AwD//wQA//8FAP3/BQAAAAIAAgD//wMAAgAAAAAAAgAAAAIAAQADAP7/BQD//wQAAAADAP//AwABAAEAAwAAAAEAAgACAAIAAQABAAIAAgAAAAQA/v8DAAEAAQADAAAAAgACAAAABAAAAAEAAgAAAAQA//8EAP//AgABAAEAAgACAP//AwADAP7/AwABAAMAAAAEAAAAAgABAAEAAwABAAEAAgACAAEAAgACAAEAAgACAAEABAD+/wQAAgACAAEAAgAEAP7/BwD8/wUAAAADAAAAAwD//wMAAQADAAIAAQACAAMAAAADAAEAAAAFAAAAAAADAAEAAgABAAIAAgABAAMAAQABAAMAAQAEAAAAAQACAAMAAAADAAAABAD//wMAAwD//wUAAAAEAAEA//8GAP7/BAD//wMAAQACAAEAAwD//wQAAgABAAIAAgABAAIAAgABAAIAAgAAAAQAAAACAAMA//8FAP//AgADAP//BQD+/wUA//8EAAAAAQADAAIAAQADAAAABAD//wQAAQAAAAUA//8CAAEAAgACAAIAAgAAAAUA//8GAP7/BgD9/wkA+/8FAAAAAwABAAMAAAAEAAAAAwABAAIAAgABAAQA//8CAAMAAQABAAQA//8EAAEAAQADAAAAAgADAAAAAwAAAAMAAAADAAEAAQACAAIAAAADAAAAAwABAAIAAgABAAEAAgAAAAQA/f8GAP//AAADAAIA//8EAP//AwABAAAAAQABAAEAAAADAAAAAAACAAEAAgD//wQAAAD//wMAAAAAAAMA//8BAAEAAAABAAIAAAAAAAIAAAACAAAAAgAAAAEAAAADAP7/AwD//wEAAAACAP//AwD+/wQA/f8EAP//AgAAAAAAAQABAAEAAgD9/wYA/f8EAAAAAAABAAEAAQD//wIA/f8FAP3/BAD8/wUA/f8DAAEA//8BAAEA//8CAP//AAACAP//AQD//wIA/v8DAP//AQABAP//AgABAP7/BAD+/wEAAgD+/wMA/v8CAAAAAgAAAAAAAQAAAAIA//8AAAIA/v8BAAEA//8BAAEA//8CAAAAAAABAAEA//8BAAEA/v8EAPz/AwAAAAAAAgD+/wIAAAD//wMA/f8CAAAA//8BAAAA//8CAP//AAAAAAAAAQAAAAAA//8CAP3/BAD8/wIA/////wEAAAD9/wQA/P8EAP////8DAP3/AgD//wEAAAAAAP7/AwD9/wEAAAD//wIA/v8BAP7/AgD9/wMA/v8AAAAAAAAAAAEA/v8BAP//AQAAAP//AQD//wAAAAD//wIA//8AAAAA//8CAAAA//8CAP7/AwD9/wMA/v8BAAAA/v8CAP7/AQD//wEA/v8DAP3/AwD+/wEA//8CAP7/AgD+/wAA//8CAP//AAAAAAAAAAAAAAAA/v8DAP3/AQABAP7/AQD//wAAAQD//wEA/////wEA//8BAP////8DAP3/AAABAP3/BAD9/wEAAAD//wEAAAAAAAEA//8AAAEA/f8EAP3/AgD9/wMA/v8DAP3/AgAAAAEA//8AAAAAAAAAAAAAAAABAP//AAAAAAAAAgD9/wMA///+/wQA+/8GAPr/BAD+/wEAAAAAAAAAAQD//wEA//8CAP//AQAAAP//AQAAAAEA/v8CAP//AQAAAP//AQAAAAAAAQAAAAEA/v8BAAAAAQD//wEA//8BAAAAAAAAAAEA//8BAAAA//8CAP3/AwD+/wIA//8AAAEA//8BAAEA//8BAP7/AgD+/wQA/P8DAP3/AgD//wEAAAD//wEA//8BAAAA//8CAP//AAABAP3/BQD6/wYA+/8EAP7/AAABAP//AQAAAP7/BAD7/wQA/v8BAAEA/v8BAP//AQABAP7/AwD9/wIA//8BAAAA//8CAP3/AgABAP7/AgD9/wIAAQD+/wQA+/8DAAAA//8CAP//AAAAAAAAAgD9/wMA/f8CAAAAAAD//wEA//8CAP7/AQD//wEAAAAAAAAAAAD//wEAAAD//wIA/v8BAAAA/v8CAP//AAACAP3/AwD9/wMA//8AAAAA//8CAAAA//8AAAEA//8CAPz/BQD7/wMA/////wIA/v8AAAAAAQD//wEA//8AAAAAAQD+/wMA/P8EAPz/BAD9/wIA/f8CAAAAAAAAAP//AAABAAAA/v8CAAAA/v8DAP3/AQABAAAA//8BAP//AQABAP7/AgD+/wIA//8AAAAAAQD+/wIA/v8BAP7/AwD+/wAAAgD8/wQA/f8BAAEA//8AAP7/AwD+/wIA/v8AAAEAAAAAAP//AQABAP7/AgD+/wEAAQAAAP//AQD/////AwD9/wIA/////wEAAAD//wEA/v8CAP//AQD//wAAAAABAP7/BAD7/wQA/f8CAAAA//8BAP7/AwD+/wIA/f8DAP3/AgABAP3/AgD//wAAAAAAAAAAAAAAAP//AAACAPz/BQD8/wMA/P8DAP//AAABAP////8CAP7/AgAAAP//AQD//wEAAAD//wEA//8AAAEA/v8BAAAAAAAAAP7/AwD9/wMA/v8AAAEA//8BAAAA//8CAPz/BgD6/wYA+f8GAP3/AQABAP3/AgD//wEAAAAAAP7/AwD9/wMA/v8BAP7/AwD8/wQA/v/+/wQA+/8EAP7///8CAP7/AQAAAP//AQAAAP//AQD+/wMA/v8AAAEA/v8BAAAA//8AAAIA/f8DAP3/AgD+/wQA/P8DAP3/AQABAP//AgD8/wQA/f8CAP//AAAAAAAAAAD//wEAAAD//wEA//8AAAEAAAD//wEA//8AAAEA//8BAP3/AwD9/wMA/v8AAAAA//8CAP////8CAP3/AgAAAP//AgD+/wAAAAAAAAEA/v8CAP3/AgD+/wIA/v8CAP7/AQD+/wQA/P8DAP3/AQABAP7/AgD+/wEA//8BAP7/AwD9/wIA//8AAAAAAAAAAAAAAAABAP7/AQAAAP//AwD9/wEAAQD+/wIA/v8CAP//AQD+/wEAAAAAAAEA/////wEA//8CAP//AAD//wEAAAA='    }
            }
        } ;
        $sound = new-Object -TypeName System.Media.SoundPlayer
        $sound.stream = (New-Object -TypeName System.IO.MemoryStream -ArgumentList (($$ = [System.Convert]::FromBase64String($media)),0,$$.Length))
        $sound.play()
        Remove-Variable -Name sound
        Remove-Variable -Name media
    
    } else {
    #>

    # instead reimplement the broad concept from scratch leveraging common default sounds and trigger event mappings
    <#
    [When Is Each Sound From A Windows Sound Scheme Played? | Digital Citizen - www.digitalcitizen.life/](https://www.digitalcitizen.life/when-each-sound-windows-sound-scheme-played/)
        - Asterisk - the sound that is played when a popup alert is displayed, like a warning message.
        [System.Media.SystemSounds]::Asterisk.Play(); sleep 1 ; # Asterisk - (jay)
        - Default Beep - this sound is played for multiple reasons, depending on what you do. For example, it will play if you try to select a parent window before closing the active one.
        [System.Media.SystemSounds]::Beep.Play(); sleep 1 ; # Default Beep (thrush1-deet)
        - Exclamation - the sound that is played when you try to do something that is not supported by Windows.
        [System.Media.SystemSounds]::Exclamation.Play(); sleep 1 ; # Exclamation (antlers)
        - Critical Stop - the sound that is played when a fatal error occurs.
        [System.Media.SystemSounds]::Hand.Play(); sleep 1 ; # Critical Stop - (chainsaw 3 pulls)
         - Question (unset by default, but there's a file)
        [System.Media.SystemSounds]::Question.Play(); sleep 1 ; # Question (redtail hawk)
        - Notification - the sound that is played when a default notification from a program or app is displayed. ("twee-dum")
        # no direct access, use : (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Notify.wav").Play() ; 
        - System Notification - the sound that is played when a system notification is displayed. ("boong") 
        # no direct access, use : (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Notify System Generic.wav").Play() ; 

        # play the default Win files in niches:
        (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Ding.wav").Play() ; 
        (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Default.wav").Play() ; 
        (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Error.wav").Play() ; 
        (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Exclamation.wav").Play() ; 
        (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Foreground.wav").Play() ; 
        (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows System Generic.wav").Play() ; 
        (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Notify.wav").Play() ; 
        (New-Object System.Media.SoundPlayer "$env:windir\Media\tada.wav").Play() ; 
        (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Background.wav").Play() ;       
    #>
    switch -regex ($Type){
        'Success' {
            <# Potential "success:"
            C:\Windows\media\chord.wav
            C:\Windows\media\chimes.wav
            C:\Windows\media\Windows Notify.wav
            C:\Windows\media\notify.wav
            * C:\Windows\media\tada.wav
            C:\Windows\media\Windows Foreground.wav
            C:\Windows\media\Windows Notify System Generic.wav
            C:\Windows\media\Ring06.wav
            #>
            if($System){
                $smsg = "System:" ;
                $sound = "$env:windir\Media\tada.wav"; 
            } elseif($CurrentSystem){
                $smsg = "CurrentSystem:" ;
                $sound = "$env:windir\Media\tada.wav"; 
            };
            $smsg += "(playing Success:$($sound))" ; 
            write-verbose $smsg ;
            (New-Object System.Media.SoundPlayer $sound).Play()  ;
        }
        '(Asterisk|Warning)' {
            # - Asterisk - the sound that is played when a popup alert is displayed, like a warning message - (jay)
            if($System){
                $smsg = "System:" ;
                $sound = "$env:windir\Media\Windows Background.wav"; 
                $smsg += "(playing Warning:$($sound))" ; 
                write-verbose $smsg ;
                (New-Object System.Media.SoundPlayer $sound).Play()  ;
            } elseif($CurrentSystem){
                $smsg = "CurrentSystem:" ;
                $smsg += "(playing Warning:(current)" ; 
                write-verbose $smsg ;
                [System.Media.SystemSounds]::Asterisk.Play();
            };
        }
        'Beep'{
            <# - Default Beep - this sound is played for multiple reasons, depending on what 
                you do. For example, it will play if you try to select a parent window before 
                closing the active one. - (thrush1-deet) 
            #>
            if($System){
                $smsg = "System:" ;
                $sound = "$env:windir\Media\Windows Default.wav"; 
                $smsg += "(playing Default Beep:$($sound))" ; 
                write-verbose $smsg ;
                (New-Object System.Media.SoundPlayer $sound).Play()  ;
            } elseif($CurrentSystem){
                $smsg = "CurrentSystem:" ;
                $smsg += "(playing Default Beep:(current)" ; 
                write-verbose $smsg ;
                [System.Media.SystemSounds]::Beep.Play() ; 
            };
        }
        'Exclamation'{
            <# # - Exclamation - the sound that is played when you try to do something that is not supported by Windows. (antlers)
            #>
            if($System){
                $smsg = "System:" ;
                $sound = "$env:windir\Media\Windows Exclamation.wav"; 
                $smsg += "(playing Exclamation:$($sound))" ; 
                write-verbose $smsg ;
                (New-Object System.Media.SoundPlayer $sound).Play()  ;
            } elseif($CurrentSystem){
                $smsg = "CurrentSystem:" ;
                $smsg += "(playing Exclamation::(current)" ; 
                write-verbose $smsg ;
                [System.Media.SystemSounds]::Exclamation.Play() ;
            };
        }
        'Critical|Error|Failure'{
            <# - CriticalStop - the sound that is played when a fatal error occurs. (chainsaw 3 pulls)
            #>
            if($System){
                $smsg = "System:" ;
                $sound = "$env:windir\Media\Windows Critical Stop.wav"; 
                $smsg += "(playing CriticalStop:$($sound))" ; 
                write-verbose $smsg ;
                (New-Object System.Media.SoundPlayer $sound).Play()  ;
            } elseif($CurrentSystem){
                $smsg = "CurrentSystem:" ;
                $smsg += "(playing CriticalStop:(current)" ; 
                write-verbose $smsg ;
                [System.Media.SystemSounds]::Hand.Play(); ;
            };
        }
        'Question'{
            <# - Question (unset by default, no file as well) (redtail hawk)
            #>
            if($System){
                $smsg = "System:" ;
                $sound = "$env:windir\Media\Windows Foreground.wav"; 
                $smsg += "(playing Question:$($sound))" ; 
                write-verbose $smsg ;
                (New-Object System.Media.SoundPlayer $sound).Play()  ;
            } elseif($CurrentSystem){
                $smsg = "CurrentSystem:" ;
                $smsg += "(playing Question:(current)" ; 
                [System.Media.SystemSounds]::Question.Play() ;
            };
        }
        'Notification'{
            <# - Notification - the sound that is played when a default notification from a program or app is displayed. ("twee-dum")
                # no direct access, use : (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Notify.wav").Play() ; 
            #>
            if($System){
                $smsg = "System:" ;
                $sound = "$env:windir\Media\Windows Notify.wav"; 
            } elseif($CurrentSystem){
                $smsg = "CurrentSystem:" ;
                $sound = "$env:windir\Media\Windows Notify.wav"; 
            };
            $smsg += "(playing Notification:$($sound))" ; 
            write-verbose $smsg ;
            (New-Object System.Media.SoundPlayer $sound).Play()  ;
        }
        'NotificationSystem'{
            # - System Notification - the sound that is played when a system notification is displayed. ("boong") 
                # no direct access, use : (New-Object System.Media.SoundPlayer "$env:windir\Media\Windows Notify System Generic.wav").Play() ; 
            #
            if($System){
                $smsg = "System:" ;
                $sound = "$env:windir\Media\Windows Notify System Generic.wav"; 
            } elseif($CurrentSystem){
                $smsg = "CurrentSystem:" ;
                $sound = "$env:windir\Media\Windows Notify System Generic.wav"; 
            };
            $smsg += "(playing NotificationSystem:$($sound))" ; 
            write-verbose $smsg ;
            (New-Object System.Media.SoundPlayer $sound).Play()  ;
        }
    } ; # Swtch-E
}

#*------^ invoke-SoundCue.ps1 ^------

#*------v mount-UnavailableMappedDrives.ps1 v------
Function mount-UnavailableMappedDrives{
    <#
    .SYNOPSIS
    mount-UnavailableMappedDrives.ps1 - Check mapped shell drives (via Get-SMBMapping) for 'Unavailable' status, and create temp PSDrive mounts for each, to make the PS profile completely functional. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-11-08
    FileName    : mount-UnavailableMappedDrives.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Development,Parser
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 11:07 AM 1/19/2022 swapped in $hommeta.rgxMapsUNCs for hard-coded rgx ; added test for value, pre-run
    *2:51 PM 12/5/2021 init
    .DESCRIPTION
    mount-UnavailableMappedDrives.ps1 - Check mapped shell drives (via Get-SMBMapping) for 'Unavailable' status, and create temp PSDrive mounts for each, to make the PS profile completely functional. 
    .PARAMETER rgxRemoteHosts
    Regex of RemotePath 'hosts' to be re-mounted in session[-rgxRemoteHosts '(Host1|host2)']
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS>  mount-UnavailableMappedDrives -rgxRemoteHOsts $homMeta.rgxMapsUNCs -verbose ;
    Run a pass with verbose output, and a regex UNC root path filter passed as a hash variable
    .LINK
    https://github.com/tostka/verb-io
    #>
    #Requires -Version 5
    #Requires -Modules SmbShare
    PARAM(
        [Parameter(HelpMessage="Regex of RemotePath 'hosts' to be re-mounted in session[-rgxRemoteHosts '(Host1|host2)']")]
        [string]$rgxRemoteHosts=$HOMMeta.rgxMapsUNCs,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    $propsSDrv = 'Status','LocalPath','RemotePath' ; 
    $error.clear() ;
    TRY {
        if(-not($rgxRemoteHosts)){
            $smsg = "`$rgxRemoteHosts is not configured!`nspecify a value and rerun" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            throw $smsg ;
        } ; 
        $unavdrvs = Get-SMBMapping -verbose:$($VerbosePreference -eq "Continue") | ?{$_.RemotePath -match $rgxRemoteHosts -AND $_.status -eq 'Unavailable'} ; 
        $psdrvs = Get-psdrive -verbose:$($VerbosePreference -eq "Continue") | ?{$_.remotepath -match $rgxRemoteHosts } ; 
        if($unavdrvs){
            $smsg = "Unavailable mapped drives:`n$(($unavdrvs|ft -a $propsSDrv | out-string).trim())" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        } ; 
        $pltNPSD=[ordered]@{
          Name = $null ; 
          Root = $null ; 
          PSProvider = 'FileSystem' ; 
          Scope = "Global" ; 
          ErrorAction = 'STOP' ; 
          Verbose = $($VerbosePreference -eq "Continue") ; 
          whatif = $($whatif) ; 
        } ; 
        # New-PSDrive -Name "S" -Root "\\Server01\Scripts" -Persist -PSProvider "FileSystem" -Credential $cred ;      
        $netDrvs = @() ;    
        foreach($drv in $unavdrvs){
            $pltNPSD.Name = [regex]::match($drv.localpath.tostring(),"([A-Z]):").captures[0].groups[1].value; 
            $pltNPSD.Root = $drv.remotepath; 
            if($psdrvs |?{($_.Root -eq $drv.remotepath) -AND $_.name -eq $pltNPSD.Name}){
                $smsg = "(existing psDrive for " ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
            } else { 
                write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):Fix:Unavail Map: New-PSDrive w`n$(($pltNPSD|out-string).trim())" ; 
                $netDrvs += New-PsDrive @pltNPSD ; 
                if(-not $whatif){
                    if(test-path -path "$($netDrvs[-1].Name):" -ea continue){
                        $smsg = "(confirmed drive available)" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } else { 
                        $smsg = "drive fails availability test!" ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN} #Error|Warn|Debug 
                        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } ; 
           


                } else { 
                    $smsg = "(-whatif: skipping confirmation)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                } ;
            } ; 
        } ; 
        $smsg = "Post Status:`n$(($netDrvs|ft -a | out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        #$results = Get-SMBMapping -verbose:$($VerbosePreference -eq "Continue") | ?{$_.remotepath -like '*synnas*'} ;     
        # no above still reflects unavail, do the psd's off of the $netdrv output

        <#$smsg = "Post Status w`n$((Get-SMBMapping  | ?{$_.remotepath -like '*synnas*'}|  ft -a $propsSDrv |out-string).trim())" ;     
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
        #>
        $results | write-output ; 
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #-=-record a STATUSWARN=-=-=-=-=-=-=
        $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
        if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
        if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
        #-=-=-=-=-=-=-=-=
        $smsg = "FULL ERROR TRAPPED (EXPLICIT CATCH BLOCK WOULD LOOK LIKE): } catch[$($ErrTrapd.Exception.GetType().FullName)]{" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level ERROR } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        $false | write-output ; 
        Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
    } ; 
}

#*------^ mount-UnavailableMappedDrives.ps1 ^------

#*------v move-FileOnReboot.ps1 v------
function move-FileOnReboot {
    <#
    .SYNOPSIS
    move-FileOnReboot.ps1 - Move Locked file (dir) on next reboot
    .NOTES
    Version     : 1.0.0
    Author      : psytechnic
    Website     : https://psytechnic.blogspot.com/2017/12/powershell-golden-egg-delete.html
    CreatedDate : 2020-11-23
    FileName    : move-FileOnReboot.ps1
    License     : (none specified)
    Copyright   : (none specified)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,FileSystem,File,Move,Reboot
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 12:10 PM 11/23/2020 replaced Lee Holmes old code ; this is a more up to date well-rounded option ; also renamed to move-FileOnReboot (from move-FileLocked)
    * 12/1/2017 - posted version
    .DESCRIPTION
    Move Locked file on next reboot.Win32 API that enables this is MoveFileEx. Calling this API with the MOVEFILE_DELAY_UNTIL_REBOOT flag tells Windows to move (or delete) your file at the next boot. Specify a destination, and it moves on reboot. Omit destination and it deletes the file on reboot. Note: directory contents (or permission restrictions) must be removed & queued for reboot removal *before* doing any parent directory object deletion. 
    .PARAMETER path
    Source file path [c:\path-to\file.txt]
    .PARAMETER destination
    Destination path [c:\path-to\destination\]
    .EXAMPLE
    gci "W:\archs\pix\20150820-reload-eq\Thumbs.db" -force | % { move-FileOnReboot -path $_.FullName -destination (Join-Path c:\tmp ($_.Name + ".Bak")) -whatif }  ;
    .EXAMPLE
    dir C:\Users\leeholm -Filter "NTUser.DAT { 
        * " -force | % { move-FileOnReboot $_.FullName (Join-Path c:\temp\ ($_.Name + ".Bak")) }  ;
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://psytechnic.blogspot.com/2017/12/powershell-golden-egg-delete.html
    #>
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = "Source file path [c:\path-to\file.txt]")]
        [ValidateNotNull()] [string]$path,
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "Destination path [c:\path-to\destination\]")]
        [ValidateNotNull()] [string]$destination
    ) ;
    BEGIN{
        TRY{ [Microsoft.PowerShell.Commands.AddType.AutoGeneratedTypes.MoveFileUtils]|Out-Null }
        CATCH{
            $memberDefinition = @' 
[DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Auto)]
public static extern bool MoveFileEx(string lpExistingFileName, string lpNewFileName, int dwFlags);
'@ ;
            Add-Type -Name MoveFileUtils -MemberDefinition $memberDefinition ;
        } ;
    } ;
    PROCESS{
        $Path="$((Resolve-Path $Path).Path)" ;
        if ($Destination){
            $Destination = $executionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Destination) ;
        }else{ $Destination = [Management.Automation.Language.NullString]::Value } ;
        $MOVEFILE_DELAY_UNTIL_REBOOT = 0x00000004 ;
        [Microsoft.PowerShell.Commands.AddType.AutoGeneratedTypes.MoveFileUtils]::MoveFileEx($Path, $Destination, $MOVEFILE_DELAY_UNTIL_REBOOT) ;
    } ;
    END{} ;
}

#*------^ move-FileOnReboot.ps1 ^------

#*------v new-Shortcut.ps1 v------
function new-Shortcut {
    <#
    .SYNOPSIS
    new-Shortcut.ps1 - create shortcut .lnk files
    .NOTES
    Version     : 1.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-13
    FileName    : new-Shortcut.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,FileSystem,Shortcut,Link
    AddedCredit : GodHand
    AddedWebsite: https://forums.mydigitallife.net/threads/create-shortcuts-with-powershell-new-shortcut.78748/
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 7:56 AM 4/15/2021 moved Elevated rewrite into non-whatif; added -ea 0 to the variable checks
    * 8:18 AM 4/13/2021 minor updates, added whatif support ; revised param names to match my set-shortcut (which uses the underlying call argument names) ; put into otb format, tightened up layout.
    * 1/5/2019 GodHand's posted vers
    .DESCRIPTION
    new-Shortcut.ps1 - create shortcut .lnk files
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
    .PARAMETER TargetPath
    The full path to the target file the shortcut will point to.
    .PARAMETER OutputDirectory
    The full path to the directory where the shortcut will be created. If no output directory is supplied, the shortcut will be created in the same location as the target application.
    .PARAMETER Name
    The name of the shortcut. By default the target application name is used for the shortcut name.
    .PARAMETER Description
    A comment describing the details of the shortcut.
    .PARAMETER Arguments
    Any special arguments the shortcut will pass to the target application.
    .PARAMETER WorkingDirectory
    The full path of the directory the target application uses during execution.
    .PARAMETER HotKey
    A hotkey combination that can be used to execute the shortcut.
    .PARAMETER WindowStyle
    The windows style of the target application - Normal, Maximized or Minimized.
    .PARAMETER IconPath
    The full path and optional integer value of the icon file to use for the shortcut. Example: 'imageres.dll,-1023'
    .PARAMETER Elevated
    Sets the shortcut to run with administrative privileges.
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    PSCustomObject
    .EXAMPLE
    PS> New-Shortcut -TargetPath "C:\Tools and Utilities\Registry Workshop\RegWorkshop64.exe" -OutputDirectory "$HOME\Desktop" -Name "Registry Workshop" -Description "An advanced registry editor." -Elevated
    PS> New-Shortcut -TargetPath "C:\Tools and Utilities\Notepad++\notepad++.exe" -HotKey Ctrl+Alt+N
    PS> "D:\Imaging Tools\Deployment\imagex.exe | New-Shortcut
    PS> New-Shortcut -TargetPath 'C:\usr\local\bin\Admin-W10Home-TINSTOY-1280x768-TSK.RDP' -OutputDirectory "$HOME\Desktop" -Name "Tinstoy-RDP" -Description "RDP to Tinstoy." -Elevated -verbose #-whatif ;
    Examples using -OutputDirectory & -Name and a mix of parameters, included -Elevated & -Hotkey
    .EXAMPLE
    New-Shortcut -TargetPath "$($env:SystemRoot)\system32\WindowsPowerShell\v1.0\powershell.exe" -OutputDirectory "$HOME\Desktop" -Name "Powershell (Elevated)" -Description "Performs object-based (command-line) functions" -Elevated -verbose -whatif ;
    Example using -OutputDirectory & -Name, with Elevated & Description
    New-Shortcut -TargetPath "$($env:ProgramFiles)\PowerShell\6\pwsh.exe" -linkpath "$HOME\Desktop\Powershell 6 (Elevated).lnk" -Description "PowerShell 6 (x64)" -Elevated -verbose -whatif ;
    Example using full -linkpath (vs -OutputDirectory & -Name)
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://forums.mydigitallife.net/threads/create-shortcuts-with-powershell-new-shortcut.78748/
    #>
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    PARAM(
        [Parameter(Mandatory = $true,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true,HelpMessage = 'The full path to the target file the shortcut will point to.')]
        [ValidateScript( { Test-Path (Resolve-Path -Path $_).Path })]
        [ValidateNotNullOrEmpty()]
        [string]$TargetPath,
        
        [Parameter(ParameterSetName='FullPath', HelpMessage = 'Path to target .lnk file.')]
        [ValidateNotNullOrEmpty()]$LinkPath,
        [Parameter(ParameterSetName='FolderPath', HelpMessage = 'The full path to the directory where the shortcut will be created.')]
        [string]$OutputDirectory,
        [Parameter(ParameterSetName='FolderPath', HelpMessage = 'The name of the shortcut. By default the target application name is used for the shortcut name.')]
        [string]$Name,
        [Parameter(HelpMessage = 'A comment describing the details of the shortcut.')]
        [string]$Description,
        [Parameter(HelpMessage = 'Any special arguments the shortcut will pass to the target application.')]
        [string]$Arguments,
        [Parameter(HelpMessage = 'The full path of the directory the target application uses during execution.')]
        [string]$WorkingDirectory,
        [Parameter(HelpMessage = 'A hotkey combination that can be used to execute the shortcut.')]
        [string]$HotKey,
        [Parameter(HelpMessage = 'The windows style of the target application.')]
        [ValidateSet('Normal', 'Maximized', 'Minimized')]
        [string]$WindowStyle = 'Normal',
        [Parameter(HelpMessage = 'The full path and integer value to the icon file to use for the shortcut.')]
        [string]$IconLocation,
        [Parameter(HelpMessage = 'Sets the shortcut to run with administrative privileges.')]
        [switch]$Elevated,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN {
        $Verbose = ($PSBoundParameters['Verbose'] -eq $true) ; 
        #$shell = New-Object -ComObject WScript.Shell 
        $Offset = 0x15 ; 
    } ;
    PROCESS {
        if($LinkPath -AND (!$Name -AND !$OutputDirectory)){
            
        } else{
            If ($Name){
                $ShortcutName = [System.IO.Path]::ChangeExtension($Name, '.lnk') ; 
            } else { 
                $ShortcutName = [System.IO.Path]::ChangeExtension($(Split-Path -Path $TargetPath -Leaf), '.lnk') ; 
            } ; 

            If (!$OutputDirectory){
                $LinkPath = Join-Path -Path (Split-Path -Path $TargetPath -Parent) -ChildPath $ShortcutName ; 
            } else { 
                $LinkPath = Join-Path -Path $OutputDirectory -ChildPath $ShortcutName ; 
            } ; 
        } ; 
        Switch ($WindowStyle){
            'Normal' { [int]$WindowStyle = 1 } 
            'Maximized' { [int]$WindowStyle = 3 } 
            'Minimized' { [int]$WindowStyle = 7 } 
        } ; 
        Try{
            $ObjShell = New-Object -ComObject WScript.Shell ; 
            $Shortcut = $ObjShell.CreateShortcut($LinkPath) ; 
            $Shortcut.TargetPath = $TargetPath ; 
            $Shortcut.WorkingDirectory = $WorkingDirectory ; 
            $Shortcut.Description = $Description ; 
            $Shortcut.Arguments = $Arguments ; 
            $Shortcut.WindowStyle = $WindowStyle ; 
            $Shortcut.HotKey = $HotKey ; 
            If ($IconLocation){
                $Shortcut.IconLocation = $IconLocation ; 
            } ; 
            if($whatif){
                #write-verbose -verbose:$verbose  'What if: Performing the operation "CreateShortcut" on target "$($LinkPath)".' ;
                write-verbose "What if: Performing the operation 'CreateShortcut'  w`n$(($Shortcut|out-string).trim())" ; 
            } else { 
                $Shortcut.Save() ; 
                # this updates the file, doesn't exist if -whatif
                If ($Elevated){
                    $Bytes = [System.IO.File]::ReadAllBytes($LinkPath) ; 
                    $Bytes[$Offset] = $Bytes[$Offset] -bor 0x20 ; 
                    [System.IO.File]::WriteAllBytes($LinkPath, $Bytes) ; 
                    [bool]$Elevated = $true ; 
                } else { 
                    [bool]$Elevated = $false ; 
                } ; 
            } ; 
            
            # chg: retain $Result as hash, till actual output, easier to dyn add approp props
            $Result = @{
                Application     = (Split-Path -Path $TargetPath -Leaf)
                ApplicationPath = (Split-Path -Path $TargetPath)
                Description     = $Description ; 
                Arguments       = $Arguments ; 
                HotKey          = $HotKey ; 
                Elevated        = $Elevated ; 
            }
            if($LinkPath){
                $Result.add('LinkPath',$LinkPath) ; 
            } ; 
            if($ShortcutName){
                $Result.add('Name',$ShortcutName) ; 
                $Result.add('Directory',(Split-Path -Path $LinkPath -Parent)) ; 
            }
        }Catch{
            $ErrTrapd=$Error[0] ;
            $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            ##Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
            $PSCmdlet.ThrowTerminatingError($ErrTrapd) ; 
        }Finally{
            [void][Runtime.InteropServices.Marshal]::ReleaseComObject($ObjShell) ; 
        } ; 
    } ;
    END{
        If ($Result) {
            # (flipped to write-output vs return stmt)
            New-Object PSObject -Property $Result  | write-output ;
        } ; 
    } ; 
}

#*------^ new-Shortcut.ps1 ^------

#*------v out-Clipboard.ps1 v------
Function out-Clipboard {
    <#
    .SYNOPSIS
    out-Clipboard.ps1 - cross-version emulation of the older pre-psv3 out-clipboard 'clip.exe' use (for pre psv3); or emulates the `n-appending bahavior of clip.exe, when using it for psv3+. This differentiates from the native set-clipboard, which appends no trailing `n.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : out-Clipboard.ps1
    License     : (none-asserted)
    Copyright   : (none-asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Hashtable,PSCustomObject,Conversion
    AddedCredit : https://community.idera.com/members/tobias-weltner
    AddedWebsite:	https://community.idera.com/members/tobias-weltner
    AddedTwitter:	URL
    REVISIONS
    * 10:59 AM 11/29/2021 fixed - shift to adv func broke the $input a-vari (only present w simple funcs): Added declared $content pipeline vari; added -NoLegacy switch to suppress the default 'append-`n to each line' clip.exe behavior emulation. 
    * 3:17 PM 11/8/2021 init vers, flip profile alias & clip.exe to holistic function for either
    .DESCRIPTION
    out-Clipboard.ps1 - cross-version emulation of the older pre-psv3 out-clipboard 'clip.exe' use (for pre psv3); or emulates the `n-appending bahavior of clip.exe, when using it for psv3+. This differentiates from the native set-clipboard, which appends no trailing `n.
    Set-clipboard supports pipeline support, like the older | clip.exe approach. 
    But, there are differences between set-clipboard & clip.exe: 
    - clip.exe appends `n to every item added. 
    - set-clipboard does not.
    if you have code in place using the prior clip.exe support, and want an emulation of the prior behavior, this fakes it by appending `n to the input, before set-clipboarding the value. 
    .OUTPUT
    None. places specified input onto the clipboard.
    .EXAMPLE
    "some text" | out-clipboard ; 
    .LINK
    https://github.com/tostka/verb-IO
    #>

    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,HelpMessage="Content to be copied to clipboard [-Content `$object]")]
        [ValidateNotNullOrEmpty()]$Content,
        [Parameter(HelpMessage="Switch to suppress the default 'append `n' clip.exe-emulating behavior[-NoLegacy]")]
        [switch]$NoLegacy
    ) ;
    PROCESS {
        if($host.version.major -lt 3){
            # provide clipfunction downrev
            if(-not (get-command out-clipboard)){
                # build the alias if not pre-existing
                $tClip = "$((Resolve-Path $env:SystemRoot\System32\clip.exe).path)" ;
                #$input | "($tClip)" ; 
                #$content | ($tClip) ; 
                Set-Alias -Name 'Out-Clipboard' -Value $tClip -scope script ;
            } ;
            # input only works in simple functions, in adv funcs declare a suitable vari
            #$input | out-clipboard 
            $content | out-clipboard ;
        } else {
            # emulate clip.exe's `n-append behavior on ps3+
            <#$input = $input | foreach-object {"$($_)$([Environment]::NewLine)"} ; 
            $input | set-clipboard ; 
            #>
            if(-not $NoLegacy){
                $content = $content | foreach-object {"$($_)$([Environment]::NewLine)"} ; 
            } ; 
            $content | set-clipboard ;
        } ; 
    } ; 
}

#*------^ out-Clipboard.ps1 ^------

#*------v Out-Excel.ps1 v------
function Out-Excel {
    <#
    .SYNOPSIS
    Out-Excel.ps1 - Simple func to deliver Excel as a out-gridview alternative.
    .NOTES
    Version     : 1.0.0
    Author      : heyscriptingguy
    Website     :	http://blogs.technet.com/b/heyscriptingguy/archive/2014/01/10/powershell-and-excel-fast-safe-and-reliable.aspx
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : Out-Excel.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Excel
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    # vers: * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
    # vers: 1/10/2014
    .DESCRIPTION
    Out-Excel.ps1 - Simple func to deliver Excel as a out-gridview alternative.
    .EXAMPLE
    PS> $obj | Out-Excel
    .EXAMPLE
    .LINK
    https://github.com/tostka/verb-IO
    #>
    PARAM($Path = "$env:temp\$(Get-Date -Format yyyyMMddHHmmss).csv")
    $input | Export-CSV -Path $Path -UseCulture -Encoding UTF8 -NoTypeInformation
    Invoke-Item -Path $Path
}

#*------^ Out-Excel.ps1 ^------

#*------v Out-Excel-Events.ps1 v------
function Out-Excel-Events {
<#
.SYNOPSIS
Out-Excel-Events.ps1 - Simple func() to deliver Excel as a out-gridview alternative, this variant massages array ReplacementStrings into a comma-delimited string.
.NOTES
Version     : 1.0.0
Author      : heyscriptingguy
Website     :	http://blogs.technet.com/b/heyscriptingguy/archive/2014/01/10/powershell-and-excel-fast-safe-and-reliable.aspx
Twitter     :	@tostka / http://twitter.com/tostka
CreatedDate : 2020-
FileName    : Out-Excel-Events.ps1 
License     : (none asserted)
Copyright   : (none asserted)
Github      : https://github.com/tostka/verb-XXX
Tags        : Powershell,Excel
REVISIONS
# vers: * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
# vers: 1/10/2014
.DESCRIPTION
Simple func() to deliver Excel as a out-gridview alternative, this variant massages array ReplacementStrings into a comma-delimited string.
.EXAMPLE
PS> $obj | Out-Excel-Events
.EXAMPLE
.LINK
https://github.com/tostka/verb-IO
#>
    PARAM($Path = "$env:temp\$(Get-Date -Format yyyyMMddHHmmss).csv")
    $input | Select -Property * |
    ForEach-Object {
        $_.ReplacementStrings = $_.ReplacementStrings -join ','
        $_.Data = $_.Data -join ','
        $_
    } | Export-CSV -Path $Path -UseCulture -Encoding UTF8 -NoTypeInformation
    Invoke-Item -Path $Path
}

#*------^ Out-Excel-Events.ps1 ^------

#*------v parse-PSTitleBar.ps1 v------
Function parse-PSTitleBar {
    <#
    .SYNOPSIS
    parse-PSTitleBar.ps1 - parse Powershell console Titlebar into components '[consHost] [role] - [domain] - [org] [svcs]' sorted format
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    Twitter     :	
    CreatedDate : 2021-07-23
    FileName    : parse-PSTitleBar.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Console
    REVISIONS
    * 8:15 AM 7/27/2021 sub'd in $rgxQ for duped rgx
    * 11:42 AM 7/26/2021 added verbose echo support
    * 3:15 PM 7/23/2021 init vers
    .DESCRIPTION
    parse-PSTitleBar.ps1 - parse Powershell console Titlebar into components '[consHost] [role] - [domain] - [org] [svcs]' sorted format
    .EXAMPLE
    $consParts = parse-PSTitleBar 
    Parse the current powershell console Title Bar and return components
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    [CmdletBinding()]
    Param (
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug
    )
    BEGIN {
        $showDebug=$true ; 
        $verbose = ($VerbosePreference -eq "Continue") ; 
        # simpler alt, take everything after last '-':
        [regex]$rgxsvcs = ('^(' + (((Get-Variable  -name "TorMeta").value.OrgSvcs |foreach-object{[regex]::escape($_)}) -join '|') + ')$') ;
        write-verbose "using `$rgxsvcs:$($rgxsvcs)" ; 
        $Metas=(get-variable *meta|?{$_.name -match '^\w{3}Meta$'}).name ; 
        if(!$rgxTenOrgs){ [regex]$rgxTenOrgs = ('^(' + (($metas.substring(0,3) |foreach-object{[regex]::escape($_)}) -join '|') + ')$') } ; 
        write-verbose "`$rgxTenOrgs:$($rgxTenOrgs)" ; 
    } 
    PROCESS {
        #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
        If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
            $hshCons=[ordered]@{
                Host=$null ; 
                Role = $null ; 
                Domain = $null ; 
                Info = $null ; 
                Orgs = $null ; 
                Services = $null ; 
            } ; 
            # doing it with rgx
            #$rgxTitleBarTemplate = '(PS|PSc)\s(ADMIN|Console)\s-\s(.*)\s-(.*)' ; 
            $rgxTitleBarTemplate = '^(PS|PSc)\s(.*)\s-\s(.*)\s-(.*)$' ; 
            if($host.ui.rawui.windowtitle -match $rgxTitleBarTemplate){
                $hshCons.host,$hshCons.role,$hshCons.domain=$matches[1..3]; 
                if($hshCons.role.indexof('-')){
                    $xs = $hshCons.role ; 
                    $hshCons.role=$xs.tostring().split('-')[0] ; 
                    $hshCons.add('TermTag',($xs.tostring().split('-'))[1] ) ; 
                    remove-variable xs
                } ;
                $hshCons.Info = $matches[4] ;
                $hshCons.Orgs = $hshCons.Info -split ' '| ?{$_} | ?{$_ -match $rgxTenOrgs} | sort | select -unique  ; 
                $hshCons.Services = $hshCons.Info -split ' '| ?{$_} | ?{$_ -match $rgxsvcs} | sort | select -unique  ; 
            }
            <# simple parser        
            $consPrembl = $host.ui.rawui.windowtitle.substring(0,$host.ui.rawui.windowtitle.LastIndexOf('-')).trim() ;
            $consData = ($host.ui.rawui.windowtitle.substring(($host.ui.rawui.windowtitle.LastIndexOf('-'))+1) -split '\s\s').trim(); 
            $svcs = $consdata | ?{$_ -match $rgxsvcs} | sort | select -unique  ; 
            $Orgs = $consdata |?{$_ -match $rgxTenOrgs } | sort | select -unique  ; 
            [array]$titElems = @($consPrembl) ; 
            $titElems += (([array]$orgs + $svcs) -join ' ') ; 
            $host.ui.RawUI.WindowTitle = "$($titElems -join ' - ') " ; # manually add trailing space, to keep consistent for parsing.
            #>
        }
    }
    END {
        write-verbose "Returning values:`n$(($hshCons|out-string).trim())" ; 
        [pscustomobject]$hshCons | write-output ;  
    } ;
}

#*------^ parse-PSTitleBar.ps1 ^------

#*------v play-beep.ps1 v------
function play-beep {
    <#
    .SYNOPSIS
    play-beep - play a simple console beep for on-completion alert
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Certificate,Developoment
    REVISIONS   :
    12:23 PM 12/18/2014
    .DESCRIPTION
    play-beep - play a simple console beep for on-completion alert
    .EXAMPLE
    ping localhost ; play-beep;
    .LINK
    #>
    write-host "`a";
}

#*------^ play-beep.ps1 ^------

#*------v prompt-Continue.ps1 v------
Function prompt-Continue {
    <#
    .SYNOPSIS
    prompt-Continue - Prompted wait for "YYY" confirmation
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    9:55 AM 2/4/2015 - updated TOR
    9:54 AM 2/4/2015 TOR port, update
    20090731 - set the prompt to reverse video (write-warning, vs. write-host)
    .DESCRIPTION
    prompt-Continue - Prompted wait for "YYY" confirmation
    throws up a continue-prompt.
    .PARAMETER  MsgText
    Prompt text [text]
    .PARAMETER  Type
    Specify WARN message [Type: WARN]
    .EXAMPLE
    prompt-Continue "hello"
    .EXAMPLE
    prompt-Continue "hello" WARN
    (warning prompt)
    .LINK
     #>
    Param(
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Enter prompt text [text]")]
        [ValidateNotNullOrEmpty()]
        [string]$MsgText
        ,
        [Parameter(Position = 1, HelpMessage = "Specify if WARN message [Type: WARN]")]
        [ValidateSet("WARN")]
        [string]$Type
    ) # PARAM BLOCK END
    #$MsgText ;
    If (($MsgText -eq $null) -OR ($MsgText -eq "")) { write-warning "No `$MsgText specified" ; break } ;
    If (($Type -ne $null) -AND ($Type.ToUpper() -eq "WARN")) {
        write-warning $MsgText  ;
        #"This script will " $sAppDesc " ON " $targservr
        write-warning "DO NOT CONTINUE UNLESS YOU KNOW WHAT YOU'RE DOING AND WHAT THIS SCRIPT DOES!!!" ;
        # beep
        write-host "`a"; ;
    }
    else {
        write-host -foregroundcolor yellow ($MsgText) ;
        #"This script will " $sAppDesc " ON " $targservr
        write-host -foregroundcolor yellow ("DO NOT CONTINUE UNLESS YOU KNOW WHAT YOU'RE DOING AND WHAT THIS SCRIPT DOES!!!") ;
    } ; # if-E
    $bRet = read-host "Enter YYY to continue:" ;
    if ($bRet.ToUpper() -eq "YYY") {
        "continuing..." ;
    }
    else {
        write-warning "Invalid response. Exiting..." ;
        # exit <asserted exit error #>
        exit 1 ;
    } ;
}

#*------^ prompt-Continue.ps1 ^------

#*------v read-Host2.ps1 v------
Function Read-Host2 {
    <#
    .SYNOPSIS
    An alternative to Read-Host
    .NOTES
    Author      : Jeff Hicks
    Website     :	http://jdhitsolutions.com/blog/2014/08/more-flashing-fun
    CreatedDate : 2020-04-17
    FileName    : Read-Host2.ps1
    REVISIONS   :
    Version     : 0.9 August 18, 2014
    .DESCRIPTION
    This is an alternative to Read-Host which works almost the same as the original cmdlet. You can use this to prompt the user for input. They can either enter text or have the text converted to a secure string. The only difference is that the prompt will display in a flashing colors until you start typing.
    requires -version 3.0
    This command will NOT work properly in the PowerShell ISE.
    .PARAMETER Prompt
    The text to be displayed. A colon will be appended.
    .PARAMETER AsSecureString
    The entered text will be treated as a secure string. This parameter has an alias of 'ss'.
    .PARAMETER UseForeground
    Flash the text color instead of the background. This parameter has aliases of 'fg' and 'foreground'.
    .EXAMPLE
    PS C:\> $user = Read-Host2 "Enter a username" -color DarkGreen ;$user;
    Prompt for user name using a dark green background
    .EXAMPLE
    PS C:\> $pass = Read-Host2 "Enter a password" -color darkred -foreground -asSecureString
    Prompt for a password using DarkRed as the foreground color.
    .EXAMPLE
    PS C:\> $s={ $l = get-eventlog -list ; Read-host2 "Press enter to continue" ; $l}
    PS C:\> &$s
    Press enter to continue :
      Max(K) Retain OverflowAction        Entries Log
      ------ ------ --------------        ------- ---
      20,480      0 OverwriteAsNeeded      30,829 Application
      20,480      0 OverwriteAsNeeded           0 HardwareEvents
         512      7 OverwriteOlder              0 Internet Explorer
      20,480      0 OverwriteAsNeeded           0 Key Management Service
      20,480      0 OverwriteAsNeeded          12 Lenovo-Customer Feedback
         128      0 OverwriteAsNeeded         455 OAlerts
         512      7 OverwriteOlder              0 PreEmptive
      20,480      0 OverwriteAsNeeded      32,013 Security
      20,480      0 OverwriteAsNeeded      26,475 System
      15,360      0 OverwriteAsNeeded      17,715 Windows PowerShell
     This is an example of how you might use the command in a script. The prompt will keep flashing until you press Enter.
    .LINK
    http://jdhitsolutions.com/blog/2014/08/more-flashing-fun
    .LINK
    Read-Host
    ConvertTo-SecureString
    #>
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = "Enter a prompt message")]
        [string]$Prompt,
        [Alias('ss')]
        [switch]$AsSecureString,
        [System.ConsoleColor]$Color = "Red",
        [Alias("fg", "Foreground")]
        [switch]$UseForeground
    )
    #this will be the array of entered characters
    $text = @() ;
    #save current background and foreground colors
    $bg = $host.ui.RawUI.BackgroundColor ;
    $fg = $host.ui.RawUI.ForegroundColor ;
    #set a variable to be used in a While loop
    $Running = $True ;
    #set a variable to determine if the user is typing something
    $Typing = $False ;
    #get current cursor position
    $Coordinate = $host.ui.RawUI.CursorPosition ;
    $msg = "`r$Prompt : " ;
    While ($Running) {
        ;
        if (-Not $Typing) {
            ;
            #don't toggle or pause if the user is typing
            if ($UseForeground) {
                ;
                if ($host.ui.RawUI.ForegroundColor -eq $fg) {
                    $host.ui.RawUI.ForegroundColor = $color ;
                }
                else {
                    $host.ui.RawUI.ForegroundColor = $fg ;
                } ;
            }  # if-block end;
            else {
                ;
                if ($host.ui.RawUI.BackgroundColor -eq $bg) {
                    $host.ui.RawUI.BackgroundColor = $color ;
                }
                else {
                    ;
                    $host.ui.RawUI.BackgroundColor = $bg ;
                }  # if-block end;
            }  # if-block end;
            Start-Sleep -Milliseconds 350 ;
        } #if not typing ;
        #set the cursor position
        $host.ui.rawui.CursorPosition = $Coordinate ;
        #write the message on a new line
        Write-Host $msg ;
        #see if a key has been pushed
        if ($host.ui.RawUi.KeyAvailable) {
            #user is typing
            $Typing = $True ;
            #filter out shift key
            $key = $host.ui.RawUI.ReadKey("NoEcho,IncludeKeyDown")  ;
            Switch ($key.virtualKeyCode) {
                13 { $Running = $False ; Break } ;
                16 {
                    #Shift key so don't do anything ;
                    Break ;
                }  # switch entry end;
                Default {
                    #add the key to the array
                    $text += $key ;
                    #display the entered text
                    if ($AsSecureString) {
                        #mask the character if asking for a secure string
                        $out = "*" ;
                    }
                    else {
                        $out = $key.character ;
                    } ;
                    #append the character to the prompt
                    $msg += $out ;
                }  # switch entry end;
            }  # switch block end ;
        }  # if-block end;
    }  # while-loop end;
    #reset the original background color
    $host.ui.RawUI.BackgroundColor = $bg ;
    $host.ui.RawUI.ForegroundColor = $fg ;
    #write the input to the pipeline
    #removing any leading or trailing spaces
    $data = (-join $text.Character).Trim() ;
    #convert to SecureString if specified
    if ($AsSecureString) {
        ConvertTo-SecureString -String $data -AsPlainText -Force ;
    }
    else {
        #write the read data to the pipeline
        $data ;
    }  # if-block end;

}

#*------^ read-Host2.ps1 ^------

#*------v rebuild-PSTitleBar.ps1 v------
Function rebuild-PSTitleBar {
    <#
    .SYNOPSIS
    rebuild-PSTitleBar.ps1 - reconstruct Powershell console Titlebar in '[consHost] [role] - [domain] - [org] [svcs]' sorted format
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : 
    AddedWebsite:	
    AddedTwitter:	
    Twitter     :	
    CreatedDate : 2021-07-22
    FileName    : rebuild-PSTitleBar.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Console
    REVISIONS
    * 11:53 AM 7/26/2021 refactor for verbose/begin/proc/whatif etc
    * 10:15 AM 7/22/2021 init vers
    .DESCRIPTION
    rebuild-PSTitleBar.ps1 - reconstruct Powershell console Titlebar in '[consHost] [role] - [domain] - [org] [svcs]' sorted format
    .EXAMPLE
    rebuild-PSTitleBar 
    Test for the string 'EMS' in the powershell console Title Bar
    .EXAMPLE
    rebuild-PSTitleBar -showdebug
    run with flag to permit code to run in ISE/VSCode (normally suppressed, they don't have consistent window titles)
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    [CmdletBinding()]
    Param (
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    )
    BEGIN{
        $showDebug=$true ; 
        $verbose = ($VerbosePreference -eq "Continue") ; 
    } 
    PROCESS{
        #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
        If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
            # doing it with rgx
            #if($host.ui.rawui.windowtitle -match '(PS|PSc)\s(ADMIN|Console)\s-\s(.*)\s-(.*)'){
            #     $conshost,$consrole,$consdom=$matches[1..3]; 
            #     $conssvcs = $matches[4] -split ' '|?{$_}|%{"'$($_)'"}
            # }
            # simpler alt, take everything after last '-':
            #[regex]$rgxsvcs = ('(' + (((Get-Variable  -name "TorMeta").value.OrgSvcs |foreach-object{[regex]::escape($_)}) -join '|') + ')') ;
            # make it ^$ restrictive, no substring matches
            [regex]$rgxsvcs = ('^(' + (((Get-Variable  -name "TorMeta").value.OrgSvcs |foreach-object{[regex]::escape($_)}) -join '|') + ')$') ;
            write-verbose "`$rgxsvcs:$($rgxsvcs)" ; 
            $Metas=(get-variable *meta|?{$_.name -match '^\w{3}Meta$'}).name ; 
            if(!$rgxTenOrgs){ [regex]$rgxTenOrgs = ('^(' + (($metas.substring(0,3) |foreach-object{[regex]::escape($_)}) -join '|') + ')$') } ; 
            write-verbose "`$rgxTenOrgs:$($rgxTenOrgs)" ; 
            $consPrembl = $host.ui.rawui.windowtitle.substring(0,$host.ui.rawui.windowtitle.LastIndexOf('-')).trim() ;
            write-verbose "`$consPrembl:$($consPrembl)" ; 
            #$consData = ($host.ui.rawui.windowtitle.substring(($host.ui.rawui.windowtitle.LastIndexOf('-'))+1) -split '\s\s').trim(); 
            # split to an array, not space-dcelimtied
            $consData = ($host.ui.rawui.windowtitle.substring(($host.ui.rawui.windowtitle.LastIndexOf('-'))+1) -split '\s').trim(); 
            write-verbose "`$consData:`n$(($consData|out-string).trim())" ; 
            $svcs = $consdata | ?{$_ -match $rgxsvcs} | sort | select -unique  ; 
            write-verbose "`$svcs:`n$(($svcs|out-string).trim())" ; 
            $Orgs = $consdata |?{$_ -match $rgxTenOrgs } | sort | select -unique  ; 
            write-verbose "`$Orgs:`n$(($Orgs|out-string).trim())" ; 
            [array]$titElems = @($consPrembl) ; 
            write-verbose "`$titElems:`n$(($titElems|out-string).trim())" ; 
            $titElems += (([array]$orgs + $svcs) -join ' ') ; 
            write-verbose "`$titElems:`n$(($titElems|out-string).trim())" ; 
            if(-not($whatif)){
                write-verbose "update:`$host.ui.RawUI.WindowTitle to :`n'$($titElems -join ' - ') '" ; 
                $host.ui.RawUI.WindowTitle = "$($titElems -join ' - ') " ; # manually add trailing space, to keep consistent for parsing.
            } else { 
                write-host "update:`$host.ui.RawUI.WindowTitle to :`n'$($titElems -join ' - ') '" ;  
            } ;
        } ;
    }
    END{} ;
}

#*------^ rebuild-PSTitleBar.ps1 ^------

#*------v Remove-InvalidFileNameChars.ps1 v------
Function Remove-InvalidFileNameChars {
  <#
    .SYNOPSIS
    Remove-InvalidFileNameChars - Remove OS-specific illegal filename characters from the passed string
    .NOTES
    Author: Ansgar Wiechers
    Website:	https://stackoverflow.com/questions/23066783/how-to-strip-illegal-characters-before-trying-to-save-filenames
    Twitter     :	
    AddedCredit : 
    AddedWebsite:	
    Version     : 1.0.0
    CreatedDate : 2020-09-01
    FileName    : Remove-InvalidFileNameChars.ps1
    License     : 
    Copyright   : 
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Filesystem
    REVISIONS   :
    * 4:35 PM 12/16/2021 added -PurgeSpaces, to fully strip down the result. Added a 2nd CBH example
    * 7:21 AM 9/2/2020 added alias:'Remove-IllegalFileNameChars'
    * 3:32 PM 9/1/2020 added to verb-IO
    * 4/14/14 posted version
    .DESCRIPTION
    Remove-InvalidFileNameChars - Remove OS-specific illegal filename characters from the passed string
    Note: You should pass the filename, and not a full-path specification as '-Name', 
    or the function will remove path-delimters and other routine path components. 
    .PARAMETER Name
    Potential file 'name' string (*not* path), to have illegal filename characters removed. 
    .PARAMETER PurgeSpaces
    Switch to purge spaces along with OS-specific illegal filename characters. 
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.String
    .EXAMPLE
    $Name = Remove-InvalidFileNameChars -name $ofile ; 
    Remove OS-specific illegal characters from the sample filename in $ofile. 
    .EXAMPLE
    $Name = Remove-InvalidFileNameChars -name $ofile -purgespaces ; 
    Remove OS-specific illegal characters & spaces from the sample filename in $ofile. 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('Remove-IllegalFileNameChars')]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Name,
        [switch]$PurgeSpaces
    )
    $verbose = ($VerbosePreference -eq "Continue") ; 
    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join '' ; 
    if($PurgeSpaces){
        write-verbose "(-PurgeSpaces: removing spaces as well)" ; 
        $invalidChars += ' ' ; 
    } ; 
    $re = "[{0}]" -f [RegEx]::Escape($invalidChars)
    ($Name -replace $re) | write-output ; 
}

#*------^ Remove-InvalidFileNameChars.ps1 ^------

#*------v remove-ItemRetry.ps1 v------
function remove-ItemRetry {
    <#
    .SYNOPSIS
    remove-ItemRetry - Write output string to specified File
    .NOTES
    Version     : 1.0.0
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
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 2:23 PM 4/21/2021 added -GracefulFail, to permit process-newmodule to process past failed existing content removals, to get the mod built (better than hard fails)
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
    PS> $bRet = remove-ItemRetry -Path "$($env:userprofile)\Documents\WindowsPowerShell\Modules\$($ModuleName)\*.*" -Recurse -showdebug:$($showdebug) -whatif:$($whatif) ;
    PS> if (!$bRet) {throw "FAILURE" ; EXIT ; } ;
    Recursively remove content specified, failures result in retry with -Force
    .LINK
    #>

    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to target file/directory [-Path path-to\file.ext]")]
        [ValidateNotNullOrEmpty()]$Path,
        [Parameter(HelpMessage = "Recursive removal [-Recurse]")]
        [switch] $Recurse,
        [Parameter(HelpMessage = "Graceful fail recovery Flag (-ea:'continue', rather than 'Stop' on inability to remove)[-GracefulFail]")]
        [switch] $GracefulFail,
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
    if($GracefulFail){
        $pltRemoveItem.ErrorAction = 'Continue' ; 
        $smsg= "-GracefulFail specified, using EA:'Continue'" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
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

#*------v remove-JsonComments.ps1 v------
Function Remove-JsonComments{ 
    <#
    .SYNOPSIS
    Remove-JsonComments.ps1 - Removes \\Comments from JSON, to permit ConvertFrom-JSON in ps5.1, to properly process json (PsCv7 ConvertFrom-JSON handles wo issues).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-05
    FileName    : Remove-JsonComments.ps1
    License     : (none-asserted)
    Copyright   : (none-asserted)
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell
    AddedCredit : Paul Harrison
    AddedWebsite:	https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/parsing-json-with-powershell/ba-p/2768721
    AddedTwitter:	URL
    REVISIONS
    * 1:37 PM 10/5/2021 added CBH, and minor formatting. 
    * Sep 20 2021 02:25 PM PaulH's posted version
    .DESCRIPTION
    Remove-JsonComments.ps1 - Removes \\Comments from JSON, to permit ConvertFrom-JSON in ps5.1, to properly process json (PsCv7 ConvertFrom-JSON handles comments wo issues).
    Comments will prevent ConvertFrom-Json from working properly in PowerShell 5.1.  I like to use this simple function to fix my JSON for me. 
    .PARAMETER  File
[string] The JSON file from which to remove \\Comments.[-File c:\path-to\file.json]
    .EXAMPLE
    PS> Remove-Comments .\test.json 
    .LINK
    https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/parsing-json-with-powershell/ba-p/2768721
    .LINK
    https://github.com/tostka/verb-IO
    #>
    PARAM( 
        [CmdletBinding()] 
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0,HelpMessage="[string] The JSON file from which to remove \\Comments.[-File c:\path-to\file.json]")] 
        [ValidateScript({test-path $_})] 
        [string] $File 
    )  ; 
    $CComments = "(?s)/\\*.*?\\*/"  ; 
    $content = Get-Content $File -Raw  ; 
    [regex]::Replace($content,$CComments,"") | Out-File $File -Force  ; 
}

#*------^ remove-JsonComments.ps1 ^------

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
    * 8:15 AM 7/27/2021 sub'd in $rgxQ for duped rgx
    * 4:37 PM 2/27/2020 updated CBH
    # 8:46 AM 3/15/2017 Remove-PSTitleBar: initial version
    # 11/12/2014 - posted version
    .DESCRIPTION
    Remove-PSTitleBar.ps1 - Append specified string to the end of the powershell console Titlebar
    Inspired by dsolodow's Update-PSTitleBar code
    .PARAMETER Tag
    Tag string to be removed to current powershell console Titlebar (supports regex syntax)
    .EXAMPLE
    Remove-PSTitleBar 'EMS'
    Add the string 'EMS' to the powershell console Title Bar
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    [CmdletBinding()]
    Param (
        #[parameter(Mandatory = $true,Position=0)][String]$Tag
        [parameter(Mandatory = $true,Position=0)]$Tag,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    )
    $showDebug=$true ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    write-verbose "`$Tag:`n$(($Tag|out-string).trim())" ; 
    $rgxRgxOps = [regex]'[\[\]\\\{\}\+\*\?\.]+' ; 
    #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        if($Tag -is [system.array]){ 
            foreach ($Tg in $Tag){
                if($Tg -notmatch $rgxRgxOps){
                    $rgxQ = "\s$([Regex]::Escape($Tg))\s" ; 
                } else { 
                    $rgxQ = "\s$($Tg)\s" ; # assume it's already a regex, no manual escape
                }; 
                write-verbose "`$rgxQ:$($rgxQ)" ; 
                if($host.ui.RawUI.WindowTitle  -match $rgxQ){
                    if(-not($whatif)){
                        write-verbose "update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle -replace $rgxQ,''|out-string).trim())" ; 
                        #$host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle.replace(" $Tg ","") ;
                        $host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle -replace $rgxQ,'' ;
                    } else { 
                        write-host "update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle -replace $rgxQ,''|out-string).trim())" ; 
                    } ; 
                }else{
                    write-verbose "(unable to match '$($rgxQ)' to `$host.ui.RawUI.WindowTitle`n`$($host.ui.RawUI.WindowTitle)')" ;
                } ;
            }
        } else { 
            if($Tag -notmatch $rgxRgxOps){
                $rgxQ = "\s$([Regex]::Escape($Tag))\s" ; 
            } else { 
                $rgxQ = "\s$($Tag)\s" ; # assume it's already a regex, no manual escape
            }; 
            write-verbose "`$rgxQ:$($rgxQ)" ; 
            if($host.ui.RawUI.WindowTitle -match $rgxQ){
                if(-not($whatif)){
                    write-verbose "update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle -replace $rgxQ,''|out-string).trim())" ; 
                    #$host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle.replace(" $Tag ","") ;
                    $host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle -replace $rgxQ,'' ;
                }else{
                    write-host "-whatif:update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle.replace(" $Tag ",'')|out-string).trim())" ; 
                } ;
            }else{
                write-verbose "(unable to match '$($rgxQ)' to `$host.ui.RawUI.WindowTitle`n`'$($host.ui.RawUI.WindowTitle)')" ;
            } ;
        } ; 
        rebuild-PSTitleBar -verbose:$($VerbosePreference -eq "Continue") -whatif:$($whatif);
    } ;
}

#*------^ Remove-PSTitleBar.ps1 ^------

#*------v Remove-ScheduledTaskLegacy.ps1 v------
Function Remove-ScheduledTaskLegacy {
    <#
    .SYNOPSIS
    Remove-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    .NOTES
    Author: Hugo @ peeetersonline
    Website:	http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    Tweaked By: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    REVISIONS   :
    * 7:27 AM 12/2/2020 re-rename '*-ScheduledTaskCmd' -> '*-ScheduledTaskLegacy', L13 copy still had it, it's more descriptive as well.
    * 8:13 AM 11/24/2020 renamed to '*-ScheduledTaskCmd', to remove overlap with ScheduledTasks module
    * 8:06 AM 4/18/2017 comment: Invoke-Expression is unnecessary. You can simply state: schtasks.exe /query /s $ComputerName
    * 7:42 AM 4/18/2017 tweaked, added pshelp, comments etc, put into OTB
    * June 4, 2009 posted version
    .DESCRIPTION
    Get-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    Allows you to manage queryingscheduled tasks on one or more computers remotely.
    The functions use schtasks.exe, which is included in Windows. Unlike the Win32_ScheduledJob WMI class, the schtasks.exe commandline tool will show manually created tasks, as well as script-created ones. The examples show some, but not all parameters in action. I think the parameter names are descriptive enough to figure it out, really. If not, take a look at schtasks.exe /?. One tip: try piping a list of computer names to foreach-object and into this function.
    .PARAMETER  ComputerName
    Computer Name [-ComputerName server]
    .PARAMETER TaskName
    Name of Task being targeted
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns object summary of matched task(s)
    .EXAMPLE
    Remove-ScheduledTaskLegacy -ComputerName Server01 -TaskName MyTask
    .LINK
    http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    #>
    param(
        [string]$ComputerName = "localhost",
        [string]$TaskName = "blank"
    ) ;
    If ((Get-ScheduledTaskLegacy -ComputerName $ComputerName) -match $TaskName) {
        If ((Read-Host "Are you sure you want to remove task $TaskName from $ComputerName(y/n)") -eq "y") {
            #$Command = "schtasks.exe /delete /s $ComputerName /tn $TaskName /F" ;
            #Invoke-Expression $Command ;
            #Clear-Variable Command -ErrorAction SilentlyContinue ;
            schtasks.exe /delete /s $ComputerName /tn $TaskName /F
        } ;
    }
    else {
        Write-Warning "Task $TaskName not found on $ComputerName" ;
    } ;
}

#*------^ Remove-ScheduledTaskLegacy.ps1 ^------

#*------v remove-UnneededFileVariants.ps1 v------
function remove-UnneededFileVariants {
    <#
    .SYNOPSIS
    remove-UnneededFileVariants.ps1 - Collect a set of files at -path & -include (filename), then post-filter matching -pattern, and keep the most recent -Keep generations of the files, as sorted and filtered on CreationTime|LastWriteTime (as specified by FilterOn specification)
    .NOTES
    Version     : 1.0.
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 1:43 PM 11/16/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 7:28 PM 11/6/2021 added missing $population = $population reassign post filtering (prevented filter reduction form occuring at all)
    * 9:58 AM 9/21/2021 rem'd retry loop
    * 12:34 PM 9/20/2021  init
    .DESCRIPTION
    remove-UnneededFileVariants.ps1 - Collect a set of files at -path & -include (filename), then post-filter matching -pattern, and keep the most recent -Keep generations of the files, as sorted and filtered on CreationTime|LastWriteTime (as specified by FilterOn specification)
    .PARAMETER  Path
    Path to script
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS> $whatif=$true ;
    PS> $pltRGens =[ordered]@{
            Path = 'C:\sc\verb-auth\' ;
            Include ='process-NewModule-verb-auth-LOG-BATCH-EXEC-*-log.txt' ;
            Pattern = 'verb-\w*\.ps(m|d)1_\d{8}-\d{3,4}(A|P)M' ;
            FilterOn = 'CreationTime' ;
            Keep = 2 ;
            KeepToday = $true ;
            verbose=$true ;
            whatif=$($whatif) ;
        } ; 
    PS> write-host -foregroundcolor green "remove-UnneededFileVariants w`n$(($pltRGens|out-string).trim())" ; 
    PS> remove-UnneededFileVariants @pltRGens ;
    Splatted call example: remove all variant -include-named files in -Path, post-filtered matching -Pattern, retaining items with CreationTime after midnight today, and then retain most recent 2 files (net of prior filtering), as sorted on CreationTime.
    .LINK
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, HelpMessage = "Path to directory[-Path path-to\]")]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]$Path,
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "File Name include wildcard filter to match files [-Include  'process-NewModule-verb-auth-LOG-BATCH-EXEC-*-log.txt']")]
        [string]$include,
        [Parameter(Position = 1, HelpMessage = "File Name Regex to post-filter match files [-Pattern  'verb-\w*\.ps(m|d)1_\d{8}-\d{3,4}(A|P)M']")]
        [string]$Pattern,
        [Parameter(Position = 1, HelpMessage = "Specifies whether sorts & filtering target CreationTime or LastWriteTime of target files (defaults to CreationTime)[-FilterOn  'CreationTime']")]
        [ValidateSet('CreationTime','LastWriteTime')]
        [string]$FilterOn='CreationTime',
        [Parameter(Position = 2, Mandatory = $True, HelpMessage = "Generations to Keep[-Keep 2]")]
        [int] $Keep,
        [Parameter(HelpMessage = "Datetime that enforce retention of files with CreationTime or LastWriteTime (as specified by FilterOn), after specified datetime [-KeepAfter [datetime]::today]")]
        [datetime] $KeepAfter,
        [Parameter(HelpMessage = "Switch that enforce retention of files with CreationTime or LastWriteTime (as specified by FilterOn), after midnight today [-KeepToday]")]
        [switch] $KeepToday,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    $verbose = ($VerbosePreference -eq "Continue") ; 
    $pltGci = [ordered]@{
        path = "$(join-path -path $Path -childpath '*')" ; # include relies on trailing * on path (or -Recurse, which returns subdirs)
        #Recurse = $true ;
        include = $include ; 
        ErrorAction="Stop" ;
    } ;
    $smsg = "gci w`n$(($pltGci|out-string).trim())" ;
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    $Exit = 0 ;
    if($KeepToday){
        $cuttime = [datetime]::today ; # midnight today
    } elseif($KeepAfter){
        $cuttime = (get-date $KeepAfter) # specific time specified - if a date is spec'd it comes through as 12:00 AM that day 
    } ; 
    if($cuttime){
        write-verbose "`$cuttime:$($cuttime)" ; 
    } ; 
    TRY {
        $initialpop = $population = get-childitem @pltGci ; # our pool of files to purge (cached original & working set)
        if($pattern){
            $smsg = "post-filtering on pattern:$($pattern)" ;
            $smsg += "`n($(($population|measure).count) in set *before* filtering)"
            $population = $population | ?{$_.name -match $pattern} 
            $smsg += "`n($(($population|measure).count) in set *after* filtering)"
            write-verbose $smsg ;
        } ; 
        if($cuttime){
            $smsg = "filtering on files prior to `$cuttime:$((get-date $cuttime).tostring('MM/dd/yyyy HH:mm:ss tt')), on $($FilterOn) property" ;
            $smsg += "`n($(($population|measure).count) in set *before* filtering)"

            switch($FilterOn){
                'CreationTime'{
                    $population = $population | ?{$_.CreationTime -lt $cuttime } | 
                        sort-object CreationTime -Descending  ;
                }
                'LastWriteTime' {
                    $population = $population | ?{$_.LastWriteTime -lt $cuttime  } | 
                        sort-object LastWriteTime -Descending  ;
                } ; 
            } ;
            $smsg += "`n($(($population|measure).count) in set *after* filtering)"
            write-verbose $smsg ;
            
        } ; 
        $smsg = "attempting to retain remaining $($Keep) generations net of prior filtering" ;
        $smsg += "`n($(($population|measure).count) in set *before* filtering)"
        $population = $population | select-object -skip $Keep ; 
        $smsg += "`n($(($population|measure).count) in set *after* filtering)"
        if(($population|measure).count -lt $Keep){
            $smsg += "`n(Note:net population is *below* target -Keep:$($Keep) spec - insufficient older files available)" ; 
        } ; 
        write-verbose $smsg ;
        
        
        # $initialpop = $population
        $smsg = "Reducing matched population from $(($initialpop|measure).count) to $(($population|measure).count) files via:" ; 
        if($pattern){
            $smsg += "`npost-filtered files with regex pattern:$($pattern)" ; 
        } ;
        if($cuttime){
            $smsg += "`nfiltered files on $($filteron) prior to $((get-date $cuttime).tostring('MM/dd/yyyy HH:mm:ss tt'))" ; 
        } ; 
        
        
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

      
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #-=-record a STATUSWARN=-=-=-=-=-=-=
        $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
        if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
        if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
        #-=-=-=-=-=-=-=-=
        $smsg = "FULL ERROR TRAPPED (EXPLICIT CATCH BLOCK WOULD LOOK LIKE): } catch[$($ErrTrapd.Exception.GetType().FullName)]{" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level ERROR } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
    } ; 
    

    if($population){
    
        $pltRItm = [ordered]@{
            path=$population.fullname ; 
            whatif=$($whatif) ;
        } ; 
        
        $smsg = "Remove-Item w `n$(($pltRItm|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY {
            Remove-Item @pltRItm ;
            $true | write-output ; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #-=-record a STATUSWARN=-=-=-=-=-=-=
            $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
            if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
            if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
            #-=-=-=-=-=-=-=-=
            $smsg = "FULL ERROR TRAPPED (EXPLICIT CATCH BLOCK WOULD LOOK LIKE): } catch[$($ErrTrapd.Exception.GetType().FullName)]{" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level ERROR } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

            $false | write-output ; 

            Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ; 
    } else { 
        $smsg = "There are *no* files to be removed, as per the specified inputs. (`$population:$(($population|measure).count))" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 

    $Exit = $Retries ;

}

#*------^ remove-UnneededFileVariants.ps1 ^------

#*------v replace-PSTitleBarText.ps1 v------
Function replace-PSTitleBarText {
    <#
    .SYNOPSIS
    replace-PSTitleBarText.ps1 - replaced specified text string in powershell console Titlebar with updated text
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : replace-PSTitleBarText.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    AddedCredit : mdjxkln
    AddedWebsite:	https://xkln.net/blog/putting-the-powershell-window-title-to-better-use/
    REVISIONS
   * 7:47 AM 7/26/2021init vers
    .DESCRIPTION
    replace-PSTitleBarText.ps1 - replace-PSTitleBarText.ps1 - replaced specified text string in powershell console Titlebar with updated text
    .PARAMETER Title
    Title string to be set on current powershell console Titlebar
    .EXAMPLE
    replace-PSTitleBarText -text ([Environment]::UserDomainName) -replace "$([Environment]::UserDomainName)-EMS" -whatif
    Replace title previously set with: ("PS ADMIN - " + [Environment]::UserDomainName), to "Domain-EMS - "
    .EXAMPLE
    replace-PSTitleBarText -text 'PS ADMIN' -replace 'PS ADMIN-EMS' -whatif -verbose
    replace title PS ADMIN string with PS ADMIN-EMS
    .LINK
    https://xkln.net/blog/putting-the-powershell-window-title-to-better-use/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    #[Alias('set-PSTitle')]
    Param (
        [parameter(Mandatory = $true,Position=0,HelpMessage="Title substring to be replaced on current powershell console Titlebar (supports regex syntax)[-title 'Domain'")]
        [String]$Text,
        [parameter(Mandatory = $true,Position=0,HelpMessage="Title substring replace the -Text string with, on current powershell console Titlebar[-Replacement 'Domain-EMS'")]
        [String]$Replacement,
        #[Parameter(HelpMessage="switch to indicate that $Text is a regular expression [-regex]")]
        #[switch] $regex, # not needed -replace seamlessly supports both string & regex (tho' capture grpneed $1, $2 etc, unsupported in this simple variant
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug
    )
    $showDebug=$true ; 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    write-verbose "`$Text:$($Text)" ; 
    write-verbose "`$Replacement:$($Replacement)" ; 
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        #only use on console host; since ISE shares the WindowTitle across multiple tabs
        #$bPresent = $true ;
        if(-not($whatif)){
            write-verbose "update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle -replace $Text,$Replacement|out-string).trim())" ; 
            $host.ui.RawUI.WindowTitle = $host.ui.RawUI.WindowTitle -replace $Text,$Replacement ;
        } else { 
            write-host "update:`$host.ui.RawUI.WindowTitle to`n$(($host.ui.RawUI.WindowTitle -replace $Text,$Replacement|out-string).trim())" ;
        } 
        rebuild-PSTitleBar  -verbose:$($VerbosePreference -eq "Continue") -whatif:$($whatif);
    } ;
}

#*------^ replace-PSTitleBarText.ps1 ^------

#*------v reset-ConsoleColors.ps1 v------
Function reset-ConsoleColors {
    <#
    .SYNOPSIS
    reset-ConsoleColors - reset $Host.UI.RawUI.BackgroundColor & ForegroundColor to default values
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-03-03
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Copyright   : 
    Github      : https://github.com/tostka
    Tags        : Powershell,ExchangeOnline,Exchange,RemotePowershell,Connection,MFA
    REVISIONS   :
    * 1:25 PM 3/5/2021 init ; added support for both ISE & powershell console
    .DESCRIPTION
    reset-ConsoleColors - reset $Host.UI.RawUI.BackgroundColor & ForegroundColor to default values
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    reset-ConsoleColors;
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    #[Alias('dxo')]
    Param() 
    $verbose = ($VerbosePreference -eq "Continue") ; 
    write-verbose "(Issuing `$Host color reset...)" ; 
    # add detection for psReadLine - and version differences (v1 & v2 have fundemental param support syntax - breaaking change)
    if ($psrMod = Get-Module -name PSReadline) {
            switch -regex ($psrMod.version.major){
                "[1]" {
                    Set-PSReadlineOption -ResetTokenColors ; 
                }
                "[2-9]" {
                    # two *lost* the above ResetTokenColors param! doesn't seem to have *any* reset now
                    # you'd literally have to cache & re-assign *every*value!
                    # braindead!
                    write-host "PsReadline v2 *LOST* THE ResetTokenColors cmd. Doesn't seem to have *any* reset to default support anymore!" ; 
                }
               default {
                    throw "Unrecognized PSReadline revision:$($psrMod.version.major)" ; 
               } 
            } ;  # switch-E 

    } else { 
        switch($host.name){
            "Windows PowerShell ISE Host" {
                $psISE.Options.RestoreDefaultTokenColors()
            } 
            "ConsoleHost" {
                [console]::ResetColor()  # reset console colorscheme to default
            }
            default {
                write-warning "Unrecognized `$Host.name:$($Host.name), skipping set-ConsoleColor" ; 
            } ; 
        } ; 
    } ; 
}

#*------^ reset-ConsoleColors.ps1 ^------

#*------v revert-File.ps1 v------
function revert-File {
    <#
    .SYNOPSIS
    revert-File.ps1 - Restore file from prior backup
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2:23 PM 12/29/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
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
    PS> $bRet = revert-File -Source "C:\sc\verb-dev\verb-dev\verb-dev.psm1_20191229-0904AM" -Destination "C:\sc\verb-dev\verb-dev\verb-dev.psm1" -showdebug:$($showdebug) -whatif:$($whatif)
    PS> if (!$bRet) {throw "FAILURE" } ;
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

#*------v Run-ScheduledTaskLegacy.ps1 v------
Function Run-ScheduledTaskLegacy {
    <#
    .SYNOPSIS
    Run-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    .NOTES
    Author: Todd Kadrie
    Website:	http://tinstoys.blogspot.com
    Twitter:	http://twitter.com/tostka
    Based-on code by: Hugo @ peeetersonline
    Website:	http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    REVISIONS   :
    * 7:27 AM 12/2/2020 re-rename '*-ScheduledTaskCmd' -> '*-ScheduledTaskLegacy', L13 copy still had it, it's more descriptive as well.
    * 8:13 AM 11/24/2020 renamed to '*-ScheduledTaskCmd', to remove overlap with ScheduledTasks module
    * 8:15 AM 4/18/2017 write my own run- variant
    * 8:06 AM 4/18/2017 comment: Invoke-Expression is unnecessary. You can simply state: schtasks.exe /query /s $ComputerName
    * 7:42 AM 4/18/2017 tweaked, added pshelp, comments etc
    * June 4, 2009 posted version
    .DESCRIPTION
    Run-ScheduledTaskLegacy - schtasks-wrapped into a ps verb-noun function
    .PARAMETER  ComputerName
    Computer Name [-ComputerName server]
    .PARAMETER TaskName
    Name of Task being targeted
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns object summary of matched task(s)
    .EXAMPLE
    Run-ScheduledTaskLegacy -ComputerName Server01 -TaskName MyTask
    .LINK
    http://www.peetersonline.nl/2009/06/managing-scheduled-tasks-remotely-using-powershell/
    #>
    param(
        [string]$ComputerName = "localhost",
        [string]$TaskName = "blank"
    ) ;
    If ((Get-ScheduledTaskLegacy -ComputerName $ComputerName) -match $TaskName) {
        #If ((Read-Host "Are you sure you want to remove task $TaskName from $ComputerName(y/n)") -eq "y") {
        #$Command = "schtasks.exe /delete /s $ComputerName /tn $TaskName /F" ;
        #Invoke-Expression $Command ;
        #Clear-Variable Command -ErrorAction SilentlyContinue ;
        # SCHTASKS /Run /S system /U user /P password /I /TN "Backup and Restore"
        schtasks.exe /Run /s $ComputerName /tn $TaskName ;
        #} ;
    }
    else {
        Write-Warning "Task $TaskName not found on $ComputerName" ;
    } ;
}

#*------^ Run-ScheduledTaskLegacy.ps1 ^------

#*------v Save-ConsoleOutputToClipBoard.ps1 v------
function Save-ConsoleOutputToClipBoard {
    <#
    .SYNOPSIS
    Save-ConsoleOutputToClipBoard.ps1 - 1LINEDESC
    .NOTES
    Author: Adam Bertrand
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	http://www.adamtheautomator.com/
    Twitter:	@adbertram
    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 5/14/2019 posted version
    .DESCRIPTION
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    Save-ConsoleOutputToClipBoard.ps1 
    Save current console output to clipboard.
    .LINK
    https://gist.github.com/adbertram/4e4bf0ba5f876ed474f90534520cf2e2
    #>

    [OutputType('string')]
    [CmdletBinding()]
    param () ;
    <#if ($host.Name -ne -ConsoleHost-) {
        write-host -ForegroundColor Red "This script runs only in the console host. You cannot run this script in $($host.Name)." ;
    } ;#>

    # Initialize string builder.
    $textBuilder = new-object system.text.stringbuilder ;

    # Grab the console screen buffer contents using the Host console API.
    $bufferWidth = $host.ui.rawui.BufferSize.Width
    $bufferHeight = $host.ui.rawui.CursorPosition.Y

    $rec = new-object System.Management.Automation.Host.Rectangle 0, 0, ($bufferWidth - 1), $bufferHeight ;
    $buffer = $host.ui.rawui.GetBufferContents($rec) ;

    # Iterate through the lines in the console buffer.
    for ($i = 0; $i -lt $bufferHeight; $i++) {
        for ($j = 0; $j -lt $bufferWidth; $j++) {
            $cell = $buffer[$i, $j] ;
            $null = $textBuilder.Append($cell.Character) ;
        } ;
        $null = $textBuilder.Append("`r`n") ;
    } ;

    ## Ensure the PS prompt is always just PS>
    $out = $textBuilder.ToString() -replace 'PS .*\>', 'PS>' ;

    ## Remove the line that actually invoked this function
    $out -replace "PS> $($MyInvocation.MyCommand.Name)" | Set-Clipboard ;
}

#*------^ Save-ConsoleOutputToClipBoard.ps1 ^------

#*------v select-first.ps1 v------
function select-first {
    <#
    .SYNOPSIS
    select-first.ps1 - functionalized 'Select-Object -first $n' 
    .NOTES
    Version     : 1.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-13
    FileName    : select-first.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,FileSystem,Shortcut,Link
    AddedCredit : tonymcgee
    AddedWebsite: https://www.tonymcgee.net/2013/11/powershell-profile-snippets/
    REVISIONS
    * 8:20 AM 5/4/2021 had in xxx-prof.ps1, wasn't replicated out to other admin profiles, so stick it in verb-io    
    * 11/2013 tonymcgee's posted vers
    .DESCRIPTION
    select-first.ps1 - functionalized 'Select-Object -first $n' 
    .PARAMETER  n
    count of pipline items to be returned
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    PSCustomObject
    .EXAMPLE
    PS > $object | select-first ; 
    Example using default settings (returns first object from pipeline)
    .EXAMPLE
    PS > $object | select-first -n 5; 
    Example returning first 5 objects from pipeline
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://www.tonymcgee.net/2013/11/powershell-profile-snippets/
    #>
    # cmdletbinding breaks default pipeline, and causes err:' The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or the input and its properties do not match any of the parameters that take pipeline input'
    #[CmdletBinding()]
    PARAM([int] $n=1) ;
    $Input | Select-Object -first $n ; 
}

#*------^ select-first.ps1 ^------

#*------v select-last.ps1 v------
function Select-last {
    <#
    .SYNOPSIS
    Select-last.ps1 - functionalized 'Select-Object -last $n' 
    .NOTES
    Version     : 1.0.1
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-13
    FileName    : Select-last.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,FileSystem,Pipeline
    AddedCredit : tonymcgee
    AddedWebsite: https://www.tonymcgee.net/2013/11/powershell-profile-snippets/
    REVISIONS
    * 8:20 AM 5/4/2021 had in xxx-prof.ps1, wasn't replicated out to other admin profiles, so stick it in verb-io    
    * 11/2013 tonymcgee's posted vers
    .DESCRIPTION
    Select-last.ps1 - functionalized 'Select-Object -last $n' 
    .PARAMETER  n
    count of pipline items to be returned
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    PSCustomObject
    .EXAMPLE
    PS > $object | Select-last ; 
    Example using default settings (returns last object from pipeline)
    .EXAMPLE
    PS > $object | Select-last -n 5; 
    Example returning last 5 objects from pipeline
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://www.tonymcgee.net/2013/11/powershell-profile-snippets/
    #>
    # cmdletbinding breaks default pipeline, and causes err:' The input object cannot be bound to any parameters for the command either because the command does not take pipeline input or the input and its properties do not match any of the parameters that take pipeline input'
    #[CmdletBinding()]
    PARAM([int] $n=1) ;
    $Input | Select-Object -last $n ;
}

#*------^ select-last.ps1 ^------

#*------v Select-StringAll.ps1 v------
Function Select-StringAll {

    <#
    .SYNOPSIS
    Select-StringAll.ps1 - Finds text in strings and files using CONJUNCTIVE logic. That is, Select-StringAll requires that all patterns passed to it - whether they're regexes (by default) or literals (with -SimpleMatch) - match a line.
    .NOTES
    Version     : 1.0.0
    Author      : Michael Klement <mklement0@gmail.com>
    Website     :	https://github.com/mklement0/
    Twitter     :	
    CreatedDate : 2021-10-12
    FileName    : Select-StringAll.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 12:37 PM 10/25/2021 rem'd req version
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    Select-StringAll.ps1 - Finds text in strings and files using CONJUNCTIVE logic.
    Select-StringAll.ps1 - Finds text in strings and files using CONJUNCTIVE logic. That is, Select-StringAll requires that all patterns passed to it - whether they're regexes (by default) or literals (with -SimpleMatch) - match a line.
    This function is a wrapper around Select-String that applies CONJUNCTIVE logic
    to the search terms passed to parameter Pattern.
    That is, each input line must match ALL patterns, in any order.
    This is in contrast with Select-String, where ANY pattern matching is considered
    an overall match.
    In all other respects, this function behaves like Select-String, except:
     * Given that *all* patterns must match, the -AllMatches switch makes no sense
       and therefore isn't supported.
     * Use .Line on the output objects to obtain the matching input line in full.
     * The .Matches property contains no useful information - unless you use capture
       groups around the patterns, i.e. you enclose them in (...) - except with -SimpleMatch.
    See Select-String's help for details.

    .PARAMETER InputObject
Specifies the text to be searched. Enter a variable that contains the text, or type a command or expression that gets the text.

Using the InputObject parameter isn't the same as sending strings down the pipeline to `Select-String`.

When you pipe more than one string to the `Select-String` cmdlet, it searches for the specified text in each string and returns each string that contains the search text.

When you use the InputObject parameter to submit a collection of strings, `Select-String` treats the collection as a single combined string. `Select-String` returns the strings as a unit if it finds the search text in any string.
.PARAMETER Pattern
Specifies the text to find on each line. The pattern value is treated as a regular expression.
To learn about regular expressions, see about_Regular_Expressions (../Microsoft.PowerShell.Core/About/about_Regular_Expressions.md).
.PARAMETER Path
Specifies the path to the files to search. Wildcards are permitted. The default location is the local directory.
Specify files in the directory, such as `log1.txt`, ` .doc`, or ` .*`. If you specify only a directory, the command fails.
.PARAMETER LiteralPath
Specifies the path to the files to be searched. The value of the LiteralPath parameter is used exactly as it's typed. No characters are interpreted as wildcards. If the path includes escape characters, enclose it in single quotation marks. Single quotation marks tell PowerShell not to interpret any
characters as escape sequences. For more information, see about_Quoting_Rules (../Microsoft.Powershell.Core/About/about_Quoting_Rules.md).
.PARAMETER SimpleMatch
.PARAMETER CaseSensitive
Indicates that the cmdlet matches are case-sensitive. By default, matches aren't case-sensitive.
.PARAMETER Quiet
.PARAMETER List
Only the first instance of matching text is returned from each input file. This is the most efficient way to retrieve a list of files that have contents matching the regular expression.

By default, `Select-String` returns a MatchInfo object for each match it finds.
.PARAMETER Include
Includes the specified items. The value of this parameter qualifies the Path parameter. Enter a path element or pattern, such as `*.txt`. Wildcards are permitted.
.PARAMETER Exclude
Exclude the specified items. The value of this parameter qualifies the Path parameter. Enter a path element or pattern, such as `*.txt`. Wildcards are permitted.
.PARAMETER NotMatch
.PARAMETER Encoding
Specifies the type of encoding for the target file. The default value is `default`.

The acceptable values for this parameter are as follows:

- `ascii` Uses ASCII (7-bit) character set.

- `bigendianunicode` Uses UTF-16 with the big-endian byte order.

- `default` Uses the encoding that corresponds to the system's active code page (usually ANSI).

- `oem` Uses the encoding that corresponds to the system's current OEM code page.

- `unicode` Uses UTF-16 with the little-endian byte order.

- `utf7` Uses UTF-7.

- `utf8` Uses UTF-8.

- `utf32` Uses UTF-32 with the little-endian byte order.

.PARAMETER Context
Captures the specified number of lines before and after the line that matches the pattern.

If you enter one number as the value of this parameter, that number determines the number of lines captured before and after the match. If you enter two numbers as the value, the first number determines the number of lines before the match and the second number determines the number of lines after the
match. For example, `-Context 2,3`.

In the default display, lines with a match are indicated by a right angle bracket (`>`) (ASCII 62) in the first column of the display. Unmarked lines are the context.

The Context parameter doesn't change the number of objects generated by `Select-String`. `Select-String` generates one MatchInfo (/dotnet/api/microsoft.powershell.commands.matchinfo)object for each match. The context is stored as an array of strings in the Context property of the object.

When the output of a `Select-String` command is sent down the pipeline to another `Select-String` command, the receiving command searches only the text in the matched line. The matched line is the value of the Line property of the MatchInfo object, not the text in the context lines. As a result, the
Context parameter isn't valid on the receiving `Select-String` command.

When the context includes a match, the MatchInfo object for each match includes all the context lines, but the overlapping lines appear only once in the display.
    .OUTPUT
    decimal size in converted decimal unit.
    .EXAMPLE
    PS> (Get-ChildItem -File -Filter *.abc -Recurse |
        Select-StringAll -SimpleMatch word1, word2, word3).Count
    Example searching for files with extension .abc, recursively, with word1, word2, or word3, appearing in any order.
    .LINK
    Select-String
    .LINK
    https://gist.github.com/mklement0/356acffc2521fdd338ef9d6daf41ef07
    .LINK
    https://github.com/tostka/verb-IO
    #>
    ##requires -version 3
    #[Alias('convert-
    [CmdletBinding(DefaultParameterSetName='File')]
  param(
      [Parameter(ParameterSetName='Object', Mandatory, ValueFromPipeline)]
      [psobject] ${InputObject},

      [Parameter(Mandatory, Position=0)]
      [string[]] ${Pattern},

      [Parameter(ParameterSetName='File', Mandatory, Position=1, ValueFromPipelineByPropertyName)]
      [string[]] ${Path},

      [Parameter(ParameterSetName='LiteralFile', Mandatory, ValueFromPipelineByPropertyName)]
      [Alias('PSPath')]
      [string[]] ${LiteralPath},

      [switch] ${SimpleMatch},

      [switch] ${CaseSensitive},

      [switch] ${Quiet},

      [switch] ${List},

      [ValidateNotNullOrEmpty()]
      [string[]] ${Include},

      [ValidateNotNullOrEmpty()]
      [string[]] ${Exclude},

      [switch] ${NotMatch},

      [ValidateNotNullOrEmpty()]
      [ValidateSet('unicode','utf7','utf8','utf32','ascii','bigendianunicode','default','oem')]
      [string] ${Encoding},

      [ValidateRange(0, 2147483647)]
      [ValidateNotNullOrEmpty()]
      [ValidateCount(1, 2)]
      [int[]] ${Context}
    )
    BEGIN{
      TRY {

          # Prepare the individual patterns:
          if ($SimpleMatch) {
            # If the patterns are literals, we must escape them for use
            # as such in a regex.
            $regexes = $Pattern.ForEach({ [regex]::Escape($_) }) ; 
            # Remove the -SimpleMatch switch, because we're translating
            # the patterns into a regex.
            $null = $PSBoundParameters.Remove('SimpleMatch') ; 
          } else {
            # Patterns are already regexes? Use them as-is.
            $regexes = $Pattern ; 
          } ; 
        
          # To apply conjunctive logic, juxtapose lookahead assertions for
          # all patterns and make the expression match the whole line.
          # (While that's not strictly necessary, given that we're 
          # precluding -AllMatches, it makes for more predictable outcome,
          # because the '.*$' part then captures the entire line and reflects
          # it in the output objects' .Matches property.)
          $PSBoundParameters['Pattern'] = (-join $regexes.ForEach({ '(?=.*?' + $_ + ')' })) ; 

          Write-Verbose "Conjunctive compound regex: $($PSBoundParameters['Pattern'])" ; 

          $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Select-String', [System.Management.Automation.CommandTypes]::Cmdlet) ; 
          $scriptCmd = {& $wrappedCmd @PSBoundParameters } ; 
          $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin) ; 
          $steppablePipeline.Begin($PSCmdlet) ; 
      } CATCH {
          $PSCmdlet.ThrowTerminatingError($_) ; 
      } ; 
  } # BEG-E
  PROCESS{
    $steppablePipeline.Process($_) ; 
  } ; 
  END{
    $steppablePipeline.End() ; 
  } ; 
}

#*------^ Select-StringAll.ps1 ^------

#*------v set-ConsoleColors.ps1 v------
Function set-ConsoleColors {
    <#
    .SYNOPSIS
    set-ConsoleColors.ps1 - Converts a PowerShell object to a Markdown table.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2021-01-20
    FileName    : set-ConsoleColors.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Markdown,Output
    REVISION
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 11:41 AM 9/16/2021 string
    * 1:25 PM 3/5/2021 init ; added support for both ISE & powershell console
    .DESCRIPTION
    set-ConsoleColors.ps1 - Converts a PowerShell object to a Markdown table.
    Use reset-ConsoleColors to reset colors to the configured $host/Console defaults
    Use 
    .PARAMETER BackgroundColor
    Powershell Host colorname to be set as BackgroundColor
    .PARAMETER ForegroundColor
    Powershell Host colorname to be set as ForegroundColor
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    String
    .EXAMPLE
    set-ConsoleColors -BackgroundColor DarkMagenta -ForegroundColor DarkYellow
    Set console/host color scheme to match the default Powershell colors
    .EXAMPLE
    PS> $colors = get-colorcombo -Combo 69 ; 
    PS> set-ConsoleColors @colors -verbose ; 
    Leverage the verb-IO:get-colorcombo() to pull & set the default scheme
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('set-ConsColor')]
    Param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage="Powershell Host colorname to be set as BackgroundColor[-BackgroundColor darkgray]")]
        [ValidateSet('Black','DarkBlue','DarkGreen','DarkCyan','DarkRed','DarkMagenta','DarkYellow','Gray','DarkGray','Blue','Green','Cyan','Red','Magenta','Yellow','White')]
        [string]$BackgroundColor,
        [Parameter(Mandatory = $true, Position = 1, HelpMessage="Powershell Host colorname to be set as ForegroundColor[-ForegroundColor darkgray]")]
        [ValidateSet('Black','DarkBlue','DarkGreen','DarkCyan','DarkRed','DarkMagenta','DarkYellow','Gray','DarkGray','Blue','Green','Cyan','Red','Magenta','Yellow','White')]
        [string] $ForegroundColor
    ) ;
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
    } ;
    PROCESS {
        write-verbose "(setting console colors:BackgroundColor:$($BackgroundColor),ForegroundColor:$($ForegroundColor))" ; 
        if ($psrMod = Get-Module -name PSReadline) {
            switch -regex ($psrMod.version.major){
                "[1]" {
                    <# 
                        -BackgroundColor <ConsoleColor>     Specifies the background color for the token kind that is specified by the TokenKind parameter.
                        -ForegroundColor <ConsoleColor>     Specifies the foreground color for the token kind that is specified by the TokenKind parameter.
                        -ResetTokenColors [<SwitchParameter>] Indicates that this cmdlet restores token colors to default settings.
                        -ContinuationPrompt <String>     Specifies the string displayed at the start of the second and subsequent lines when multi-line input is being entered. The default value is '>>>'. The empty string is valid.
                        -ContinuationPromptBackgroundColor <ConsoleColor>     Specifies the background color of the continuation prompt.
                        -ContinuationPromptForegroundColor
                        -EmphasisBackgroundColor <ConsoleColor>     Specifies the background color that is used for emphasis, such as to highlight search text.      The acceptable values for this parameter are: the same values as for BackgroundColor .         
                        -EmphasisForegroundColor <ConsoleColor>
                        -ErrorBackgroundColor
                        -ResetTokenColors [<SwitchParameter>]     Indicates that this cmdlet restores token colors to default settings.
                        -TokenKind Specifies the kind of token when you are setting token coloring options with the ForegroundColor and BackgroundColor parameters. The acceptable values for this parameter are: [None|Comment|Keyword|String|Operator|Variable|Command|Parameter|Type|Number|Member]
                        # use of BackgroundColor,ForegroundColor w TokenKind
                        Set-PSReadlineOption -TokenKind Comment -ForegroundColor Green -BackgroundColor Gray
                        # gonna take a stack of repeated Set-PSReadlineOption, clearly can't hybrid everything in a single hash like v2
                        get-PSReadLineOption | fl *
                        EditMode                               : Windows
                        ContinuationPrompt                     : >>
                        ContinuationPromptForegroundColor      : DarkYellow
                        ContinuationPromptBackgroundColor      : DarkMagenta
                        ExtraPromptLineCount                   : 0
                        AddToHistoryHandler                    :
                        CommandValidationHandler               :
                        CommandsToValidateScriptBlockArguments : {ForEach-Object, %, Invoke-Command, icm...}
                        HistoryNoDuplicates                    : False
                        MaximumHistoryCount                    : 4096
                        MaximumKillRingCount                   : 10
                        HistorySearchCursorMovesToEnd          : False
                        ShowToolTips                           : False
                        DingTone                               : 1221
                        CompletionQueryItems                   : 100
                        WordDelimiters                         : ;:,.[]{}()/\|^&*-=+'"â€“â€”â€•
                        DingDuration                           : 50
                        BellStyle                              : Audible
                        HistorySearchCaseSensitive             : False
                        ViModeIndicator                        : None
                        HistorySavePath                        : $($ENV:USERPROFILE)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt
                        HistorySaveStyle                       : SaveIncrementally
                        DefaultTokenForegroundColor            : DarkYellow
                        CommentForegroundColor                 : DarkGreen
                        KeywordForegroundColor                 : Green
                        StringForegroundColor                  : DarkCyan
                        OperatorForegroundColor                : DarkGray
                        VariableForegroundColor                : Green
                        CommandForegroundColor                 : Yellow
                        ParameterForegroundColor               : DarkGray
                        TypeForegroundColor                    : Gray
                        NumberForegroundColor                  : White
                        MemberForegroundColor                  : White
                        DefaultTokenBackgroundColor            : DarkMagenta
                        CommentBackgroundColor                 : DarkMagenta
                        KeywordBackgroundColor                 : DarkMagenta
                        StringBackgroundColor                  : DarkMagenta
                        OperatorBackgroundColor                : DarkMagenta
                        VariableBackgroundColor                : DarkMagenta
                        CommandBackgroundColor                 : DarkMagenta
                        ParameterBackgroundColor               : DarkMagenta
                        TypeBackgroundColor                    : DarkMagenta
                        NumberBackgroundColor                  : DarkMagenta
                        MemberBackgroundColor                  : DarkMagenta
                        EmphasisForegroundColor                : Cyan
                        EmphasisBackgroundColor                : DarkMagenta
                        ErrorForegroundColor                   : Red
                        ErrorBackgroundColor                   : DarkMagenta
                    #>
                    # bgs
                    Set-PSReadlineOption -TokenKind ContinuationPromptBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind DefaultTokenBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind CommentBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind KeywordBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind StringBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind OperatorBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind VariableBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind CommandBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind ParameterBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind TypeBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind NumberBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind MemberBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind EmphasisBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    Set-PSReadlineOption -TokenKind ErrorBackgroundColor -BackgroundColor [ConsoleColor]::$($BackgroundColor)
                    # fgs
                    Set-PSReadlineOption -TokenKind ContinuationPromptForegroundColor -ForegroundColor [ConsoleColor]::$($ForegroundColor)
                    Set-PSReadlineOption -TokenKind DefaultTokenForegroundColor -ForegroundColor [ConsoleColor]::$($ForegroundColor)
                }
                "[2-9]" {
                    # vers2 refactored, got rid of tokenKind and added explicit bgcolor/bgcolor params for every component
                    <# V2 supports 24bit colors, over orig 16 colors:
                    Set-PSReadLineOption -Colors @{ "Comment"="$([char]0x1b)[32;47m" } 
                    https://docs.microsoft.com/en-us/powershell/module/psreadline/set-psreadlineoption?view=powershell-5.1
                    Colors can be either a value from ConsoleColor, for example [ConsoleColor]::Red, or a valid ANSI escape sequence. Valid escape sequences depend on your terminal. In PowerShell 5.0, an example escape sequence for red text is $([char]0x1b)[91m. In PowerShell 6 and above, the same escape sequence is `e[91m. You can specify other escape sequences including the following types:
                    256 color
                    24-bit color
                    Foreground, background, or both
                    Inverse, bold

                    #>
                    $colors = @{
                      # bgs
                      "ContinuationPromptBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "DefaultTokenBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "CommentBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "KeywordBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "StringBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "OperatorBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "VariableBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "CommandBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "ParameterBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "TypeBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "NumberBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "MemberBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "EmphasisBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      "ErrorBackgroundColor" = [ConsoleColor]::$($BackgroundColor)
                      # fgs
                      "ContinuationPromptForegroundColor" = [ConsoleColor]::$($ForegroundColor)
                      "DefaultTokenForegroundColor" = [ConsoleColor]::$($ForegroundColor)

                      # ConsoleColor enum has all the old colors
                      #"Error" = [ConsoleColor]::DarkRed

                      # A mustardy 24 bit color escape sequence
                      #"String" = "$([char]0x1b)[38;5;100m"

                      # A light slate blue RGB value
                      #"Command" = "#8470FF"
                    } ; 
                    write-verbose "PSReadLineOption detected:Set-PSReadLineOption -Colors`n$(($colors|out-string).trim())" ; 
                    Set-PSReadLineOption -Colors @colors ; 
                }
               default {
               
               } 
           } ;  # switch-E 
            
        } else { 
            switch($host.name){
                "Windows PowerShell ISE Host" {
                    #write-verbose "ISE detected:`$psise.Options.ConsolePaneBackgroundColor`n`$psISE.Options.ConsolePaneTextBackgroundColor`n`$psISE.Options.ConsolePaneForegroundColor"
                    # ise includes an extra TextBackgroundColor variant
                    <# the colors are abberant, don't match the real console colors
                    # and now, doesn't like either raw colornames or [consolecolor] converted codes
                    $psise.Options.ConsolePaneBackgroundColor = [ConsoleColor]::$($BackgroundColor) ;
                    $psISE.Options.ConsolePaneTextBackgroundColor = [ConsoleColor]::$($BackgroundColor) ;
                    $psISE.Options.ConsolePaneForegroundColor =  [ConsoleColor]::$($ForegroundColor) ; 
                    #>
                } 
                "ConsoleHost" {
                    write-verbose "ConsoleHost detected:`$Host.UI.RawUI.BackgroundColor`n`$Host.UI.RawUI.ForegroundColor"
                    $Host.UI.RawUI.BackgroundColor = [ConsoleColor]::$($BackgroundColor) ;
                    $Host.UI.RawUI.ForegroundColor =  [ConsoleColor]::$($ForegroundColor) ; 
                    # legacy admin-color tagging script
                    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent() ;
                    $p = New-Object system.security.principal.windowsprincipal($id) ;
                    # Find out if we're running as admin (IsInRole), If we are, set $Admin = $True. 
                    if ($p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)){$Admin = $True } else {    $Admin = $False } ;
                    if ($Admin) {
                        $effectivename = "Administrator";
                        $host.UI.RawUI.Backgroundcolor="DarkRed";
                        $host.UI.RawUI.Foregroundcolor="White" ;
                        clear-host ; 
                    } else {
                        $effectivename = $id.name ;
                        $host.UI.RawUI.Backgroundcolor="White" ;
                        $host.UI.RawUI.Foregroundcolor="DarkBlue" ;
                        clear-host ;
                    } ; 
                }
                
                <# early win10: variant
                $pData = (Get-Host).PrivateData ;
                $curForeground = [console]::ForegroundColor ;
                $curBackground = [console]::BackgroundColor ;
                # PowerShell v5 uses PSReadLineOptions to do syntax highlighting. 
                # Base the color scheme on the background color 
                If ( $curBackground -eq "White" ) {
                    Set-PSReadLineOption -TokenKind None      -ForegroundColor DarkBlue  -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Comment   -ForegroundColor DarkGray  -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Keyword   -ForegroundColor DarkGreen -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind String    -ForegroundColor Blue      -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Operator  -ForegroundColor Black ;
                    -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Variable  -ForegroundColor DarkCyan  -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Command   -ForegroundColor DarkRed   -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Parameter -ForegroundColor DarkGray  -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Type      -ForegroundColor DarkGray  -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Number    -ForegroundColor Red       -BackgroundColor White ;
                    Set-PSReadLineOption -TokenKind Member    -ForegroundColor DarkBlue  -BackgroundColor White ;
                    $pData.ErrorForegroundColor   = "Red" ;
                    $pData.ErrorBackgroundColor   = "Gray" ;
                    $pData.WarningForegroundColor = "DarkMagenta" ;
                    $pData.WarningBackgroundColor = "White" ;
                    $pData.VerboseForegroundColor = "DarkYellow" ;
                    $pData.VerboseBackgroundColor = "DarkCyan"    
                } elseif ($curBackground -eq "DarkRed") {
                    Set-PSReadLineOption -TokenKind None      -ForegroundColor White    -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Comment   -ForegroundColor Gray     -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Keyword   -ForegroundColor Yellow   -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind String    -ForegroundColor Cyan     -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Operator  -ForegroundColor White    -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Variable  -ForegroundColor Green    -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Command   -ForegroundColor White    -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Parameter -ForegroundColor Gray     -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Type      -ForegroundColor Magenta  -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Number    -ForegroundColor Yellow   -BackgroundColor DarkRed ;
                    Set-PSReadLineOption -TokenKind Member    -ForegroundColor White    -BackgroundColor DarkRed ;
                    $pData.ErrorForegroundColor   = "Yellow" ;
                    $pData.ErrorBackgroundColor   = "DarkRed" ;
                    $pData.WarningForegroundColor = "Magenta" ;
                    $pData.WarningBackgroundColor = "DarkRed" ;
                    $pData.VerboseForegroundColor = "Cyan" ;
                    $pData.VerboseBackgroundColor = "DarkRed" ;  
                } ; 
                #>
 
                default {
                    write-warning "Unrecognized `$Host.name:$($Host.name), skipping set-ConsoleColor" ; 
                } 
            } ; 
        } ; 
    } ;  # PROC-E
    END {} ;
}

#*------^ set-ConsoleColors.ps1 ^------

#*------v Set-FileContent.ps1 v------
function Set-FileContent {
    <#
    .SYNOPSIS
    Set-FileContent - Write output string to specified File
    .NOTES
    Version     : 1.0.0
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
    * 10:35 AM 2/21/2022 CBH example ps> adds 
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
    PS> $bRet = Set-FileContent -Text $updatedContent -Path $outfile -showdebug:$($showdebug) -whatif:$($whatif) ;
    PS> if (!$bRet) {throw "FAILURE" } ;
    .LINK
    https://github.com/tostka/verb-IO
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

#*------v set-PSTitleBar.ps1 v------
Function set-PSTitleBar {
    <#
    .SYNOPSIS
    set-PSTitleBar.ps1 - Set specified powershell console Titlebar
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-04-19
    FileName    : set-PSTitleBar.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    AddedCredit : mdjxkln
    AddedWebsite:	https://xkln.net/blog/putting-the-powershell-window-title-to-better-use/
    REVISIONS
    * 12:12 PM 7/26/2021 rework for verbose & whatif
    * 4:26 PM 7/23/2021 added rebuild-pstitlebar to post cleanup
       * 3:14 PM 4/19/2021 init vers
    .DESCRIPTION
    set-PSTitleBar.ps1 - Set specified powershell console Titlebar
    Added some examples posted by mdjxkln
    .PARAMETER Title
    Title string to be set on current powershell console Titlebar
    .EXAMPLE
    set-PSTitleBar 'EMS'
    Set the string 'EMS' as the powershell console Title Bar
    .EXAMPLE
    if ((Get-History).Count -gt 0) {
        set-PsTitleBar ((Get-History)[-1].CommandLine[0..25] -join '')
    }
    mdjxkln's example to set the title to the last entered command
    .EXAMPLE
    $ExampleArray = @(1..200) ; 
    $ExampleArray | % {
        Write-Host "Processing $_" # Doing some stuff...
        $PercentProcessed = [Math]::Round(($ExampleArray.indexOf($_) + 1) / $ExampleArray.Count * 100,0) ; 
        $Host.UI.RawUI.WindowTitle = "$PercentProcessed% Completed" ; 
        Start-Sleep -Milliseconds 50 ; 
    } ; 
    mdjxkln's example to display script progress
    .LINK
    https://xkln.net/blog/putting-the-powershell-window-title-to-better-use/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('set-PSTitle')]
    Param (
        [parameter(Mandatory = $true,Position=0,HelpMessage="Title string to be set on current powershell console Titlebar[-title 'PS Window'")]
        [String]$Title,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    )
    $verbose = ($VerbosePreference -eq "Continue") ; 
    write-verbose "`$Title:$($Title)" ; 
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        #only use on console host; since ISE shares the WindowTitle across multiple tabs
        if(-not($whatif)){
            write-verbose "update:`$host.ui.RawUI.WindowTitle to`n$($Title|out-string).trim())" ; 
            $host.ui.RawUI.WindowTitle = $Title ;
        } else { 
            write-host "whatif:update:`$host.ui.RawUI.WindowTitle to`n$($Title|out-string).trim())" ; 
        } 
        Rebuild-PSTitleBar -verbose:$($VerbosePreference -eq "Continue") -whatif:$($whatif);
    } ;
}

#*------^ set-PSTitleBar.ps1 ^------

#*------v Set-Shortcut.ps1 v------
function Set-Shortcut {
    <#
    .SYNOPSIS
    Set-Shortcut.ps1 - writes changes to target .lnk files
    .NOTES
    Author: Tim Lewis
    REVISIONS   :
    * 11:40 AM 9/16/2021 string
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
    set-shortcut -linkpath "$($env:USERPROFILE)\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\SU\Iexplore ACCT.lnk" -TargetPath 'C:\sc\batch\BatScripts\runas-UID-IE.cmd' ;
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

#*------v Shorten-Path.ps1 v------
function Shorten-Path([string] $path) {
        <#
    .SYNOPSIS
    Shorten-Path - Abbreviates path entries to the first letter of all but the most leaf dir
    .NOTES
    Author: from winterdom.com
    Website:	winterdom.com
    Twitter:
    REVISIONS   :
    12:25 PM 11/2/2015 - added pshelp
    .DESCRIPTION
    Shorten-Path - Abbreviates path entries to the first letter of all but the most leaf dir
    c:\usr\work\exch\scripts becomes: C:\u\w\e\scripts
    .INPUTS
    Takes a standard path string
    .OUTPUTS
    Output's the abbreviated path
    .EXAMPLE
    write-host (shorten-path (pwd).Path) -n -f $cloc
    .LINK
    #>
        $loc = $path.Replace($HOME, '~')
        # remove prefix for UNC paths
        $loc = $loc -replace '^[^:]+::', ''
        # make path shorter like tabs in Vim,
        # handle paths starting with \\ and . correctly
        return ($loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)', '\$1$2')
    }

#*------^ Shorten-Path.ps1 ^------

#*------v Show-MsgBox.ps1 v------
function Show-MsgBox {
        <#
        .SYNOPSIS
        Show-MsgBox.ps1 - Shows a graphical message box, with various prompt types available.
        .NOTES
        Version     : 1.0.0
        Author      : BigTeddy
        Website     :	http://social.technet.microsoft.com/profile/bigteddy/.
        Twitter     :	@tostka / http://twitter.com/tostka
        CreatedDate : 2020-
        FileName    : 
        License     : MIT License
        Copyright   : (c) 2020 Todd Kadrie
        Github      : https://github.com/tostka
        Tags        : Powershell,Dialogs,GUI,UI,VisualBasic
        REVISIONS
        * 11:49 AM 4/17/2020 updated cbh
        * 12:18 PM 2/20/2015 ported/tweaked
        * August 23, 2011 10:40 PM posted version
        .DESCRIPTION
        Emulates the Visual Basic MsgBox function. It takes four parameters, of which only the prompt is mandatory
        .PARAMETER  Prompt
        Text string that you wish to display
        .PARAMETER  Title
        The title that appears on the message box
        .PARAMETER  Icon
        Available options are:Information, Question, Critical, Exclamation (not case sensitive)
        .PARAMETER  BoxType
        Available options are: OKOnly, OkCancel, AbortRetryIgnore, YesNoCancel, YesNo, RetryCancel (not case sensitive)
        .PARAMETER  DefaultButton 
        Available options are:1, 2, 3
        .EXAMPLE
        Show-MsgBox Hello
        Shows a popup message with the text "Hello", and the default box, icon and defaultbutton settings.
        .EXAMPLE
        Show-MsgBox -Prompt "This is the prompt" -Title "This Is The Title" -Icon Critical -BoxType YesNo -DefaultButton 2
        Shows a popup with the parameter as supplied.
        .LINK
        http://msdn.microsoft.com/en-us/library/microsoft.visualbasic.msgboxresult.aspx
        .LINK
        http://msdn.microsoft.com/en-us/library/microsoft.visualbasic.msgboxstyle.aspx
        #>
        [CmdletBinding()]
        param(
            [Parameter(Position = 0, Mandatory = $true)]
            [string]$Prompt,
            [Parameter(Position = 1, Mandatory = $false)]
            [string]$Title = "",
            [Parameter(Position = 2, Mandatory = $false)] [ValidateSet("Information", "Question", "Critical", "Exclamation")]
            [string]$Icon = "Information",
            [Parameter(Position = 3, Mandatory = $false)] [ValidateSet("OKOnly", "OKCancel", "AbortRetryIgnore", "YesNoCancel", "YesNo", "RetryCancel")]
            [string]$BoxType = "OkOnly",
            [Parameter(Position = 4, Mandatory = $false)] [ValidateSet(1, 2, 3)]
            [int]$DefaultButton = 1
        )
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.VisualBasic")
        switch ($Icon) {
            "Question" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Question }
            "Critical" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Critical }
            "Exclamation" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Exclamation }
            "Information" { $vb_icon = [microsoft.visualbasic.msgboxstyle]::Information }
        }
        switch ($BoxType) {
            "OKOnly" { $vb_box = [microsoft.visualbasic.msgboxstyle]::OKOnly }
            "OKCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::OkCancel }
            "AbortRetryIgnore" { $vb_box = [microsoft.visualbasic.msgboxstyle]::AbortRetryIgnore }
            "YesNoCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNoCancel }
            "YesNo" { $vb_box = [microsoft.visualbasic.msgboxstyle]::YesNo }
            "RetryCancel" { $vb_box = [microsoft.visualbasic.msgboxstyle]::RetryCancel }
        }
        switch ($Defaultbutton) {
            1 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton1 }
            2 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton2 }
            3 { $vb_defaultbutton = [microsoft.visualbasic.msgboxstyle]::DefaultButton3 }
        }
        $popuptype = $vb_icon -bor $vb_box -bor $vb_defaultbutton
        $ans = [Microsoft.VisualBasic.Interaction]::MsgBox($prompt, $popuptype, $title)
        return $ans
    }

#*------^ Show-MsgBox.ps1 ^------

#*------v Sign-File.ps1 v------
function Sign-File {
    <#
    .SYNOPSIS
    Sign-File - adds an Authenticode signature to any file that supports Subject Interface Package (SIP).
    .NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Certificate,Developoment
    REVISIONS   :
    10:45 AM 10/14/2020 added cert hunting into cert:\LocalMachine\my -codesigning as well as currentuser
    7:56 AM 6/19/2018 added -whatif & -showdebug params
    10:46 AM 1/16/2015 corrected $oReg|$oRet typo that broke status attrib
    10:20 AM 1/15/2015 rewrote into pipeline format
    9:50 AM 1/15/2015 added a $f.name echo to see if it's doing anything
    8:54 AM 1/8/2015 - added play-beep to end
    10:01 AM 12/30/2014
    .PARAMETER file
    file name(s) to appl authenticode signature into.
    .PARAMETER cert
    The path and filename of a text file where failed computers will be logged. Defaults to c:\retries.txt.
    .INPUTS
    Accepts piped input (computername).
    .OUTPUTS
    Outputs CustomObject to pipeline
    .DESCRIPTION
    Sign-File - adds an Authenticode signature to any file that supports Subject Interface Package (SIP).
    .EXAMPLE
      get-childitem *.ps1,*.psm1,*.psd1,*.psd1,*.ps1xml | Get-AuthenticodeSignature | Where {!(Test-AuthenticodeSignature $_ -Valid)} | gci | Set-AuthenticodeSignature
      Set sigs on all ps files with invalid sigs (for ps, it's: ps1, psm1, psd1, dll, exe, and ps1xml files)
    .EXAMPLE
    Get-ADComputer -filter * | Select @{label='computername';expression={$_.name}} | Get-Info
    .EXAMPLE
    Get-Info -computername SERVER2,SERVER3
    .EXAMPLE
    sign-file C:\usr\work\lync\scripts\enable-luser.ps1
    .EXAMPLE
    sign-file C:\usr\work\lync\scripts\*-luser.ps1
    .EXAMPLE
    get-childitem C:\usr\work\lync\scripts\*-luser.ps1 | %{sign-file $_}
    .EXAMPLE
    get-childitem c:\usr\local\bin\*.ps1 | sign-file
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelinebyPropertyName = $True, HelpMessage = 'What file(s) would you like to sign?')]
        $file,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    # alt: the simplest option:
    # $cert = @(get-childitem cert:\currentuser\my -codesigning)[0] ; Set-AuthenticodeSignature -filepath c:\usr\work\ps\scripts\authenticate-profile.ps1 -Certificate $cert
    BEGIN {
        $error.clear() ;
        TRY {
            if($cert = @(get-childitem cert:\currentuser\my -codesigning -ea 0 )[0]){
            
            } elseif($cert = @(get-childitem cert:\LocalMachine\my -codesigning -ea 0 )[0]){
            
            } else { 
                throw "Unable to locate a Signing Cert in either`ncert:\currentuser\my -codesigning`nor cert:\LocalMachine\my -codesigning. ABORTING!" ; 
            } 
        } CATCH {
            Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($_.Exception.ItemName). `nError Message: $($_.Exception.Message)`nError Details: $($_)" ;
            Exit #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ; 
    }  # BEG-E
    PROCESS {
        foreach ($f in $file) {
            $continue = $true
            try {
                #$f.name
                $oRet = Set-AuthenticodeSignature -filepath $f -Certificate $cert -whatif:$($whatif) ;
            }
            catch {
                Write "$((get-date).ToString('HH:mm:ss')): Error Details: $($_)"
            } # try/cat-E
            if ($continue) {
                $sig = Get-AuthenticodeSignature -filepath $f
                # create a hashtable with your output info
                $info = @{
                    'file'       = $oRet.Path;
                    'Thumbprint' = $oRet.SignerCertificate.Thumbprint;
                    'Subject'    = $oRet.SignerCertificate.Subject;
                    'status'     = $oRet.Status.Status
                } ;
                Write-Output $oRet
            } 
        } # loop-E
    } # Proc-E
}

#*------^ Sign-File.ps1 ^------

#*------v stop-driveburn.ps1 v------
Function stop-driveburn {
    <#
    .SYNOPSIS
    stop-driveburn - stop drive high IO processes that lag down workstation
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-10-05
    FileName    : stop-driveburn.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Performance,Workstation
    REVISIONS
    7:35 AM 10/5/2020 ported to verb-IO, updated tsksid/admin-incl-ServerCore.ps1
    * 8:48 AM 10/22/2019 added ldesk gatherproducts
    *11:34 AM 4/16/2019 rearranging cmd order
    * 11:46 AM 3/12/2019 rewrote/internalized the wsearch stop, updated the output to be write-hosts with timestamps
    *7:57 AM 2/27/2018 #36, was getting obj as output, tried out-string/out-default to see if we could clean it to just the id & name properties as string
    *9:04 AM 10/18/2017 found it picking up $whatif from ps, so added it as an explicit param (don't want a whatif, want them dead), added sig, added passthrough -whatif on the stop-indexing call
    *9:47 AM 5/5/2017 broke out, had it echo on matches, added pshelps, added process echos & results
    *7:01 AM 3/31/2017 added call to stop-indexing-win7.ps1
    *7:35 AM 3/20/2017 initial vers
    .DESCRIPTION
    stop-driveburn - stop drive high IO processes that lag down workstation
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output
    .EXAMPLE
    stop-driveburn
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    #>
    [CmdletBinding()]
    [Alias('sdb')]
    Param([Parameter(HelpMessage="Whatif Flag  [-whatIf]")][switch] $whatIf) ; 
    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):KILLING DRIVE SUCKERS!`nQUIT READING BY THE HARDDRIVE LIGHT!" ; 
    "LDIScn32","Cagent32","gatherproducts" | foreach {
        #"==Checking for $($_)" ;
        if($gp=get-process "$($_)" -ea 0 ){
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):PROCMATCH:Stopping proc:`n$(($gp | ft -auto ID,ProcessName|out-string).trim())" ; 
            $gp | stop-process -force -whatif:$($whatif)
        } else {
            write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):(no $($_) processes found)" ; 
        } ; 
    } ; 

    #  tack index stop in here too
    $stat=(Get-Service -Name wsearch).status ; 
    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):===Windows Search:Status:$($stat)" ; 
    if ($stat -eq 'Running') {
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):STOPPING WSEARCH SVC" ; 
        stop-Service -Name wsearch ; 
    } else { 
        write-verbose "$((get-date).ToString('HH:mm:ss')):(wsearch is *not* running)" ; 
    } ; 
    write-verbose "$((get-date).ToString('HH:mm:ss')):(waiting 5secs to close)" ; 
    #start-sleep -s 5 ; 
}

#*------^ stop-driveburn.ps1 ^------

#*------v test-MediaFile.ps1 v------
Function test-MediaFile {
    <#
    .SYNOPSIS
    test-MediaFile.ps1 - First pulls media descriptive metadata (from MediaInfo.dll via get-MediaInfoRAW()) out of a media file, 
    then compares key A/V metrics against (my arbitrary) thresholds for suitability, 
    and finally outputs a summary report of the metrics. 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2021-10-12
    FileName    : test-MediaFile.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Media,Metadata,Video,Audio,Subtitles
    REVISIONS
    * 10:25 AM 2/21/2022 updated CBH, added an example sample output. Not sure if worked before, but CBH currently doesn't seem to get-hepl correctly. Needs debugging, but can't determine issue source.
    * 8:08 PM 12/11/2021 added simpler pipeline example 
    * 11:12 AM 11/27/2021 fixed echo typo in the test block, added detailed echo on fail attrib/test details
    * 8:15 PM 11/19/2021 added tmr alias
    * 7:37 PM 11/12/2021 added example for doing a full dir of files ; flip $path param test-path to use -literalpath - too many square brackets in sources
    * 6:05 PM 11/6/2021 swap $finalfile -> "$($entry)" ; fixed missing use of pltGIMR (wasn't doing xml export)
    * 8:44 PM 11/2/2021 flip gci -path => -literalpath, avoid [] wildcard issues
    * 7:47 PM 10/26/2021 added -ExportToFile defaulted to true
    * 12:53 PM 10/20/2021 init vers - ported over to verb-io from my fix-htpcfiles.ps1
    .DESCRIPTION
    test-MediaFile.ps1 - First pulls media descriptive metadata (from MediaInfo.dll via get-MediaInfoRAW()) out of a media file, 
    then compares key A/V metrics against (my arbitrary) thresholds for suitability, 
    and finally outputs a summary report of the metrics. 

    This is a wrapper function for my Get-MediaINfoRaw() cmdlet, which is part of my [Get-MediaInfo](https://github.com/tostka/Get-MediaInfo)
    module, which is forked from Frank Skare/stax76's Get-MediaInfoSummary() function (part of his [get-MediaInfo module](https://github.com/stax76/Get-MediaInfo)).
    which in turn leverages the [MediaInfo.dll](https://mediaarea.net/en/MediaInfo/Support/SDK/ReadFirst),
    development component made available by the open source [MediaInfo](https://mediaarea.net/en/MediaInfo) project 
    (which has a nifty free-standing .exe gui version as their core tool). 
    
    1) This wrapper function calls Get-MediaInfoRaw(), to retrieve desciptive media metadata on the file specified by the -Path param.
    
    2) It then and processes the returned media metadata, checking the following thresholds:
    
    - Has all of the following General stream properties populated:
        CompleteNamem, OverallBitRate_String and OverallBitRate_kbps 
        (last 2 are my Get-MediaInfoRaw() decimal-parsed variants of the xxx_String properties).
    
    - Has a 'mb-Per-Minute' ratio of _2_ or better (specified via the -Threshmbpm parameter).  
        I calulate 'mb-Per-Minute' as: General stream 'FileSize_MB' / General stream 'Duration_Mins' 
        (both are my numeric parses of the underlying xxx_String properties)

        Goal of this metric is flagging 'bogus' files, that don't have 
        enough "size to metadata minutes" to reflect a typical "legit" video file.    
        
    - Has a minimum vertical resolution of at least 480 pixels (specified via the -ThresholdMinVerticalRes parameter), 
        as reported in the Video stream Height_String property.
  
    - Has all of the following Video stream properties populated:
        Format_String, CodecID, Duration_Mins, BitRate_kbps, FrameRate_fps 
        (the trailing three are numeric parses of the matching _String properties). 
    
    - Has all of the following Audio stream properties populated:
      Format_String, CodecID, SamplingRate_bit
      (last is my numeric parse of SamplingRate_String).

    3) It then outputs a summary report to console.

    .PARAMETER Path
    Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]
    .PARAMETER ThresholdMbPerMin
    [float] Cutoff threshold for ratio of 'file size in mb'/'minutes duration' (defaults 2).[-ThresholdMbPerMin 1.5]
    .PARAMETER ThresholdMinVerticalRes
    [int] Cutoff threshold for minimum video lines of resolution (in pixels the underlying video stream 'Height_String').[-ThresholdMinVerticalRes 300]
    .OUTPUT
    None. Outputs summary to console. 
    .EXAMPLE
    PS> test-MediaFile -Path c:\pathto\video.mp4
    Example summarizing a video file
    .EXAMPLE
    PS> if(test-mediafile "C:\users\USER\Documents\Reflections Video.mp4"){write-host "Valid, meets specs"}else{write-warning "INVALID, DOES not meets specs" }  ;
        (writing metadata to matching -media.XML file)
        09:42:35:-----
        FileName
        C:\users\USER\Documents\Reflections Video.mp4
        FileMB | Mins | OBitRate  | Format      | Ext
        70mb   | 9.3  | 1058 kbps | MPEG-4 kbps | .mp4
        V-Fmt | V-Kbps | V-WxH:Ratio    | V-fps | V-Std | V-Encoder
        AVC   | 881    | 1920x1080:16:9 | 30    |       |
        A-Chnls   | A-Lang | A-Fmt  | A-BitRate | A-kHz
        2 channel |        | AAC LC | 174 Kbps  | 48.0
        -----
        Valid, meets specs
    Example testing the validity of a video file, to output a descriptive output to console.
    .EXAMPLE
    PS> 'c:\pathto\video.mp4'| test-MediaFile ; 
    Example using pipeline support
    .EXAMPLE
    PS> gci "c:\PathTo\*" -include *.mkv | select -expand fullname | test-MediaFile ; 
    Bulk file pipeline example
    .EXAMPLE
    PS> gci "c:\pathto\*.mp4" | tmf ; 
    Another simpler pipeline example, leveraging the native tmf alias.
    .LINK
    https://hexus.net/tech/tech-explained/storage/1376-gigabytes-gibibytes-what-need-know/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('tmf')]
    PARAM(
            #[Parameter(Position=0,Mandatory=$True,ValueFromPipelineByPropertyName=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]
            [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]
            [ValidateScript({Test-Path -literalpath $_})]
            [string[]] $Path,
            [Parameter(HelpMessage="[float] Cutoff threshold for ratio of 'file size in mb'/'minutes duration' (defaults 2).[-ThresholdMbPerMin 1.5]")]
            [float]$ThresholdMbPerMin=2,
            [Parameter(HelpMessage="[int] Cutoff threshold for minimum video lines of resolution (in pixels the underlying video stream 'Height_String').[-ThresholdMinVerticalRes 300]")]
            [int]$ThresholdMinVerticalRes=480,
            [Parameter(HelpMessage="Suppress all outputs but return pass status as`$true/`$false, to the pipeline[-Silent]")]
            [switch] $Silent,
            [Parameter(HelpMessage="Switch to create a matching XML metadata export file (with -Path name/location and .xml ext).[-ExportToFile]")]
            [switch]$ExportMediaToFile=$true
        ) ;
        BEGIN{

        $propsGeneral1 = @{name="FileName";expression={$_.CompleteName}}
                        
        $propsGeneral2 = @{name="FileMB";expression={"$($_.FileSize_MB)mb"}},@{name="Mins";expression={[math]::round($_.Duration_Mins,1)}},
            @{name="OBitRate";expression={"$($_.OverallBitRate_kbps) kbps"}},@{name="Format";expression={"$($_.Format_String) kbps"}},@{name="Ext";expression={$pfile.extension}} ; 
        $propsAudio = @{name="A-Chnls";expression={$_.Channel_s__String.replace('annels','')}},@{name="A-Lang";expression={$_.Language_String}},
            @{name="A-Fmt";expression={$_.Format_String}},@{name="A-BitRate";expression={$_.BitRate_String}},
            @{name="A-kHz";expression={$_.SamplingRate_bit}}; 

        $propsVideo = @{name="V-Fmt";expression={$_.Format_String}},@{name="V-Kbps";expression={$_.BitRate_kbps}},
            @{name="V-WxH:Ratio";expression={"$($_.Width_Pixels)x$($_.Height_Pixels):$($_.DisplayAspectRatio_String)"}},
            @{name="V-fps";expression={[math]::round($_.FrameRate_fps,1)}},@{name="V-Std";expression={$_.Standard}},
            @{name="V-Encoder";Expression={(($_.Encoded_Library_String.ToString())).substring(0,[System.Math]::Min(10, $_.Encoded_Library_String.Length)).trim() + "..."}} ;

        
        $propsGeneralTest = 'CompleteName','OverallBitRate_String','OverallBitRate_kbps' ;
        $propsVidTest = 'Format_String','CodecID','Duration_Mins','BitRate_kbps','FrameRate_fps' ;
        $propsAudioTest = 'Format_String','CodecID','SamplingRate_bit' ; 

        $isLegit = $false ; 
        $isWarn = $false ; 
        
        }  # BEG-E
        PROCESS{
            foreach($entry in $Path){
                $entry = (Convert-Path -LiteralPath $entry) ;
                $pfile = get-childitem -literalpath $entry ; 
                # pull get-mediaInfo and validate it's legit    
                $pltGMIR=[ordered]@{
                    ExportToFile = $($ExportMediaToFile) ; 
                    verbose = $($VerbosePreference -eq "Continue")
                } ; 
                if(-not$Silent){
                    $smsg = "Get-MediaInfoRAW w`n$(($pltGMIR|out-string).trim())`n-Path: -$($entry)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                } ; 
                $mediaMeta = Get-MediaInfoRAW -Path "$($entry)" @pltGMIR ; 
                $finalfile = get-childitem -literalpath "$($entry)"; 
               
                $hasGeneralProps = [boolean]($mediaMeta.general.CompleteName -AND $mediaMeta.general.OverallBitRate_String -AND $mediaMeta.general.OverallBitRate_kbps) 
                $hasMbps = [boolean]([double]$mediaMeta.general.FileSize_MB/[double]$mediaMeta.general.Duration_Mins -gt $ThresholdMbPerMin) ; 
                $hasVRes = [boolean]([int]$mediaMeta.video.Height_Pixels -gt $ThreshVRes)
                $hasVidProps = [boolean](($mediameta.video.Format_String -AND $mediameta.video.CodecID -AND $mediameta.video.Duration_Mins -AND $mediameta.video.BitRate_kbps -AND $mediameta.video.FrameRate_fps) )
                $hasAudioProps = [boolean](($mediameta.audio.Format_String -AND $mediameta.audio.CodecID -AND $mediameta.audio.SamplingRate_bit ) )               

                $MDtbl=[ordered]@{NoDashRow=$true } ; # out-markdowntable splat
                
                $sRpt = '-'*5 ; 
                $sRpt += "`n$(($mediaMeta.general| select $propsGeneral1|out-markdowntable @MDtbl |out-string).trim())" ;
                $sRpt += "`n$(($mediaMeta.general| select $propsGeneral2|out-markdowntable @MDtbl |out-string).trim())" ;
                $sRpt += "`n$(($mediaMeta.video| select $propsVideo|out-markdowntable @MDtbl |out-string).trim())" ;
                $sRpt += "`n$(($mediaMeta.audio| select $propsAudio|out-markdowntable @MDtbl |out-string).trim())" ;
                $sRpt += "`n$(($mediaMeta.SubtitleLanguagesInternal|out-markdowntable @MDtbl |out-string).trim())" ;
                $sRpt += "`n$('-'*5)" ; 

                if($hasGeneralProps -AND $hasMbps -AND $hasVRes -AND $hasVidProps -AND $hasAudioProps){
                    $isLegit = $true ; 
                    $smsg = "($($finalname) passes meta props test)" ;                         
                    if(-not$Silent){
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        $smsg = $sRpt ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    } ; 
                } else { 
                    $isLegit = $false ; 
                    $smsg = "$($finalname) *FAILS* meta props test" ; 
                    $smsg += $sRpt ;
                    if(-not$Silent){
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } ; 
                    if(-not $hasGeneralProps){
                        $smsg = "-LACKS key general meta props!:" ; 
                        $smsg = "`n$(($mediaMeta.general| fl $propsGeneralTest|out-string).trim())" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        }
                        $smsg = $null ; 
                        if(-not $mediaMeta.general.CompleteName){
                            $smsg = "`n(missing general.CompleteName)" ; 
                        }
                        if(-not $mediaMeta.general.OverallBitRate_String){
                            $smsg = "`n(missing general.OverallBitRate_String)" ; 
                        } 
                        if(-not $mediaMeta.general.OverallBitRate_kbps){
                            $smsg = "`n(missing general.OverallBitRate_kbps)" ; 
                        } ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } ;
                    if(-not $hasVidProps){
                        $smsg = "-LACKS key video meta props!:" ; 
                        $smsg = "`n$(($mediaMeta.video| fl $propsVidTest|out-string).trim())" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ; 
                        $smsg = $null ; 
                        if(-not $mediameta.video.Format_String ){
                            $smsg = "`n(missing video.Format_String)" ; 
                        }
                        if(-not $mediameta.video.CodecID){
                            $smsg = "`n(missing video.CodecID)" ; 
                        } 
                        if(-not $mediameta.video.Duration_Mins){
                            $smsg = "`n(missing video.Duration_Mins)" ; 
                        } ; 
                        if(-not $mediameta.video.BitRate_kbps){
                            $smsg = "`n(missing video.BitRate_kbps)" ; 
                        } ; 
                        if(-not $mediameta.video.FrameRate_fps){
                            $smsg = "`n(missing video.FrameRate_fps)" ; 
                        } ;   
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;                       
                    } ;
                    if(-not $hasAudioProps){
                        $smsg = "-LACKS key audio meta props!:" ; 
                        $smsg = "`n$(($mediaMeta.audio| fl $propsVidTest|out-string).trim())" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ;
                        $smsg = $null ; 
                        if(-not $mediameta.audio.Format_String ){
                            $smsg = "`n(missing audio.Format_String)" ; 
                        }
                        if(-not $mediameta.audio.CodecID){
                            $smsg = "`n(missing audio.CodecID)" ; 
                        } 
                        if(-not $mediameta.audio.SamplingRate_bit){
                            $smsg = "`n(missing audio.SamplingRate_bit)" ; 
                        } ; 
                        if(-not $mediameta.video.BitRate_kbps){
                            $smsg = "`n(missing video.BitRate_kbps)" ; 
                        } ;                        
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;                      
                    } ;
                    if(-not $hasMbps){
                        $smsg = "-has a VERY LOW MB/SEC spec! ($($mediaMeta.general.FileSize_MB/$mediaMeta.general.Duration_Mins) vs min:$($ThresholdMbPerMin))!:" ; 
                        $smsg = "`nPOTENTIALLY UNDERSIZED/NON-VIDEO FILE!" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ;
                    } ;
                    if(-not $hasVRes){
                        $smsg = "-is a VERY LOW RES! ($($mediaMeta.video.Height_Pixels) vs min:$($ThreshVRes))!:" ; 
                        $smsg = "`nPOTENTIALLY UNDERSIZED/NON-VIDEO FILE!" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        };
                    } ;
                } ;  # good/bad
                
                $isLegit | write-output ;

            }  # loop-E
        }  # PROC-E
        END{
          
        };
}

#*------^ test-MediaFile.ps1 ^------

#*------v Test-PendingReboot.ps1 v------
function Test-PendingReboot {
    <#
    .SYNOPSIS
    Test-PendingReboot.ps1 - Check specified Server(s) registry for telltale PendingReboot registry keys. Returns a hashtable with IsPendingREboot and ComputerName for each machine checked. Requires localadmin permissions.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : Adam Bertram
    AddedWebsite:	https://adamtheautomator.com/pending-reboot-registry-windows/
    AddedTwitter:	@adambertram
    CreatedDate : 20201014-0826AM
    FileName    : Test-PendingReboot.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,System,Reboot
    REVISIONS
    * 9:52 AM 2/11/2021 pulled spurios trailing fire of the cmd below func, updated CBH
    * 5:03 PM 1/14/2021 init, minor CBH mods
    * 7/29/19 AB's posted version
    .DESCRIPTION
    Test-PendingReboot.ps1 - Check specified Server(s) registry for telltale PendingReboot registry keys. Returns a hashtable with IsPendingREboot and ComputerName for each machine checked. Requires localadmin permissions.
    .PARAMETER  ComputerName
    Array of computernames to be tested for pending reboot
    .PARAMETER  Credential
    windows Credential [-credential (get-credential)]
    .OUTPUT 
    System.Collections.Hashtable
    .EXAMPLE
    if((Test-PendingReboot -ComputerName $env:Computername).IsPendingReboot){write-warning "$env:computername is PENDING REBOOT!"} ;
    Test for pending reboot.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    #[Alias('get-ScheduledTaskReport')]
    PARAM(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$ComputerName,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [pscredential]$Credential
    ) ;
    $ErrorActionPreference = 'Stop'

    $scriptBlock = {

        $VerbosePreference = $using:VerbosePreference
        
        <# try to pull in local modules into the scriptblock (rather than expliciting a copy in the block) - didn't work, module load threw 
        Error Message: A Using variable cannot be retrieved. A Using variable can be used only with Invoke-Command, Start-Job, or InlineScript in the script workflow. When it is used with Invoke-Command, the Using variable is valid only if the script block is invoked on a remote computer
        #>
        function Test-RegistryKey {
            [OutputType('bool')]
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory)]
                [ValidateNotNullOrEmpty()]
                [string]$Key
            )
            $ErrorActionPreference = 'Stop'
            if (Get-Item -Path $Key -ErrorAction Ignore) {
                $true
            }
        }
        function Test-RegistryValue {
            [OutputType('bool')]
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory)]
                [ValidateNotNullOrEmpty()]
                [string]$Key,
                [Parameter(Mandatory)]
                [ValidateNotNullOrEmpty()]
                [string]$Value
            )
            $ErrorActionPreference = 'Stop'
            if (Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) {
                $true
            }
        }
        function Test-RegistryValueNotNull {
            [OutputType('bool')]
            [CmdletBinding()]
            param
            (
                [Parameter(Mandatory)]
                [ValidateNotNullOrEmpty()]
                [string]$Key,
                [Parameter(Mandatory)]
                [ValidateNotNullOrEmpty()]
                [string]$Value
            )
            $ErrorActionPreference = 'Stop'
            if (($regVal = Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) -and $regVal.($Value)) {
                $true
            }
        }

        # Added "test-path" to each test that did not leverage a custom function from above since
        # an exception is thrown when Get-ItemProperty or Get-ChildItem are passed a nonexistant key path
        # $tests is an array of scriptblocks, to be executed in a stack
        $tests = @(
            { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' }
            { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootInProgress' }
            { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired' }
            { Test-RegistryKey -Key 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\PackagesPending' }
            { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting' }
            { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations' }
            { Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations2' }
            { 
                # Added test to check first if key exists, using "ErrorAction ignore" will incorrectly return $true
                'HKLM:\SOFTWARE\Microsoft\Updates' | Where-Object { test-path $_ -PathType Container } | ForEach-Object {            
                    (Get-ItemProperty -Path $_ -Name 'UpdateExeVolatile' | Select-Object -ExpandProperty UpdateExeVolatile) -ne 0 
                }
            }
            { Test-RegistryValue -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce' -Value 'DVDRebootSignal' }
            { Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\ServerManager\CurrentRebootAttemps' }
            { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'JoinDomain' }
            { Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'AvoidSpnSet' }
            {
                # Added test to check first if keys exists, if not each group will return $Null
                # May need to evaluate what it means if one or both of these keys do not exist
                ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName' | Where-Object { test-path $_ } | %{ (Get-ItemProperty -Path $_ ).ComputerName } ) -ne 
                ( 'HKLM:\SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName' | Where-Object { Test-Path $_ } | %{ (Get-ItemProperty -Path $_ ).ComputerName } )
            }
            {
                # Added test to check first if key exists
                'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending' | Where-Object { 
                    (Test-Path $_) -and (Get-ChildItem -Path $_) } | ForEach-Object { $true }
            }
        ) ; # scriptblock-E
        # cycle the list and break on first match
        foreach ($test in $tests) {
            Write-Verbose "Running scriptblock: [$($test.ToString())]"
            if (& $test) {
                $true
                break
            }
        }
    } # scriptblock-E

    foreach ($computer in $ComputerName) {
        try {
            $connParams = @{'ComputerName' = $computer} ; 
            if ($PSBoundParameters.ContainsKey('Credential')) {
                $connParams.Credential = $Credential ; 
            } ; 

            $output = @{
                ComputerName    = $computer ; 
                IsPendingReboot = $false ; 
            } ; 

            $psRemotingSession = New-PSSession @connParams ; 
            
            if (-not ($output.IsPendingReboot = Invoke-Command -Session $psRemotingSession -ScriptBlock $scriptBlock)) {
                $output.IsPendingReboot = $false ; 
            } ; 
            [pscustomobject]$output | write-output ; 
        } catch {
            Write-Error -Message $_.Exception.Message
        } finally {
            if (Get-Variable -Name 'psRemotingSession' -ErrorAction Ignore) {
                $psRemotingSession | Remove-PSSession
            }
        } # TRY-E
    } ; 
}

#*------^ Test-PendingReboot.ps1 ^------

#*------v test-PSTitleBar.ps1 v------
Function test-PSTitleBar {
    <#
    .SYNOPSIS
    test-PSTitleBar.ps1 - Test for presence of specified string(s) from the Powershell console Titlebar
    .NOTES
    Version     : 1.0.0
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
    * 8:03 AM 7/27/2021 added rgx esc to inbound tags
    * 12:14 PM 7/26/2021 add verbose echos
    * 10:15 AM 7/22/2021 init vers
    .DESCRIPTION
    test-PSTitleBar.ps1 - Test for presence of specified string(s) from the Powershell console Titlebar
    Inspired by dsolodow's Update-PSTitleBar code
    .PARAMETER Tag
    Tag/array-of-tags string to be tested-for in text of current powershell console Titlebar
    .EXAMPLE
    test-PSTitleBar 'EMS'
    Test for the string 'EMS' in the powershell console Title Bar
    .EXAMPLE
    test-PSTitleBar 'EMS','EXO'
    Test for the 'EMS' or 'EXO' strings in the powershell console Title Bar
    .LINK
    https://github.com/dsolodow/IndyPoSH/blob/master/Profile.ps1
    #>
    
    Param (
        #[parameter(Mandatory = $true,Position=0)][String][]$Tag
        [parameter(Mandatory = $true,Position=0)]$Tag,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug
    )
    $showDebug=$true ; 
    $rgxRgxOps = [regex]'[\[\]\\\{\}\+\*\?\.]+' ; 
    write-verbose "`$Tag:`n$(($Tag|out-string).trim())" ; 
    $bPresent = $false ; 
    #only use on console host; since ISE shares the WindowTitle across multiple tabs, this information is misleading in the ISE.
    If ( $host.name -eq 'ConsoleHost' -OR ($showDebug)) {
        if($Tag -is [system.array]){ 
            foreach ($Tg in $Tag){
                #if($host.ui.RawUI.WindowTitle -like "*$($Tg)*"){
                <# could do rebuild style parse as well:
                $consPrembl = $host.ui.rawui.windowtitle.substring(0,$host.ui.rawui.windowtitle.LastIndexOf('-')).trim() ;
                $consData = ($host.ui.rawui.windowtitle.substring(($host.ui.rawui.windowtitle.LastIndexOf('-'))+1) -split '\s\s').trim(); 
                $svcs = $consdata | ?{$_ -match $rgxsvcs} | sort | select -unique  ; 
                $Orgs = $consdata |?{$_ -match $rgxTenOrgs } | sort | select -unique  ; 
                #>
                if($Tg -notmatch $rgxRgxOps){
                    $rgxQ = "\s$([Regex]::Escape($Tg))\s" ; 
                } else { 
                    $rgxQ = "\s$($Tg)\s" ; # assume it's already a regex, no manual escape
                };  
                write-verbose "`$rgxQ:$($rgxQ)" ; 
                if($host.ui.RawUI.WindowTitle  -match $rgxQ){
                    write-verbose "(matched '$($rgxQ)' in`n$(($host.ui.RawUI.WindowTitle|out-string).trim()))" ; 
                    $bPresent = $true ;
                }else{
                    write-verbose "(*no*-match '$($rgxQ)' in`n$(($host.ui.RawUI.WindowTitle|out-string).trim()))" ; 
                } ;
            } ; 
        } else {
            if($Tag -notmatch $rgxRgxOps){
                $rgxQ = "\s$([Regex]::Escape($Tag))\s" ;
            } else { 
                $rgxQ = "\s$($Tag)\s" ; # assume it's already a regex, no manual escape
            }; 
            write-verbose "`$rgxQ:$($rgxQ)" ; 
            if($host.ui.RawUI.WindowTitle -match $rgxQ){
                write-verbose "(matched '$($rgxQ)' in`n$(($host.ui.RawUI.WindowTitle|out-string).trim()))" ; 
                $bPresent = $true ;
            }else{
                write-verbose "(*no*-match '$($rgxQ)' in`n$(($host.ui.RawUI.WindowTitle|out-string).trim()))" ; 
            } ;
        }; 
    } ;
    $bPresent | write-output ;
}

#*------^ test-PSTitleBar.ps1 ^------

#*------v Test-RegistryKey.ps1 v------
function Test-RegistryKey {
    <#
    .SYNOPSIS
    Test-RegistryKey.ps1 - Checks specified registry key for presence (gi)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : Adam Bertram
    AddedWebsite:	https://adamtheautomator.com/pending-reboot-registry-windows/
    AddedTwitter:	@adambertram
    CreatedDate : 20201014-0826AM
    FileName    : Test-RegistryKey.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,System,Reboot
    REVISIONS
    * 5:03 PM 1/14/2021 init, minor CBH mods
    * 7/29/19 AB's posted version
    .DESCRIPTION
    Test-RegistryKey.ps1 - Checks specified registry key for presence (gi)
    .PARAMETER  Key
    Full registkey to be tested [-Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending']
    .EXAMPLE
    Test-RegistryKey -Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending' ; 
    Tests one of the Pending Reboot keys
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [OutputType('bool')]
    [CmdletBinding()]
    #[Alias('get-ScheduledTaskReport')]
    PARAM(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Key
    ) ;
    $ErrorActionPreference = 'Stop' ; 
    if (Get-Item -Path $Key -ErrorAction Ignore) {
        $true | write-output ; 
    } ; 
}

#*------^ Test-RegistryKey.ps1 ^------

#*------v Test-RegistryValue.ps1 v------
function Test-RegistryValue {
    <#
    .SYNOPSIS
    Test-RegistryValue.ps1 - Compares value of registry key against specified -value
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : Adam Bertram
    AddedWebsite:	https://adamtheautomator.com/pending-reboot-registry-windows/
    AddedTwitter:	@adambertram
    CreatedDate : 20201014-0826AM
    FileName    : Test-RegistryValue.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,System,Reboot
    REVISIONS
    * 5:03 PM 1/14/2021 init, minor CBH mods
    * 7/29/19 AB's posted version
    .DESCRIPTION
    Test-RegistryValue.ps1 - Compares value of registry key against specified -value
    .PARAMETER  Key
    Full registkey to be tested [-Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending']
    .PARAMETER  Value
    Value to be compared to
    .EXAMPLE
    Test-RegistryValue -Key 'HKLM:\SYSTEM\CurrentControlSet\Services\Netlogon' -Value 'JoinDomain'
    Tests value of the specified key -eq 'JoinDomain'
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [OutputType('bool')]
    [CmdletBinding()]
    #[Alias('get-ScheduledTaskReport')]
    PARAM(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$Key,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$Value
    ) ;
    $ErrorActionPreference = 'Stop' ;
    if (Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) {
        $true | write-output ; 
    } ;
}

#*------^ Test-RegistryValue.ps1 ^------

#*------v Test-RegistryValueNotNull.ps1 v------
function Test-RegistryValueNotNull {
    <#
    .SYNOPSIS
    Test-RegistryValueNotNull.ps1 - Checks specified registry key is Not Null
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    AddedCredit : Adam Bertram
    AddedWebsite:	https://adamtheautomator.com/pending-reboot-registry-windows/
    AddedTwitter:	@adambertram
    CreatedDate : 20201014-0826AM
    FileName    : Test-RegistryValueNotNull.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,System,Reboot
    REVISIONS
    * 5:03 PM 1/14/2021 init, minor CBH mods
    * 7/29/19 AB's posted version
    .DESCRIPTION
    Test-RegistryValueNotNull.ps1 - Checks specified registry key is Not Null
    .PARAMETER  Key
    Full registkey to be tested [-Key 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending']
    .PARAMETER  Value
    Value to be compared to
    .EXAMPLE
    Test-RegistryValueNotNull -Key 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager' -Value 'PendingFileRenameOperations2'
    Tests value of the specified key is NotNull 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [OutputType('bool')]
    [CmdletBinding()]
    #[Alias('get-ScheduledTaskReport')]
    PARAM(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$Key,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()]
        [string]$Value
    ) ;
    $ErrorActionPreference = 'Stop'
    if (($regVal = Get-ItemProperty -Path $Key -Name $Value -ErrorAction Ignore) -and $regVal.($Value)) {
        $true| write-output  ; 
    } ; 
}

#*------^ Test-RegistryValueNotNull.ps1 ^------

#*------v Touch-File.ps1 v------
Function Touch-File {
    <#
    .SYNOPSIS
    Touch-File.ps1 - Approx *nix 'touch', create empty file if non-prexisting| update timestemp if exists.
    .NOTES
    Author: LittleBoyLost
    Website:	https://superuser.com/users/210235/littleboylost
    REVISIONS   :
    * 3/25/13 - posted version
    .DESCRIPTION
    .PARAMETER  File
    File [-file c:\path-to\file.ext]
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    touch-file -file c:\tmp.txt ;
    Create a new file, or update timestamp of exising file
    .LINK
    https://superuser.com/questions/502374/equivalent-of-linux-touch-to-create-an-empty-file-with-powershell#
    #>
    [Alias('touch')]
    Param([Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "File [-file c:\path-to\file.ext]")]$File) ;
    if ($file -eq $null) { throw "No filename supplied" } ;
    if (Test-Path $file) { (Get-ChildItem $file).LastWriteTime = Get-Date } else { echo $null > $file } ;
}

#*------^ Touch-File.ps1 ^------

#*------v trim-FileList.ps1 v------
function trim-FileList {
    <#
    .SYNOPSIS
    trim-FileList.ps1 - Sort and unique a file containing a list of items
    .NOTES
    Version     : 1.0.0
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
    * 10:35 AM 2/21/2022 CBH example ps> adds 
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
    PS> $tfiles = @(gci C:\sc\powershell\_key-admin-scripts-*.txt -recur |select -expand fullname )  ;
    PS> trim-FileList.ps1 -files $tfiles -verbose -whatif ; 
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

#*------v unless.ps1 v------
function unless {
    <#
    .SYNOPSIS
    unless() - Parameter validation friendly fail msgs func
    .NOTES
    Author: Karl Prosser
    Website:	https://powershell.org/wp/2013/05/21/validatescript-for-beginners/

    REVISIONS   :
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    8:32 AM 9/2/2015 reformatted, added help
    20130521 - web version
    .DESCRIPTION
    use the Unless (condition) -fail "message" pattern to provide a human-friendly fail response
    
    Sample using the unless function call, with the validation expression, and a pre-specified friendly failure message.
    ```powershell
    [CmdletBinding()]
    param(
      [ValidateScript({unless ($_ -gt 100 ) -fail "needs to be greater than 100"})]
      [int] $a
    ) ;
    ```
    .PARAMETER  expressionResultOrScriptBlock
    (Auto-populated by call)
    .PARAMETER  failmessage
    User-friendly failure message to be returned to user
    .INPUTS
    Accepts piped input for the expressionResultOrScriptBlock param.
    .OUTPUTS
    Throws the specified Fail Message to user, if the Parameter Validation specified in expressionResultOrScriptBlock fails to validate.
    .EXAMPLE
      [CmdletBinding()]
      param(
        [ValidateScript({unless ($_ -gt 100 ) -fail "needs to be greater than 100"})]
        [int] $a
      ) ;
      Using the unless function call, with the validation expression, and a pre-specified friendly failure message.
    .LINK
    https://powershell.org/wp/2013/05/21/validatescript-for-beginners/
    #>

    [cmdletbinding()]
    param ($expressionResultOrScriptBlock , $failmessage) ;
    process {
        $_ = (Get-Variable -Scope 1 -Name _).Value ;
        $result = $expressionResultOrScriptBlock; ;
        if ($expressionResultOrScriptBlock -is [scriptblock]) { $result = & $expressionResultOrScriptBlock } ;
        if ($result) { $true } else { throw "[ $failmessage ]" } ;
    } ;
}

#*------^ unless.ps1 ^------

#*------v update-RegistryProperty.ps1 v------
function update-RegistryProperty {
    <#
    .SYNOPSIS
    update-RegistryProperty - Update a registry key, dump the pre/post values
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-05-01
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Registry,Maintenance
    REVISIONS
    * 10:13 AM 5/1/2020 init vers
    .DESCRIPTION
    update-RegistryProperty - Update a registry key, dump the pre/post values
    .PARAMETER  Path
    Registry path to target key to be updated[-Path 'HKCU:\Control Panel\Desktop']
    .PARAMETER Name
    Registry property to be updated[-Name AutoColorization]
    .PARAMETER Value
    Value to be set on the specified 'Name' property [-Value 0]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .OUTPUT
    System.Object[]
    .EXAMPLE
    update-RegistryProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0
    Update the desktop AutoColorization property to the value 0 
    .EXAMPLE
    update-RegistryProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'AutoColorization' -Value 0 -verbose
    Update the desktop AutoColorization property to the value 0 with verbose detailed pre/post output
    .LINK
    https://github.com/tostka
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True,HelpMessage = "Registry property to be updated[-Name AutoColorization]")]
        [ValidateNotNullOrEmpty()][string]$Name,
        [Parameter(Mandatory = $True,HelpMessage = "Registry path to target key to be updated[-Path 'HKCU:\Control Panel\Desktop']")]
        [ValidateNotNullOrEmpty()][string]$Path,
        [Parameter(Mandatory = $True,HelpMessage = "Value to be set on the specified 'Name' property [-Value 0]")]
        [ValidateNotNullOrEmpty()][string]$Value,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    $error.clear() ;
    TRY {
        $pltReg=[ordered]@{
            Path = $Path ;
            Name = $Name ;
            Value = $Value ;
            whatif=$($whatif) ;
        } ;
        write-verbose -Verbose:$Verbose  "$((get-date).ToString('HH:mm:ss')):PRE:$($pltReg.Path)\`n$($pltReg.Name):$((Get-ItemProperty -path $pltReg.path -name $pltReg.name| select -expand $pltReg.name|out-string).trim())" ;
        write-verbose -Verbose:$Verbose "$((get-date).ToString('HH:mm:ss')):Set-ItemProperty w`n$(($pltReg|out-string).trim())" ;
        Set-ItemProperty @pltReg;
        write-verbose -Verbose:$Verbose  "$((get-date).ToString('HH:mm:ss')):POST:$($pltReg.Path)\`n$($pltReg.Name):$((Get-ItemProperty -path $pltReg.path -name $pltReg.name| select -expand $pltReg.name|out-string).trim())" ;
        $true | write-output ; 
    } CATCH {
        $ErrTrpd = $_ ; 
        Write-Warning "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrTrpd.Exception.ItemName). `nError Message: $($ErrTrpd.Exception.Message)`nError Details: $($ErrTrpd)" ;
        $false | write-output ; 
    } ; 
}

#*------^ update-RegistryProperty.ps1 ^------

#*------v Write-ProgressHelper.ps1 v------
function Write-ProgressHelper {
    <#
    .SYNOPSIS
    Write-ProgressHelper - Dynamically scaling static Write-Progress function. 
    .NOTES
    Version     : 1.0.0.0
    Author      : Adam Bertram
    Website     :	https://adamtheautomator.com/building-progress-bar-powershell-scripts/
    Twitter     :	
    CreatedDate : 2020-08-10
    FileName    : Write-ProgressHelper
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    * 11:17 AM 8/26/2020 added CBH, added supp for balance of write-progress params, ren'd orig $Message -> underlying $Status param. Example demo'ing more-flexible splat use
    * 18 June 2019 posted vers
    .DESCRIPTION
    Write-ProgressHelper - Dynamically scaling static Write-Progress function. 
    Leverages the parser to count the number of write-progress's in the current script, and uses each execucution to calculate completion percentage. Replaces hard-coded percentages per write-progress. 
    .PARAMETER StepNumber
    Number of current step, (1,2,3...)[-StepNumber 1]
    .PARAMETER Message
    String to be displayed as the write-progress '-Status' [-Message 'StepDescriptiOn']
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. 
    .EXAMPLE
    PS> $script:steps = ([System.Management.Automation.PsParser]::Tokenize((gc "$PSScriptRoot\$($MyInvocation.MyCommand.Name)"), [ref]$null) | where { $_.Type -eq 'Command' -and $_.Content -eq 'Write-ProgressHelper' }).Count ; 
    # splat to hold the static write-progress params
    PS> $pltWPH=@{
            Activity = "BROAD ACTIVITY" ;
            CurrentOperation = "Querying..." ;
        };
    PS> $iStep = 0 ; # counter to be incremented ea write-progress exec
    PS> Write-ProgressHelper @pltWPH -Status 'DOING SOMETHING' -StepNumber ($iStep++) ;
    ## SOME PROCESS HERE
    PS> Write-ProgressHelper @pltWPH -Status 'DOING SOMETHING2' -StepNumber ($iStep++) ;
    Above displays a two-step Write-Progress bar, dynamically scaling the progress & total around the number of 'write-progress' cmdlets present in the $MyInvocation
    .LINK
    https://adamtheautomator.com/building-progress-bar-powershell-scripts/
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$True,HelpMessage="Number of current step, (1,2,3...)[-StepNumber 1]")]
        [int]$StepNumber,
        [Parameter(Mandatory=$True,HelpMessage="String to be displayed as the write-progress '-Activity' [-Message 'StepDescriptiOn']")]
        [string]$Activity,
        [Parameter(Mandatory=$True,HelpMessage="String to be displayed as the write-progress '-CurrentOperation' [-Message 'StepDescriptiOn']")]
        [string]$CurrentOperation,
        [Parameter(Mandatory=$True,HelpMessage="String to be displayed as the write-progress '-Status' [-Message 'StepDescriptiOn']")]
        [string]$Status
    ) ;
    BEGIN {
        #${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        # Get parameters this function was invoked with
        #$PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    } ;
    PROCESS {
        Write-Progress -Activity:$($Activity) -Status:$($Status) -CurrentOperation:$($CurrentOperation) -PercentComplete (($StepNumber / $steps) * 100) ; 
    } ; 
    END{} ;
}

#*------^ Write-ProgressHelper.ps1 ^------

#*======^ END FUNCTIONS ^======

Export-ModuleMember -Function Add-PSTitleBar,Authenticate-File,backup-File,check-FileLock,Close-IfAlreadyRunning,ColorMatch,Compare-ObjectsSideBySide,Compare-ObjectsSideBySide4,Compare-ObjectsSideBySide4,convert-BinaryToDecimalStorageUnits,convert-ColorHexCodeToWindowsMediaColorsName,convert-DehydratedBytesToGB,convert-DehydratedBytesToMB,Convert-FileEncoding,ConvertFrom-CanonicalOU,ConvertFrom-CanonicalUser,ConvertFrom-CmdList,ConvertFrom-DN,ConvertFrom-IniFile,convertFrom-MarkdownTable,ConvertFrom-SourceTable,Null,True,False,Debug-Column,Mask,Slice,TypeName,ErrorRecord,convert-HelpToMarkdown,_encodePartOfHtml,_getCode,_getRemark,ConvertTo-HashIndexed,convertTo-MarkdownTable,convertTo-Object,ConvertTo-SRT,convert-VideoToMp3,copy-Profile,Count-Object,Create-ScheduledTaskLegacy,dump-Shortcuts,Echo-Finish,Echo-ScriptEnd,Echo-Start,Expand-ZIPFile,extract-Icon,Find-LockedFileProcess,Format-Json,Get-AverageItems,get-colorcombo,get-ConsoleText,Get-CountItems,Get-FileEncoding,Get-FileEncodingExtended,Get-FolderSize,Convert-FileSize,Get-FolderSize2,Get-FsoShortName,Get-FsoShortPath,Get-FsoTypeObj,get-InstalledApplication,get-LoremName,Get-ProductItems,get-RegistryProperty,Get-ScheduledTaskLegacy,Get-Shortcut,Get-SumItems,get-TaskReport,Get-Time,Get-TimeStamp,get-TimeStampNow,get-Uptime,Invoke-Flasher,Invoke-Pause,Invoke-Pause2,invoke-SoundCue,mount-UnavailableMappedDrives,move-FileOnReboot,new-Shortcut,out-Clipboard,Out-Excel,Out-Excel-Events,parse-PSTitleBar,play-beep,prompt-Continue,Read-Host2,rebuild-PSTitleBar,Remove-InvalidFileNameChars,remove-ItemRetry,Remove-JsonComments,Remove-PSTitleBar,Remove-ScheduledTaskLegacy,remove-UnneededFileVariants,replace-PSTitleBarText,reset-ConsoleColors,revert-File,Run-ScheduledTaskLegacy,Save-ConsoleOutputToClipBoard,select-first,Select-last,Select-StringAll,set-ConsoleColors,Set-FileContent,set-PSTitleBar,Set-Shortcut,Shorten-Path,Show-MsgBox,Sign-File,stop-driveburn,test-MediaFile,Test-PendingReboot,Test-RegistryKey,Test-RegistryValue,Test-RegistryValueNotNull,test-PSTitleBar,Test-RegistryKey,Test-RegistryValue,Test-RegistryValueNotNull,Touch-File,trim-FileList,unless,update-RegistryProperty,Write-ProgressHelper -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYJQAPXf0ypGaqwKQhpxe89Vk
# W6agggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSHwiAf
# ecinEdayvxclIOaLyLShjTANBgkqhkiG9w0BAQEFAASBgKnoSd0JJgnw2Hx/Csbe
# UzwtZuzF4adQ2JKB2cqopEiCwTkPUdIVGQ0cPljVr/DaSFcXAGfgVOw+5D3MavCf
# FXTsxPtdjXJiMui4+heMNesG803OqJ4KslE9nxGiLJkKGJJWNc6elrh4DVIhGR8n
# P4ouA0FfB4AZXX3PvtyXvTiK
# SIG # End signature block
