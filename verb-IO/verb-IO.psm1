﻿# verb-io.psm1


<#
.SYNOPSIS
verb-IO - Powershell Input/Output generic functions module
.NOTES
Version     : 7.0.0.0.0
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
    $runningInVsCode = $env:TERM_PROGRAM -eq 'vscode' ;

#*======v FUNCTIONS v======




#*------v Add-ContentFixEncoding.ps1 v------
function Add-ContentFixEncoding {
    <#
    .SYNOPSIS
    Add-ContentFixEncoding - Add-Content variant that auto-coerces files with 'ASCII' encoding to UTF8
    .NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-05-03
    FileName    : Add-ContentFixEncoding.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,File,Encoding,Management
    REVISIONS   :
    *4:26 PM 5/27/2022 fixed typo in doloop #98: $Retries => $DoRetries (loop went full dist before exiting, even if successful 1st attempt)
    * 10:01 AM 5/17/2022 updated CBH exmple
    * 10:39 AM 5/13/2022 removed 'requires -modules', to fix nesting limit error loading verb-io
    * 3:35 PM 5/10/2022 typo, fixed non capture & return of -passthru to pipeline ; add array back to $value, saw signs it was flattening systemobjects coming in as an array of lines, and only writing the last line to the -path.
    * 12:45 PM 5/9/2022 flipped pipeline to the Value param (from Path); pulled array spec on both - should be one value into one file, not loop one into a series ;
        yanked advfunc, and all looping other than retry. 
    * 9:25 AM 5/4/2022 add -passthru support, rather than true/false return ; add retry code & $DoRetries, $RetrySleep; alias 'Set-FileContent', retire the other function
    * 11:24 AM 5/3/2022 init
    .PARAMETER Path
    Specifies the path of the item that receives the content.[-Path c:\pathto\script.ps1]
    .PARAMETER Value
    Specifies the new content for the item.[-value $content]
    .PARAMETER Encoding
    Specifies the type of encoding for the target file. The default value is 'UTF8'.[-encoding Unicode]
    .PARAMETER PassThru
    Returns an object that represents the content. By default, this cmdlet does not generate any output [-PassThru]
    .PARAMETER whatIf
    Whatif switch [-whatIf]
    .INPUTS
    Accepts piped input (computername).
    .OUTPUTS
    System.String
    .DESCRIPTION
    Add-ContentFixEncoding - Set-Content variant that auto-coerces the encoding to UTF8 
    .EXAMPLE
    PS> Add-ContentFixEncoding -Path c:\tmp\tmp20220503-1101AM.ps1 -Value 'write-host blah' -verbose ;
    Adds specified value to specified file, (auto-coercing encoding to UTF8)
    .EXAMPLE
    PS> $bRet = Add-ContentFixEncoding -Value $updatedContent -Path $outfile -PassThru -Verbose -whatif:$($whatif) ;
    PS> if (!$bRet) {throw "FAILURE" } ;
    Demo use of -PassThru to return the set Content, for validation
    .EXAMPLE
    PS> $bRet = $Content | Add-ContentFixEncoding @pltAdd ;
    PS> if(-not $bRet -AND -not $whatif){throw "Add-ContentFixEncoding $($pltAdd.Path)!" } ;
    PS> $PassStatus += ";Add-Content:UPDATED";    
    Demo with broader whatif-conditional post test, and $PassStatus support
    .LINK
    https://github.com/tostka/verb-io
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("US","GB","AU")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)]#positiveInt:[ValidateRange(0,[int]::MaxValue)]#negativeInt:[ValidateRange([int]::MinValue,0)][ValidateCount(1,3)]
    ## [OutputType('bool')] # optional specified output type
    [CmdletBinding()]
    ###[Alias('Alias','Alias2')]
    Param(
        #[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the path of the item that receives the content.[-Path c:\pathto\script.ps1]')]
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Specifies the path of the item that receives the content.[-Path c:\pathto\script.ps1]')]
        [Alias('PsPath','File')]
        [system.io.fileinfo[]]$Path,
        #[system.io.fileinfo]$Path,
        [Parameter(Mandatory = $true,Position = 1,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the new content for the item.[-value $content]')]
        [Alias('text','string')]
        #[System.Object[]]$Value,
        [System.Object]$Value,
        [Parameter(HelpMessage = "Specifies the type of encoding for the target file. The default value is 'UTF8'.[-encoding Unicode]")]
        [ValidateSet('Ascii','BigEndianUnicode','BigEndianUTF32','Byte','Default','Oem','String','Unicode','Unknown','UTF7','UTF8','UTF32')]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$encoding='UTF8',
        [Parameter(HelpMessage = "Returns an object that represents the content. By default, this cmdlet does not generate any output [-PassThru]")]
        [switch] $PassThru,
        [Parameter(HelpMessage = "Whatif switch [-whatIf]")]
        [switch] $whatIf
    ) ;
    # Get parameters this function was invoked with
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    write-verbose  "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
    $verbose = $($VerbosePreference -eq "Continue") ; 
    if(-not $DoRetries){$DoRetries = 4 } ;
    if(-not $RetrySleep){$RetrySleep = 10 } ; 
    $smsg = "(Add-ContentFixEncoding:$($val.FullName))" ;
    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    $enc=$null ; 
    $enc=get-FileEncoding -path $Path.FullName ;
    if($enc -eq 'ASCII') {
        $enc = 'UTF8' ;
        $smsg = "(ASCI encoding detected, converting to UTF8)" ;
        if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    } ; # force damaged/ascii to UTF8
    $pltSetCon = @{ Path=$Path.FullName ; ErrorAction = 'STOP' ; PassThru = $($PassThru); whatif=$($whatif) ;  } ;
    if($enc){$pltSetCon.add('encoding',$enc) } ;
    $smsg = "Set-Content w`n$(($pltSetCon|out-string).trim())" ; 
    $smsg += "`n-Value[0,2]:`n$(($value | out-string).Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)| select -first 2|out-string)" ; 
    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    $Exit = 0 ;
    Do {
        Try{
            $Returned = Add-Content @pltSetCon -Value $Value ;
            $Returned | write-output ;
            $Exit = $DoRetries ;
        }Catch{
            #Write-Error -Message $_.Exception.Message ;
            $ErrTrapd=$Error[0] ;
            $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #-=-record a STATUSWARN=-=-=-=-=-=-=
            $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
            if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
            if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
            Write-Warning "Unable to Add-ContentFixEncoding:$($Path.FullName)" ;
            $false | write-output ;
            start-sleep -s $RetrySleep ; 
            Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ;
    } Until ($Exit -eq $DoRetries) ;
}

#*------^ Add-ContentFixEncoding.ps1 ^------


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


#*------v backup-FileTDO.ps1 v------
function backup-FileTDO {
    <#
    .SYNOPSIS
    backup-FileTDO.ps1 - Create a backup of specified script. Simply replaces specified file's extension with a date-stamped variant: '[prior-extension]_yyyyMMdd-HHmmtt'
    .NOTES
    Version     : 1.0.2
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 1:43 PM 11/16/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 1:35 PM 5/20/2022 flipped echos w-h -> w-v
    * 11:53 AM 5/19/2022 ren: $pltBU -> $pltCpy
    * 8:58 AM 5/16/2022 added pipeline handling; ren backup-file -> backup-fileTDO (and alias orig name)
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 9:12 AM 12/29/2019 switch output to being the backupfile name ($pltBu.destination ), or $false for fail
    * 9:34 AM 12/11/2019 added dyanamic recycle of existing ext (got out of hardcoded .ps1)
    * 1:43 PM 11/16/2019 init
    .DESCRIPTION
    backup-FileTDO.ps1 - Create a backup of specified script. Simply replaces specified file's extension with a date-stamped variant: '[prior-extension]_yyyyMMdd-HHmmtt'
    .PARAMETER  Path
    Path to script
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUTS
    System.String, system.io.fileinfo
    .OUTPUTS
    System.String reflecting backup file fullname.

    .EXAMPLE
    PS> $bRet = backup-FileTDO -path $oSrc.FullName -showdebug:$($showdebug) -whatif:$($whatif)
    PS> if (!$bRet) {throw "FAILURE" } ;
    Backup specified file
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('backup-File')]
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = "Path to script[-Path path-to\script.ps1]")]
        [ValidateScript( { Test-Path $_ })]$Path,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN{
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        #$PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        $smsg = $sBnr = "#*======v $(${CmdletName}): v======" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else { write-verbose $smsg } ;

        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ;
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ;
            write-verbose "(non-pipeline - param - input)" ;
        } ;

        $Procd = 0 ; 
    } # BEG-E
    PROCESS{
        foreach($item in $path) {
            $Procd++ ;
            $fnparts = @() ; 
            $error.clear() ;
            Try {
                if ($item.GetType().FullName -ne 'System.IO.FileInfo') {
                    $item = get-childitem -path $item ;
                } ;
                $sBnrS = "`n#*------v ($($Procd)):$($item.fullname) v------" ;
                $smsg = "$($sBnrS)" ;
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-verbose $smsg } ; } ;

                $pltCpy = [ordered]@{
                    path        = $item.fullname ;
                    destination = $null ;
                    ErrorAction="Stop" ;
                    whatif      = $($whatif) ;
                } ;

                $fnparts = $item.BaseName ; 

                if($item.extension){
                    $pltCpy.destination = $item.fullname.replace($item.extension, "$($item.extension)_$(get-date -format 'yyyyMMdd-HHmmtt')") ;
                } ELSE { 
                    $fnparts += "." ; 
                    $fnparts += "_$(get-date -format 'yyyyMMdd-HHmmtt')" ; 
                    $pltCpy.destination = join-path (split-path $item.fullname) -childpath ($fnparts -join '') ; 
                } ; 
            } Catch {
                $ErrorTrapped = $Error[0] ;
                Write-WARNING "Failed to exec cmd because: $($ErrorTrapped)" ;
            }  ;

            $smsg = "BACKUP:copy-item w`n$(($pltCpy|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
            else{ write-verbose $smsg } ;
            $Exit = 0 ;
            Do {
                Try {
                    copy-item @pltCpy ;
                    $Exit = $Retries ;
                } Catch {
                    $ErrorTrapped = $Error[0] ;
                    Write-WARNING "Failed to exec cmd because: $($ErrorTrapped)" ;
                    Start-Sleep -Seconds $RetrySleep ;
                    $Exit ++ ;
                    Write-WARNING "Try #: $Exit" ;
                    If ($Exit -eq $Retries) { Write-Warning "Unable to exec cmd!" } ;
                }  ;
            } Until ($Exit -eq $Retries) ;

            # validate copies *exact*
            if (!$whatif) {
                if (Compare-Object -ReferenceObject $(Get-Content $pltCpy.path) -DifferenceObject $(Get-Content $pltCpy.destination)) {
                    $smsg = "BAD COPY!`n$pltCpy.path`nIS DIFFERENT FROM`n$pltCpy.destination!`nEXITING!";
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error }  #Error|Warn|Debug
                    else{ write-verbose $smsg } ;
                    $false | write-output ;
                } Else {
                    if ($showDebug) {
                        $smsg = "Validated Copy:`n$($pltCpy.path)`n*matches*`n$($pltCpy.destination)"; ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                        else{ write-verbose $smsg } ;
                    } ;
                    #$true | write-output ;
                    $pltCpy.destination | write-output ;
                } ;
            } else {
                #$true | write-output ;
                $pltCpy.destination | write-output ;
            };
            $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-verbose $smsg } ; } ;
        }  # loop-E
    } ;  # E PROC
    END{
        $smsg = $sBnr.replace('=v','=^').replace('v=','^=') ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-verbose $smsg } ;
    }
}

#*------^ backup-FileTDO.ps1 ^------


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


#*------v clear-HostIndent.ps1 v------
function clear-HostIndent {
    <#
    .SYNOPSIS
    clear-HostIndent - Utility cmdlet that clears/removes the $env:HostIndentSpaces (used when exiting script to avoid leaving process-level evari in place)
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : clear-HostIndent.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 2:19 PM 2/15/2023 broadly: moved $PSBoundParameters into test (ensure pop'd before trying to assign it into a new object) ; 
        typo fix, removed [ordered] from hashes (psv2 compat); 
    * 2:00 PM 2/2/2023 typo fix: (trailing block-comment end unmatched)
    * 2:01 PM 2/1/2023 add: -PID param; ported variant of reset-HostIndent
    * 2:39 PM 1/31/2023 updated to work with $env:HostIndentSpaces in process scope. 
    * 9:50 AM 1/17/2023 All need to be recoded to use evari's, scoped varis aren't consistently discoverable, to have the current 'indent depth' being tweaked by pop|push|reset|set and read by write:
    * 4:39 PM 1/11/2023 init
    .DESCRIPTION
    clear-HostIndent - Utility cmdlet that clears/removes the $env:HostIndentSpaces (used when exiting script to avoid leaving process-level evari in place)

            
    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reset-HostIndent # $env:HostIndentSpaces = 0 ; 
    clear-HostIndent # remove $env:HostIndentSpaces ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces -= 4
    set-HostIndent # explicit set to multiples of 4
            
    .PARAMETER PadIncrement
    Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]
    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .EXAMPLE
    PS> clear-HostIndent ;
    PS> $env:HostIndentSpaces ; 
    Simple indented text demo
    .EXAMPLE
    PS>  $domain = 'somedomain.com' ; 
    PS>  write-verbose "Top of code, establish 0 Indent" ;
    PS>  $env:HostIndentSpaces = 0 ;
    PS>  #...
    PS>  # indent & do nested thing
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  clear-HostIndent "Spf Version: $($spfElement)" -verbose ;
    PS>  # nested another level
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: += 4 Net:$($env:HostIndentSpaces)" ;
    PS>  clear-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  clear-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    Typical Usage      
    #>
    [CmdletBinding()]
    [Alias('c-hi')]
    PARAM(
        [Parameter(
            HelpMessage="Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]")]
        [int]$PadIncrement = 4,
        [Parameter(
            HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
            [switch]$usePID
    ) ;
    BEGIN {
    #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
    # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    if(($PSBoundParameters.keys).count -ne 0){
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
    } ;
    $Verbose = ($VerbosePreference -eq 'Continue') ;
    #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

    #if we want to tune this to a $PID-specific variant, use:
    if($usePID){
            $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $HISName = "Env:HostIndentSpaces$($PID)" ;
        } else {
            $HISName = "Env:HostIndentSpaces" ;
        } ;
        if(($smsg = Get-Item -Path "Env:HostIndentSpaces$($PID)" -erroraction SilentlyContinue).value){
            write-verbose $smsg ;
        } ;
        if (-not ([int]$CurrIndent = (Get-Item -Path $HISName -erroraction SilentlyContinue).Value ) ){
            [int]$CurrIndent = 0 ;
        } ;
        $pltSV=@{
            Path = $HISName ;
            Force = $true ;
            erroraction = 'STOP' ;
        } ;
        $smsg = "$($CmdletName): Set 1 lvl:Set-Variable w`n$(($pltSV|out-string).trim())" ;
        write-verbose $smsg  ;
        TRY{
            Clear-Item @pltSV  ;
        } CATCH {
            $smsg = $_.Exception.Message ;
            write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            BREAK ;
        } ;
    } ;  # BEG-E
}

#*------^ clear-HostIndent.ps1 ^------


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
    * 11:04 AM 4/25/2022 added CBH example output, and another example using Exchange Get-MailboxDatabaseCopyStatus results, between a pair of DAG nodes.
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
    Property     Col1    Col2
    --------     ----    ----
    Company      Amido   Google
    Forename     Richard Jane
    MaidenName           Jones
    SelfEmployed True
    Surname      Slater  Smith
    Display $object1 & $object2 in comparative side-by-side columns
    .EXAMPLE
    PS> $prpDBR = 'Name','Status', @{ Label ="CopyQ"; Expression={($_.CopyQueueLength).tostring("F0")}}, @{ Label ="ReplayQ"; Expression={($_.ReplayQueueLength).tostring("F0")}},@{ Label ="IndxState"; Expression={$_.ContentIndexState.ToSTring()}} ; 
    PS> $dbs0 = (Get-MailboxDatabaseCopyStatus -Server $srvr0.name -erroraction silentlycontinue | sort Status,Name| select $prpDBR) ; 
    PS> $dbs1 = (Get-MailboxDatabaseCopyStatus -Server $srvr1.name -erroraction silentlycontinue | sort Status,Name| select $prpDBR) ; 
    PS> Compare-ObjectsSideBySide $dbs0 $dbs1 | ft  property,col1,col2
    Property  Col1                                                                        Col2
    --------  ----                                                                        ----
    CopyQ     {0, 0, 0}                                                                   {0, 0, 0}
    IndxState {Healthy, Healthy, Healthy}                                                 {Healthy, Healthy, Healthy}
    Name      {SPBMS640Mail01\SPBMS640, SPBMS640Mail03\SPBMS640, SPBMS640Mail04\SPBMS640} {SPBMS640Mail01\SPBMS641, SPBMS640Mail03\SPBMS641, SPBMS640Mail04\SPBMS641}
    ReplayQ   {0, 0, 0}                                                                   {0, 0, 0}
    Status    {Mounted, Mounted, Mounted}                                                 {Healthy, Healthy, Healthy}
    Demo output with Exchange DAG database status from two nodes. Not as well formatted as prior demo, but still somewhat useful for side by side of DAG nodes. 
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
function Compare-ObjectsSideBySide3 {
    <#
    .SYNOPSIS
    Compare-ObjectsSideBySide3() - Displays four objects side-by-side comparatively in console
    .NOTES
    Author: Richard Slater
    Website:	https://stackoverflow.com/users/74302/richard-slater
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    FileName    : Compare-ObjectsSideBySide3.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Compare
    REVISIONS   :
    * 10:33 AM 4/25/2022 edit back to compliance, prior overwrite with cosbs4; , fixed pos param specs (uniqued); included output in exmplt
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 10:17 AM 9/15/2021 moved to full param block,expanded CBH
    * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
    * 10:18 AM 11/2/2018 Extension of base model, to 4 columns
    * May 7 '16 at 20:55 posted version
    .DESCRIPTION
    Compare-ObjectsSideBySide3() - Displays four objects side-by-side comparatively in console
    .PARAMETER col1
    Object to compare in 1st column[-col1 `$PsObject1]
    PARAMETER col2
    Object to compare in 2nd column[-col2 `$PsObject1]
    PARAMETER col3
    Object to compare in 3rd column[-col3 `$PsObject1]
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
    PS> Compare-ObjectsSideBySide3 $object1 $object2 $object3| Format-Table Property, col1, col2, col3;
    Property     Col1    Col2   Col3
    --------     ----    ----   ----
    Company      Amido   Google Apfel
    Forename     Richard Jane   Zhe
    MaidenName           Jones  NunaUBusiness
    SelfEmployed True
    Surname      Slater  Smith  Person
    Display $object1,2, & 3 in comparative side-by-side columns
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
        [Parameter(Position=2,Mandatory=$True,HelpMessage="Object to compare in 3rd column[-col1 `$PsObject1]")]
        #[Alias('rhs')]        
        $col3
    ) ;
    $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col3Members = $col3 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $combinedMembers = ($col1Members + $col2Members + $col3Members) | Sort-Object -Unique ;
    $combinedMembers | ForEach-Object {
        $properties = @{'Property' = $_} ;
        if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
        if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
        if ($col3Members.Contains($_)) {$properties['Col3'] = $col3 | Select-Object -ExpandProperty $_} ;
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
    * 10:32 AM 4/25/2022 fix typo, fixed pos param specs (uniqued); included output in exmplt
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
    PARAMETER col4
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
    Property     Col1    Col2   Col3          col4
    --------     ----    ----   ----          ----
    Company      Amido   Google Apfel         Facemook
    Forename     Richard Jane   Zhe           Zir
    MaidenName           Jones  NunaUBusiness Not!
    SelfEmployed True
    Surname      Slater  Smith  Person        NPC
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
        [Parameter(Position=2,Mandatory=$True,HelpMessage="Object to compare in 3rd column[-col1 `$PsObject1]")]
        #[Alias('rhs')]        
        $col3,
        [Parameter(Position=3,Mandatory=$True,HelpMessage="Object to compare in 4th column[-col1 `$PsObject1]")]
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

#*------^ Compare-ObjectsSideBySide4.ps1 ^------


#*------v Compress-ArchiveFile.ps1 v------
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
}

#*------^ Compress-ArchiveFile.ps1 ^------


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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes. 
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
        [ValidatePattern('^([\d\.]+)((\s)*)([KMGTP]iB)$')]
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
    * 3:08 PM 5/27/2022 CBH added example for select property expression; strongly typed output as double
    * 1:34 PM 2/25/2022 refactored CBH (was broken, non-parsing), renamed -data -> -string, retained prior name as a parameter alias
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    convert-DehydratedBytesToGB - Convert MS Dehydrated byte sizes string - 'NN.NN MB (nnn,nnn,nnn bytes)' string returned - into equivelent decimal gigabytes.
    Microsoft routinely returns storage values as space/parenthese-delimited string in units value, and a parenthetical comma'd bytes value. Neither of which is usable for comparison or sorting, unless converted to a single underlying unit of value. This does that conversion. 
    .PARAMETER String
    Array of Dehydrated byte sizes to be converted
    .PARAMETER Decimals
    Number of decimal places to return on results
    .INPUTS
    Accepts pipeline input. 
    .OUTPUTS
    System.Double
    .EXAMPLE
    PS> (get-mailbox -id hoffmjj | get-mailboxstatistics).totalitemsize | convert-DehydratedBytesToGB ;
    Convert a series of get-MailboxStatistics.totalitemsize.values ("102.8 MB (107,808,015 bytes)") into decimal gigabyte values.
    .EXAMPLE
    PS> $propsFldr = 'Name','ItemsInFolder', @{Name='FolderSizeGB';Expression={$_.FolderSize | convert-DehydratedBytesToGB -decimals 5 }},@{Name='TopSubjectSizeGB';Expression={$_.TopSubjectSize | convert-DehydratedBytesToGB -decimals 5 }},'TopSubject','TopSubjectCount','TopSubjectClass' ; 
    PS> Connect-ExchangeOnline ; 
    PS> $fldrstats = Get-XOMailboxFolderStatistics -Identity user@domain.com  -IncludeAnalysis -FolderScope RecoverableItems ; 
    PS>  $fldrstats | select $propsFldr |?{$_.TopSubjectSizeGB -gt 1}
    
    Name             : DiscoveryHolds
    ItemsInFolder    : 291212
    FolderSizeGB     : 98.03443
    TopSubjectSizeGB : 49.32737
    TopSubject       : Subject Meeting
    TopSubjectCount  : 29154
    TopSubjectClass  : IPM.Appointment
    
    Demo construction of a select-object properties array that includes expressions leveraging convert-DehydratedBytesToGB to produce decimal gigabyte sizes for EXO two dehydrated byte sizes properties (with 5-digit decimal values), and then postfiltering that value for oversize mailbox folders (with ExchangeOnlineManagement module)
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
                [double]($item -replace '.*\(| bytes\).*|,' |foreach-object {$FmtCode  -f ($_ / 1GB)}) | write-output ;
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
    convert-DehydratedBytesToMB - Convert MS Dehydrated byte sizes string returned - 'NN.NN MB (nnn,nnn,nnn bytes)' - into equivelent decimal megabytes.
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
    * 3:08 PM 5/27/2022 CBH added example for select property expression; strongly typed output as double
    * 1:34 PM 2/25/2022 refactored CBH (was broken, non-parsing), renamed -data -> -string, retained prior name as a parameter alias
    * 5:19 PM 7/20/2021 init vers
    .DESCRIPTION
    convert-DehydratedBytesToMB - Convert MS Dehydrated byte sizes string returned - 'NN.NN MB (nnn,nnn,nnn bytes)' - into equivelent decimal megabytes.
    .PARAMETER String
    Array of Dehydrated byte sizes to be converted
    .PARAMETER Decimals
    Number of decimal places to return on results
    .INPUTS
    Accepts pipeline input. 
    .OUTPUTS
    System.Double
    .EXAMPLE
    PS> (get-mailbox -id hoffmjj | get-mailboxstatistics).totalitemsize | convert-DehydratedBytesToMB ;
    Convert a series of get-MailboxStatistics.totalitemsize.values ("102.8 MB (107,808,015 bytes)") into decimal megabyte values.
    .EXAMPLE
    PS> $propsFldr = 'Name','ItemsInFolder', @{Name='FolderSizeMB';Expression={$_.FolderSize | convert-DehydratedBytesToMB -decimals 5 }},@{Name='TopSubjectSizeGB';Expression={$_.TopSubjectSize | convert-DehydratedBytesToGB -decimals 5 }},'TopSubject','TopSubjectCount','TopSubjectClass' ; 
    PS> Connect-ExchangeOnline ; 
    PS> $fldrstats = Get-XOMailboxFolderStatistics -Identity user@domain.com  -IncludeAnalysis -FolderScope RecoverableItems ; 
    PS>  $fldrstats | select $propsFldr |?{$_.TopSubjectSizeMB -gt 1}
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
                [double]($item -replace '.*\(| bytes\).*|,' |foreach-object {$FmtCode  -f ($_ / 1MB)}) | write-output ;
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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes. 
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
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
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
        [Parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
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
      [Parameter(Mandatory=$true,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
      [ValidateNotNullOrEmpty()]
      [string[]]$DistinguishedName
    )
    process{
        foreach ($DN in $DistinguishedName){
            foreach ( $item in ($DN.replace('\,','~').split(","))){
                switch ($item.TrimStart().Substring(0,2)){
                    'CN' {$CN = '/' + $item.Replace("CN=","")}
                    'OU' {$OU += ,$item.Replace("OU=","");$OU += '/'}
                    'DC' {$DC += $item.Replace("DC=","");$DC += '.'}
                }
            }
            $CanonicalName = $DC.Substring(0,$DC.length - 1)
            for ($i = $OU.count;$i -ge 0;$i -- ){
                $CanonicalName += $OU[$i]
            }
            if ( $DN.Substring(0,2) -eq 'CN' ){
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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
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
        [Parameter(Position=0,Mandatory=$true,HelpMessage="Enter the path to an INI file",
        ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
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
if($host.version.major -gt 2){
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
        * 4:43 PM 4/25/2022 cleanedup indents, added comments, for clarity; prefixed all internal funcs w _, to make them distinctive ; 
        fighting persistent error ipmo'ing into psv2:
        ```text
        <position> : The Data section is missing its statement block.
        + CategoryInfo          : ParserError: (:) [], ParentContainsErrorRecordException
        + FullyQualifiedErrorId : MissingStatementBlockForDataSection
        ```
        For now if it out anytime psv2 is in play. Nope, parser can't parse the content, so it won't even properly skip the function
        Psv2 appears unable to parse some aspect of this. 
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
        [CmdletBinding()]
        [OutputType([Object[]])]
        PARAM (
            [Parameter(ValueFromPipeLine = $True)]
            [String[]]$InputObject, 
            [String[]]$Header, 
            [String]$Ruler,
            [Alias("HDash")][Char]$HorizontalDash = '-', 
            [Alias("VDash")][Char]$VerticalDash = '|',
            [Char]$Junction = '+', 
            [Char]$Anchor = ':', 
            [String]$Omit, 
            [Switch]$Literal
        )
        BEGIN {
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
            
            #*======v FUNCTIONS INTERNAL v======
            Function Null {$Null}; Function True {$True}; Function False {$False};								# Wrappers
            
            #*------v Function _debug-Column v------
            Function _debug-Column {
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
            #*------^ END Function _debug-Column ^------
            #*------v Function _mask v------
            Function _mask([String]$Line, [Byte]$Or = [Mask]::Data) {
                $Init = [Mask]::All * ($Null -eq $Mask)
                If ($Init) {([Ref]$Mask).Value = New-Object Collections.Generic.List[Byte]}
                For ($i = 0; $i -lt ([Math]::Max($Mask.Count, $Line.Length)); $i++) {
                    If ($i -ge $Mask.Count) {([Ref]$Mask).Value.Add($Init)}
                    $Mask[$i] = If ($Line[$i] -Match '\S') {$Mask[$i] -bOr $Or} Else {$Mask[$i] -bAnd (0xFF -bXor [Mask]::All)}
                }
            }
            #*------^ END Function _mask ^------
            #*------v Function _slice v------
            Function _slice([String]$String, [Int]$Start, [Int]$End = [Int]::MaxValue) {
                If ($Start -lt 0) {$End += $Start; $Start = 0}
                If ($End -ge 0 -and $Start -lt $String.Length) {
                    If ($End -lt $String.Length) {$String.Substring($Start, $End - $Start + 1)} Else {$String.Substring($Start)}
                } Else {$Null}
            }
            #*------^ END Function _slice ^------
            #*------v Function _typeName v------
            Function _typeName([String]$TypeName) {
                If ($Literal) {
                    $Null, $TypeName.Trim()
                } Else {
                    $Null = $TypeName.Trim() -Match '(\[(.*)\])?\s*(.*)'
                    $Matches[2]
                    If($Matches[3]) {$Matches[3]} Else {$Matches[2]}
                }
            }
            #*------^ END Function _typeName ^------
            #*------v Function _errorRecord v------
            Function _errorRecord($Line, $Start, $End, $Message) {
                $msg =@"
$Message
$($Line -Replace '[\s]', ' ')
$(' ' * $Start)$('~' * ($End - $Start + 1))      
"@ ; 
    <# Psv2 is throwing error ipmo'ing: ": Missing expression after unary operator '+'."
    $Exception = New-Object System.InvalidOperationException "
$Message
+ $($Line -Replace '[\s]', ' ')
+ $(' ' * $Start)$('~' * ($End - $Start + 1))
"
#>
                $Exception = New-Object System.InvalidOperationException $msg  ; 
                New-Object Management.Automation.ErrorRecord $Exception,
                  $_.Exception.ErrorRecord.FullyQualifiedErrorId,
                  $_.Exception.ErrorRecord.CategoryInfo.Category,
                  $_.Exception.ErrorRecord.TargetObject
            }
            #*------^ END Function _errorRecord ^------
            #*======^ END FUNCTIONS INTERNAL ^======
            
        } # BEG-E
        PROCESS {
            $Lines = $InputObject -Split '[\r\n]+'
            If ($Omit) {
                $Lines = @(
                          ForEach ($Line in $Lines) {
                              ForEach ($Char in [Char[]]$Omit) {$Line = $Line.Replace($Char, ' ')}
                              $Line
                          }
                )
            } # if-E
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
                            } # if-E
                        } # if-E
                        If ($Line -NotMatch $RulerPattern) {
                            If ($VRx -and $Line -Match $VRx -and $TopLine -NotMatch $VRx) {$TopLine = $Line; $NextIndex = $Null}
                            ElseIf ($Null -eq $TopLine) {$TopLine = $Line}
                            ElseIf ($Null -eq $NextIndex) {$NextIndex = $Index}
                            $LastLine = $Line
                        }
                        If ($DataIndex) {Break}
                    } # if-E
                } # loop-E
                If (($Auto -or ($VRx -and $TopLine -Match $VRx)) -and $Null -ne $NextIndex) {
                  If ($Null -eq $HeaderLine) {
                      $HeaderLine = $TopLine
                      If ($Null -eq $Ruler) {$Ruler = ''}
                      $DataIndex = $NextIndex
                  } ElseIf ($Null -eq $Ruler) {
                      $Ruler = ''
                      $DataIndex = $NextIndex
                  } # if-E
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
                            $Type, $Name = If (@($Header).Count -le 1) {_typeName $Column.Trim()}
                                           ElseIf ($Index -lt @($Header).Count) {_typeName $Header[$Index]}
                            If ($Name) {
                                $End = $Start + $Length - 1
                                $Padding = [Math]::Min($Padding, $Column.Length - $Column.TrimStart().Length)
                                If ($Ruler -or $End -lt $HeaderLine.Length -1) {$Padding = [Math]::Min($Padding, $Column.Length - $Column.TrimEnd().Length)}
                                $Columns += @{Index = $Index; Name = $Column; Type = $Null; Start = $Start; End = $End}
                                $Property.Add($Name, $Null)
                            }
                            $Index++; $Start += $Column.Length + 1
                        } # loop-E
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
                            } # if-E
                            $Column.Type, $Column.Name = _typeName $Column.Name.Trim()
                            If ($Anchored) {
                                $Column.Alignment = [Alignment]::None
                                If ($Ruler[$Column.Start] -Match $ANx) {$Column.Alignment = $Column.Alignment -bor [Alignment]::Left}
                                If ($Ruler[$Column.End]   -Match $ANx) {$Column.Alignment = $Column.Alignment -bor [Alignment]::Right}
                            } Else {
                                $Column.Alignment = [Alignment]::Justified
                                If ($HeaderLine[$Column.Start + $Padding] -NotMatch '\S') {$Column.Alignment = $Column.Alignment -band -bnot [Alignment]::Left}
                                If ($HeaderLine[$Column.End   - $Padding] -NotMatch '\S') {$Column.Alignment = $Column.Alignment -band -bnot [Alignment]::Right}
                            } # if-E
                        } # loop-E
                    } Else {
                        _mask $HeaderLine ([Mask]::Header)
                        If ($Ruler) {_mask $Ruler ([Mask]::Ruler)}
                        $Lines | Select-Object -Skip $DataIndex | Where-Object {$_.Trim()} | Foreach-Object {_mask $_}
                        If (!$Ruler -and $HRx) {									# Connect (rulerless) single spaced headers where either column is empty
                            $InWord = $False; $WordMask = 0
                            For ($i = 0; $i -le $Mask.Count; $i++) {
                                If($i -lt $Mask.Count) {$WordMask = $WordMask -bor $Mask[$i]}
                                $Masked = $i -lt $Mask.Count -and $Mask[$i]
                                If ($Masked -and !$InWord) {$InWord = $True; $Start = $i}
                                ElseIf (!$Masked -and $InWord) {
                                    $InWord = $False; $End = $i - 1
                                    If ([Mask]::Header -eq $WordMask -bAnd 7) {		# only header
                                      If ($Start -ge 2 -and $Mask[$Start - 2] -band [Mask]::Header) {$Mask[$Start - 1] = [Mask]::Header}
                                      ElseIf (($End + 2) -lt $Mask.Count -and $Mask[$End + 2] -band [Mask]::Header) {$Mask[$End + 1] = [Mask]::Header}
                                    }
                                    $WordMask = 0
                                }
                            } # loop-E
                        } # if-E
                        $InWord = $False; $Index = 0; $Start = $Null
                        For ($i = 0; $i -le $Mask.Count; $i++) {
                            $Masked = $i -lt $Mask.Count -and $Mask[$i]
                            If ($Masked -and !$InWord) {$InWord = $True; $Start = $i}
                            ElseIf (!$Masked -and $InWord) {
                                $InWord = $False; $End = $i - 1
                                $Type, $Name = If (@($Header).Count -le 1) {_typeName "$(_slice -String $HeaderLine -Start $Start -End $End)".Trim()}
                                               ElseIf ($Index -lt @($Header).Count) {_typeName $Header[$Index]}
                                If ($Name) {
                                    If ($Columns.Where{$_.Name -eq $Name}) {Write-Warning "Duplicate column name: $Name."}
                                    Else {
                                        If ($Type) {
                                            $Type = Try {[Type]$Type} Catch {
                                              Write-Error -ErrorRecord (_errorRecord -Line $HeaderLine -Start $Start -End $End -Message (
                                                "Unknown type {0} in header at column '{1}'" -f $Type, $Name
                                              ))
                                            }
                                        } # if-E
                                        $Columns += @{Index = $Index++; Name = $Name; Type = $Type; Start = $Start; End = $End; Alignment = $Null}
                                        $Property.Add($Name, $Null)
                                    } # if-E
                                } # if-E
                            }
                        } # loop-E
                    } # if-E
                    $RulerPattern = If ($Ruler) {'^' + ($Ruler -Replace "[^$HRx]", "[$VRx$JNx$ANx\s]" -Replace "[$HRx]", "[$HRx]")} Else {'\A(?!x)x'}
                } # if-E
            } # if-E -not cols
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
                            } # if-E
                        } # if-E
                    } # loop-E
                } Else {
                    $HeadMask = If ($Ruler) {[Mask]::Header -bOr [Mask]::Ruler} Else {[Mask]::Header}
                    $Lines | Select-Object -Skip (0 + $DataIndex) | Where-Object {$_.Trim()} | Foreach-Object {_mask $_}
                    For ($c = 0; $c -lt $Columns.Length; $c++) {
                        $Column = $Columns[$c]
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
                        } # if-E
                    } # loop-E
                }
                If ($DebugPreference -ne 'SilentlyContinue' -and !$RowIndex) {Write-Debug ($HeaderLine -Replace '\s', ' '); _debug-Column}
                ForEach ($Line in ($Lines | Select-Object -Skip ([Int]$DataIndex))) {
                    If ($Line.Trim() -and ($Line -NotMatch $RulerPattern)) {
                        $RowIndex++
                        If ($DebugPreference -ne 'SilentlyContinue') {Write-Debug ($Line -Replace '\s', ' ')}
                        $Fields = If ($VRx -and $Line -notlike $Mask) {$Line -Split $VRx}
                        ForEach($Column in $Columns) {
                            $Property[$Column.Name] = If ($Fields) {
                                    $Fields[$Column.Index].Trim()
                                } Else {
                                    $Field = _slice -String $Line -Start $Column.Start -End $Column.End
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
                                                    Write-Error -ErrorRecord (_errorRecord -Line $Line -Start $Column.Start -End $Column.End -Message (
                                                      "The expression '{0}' in row {1} at column '{2}' can't be evaluated. Check the syntax or use the -Literal switch." -f $Value, $RowIndex, $Column.Name
                                                    ))
                                                }
                                            } ElseIf ($Column.Type) {
                                                Try {&([Scriptblock]::Create("[$($Column.Type)]`$Value"))}
                                                Catch {$Value
                                                    Write-Error -ErrorRecord (_errorRecord -Line $Line -Start $Column.Start -End $Column.End -Message (
                                                      "The value '{0}' in row {1} at column '{2}' can't be converted to type {1}." -f $Valuee, $RowIndex, $Column.Name, $Column.Type
                                                    ))
                                                }
                                            } Else {$Value}
                                        } Else {$Value}
                                    } Else {''}
                              } # if-E
                        } # loop-E
                        New-Object PSObject -Property $Property
                    } # if-E
                } # loop-E
                If ($DebugPreference -ne 'SilentlyContinue' -and $RowIndex) {_debug-Column}
            }  # if-E cols
        } # PROC-E
    };
    #*------^ END Function ConvertFrom-SourceTable ^------
}

