﻿# verb-IO.psm1


<#
.SYNOPSIS
verb-IO - Powershell Input/Output generic functions module
.NOTES
Version     : 1.0.23.0.0
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

#*------v ConvertFrom-SourceTable.ps1 v------
Function ConvertFrom-SourceTable {
  <#
  .SYNOPSIS
  Converts a fixed column table to objects.
  .NOTES
  Version     : 0.3.11
  Author      : iRon
  Website     : http://www.toddomation.com
  Twitter     : 
  CreatedDate : 2020-03-27
  FileName    : ConvertFrom-SourceTable
  License     : https://github.com/iRon7/ConvertFrom-SourceTable/LICENSE.txt
  Copyright   : (Not specified)
  Github      : https://github.com/iRon7/ConvertFrom-SourceTable
  Tags        : Powershell,Conversion,Text
  REVISIONS
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

  $Colors = ConvertFrom-SourceTable '
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
  '

  PS C:\> $Colors | Where {$_.Name -eq "Red"}

  Name    Value RGB
  ----    ----- ---
  Red  16711680 {255, 0, 0}

  .EXAMPLE

  $Employees = ConvertFrom-SourceTable '
  | Department  | Name    | Country |
  | ----------- | ------- | ------- |
  | Sales       | Aerts   | Belgium |
  | Engineering | Bauer   | Germany |
  | Sales       | Cook    | England |
  | Engineering | Duval   | France  |
  | Marketing   | Evans   | England |
  | Engineering | Fischer | Germany |
  '

  .EXAMPLE

  $ChangeLog = ConvertFrom-SourceTable '
  [Version] [DateTime]Date Author      Comments
  --------- -------------- ------      --------
  0.0.10    2018-05-03     Ronald Bode First design
  0.0.20    2018-05-09     Ronald Bode Pester ready version
  0.0.21    2018-05-09     Ronald Bode removed support for String[] types
  0.0.22    2018-05-24     Ronald Bode Better "right aligned" definition
  0.0.23    2018-05-25     Ronald Bode Resolved single column bug
  0.0.24    2018-05-26     Ronald Bode Treating markdown table input as an option
  0.0.25    2018-05-27     Ronald Bode Resolved error due to blank top lines
  '

  .EXAMPLE

  $Files = ConvertFrom-SourceTable -Literal '
  Mode                LastWriteTime         Length Name
  ----                -------------         ------ ----
  d----l       11/16/2018   8:30 PM                Archive
  -a---l        5/22/2018  12:05 PM          (726) Build-Expression.ps1
  -a---l       11/16/2018   7:38 PM           2143 CHANGELOG
  -a---l       11/17/2018  10:42 AM          14728 ConvertFrom-SourceTable.ps1
  -a---l       11/17/2018  11:04 AM          23909 ConvertFrom-SourceTable.Tests.ps1
  -a---l         8/4/2018  11:04 AM         (6237) Import-SourceTable.ps1
  '

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

#*------v convert-ObjectToIndexedHash.ps1 v------
function convert-ObjectToIndexedHash {
    <#
    .SYNOPSIS
    convert-ObjectToIndexedHash - Convert passed in System Object into an indexed hash (faster lookup via $vari['value'] on the indexed value)
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-08-10
    FileName    : convert-ObjectToIndexedHash
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/
    REVISIONS
    * 12:14 PM 8/10/2020 init
    .DESCRIPTION
    convert-ObjectToIndexedHash - Convert passed in System Object into an indexed hash (faster lookup via $vari['value'] on the indexed value)
    .PARAMETER Object
    System Object to be converted into an indexed-hash[-LicensedUsers alias]
    .PARAMETER Key
    Property to be used to 'index' the object[-Key 'PropName']
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object indexed hashtable of updated Object
    .EXAMPLE
    $object = convert-ObjectToIndexedHash -object $object -Key 'property'
    .LINK
    https://github.com/tostka
    #>
    [CmdletBinding()]
    
    PARAM(
        [Parameter(Mandatory=$True,HelpMessage="System Object to be converted into an indexed-hash[-LicensedUsers alias]")]
        $Object,
        [Parameter(Mandatory=$True,HelpMessage="Property to be used to 'index' the object[-Key 'PropName']")]
        $Key
    ) ;
    BEGIN {
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        # Get parameters this function was invoked with
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        $smsg = "Indexing $(($Object|measure).count) items in passed object on key:$($key)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ;
    PROCESS {
        $Hashtable = @{} ; 
        Foreach ($Item in $Object){
            $Hashtable[$Item.$Key.ToString()] = $Item ; 
        } ; 
    } ; 
    END{
        $Hashtable | write-output ; 
    } ;
}

#*------^ convert-ObjectToIndexedHash.ps1 ^------

#*------v convertTo-Base64String.ps1 v------
function convertTo-Base64String {
    <#
    .SYNOPSIS
    convertTo-Base64String - Convert specified file to Base64 encoded string and return to pipeline
    .NOTES
    Version     : 1.0.0
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
    $Exs=(get-exchangeserver | ?{(($_.IsMailboxServer) -OR ($_.IsHubTransportServer))} )
    if($Exs){
        copy-Profile -ComputerName $Exs -SourceProfileMachine $SourceProfileMachine -TargetProfile $TargetProfileAcct -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    } else {write-verbose -verbose:$true "$((get-date).ToString('HH:mm:ss')):No Mbx or HT servers found)"} ;
    Copy targetprofile to all Exchange servers (leveraging ExchMgmtShell cmd)
    .EXAMPLE
    if($AdminJumpBox ){
        write-verbose -verbose:$true "$((get-date).ToString('HH:mm:ss')):AdminJumpBox..."
        copy-Profile -ComputerName $AdminJumpBox -SourceProfileMachine $SourceProfileMachine -TargetProfile $TargetProfileAcct -JumpBox -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
    } ; 
    Perform a full 'admin' profile copy into target jumpbox (specifies -JumpBox param)
    .EXAMPLE
    copy-Profile -ComputerName $JumpBox -SourceProfileMachine $SourceProfileMachine -TargetProfile $SvcAcctProf -JumpBox -MinProfile -showDebug:$($showdebug) -whatIf:$($whatif) -verbose:($VerbosePreference -eq "Continue") ;  
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
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    # 3:21 PM 4/17/2020 added cbh
    # 8:51 AM 10/31/2014 ren'd EchoXXX to Echo-XXX
    .DESCRIPTION
    Echo-Finish - Opening Banner with Elapsed Timer (used with Echo-Finish or Echo-ScriptEnd)
    .EXAMPLE
    Echo-Finish ; 
    gci c:\windows\ | out-null ; 
    Echo-Finish ; 
    .LINK
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
    # 8:51 AM 10/31/2014 ren'd EchoXXX to Echo-XXX
    # 11/6/2013
    .DESCRIPTION
    Echo-ScriptEnd - Opening Banner with Elapsed Timer (used with Echo-ScriptEnd or Echo-ScriptEnd)
    .EXAMPLE
    Echo-ScriptEnd ; 
    gci c:\windows\ | out-null ; 
    Echo-ScriptEnd ; 
    .LINK
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
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    # 3:21 PM 4/17/2020 added cbh
    # 8:51 AM 10/31/2014 ren'd EchoXXX to Echo-XXX
    .DESCRIPTION
    Echo-Start - Opening Banner with Elapsed Timer (used with Echo-Finish or Echo-ScriptEnd)
    .EXAMPLE
    Echo-Start ; 
    gci c:\windows\ | out-null ; 
    Echo-Finish ; 
    .LINK
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
    $plt=get-colorcombo 70 ;
    write-host @plt "Combo $($a):$($plt.foregroundcolor):$($plt.backgroundcolor)" ;
    Pull and use get-colorcombo 72 in a write-host ;
    .EXAMPLE
    get-colorcombo -demo ;
    .EXAMPLE
    write-host -foregroundcolor green "$((get-date).ToString('HH:mm:ss')):Pull Random get-colorcombo" ;
    $plt=get-colorcombo -Rand ; write-host  @plt "Combo $($a):$($plt.foregroundcolor):$($plt.backgroundcolor)" ;
    Run a demo
    .LINK
    #>
    Param(
        [Parameter(Position = 0, HelpMessage = "Combo Number (0-73)[-Combo 65]")][int]$Combo,
        [Parameter(HelpMessage = "Returns a random Combo [-Random]")][switch]$Random,
        [Parameter(HelpMessage = "Dumps a table of all combos for review[-Demo]")][switch]$Demo
    )
    if (-not($Demo) -AND -not($Combo) -AND -not($Random)) {
        throw "No -Combo integer specified, no -Random, and no -Demo param. One of these must be specified"
        Exit ;
    } ;
    # psv2 doesn't support ordered
    $colorcombo = @{ } ;
    $schemes = "Black;DarkYellow", "Black;Gray", "Black;Green", "Black;Cyan", "Black;Red", "Black;Yellow", "Black;White", "DarkGreen;Gray", "DarkGreen;Green", "DarkGreen;Cyan", "DarkGreen;Magenta", "DarkGreen;Yellow", "DarkGreen;White", "White;DarkGray", "DarkRed;Gray", "White;Blue", "White;DarkRed", "DarkRed;Green", "DarkRed;Cyan", "DarkRed;Magenta", "DarkRed;Yellow", "DarkRed;White", "DarkYellow;Black", "White;DarkGreen", "DarkYellow;Blue", "DarkYellow;Green", "DarkYellow;Cyan", "DarkYellow;Yellow", "DarkYellow;White", "Gray;Black", "Gray;DarkGreen", "Gray;DarkMagenta", "Gray;Blue", "Gray;White", "DarkGray;Black", "DarkGray;DarkBlue", "DarkGray;Gray", "DarkGray;Blue", "Yellow;DarkGreen", "DarkGray;Green", "DarkGray;Cyan", "DarkGray;Yellow", "DarkGray;White", "Blue;Gray", "Blue;Green", "Blue;Cyan", "Blue;Red", "Blue;Magenta", "Blue;Yellow", "Blue;White", "Green;Black", "Green;DarkBlue", "White;Black", "Green;Blue", "Green;DarkGray", "Yellow;DarkGray", "Yellow;Black", "Cyan;Black", "Yellow;Blue", "Cyan;Blue", "Cyan;Red", "Red;Black", "Red;DarkGreen", "Red;Blue", "Red;Yellow", "Red;White", "Magenta;Black", "Magenta;DarkGreen", "Magenta;Blue", "Magenta;DarkMagenta", "Magenta;Blue", "Magenta;Yellow", "Magenta;White" ;
    $i = 0 ;
    foreach ($scheme in $schemes) {
        $colorcombo["$($i)"] = @{BackgroundColor = $scheme.split(";")[0] ; foregroundcolor = $scheme.split(";")[1] ; } ;
        $i++ ;
    } ;
    if ($Demo) {
        write-verbose -verbose:$true  "-Demo specified: Dumping a table of range from Combo 0 to $($colorcombo.count)" ;
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
        $colorcombo[$Combo] | write-output ;
    } ;
}

#*------^ get-colorcombo.ps1 ^------

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
    #requires -version 2
    BEGIN { $x = 0 }
    PROCESS { $x += $_ }
    END { $x }
}

#*------^ Get-SumItems.ps1 ^------

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
    # vers: 8:43 AM 10/31/2014 - simple timestamp echo
    # stock version
    #Get-DateTime -Format 'yyyy-MM-dd HH:mm:ss'
    # my version
    #(get-date).ToString("HH:mm:ss")
    #Get-DateTime -Format "HH:mm:ss"
    # 2:11 PM 12/3/2014 no such cmd as get-datetime
    Get-Date -Format "HH:mm:ss"
}

