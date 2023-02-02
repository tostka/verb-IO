# set-FileAssociation.ps1

#*------v Function set-FileAssociation v------
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
    [Alias('fix-encoding')]
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
   

    
    
} ; 
#*------^ END Function set-FileAssociation ^------