#*------^ ConvertFrom-SourceTable.ps1 ^------


#*------v ConvertFrom-UncPath.ps1 v------
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
}

#*------^ ConvertFrom-UncPath.ps1 ^------


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


#*------v Convert-NumbertoWords.ps1 v------
function Convert-NumbertoWords {
    <#
    .SYNOPSIS
    Convert-NumbertoWords - Converts any number up to the octillions to its word equivilent. Example: 1,234,567 = one million two hundred thirty-four thousand five hundred sixty-seven.
    .NOTES
    Version     : 0.0.5
    Author      : smithcbp
    Website     : https://github.com/smithcbp
    Twitter     : 
    CreatedDate : 2023-01-06
    FileName    : Convert-NumbertoWords
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Text
    AddedCredit : Todd Kadrie
    AddedWebsite: http://www.toddomation.com
    AddedTwitter: @tostka / http://twitter.com/tostka
    REVISIONS
    * 11:01 AM 1/9/2023 _convert-3DigitNumberToWords():TSK: fixed bug: wasn't pretesting number places, to ensure enough digits to support 10s & hundreds.
        add: CBH example, and _-prefixed internal func; flip output from string of both comma & text to object w both as props, trim() text output (has trailing space)
    * 5:06 PM 1/6/2023 TSK fixed a bug - it didn't properly accomdate '000' sets - which aren't pronounced, but are part of bumping the setting up a level; 
    added CBH ; 
    added pipeline support on the IPAddress input ; simplfied compound stmts ; added to verb-Network.
    * Apr 17, 2018 smithcbp posted github version from: https://github.com/smithcbp/Powershell-Convert-NumbertoWords/blob/main/Convert-NumbertoWords.ps1
    .DESCRIPTION
    Convert-NumbertoWords - Converts any number up to the octillions to its word equivilent. Example: 1,234,567 = one million two hundred thirty-four thousand five hundred sixty-seven.

    Convert a Number to Words

    Converts any number up to the octillions to its word equivilent. Example: 1,234,567 = one million two hundred thirty-four thousand five hundred sixty-seven

    .PARAMETER number
    Number to be represented as a spoken sentance[-Numnber 123456
    .INPUTS
    Does not accepted piped input
    .OUTPUTS
    System.string
    .EXAMPLE
    PS> if(get-command -name Convert-NumberToWords -ea 0){
    PS>     $textNum = Convert-NumbertoWords -number ($subnet.HostAddressCount+1) ; 
    PS>     $smsg += "(`nThat's $($textNum.text) ip addresses" ; 
    PS> } ; 
    PS> write-host $smsg ; 
    .LINK
    https://github.com/tostka/verb-IO
    https://github.com/smithcbp/Powershell-Convert-NumbertoWords/blob/main/Convert-NumbertoWords.ps1
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("US","GB","AU")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)]#positiveInt:[ValidateRange(0,[int]::MaxValue)]#negativeInt:[ValidateRange([int]::MinValue,0)][ValidateCount(1,3)]
    [outputtype([System.String])]
    [CmdletBinding()]
    PARAM(
        [parameter(Mandatory=$true, Position=0,ValueFromPipeline = $True,HelpMessage="Number to be represented as a spoken sentance[-Numnber 123456")]
        $number
    ) ; 
    $verbose = ($VerbosePreference -eq "Continue") ;

    #$ErrorActionPreference = "SilentlyContinue"
    $numbercommas = [string]::Format('{0:N0}',$number)
    $numbergroups = $numbercommas -split ',' ; # (e.g. split into 'thousands, millions' groups)
    
    #*======v FUNCTIONS v======

    #*------v Function _convert-3DigitNumberToWords v------
    Function _convert-3DigitNumberToWords {
        <# .NOTES
            REVISIONS
            * 11:01 AM 1/9/2023 _convert-3DigitNumberToWords():TSK: fixed bug: wasn't pretesting number places, to ensure enough digits to support 10s & hundreds.
        #> 
        Param([int]$number)
        $wordarray = @{
            1 = 'one';
            2 = 'two';
            3 = 'three';
            4 = 'four';
            5 = 'five';
            6 = 'six';
            7 = 'seven';
            8 = 'eight';
            9 = 'nine';
            10 = 'ten';
            11 = 'eleven';
            12 = 'twelve';
            13 = 'thirteen';
            14 = 'fourteen';
            15 = 'fifteen';
            16 = 'sixteen';
            17 = 'seventeen';
            18 = 'eighteen';
            19 = 'nineteen';
            20 = 'twenty';
            30 = 'thirty';
            40 = 'forty';
            50 = 'fifty';
            60 = 'sixty';
            70 = 'seventy';
            80 = 'eighty';
            90 = 'ninety';
        } ; 
        
        if ($number -le 19){
            $word = $wordarray.$($number) ; 
        } ; 
            
        $Ones = $number.ToString().ToCharArray()[-1].ToString().ToInt32($null) ; 
        # pre-test char count before taking -gt 1:
        if(($number.ToString().ToCharArray().count -gt 1)){
            $Tens = $number.ToString().ToCharArray()[-2].ToString().ToInt32($null) ; 
        } ; 
        if(($number.ToString().ToCharArray().count -gt 2)){
            $Hundreds = $number.ToString().ToCharArray()[-3].ToString().ToInt32($null) ; 
        } ;
        $OnesTens = (-join ($number.ToString().ToCharArray()[-2..-1])).ToInt32($null) ; 

        if ($Hundreds -ge 1) {
            $HundredsWord = "$($wordarray.($hundreds)) hundred" ; 
        } ; 
        if ($OnesTens -le 19) {
            $OneTensWord = $wordarray.($OnesTens) ; 
        } ; 
        if ($Tens -ge 2 ) {
            $Tensword = $wordarray.($Tens * 10) ; 
            $Onesword = $wordarray.($Ones)  ; 
            if ($onestens % 10 -eq 0){$OneTensWord = $Tensword}
            else {$OneTensWord = $Tensword + '-' + $Onesword} ; 
        } ; 

        $finalwordarray = @($hundredsword,$OneTensword) ; 
        $finalwordarray = $finalwordarray | where-Object {$_} ; 
        $finalwordarray -join " " ; 
    }
    #*------^ END Function _convert-3DigitNumberToWords ^------
    #*======^ END FUNCTIONS ^======

    #*======v SUB MAIN v======
    $groupwordarray = foreach ($numbergroup in $numbergroups) {
        if($numbergroup -eq '000'){
            write-verbose "c3dntw uses [int] numbers, 000 isn't an integer (other than 0, but comes in as a string)..." ; 
            # drop a marker in to ensure gorup bump occurs at the right place
            '000'
        } else { 
            _convert-3DigitNumberToWords -number $numbergroup ; 
        } ; 
    } ; 

    $thouwordhash = @{
        1 = '' ;
        2 = 'thousand' ;
        3 = 'million' ;
        4 = 'billion' ;
        5 = 'trillion' ;
        6 = 'quadrillion' ;
        7 = 'quintillion' ;
        8 = 'sextillion' ;
        9 = 'septillion' ;
        10 = 'octillion'    ;        
    } ; 

    [array]::reverse($groupwordarray) ; 

    $i = 0 ; 
    $modifiedgroups = foreach($group in $groupwordarray){
        $i++ ; 
        if ($group -eq '000'){
             write-verbose 'suppress zeros, not pronounced, bump position' ; 
        }elseif ($group){ 
            Write-Output "$group $($thouwordhash.$i)" 
        } ; 
    } ; 
    
    [array]::reverse($modifiedgroups) ; 
    
    <# 
    if($VerbosePreference -eq "Continue"){
        $numbercommas ; 
    } ; 
    $modifiedgroups -join ' ' ; 
    #>
    #emit an object with both, not a string ; 
    New-Object PSObject -Property @{
        Number = $numbercommas ;
        Text = ($modifiedgroups -join ' ').Trim() ; 
    } | write-output ; 

    #*======^ END SUB MAIN ^======
}

#*------^ Convert-NumbertoWords.ps1 ^------


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
    * 10:58 AM 7/13/2022 added -NoPadding to suppress column alignment; added CBH examples: one that demos prettying up handbuilt md tables comboing convertfrom-md | convertto-mdt, and one that demos -NoPadding use with -Tight (produce tightest md tbl output)
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 4:04 PM 9/16/2021 coded around legacy code issue, when using [ordered] hash - need it or it randomizes column positions. Also added -NoDashRow param (breaks md rendering, but useful if using this to dump delimited output to console, for readability)
    * 10:51 AM 6/22/2021 added convertfrom-mdt alias
    * 4:49 PM 6/21/2021 pretest $thing.value: suppress errors when $thing.value is $null (avoids:'You cannot call a method on a null-valued expression' trying to eval it's null value len).
    * 10:49 AM 2/18/2021 added default alias: out-markdowntable & out-mdt
    * 8:29 AM 1/20/2021 - ren'd convertto-Markdown -> convertTo-MarkdownTable (avoid conflict with PSScriptTools cmdlet, also more descriptive as this *soley* produces md tables from objects; spliced in -Title -PreContent -PostContent params ; added detect & flip hashtables to cobj: gets them through, but end up in ft -a layout ; updated CBH, added -Border & -Tight params, integrated *some* of forked fixes by Matticusau: A couple of aliases changed to full cmdlet name for best practices;Extra Example for how I use this with PSScriptAnalyzer;
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
    .PARAMETER NoPadding
    Switch to suppress column-width alignment via spaces (creates tightest md output)
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
    PS> ConvertTo-Markdown | Out-File C:\MyScript.ps1.md ; 
    Converts output of PSScriptAnalyzer to a Markdown report file using selected properties
    .EXAMPLE
    PS> Get-Service Bits,Winrm | select status,name,displayname | 
        Convertto-Markdowntable -Title 'This is Title' -PreContent 'A little something *before*' -PostContent 'A little something *after*' ; 
    Demo use of -title, -precontent & -postcontent params:
    .EXAMPLE
    PS> 
.EXAMPLE
    PS>  $pltcMT=[ordered]@{
    PS>      Title='This is Title' ;
    PS>      PreContent='A little something *before*' ;
    PS>      PostContent='A little something *after*'
    PS>  } ;
    PS>  Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable @pltcMT ; 
    Same as prior example, but leveraging more readable splatting
    .EXAMPLE
    PS> Get-Service Bits,Winrm | select status,name,displayname | Convertto-Markdowntable -NoDashRow
        Status  | Name  | DisplayName                              
        Stopped | Bits  | Background Intelligent Transfer Service  
        Running | Winrm | Windows Remote Management (WS-Management)
    Demo effect of -NoDashRow param (drops header-seperator line)
    .EXAMPLE
    PS> gci d:\scripts\*_func.ps1 | select name,fullname,length | convertto-markdowntable -border -NoPadding -tight -verbose ;
        |Name|FullName|Length|
        |---|---|---|
        |add-AADUserLicense_func.ps1|D:\scripts\add-AADUserLicense_func.ps1|17747|
        |toggle-AADLicense_func.ps1|D:\scripts\toggle-AADLicense_func.ps1|26482|
    Demo -NoPadding + -border + -tight , on 3 cols of file specs (tightest possible md table output)
    .EXAMPLE
    PS> @"
    PS> |tag|ResourceString|
    PS> |---|---|
    PS> |aad_graph_api|https://graph.windows.net|
    PS> |spacesapi|https://api.spaces.skype.com|
    PS> "@ | convertfrom-markdowntable | convertto-markdowntable -border ;
        | tag           | ResourceString               |
        | ------------- | ---------------------------- |
        | aad_graph_api | https://graph.windows.net    |
        | spacesapi     | https://api.spaces.skype.com |
    Pretty up a minimal hand-built mdtable (from herestring), into space-aligned using convertFrom-MarkdownTable | ConvertTo-MarkdownTable 
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
        [Parameter(HelpMessage="Switch to suppress column-width alignment via spaces (creates tightest md output) [-NoPadding]")]
        [switch] $NoPadding,
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
            # this is doing the padding
            if(-not $NoPadding){
                $header += ('{0,-' + $columns[$key] + '}') -f $key ;
            } else { 
                $header += $key ;
            } ; 
        } ;
        if(!$Border){
            $output += ($header -join $Delimiter) + "`n" ; 
        }else{
            $output += $BorderLeft + ($header -join $Delimiter) + $BorderRight + "`n" ; 
        } ;
        $separator = @() ;
        ForEach($key in $columns.Keys) {
            if(-not $NoPadding){
                $separator += '-' * $columns[$key] ;
            } else { 
                # static md table min, 3 dashes
                $separator += '-' * 3 ;
            } ;
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
                if(-not $NoPadding){
                    $values += ('{0,-' + $columns[$key] + '}') -f $item.($key) ;
                } else { 
                    $values += $item.($key) ;
                } ; 
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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
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
            ValueFromPipeline=$true,
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


#*------v ConvertTo-UncPath.ps1 v------
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
}

#*------^ ConvertTo-UncPath.ps1 ^------


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
    [Alias('convert-ToMp3','convert-VideoToMp3')]
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


#*------v Expand-ArchiveFile.ps1 v------
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
}

#*------^ Expand-ArchiveFile.ps1 ^------


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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
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
        [Parameter(Mandatory=$true)][string]$FileName,
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


#*------v get-AliasDefinition.ps1 v------
Function get-AliasDefinition {
    <#
    .SYNOPSIS
    get-AliasDefinition.ps1 - Returns alias with matching specified definition (Tired of typing |? where definition -eq 'xxx' ; can it up in a function). Has alias 'gald' (variant of the get-alias: gal alias).
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-04-29
    FileName    : get-AliasDefinition.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    REVISIONS
    * 8:31 AM 4/29/2022init vers
    .DESCRIPTION
    get-AliasDefinition.ps1 - Returns alias with matching specified definition (Tired of typing get-alias |? where definition -eq 'xxx' ; can it up in a function). Has alias 'gald' (variant of the get-alias: gal alias).
    Base params on: new-alias -Name -Value
    .PARAMETER Value <System.String>
    Specifies the name of the cmdlet or command that the alias runs. The Value parameter is the alias's Definition property.
    .OUTPUT
    System.Management.Automation.CommandInfo
    .EXAMPLE
    get-AliasDefinition -value 'select-string'
    Find the Alias for the 'select-string' cmdlet.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [Alias('gald')]
    [CmdletBinding()]
    Param (
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Specifies the name of the cmdlet or command that the alias runs. The Value parameter is the alias's Definition property. [-value 'select-string']")]
        [ValidateNotNullOrEmpty()]
        [Alias('Definition')]
        [string]$Value
    )
    $smsg += "Locate existing alias for Value (Definition):$($value)" ;
    write-verbose $smsg  ;
    # use oldest supported where syntax, for largest backward compat.
    get-alias | ?{$_.Definition -eq $value} | write-output ;
}

#*------^ get-AliasDefinition.ps1 ^------


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
    * 8:53 AM 4/29/2022 add: Alias gclr; ValueFromPipeline (now supports pipeline input); updated CBH
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 1:46 PM 3/5/2021 set DefaultParameterSetName='Random' to actually make 'no-params' default that way, also added $defaultPSCombo (DarkYellow:DarkMagenta), and added it as the 'last' combo in the combo array 
    * 3:15 PM 12/29/2020 fixed typo in scheme parse (quotes broke the hashing), pulled 4 low-contrast schemes out
    * 1:22 PM 5/10/2019 init version
    .DESCRIPTION
    get-colorcombo - Return a readable console fg/bg color combo (commonly for use with write-host blocks to id variant datatypes across a series of tests)
    