#*------^ Get-TimeStamp.ps1 ^------

#*------v get-TimeStampNow.ps1 v------
Function get-TimeStampNow () {
    # 	# ren'd TimeStampNow to get-TimeStampNow
    # vers: 20091002
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

#*------v Move-LockedFile.ps1 v------
function Move-LockedFile {
    <#
    .SYNOPSIS
    Move-LockedFile.ps1 - Move Locked file on next reboot
    .NOTES
    Version     : 1.0.0
    Author      : Lee Holmes
    Website: http://www.leeholmes.com/blog/2009/02/17/moving-and-deleting-really-locked-files-in-powershell/
    Twitter: https://twitter.com/Lee_Holmes
    CreatedDate : 2020-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka
    Tags        : Powershell,FileSystem,File,Move
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    # 11:52 AM 9/2/2015 unscrambled from gmail-mangled unwrapped version
    # 10:13 PM 9/1/2015 updated, added pshelp, and validated params, fixed examples to use FullName
    * 20090217 - Web version
    .DESCRIPTION
    Move Locked file on next reboot.Win32 API that enables this is MoveFileEx. Calling this API with the MOVEFILE_DELAY_UNTIL_REBOOT flag tells Windows to move (or delete) your file at the next boot.
    .PARAMETER path
    Source file path [c:\path-to\file.txt]
    .PARAMETER destination
    Destination path [c:\path-to\destination\]
    .PARAMETER Whatif
    Parameter to run a Test no-change pass[-Whatif switch]
    .EXAMPLE
    gci "W:\archs\pix\20150820-reload-eq\Thumbs.db" -force | % { Move-LockedFile -path $_.FullName -destination (Join-Path c:\tmp ($_.Name + ".Bak")) -whatif }  ;
    .EXAMPLE
    dir C:\Users\leeholm -Filter "NTUser.DAT { 
        * " -force | % { Move-LockedFile $_.FullName (Join-Path c:\temp\txr ($_.Name + ".Bak")) }  ;
    .LINK
    http://www.leeholmes.com/blog/2009/02/17/moving-and-deleting-really-locked-files-in-powershell/
    #>
    Param(
        [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = "Source file path [c:\path-to\file.txt]")]
        [ValidateNotNull()] [string]$path,
        [Parameter(Position = 1, Mandatory = $True, HelpMessage = "Destination path [c:\path-to\destination\]")]
        [ValidateNotNull()] [string]$destination,
        [Parameter(HelpMessage = 'Debug Output Flag [$switch]')]
        [switch] $ShowDebug,
        [Parameter(HelpMessage = 'Whatif Flag [$switch]')]
        [switch] $whatIf
    ) # PARAM BLOCK END
    if ($showDebug) {
        $bDebug = $true
        "`$path:$path";
        "`$destination:$destination";
    } ;
    if ( (test-path $path) ) {
        $path = (Resolve-Path $path).Path ;
        if ( (!(Test-Path $destination -pathType container)) ) {
            $destination = $executionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($destination) ;
            $MOVEFILE_DELAY_UNTIL_REBOOT = 0x00000004 ;
            $memberDefinition = @'
[DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Auto)] public static extern bool MoveFileEx(string lpExistingFileName, string lpNewFileName, int dwFlags);
'@ ;
            if ($whatif) {
                write-host "Whatif`nMoveFileEx($($path), $($destination), `$MOVEFILE_DELAY_UNTIL_REBOOT)"
            }
            else {
                $type = Add-Type -Name MoveFileUtils -MemberDefinition $memberDefinition -PassThru ;
                $bRet = $type::MoveFileEx($path, $destination, $MOVEFILE_DELAY_UNTIL_REBOOT) ;
                "results:`$bRet:$bRet";
            } # if-block end ;
        }
        else {
            write-error "Invalid `$destination:$destination";
        } # if-E ;
    }
    else {
        write-error "Invalid `$path:$path";
    }  # if-E;
}