Available stock powershell color names (for constructing combos): Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White    

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
    [Alias('gclr')]
    [CmdletBinding(DefaultParameterSetName='Random')]
    # ParameterSetName='EXCLUSIVENAME'
    Param(
        [Parameter(ParameterSetName='Combo',Position = 0, ValueFromPipeline=$true, HelpMessage = "Combo Number (0-73)[-Combo 65]")][int]$Combo,
        [Parameter(ParameterSetName='Random',HelpMessage = "Returns a random Combo [-Random]")][switch]$Random,
        [Parameter(ParameterSetName='Demo',HelpMessage = "Dumps a table of all combos for review[-Demo]")][switch]$Demo
    )
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    if (-not($Demo) -AND -not($Combo) -AND -not($Random)) {
        write-host "(No -combo or -demo specified: Asserting a 'Random' scheme)" ;
        $Random=$true ; 
    } ;
    # rem'd, low-contrast removals: "DarkYellow;Green", "DarkYellow;Cyan","DarkYellow;Yellow", "DarkYellow;White", 
    # array of color combo definitions in format: "[BackgroundColor];[ForegroundColor]"
    $schemes = "Black;DarkYellow", "Black;Gray", "Black;Green", "Black;Cyan", "Black;Red", "Black;Yellow", "Black;White", "DarkGreen;Gray", "DarkGreen;Green", "DarkGreen;Cyan", "DarkGreen;Magenta", "DarkGreen;Yellow", "DarkGreen;White", "White;DarkGray", "DarkRed;Gray", "White;Blue", "White;DarkRed", "DarkRed;Green", "DarkRed;Cyan", "DarkRed;Magenta", "DarkRed;Yellow", "DarkRed;White", "DarkYellow;Black", "White;DarkGreen", "DarkYellow;Blue",  "Gray;Black", "Gray;DarkGreen", "Gray;DarkMagenta", "Gray;Blue", "Gray;White", "DarkGray;Black", "DarkGray;DarkBlue", "DarkGray;Gray", "DarkGray;Blue", "Yellow;DarkGreen", "DarkGray;Green", "DarkGray;Cyan", "DarkGray;Yellow", "DarkGray;White", "Blue;Gray", "Blue;Green", "Blue;Cyan", "Blue;Red", "Blue;Magenta", "Blue;Yellow", "Blue;White", "Green;Black", "Green;DarkBlue", "White;Black", "Green;Blue", "Green;DarkGray", "Yellow;DarkGray", "Yellow;Black", "Cyan;Black", "Yellow;Blue", "Cyan;Blue", "Cyan;Red", "Red;Black", "Red;DarkGreen", "Red;Blue", "Red;Yellow", "Red;White", "Magenta;Black", "Magenta;DarkGreen", "Magenta;Blue", "Magenta;DarkMagenta", "Magenta;Blue", "Magenta;Yellow", "Magenta;White" ;
    $defaultPSCombo = @{BackgroundColor = 'DarkMagenta' ; ForegroundColor = 'DarkYellow'} ;
    $colorcombo = @{} ;
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


#*------v get-ColorNames.ps1 v------
function get-ColorNames {
    <#
    .SYNOPSIS
    get-ColorNames - Outputs a color-chart grid of all write-host -backgroundcolor & -foregroundcolors comboos, for easy selection of suitable combos for output. 
    .NOTES
	Author      : Todd Kadrie
	Website     : http://www.toddomation.com
	Twitter     : @tostka / http://twitter.com/tostka
	CreatedDate : 2023-01-30
	FileName    : get-ColorNames.ps1
	License     : MIT License
	Copyright   : (c) 2023 Todd Kadrie
	Github      : https://github.com/tostka/verb-IO
	Tags        : Powershell
	AddedCredit : REFERENCE
	AddedWebsite: URL
	AddedTwitter: URL
    REVISIONS
    * 8:42 AM 2/16/2023 hybrided in new -narrow support (for psv2/ISE); added PARAM() block; -Narrow & -MaxColumns to support, stdized the vari names across both (shorter names , as this also winds up in psb-pscolors.cbp, unwrapped); updated CBH to include; added bnr support to both.
    * 4:24 PM 2/1/2023 typo, trailing missing }
    * 4:24 PM 1/30/2023 flipped freeshtanding script to function in verb-io 
    .DESCRIPTION
    get-ColorNames - Outputs a color-chart grid of all write-host -backgroundcolor & -foregroundcolors comboos, for easy selection of suitable combos for output. 
    
    Simple nested loop on the default consolecolor foreground & background color combos.
    .PARAMETER Narrow
    Optional Parameter to use a narrower layout, grouped by foreground color [-Narrow]
    .PARAMETER MaxColumns
    Optional Parameter to specify the number of columns of colors to display per line, in the -Narrow layout (defaults to 4)[-MaxColumns 5]
    .INPUTS
    Does not accepted piped input
    .OUTPUTS
    None.
    .EXAMPLE
    PS> get-ColorNames ;
    
          #*------v PS WIDE CONSOLE COLOR TABLE v------
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Black
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkBlue
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkGreen
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkCyan
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkRed
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkMagenta
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkYellow
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Gray
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on DarkGray
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Blue
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Green
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Cyan
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Red
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Magenta
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on Yellow
          Black|DarkBlue|DarkGreen|DarkCyan|DarkRed|DarkMagenta|DarkYellow|Gray|DarkGray|Blue|Green|Cyan|Red|Magenta|Yellow|White| on White
          08:34:49:
          #*------^ PS WIDE CONSOLE COLOR TABLE ^------
		
    Demo typical pass output (obviously rendered in appriate colors in actual console output).
    .EXAMPLE
    PS>  get-ColorNames -Narrow ;
     
          11:55:11:
          #*------v PS NARROW/ADJ-WIDTH CONSOLE COLOR TABLE v------
          Black on Black|Black on DarkBlue|Black on DarkGreen|Black on DarkCyan|
          Black on DarkRed|Black on DarkMagenta|Black on DarkYellow|Black on Gray|
          Black on DarkGray|Black on Blue|Black on Green|Black on Cyan|
          Black on Red|Black on Magenta|Black on Yellow|Black on White|

          DarkBlue on Black|DarkBlue on DarkBlue|DarkBlue on DarkGreen|DarkBlue on DarkCyan|
          DarkBlue on DarkRed|DarkBlue on DarkMagenta|DarkBlue on DarkYellow|DarkBlue on Gray|
          DarkBlue on DarkGray|DarkBlue on Blue|DarkBlue on Green|DarkBlue on Cyan|
          DarkBlue on Red|DarkBlue on Magenta|DarkBlue on Yellow|DarkBlue on White|

          DarkGreen on Black|DarkGreen on DarkBlue|DarkGreen on DarkGreen|DarkGreen on DarkCyan|
          DarkGreen on DarkRed|DarkGreen on DarkMagenta|DarkGreen on DarkYellow|DarkGreen on Gray|
          DarkGreen on DarkGray|DarkGreen on Blue|DarkGreen on Green|DarkGreen on Cyan|
          DarkGreen on Red|DarkGreen on Magenta|DarkGreen on Yellow|DarkGreen on White|

          DarkCyan on Black|DarkCyan on DarkBlue|DarkCyan on DarkGreen|DarkCyan on DarkCyan|
          DarkCyan on DarkRed|DarkCyan on DarkMagenta|DarkCyan on DarkYellow|DarkCyan on Gray|
          DarkCyan on DarkGray|DarkCyan on Blue|DarkCyan on Green|DarkCyan on Cyan|
          DarkCyan on Red|DarkCyan on Magenta|DarkCyan on Yellow|DarkCyan on White|

          DarkRed on Black|DarkRed on DarkBlue|DarkRed on DarkGreen|DarkRed on DarkCyan|
          DarkRed on DarkRed|DarkRed on DarkMagenta|DarkRed on DarkYellow|DarkRed on Gray|
          DarkRed on DarkGray|DarkRed on Blue|DarkRed on Green|DarkRed on Cyan|
          DarkRed on Red|DarkRed on Magenta|DarkRed on Yellow|DarkRed on White|

          DarkMagenta on Black|DarkMagenta on DarkBlue|DarkMagenta on DarkGreen|DarkMagenta on DarkCyan|
          DarkMagenta on DarkRed|DarkMagenta on DarkMagenta|DarkMagenta on DarkYellow|DarkMagenta on Gray|
          DarkMagenta on DarkGray|DarkMagenta on Blue|DarkMagenta on Green|DarkMagenta on Cyan|
          DarkMagenta on Red|DarkMagenta on Magenta|DarkMagenta on Yellow|DarkMagenta on White|

          DarkYellow on Black|DarkYellow on DarkBlue|DarkYellow on DarkGreen|DarkYellow on DarkCyan|
          DarkYellow on DarkRed|DarkYellow on DarkMagenta|DarkYellow on DarkYellow|DarkYellow on Gray|
          DarkYellow on DarkGray|DarkYellow on Blue|DarkYellow on Green|DarkYellow on Cyan|
          DarkYellow on Red|DarkYellow on Magenta|DarkYellow on Yellow|DarkYellow on White|

          Gray on Black|Gray on DarkBlue|Gray on DarkGreen|Gray on DarkCyan|
          Gray on DarkRed|Gray on DarkMagenta|Gray on DarkYellow|Gray on Gray|
          Gray on DarkGray|Gray on Blue|Gray on Green|Gray on Cyan|
          Gray on Red|Gray on Magenta|Gray on Yellow|Gray on White|

          DarkGray on Black|DarkGray on DarkBlue|DarkGray on DarkGreen|DarkGray on DarkCyan|
          DarkGray on DarkRed|DarkGray on DarkMagenta|DarkGray on DarkYellow|DarkGray on Gray|
          DarkGray on DarkGray|DarkGray on Blue|DarkGray on Green|DarkGray on Cyan|
          DarkGray on Red|DarkGray on Magenta|DarkGray on Yellow|DarkGray on White|

          Blue on Black|Blue on DarkBlue|Blue on DarkGreen|Blue on DarkCyan|
          Blue on DarkRed|Blue on DarkMagenta|Blue on DarkYellow|Blue on Gray|
          Blue on DarkGray|Blue on Blue|Blue on Green|Blue on Cyan|
          Blue on Red|Blue on Magenta|Blue on Yellow|Blue on White|

          Green on Black|Green on DarkBlue|Green on DarkGreen|Green on DarkCyan|
          Green on DarkRed|Green on DarkMagenta|Green on DarkYellow|Green on Gray|
          Green on DarkGray|Green on Blue|Green on Green|Green on Cyan|
          Green on Red|Green on Magenta|Green on Yellow|Green on White|

          Cyan on Black|Cyan on DarkBlue|Cyan on DarkGreen|Cyan on DarkCyan|
          Cyan on DarkRed|Cyan on DarkMagenta|Cyan on DarkYellow|Cyan on Gray|
          Cyan on DarkGray|Cyan on Blue|Cyan on Green|Cyan on Cyan|
          Cyan on Red|Cyan on Magenta|Cyan on Yellow|Cyan on White|

          Red on Black|Red on DarkBlue|Red on DarkGreen|Red on DarkCyan|
          Red on DarkRed|Red on DarkMagenta|Red on DarkYellow|Red on Gray|
          Red on DarkGray|Red on Blue|Red on Green|Red on Cyan|
          Red on Red|Red on Magenta|Red on Yellow|Red on White|

          Magenta on Black|Magenta on DarkBlue|Magenta on DarkGreen|Magenta on DarkCyan|
          Magenta on DarkRed|Magenta on DarkMagenta|Magenta on DarkYellow|Magenta on Gray|
          Magenta on DarkGray|Magenta on Blue|Magenta on Green|Magenta on Cyan|
          Magenta on Red|Magenta on Magenta|Magenta on Yellow|Magenta on White|

          Yellow on Black|Yellow on DarkBlue|Yellow on DarkGreen|Yellow on DarkCyan|
          Yellow on DarkRed|Yellow on DarkMagenta|Yellow on DarkYellow|Yellow on Gray|
          Yellow on DarkGray|Yellow on Blue|Yellow on Green|Yellow on Cyan|
          Yellow on Red|Yellow on Magenta|Yellow on Yellow|Yellow on White|

          White on Black|White on DarkBlue|White on DarkGreen|White on DarkCyan|
          White on DarkRed|White on DarkMagenta|White on DarkYellow|White on Gray|
          White on DarkGray|White on Blue|White on Green|White on Cyan|
          White on Red|White on Magenta|White on Yellow|White on White|

          11:55:17:
          #*------^ PS NARROW/ADJ-WIDTH CONSOLE COLOR TABLE ^------      
          
    Demo -narrow output. 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    ###[Alias('Alias','Alias2')]
    PARAM(
        [Parameter(HelpMessage="Optional Parameter to use a narrower layout, grouped by foreground color [-Narrow]")]
        [int]$Narrow,
        [Parameter(HelpMessage="Optional Parameter to specify the number of columns of colors to display per line, in the -Narrow layout (defaults to 4)[-MaxColumns 5]")]
        [int]$MaxColumns = 4
    ) ;
    $colors = [enum]::GetValues([System.ConsoleColor]) ;
    if(-not $Narrow){
        $sBnrS="`n#*------v PS WIDE CONSOLE COLOR TABLE v------" ; 
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnrS)" ;
        Foreach ($back in $colors){
            Foreach ($fore in $colors) {Write-Host -ForegroundColor $fore -BackgroundColor $back "$($fore)|" -NoNewLine } ;
            Write-Host " on $back" ;
        } ;
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
    } else { 
        $sBnrS="`n#*------v PS NARROW/ADJ-WIDTH CONSOLE COLOR TABLE v------" ; 
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnrS)" ;
        if(-not $colors){$colors=[enum]::GetValues([System.ConsoleColor]);} ; # (to clip out usable block for non-module use)
        $prcd = 0 ;
        foreach($back in $colors){
            foreach($fore in $colors){
                $prcd++ ;
                if($prcd -lt $MaxColumns){
                    write-host -ForegroundColor $fore -BackgroundColor $back -nonewline ("{0} on {1}|" -f $fore,$back ) ;
                } else {
                    write-host -ForegroundColor $fore -BackgroundColor $back ("{0} on {1}|" -f $fore,$back ) ;
                    $prcd = 0 ;
                } ;
            } ;
            write-host "`n" ;
        } ;
        write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
    } ; 
}

#*------^ get-ColorNames.ps1 ^------


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
    AddedCredit : AutomatedLab:Raimund Andrée [MSFT],Jan-Hendrik Peters [MSFT]
    AddedWebsite:	https://github.com/AutomatedLab/AutomatedLab.Common/blob/develop/AutomatedLab.Common/Common/Public/Get-ConsoleText.ps1
    AddedGithub : https://github.com/AutomatedLab/AutomatedLab
    AddedTwitter:	@raimundandree,@nyanhp
    CreatedDate : 2022-02-02
    FileName    : get-ConsoleText.ps1
    License     : https://github.com/AutomatedLab/AutomatedLab/blob/develop/LICENSE
    Copyright   : Copyright (c) 2022 Raimund Andrée, Jan-Hendrik Peters
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
    * 2:08 PM 11/7/2022 updated CBH example3 to reset to UTF8 (vs prior Ascii); added examples for running the entire source tree recursive, and added example echos of the per-file processing.
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
    ## code to dump first 9 bytes of each:
    ```ps
    $encodingS = "unicode","bigendianunicode","utf8","utf7","utf32","ascii","default","oem" ;foreach($encoding in $encodings){    "`n==$($encoding):" ;    Get-Date | Out-File date.txt -Encoding $encoding ;    [byte[]] $x = get-content -encoding byte -path .\date.txt -totalcount 9 ;    $x | format-hex ;} ; 
    ```
    
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
    PS> Get-ChildItem  *.ps1 | ?{$_.length -gt 0} | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'UTF8'} | ft -a ; 
    This command gets ps1 files in current directory (with non-zero length) where encoding is not UTF8 ;
    .EXAMPLE
    PS> $Encoding = 'UTF8' ; 
    PS> Get-ChildItem  *.ps1 | ?{$_.length -gt 0} | 
    PS>    select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | 
    PS>    where {$_.Encoding -ne $Encoding} | foreach-object { 
    PS>        write-host "==$($_.fullname):" ; 
    PS>        (get-content $_.FullName) | set-content $_.FullName -Encoding $Encoding -whatif ;
    PS>    } ;
    Gets ps1 files in current directory (with non-zero length) where encoding is not UTF8, and then sets encoding to UTF8 using set-content ;
    .EXAMPLE
    PS> $Encoding = 'UTF8' ;
    PS> Get-ChildItem  c:\sc\*.ps1 -recur | ?{$_.length -gt 0} |
    PS>     select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} |
    PS>     where {$_.Encoding -ne $Encoding}  | ft -a ; 
        FullName                        Encoding
        --------                        --------
        C:\sc\AADInternals\MDM.ps1      ASCII
        C:\sc\AADInternals\OneDrive.ps1 ASCII
    Demo recursing down the entire c:\sc source tree, and reporting non-UTF8s
    .EXAMPLE
    PS> $Encoding = 'UTF8' ;
    PS> Get-ChildItem  c:\sc\*.ps1 -recur | ?{$_.length -gt 0} |
    PS>     select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} |
    PS>     where {$_.Encoding -ne $Encoding} | foreach {
    PS>         write-host "==$($_.fullname):" ;
    PS>         (get-content $_.FullName) | set-content $_.FullName -Encoding $Encoding -whatif ;
    PS>     } ;
    Demo recursing source tree, and coercing non-UTF8 PS1's to UTF8.
    .LINK
    https://github.com/tostka/verb-io
    http://franckrichard.blogspot.com/2010/08/powershell-get-encoding-file-type.html
    https://gist.github.com/jpoehls/2406504
    http://goo.gl/XQNeuc
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


#*------v get-HostIndent.ps1 v------
function get-HostIndent {
    <#
    .SYNOPSIS
    get-HostIndent - Utility cmdlet that retrieves the current $env:HostIndentSpaces value. 
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : get-HostIndent.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 2:19 PM 2/15/2023 broadly: moved $PSBoundParameters into test (ensure pop'd before trying to assign it into a new object) ; 
        typo fix, removed [ordered] from hashes (psv2 compat); 
    * 2:13 PM 2/3/2023 init
    .DESCRIPTION
    get-HostIndent - Utility cmdlet that retrieves the current $env:HostIndentSpaces value. 

    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reget-HostIndent # $env:HostIndentSpaces = 0 ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    get-HostIndent # explicit set to multiples of 4
    clear-HostIndent # remove $env:HostIndentSpaces
    get--HostIndent # return current env:HostIndentSpaces value to pipeline
            

    Concept inspired by L5257's printIndent() in his get-DNSspf.ps1 (which ran a simple write-host -nonewline loop, to be run prior to write-host use). 

    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .EXAMPLE
    PS> $CurrIndnet = get-HostIndent ;
    Simple retrieval demo    
    #>
    [CmdletBinding()]
    [Alias('s-hi')]
    PARAM(
        [Parameter(
            HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
            [switch]$usePID
    ) ;
    BEGIN {
    #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
    # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    if(($PSBoundParameters.keys).count -ne 0){
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
    } ;
    $Verbose = ($VerbosePreference -eq 'Continue') ;
    #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

    #if we want to tune this to a $PID-specific variant, use:
    if($usePID){
            $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $HISName = "Env:HostIndentSpaces$($PID)" ;
        } else {
            $HISName = "Env:HostIndentSpaces" ;
        } ;
        write-verbose "$($CmdletName): Discovered `$$($HISName):$($CurrIndent)" ;
        $smsg = "$($CmdletName): get $($HISName) value)" ;
        write-verbose $smsg  ;
        TRY{
            if (-not ([int]$CurrIndent = (Get-Item -Path $HISName -erroraction SilentlyContinue).Value ) ){
                [int]$CurrIndent = 0 ;
            } ;
            $CurrIndent | write-output ;
        } CATCH {
            $smsg = $_.Exception.Message ;
            write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            $false  | write-output ;
            BREAK ;
        } ;
    } ;
}

#*------^ get-HostIndent.ps1 ^------


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
    * 8:04 AM 4/18/2022 added one exception: b64-encoded -type 'ping' sample (common need, not commonly covered by Soundscheme evts)
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
        [ValidateSet('Asterisk','Beep','Critical','Error','Exclamation','Failure','Notification','NotificationSystem','Question','Success','Warning','Ping')]
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
                $media = 'UklGR-TRIMMED-wEAAAA='    }
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
        'ping'{
            #region Use this to convert a WAV to a Base64 String for playing
            #$media = [convert]::ToBase64String((Get-Content c:\usr\local\bin\sonar-ping.wav -Encoding Byte))
            #endregion
            $media = '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.0.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' ;
            $smsg += "(playing NotificationSystem:ping.wav)" ; 
            write-verbose $smsg ;
            $sound = new-Object -TypeName System.Media.SoundPlayer
            $sound.stream = (New-Object -TypeName System.IO.MemoryStream -ArgumentList (($$ = [System.Convert]::FromBase64String($media)),0,$$.Length))
            $sound.play()
            Remove-Variable -Name sound ; 
            Remove-Variable -Name media ; 
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
    * 4:43 PM 1/1/2023 fixed on TINKERTOY debugging (was missing returned obj props etc)
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
        #$unavdrvs = Get-SMBMapping -verbose:$($VerbosePreference -eq "Continue") | ?{$_.RemotePath -match $rgxRemoteHosts -AND $_.status -eq 'Unavailable'} ; 
        # flip it to generic detect of unc RemotePath (supports fqdn, over nbnames, wo customized rgx)
        $unavdrvs = Get-SMBMapping -verbose:$($VerbosePreference -eq "Continue") | ?{([system.uri]$_.RemotePath).isUnc -AND $_.status -eq 'Unavailable'} ;
        #$psdrvs = Get-psdrive -verbose:$($VerbosePreference -eq "Continue") | ?{$_.remotepath -match $rgxRemoteHosts } ; 
        # flip it to generic detect of unc RemotePath (supports fqdn, over nbnames, wo customized rgx)
        $psdrvs = Get-psdrive -verbose:$($VerbosePreference -eq "Continue") | ? {$_.provider.name -eq 'Filesystem'} | ?{ ([system.uri]$_.displayroot).isUnc} ;
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
            #$pltNPSD.Name = [regex]::match($drv.localpath.tostring(),"([A-Z]):").captures[0].groups[1].value; 
            $pltNPSD.Name = $drv.localpath.tostring().split(':')[0]
            $pltNPSD.Root = $drv.remotepath; 
            #if($psdrvs |?{($_.Root -eq $drv.remotepath) -AND $_.name -eq $pltNPSD.Name}){
            if( ($psdrvs |?{$_.displayroot -eq $drv.RemotePath}) -AND ($psdrvs |?{$_.name -eq $pltNPSD.Name}) ) {
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


#*------v New-RandomFilename.ps1 v------
function New-RandomFilename{
    <#
    SYNOPSIS
    New-RandomFilename.ps1 - Create a RandomFilename
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-07-18
    FileName    : New-RandomFilename.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell
    AddedCredit : cybercastor
    AddedWebsite:	https://www.reddit.com/user/cybercastor
    AddedTwitter:	
    REVISIONS
    * 2:25 PM 7/20/2022 added/expanded CBH, spliced in his later posted new-RandomFilename dependant function ; subst ValidateRange for $maxlen tests ; subbed out missing show-exceptiondetails()
    * 7/18/22 cybercastor posted rev
    .DESCRIPTION
    New-RandomFilename.ps1 - Create a new random filename

    [Invoke-BypassPaywall](https://www.reddit.com/r/PowerShell/comments/w1ypp2/invokebypasspaywall_open_a_webpage_locally/)

    .PARAMETER Path
    Host directory for new file (defaults `$ENV:Temp)
    .PARAMETER Extension
    Extension for new file (defaults 'tmp')
    .PARAMETER MaxLen
    Length of new file name (defaults 6, 4-36 range)
    .PARAMETER CreateFile
    Switch to create new empty file matching the specification.
    .PARAMETER CreateDirectory
    Switch to create a new hosting directory below `$Path,  with a random (guid) name (which will be 36chars long).
    .EXAMPLE
    PS> $fn = New-RandomFilename -Extension 'html'
    Create a new randomfilename with html ext
    .EXAMPLE
    PS> .Invoke-BypassPaywall 'https://www.theatlantic.com/ideas/archive/2022/07/russian-invasion-ukraine-democracy-changes/661451'
    theatlantic.com demo
    .LINK
    https://github.com/tostka/verb-IO
    https://www.reddit.com/r/PowerShell/comments/w1ypp2/invokebypasspaywall_open_a_webpage_locally/               
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Path = "$ENV:Temp",
        [Parameter(Mandatory=$false)]
        [string]$Extension = 'tmp',
        [Parameter(Mandatory=$false)]
        [ValidateRange(4,36)]
        [int]$MaxLen = 6,
        [Parameter(Mandatory=$false)]
        [switch]$CreateFile,
        [Parameter(Mandatory=$false)]
        [switch]$CreateDirectory
    )    
    TRY{
        #if($MaxLen -lt 4){throw "MaxLen must be between 4 and 36"}
        #if($MaxLen -gt 36){throw "MaxLen must be between 4 and 36"}
        [string]$filepath = $Null
        [string]$rname = (New-Guid).Guid
        Write-Verbose "Generated Guid $rname"
        [int]$rval = Get-Random -Minimum 0 -Maximum 9
        Write-Verbose "Generated rval $rval"
        [string]$rname = $rname.replace('-',"$rval")
        Write-Verbose "replace rval $rname"
        [string]$rname = $rname.SubString(0,$MaxLen) + '.' + $Extension
        Write-Verbose "Generated file name $rname"
        if($CreateDirectory -eq $true){
            [string]$rdirname = (New-Guid).Guid
            $newdir = Join-Path "$Path" $rdirname
            Write-Verbose "CreateDirectory option: creating dir: $newdir"
            $Null = New-Item -Path $newdir -ItemType "Directory" -Force -ErrorAction Ignore
            $filepath = Join-Path "$newdir" "$rname"
        }
        $filepath = Join-Path "$Path" $rname
        Write-Verbose "Generated filename: $filepath"

        if($CreateFile -eq $true){
            Write-Verbose "CreateFile option: creating file: $filepath"
            $Null = New-Item -Path $filepath -ItemType "File" -Force -ErrorAction Ignore 
        }
        return $filepath
    
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
    } ; 
}

#*------^ New-RandomFilename.ps1 ^------


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


#*------v pop-HostIndent.ps1 v------
function pop-HostIndent {
    <#
    .SYNOPSIS
    pop-HostIndent - Utility cmdlet that decrements/pops the $env:HostIndentSpaces by 4 (or the configured `$PadIncrement)
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : pop-HostIndent.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 2:19 PM 2/15/2023 broadly: moved $PSBoundParameters into test (ensure pop'd before trying to assign it into a new object) ; 
        typo fix, removed [ordered] from hashes (psv2 compat). 
    * 2:01 PM 2/1/2023 add: -PID param
    * 2:39 PM 1/31/2023 updated to work with $env:HostIndentSpaces in process scope. 
    * 9:50 AM 1/17/2023 All need to be recoded to use evari's, scoped varis aren't consistently discoverable, to have the current 'indent depth' being tweaked by pop|push|reset|set and read by write:
    * 4:39 PM 1/11/2023 init
    .DESCRIPTION
    pop-HostIndent - Utility cmdlet that decrements/pops the $env:HostIndentSpaces by 4 (or the configured `$PadIncrement)

    If it doesn't find a preexisting $IndentHostSpaces in 'private','local','script','global'
    it throws an error

    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reset-HostIndent # $env:HostIndentSpaces = 0 ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    set-HostIndent # explicit set to multiples of 4
            
    .PARAMETER PadIncrement
    Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]
    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .EXAMPLE
    PS> pop-HostIndent ;
    PS> $env:HostIndentSpaces ; 
    Simple indented text demo
    .EXAMPLE
    PS>  $domain = 'somedomain.com' ; 
    PS>  write-verbose "Top of code, establish 0 Indent" ;
    PS>  $env:HostIndentSpaces = 0 ;
    PS>  #...
    PS>  # indent & do nested thing
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  pop-HostIndent "Spf Version: $($spfElement)" -verbose ;
    PS>  # nested another level
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: += 4 Net:$($env:HostIndentSpaces)" ;
    PS>  pop-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  pop-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    Demo typical usage.
    #>
    [CmdletBinding()]
    [Alias('pop-hi')]
    [CmdletBinding()]
    [Alias('pop-hi')]
    PARAM(
        [Parameter(
            HelpMessage="Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]")]
            [int]$PadIncrement = 4,
        [Parameter(
            HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
            [switch]$usePID
    ) ;
    BEGIN {
    #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
    # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    if(($PSBoundParameters.keys).count -ne 0){
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
    } ;
    $Verbose = ($VerbosePreference -eq 'Continue') ;        
    #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

    write-verbose "$($CmdletName): Using `$PadIncrement:`'$($PadIncrement)`'" ; 

    #if we want to tune this to a $PID-specific variant, could use:
    if($usePID){
            $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $HISName = "Env:HostIndentSpaces$($PID)" ;
        } else {
            $HISName = "Env:HostIndentSpaces" ;
        } ;
        if(($smsg = Get-Item -Path "Env:HostIndentSpaces$($PID)" -erroraction SilentlyContinue).value){
            write-verbose $smsg ;
        } ;
        if (-not ([int]$CurrIndent = (Get-Item -Path $HISName -erroraction SilentlyContinue).Value ) ){
            [int]$CurrIndent = 0 ;
        } ;
        write-verbose "$($CmdletName): Discovered `$$($HISName):$($CurrIndent)" ;
        if(($NewIndent = $CurrIndent - $PadIncrement) -lt 0){
            write-warning "$($CmdletName): `$HostIndentSpaces has reached 0/left margin (limiting to 0)" ;
            $NewIndent = 0 ;
        } ;
        $pltSV=@{
            Path = $HISName ;
            Value = $NewIndent ;
            Force = $true ;
            erroraction = 'STOP' ;
        } ;
        $smsg = "$($CmdletName): Set 1 lvl:Set-Variable w`n$(($pltSV|out-string).trim())" ;
        write-verbose $smsg  ;
        TRY{
            Set-Item @pltSV ;
        } CATCH {
            $smsg = $_.Exception.Message ;
            write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            BREAK ;
        } ;
    } ;
}

#*------^ pop-HostIndent.ps1 ^------


#*------v Pop-LocationFirst.ps1 v------
function Pop-LocationFirst {
    <#
    .SYNOPSIS
    Pop-LocationFirst - Pop-Location to the 'first'/'oldest'/'original' item in the stack (which in a normal (Get-Location -stack).path, is actually the _bottom_ entry in the stack ;P)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-05-06
    FileName    : Pop-LocationFirst.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,File,FileSystem
    REVISIONS   :
    * 10:13 AM 5/20/2022 updated the logic, added write-host  dot crawl, vs verbose detailed echos.
    * 3:20 PM 5/6/2022 init
    .PARAMETER PassThru <System.Management.Automation.SwitchParameter>
    Passes an object that represents the location to the pipeline. By default, this cmdlet does not generate any output.
    .INPUTS
    Does not accept piped input.
    .OUTPUTS
    None or System.Object
    .DESCRIPTION
    Pop-LocationFirst - Pop-Location to the 'first'/'oldest'/'original' item in the stack (which in a normal (Get-Location -stack).path, is actually the _bottom_ entry in the stack ;P)
    Usefull for when doing a lot of debugging, and use of pushd in code, with bug/aborts failure to exec tailing bracketing popd to restore to origin pwd (results in deeply nested pwd, when you want to be back at the stack top for fresh debugging passes).
    .EXAMPLE
    PS> pushd c:\usr\local\bin\ ; pushd c:\usr\sbin\ ; pushd C:\temp\ ; 
    PS> Pop-LocationFirst -verbose ;
    Push-location three locations into the stack, then Set-Location to the first/lowest location in the stack
    .EXAMPLE
    $finalPwd = popd1 -verbose -passthru ;
    Set-Location to the first/lowest location in the stack, and assign the resulting location system.object to the $currDir variable; with verbose output (emulates pop-location/popd -passthru behavior)
    .LINK
    https://github.com/tostka/verb-io
    #>    
    [CmdletBinding()]
    [Alias('popd1')]
    Param(
        [Parameter(HelpMessage = 'Passes an object that represents the location to the pipeline. By default, this cmdlet does not generate any output.[-PassThru]')]
        [switch]$PassThru
    ) ;
    $stk = get-location -stack ; 
    if($stk.count){
        $nwd = ((get-location -stack).path)[-1] ; 
        write-verbose "pop-location to first/bottom stack entry:$($nwd)" ;
        # could directly cd to the target dir
        # set-location $nwd ; 
        # but if you want to increment the pointer to the matching location (esp if depicting the depth in prompt), you need to popd your way back out.
        #1..((get-location -stack).path.count + 1) | foreach-object {write-verbose 'pop-location' ; Pop-Location  } ; 
        if($n = (get-location -Stack).count){ 
            1..$($n) |foreach-object {
                if($VerbosePreference -eq "Continue"){write-verbose 'pop-location'}
                else {write-host '.' -nonewline } ; 
                Pop-Location  ; 
            } 
        } ;
    } else { 
        write-verbose '(no current locations in the stack)' ; 
    } ; 
    if($PassThru){
        write-verbose "(returning pwd object to pipeline)" ; 
        Get-Location |write-output ; 
    } ; 
}

#*------^ Pop-LocationFirst.ps1 ^------


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


#*------v push-HostIndent.ps1 v------
function push-HostIndent {
    <#
    .SYNOPSIS
    push-HostIndent - Utility cmdlet that increments/pushes the $env:HostIndentSpaces by 4 (or the configured `$PadIncrement)
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : push-HostIndent.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 2:19 PM 2/15/2023 broadly: moved $PSBoundParameters into test (ensure pop'd before trying to assign it into a new object) ; 
        typo fix, removed [ordered] from hashes (psv2 compat). 
    * 2:01 PM 2/1/2023 add: -PID param
    * 2:39 PM 1/31/2023 updated to work with $env:HostIndentSpaces in process scope. 
    * 9:50 AM 1/17/2023 All need to be recoded to use evari's, scoped varis aren't consistently discoverable, to have the current 'indent depth' being tweaked by pop|push|reset|set and read by write:
    * 4:39 PM 1/11/2023 init
    .DESCRIPTION
    push-HostIndent - Utility cmdlet that increments/pushes the $env:HostIndentSpaces by 4 (or the configured `$PadIncrement)

    If it doesn't find a preexisting $IndentHostSpaces in 'private','local','script','global'
    it throws an error

    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reset-HostIndent # $env:HostIndentSpaces = 0 ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    set-HostIndent # explicit set to multiples of 4
            
    .PARAMETER PadIncrement
    Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]
    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .EXAMPLE
    PS> push-HostIndent ;
    PS> $env:HostIndentSpaces ; 
    Simple indented text demo
    .EXAMPLE
    PS>  $domain = 'somedomain.com' ; 
    PS>  write-verbose "Top of code, establish 0 Indent" ;
    PS>  $env:HostIndentSpaces = 0 ;
    PS>  #...
    PS>  # indent & do nested thing
    PS>  $env:HostIndentSpaces += 4 ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  push-HostIndent "Spf Version: $($spfElement)" -verbose ;
    PS>  # nested another level
    PS>  $env:HostIndentSpaces += 4 ;
    PS>  write-verbose "`$env:HostIndentSpaces: += 4 Net:$($env:HostIndentSpaces)" ;
    PS>  push-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces -= 4 ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces -= 4 ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  push-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    SAMPLEOUTPUT
    DESCRIPTION
    SAMPLEOUTPUT
    DESCRIPTION        
    #>
    [CmdletBinding()]
    [Alias('push-hi')]
    PARAM(
        [Parameter(
            HelpMessage="Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]")]
        [int]$PadIncrement = 4,
        [Parameter(
            HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
            [switch]$usePID
    ) ;
    BEGIN {
    #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
    # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    if(($PSBoundParameters.keys).count -ne 0){
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
    } ; 
    write-verbose "$($CmdletName): Using `$PadIncrement:`'$($PadIncrement)`'" ;
        if($usePID){
            $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $HISName = "Env:HostIndentSpaces$($PID)" ;
        } else {
            $HISName = "Env:HostIndentSpaces" ;
        } ;

        if (-not ([int]$CurrIndent = (Get-Item -Path $HISName -erroraction SilentlyContinue).Value ) ){
            [int]$CurrIndent = 0 ;
        } ;
        write-verbose "$($CmdletName): Discovered `$$($HISName):$($CurrIndent)" ;
        $pltSV=@{
            Path = $HISName ;
            Value = [int](Get-Item -Path $HISName -erroraction SilentlyContinue).Value + $PadIncrement;
            Force = $true ;
            erroraction = 'STOP' ;
        } ;
        $smsg = "$($CmdletName): Set 1 lvl:Set-Variable w`n$(($pltSV|out-string).trim())" ;
        write-verbose $smsg  ;
        TRY{
                Set-Item @pltSV ;
        } CATCH {
            $smsg = $_.Exception.Message ;
            write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            BREAK ;
        } ;
        } ; 
    }

#*------^ push-HostIndent.ps1 ^------


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


#*------v Remove-AuthenticodeSignature.ps1 v------
function Remove-AuthenticodeSignature {
    <#
    .SYNOPSIS
    Remove-AuthenticodeSignature - removes an Authenticode signature from any file that supports Subject Interface Package (SIP).
    .NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-04-17
    FileName    : Remove-AuthenticodeSignature.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,Certificate,Developoment
    AddedCredit : Adrian Rodriguez
    AddedWebsite:	https://psrdrgz.github.io/RemoveAuthenticodeSignature/
    AddedTwitter:	@psrdgz
    REVISIONS   :
    * 10:39 AM 5/13/2022 removed 'requires -modules', to fix nesting limit error loading verb-io
    * 9:56 AM 5/12/2022 add: incrementing counter
    * 4:54 PM 5/3/2022 init vers
    .PARAMETER Path
    file name(s) to appl authenticode signature into.
    .INPUTS
    system.io.fileinfo[]
    .DESCRIPTION
    Remove-AuthenticodeSignature - removes an Authenticode signature from any file that supports Subject Interface Package (SIP).
    .EXAMPLE
      get-childitem *.ps1,*.psm1,*.psd1,*.psd1,*.ps1xml | Get-AuthenticodeSignature | ? {($_.status -eq 'Valid')} | remove-AuthenticodeSignature
      Remove sigs on all ps files with valid sigs (for ps, it's: ps1, psm1, psd1, dll, exe, and ps1xml files)
    .EXAMPLE
    Remove-AuthenticodeSignature C:\usr\work\lync\scripts\enable-luser.ps1
    Parameter removal
    .EXAMPLE
    get-childitem c:\usr\local\bin\*.ps1 | Remove-AuthenticodeSignature
    Pipeline example
    #>
    [CmdletBinding()]
    ###[Alias('Alias','Alias2')]
    Param(
        [Parameter(Mandatory = $False,Position = 0,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True, HelpMessage = 'Files to have signature removed [-file c:\pathto\script.ps1]')]
        [Alias('PsPath','File')]
        [system.io.fileinfo[]]$Path,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN {
        $rgxSignFiles='\.(CAT|MSI|JAR,OCX|PS1|PSM1|PSD1|PS1XML|PSC1|MSP|CMD|BAT|VBS)$' ;
        $rgxSigStart = '^#\sSIG\s#\sBegin\ssignature\sblock' ;
        $rgxSigEnd = '^#\sSIG\s#\sEnd\ssignature\sblock' ;
        $verbose = ($VerbosePreference -eq "Continue") ;
    } ;
    PROCESS {
        $ttl = ($Path|measure).count ; $proc=0 ; 
        $Path | ForEach-Object -Process {
            $proc++ ; 
            $Item = $_ ; 
			If($Item.Extension -match $rgxSignFiles){
                # sls for sig marker, (plan to dump large numbers at it from modules, to strip sigs, when rebuilding into monolithic .psm1s)
                if(select-string -Path  $Item -Pattern $rgxSigStart){
                    $smsg = "(($($proc)/$($ttl)):Remove-Sig:$($Item.FullName))" ;
                    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;

                    Try{
                        $rawSourceLines = get-content -path $Item.FullName -ErrorAction Stop ;
                        $SrcLineTtl = ($rawSourceLines | Measure-Object).count ;
                        $sigOpenLn = ($rawSourceLines | select-string -Pattern $rgxSigStart).linenumber ;
                        $sigCloseLn = ($rawSourceLines | select-string -Pattern $rgxSigEnd).linenumber ;
                        if(!$sigOpenLn){$sigCloseLn = 0 } ;
                        $updatedContent = @() ; $DropContent=@() ;
                        $updatedContent = $rawSourceLines[0..($sigOpenLn-2)] |out-string ;
                        #$DropContent = $rawsourcelines[$sigOpenLn..$sigCloseLn] |out-string ;

                        if(get-command set-ContentFixEncoding){
                            $pltSCFE=[ordered]@{  Path =$Item.FullName  ;  Value = $updatedContent ;  verbose =$($verbose) ;  errorAction = 'STOP' ;  whatif=$($whatif) } ; 
                            $smsg = "($($proc)/$($ttl)):Set-ContentFixEncoding  w`n$(($pltSCFE|out-string).trim())" ; 
                            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            Set-ContentFixEncoding @pltSCFE ; 
                        } else { 
                            # encoding mgmt/coerce
                            $enc=$null ; $enc=get-FileEncoding -path $Item.FullName ;
                            if($enc -eq 'ASCII') {
                                $enc = 'UTF8' ;
                                $smsg = "(($($proc)/$($ttl)):ASCI encoding detected, converting to UTF8)" ;
                                if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                            } ; # force damaged/ascii to UTF8
                            $pltSetCon=[ordered]@{ Path=$Item.FullName ; whatif=$($whatif) ;  } ;
                            if($enc){$pltSetCon.add('encoding',$enc) } ;
                            Set-Content @pltSetCon -Value $updatedContent ;
                        } ; 
                    }Catch{
                        #Write-Error -Message $_.Exception.Message ;
                        $ErrTrapd=$Error[0] ;
                        $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #-=-record a STATUSWARN=-=-=-=-=-=-=
                        $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
                        if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
                        if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
                        Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
                    } ;
                } else { 
                    $smsg = "(($($proc)/$($ttl)):$($item):has no existing Authenticode signature)" ; 
                    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
                };
            } ;
        } # loop-E
    } # Proc-E
}

#*------^ Remove-AuthenticodeSignature.ps1 ^------


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


#*------v Remove-InvalidVariableNameChars.ps1 v------
Function Remove-InvalidVariableNameChars {

  <#
    .SYNOPSIS
    Remove-InvalidVariableNameChars - Remove Powershell illegal Variable Name characters from the passed string. By default complies with about_Variables Best practice guidence: 'The best practice is that variable names include only alphanumeric characters and the underscore (_) character. Variable names that include spaces and other special characters, are difficult to use and should be avoided.'
    .NOTES
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-07-26
    FileName    : Remove-InvalidVariableNameChars.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Tags        : Powershell,Variable,NameStandard,BestPractice
    REVISIONS   :
    * 3:35 PM 7/26/2022 Cleans potential variable names, simple update to the regex.
    .DESCRIPTION
    Remove-InvalidVariableNameChars - Remove Powershell illegal Variable Name characters from the passed string. By default complies with about_Variables Best practice guidence: 'The best practice is that variable names include only alphanumeric characters and the underscore (_) character. Variable names that include spaces and other special characters, are difficult to use and should be avoided.'
    I use this with dynamically-generated ticket-based variables for accumulating ticket data (traces, log parses etc), basing the dyn variable on ticket attribute, email address etc. 
    MS docs on variable name restrictions: 
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    [about Variables - PowerShell | Microsoft Docs - docs.microsoft.com/](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_variables?view=powershell-7.2#variable-names-that-include-special-characters)

    ## Variable names that include special characters

    Variable names begin with a dollar ($) sign and can include alphanumeric characters and special characters. The variable name length is limited only by available memory.

    The best practice is that variable names include only alphanumeric characters and the underscore (_) character. Variable names that include spaces and other special characters, are difficult to use and should be avoided.

    Alphanumeric variable names can contain these characters:

     - Unicode characters from these categories: Lu, Ll, Lt, Lm, Lo, or Nd.
     - Underscore (_) character.
     - Question mark (?) character.
     
    The following list contains the Unicode category descriptions. For more information, see UnicodeCategory.

     - Lu - UppercaseLetter
     - Ll - LowercaseLetter
     - Lt - TitlecaseLetter
     - Lm - ModifierLetter
     - Lo - OtherLetter
     - Nd - DecimalDigitNumber
     - 
    To create or display a variable name that includes spaces or special characters, enclose the variable name with the curly braces ({}) characters. The curly braces direct PowerShell to interpret the variable name's characters as literals.
    #-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    
    .PARAMETER Name
    Potential variable 'name' string to have illegal variable name characters removed. 
    .PARAMETER PermitSpecial
    Switch to permit inclusion of Special characters in variable name (use requires wrapping name in curly-braces) [-PermitSpecial]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.String
    .EXAMPLE
    $Name = Remove-InvalidVariableNameChars -name $vname ; 
    Remove OS-specific illegal characters from the sample filename in $ofile. 
    .EXAMPLE
    $Name = Remove-InvalidVariableNameChars -name $vname -PermitSpecial ; 
    Demo use of -permitSpecial: Remove all but closing curly-brace } and backtick ` characters from name in $vname. 
    .EXAMPLE
    set-variable -name ($VName | Remove-InvalidVariableNameChars) -value 1 ; 
    Demo pipeline use with set-variable.
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    #[Alias('')]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String[]]$Name,
        [Parameter(HelpMessage = 'Switch to permit inclusion of Special characters in variable name (use requires wrapping name in curly-braces) [-PermitSpecial]')]
        [switch]$PermitSpecial
    )
    BEGIN {
        $verbose = ($VerbosePreference -eq "Continue") ; 
        $rgxVariableNameBP = '[A-Za-z0-9_]' ; 
        $rgxInvalidChars = "[\}`]" ; # all but closing curly brace (}) character (U+007D) and backtick (`) character (U+0060).
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 

    } ;  # BEGIN-E
    PROCESS {
        foreach($item in $Name) {
            If($PermitSpecial){
                $uName = ($item -replace $rgxInvalidChars) 
                write-verbose "(-PermitSpecial specified: returning cleaned name:'$($uname)' to pipeline)" ;
            } else { 
                $uName = ($item.tochararray() -match $rgxVariableNameBP) -join '' ;
                write-verbose "(returning cleaned name:'$($uname)' to pipeline)" ; 
            } ; 
            $uName | write-output ; 
        } ; 
    } ;  # PROC-E
}

#*------^ Remove-InvalidVariableNameChars.ps1 ^------


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
    * 12:52 PM 5/23/2022 flip rm catch to Continue, and add ea continue to the splat, Break aborts what is really only a maint task, not a critical path step ; added variant catch for perms/read-only error: catch[System.IO.IOException]{
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
    
        # add ea cont, to permit it to survive read-only files wo errors.
        $pltRItm = [ordered]@{
            path=$population.fullname ; 
            #ErrorAction =  'Continue' ; 
            ErrorAction =  'STOP' ; 
            whatif=$($whatif) ;
        } ; 
        
        $smsg = "Remove-Item w `n$(($pltRItm|out-string).trim())" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        TRY {
            Remove-Item @pltRItm ;
            $true | write-output ; 
        } CATCH [System.IO.IOException]{
            $ErrTrapd=$Error[0] ;
            $smsg = "File permissions/read-only issue (SKIPPING:$pltRItm.path)..."
            $smsg += "`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #-=-record a STATUSWARN=-=-=-=-=-=-=
            $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
            if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
            if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
            #-=-=-=-=-=-=-=-=
            $false | write-output ; 

            Continue  ; 
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
            # flip it to Continue, Break aborts what is really only a maint task, not a critical path step
            Continue #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ; 
    } else { 
        $smsg = "There are *no* files to be removed, as per the specified inputs. (`$population:$(($population|measure).count))" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ; 

    $Exit = $Retries ;

}

#*------^ remove-UnneededFileVariants.ps1 ^------


#*------v repair-FileEncoding.ps1 v------
function repair-FileEncoding {
    <#
    .SYNOPSIS
    repair-FileEncoding.ps1 - Filter specified Path for risky high-ascii chars & Encoding conversion failure markers, replace each with a low-ascii equiv, (or dash for diamond questionmarks), and convert output file to UTF8
    .NOTES
    Version     : 1.6.2
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2019-02-06
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/powershell
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 10:11 AM 12/8/2022 pull *all* reqs; verb-logging is cross broken too; nested-limit triggering recursive req's verb-io
    * 4:37 PM 11/22/2022 moved into verb-io; fixed typo utf8 spec (utf-8), flip into an adv function;refactored, added broader try/catch, handling for both 
    file or dir path; simplified logic, does encoding repair always, always detects 
    highascii chars, recommends fixes, but only runs fixes with -ReplaceChars param.
    pulled -ConvertToUTF8Only param, it's the default purpose
    * 1:06 PM 11/22/2022 added adv func/pipeline support; ren fix-encoding (& alias) ->  repair-FileEncoding
    * 12:08 PM 4/21/2021 expanded ss aliases
    * 1:09 PM 1/14/2020 added support for ahk .cbp files (spotted blkdiamonds in ghd), use explicit path to target ahk files. Probably should consider putting .ahk's in as well...
    * 3:00 PM 1/2/2020 got through live pass using ConvertToUTF8Only, initial review of chgs in ghd appears to be functional
    * 2:52 PM 1/2/2020 used a prior version of the replc spec successfully, now have written in the broad conversion, and debugged, but not run prod yet.
    .DESCRIPTION
    repair-FileEncoding.ps1 - Filter specified Path for risky high-ascii chars & Encoding conversion failure markers, replace each with a low-ascii equiv, (or dash for diamond questionmarks), and convert output file to UTF8. Processess all matching ps1, psm1 & psd1 files in the tree.
    doesn't like it when you copy in a revised file from another box from debugging, and the encoding has changed: Tends to describe the file as 'This binary file has changed'. 
    Fix requires flipping the encoding back. 
    Underlying GIT issue documented here:
    [Binary file has changed shows for normal text file · Issue #7857 · desktop/desktop · GitHub - github.com/](https://github.com/desktop/desktop/issues/7857)

    Following high-ascii chars are replaced when -ReplaceChars is used:
    | CharCode | Replacement | Note |
    |---|---|---
    | [Char]0x2013 | " -"  | en dash  |
    | [Char]0x2014 | " -"  | em dash |
    | [Char]0x2015 | " -"  | horizontal bar |
    | [Char]0x2017 | " _"   | double low line |
    | [Char]0x2018 | " `'"  | left single quotation mark |
    | [Char]0x2019 | " `'"  | right single quotation mark |
    | [Char]0x201a | " ,"  | single low-9 quotation mark |
    | [Char]0x201b | " `'"  | single high-reversed-9 quotation mark |
    | [Char]0x201c | " `""  | right double quotation mark |
    | [Char]0x201d | " `""  | right double quotation mark |
    | [Char]0x201e | " `""  | double low-9 quotation mark |
    | [Char]0x2026 | " ..."  | horizontal ellipsis |
    | [Char]0x2032 | " `""  | prime  |
    | [Char]0x2033 | " `"" | double prime |
    | [char]65533  | Unicode Replacement Character (black diamond questionmark) in hex: [char] 0xfffd|


    .PARAMETER  Path
    Path to a file or Directory to be checked for encoding or encoding-conversion damage [-Path C:\sc\powershell]
    .PARAMETER EncodingTarget
    Encoding to be coerced on targeted files (defaults to UTF8, supports:ASCII|BigEndianUnicode|BigEndianUTF32|Byte|Default (system active codepage, freq ANSI)|OEM|String|Unicode|UTF7|UTF8|UTF32)[-EncodingTarget ASCII]
    .PARAMETER showDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS> repair-FileEncoding.ps1 -replaceChars
    In files in default path (C:\sc\powershell), in files Where-Object high-ascii chars are found, replace the chars with matching low-bit chars (whatif is autoforced true to ensure no accidental runs)
    .EXAMPLE
    PS> repair-FileEncoding.ps1 -path C:\sc\verb-AAD -replacechars -whatif:$false ;
    Exec-pass: problem char files, replacements, with explicit path and overridden whatif
    .EXAMPLE
    PS> gci c:\sc\ -recur| ?{$_.extension -match '\.ps((d|m)*)1' } | 
    PS>     select -expand fullname | repair-FileEncoding -whatif ;
    Recurse a sourcecode root, for ps-related files, expand the fullnames and run the set through repair-FileEncoding with whatif
    .LINK
    https://github.com/tostka/verb-io
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    [CmdletBinding()]
    [Alias('fix-encoding')]
    PARAM(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline=$true,HelpMessage="Path to a file or Directory to be checked for encoding or encoding-conversion damage [-Path C:\sc\powershell]")]
        #[ValidateScript({Test-Path $_ -PathType 'Container'})]
        [ValidateScript({Test-Path $_ })]
        [string[]] $Path="C:\sc\powershell",
        [Parameter(HelpMessage="Array of extensions to be included in checks of Containers (defaults to .ps1|.psm1|.psd1|.cbp) [-IncludeExtentions '.ps1','.psm1','.psd1']")]
        [array]$IncludeExtentions = @('*.ps1','*.psm1','*.psd1','*.cbp'),
        [Parameter(HelpMessage="Encoding to be coerced on targeted files (defaults to UTF8, supports:ASCII|BigEndianUnicode|BigEndianUTF32|Byte|Default|OEM|String|Unicode|UTF7|UTF8|UTF32)[-EncodingTarget ASCII]")]
        [ValidateSet('ASCII','BigEndianUnicode','BigEndianUTF32','Byte','Default','OEM','String','Unicode','UTF7','UTF8','UTF32')]
        [string]$EncodingTarget= 'UTF8',
        [Parameter(HelpMessage="Switch that specifies to also update files with high ascii chars: All matches are reqplaced with the equiv low-asci equivs[-ReplaceChars]")]
        [switch] $ReplaceChars,
        [Parameter(HelpMessage="Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    BEGIN{
        #*======v SUB MAIN v======
        #region INIT; # ------
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        #region START-LOG-HOLISTIC #*------v START-LOG-HOLISTIC v------
        # Single log for script/function example that accomodates detect/redirect from AllUsers scope'd installed code, and hunts a series of drive letters to find an alternate logging dir (defers to profile variables)
        #${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if(!(get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
        foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
        if(!(get-variable rgxPSAllUsersScope -ea 0)){
            $rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;
        } ;
        if(!(get-variable rgxPSCurrUserScope -ea 0)){
            $rgxPSCurrUserScope="^$([regex]::escape([Environment]::GetFolderPath('MyDocuments')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps((d|m)*)1|dll)$" ;
        } ;
        $pltSL=[ordered]@{Path=$null ;NoTimeStamp=$false ;Tag=$null ;showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($whatif) ;} ;
        $pltSL.Tag = $ModuleName ; 
        if($script:PSCommandPath){
            if(($script:PSCommandPath -match $rgxPSAllUsersScope) -OR ($script:PSCommandPath -match $rgxPSCurrUserScope)){
                $bDivertLog = $true ; 
                switch -regex ($script:PSCommandPath){
                    $rgxPSAllUsersScope{$smsg = "AllUsers"} 
                    $rgxPSCurrUserScope{$smsg = "CurrentUser"}
                } ;
                $smsg += " context script/module, divert logging into [$budrv]:\scripts" 
                write-verbose $smsg  ;
                if($bDivertLog){
                    if((split-path $script:PSCommandPath -leaf) -ne $cmdletname){
                        # function in a module/script installed to allusers|cu - defer name to Cmdlet/Function name
                        $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
                    } else {
                        # installed allusers|CU script, use the hosting script name
                        $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
                    }
                } ;
            } else {
                $pltSL.Path = $script:PSCommandPath ;
            } ;
        } else {
            if(($MyInvocation.MyCommand.Definition -match $rgxPSAllUsersScope) -OR ($MyInvocation.MyCommand.Definition -match $rgxPSCurrUserScope) ){
                 $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
            } elseif(test-path $MyInvocation.MyCommand.Definition) {
                $pltSL.Path = $MyInvocation.MyCommand.Definition ;
            } elseif($cmdletname){
                $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
            } else {
                $smsg = "UNABLE TO RESOLVE A FUNCTIONAL `$CMDLETNAME, FROM WHICH TO BUILD A START-LOG.PATH!" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } #Error|Warn|Debug 
                else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                BREAK ;
            } ; 
        } ;
        write-verbose "start-Log w`n$(($pltSL|out-string).trim())" ; 
        $logspec = start-Log @pltSL ;
        $error.clear() ;
        TRY {
            if($logspec){
                $logging=$logspec.logging ;
                $logfile=$logspec.logfile ;
                $transcript=$logspec.transcript ;
                $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
                start-Transcript -path $transcript ;
            } else {throw "Unable to configure logging!" } ;
        } CATCH [System.Management.Automation.PSNotSupportedException]{
            if($host.name -eq 'Windows PowerShell ISE Host'){
                $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
            } else { 
                $smsg = "This host does *not* support native (start-)transcription" ; 
            } ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ;
        #endregion START-LOG-HOLISTIC #*------^ END START-LOG-HOLISTIC ^------

        #region BANNER ; #*------v BANNER v------
        $sBnr="#*======v $(${CmdletName}): v======" ;
        $smsg = $sBnr ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        #endregion BANNER ; #*------^ END BANNER ^------

    
        # Build a regex char set of chars to be detected and replaced (with the -replace block).
        [array]$chars=@() ;
        $chars+= [Char]0x2013; # en dash
        $chars+= [Char]0x2014; # em dash
        $chars+= [Char]0x2015; # horizontal bar
        $chars+= [Char]0x2017; # double low line
        $chars+= [Char]0x2018; # left single quotation mark
        $chars+= [Char]0x2019; # right single quotation mark
        $chars+= [Char]0x201a; # single low-9 quotation mark
        $chars+= [Char]0x201b; # single high-reversed-9 quotation mark
        $chars+= [Char]0x201c; # left double quotation mark
        $chars+= [Char]0x201d; # right double quotation mark
        $chars+= [Char]0x201e; # double low-9 quotation mark
        $chars+= [Char]0x2026; # horizontal ellipsis
        $chars+= [Char]0x2032; # prime
        $chars+= [Char]0x2033; # double prime
        $chars+= [char]65533;  # Unicode Replacement Character (black diamond questionmark) in hex: [char] 0xfffd
        $chars | ForEach-Object -begin {[string]$rgxChars = $null } -process {$rgxChars+=$_} #-end {"`$rgxChars: $(($rgxChars|out-string).trim())"} ;
        $regex = '[' + [regex]::escape($rgxChars) + ']' ;

    } ;  # BEG-E
    PROCESS{
        $Error.Clear() ;

        foreach($Pth in $Path) {
            TRY{
                switch( (get-item $Pth -ErrorAction STOP).psIsContainer){
                    $true {
                        write-host "Container path detected, recursing files..." ;
                        $smsg = "Collecting matching files:`n$($Pth)..." ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                        else { write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

                        # use select-string to do the regex search for problem chars
                        #$files = Get-ChildItem $Pth\* -Include *.ps1,*.psm1,*.psd1 -recurse |
                        # add ahk cdeblock file support
                        $pltGci=[ordered]@{
                            path="$($Pth)\*" ;
                            #Include='*.ps1', '*.psm1', '*.psd1', '*.cbp' ;
                            Include = $IncludeExtentions ; 
                            recurse=$true ;
                            erroraction = 'STOP' ;
                        } ;
                        $smsg = "Get-ChildItem w`n$(($pltGci|out-string).trim())" ; 
                        if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                        $files = Get-ChildItem @pltGci | where-object { $_.length } ;
                        if ($ReplaceChars) {
                            $smsg = "-ReplaceChars specified: Pulling files with problematic high-ascii chars in specified Path`n$($Pth)" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                            else { write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            $smsg = "`$rgxChars: $(($rgxChars|out-string).trim())"
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                            else { write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                            $smsg = "`$regex:$($regex)" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                            else { write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;

                            #$files = $files | select-string $regex | select -unique Path ;
                        } ;
                
                    }
                    $false {
                        $smsg = "Leaf File object path detected, handling single file:`n$($Pth)..." ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                        $files = Get-ChildItem $Pth -ErrorAction STOP|
                            where-object { $_.length } ;
                        

                    } ;
                } ;

 
                $rfiles = $files | select-string -pattern $regex | select -unique Path ;
                if($rfiles){
                    $smsg = "`nFiles with high-ascii chars detected (use -ReplaceChars to fix):`n$(($rfiles|out-string).trim())" ; 
                    $smsg += "`n`n`$rgxChars: $(($rgxChars|out-string).trim())"
                    $smsg +="`n`$regex:$($regex)" ;
                    $smsg += "`n$(($rfiles | gci |  select-string -pattern $regex |  ft -a filename,linenumber,line|out-string).trim())`n" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } 
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
                } ; 

                $cfiles = $files |
                    select @{n='Path';e={$_.FullName}}, @{n='Encoding';e={Get-FileEncoding $_.FullName}} |
                        Where-Object {$_.Encoding -ne $EncodingTarget} ;
                    # below is no longer the output of get-fileencoding, it's just a string 'Encoding' 
                    #Where-Object {$_.Encoding.HeaderName -ne $EncodingTarget} ;
                $cfiles = $cfiles | select Path ;
                if($cfiles){
                    $smsg = "Files with bad encodings (will be re-encoded):`n$(($cfiles|out-string).trim())" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ; 

                write-verbose "hybrid the two sets"
                #$diff = Compare-Object -ReferenceObject $cfiles -DifferenceObject $rfiles -Property path ; 
                # pull the Additions: entries with .SideIndicator -eq "=>" (present in right list but not in left)
                # $result|?{$_.SideIndicator -eq "=>"}
                # simpler to combo and select uniq
                [array]$tfiles = @() ;
                $tfiles += @($cfiles) ; 
                if ($ReplaceChars){
                    $tfiles += @($rfiles) ; 
                } ; 
                $tfiles = $tfiles.path | select -unique ;

            } CATCH {
                $ErrorTrapped = $Error[0] ;
                #write-warning "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
                $PassStatus += ";ERROR";
                $smsg= "Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } #Error|Warn
                else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" }
                #Continue #STOP(debug)|EXIT(close)|Continue(move on in loop cycle) ;
            } ;

            $ttl=($tfiles|measure).count ;
            $smsg="Processing $($ttl) matching files..." ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $procd=0 ;
            $tfiles | Foreach-Object {
                $procd++ ;
                TRY {
                    #$ofile=$_.path;
                    #$ofile = $_.fullname ; 
                    $ofile = $_
                    write-host -foregroundcolor green "=($($procd)/$($ttl)):$($ofile )" ;
                    $content = (Get-Content -Raw -Encoding $EncodingTarget $ofile -ErrorAction STOP)  ;
                    if ($content.Contains([char]0xfffd)) {
                        $smsg= "--(UTF8 conversion fault)" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        $content = Get-Content -Raw $ofile -ErrorAction STOP ;
                    } ;

                    if ($ReplaceChars){
                        if($content -match $regex){
                            $content = $content -replace [Char]0x2013, "-" `
                            -replace [Char]0x2014, "-" `
                            -replace [Char]0x2015, "-" `
                            -replace [Char]0x2017, "_" `
                            -replace [Char]0x2018, "`'" `
                            -replace [Char]0x2019, "`'" `
                            -replace [Char]0x201a, "," `
                            -replace [Char]0x201b, "`'" `
                            -replace [Char]0x201c, "`"" `
                            -replace [Char]0x201d, "`"" `
                            -replace [Char]0x201e, "`"" `
                            -replace [Char]0x2026, "..." `
                            -replace [Char]0x2032, "`"" `
                            -replace [Char]0x2033, "`"" ;
                        } ;
                        # finally rplc any remaining blackdiamond questionmarks with -
                        $content = $content -replace [char]65533, "-" ;
                    } ;
                    
                    $error.clear() ;
                    #$smsg = "Conv:$((Get-FileEncoding -Path $ofile).headername.tostring())->$($EncodingTarget):$($ofile)" ;
                    # above was working with output of select-string (path), below is gci output (fullname)
                    $smsg = "Conv:$((Get-FileEncoding -Path $ofile).tostring())->$($EncodingTarget):$($ofile)"
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $content | set-content -path $ofile  -Encoding $EncodingTarget  -ErrorAction STOP -whatif:$($whatif) ;
                } CATCH {
                    $ErrorTrapped = $Error[0] ;
                    #write-warning "$(get-date -format 'HH:mm:ss'): Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
                    $PassStatus += ";ERROR";
                    $smsg= "Failed processing $($ErrorTrapped.Exception.ItemName). `nError Message: $($ErrorTrapped.Exception.Message)`nError Details: $($ErrorTrapped)" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error } #Error|Warn
                    else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" }
                    #Continue #STOP(debug)|EXIT(close)|Continue(move on in loop cycle) ;
                    Continue ; 
                } ;
            } ;   # foreach-object-E
        } ;  # loop-E $item ;
    } ; # PROC-E
    END {
        $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
        write-host $stopResults ; 
    } ;  # END-E
}

#*------^ repair-FileEncoding.ps1 ^------


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


#*------v reset-HostIndent.ps1 v------
function reset-HostIndent {
    <#
    .SYNOPSIS
    reset-HostIndent - Utility cmdlet that rests the $env:HostIndentSpaces to 0 (resets prior indenting to left margin)
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : reset-HostIndent.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 2:19 PM 2/15/2023 broadly: moved $PSBoundParameters into test (ensure pop'd before trying to assign it into a new object) ; 
    typo fix, removed [ordered] from hashes (psv2 compat). 
    * 2:01 PM 2/1/2023 add: -PID param
    * 2:39 PM 1/31/2023 updated to work with $env:HostIndentSpaces in process scope. 
    * 9:50 AM 1/17/2023 All need to be recoded to use evari's, scoped varis aren't consistently discoverable, to have the current 'indent depth' being tweaked by pop|push|reset|set and read by write:
    * 4:39 PM 1/11/2023 init
    .DESCRIPTION
    reset-HostIndent - Utility cmdlet that rests the $env:HostIndentSpaces to 0 (resets prior indenting to left margin)

    If it doesn't find a preexisting $IndentHostSpaces in 'private','local','script','global'
    it defaults to intializing to value 0 in the 'local' scope.

    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reset-HostIndent # $env:HostIndentSpaces = 0 ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces -= 4
    set-HostIndent # explicit set to multiples of 4
            
    .PARAMETER PadIncrement
    Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]
    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .EXAMPLE
    PS> reset-HostIndent ;
    PS> $env:HostIndentSpaces ; 
    Simple indented text demo
    .EXAMPLE
    PS>  $domain = 'somedomain.com' ; 
    PS>  write-verbose "Top of code, establish 0 Indent" ;
    PS>  $env:HostIndentSpaces = 0 ;
    PS>  #...
    PS>  # indent & do nested thing
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  reset-HostIndent "Spf Version: $($spfElement)" -verbose ;
    PS>  # nested another level
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: += 4 Net:$($env:HostIndentSpaces)" ;
    PS>  reset-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  reset-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    Independant Demo      
    #>
    [CmdletBinding()]
    [Alias('r-hi')]
    PARAM(
        [Parameter(
            HelpMessage="Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]")]
        [int]$PadIncrement = 4,
        [Parameter(
            HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
            [switch]$usePID
    ) ; 
    BEGIN {
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if(($PSBoundParameters.keys).count -ne 0){
            $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
            write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        } ; 
        $Verbose = ($VerbosePreference -eq 'Continue') ;     
        if($usePID){
            $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $HISName = "Env:HostIndentSpaces$($PID)" ; 
        } else { 
            $HISName = "Env:HostIndentSpaces" ; 
        } ; 
                
        if(($smsg = Get-Item -Path "Env:HostIndentSpaces$($PID)" -erroraction SilentlyContinue).value){
            write-verbose $smsg ; 
        } ; 
        if (-not ([int]$CurrIndent = (Get-Item -Path $HISName -erroraction SilentlyContinue).Value ) ){
            [int]$CurrIndent = 0 ; 
        } ; 
        $pltSV=@{
            Path = $HISName 
            Value = 0; 
            Force = $true ; 
            erroraction = 'STOP' ;
        } ;
        $smsg = "$($CmdletName): Set 1 lvl:Set-Variable w`n$(($pltSV|out-string).trim())" ; 
        write-verbose $smsg  ;
        TRY{
            Set-Item @pltSV ;
        } CATCH {
            $smsg = $_.Exception.Message ;
            write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            BREAK ;
        } ;
    } ;  
}

#*------^ reset-HostIndent.ps1 ^------


#*------v restore-FileTDO.ps1 v------
function restore-FileTDO {
    <#
    .SYNOPSIS
    restore-FileTDO.ps1 - Restore file from prior backup
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2:23 PM 12/29/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    REVISIONS
    * 8:27 AM 5/20/2022 flipped echos w-h -> w-v; catpure set-itemReadOnly return; recoding unset IsReadOnly where restore source is RO'd (leverage new 'set-ItemReadOnly() -clear'); fixed missing trailing "
    * 11:52 AM 5/19/2022 typo fix
    * 8:51 AM 5/16/2022 ren revert-File -> restore-file (stock verb, add my uniquing suffix); add orig to alias; added pipeline handling;
    * 10:35 AM 2/21/2022 CBH example ps> adds
    * 2:23 PM 12/29/2019 init
    .DESCRIPTION
    restore-FileTDO.ps1 - Revert a file to a prior backup of the file
    .PARAMETER  Path
    Path to backup file to be restored
    .PARAMETER Destination
    Optional explicit fullpath file specified as 'source' should be copied to (default behavior is to trim the extension of the trailing time stamp, previously appended via use of backup-FileTDO())[-Dest path-to\script.ps1]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS> $bRet = restore-FileTDO -Source "C:\sc\verb-dev\verb-dev\verb-dev.psm1_20191229-0904AM" -Destination "C:\sc\verb-dev\verb-dev\verb-dev.psm1" -showdebug:$($showdebug) -whatif:$($whatif)
    PS> if (!$bRet) {throw "FAILURE" } ;
    Restore file to prior revision.
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('revert-File','restore-file')]
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to script[-Source path-to\script.ps1]")]
        [ValidateScript( { Test-Path $_ })]
        [Alias('Source')]$Path,
        [Parameter(Position = 0, Mandatory = $False, HelpMessage = "Optional explicit fullpath file specified as 'source' should be copied to (default behavior i8s to trim the extension of the trailing time stamp)[-Dest path-to\script.ps1]")]
        $Destination,
        [Parameter(HelpMessage = "Switch to remove any Readonly setting on source file, on the destionation copy[-NoReadOnly]")]
        [switch] $NoReadOnly,
        [Parameter(HelpMessage = "Debugging Flag [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN{
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        #$PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        $rgxExtensionTimeStamp = '(_\d{8}-\d{4}(A|P)M)$' ;
        $smsg = $sBnr="#*======v $(${CmdletName}): v======" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-verbose $smsg } ;

        if ($Destination -AND ($path -is [system.array])){
            $smsg = "An Array of paths was used, with explicit -Destination:" ;
            $smsg += "`nThis command *does not support explicit -Destination* when processing Path arrays!" ;
            $smsg += "`nIn Array mode, only default 'extension-timestamp-stripping' behavior is permitted. " ;
            $smsg += "`n(Please retry without an explicit -Destination, to use the default behavior)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else { write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            throw $smsg ;
            break ;
        }
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ;
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ;
            write-verbose "(non-pipeline - param - input)" ;
        } ;
        $Procd = 0 ;
    } # BEG-E
    PROCESS{
        foreach($item in $path) {
            $Procd++ ;
            $fnparts = @() ; $ExtTstamp = $null ; 
            $bIsReadOnly = $false ; 
            Try {
                if ($item.GetType().FullName -ne 'System.IO.FileInfo') {
                    $item = get-childitem -path $item ;
                } ;
                $sBnrS = "`n#*------v ($($Procd)):$($item.fullname) v------" ;
                $smsg = "$($sBnrS)" ;
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-verbose $smsg } ; } ;

                $pltCpy = [ordered]@{
                    path        = $item.fullname ;
                    destination = $null ;
                    ErrorAction="Stop" ;
                    whatif      = $($whatif) ;
                } ;
                if(-not $Destination){
                    $fnparts += $item.BaseName ; 
                    if($item.extension){
                        if($ExtTstamp = [regex]::match($item.Extension, $rgxExtensionTimeStamp).captures[0].groups[0].value){
                            $smsg = "(No -Destination specified: Trimming Timestamp $($ExtTstamp) (from existing Extension:$($item.extension))" ;
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                            else{ write-verbose $smsg } ;

                            if($item.extension.split('_')[0] -eq '.'){
                                $smsg = "(original file was extensionless: restoring basename to 'name')" ; 
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                                else{ write-verbose $smsg } ;
                            } else {
                                if($item.extension.replace($ExtTstamp,'') -eq '.'){
                                    $smsg = "(net extension would be blank: dropping extension)" ; 
                                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                                } else { 
                                    #$fnparts += "." ; 
                                    $fnparts += $item.extension.replace($ExtTstamp,'') ;
                                } ; 
                            } ; 
                        
                            $pltCpy.destination = join-path -path (split-path $item.fullname) -ChildPath ($fnparts -join '') ; 
                        } else {
                                $smsg = "UNABLE TO RESOLVE TIMESTAMP FROM EXTENSION, AND NO -Destination SPECIFIED!" ;
                                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
                                else{ WRITE-WARNING  "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                                throw $smsg;
                                break ;
                        } ;
                    } else { 
                        $smsg = "Invalid restore -path specified:`n'($item.name)' has NO EXTENSION!" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug
                        else{ WRITE-WARNING  "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        throw $smsg;
                        break ;
                    } ; 
                } else {
                    $pltCpy.destination = $Destination
                    $smsg = "-Destination specified: $($pltCpy.destination)" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ;
            } Catch {
                $ErrorTrapped = $Error[0] ;
                Write-WARNING "Failed to exec cmd because: $($ErrorTrapped)" ;
            }  ;

            if($NoReadOnly){
                write-verbose "(checking Source for ReadOnly property)" ; 
                if((get-itemproperty -Path $pltCpy.path).IsReadOnly){
                    WRITE-VERBOSE "(IsReadOnly detected)" ; 
                    $bIsReadOnly = $true ; 
                } ; 
            } ; 

            $smsg = "RESTORE:copy-item w`n$(($pltCpy|out-string).trim())" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
            else{ write-verbose $smsg } ;
            $Exit = 0 ;
            Do {
                $error.clear() ;
                Try {
                    copy-item @pltCpy ;
                    if($bIsReadOnly -AND $NoReadOnly){
                        $smsg = "(-NoReadOnly:clearing source file, restored IsReadOnly to :`$False)"
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                        else{ write-host -foregroundcolor gray "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                        $pltIRO=[ordered]@{Clear = $true ;Path =$pltCpy.Destination ;Verbose =$($verbose) ;whatif =$($whatif) ;} 
                        $smsg = "NoReadOnly:Set-ItemReadOnlyTDO w`n$(($pltIRO|out-string).trim())" ;
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                        else{ write-verbose $smsg } ;
                        # capture emitted pipe output
                        $bRet = Set-ItemReadOnlyTDO @pltIRO ; 
                    } ; 
                    $Exit = $Retries ;
                } Catch {
                    $ErrorTrapped = $Error[0] ;
                    Write-WARNING "Failed to exec cmd because: $($ErrorTrapped)" ;
                    Start-Sleep -Seconds $RetrySleep ;
                    $Exit ++ ;
                    Write-WARNING "Try #: $Exit" ;
                    If ($Exit -eq $Retries) { Write-Warning "Unable to exec cmd!" } ;
                }  ;
            } Until ($Exit -eq $Retries) ;

            # validate copies *exact*
            if (-not $whatif) {
                $smsg = "(Compare-Object restored obj to source)" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;  
                if (Compare-Object -ReferenceObject $(Get-Content $pltCpy.path) -DifferenceObject $(Get-Content $pltCpy.destination)) {
                    $smsg = "BAD COPY!`n$pltCpy.path`nIS DIFFERENT FROM`n$pltCpy.destination!`nEXITING!";
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Error }  #Error|Warn|Debug
                    else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $false | write-output ;
                } Else {
                    $smsg = "Validated Copy:`n$($pltCpy.path)`n*matches*`n$($pltCpy.destination)"; ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                    else{ write-verbose  "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    $pltCpy.destination | write-output ;
                } ;
            } else {
                #$true | write-output ;
                $pltCpy.destination | write-output ;
            };
            $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-verbose $smsg } ; } ;
        }   # loop-E
    } ;  # E PROC
    END{
         $smsg = $sBnr.replace('=v','=^').replace('v=','^=') ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-verbose $smsg } ;
    }
}

#*------^ restore-FileTDO.ps1 ^------


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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
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
      [Parameter(ParameterSetName='Object', Mandatory=$true, ValueFromPipeline=$true)]
      [psobject] ${InputObject},

      [Parameter(Mandatory=$true, Position=0)]
      [string[]] ${Pattern},

      [Parameter(ParameterSetName='File', Mandatory=$true, Position=1, ValueFromPipelineByPropertyName=$true)]
      [string[]] ${Path},

      [Parameter(ParameterSetName='LiteralFile', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
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
                        WordDelimiters                         : ;:,.[]{}()/\|^&*-=+'"–—―
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


#*------v Set-ContentFixEncoding.ps1 v------
function Set-ContentFixEncoding {
    <#
    .SYNOPSIS
    Set-ContentFixEncoding - Set-Content variant that auto-coerces the encoding to UTF8 
    .NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-05-03
    FileName    : Set-ContentFixEncoding.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,File,Encoding,Management
    REVISIONS   :
    * 2:11 PM 11/7/2022 add missing [dot]example in CBH
    * 12:21 PM 9/26/2022 add back -showdebug with 'deprecated' tag (better to use verbose); i've got code out there trying to use it and throwing up.
    *4:26 PM 5/27/2022 fixed typo in doloop #98: $Retries => $DoRetries (loop went full dist before exiting, even if successful 1st attempt)
    * 10:01 AM 5/17/2022 updated CBH exmple
    * 10:39 AM 5/13/2022 removed 'requires -modules', to fix nesting limit error loading verb-io
    * 2:37 PM 5/10/2022 add array back to $value, saw signs it was flattening systemobjects coming in as an array of lines, and only writing the last line to the -path.
    * 12:45 PM 5/9/2022 flipped pipeline to the Value param (from Path); pulled array spec on both - should be one value into one file, not loop one into a series ;
        yanked advfunc, and all looping other than retry. 
    * 9:25 AM 5/4/2022 add -passthru support, rather than true/false return ; add retry code & $DoRetries, $RetrySleep; alias 'Set-FileContent', retire the other function
    * 11:24 AM 5/3/2022 init
    .DESCRIPTION
    Set-ContentFixEncoding - Set-Content variant that auto-coerces the encoding to UTF8 
    
    NOTE: at the current time - 2:21 PM 11/7/2022 - do *not* use this with get-FileEncoding to update encoding (found it emptying target file, likely inbound pipeline issue for $Value)
    Use set-Content as per the example from get-FileEncoding:
    
    PS> $Encoding = 'UTF8' ; 
    PS> Get-ChildItem  *.ps1 | ?{$_.length -gt 0} | 
    PS>    select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | 
    PS>    where {$_.Encoding -ne $Encoding} | foreach-object { 
    PS>        write-host "==$($_.fullname):" ; 
    PS>        (get-content $_.FullName) | set-content $_.FullName -Encoding $Encoding -whatif ;
    PS>    } ;
    Gets ps1 files in current directory (with non-zero length) where encoding is not UTF8, and then sets encoding to UTF8 using set-content ;
    
    .PARAMETER Path
    Specifies the path of the item that receives the content.[-Path c:\pathto\script.ps1]
    .PARAMETER Value
    Specifies the new content for the item.[-value $content]
    .PARAMETER Encoding
    Specifies the type of encoding for the target file. The default value is 'UTF8'.[-encoding Unicode]
    .PARAMETER PassThru
    Returns an object that represents the content. By default, this cmdlet does not generate any output [-PassThru]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages (deprecated) [-ShowDebug switch]
    .PARAMETER whatIf
    Whatif switch [-whatIf]
    .INPUTS
    Accepts piped input (computername).
    .OUTPUTS
    System.String
    .DESCRIPTION
    Set-ContentFixEncoding - Set-Content variant that auto-coerces the encoding to UTF8 
    .EXAMPLE
    PS> Set-ContentFixEncoding -Path c:\tmp\tmp20220503-1101AM.ps1 -Value 'write-host blah' -verbose ;
    Adds specified value to specified file, (auto-coercing encoding to UTF8)
    .EXAMPLE
    PS> $bRet = Set-ContentFixEncoding -Value $updatedContent -Path $outfile -PassThru -Verbose -whatif:$($whatif) ;
    PS> if (!$bRet) {throw "FAILURE" } ;
    Demo use of -PassThru to return the set Content, for validation
    .EXAMPLE
    PS> $bRet = Set-ContentFixEncoding @pltSCFE -Value $newContent ; 
    PS> if(-not $bRet -AND -not $whatif){throw "Set-ContentFixEncoding $($tf)!" } ;
    PS> $PassStatus += ";Set-Content:UPDATED";     
    Demo with broader whatif-conditional post test, and $PassStatus support
    .LINK
    https://github.com/tostka/verb-io
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("US","GB","AU")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)]#positiveInt:[ValidateRange(0,[int]::MaxValue)]#negativeInt:[ValidateRange([int]::MinValue,0)][ValidateCount(1,3)]
    ## [OutputType('bool')] # optional specified output type
    [CmdletBinding()]
    [Alias('Set-FileContent')]
    Param(
        #[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the path of the item that receives the content.[-Path c:\pathto\script.ps1]')]
        [Parameter(Mandatory = $true,Position = 0,HelpMessage = 'Specifies the path of the item that receives the content.[-Path c:\pathto\script.ps1]')]
        [Alias('PsPath','File')]
        #[system.io.fileinfo[]]$Path,
        [system.io.fileinfo]$Path,
        [Parameter(Mandatory = $true,Position = 1,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the new content for the item.[-value $content]')]
        [Alias('text','string')]
        [System.Object[]]$Value,
        #[System.Object]$Value,
        [Parameter(HelpMessage = "Specifies the type of encoding for the target file. The default value is 'UTF8'.[-encoding Unicode]")]
        [ValidateSet('Ascii','BigEndianUnicode','BigEndianUTF32','Byte','Default','Oem','String','Unicode','Unknown','UTF7','UTF8','UTF32')]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$encoding='UTF8',
        [Parameter(HelpMessage = "Returns an object that represents the content. By default, this cmdlet does not generate any output [-PassThru]")]
        [switch] $PassThru,
        [Parameter(HelpMessage = "Debugging Flag (deprecated) [-showDebug]")]
        [switch] $showDebug,
        [Parameter(HelpMessage = "Whatif switch [-whatIf]")]
        [switch] $whatIf
    ) ;
    # Get parameters this function was invoked with
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    write-verbose  "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
    $verbose = $($VerbosePreference -eq "Continue") ; 
    if(-not $DoRetries){$DoRetries = 4 } ;
    if(-not $RetrySleep){$RetrySleep = 10 } ; 

    $smsg = "(Set-ContentFixEncoding:$($Path.FullName))" ;
    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    # set-content overwrites target file, no need to pretest and attempt to retain, just force to encoding specified
    $pltSetCon = @{ Path=$Path.FullName ; encoding=$encoding ; ErrorAction = 'STOP' ; PassThru = $($PassThru); whatif=$($whatif) ;  } ;
    $smsg = "Set-Content w`n$(($pltSetCon|out-string).trim())" ; 
    $smsg += "`n-Value[0,2]:`n$(($value | out-string).Split([Environment]::NewLine, [StringSplitOptions]::RemoveEmptyEntries)| select -first 2|out-string)" ; 
    if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
    $Exit = 0 ;
    Do {
        Try{
            $Returned = Set-Content @pltSetCon -Value $Value ;
            $Returned | write-output ;
            $Exit = $DoRetries ;
        }Catch{
            #Write-Error -Message $_.Exception.Message ;
            $ErrTrapd=$Error[0] ;
            $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
            else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #-=-record a STATUSWARN=-=-=-=-=-=-=
            $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
            if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
            if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
            start-sleep -s $RetrySleep ; 
            Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
        } ;
    } Until ($Exit -eq $DoRetries) ;
}

#*------^ Set-ContentFixEncoding.ps1 ^------


#*------v set-FileAssociation.ps1 v------
function set-FileAssociation {
    <#
    .SYNOPSIS
    set-FileAssociation.ps1 - Create or Update Windows File Association. Wraps underlying ftype.exe & assoc.exe OS commands to implement changes. 
    .NOTES
    Version     : 1.6.2
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2019-02-06
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/powershell
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 12:39 PM 2/17/2023 rem'd spurious alias to fix-encoding
    * 4:29 PM 2/1/2023 fixed misrenamed file; removed all requires entries (was circular at min). 
    * 10:10 AM 12/10/2022 TSK:updated
    * posted vers
    .DESCRIPTION
    set-FileAssociation.ps1 - Create or Update Windows File Association. Wraps underlying ftype.exe & assoc.exe OS commands to implement changes. 
    .PARAMETER  Path
    Path to a file or Directory to be checked for encoding or encoding-conversion damage [-Path C:\sc\powershell]
    .PARAMETER EncodingTarget
    Encoding to be coerced on targeted files (defaults to UTF8, supports:ASCII|BigEndianUnicode|BigEndianUTF32|Byte|Default (system active codepage, freq ANSI)|OEM|String|Unicode|UTF7|UTF8|UTF32)[-EncodingTarget ASCII]
    .PARAMETER showDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .EXAMPLE
    PS> set-FileAssociation.ps1 -replaceChars
    In files in default path (C:\sc\powershell), in files Where-Object high-ascii chars are found, replace the chars with matching low-bit chars (whatif is autoforced true to ensure no accidental runs)
    .EXAMPLE
    PS> set-FileAssociation.ps1 -path C:\sc\verb-AAD -replacechars -whatif:$false ;
    Exec-pass: problem char files, replacements, with explicit path and overridden whatif
    .EXAMPLE
    PS> gci c:\sc\ -recur| ?{$_.extension -match '\.ps((d|m)*)1' } | 
    PS>     select -expand fullname | set-FileAssociation -whatif ;
    Recurse a sourcecode root, for ps-related files, expand the fullnames and run the set through set-FileAssociation with whatif
    .LINK
    https://github.com/tostka/verb-io
    #>
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("USEA","GBMK","AUSYD")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)][ValidateCount(1,3)]
    [CmdletBinding()]
    #[Alias('fix-encoding')]
    PARAM(
        [Parameter(Mandatory=$true,HelpMessage="Specifies the file extension to associate the file type with[-ext .txt")]
        [string]$ext,
        [Parameter(Mandatory=$false,HelpMessage="Specifies the file type to associate with the file extension[-fileType 'Text Document'")]
        [string]$name,
        #fileType,
        #openCommandString Specifies the open command to use when launching files of this type.
        [Parameter(Mandatory=$true,HelpMessage="Specifies the open command to use when launching files of this type[-ext .txt")]
        [ValidateScript({Test-Path $_ })]
        [string]$exe,
        #openCommandString        
        [Parameter(HelpMessage="Whatif Flag  [-whatIf]")]
        [switch] $whatIf=$true
    ) ;
    #*======v SUB MAIN v======
    #region INIT; # ------
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    $Verbose = ($VerbosePreference -eq 'Continue') ;
    
    write-verbose 'confirm existing filetype' ; 
    [boolean]$ftypeFound = $false ; 
    if($name){
        if($ttype = (cmd /c "assoc $ext 2>NUL").split('=')[1]){
            $ftypeFound = $true ; 
            write-verbose "Found a existig filetype for $($ext)" ; 
        } else { 
            $ftypeFound = $false ; 
            write-verbose "NO matching existig filetype found for $($ext) (creating new)" ;
        } ; 
    } else { 
        $name = cmd /c "assoc $ext 2>NUL"
    }

    if ($name) { 
        write-verbose 'Association already exists: override it'
        $name = $name.Split('=')[1] ; 
    } else { 
        write-verbose "Name doesn't exist: create it" ; 
        $name = "$($ext.Replace('.',''))file" 
        # ".log.1" becomes "log1file" ; 
        $excCmd = "cmd /c 'assoc $($ext)=$name'"
        if($whatif){
            $smsg = "-whatif:invoke-command`n$(($excCmd |out-string).trim())" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
        } else { 
            cmd /c 'assoc $ext=$name'
        } ; 
    }
    cmd /c "ftype $name=`"$exe`" `"%1`""
   

    
    
}

#*------^ set-FileAssociation.ps1 ^------


#*------v set-HostIndent.ps1 v------
function set-HostIndent {
    <#
    .SYNOPSIS
    set-HostIndent - Utility cmdlet that explicitly forces the $env:HostIndentSpaces to a known interval of 4 (or the configured `$PadIncrement)
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : set-HostIndent.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    REVISIONS
    * 2:19 PM 2/15/2023 broadly: moved $PSBoundParameters into test (ensure pop'd before trying to assign it into a new object) ; 
        typo fix, removed [ordered] from hashes (psv2 compat); fixed typo'd alias
    * 2:40 PM 2/2/2023 correct typo: alias pop-hi -> s-hi; 
    * 2:01 PM 2/1/2023 add: -PID param
    * 2:39 PM 1/31/2023 updated to work with $env:HostIndentSpaces in process scope. 
    * 9:50 AM 1/17/2023 All need to be recoded to use evari's, scoped varis aren't consistently discoverable, to have the current 'indent depth' being tweaked by pop|push|reset|set and read by write:
    * 4:39 PM 1/11/2023 init
    .DESCRIPTION
    set-HostIndent - Utility cmdlet that explicitly forces the $env:HostIndentSpaces to a known interval of 4 (or the configured `$PadIncrement)

    If it doesn't find a preexisting $IndentHostSpaces in 'private','local','script','global'
    it throws an error

    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reset-HostIndent # $env:HostIndentSpaces = 0 ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    set-HostIndent # explicit set to multiples of 4
            

    Concept inspired by L5257's printIndent() in his get-DNSspf.ps1 (which ran a simple write-host -nonewline loop, to be run prior to write-host use). 

    .PARAMETER PadIncrement
    Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]
    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .EXAMPLE
    PS> set-HostIndent ;
    PS> $env:HostIndentSpaces ; 
    Simple indented text demo
    .EXAMPLE
    PS>  $domain = 'somedomain.com' ; 
    PS>  write-verbose "Top of code, establish 0 Indent" ;
    PS>  $env:HostIndentSpaces = 0 ;
    PS>  #...
    PS>  # indent & do nested thing
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ; ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  set-HostIndent "Spf Version: $($spfElement)" -verbose ;
    PS>  # nested another level
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ; ;
    PS>  write-verbose "`$env:HostIndentSpaces: += 4 Net:$($env:HostIndentSpaces)" ;
    PS>  set-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ; ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ; ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  set-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    Typical usage demo      
    #>
    [CmdletBinding()]
    [Alias('pop-hi')]
    PARAM(
        [Parameter(Position=0,
            HelpMessage="Number of spaces to set write-hostIndent current indent (`$scop:HostIndentpaces) to.[-Spaces 8]")]
            [int]$Spaces,
        [Parameter(
            HelpMessage="Number of spaces to pad by default (defaults to 4).[-PadIncrement 8]")]
        [int]$PadIncrement = 4,
        [Parameter(
            HelpMessage="Mathematical rounding logic to use for calculating nearest multiple of PadIncrement (RoundUp|RoundDown|AwayFromZero|Midpoint, default:RoundUp)[-Rounding awayfromzero]")]
            [ValidateSet('RoundUp','RoundDown','AwayFromZero','Midpoint')]
            [string]$Rounding = 'RoundUp',
        [Parameter(
            HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
            [switch]$usePID
    ) ;
    BEGIN {
    #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
    # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    if(($PSBoundParameters.keys).count -ne 0){
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
    } ;
    $Verbose = ($VerbosePreference -eq 'Continue') ;
    #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

    write-verbose "$($CmdletName): Using `$PadIncrement:`'$($PadIncrement)`'" ;
    switch($Rounding){
        'RoundUp' {
            $Spaces = ([system.math]::ceiling($Spaces/$PadIncrement))*$PadIncrement  ;
            write-verbose "Rounding:Roundup specified: Rounding to: $($Spaces)" ;
            }
        'RoundDown' {
            $Spaces = ([system.math]::floor($Spaces/$PadIncrement))*$PadIncrement  ;
            write-verbose "Rounding:RoundDown specified: Rounding to: $($Spaces)" ;
            }
        'AwayFromZero' {
            $Spaces = ([system.math]::round($_/$PadIncrement,0,1))*$PadIncrement  ;
            write-verbose "Rounding:AwayFromZero specified: Rounding to: $($Spaces)" ;
        }
        'Midpoint' {
            $Spaces = ([system.math]::round($_/$PadIncrement))*$PadIncrement  ;
            write-verbose "Rounding:Midpoint specified: Rounding to: $($Spaces)" ;
        }
    } ;

    #if we want to tune this to a $PID-specific variant, use:
    if($usePID){
            $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $HISName = "Env:HostIndentSpaces$($PID)" ;
        } else {
            $HISName = "Env:HostIndentSpaces" ;
        } ;
        if(($smsg = Get-Item -Path "Env:HostIndentSpaces$($PID)" -erroraction SilentlyContinue).value){
            write-verbose $smsg ;
        } ;
        if (-not ([int]$CurrIndent = (Get-Item -Path $HISName -erroraction SilentlyContinue).Value ) ){
            [int]$CurrIndent = 0 ;
        } ;
        write-verbose "$($CmdletName): Discovered `$$($HISName):$($CurrIndent)" ;
        $pltSV=@{
            Path = $HISName ;
            Value = $Spaces;
            Force = $true ;
            erroraction = 'STOP' ;
        } ;
        $smsg = "$($CmdletName): Set 1 lvl:Set-Variable w`n$(($pltSV|out-string).trim())" ;
        write-verbose $smsg  ;
        TRY{
            Set-Item @pltSV ;
        } CATCH {
            $smsg = $_.Exception.Message ;
            write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
            BREAK ;
        } ;
    } ;
}

#*------^ set-HostIndent.ps1 ^------


#*------v set-ItemReadOnlyTDO.ps1 v------
function set-ItemReadOnlyTDO {
    <#
    .SYNOPSIS
    set-ItemReadOnlyTDO.ps1 - Set an item Readonly
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	https://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2:23 PM 12/29/2019
    FileName    :
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    REVISIONS
    * 1:25 PM 5/20/2022 flipped echos w-h -> w-v
    * 3:43 PM 5/19/2022 init
    .DESCRIPTION
    set-ItemReadOnlyTDO.ps1 - Set an item Readonly
    .PARAMETER  Path
    Path to backup file to be restored
    .PARAMETER Clear
    Switch to 'clear' IsReadOnly item property (e.g. set writable)[-Clear]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass [-Whatif switch]
    .INPUT
    Accepts pipeline input
    .OUTPUT
    System.Object
    .EXAMPLE
    PS> $bRet = set-ItemReadOnlyTDO -path "C:\sc\verb-dev\verb-dev\verb-dev.psm1_20191229-0904AM"  -whatif:$($whatif)
    PS> if (-not $bRet.IsReadOnly -and -not $whatif) {throw "FAILURE" } ;
    Set specified path IsReadOnly
    .EXAMPLE
    PS> $bRet = set-ItemReadOnlyTDO -path "C:\sc\verb-dev\verb-dev\verb-dev.psm1_20191229-0904AM"  -Clear -whatif:$($whatif)
    PS> if ($bRet.IsReadOnly -and -not $whatif) {throw "FAILURE" } ;
    Clear specified path IsReadOnly setting (set to $false)
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    #[Alias('')]
    PARAM(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = "Path to item[-Path path-to\file.ext]")]
        [ValidateScript( { Test-Path $_ })]
        [Alias('Source')]
        [string[]]$Path,
        [Parameter(HelpMessage = "Switch to 'clear' IsReadOnly item property (e.g. set writable)[-Clear]")]
        [switch] $Clear,
        [Parameter(HelpMessage = "Whatif Flag  [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN{
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        #$PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        $smsg = $sBnr="#*======v $(${CmdletName}):$(-not $Clear) v======" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-verbose $smsg } ;
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ;
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ;
            write-verbose "(non-pipeline - param - input)" ;
        } ;
        $Procd = 0 ;
    } # BEG-E
    PROCESS{
        foreach($item in $path) {
            $Procd++ ;
            $bSetReadOnly = $bIsReadOnly = $false ; 
            Try {
                if ($item.GetType().FullName -ne 'System.IO.FileInfo') {
                    $item = get-childitem -path $item ;
                } ;
                $sBnrS = "`n#*------v ($($Procd)):$($item.fullname) v------" ;
                $smsg = "$($sBnrS)" ;
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-verbose $smsg } ; } ;

                if((get-itemproperty -Path $Item.fullname).IsReadOnly){
                    $bIsReadOnly = $true ;
                } else {
                    $bIsReadOnly = $false
                } ; 
                write-verbose "$($Item.fullname):IsReadonly:$($bIsReadOnly)" ; 
                $pltSIp = [ordered]@{
                    path = $item.fullname ;
                    Name ='IsReadOnly' ;
                    Value = $null;
                    ErrorAction = 'STOP' ;
                    PassThru = $true ; 
                    whatif = $($whatif) ;
                } ;
                if( -not $Clear -AND -not $bIsReadOnly){
                    $smsg = "IsReadOnly:$($bIsReadOnly):Setting IsReadOnly:$true" ; ; 
                    $bSetReadOnly= $true ; 
                    $pltSIp.Value = $true ;
                } elseif( -not $Clear -AND $bIsReadOnly){
                    $smsg = "$($Item.fullname) is *already* Readonly" ; 
                    $pltSIp.Value = $null ;
                } elseif( $Clear -AND -not $bIsReadOnly){
                    $smsg = "$($Item.fullname) is *already* -NOT Readonly" ; 
                    $pltSIp.Value = $null
                } elseif( $Clear -AND $bIsReadOnly){
                    $bSetReadOnly= $false ; 
                    $pltSIp.Value = $false ;
                } else { 
                    $smsg = "unrecognized parameter combo!" ; 
                    write-warning $smsg 
                    break ; 
                } ; 
            } Catch {
                $ErrorTrapped = $Error[0] ;
                Write-Warning "Failed to exec cmd because: $($ErrorTrapped)" ;
                Start-Sleep -Seconds $RetrySleep ;
                # reconnect-exo/reconnect-ex2010
                $Exit ++ ;
                Write-Warning "Try #: $Exit" ;
                If ($Exit -eq $Retries) { Write-Warning "Unable to exec cmd!" } ;
            }  ;
            
            if($pltSIp.Value -eq $null ){
                # no action
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-verbose $smsg } ;
            } else {
                # if value $true|$false: update the value
                $smsg = "IsREADONLY:Set-ItemProperty w`n$(($pltSIp|out-string).trim())" ;
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }  #Error|Warn|Debug
                else{ write-verbose $smsg } ;
                $Exit = 0 ;
                Do {
                    $error.clear() ;
                    Try {
                        $oReturn = Set-ItemProperty @pltSIp ; 
                        $oReturn | write-output ; 
                        $Exit = $Retries ;
                    } Catch {
                        $ErrorTrapped = $Error[0] ;
                        Write-Verbose "Failed to exec cmd because: $($ErrorTrapped)" ;
                        Start-Sleep -Seconds $RetrySleep ;
                        # reconnect-exo/reconnect-ex2010
                        $Exit ++ ;
                        Write-Verbose "Try #: $Exit" ;
                        If ($Exit -eq $Retries) { Write-Warning "Unable to exec cmd!" } ;
                    }  ;
                } Until ($Exit -eq $Retries) ;
            } ; 
            $smsg = "$($sBnrS.replace('-v','-^').replace('v-','^-'))" ;
            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
            else{ write-verbose $smsg } ; } ;
        }   # loop-E
    } ;  # E PROC
    END{
         $smsg = $sBnr.replace('=v','=^').replace('v=','^=') ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-verbose $smsg } ;
    }
}