#*------^ Move-LockedFile.ps1 ^------

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
    * 7:21 AM 9/2/2020 added alias:'Remove-IllegalFileNameChars'
    * 3:32 PM 9/1/2020 added to verb-IO
    * 4/14/14 posted version
    .DESCRIPTION
    Remove-InvalidFileNameChars - Remove OS-specific illegal filename characters from the passed string
    .PARAMETER Name
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.String
    .EXAMPLE
    $Name = Remove-InvalidFileNameChars -name $ofile ; 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    [Alias('Remove-IllegalFileNameChars')]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
        [String]$Name
    )
    $verbose = ($VerbosePreference -eq "Continue") ; 
    $invalidChars = [IO.Path]::GetInvalidFileNameChars() -join ''
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
    * 5/14/2019 posted version
    .DESCRIPTION
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    None. Returns no objects or output.
    .EXAMPLE
    .EXAMPLE
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
        $cert = @(get-childitem cert:\currentuser\my -codesigning)[0]
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
    .EXAMPLE
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

#*------v unless.ps1 v------
function unless {
    <#
    .SYNOPSIS
    unless() - Parameter validation friendly fail msgs func
    .NOTES
    Author: Karl Prosser
    Website:	https://powershell.org/wp/2013/05/21/validatescript-for-beginners/

    REVISIONS   :
    8:32 AM 9/2/2015 reformatted, added help
    20130521 - web version
    .DESCRIPTION
    use the Unless (condition) -fail "message" pattern to provide a human-friendly fail response
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
    # dyn tally # of write-prog instances in curr $MyInvocation
    $script:steps = ([System.Management.Automation.PsParser]::Tokenize((gc "$PSScriptRoot\$($MyInvocation.MyCommand.Name)"), [ref]$null) | where { $_.Type -eq 'Command' -and $_.Content -eq 'Write-ProgressHelper' }).Count ; 
    # splat to hold the static write-progress params
    $pltWPH=@{
        Activity = "BROAD ACTIVITY" ;
        CurrentOperation = "Querying..." ;
    };
    $iStep = 0 ; # counter to be incremented ea write-progress exec
    Write-ProgressHelper @pltWPH -Status 'DOING SOMETHING' -StepNumber ($iStep++) ;
    ## SOME PROCESS HERE
    Write-ProgressHelper @pltWPH -Status 'DOING SOMETHING2' -StepNumber ($iStep++) ;
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

Export-ModuleMember -Function Add-PSTitleBar,Authenticate-File,backup-File,ColorMatch,Convert-FileEncoding,ConvertFrom-SourceTable,Null,True,False,Debug-Column,Mask,Slice,TypeName,ErrorRecord,convert-ObjectToIndexedHash,convertTo-Base64String,copy-Profile,dump-Shortcuts,Echo-Finish,Echo-ScriptEnd,Echo-Start,Expand-ZIPFile,extract-Icon,Find-LockedFileProcess,Get-AverageItems,get-colorcombo,Get-CountItems,Get-FileEncoding,Get-FileEncodingExtended,Get-FolderSize,Convert-FileSize,Get-FolderSize2,Get-FsoShortName,Get-FsoShortPath,Get-FsoTypeObj,Get-ProductItems,get-RegistryProperty,Get-Shortcut,Get-SumItems,Get-Time,Get-TimeStamp,get-TimeStampNow,get-Uptime,Invoke-Flasher,Invoke-Pause,Invoke-Pause2,Move-LockedFile,play-beep,prompt-Continue,Read-Host2,Remove-InvalidFileNameChars,remove-ItemRetry,Remove-PSTitleBar,revert-File,Save-ConsoleOutputToClipBoard,Set-FileContent,Set-Shortcut,Shorten-Path,Show-MsgBox,Sign-File,Touch-File,trim-FileList,unless,update-RegistryProperty,Write-ProgressHelper -Alias *


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5kGohRv6sOQ6Vscn6+xuhAxz
# BR6gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ2OU1g
# uNBdSjXNWxYvnu5R765PTzANBgkqhkiG9w0BAQEFAASBgElERwfYNNtxfKqjFRzJ
# hXuBQuLgw+sKH7Ckw+WU7DCPtEw2GzZFRVq+cD2sPDtLISLJg5CQ43Bs+PvHEGU9
# WxzpJ1EIk4/VDzajQ5hhKhD5IeqZCnKoRWm6tZE8RMfd4sW6psXW8F82/YZ+yguP
# MPcTdccP3KvB0kbYKXw+ZPT2
# SIG # End signature block