#*------^ set-ItemReadOnlyTDO.ps1 ^------


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
    * 9:00 AM 12/22/2022 flipped start-log -notimestamp:$true
    * 9:00 AM 12/12/2022 fixed broken added logging (spliced over holistic intact, w looping timestamp exempt)
    * 10:50 AM 11/29/2022 added logging, to track how often landesk processes are impeding productive work.
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
    
    #*======v SUB MAIN v======
    #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
    # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
    write-verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
    $Verbose = ($VerbosePreference -eq 'Continue') ; 
    #if ($PSScriptRoot -eq "") {
    if( -not (get-variable -name PSScriptRoot -ea 0) -OR ($PSScriptRoot -eq '')){
        if ($psISE) { $ScriptName = $psISE.CurrentFile.FullPath } 
        elseif($psEditor){
            if ($context = $psEditor.GetEditorContext()) {$ScriptName = $context.CurrentFile.Path } 
        } elseif ($host.version.major -lt 3) {
            $ScriptName = $MyInvocation.MyCommand.Path ;
            $PSScriptRoot = Split-Path $ScriptName -Parent ;
            $PSCommandPath = $ScriptName ;
        } else {
            if ($MyInvocation.MyCommand.Path) {
                $ScriptName = $MyInvocation.MyCommand.Path ;
                $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent ;
            } else {throw "UNABLE TO POPULATE SCRIPT PATH, EVEN `$MyInvocation IS BLANK!" } ;
        };
        if($ScriptName){
            $ScriptDir = Split-Path -Parent $ScriptName ;
            $ScriptBaseName = split-path -leaf $ScriptName ;
            $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($ScriptName) ;
        } ; 
    } else {
        if($PSScriptRoot){$ScriptDir = $PSScriptRoot ;}
        else{
            write-warning "Unpopulated `$PSScriptRoot!" ; 
            $ScriptDir=(Split-Path -parent $MyInvocation.MyCommand.Definition) + "\" ;
        }
        if ($PSCommandPath) {$ScriptName = $PSCommandPath } 
        else {
            $ScriptName = $myInvocation.ScriptName
            $PSCommandPath = $ScriptName ;
        } ;
        $ScriptBaseName = (Split-Path -Leaf ((& { $myInvocation }).ScriptName))  ;
        $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;
    } ;
    if(!$ScriptDir){
        write-host "Failed `$ScriptDir resolution on PSv$($host.version.major): Falling back to $MyInvocation parsing..." ; 
        $ScriptDir=(Split-Path -parent $MyInvocation.MyCommand.Definition) + "\" ;
        $ScriptBaseName = (Split-Path -Leaf ((&{$myInvocation}).ScriptName))  ; 
        $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;     
    } else {
        if(-not $PSCommandPath ){
            $PSCommandPath  = $ScriptName ; 
            if($PSCommandPath){ write-host "(Derived missing `$PSCommandPath from `$ScriptName)" ; } ;
        } ; 
        if(-not $PSScriptRoot  ){
            $PSScriptRoot   = $ScriptDir ; 
            if($PSScriptRoot){ write-host "(Derived missing `$PSScriptRoot from `$ScriptDir)" ; } ;
        } ; 
    } ; 
    if(-not ($ScriptDir -AND $ScriptBaseName -AND $ScriptNameNoExt)){ 
        throw "Invalid Invocation. Blank `$ScriptDir/`$ScriptBaseName/`ScriptNameNoExt" ; 
        BREAK ; 
    } ; 

    $smsg = "`$ScriptDir:$($ScriptDir)" ;
    $smsg += "`n`$ScriptBaseName:$($ScriptBaseName)" ;
    $smsg += "`n`$ScriptNameNoExt:$($ScriptNameNoExt)" ;
    $smsg += "`n`$PSScriptRoot:$($PSScriptRoot)" ;
    $smsg += "`n`$PSCommandPath:$($PSCommandPath)" ;  ;
    write-host $smsg ; 
    
    $ComputerName = $env:COMPUTERNAME ;
    $NoProf = [bool]([Environment]::GetCommandLineArgs() -like '-noprofile'); # if($NoProf){# do this};
    #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

    #region START-LOG #*======v START-LOG OPTIONS v======
    #region START-LOG-HOLISTIC #*------v START-LOG-HOLISTIC v------
    # Single log for script/function example that accomodates detect/redirect from AllUsers scope'd installed code, and hunts a series of drive letters to find an alternate logging dir (defers to profile variables)
    #${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
    if(!(get-variable LogPathDrives -ea 0)){$LogPathDrives = 'd','c' };
    foreach($budrv in $LogPathDrives){if(test-path -path "$($budrv):\scripts" -ea 0 ){break} } ;
    if(!(get-variable rgxPSAllUsersScope -ea 0)){
        $rgxPSAllUsersScope="^$([regex]::escape([environment]::getfolderpath('ProgramFiles')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps(((d|m))*)1|dll)$" ;
    } ;
    if(!(get-variable rgxPSCurrUserScope -ea 0)){
        $rgxPSCurrUserScope="^$([regex]::escape([Environment]::GetFolderPath('MyDocuments')))\\((Windows)*)PowerShell\\(Scripts|Modules)\\.*\.(ps((d|m)*)1|dll)$" ;
    } ;
    $pltSL=[ordered]@{Path=$null ;NoTimeStamp=$true ;Tag=$null ;showdebug=$($showdebug) ; Verbose=$($VerbosePreference -eq 'Continue') ; whatif=$($whatif) ;} ;
    #$pltSL.Tag = $ModuleName ; 
    if($NoLoop){
        $pltSL.NoTimestamp = $true ;
        $smsg = "-NoLoop specified:"
    } else { 
        $smsg = "(Looping...):" ; 
        $pltSL.NoTimestamp = $false ; 
    } ; 
    if($script:PSCommandPath){
        if(($script:PSCommandPath -match $rgxPSAllUsersScope) -OR ($script:PSCommandPath -match $rgxPSCurrUserScope)){
            $bDivertLog = $true ; 
            switch -regex ($script:PSCommandPath){
                $rgxPSAllUsersScope{$smsg = "AllUsers"} 
                $rgxPSCurrUserScope{$smsg = "CurrentUser"}
            } ;
            $smsg += " context script/module, divert logging into [$budrv]:\scripts" 
            write-verbose $smsg  ;
            if($bDivertLog){
                if((split-path $script:PSCommandPath -leaf) -ne $cmdletname){
                    # function in a module/script installed to allusers|cu - defer name to Cmdlet/Function name
                    $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
                } else {
                    # installed allusers|CU script, use the hosting script name
                    $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
                }
            } ;
        } else {
            $pltSL.Path = $script:PSCommandPath ;
        } ;
    } else {
        if(($MyInvocation.MyCommand.Definition -match $rgxPSAllUsersScope) -OR ($MyInvocation.MyCommand.Definition -match $rgxPSCurrUserScope) ){
             $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath (split-path $script:PSCommandPath -leaf)) ;
        } elseif(test-path $MyInvocation.MyCommand.Definition) {
            $pltSL.Path = $MyInvocation.MyCommand.Definition ;
        } elseif($cmdletname){
            $pltSL.Path = (join-path -Path "$($budrv):\scripts" -ChildPath "$($cmdletname).ps1") ;
        } else {
            $smsg = "UNABLE TO RESOLVE A FUNCTIONAL `$CMDLETNAME, FROM WHICH TO BUILD A START-LOG.PATH!" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Warn } #Error|Warn|Debug 
            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            BREAK ;
        } ; 
    } ;
    write-verbose "start-Log w`n$(($pltSL|out-string).trim())" ; 
    $logspec = start-Log @pltSL ;
    $error.clear() ;
    TRY {
        if($logspec){
            $logging=$logspec.logging ;
            $logfile=$logspec.logfile ;
            $transcript=$logspec.transcript ;
            $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
            if($stopResults){
                $smsg = "Stop-transcript:$($stopResults)" ; 
                if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
            } ; 
            $startResults = start-Transcript -path $transcript ;
            if($startResults){
                $smsg = "start-transcript:$($startResults)" ; 
                if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            } ; 
        } else {throw "Unable to configure logging!" } ;
    } CATCH [System.Management.Automation.PSNotSupportedException]{
        if($host.name -eq 'Windows PowerShell ISE Host'){
            $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
        } else { 
            $smsg = "This host does *not* support native (start-)transcription" ; 
        } ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } CATCH {
        $ErrTrapd=$Error[0] ;
        $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug
        else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ;
    #endregion START-LOG-HOLISTIC #*------^ END START-LOG-HOLISTIC ^------
    #-=-=-=-=-=-=-=-=

    $smtpFrom = (($scriptBaseName.replace(".","-")) + "@toro.com") ; 

    #endregion INIT; # ------
    
    $smsg = "$((get-date).ToString('HH:mm:ss')):KILLING DRIVE SUCKERS!`nQUIT READING BY THE HARDDRIVE LIGHT!" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    #Levels:Error|Warn|Info|H1|H2|H3|Debug|Verbose|Prompt
    "LDIScn32","Cagent32","gatherproducts" | foreach {
        #"==Checking for $($_)" ;
        if($gp=get-process "$($_)" -ea 0 ){
            $smsg = "$((get-date).ToString('HH:mm:ss')):PROCMATCH:Stopping proc:`n$(($gp | ft -auto ID,ProcessName|out-string).trim())" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $gp | stop-process -force -whatif:$($whatif)
        } else {
            $smsg = "$((get-date).ToString('HH:mm:ss')):(no $($_) processes found)" ; 
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        } ; 
    } ; 

    #  tack index stop in here too
    $stat=(Get-Service -Name wsearch).status ; 
    $smsg = "$((get-date).ToString('HH:mm:ss')):===Windows Search:Status:$($stat)" ; 
    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    if ($stat -eq 'Running') {
        $smsg = "$((get-date).ToString('HH:mm:ss')):STOPPING WSEARCH SVC" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        stop-Service -Name wsearch ; 
    } else { 
        write-verbose "$((get-date).ToString('HH:mm:ss')):(wsearch is *not* running)" ; 
    } ; 
    write-verbose "$((get-date).ToString('HH:mm:ss')):(waiting 5secs to close)" ; 
    #start-sleep -s 5 ; 
}

#*------^ stop-driveburn.ps1 ^------


#*------v test-FileSysAutomaticVariables.ps1 v------
function test-FileSysAutomaticVariables {
    <#
    .SYNOPSIS
    test-FileSysAutomaticVariables.ps1 - Simply echos a report on current values within key Filesystem/Script/Function-related AutomaticVariables (Useful for determinging the extent to which you can depend on and *leverage* a given AVari, under a given specific OS/Host). 
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2022-
    FileName    : test-FileSysAutomaticVariables.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell
    REVISIONS
    * 10:13 AM 7/28/2022 init
    .DESCRIPTION
    test-FileSysAutomaticVariables.ps1 - Simply echos a report on current values within key Filesystem/Script/Function-related AutomaticVariables (Useful for determinging the extent to which you can depend on and *leverage* a given AVari, under a given specific OS/Host). 
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    None. Returns no objects or output (.NET types)    
    .EXAMPLE
    PS> .\test-FileSysAutomaticVariablesPS1.ps1
    # psv2 ISE output from .ps1:
        :==(20220729-0525AM)=Computername:SERVERNAME:PS1-CHECK
        $host.version:	2.0
        $IsCoreCLR:
        $IsLinux:
        $IsMacOS:
        $IsWindows:
        $PSCmdlet.MyInvocation.MyCommand.Name:decommission-Ex10Server.ps1
        $PSScriptRoot:	
        $PSCommandPath:	
        (&{$myInvocation}).ScriptName):	C:\scripts\decommission-Ex10Server.ps1
        $MyInvocation.InvocationName:	.\decommission-Ex10Server.ps1
        $MyInvocation.PSScriptRoot (populated when called fr a script & is *caller*):

        $MyInvocation.PSCommandPath (populated when called fr a script & is *caller*):

        --Legacy Path resolutions:
        $ScriptDir (fr $MyInvocation):	C:\scripts\
        $ScriptBaseName (fr &{System.Management.Automation.InvocationInfo}).ScriptName):	decommission-Ex10Server.ps1
        $ScriptNameNoExt (fr $MyInvocation.InvocationName):	decommission-Ex10Server
        $MyInvocation.MyCommand.Path:	C:\scripts
    Example run as a .ps1 script file. 
    .LINK
    https://github.com/tostka/verb-XXX
    #>
    [CmdletBinding()]
    ###[Alias('Alias','Alias2')]
    PARAM() ;
    
    ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;


    Try {
        $ScriptRoot = Get-Variable -Name PSScriptRoot -ValueOnly -ErrorAction Stop
    }Catch{
        $ScriptRoot = Split-Path $script:MyInvocation.MyCommand.Path
    }

    # legacy resolution methods: 
    switch($pscmdlet.myinvocation.mycommand.CommandType){
        'Function' {
            $smsg = "CommandType:Function:Running context does not support populated `$MyInvocation.MyCommand.Definition|Path" ; 
            $smsg += "(interpolating values from other configured sources)" ; 
            write-host $smsg ; 
            $ScriptDir= $ScriptRoot ; 
            $ScriptBaseName = $pscmdlet.myinvocation.mycommand.Name ; 
            $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($pscmdlet.myinvocation.mycommand.Name ) ; 
            $smsg += "`n--Legacy Path resolutions:" ; 
            $slmsg += "`n`$ScriptDir (fr `$PSScriptRoot):`t$($ScriptDir)" ; 
            $slmsg += "`n`$ScriptBaseName (fr `$pscmdlet.myinvocation.mycommand.Name):`t$($ScriptBaseName)" ; 
            $slmsg += "`n`$ScriptNameNoExt (fr `$pscmdlet.myinvocation.mycommand.Name):`t$($ScriptNameNoExt)" ;
        }
        'ExternalScript' {
            $smsg = "CommandType:ExternalScript:.ps1" ; 
            $smsg += "(determining values from legacy sources)" ;
            write-host $smsg ; 
            #$ScriptDir=(Split-Path -parent $MyInvocation.MyCommand.Definition) + "\" ;
            TRY{
                $ScriptDir=((Split-Path -parent $MyInvocation.MyCommand.Definition -ErrorAction STOP) + "\");
                $ScriptBaseName = (Split-Path -Leaf ((&{$myInvocation}).ScriptName))  ; 
                $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ; 

                $smsg += "`n--Legacy Path resolutions:" ; 
                $slmsg += "`n`$ScriptDir (fr `$MyInvocation):`t$($ScriptDir)" ; 
                $slmsg += "`n`$ScriptBaseName (fr &{$myInvocation}).ScriptName):`t$($ScriptBaseName)" ; 
                $slmsg += "`n`$ScriptNameNoExt (fr `$MyInvocation.InvocationName):`t$($ScriptNameNoExt)" ; 
                $slmsg += "`n`$MyInvocation.MyCommand.Path:`t$((Split-Path -parent $MyInvocation.MyCommand.Path))" ; 
            } CATCH {
                $smsg = "Running context does not support populated `$MyInvocation.MyCommand.Definition|Path" ; 
                $smsg += "(interpolating values from other configured sources)" ; 


            } ; 
        }
        default {
            write-warning "Unrecognized `$pscmdlet.myinvocation.mycommand.CommandType:$($pscmdlet.myinvocation.mycommand.CommandType)!" ; 

        } ; 
    } ; 

     # patch in older non-supporting ISE
    if(-not $ScriptDir -AND $psise){
        write-host "Empty `$ScriptDir with ISE:Failing through to $PSISE obj space" ; 
        $ScriptDir = Split-Path $psise.CurrentFile.FullPath ;
        $ScriptBaseName = Split-Path $psise.CurrentFile.FullPath -leaf ; 
        $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($ScriptBaseName ) ; 
    } ; 
            
    <# Quibble with a potentially interesting aside: The closer v2- approximation of 
    $PSScriptRoot is (Split-Path -Parent applied to) $MyInvocation.MyCommand.Path, 
    not $MyInvocation.MyCommand.Definition, though in the top-level scope of a 
    script they behave the same (which is the only sensible place to call from for 
    this purpose). When called inside a function or script block, the former 
    returns the empty string, whereas the latter returns the function body's / 
    script block's definition as a string (a piece of PowerShell source code). �"  
    mklement0
    Sep 4, 2019 at 14:24
    #>
              
    $smsg = "==($(get-date -format 'yyyyMMdd-HHmmtt'))=Computername:$($env:computername):" ; 
    switch($pscmdlet.myinvocation.mycommand.CommandType){
        'Function' {
            $smsg += "FUNCTION-CHECK" ;
        }
        'ExternalScript' {
            $smsg += "PS1-CHECK" ;
        }
        default {
            $smsg += "(UNKNOWN)" ;

        } ; 
    } ; 
    $smsg += "`n`n`$host.version:`t$($host.version)" ; 
    $smsg += "`n`$IsCoreCLR:$($IsCoreCLR)" ; 
    $smsg += "`n`$IsLinux:$($IsLinux)" ; 
    $smsg += "`n`$IsMacOS:$($IsMacOS)" ; 
    $smsg += "`n`$IsWindows:$($IsWindows)" ; 
    $smsg += "`n`$PSCmdlet.MyInvocation.MyCommand.Name:$($PSCmdlet.MyInvocation.MyCommand.Name)" ; 
    #$smsg += "`nSplit-Path -parent $MyInvocation.MyCommand.Definition:$(Split-Path -parent $MyInvocation.MyCommand.Definition)" ;  
    $smsg += "`n`$PSScriptRoot:`t$($PSScriptRoot)" ;
    $smsg += "`n`$PSCommandPath:`t$($PSCommandPath)" ;
    # def dumps back the source code, not much else useful. 
    #$smsg += "`n`$MyInvocation.MyCommand.Definition:`t$($MyInvocation.MyCommand.Definition)" ;
    $smsg += "`n`(&{`$myInvocation}).ScriptName):`t$((&{$myInvocation}).ScriptName)" ;
    $smsg += "`n`$MyInvocation.InvocationName:`t$($MyInvocation.InvocationName)" ;
    $smsg += "`n`$MyInvocation.PSScriptRoot (populated when called fr a script & is *caller*):`n$($MyInvocation.PSScriptRoot)" ; 
    $smsg += "`n`$MyInvocation.PSCommandPath (populated when called fr a script & is *caller*):`n$($MyInvocation.PSCommandPath)" ; 
    $smsg += "`n--Legacy Path resolutions:" ; 
    $smsg += $slmsg ; 

    write-host $smsg ; 
}

#*------^ test-FileSysAutomaticVariables.ps1 ^------


#*------v test-InstalledApplication.ps1 v------
Function test-InstalledApplication {
    <#
    .SYNOPSIS
    test-InstalledApplication.ps1 - Check registry for Installed status of specified application (checks x86 & x64 Uninstall hives, for substring matches on Name)
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 20210415-0913AM
    FileName    : test-InstalledApplication
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell,Application,Install
    REVISIONS
    * 10:37 AM 11/11/2022 ren get-InstalledApplication -> test-InstalledApplication (better match for function, default is test -detailed triggers dump back); aliased orig name; also pulling in overlapping verb-desktop:check-ProgramInstalled(), aliased -Name with ported programNam ; CBH added expl output demo
    * 9:13 AM 4/15/2021 init vers
    .DESCRIPTION
    test-InstalledApplication.ps1 - Check registry for Installed status of specified application (checks x86 & x64 Uninstall hives, for substring matches on Name)
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    Returns either System.Boolean (default) or System.Object (-detail)
    .EXAMPLE
    PS> if(test-InstalledApplication -name "powershell"){"yes"} else { "no"} ; 
    yes
    Default boolean test
    .EXAMPLE    
    PS> get-InstalledApplication -Name 'google drive' -detail
    DisplayName  DisplayVersion InstallLocation                                                      Publisher
    -----------  -------------- ---------------                                                      ---------
    Google Drive 63.0.5.0       C:\Program Files\Google\Drive File Stream\63.0.5.0\GoogleDriveFS.exe Google LLC
    Example returning detail (DisplayName and InstallLocation)
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('check-ProgramInstalled','get-InstalledApplication')]
    PARAM(
        [Parameter(Position=0,HelpMessage="Application Name substring[-Name Powershell]")]
        [Alias('programNam')]
        $Name,
        [Parameter(HelpMessage="Debugging Flag [-Return detailed object on match]")]
        [switch] $Detail
    ) ;
    $x86Hive = Get-ChildItem 'HKLM:Software\Microsoft\Windows\CurrentVersion\Uninstall' |
         % { Get-ItemProperty $_.PsPath } | ?{$_.displayname -like "*$($Name)*"} ;
    write-verbose "`$x86Hive:$([boolean]$x86Hive)" ; 
    if(Test-Path 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall'){
        #$x64Hive = ((Get-ChildItem "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall") |
        #    Where-Object { $_.'Name' -like "*$($Name)*" } ).Length -gt 0;
        $x64Hive = Get-ChildItem 'HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' |
            % { Get-ItemProperty $_.PsPath } | ?{$_.displayname -like "*$($Name)*"} ;
         write-verbose "`$x64Hive:$([boolean]$x64Hive)" ; 
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

#*------^ test-InstalledApplication.ps1 ^------


#*------v test-IsUncPath.ps1 v------
function test-IsUncPath {
    <#
    .SYNOPSIS
    test-IsUncPath.ps1 - Checks specified path is in UNC format
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-04-21
    FileName    : test-IsUncPath.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Filesystem
    REVISIONS
    * 10:28 AM 4/21/2022 init
    .DESCRIPTION
    test-IsUncPath.ps1 - Checks specified path is in UNC format
    .PARAMETER  Path
    Full registPath to be tested [-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending']
    .EXAMPLE
    test-IsUncPath -Path "L:\somepath\file.txt" ;  ; 
    Tests one of the Pending Reboot keys
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [OutputType('bool')]
    [CmdletBinding()]
    PARAM(
        [Parameter(Mandatory,Position=0,ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    ) ;
    BEGIN {
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 
    } ;  
    PROCESS {
        $Error.Clear() ; 
        foreach($item in $path) {
            $PathInfo=[System.Uri]$item ; 
            if($PathInfo.IsUnc){ 
                write-verbose "$Path is UNC Path..." ;
                $true | write-output ;
            } else { 
                write-verbose "$Path is Local Path..." ;
                $false | write-output ;
            } ; 
        } ; 
    } ;  
}

#*------^ test-IsUncPath.ps1 ^------


#*------v test-LineEndings.ps1 v------
function test-LineEndings {
    <#
    .SYNOPSIS
    test-LineEndings.ps1 - Test path/file specified for inconsistent or 'mixed' LineEndings (suppress Pester complaints; general good idea).
    .NOTES
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2022-09-08
    FileName    : test-LineEndings.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : File,LineEndings
    Additional Credits:
    AddedCredit : JasonMArcher (simple native PS EOL detect code)
    AddedWebsite: https://stackoverflow.com/users/64046/jasonmarcher
    AddedTwitter: 
    AddedCredit : phuclv (coerce EOL to CrLf sample code)
    AddedWebsite: https://superuser.com/users/241386/phuclv
    AddedTwitter: 
    REVISIONS   :
    1:20 PM 9/8/2022 expanded CBH examples suppresed noise outputs to w-v, only 
        echos normally are w-w for mixed EOL files; revision to simple JasonMArcher 
        sample: added CBH; swapped echo -> write-host; dumped tee output (declutters), 
        simplified output, built in full function with pipeline path/file looping support.
    * 3/20/22 phuclv pointed out that get-content|set-content autocleans & sample posted in StackEdit response 
    * 4/7/2209 JasonMArcher sample code scrap in stackoverflow response.
    .DESCRIPTION
    test-LineEndings.ps1 - Test path/file specified for inconsistent or 'mixed' LineEndings (suppress Pester complaints; general good idea)

    Examples demo use of get-content|Set-Content to coerce line endings to CrLf 
    underlying mechanism: get-content splits on \n (& drops any existing \r) and set-content always writes \r\n as each EOL (including trailing line of file, if not already set).
    
    Pester has been twigging on mixed/inconsistent EOLs in files. So I wrote this to quickly eval & coerce them into shape (with the fix as a followup cmdblock in the examples).
    
    Examining mixed tagged files, I can see they're turning up as EOL on Example PS> code (other than the last trailing ps line of the block, which has CRLF): likely byproduct of my codeblock -> example conversion script? 
    Yup it was in convertTo-PSHelpExample(), was writing scriptblock EOL as `n, rather than `r`n. Still should check for issue across all files.

    .PARAMETER Path
    Specifies the path or paths to the files that you want to test. To specify multiple paths, and include files in multiple locations, use commas to separate the paths. [-Path c:\path-to\file.ext,c:\pathto\file2.ext]
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    write-warning to console for mixed CrLf (use verbose for echo on all tested files)
    Returns fullname value for each mixed/inconsistent EOL file, to pipeline.
    .EXAMPLE
    PS> $mixedcrlf = test-LineEndings -path 'c:\tmp\20170411-0706AM.ps1','c:\tmp\24SbP1B9.ics' -verbose  ;
    PS> $mixedcrlf | %{
    PS>     write-host "==Fix LineEndings $($_)" ; 
    PS>     $content = Get-Content $_ ; 
    PS>     $content | Set-Content -Path $_ -encoding UTF8 -EA STOP -whatif ; 
    PS> } ; 
    Check array of files for mixed CRLF EOLs. Then run mixed returned, through process to output consistent CrLf lineendings (-remove whatif to execute).
    .EXAMPLE
    PS> $mixedcrlf = test-LineEndings -path 'c:\sc\verb-io\public\' -verbose  ;
    PS> $mixedcrlf | %{
    PS>     write-host "==Fix LineEndings $($_)" ; 
    PS>     $content = Get-Content $_ ; 
    PS>     $content | Set-Content -Path $_ -encoding UTF8 -EA STOP -whatif ; 
    PS> } ; 
    Check a folder path (auto-recursed into files), with followup fix.
    .EXAMPLE
    PS> $mixedcrlf = gci c:\sc\verb-dev\public\*  | select -expand fullname | test-lineendings -verbose ; 
    PS> $mixedcrlf | %{
    PS>     write-host "==Fix LineEndings $($_)" ; 
    PS>     $content = Get-Content $_ ; 
    PS>     $content | Set-Content -Path $_ -encoding UTF8 -EA STOP -whatif ; 
    PS> } ; 
    Pipeline demo with followup fix.
    PS> $mixedcrlf = c:\sc\verb-*\public | select -expand path | test-lineendings -verbose ;
        WARNING: ==>C:\sc\verb-IO\Public\test-LineEndings.ps1:has:MIXED CRLF eolS
    PS> $mixedcrlf |?{$_ -notlike '*-log.txt'} | %{
    PS>     write-host "==Fix LineEndings $($_)" ; 
    PS>     $content = Get-Content $_ ; 
    PS>     $content | Set-Content -Path $_ -encoding UTF8 -EA STOP -whatif ; 
    PS> } ;  
    Demo running against entire module set source Public subdirs, with postfiltered results to exclude logs, and trailing fix
    .LINK
    https://superuser.com/questions/460169/is-there-a-way-to-quickly-identify-files-with-windows-or-unix-line-termination
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    [Alias('Compress-ZipFile')]
    Param(
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True,HelpMessage = "Specifies the path or paths to the files that you want to add to the archive zipped file. To specify multiple paths, and include files in multiple locations, use commas to separate the paths. If a simple folder path is specified, the child files will be recursively checked[-Path c:\path-to\file.ext,c:\pathto\file2.ext]")]
        [ValidateScript( { Test-Path $_ })]
        [Alias('File')]
        [string[]]$Path,
        [Parameter(HelpMessage = "Regular Expression to be used to filter child files when a simple folder path is specified as -Path (defaults to ^\.(TXT|MD|PS1|PSD1|JSON|XML|PSXML|PSM1|CLASS|VBS|CMD|BAT|PY|AHK)$)[-RegexFileExtensions '^\.(TXT|MD|PS1|PSD1|JSON|XML|PSM1|CLASS|VBS|CMD|BAT|PY|AHK)$']")]
        [regex]$RegexFileExtensions = '^\.(TXT|MD|PS1|PSD1|JSON|XML|PSXML|PSM1|CLASS|VBS|CMD|BAT|PY|AHK)$'  
    ) ; 
    BEGIN { 
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "Data received from pipeline input: '$($InputObject)'" ; 
        } else {
            #write-verbose "Data received from parameter input: '$($InputObject)'" ; 
            write-verbose "(non-pipeline - param - input)" ; 
        } ; 
        $bMixedFound = $false 
    } ;  # BEGIN-E
    PROCESS {
        $Error.Clear() ; 
                
        foreach ($item in $Path){
            write-verbose "==$($item):" ; 
            TRY{
                if(test-path $item -pathtype Container){
                    write-host -foregroundcolor green "Container Path specified, recursing and post-filtering for extensions matching regex:`n$($RegexFileExtensions)" ; 
                    $item = get-childitem -recurse -path $item | ?{$_.extension.toUpper() -match $RegexFileExtensions} ; 
                    write-host -foregroundcolor green "(#Matches returned:$(((($item|measure).count)|out-string).trim()))" ; 
                } else {
                    write-verbose "gci non-container obj" ; 
                    $item = gci $item ; 
                }  ; 
                foreach($f in $item){
                    write-verbose "==$($f.fullname):" ; 
                    $content = Get-Content -Raw $f.fullname ; 
                    $newlines = [regex]::Matches($content, "\r?\n") | Group-Object -Property Length ;
                    if ($newlines.Length -eq 2) {
                        $bMixedFound = $true ; 
                        write-WARNING "==>$($f.fullname):has:MIXED CRLF eolS" ; 
                        $f.fullname | write-output ; 
                    } else {
                        if ($newlines[0].Group[0].Value.Length -eq 2) {
                            write-verbose  "==>$($f.fullname):has:CRLF eolS" ; 
                        } else {
                            write-verbose  "==>$($f.fullname):has:LF eolS" ; 
                        } ; 
                    } ; 
                } ; 
            }CATCH{
                Write-Warning -Message $_.Exception.Message ; 
            } ; 
               
        } ;  # loop-E
    }  # if-E PROC
    END{
        if($bMixedFound){
            write-warning "Mixed LineEnd (CR|LF) found within files! Each pathed file has been returned to the pipeline (for post-processing)" ; 
        } ; 
        write-verbose "Processing ended" ; 
    } ; 
}

#*------^ test-LineEndings.ps1 ^------


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
    * 8:43 AM 3/9/2022 fixed consecutive $smsg's wo += to trigger string addition.
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
                            $smsg += "`n(missing general.CompleteName)" ; 
                        }
                        if(-not $mediaMeta.general.OverallBitRate_String){
                            $smsg += "`n(missing general.OverallBitRate_String)" ; 
                        } 
                        if(-not $mediaMeta.general.OverallBitRate_kbps){
                            $smsg += "`n(missing general.OverallBitRate_kbps)" ; 
                        } ; 
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                    } ;
                    if(-not $hasVidProps){
                        $smsg = "-LACKS key video meta props!:" ; 
                        $smsg += "`n$(($mediaMeta.video| fl $propsVidTest|out-string).trim())" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ; 
                        $smsg = $null ; 
                        if(-not $mediameta.video.Format_String ){
                            $smsg += "`n(missing video.Format_String)" ; 
                        }
                        if(-not $mediameta.video.CodecID){
                            $smsg += "`n(missing video.CodecID)" ; 
                        } 
                        if(-not $mediameta.video.Duration_Mins){
                            $smsg += "`n(missing video.Duration_Mins)" ; 
                        } ; 
                        if(-not $mediameta.video.BitRate_kbps){
                            $smsg += "`n(missing video.BitRate_kbps)" ; 
                        } ; 
                        if(-not $mediameta.video.FrameRate_fps){
                            $smsg += "`n(missing video.FrameRate_fps)" ; 
                        } ;   
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;                       
                    } ;
                    if(-not $hasAudioProps){
                        $smsg = "-LACKS key audio meta props!:" ; 
                        $smsg += "`n$(($mediaMeta.audio| fl $propsVidTest|out-string).trim())" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ;
                        $smsg += $null ; 
                        if(-not $mediameta.audio.Format_String ){
                            $smsg += "`n(missing audio.Format_String)" ; 
                        }
                        if(-not $mediameta.audio.CodecID){
                            $smsg += "`n(missing audio.CodecID)" ; 
                        } 
                        if(-not $mediameta.audio.SamplingRate_bit){
                            $smsg += "`n(missing audio.SamplingRate_bit)" ; 
                        } ; 
                        if(-not $mediameta.video.BitRate_kbps){
                            $smsg += "`n(missing video.BitRate_kbps)" ; 
                        } ;                        
                        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                        else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;                      
                    } ;
                    if(-not $hasMbps){
                        $smsg = "-has a VERY LOW MB/SEC spec! ($($mediaMeta.general.FileSize_MB/$mediaMeta.general.Duration_Mins) vs min:$($ThresholdMbPerMin))!:" ; 
                        $smsg += "`nPOTENTIALLY UNDERSIZED/NON-VIDEO FILE!" ; 
                        if(-not$Silent){
                            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                            else{ write-WARNING "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; 
                        } ;
                    } ;
                    if(-not $hasVRes){
                        $smsg = "-is a VERY LOW RES! ($($mediaMeta.video.Height_Pixels) vs min:$($ThreshVRes))!:" ; 
                        $smsg += "`nPOTENTIALLY UNDERSIZED/NON-VIDEO FILE!" ; 
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


#*------v test-MissingMediaSummary.ps1 v------
Function test-MissingMediaSummary {
    <#
    .SYNOPSIS
    test-MissingMediaSummary.ps1 - Checks specified path for supported video files, foreach tests for presence of a like-named -media.xml media summary file, and runs verb-io:test-mediafile for media files missing summaries.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-03-07
    FileName    : test-MissingMediaSummary.ps1
    License     : MIT License
    Copyright   : (c) 2021 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole,Media,Metadata,Video,Audio
    REVISIONS
    * 8:36 PM 1/2/2023 added transcript logging with 4-file rotation (for post-review when running large number of dirs, and they scroll off of ps buffer recording).
    * 10:35 AM 3/14/2022 yanked [hash]Requires -Modules Get-MediaInfo: I don't want to install gmi on servers, at all. So we drop the coverage.
    * 8:34 AM 3/9/2022 set gci to recurse whole tree (span season dirs, save re-run needs); added w-v at a few useful points; expanded some alias use; duped rgx from profile into func.
    * 8:25 PM 3/7/2022init vers
    .DESCRIPTION
    test-MissingMediaSummary.ps1 - Checks specified path for supported video files, foreach tests for presence of a like-named -media.xml media summary file, and runs verb-io:test-mediafile for media files missing summaries.
    .PARAMETER Path
    Path to a media directory of files to be check.[-Path D:\path-to\]
    .OUTPUT
    None. Outputs summary to console. 
    .EXAMPLE
    PS> test-MissingMediaSummary -Path c:\pathto\
    Example scanning the c:\pathto\ dir for missing media summary ([name]-media.xml) files, for each discovered media file
    .EXAMPLE
    PS> vmf c:\pathto\
    Example using 'vmf' alias and default path param
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('vmf')]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="Path to a media file. Can also be passed via pipeline.[-Path D:\path-to\video.ext]")]
        [ValidateScript({Test-Path $_ -PathType 'Container'})]
        #[string[]] $Path,
        [system.io.fileinfo[]]$Path,
        [Parameter(HelpMessage="Suppress all outputs but return pass status as`$true/`$false, to the pipeline[-Silent]")]
        [switch] $Silent
    ) ;
    BEGIN{
        if(-not $rgxVideoExts){$rgxVideoExts = '\.(MPEG|AVI|ASF|WMV|MP4|MOV|3GP|OGM|MKV|WEBM|MXF)' } ;
        #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
        # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        write-verbose "`$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        $Verbose = ($VerbosePreference -eq 'Continue') ; 
        #if ($PSScriptRoot -eq "") {
        if( -not (get-variable -name PSScriptRoot -ea 0) -OR ($PSScriptRoot -eq '')){
            if ($psISE) { $ScriptName = $psISE.CurrentFile.FullPath } 
            elseif($psEditor){
                if ($context = $psEditor.GetEditorContext()) {$ScriptName = $context.CurrentFile.Path } 
            } elseif ($host.version.major -lt 3) {
                $ScriptName = $MyInvocation.MyCommand.Path ;
                $PSScriptRoot = Split-Path $ScriptName -Parent ;
                $PSCommandPath = $ScriptName ;
            } else {
                if ($MyInvocation.MyCommand.Path) {
                    $ScriptName = $MyInvocation.MyCommand.Path ;
                    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent ;
                } else {throw "UNABLE TO POPULATE SCRIPT PATH, EVEN `$MyInvocation IS BLANK!" } ;
            };
            if($ScriptName){
                $ScriptDir = Split-Path -Parent $ScriptName ;
                $ScriptBaseName = split-path -leaf $ScriptName ;
                $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($ScriptName) ;
            } ; 
        } else {
            if($PSScriptRoot){$ScriptDir = $PSScriptRoot ;}
            else{
                write-warning "Unpopulated `$PSScriptRoot!" ; 
                $ScriptDir=(Split-Path -parent $MyInvocation.MyCommand.Definition) + "\" ;
            }
            if ($PSCommandPath) {$ScriptName = $PSCommandPath } 
            else {
                $ScriptName = $myInvocation.ScriptName
                $PSCommandPath = $ScriptName ;
            } ;
            $ScriptBaseName = (Split-Path -Leaf ((& { $myInvocation }).ScriptName))  ;
            $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;
        } ;
        if(!$ScriptDir){
            write-host "Failed `$ScriptDir resolution on PSv$($host.version.major): Falling back to $MyInvocation parsing..." ; 
            $ScriptDir=(Split-Path -parent $MyInvocation.MyCommand.Definition) + "\" ;
            $ScriptBaseName = (Split-Path -Leaf ((&{$myInvocation}).ScriptName))  ; 
            $ScriptNameNoExt = [system.io.path]::GetFilenameWithoutExtension($MyInvocation.InvocationName) ;     
        } else {
            if(-not $PSCommandPath ){
                $PSCommandPath  = $ScriptName ; 
                if($PSCommandPath){ write-host "(Derived missing `$PSCommandPath from `$ScriptName)" ; } ;
            } ; 
            if(-not $PSScriptRoot  ){
                $PSScriptRoot   = $ScriptDir ; 
                if($PSScriptRoot){ write-host "(Derived missing `$PSScriptRoot from `$ScriptDir)" ; } ;
            } ; 
        } ; 
        if(-not ($ScriptDir -AND $ScriptBaseName -AND $ScriptNameNoExt)){ 
            throw "Invalid Invocation. Blank `$ScriptDir/`$ScriptBaseName/`ScriptNameNoExt" ; 
            BREAK ; 
        } ; 

        $smsg = "`$ScriptDir:$($ScriptDir)" ;
        $smsg += "`n`$ScriptBaseName:$($ScriptBaseName)" ;
        $smsg += "`n`$ScriptNameNoExt:$($ScriptNameNoExt)" ;
        $smsg += "`n`$PSScriptRoot:$($PSScriptRoot)" ;
        $smsg += "`n`$PSCommandPath:$($PSCommandPath)" ;  ;
        write-host $smsg ; 

        #region TRANSCRIPTPATH ; #*------v TRANSCRIPT FROM A $PATH VARI v------
        #$transcript = "$($path.directoryname)\logs" ; 
        # simple root of path'd drive x:\scripts\logs transcript on the functionname
        $transcript = "$((split-path $path[0]).split('\')[0])\scripts\logs" ; 
        if(!(test-path -path $transcript)){ write-host "Creating missing log dir $($transcript)..." ; mkdir $transcript -verbose:$true  ; } ;
        #$transcript += "\$($path[0].basename)" ; 
        $transcript += "\$($ScriptNameNoExt)" ; 
        <#$transcript += "-WHATIF-$(get-date -format 'yyyyMMdd-HHmmtt')-trans.txt" ; 
        if(get-variable whatif -ea 0){
            if(-not $whatif){$transcript = $transcript.replace('-WHATIF-','-EXECUTE-')} 
        } ;
        #>
        # rotating series of 4 logs named for the base $transcript
        $transcript += "-transNO.txt" ; 
        $rotation = (get-childitem $transcript.replace('NO','*')) ; 
        if(-not $rotation ){
            write-verbose "Establishing 4 rotating log files ($transcript)..." ; 
            1..4 | %{echo $null > $transcript.replace('NO',"0$($_)") } ; 
            $rotation = (get-childitem $transcript.replace('NO','*')) ;
        } ;
        $transcript = $rotation | sort LastWriteTime | select -first 1 | select -expand fullname ; 
        $logfile = $transcript.replace('-trans','-log') ; 
        #$logging = $true ; 
        #endregion TRANSCRIPTPATH ; #*------^ END TRANSCRIPT FROM A $PATH VARI ^------
        #region STARTTRANS ; #*------v STARTTRANSCRIPT v------
        TRY {
            if($transcript){
                $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
                if($stopResults){
                    $smsg = "Stop-transcript:$($stopResults)" ; 
                    if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
                    else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
                } ; 
                $startResults = start-Transcript -path $transcript ;
                if($startResults){
                    $smsg = "start-transcript:$($startResults)" ; 
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } 
                    else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                } ; 
            } else {
                $smsg = "UNPOPULATED `$transcript! - ABORTING!" ; 
                write-warning $smsg ; 
                throw $smsg ; 
                break ; 
            } ;  
        } CATCH [System.Management.Automation.PSNotSupportedException]{
            if($host.name -eq 'Windows PowerShell ISE Host'){
                $smsg = "This version of $($host.name):$($host.version) does *not* support native (start-)transcription" ; 
            } else { 
                $smsg = "This host does *not* support native (start-)transcription" ; 
            } ; 
            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        } CATCH {
            $ErrTrapd=$Error[0] ;
            $smsg = "Failed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: $($ErrTrapd)" ;
            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        } ;
        #endregion STARTTRANS ; #*------^ END STARTTRANSCRIPT ^------
    }
    PROCESS{
        foreach($p in $Path){
            write-verbose "checking path $($p)\*)" ; 
            $vfiles = get-childitem "$($p)\*" -recurse | ? { $_.extension -match $rgxVideoExts } ;
            $ttl = ($vfiles|measure).count ; $procd = 0; 
             foreach ($vf in $vfiles) {
                $procd++ ; 
               write-host "($($procd)/$($ttl))checking for missing -media.xml for:$($vf.fullname)" ; 
               if (-not (test-path -path (join-path -path $vf.DirectoryName -childpath "$($vf.basename)-media.xml"))) {
                  write-verbose "test-MediaFile -path $($vf.fullname) -Verbose:$($VerbosePreference -eq 'Continue'))" ;
                   test-MediaFile -path "$($vf.fullname)" -Verbose:($VerbosePreference -eq 'Continue') ;  
               } else {
                   write-verbose "(convirmed present:$($vf.basename)-media.xml)"
               };  
           } ;  # loop-E
        }  # loop-E
    }  # PROC-E
    END {
        $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level H1 } #Error|Warn|Debug
        else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
        $stopResults = try {Stop-transcript -ErrorAction stop} catch {} ;
        if($stopResults){
            $smsg = "Stop-transcript:$($stopResults)" ; 
            if($verbose){if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level VERBOSE } 
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ; 
        } ; 
    } ;  # END-E
}

#*------^ test-MissingMediaSummary.ps1 ^------


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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
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
        [Parameter(Mandatory=$true)]
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
                [Parameter(Mandatory=$true)]
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
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                [string]$Key,
                [Parameter(Mandatory=$true)]
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
                [Parameter(Mandatory=$true)]
                [ValidateNotNullOrEmpty()]
                [string]$Key,
                [Parameter(Mandatory=$true)]
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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
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
        [Parameter(Mandatory=$true)]
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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
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
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [string]$Key,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
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
    * 1:35 PM 4/25/2022 psv2 explcit param property =$true; regexpattern w single quotes.
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
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
        [string]$Key,
        [Parameter(Mandatory=$true)][ValidateNotNullOrEmpty()]
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


#*------v write-HostIndent.ps1 v------
function write-HostIndent {
    <#
    .SYNOPSIS
    write-HostIndent - write-host wrapper that adds a stock $env:HostIndentSpaces to the left of each line of text sent (splits lines prior to indenting
    .NOTES
    Version     : 0.0.5
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-01-12
    FileName    : write-HostIndent.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Host,Console,Output,Formatting
    AddedCredit : L5257
    AddedWebsite: https://community.spiceworks.com/people/lburlingame
    AddedTwitter: URL
    REVISIONS
    * 3:07 PM 2/17/2023 splice over -flatten, and other updates from w-l's fixes and workarounds
    * 2:19 PM 2/15/2023 broadly: moved $PSBoundParameters into test (ensure pop'd before trying to assign it into a new object) ; 
        typo fix, removed [ordered] from hashes (psv2 compat); 
    * 3:02 PM 2/2/2023 rolled back overwrite with w-l() code ; updated CBH
    * 2:01 PM 2/1/2023 add: -PID param
    * 2:39 PM 1/31/2023 updated to work with $env:HostIndentSpaces in process scope.
    * 9:50 AM 1/17/2023 All need to be recoded to use evari's, scoped varis aren't consistently discoverable, to have the current 'indent depth' being tweaked by pop|push|reset|set and read by write:
    * 11:50 AM 1/11/2023 ren $indentNum -> $HostIndentSpaces -> $env:HostIndentSpaces
    * 4:15 PM 1/10/2023 ren printIndent -> write-HostIndent ; expanded CBH example, Heart of this is in the example, not the simple write-host loop; 
        added to verb-io.
    * 2:06 PM 1/9/2023 add: CBH, $indentname driving this is is a parent funciton variable, tweak it on the fly to move cursor left or right.
    .DESCRIPTION

    write-HostIndent - write-host wrapper that adds a stock $env:HostIndentSpaces to the left of each line of text sent (splits lines prior to indenting

    Part of the verb-HostIndent set:
    write-HostIndent # write-host wrapper that indents/pads each line of output a fixed amount (driven by $env:HostIndentSpaces common variable). 
    reset-HostIndent # $env:HostIndentSpaces = 0 ; 
    push-HostIndent   # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    pop-HostIndent # $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    set-HostIndent # explicit set to multiples of 4
            
    .PARAMETER BackgroundColor
    Specifies the background color. There is no default. The acceptable values for this parameter are:
    (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)
    .PARAMETER ForegroundColor <System.ConsoleColor>
    Specifies the text color. There is no default. The acceptable values for this parameter are:
    (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)
    .PARAMETER NoNewline <System.Management.Automation.SwitchParameter>
    The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
    the output strings. No newline is added after the last output string.
    .PARAMETER Object <System.Object>
    Objects to display in the host.
    .PARAMETER Separator <System.Object>
    Specifies a separator string to insert between objects displayed by the host.
    .PARAMETER PadChar
    Character to use for padding (defaults to a space).[-PadChar '-']
    .PARAMETER usePID
    Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]
    .PARAMETER Flatten
    Switch to strip empty lines when using -Indent (which auto-splits multiline Objects)[-Flatten]
    .EXAMPLE
    PS> $env:HostIndentSpaces = 4 ; 
    PS> write-HostIndent 'indented message'
    Simple indented text demo
    .EXAMPLE
    PS>  write-verbose 'set to baseline' ; 
    PS>  reset-HostIndent ; 
    PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
    PS>  write-verbose 'write an H1 banner'
    PS>  $sBnr="#*======v  H1 Banner: v======" ;
    PS>  $smsg = $sBnr ;
    PS>  Write-HostIndent -ForegroundColor yellow $smsg ;
    PS>  write-verbose 'push indent level+1' ; 
    PS>  push-HostIndent ; 
    PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
    PS>  $smsg = "This is information (indented)" ; 
    PS>  Write-HostIndent -ForegroundColor Gray $smsg ;
    PS>  write-verbose 'push indent level+2' ; 
    PS>  push-HostIndent ; 
    PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
    PS>  write-verbose 'write a PROMPT entry with -Indent specified' ; 
    PS>  $smsg = "This is a subset of information (indented)" ; 
    PS>  Write-HostIndent -ForegroundColor Gray $smsg ;
    PS>  write-verbose 'pop indent level out one -1' ; 
    PS>  pop-HostIndent ; 
    PS>  write-verbose 'write a Success entry with -Indent specified' ; 
    PS>  $smsg = "This is a Successful information (indented)" ; 
    PS>  PS>  Write-HostIndent -ForegroundColor green $smsg ; ;
    PS>  write-verbose 'reset to baseline for trailing banner'
    PS>  reset-HostIndent ; 
    PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
    PS>  write-verbose 'write the trailing H1 banner'
    PS>  $smsg = "$($sBnr.replace('=v','=^').replace('v=','^='))" ;
    PS>  Write-HostIndent -ForegroundColor yellow $smsg ;
    PS>  write-verbose 'clear indent `$env:HostIndentSpaces' ; 
    PS>  clear-HostIndent ; 
    PS>  write-host "`$env:HostIndentSpaces:$($env:HostIndentSpaces)" ; 
        
        $env:HostIndentSpaces:0
        16:16:17: #  #*======v  H1 Banner: v======
        $env:HostIndentSpaces:4
            16:16:17: INFO:  This is information (indented)
        $env:HostIndentSpaces:8
                16:16:17: PROMPT:  This is a subset of information (indented)
            16:16:17: SUCCESS:  This is a Successful information (indented)
        $env:HostIndentSpaces:0
        16:16:17: #  #*======^  H1 Banner: ^======
        $env:HostIndentSpaces:

    Demo broad process for use of verb-HostIndent funcs and write-log with -indent parameter.
    .EXAMPLE
    PS>  $domain = 'somedomain.com' ; 
    PS>  write-verbose "Top of code, establish 0 Indent" ;
    PS>  $env:HostIndentSpaces = 0 ;
    PS>  #...
    PS>  # indent & do nested thing
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  Write-HostIndent "Spf Version: $($spfElement)" -verbose ;
    PS>  # nested another level
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) + 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: += 4 Net:$($env:HostIndentSpaces)" ;
    PS>  Write-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  # unindent back out
    PS>  $env:HostIndentSpaces = ([int]($env:HostIndentSpaces) - 4) ;
    PS>  write-verbose "`$env:HostIndentSpaces: -= 4: Net:$($env:HostIndentSpaces)" ;
    PS>  Write-HostIndent -ForegroundColor Gray "($Domain)" -verbose ;
                Spf Version:
                    (somedomain.com)
            (somedomain.com)            
    Demo push/popping $env:HostIndentSpaces and using write-hostIndent
    #>
    [CmdletBinding()]
        [Alias('w-hi')]
        PARAM(
            [Parameter(
                HelpMessage="Specifies the background color. There is no default. The acceptable values for this parameter are:
        (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)")]
                [System.ConsoleColor]$BackgroundColor,
            [Parameter(
                HelpMessage="Specifies the text color. There is no default. The acceptable values for this parameter are:
    (Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White)")]
                [System.ConsoleColor]$ForegroundColor,
            [Parameter(
                HelpMessage="The string representations of the input objects are concatenated to form the output. No spaces or newlines are inserted between
    the output strings. No newline is added after the last output string.")]
                [System.Management.Automation.SwitchParameter]$NoNewline,
            [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
                HelpMessage="Objects to display in the host")]
                [System.Object]$Object,
            [Parameter(
                HelpMessage="Specifies a separator string to insert between objects displayed by the host.")]
                [System.Object]$Separator,
            [Parameter(
                HelpMessage="Character to use for padding (defaults to a space).[-PadChar '-']")]
                [string]$PadChar = ' ',
            [Parameter(
                HelpMessage="Number of spaces to pad by default (defaults to 4).[-PadIncrment 8]")]
            [int]$PadIncrment = 4,
            [Parameter(
                HelpMessage="Switch to use the `$PID in the `$env:HostIndentSpaces name (Env:HostIndentSpaces`$PID)[-usePID]")]
                [switch]$usePID,
            [Parameter(
                HelpMessage = "Switch to strip empty lines when using -Indent (which auto-splits multiline Objects)[-Flatten]")]
                #[Alias('flat')]
                [switch] $Flatten
        ) ;
        BEGIN {
        #region CONSTANTS-AND-ENVIRO #*======v CONSTANTS-AND-ENVIRO v======
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        if(($PSBoundParameters.keys).count -ne 0){
            $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
            write-verbose "$($CmdletName): `$PSBoundParameters:`n$(($PSBoundParameters|out-string).trim())" ;
        } ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        #endregion CONSTANTS-AND-ENVIRO #*======^ END CONSTANTS-AND-ENVIRO ^======

        $pltWH = @{} ;
        if ($PSBoundParameters.ContainsKey('BackgroundColor')) {
            $pltWH.add('BackgroundColor',$BackgroundColor) ;
        } ;
        if ($PSBoundParameters.ContainsKey('ForegroundColor')) {
            $pltWH.add('ForegroundColor',$ForegroundColor) ;
        } ;
        if ($PSBoundParameters.ContainsKey('NoNewline')) {
            $pltWH.add('NoNewline',$NoNewline) ;
        } ;
        if ($PSBoundParameters.ContainsKey('Separator')) {
            $pltWH.add('Separator',$Separator) ;
        } ;
        write-verbose "$($CmdletName): Using `$PadChar:`'$($PadChar)`'" ;

        #if we want to tune this to a $PID-specific variant, use:
        if($usePID){
            $smsg = "-usePID specified: `$Env:HostIndentSpaces will be suffixed with this process' `$PID value!" ;
            if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
            $HISName = "Env:HostIndentSpaces$($PID)" ;
        } else {
            $HISName = "Env:HostIndentSpaces" ;
        } ;
        if(($smsg = Get-Item -Path "Env:HostIndentSpaces$($PID)" -erroraction SilentlyContinue).value){
            write-verbose $smsg ;
        } ;
        if (-not ([int]$CurrIndent = (Get-Item -Path $HISName -erroraction SilentlyContinue).Value ) ){
            [int]$CurrIndent = 0 ;
        } ;
        write-verbose "$($CmdletName): Discovered `$$($HISName):$($CurrIndent)" ;

        <# some methods to left pad console output: Most add padding within the obj written by write- host: youend up with a big block of color, if you use fore/back w w-h:

            [Indentation the Write-host output in Powershell - Stack Overflow - stackoverflow.com/](https://stackoverflow.com/questions/70895830/indentation-the-write-host-output-in-powershell)
                    
            $padding = "       "
            'test', 'test', 'test' | ForEach-Object { Write-Host ${padding}$_ }

            $padding = ' ' * 20; $padding + ('test', 'test', 'test' -join "`r`n$padding")

            'test', 'test', 'test' | ForEach-Object { $_.PadLeft(20) }

            'test', 'test', 'test' | ForEach-Object { '{0,10}' -f $_ }
            # OR
            'test', 'test', 'test' | ForEach-Object { [string]::Format('{0,10}', $_) }

            'test', 'test', 'test' | ForEach-Object { $_ -replace '^', (' ' * 20) }

            'test', 'test', 'test' -replace '(?m)^(.{0,20})',{" " * (20 - $_.Length) + $_.Groups[0].Value}

            Trick is, you want to use non-color w-h -nonewline, the number of indent spaces you need
            And then you write-host with colors etc specd.
        #>

        # if $object has multiple lines, split it:
        TRY{
            #$Object = $Object.Split([Environment]::NewLine) ;
            [string[]]$Object = [string[]]$Object.ToString().Split([Environment]::NewLine) ; 
        } CATCH{
            write-verbose "Workaround err: The variable cannot be validated because the value System.String[] is not a valid value for the Object variable." ; 
            [string[]]$Object = ($Object|out-string).trim().Split([Environment]::NewLine) ; 
        } ; 
                
        <# Issue with most above: if you use:
        $padding = "-" * 4 ; # to *see* the spaces
        $whdgy = @{ 'BackgroundColor' = 'Yellow' 'ForegroundColor' = 'DarkGreen' }; 
        $smsg.Split([Environment]::NewLine) | %{write-host -obj ${padding}$_ @whdgy}
        ```
        Output:
        ----Fail on prior TXT qry
        ----Retrying TXT qry:-Name .
        ----Resolve-DnsName -Type TXT -Name 
            you get highlights/color the *entire length of the line*, including the whitespace, padchars
            #>

        # you need to do the w-h -nonewline separately, before using w-h per line of object, with colors:
        <# works, even recog's muiltiline object outputs and splits them at the lines, indenting them cleanly.
        foreach ($obj in $object){
            for ($n=0; $n -lt [int]$env:HostIndentSpaces; $n++) {
		        Write-Host -NoNewline $PadChar ; 
	        } ; 
            write-host @pltWH -object $obj ; 
        } ; 
        #>
        # works, is equiv to the above, just collapses down the silly -nonewline loop
        foreach ($obj in $object){
            Write-Host -NoNewline $($PadChar * $CurrIndent)  ;
            write-host @pltWH -object $obj ;
        } ;
    } ;  # BEG-E
}

#*------^ write-HostIndent.ps1 ^------


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

Export-ModuleMember -Function Add-ContentFixEncoding,Add-PSTitleBar,Authenticate-File,backup-FileTDO,check-FileLock,clear-HostIndent,Close-IfAlreadyRunning,ColorMatch,Compare-ObjectsSideBySide,Compare-ObjectsSideBySide3,Compare-ObjectsSideBySide4,Compress-ArchiveFile,convert-BinaryToDecimalStorageUnits,convert-ColorHexCodeToWindowsMediaColorsName,convert-DehydratedBytesToGB,convert-DehydratedBytesToMB,Convert-FileEncoding,ConvertFrom-CanonicalOU,ConvertFrom-CanonicalUser,ConvertFrom-CmdList,ConvertFrom-DN,ConvertFrom-IniFile,convertFrom-MarkdownTable,ConvertFrom-SourceTable,Null,True,False,_debug-Column,_mask,_slice,_typeName,_errorRecord,ConvertFrom-UncPath,convert-HelpToMarkdown,_encodePartOfHtml,_getCode,_getRemark,Convert-NumbertoWords,_convert-3DigitNumberToWords,ConvertTo-HashIndexed,convertTo-MarkdownTable,convertTo-Object,ConvertTo-SRT,ConvertTo-UncPath,convert-VideoToMp3,copy-Profile,Count-Object,Create-ScheduledTaskLegacy,dump-Shortcuts,Echo-Finish,Echo-ScriptEnd,Echo-Start,Expand-ArchiveFile,extract-Icon,Find-LockedFileProcess,Format-Json,get-AliasDefinition,Get-AverageItems,get-colorcombo,get-ColorNames,get-ConsoleText,Get-CountItems,Get-FileEncoding,Get-FileEncodingExtended,Get-FolderSize,Convert-FileSize,Get-FolderSize2,Get-FsoShortName,Get-FsoShortPath,Get-FsoTypeObj,get-HostIndent,get-LoremName,Get-ProductItems,get-RegistryProperty,Get-ScheduledTaskLegacy,Get-Shortcut,Get-SumItems,get-TaskReport,Get-Time,Get-TimeStamp,get-TimeStampNow,get-Uptime,Invoke-Flasher,Invoke-Pause,Invoke-Pause2,invoke-SoundCue,mount-UnavailableMappedDrives,move-FileOnReboot,New-RandomFilename,new-Shortcut,out-Clipboard,Out-Excel,Out-Excel-Events,parse-PSTitleBar,play-beep,pop-HostIndent,Pop-LocationFirst,prompt-Continue,push-HostIndent,Read-Host2,rebuild-PSTitleBar,Remove-AuthenticodeSignature,Remove-InvalidFileNameChars,Remove-InvalidVariableNameChars,remove-ItemRetry,Remove-JsonComments,Remove-PSTitleBar,Remove-ScheduledTaskLegacy,remove-UnneededFileVariants,repair-FileEncoding,replace-PSTitleBarText,reset-ConsoleColors,reset-HostIndent,restore-FileTDO,Run-ScheduledTaskLegacy,Save-ConsoleOutputToClipBoard,select-first,Select-last,Select-StringAll,set-ConsoleColors,Set-ContentFixEncoding,set-FileAssociation,set-HostIndent,set-ItemReadOnlyTDO,set-PSTitleBar,Set-Shortcut,Shorten-Path,Show-MsgBox,Sign-File,stop-driveburn,test-FileSysAutomaticVariables,test-InstalledApplication,test-IsUncPath,test-LineEndings,test-MediaFile,test-MissingMediaSummary,Test-PendingReboot,Test-RegistryKey,Test-RegistryValue,Test-RegistryValueNotNull,test-PSTitleBar,Test-RegistryKey,Test-RegistryValue,Test-RegistryValueNotNull,Touch-File,trim-FileList,unless,update-RegistryProperty,write-HostIndent,Write-ProgressHelper -Alias *




# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUU0UMj57Cty3FvUbkf2GYPyP+
# TeegggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBS3zCi1
# x+aThi3lQKtLevS4HtSbADANBgkqhkiG9w0BAQEFAASBgFeu5s5nvCT+L/yOrUXQ
# ut1E2RMvShyS54DJlTkMUyVuUG0cbhfT1wbzLBsaZidXlXJwtp4Wzp4wrmrutleP
# iFfX7b6PUPFx6Kg7WeG5Q8PR4d6jk3cE7Urtok9uSXOJ+Uez5n+rbDFU0+3jzHAL
# z+sywp0coZkpyTT1+5OP3OlG
# SIG # End signature block
