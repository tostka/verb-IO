#*------v Function new-Shortcut v------
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
    PS C:\> New-Shortcut -TargetPath "C:\Tools and Utilities\Registry Workshop\RegWorkshop64.exe" -OutputDirectory "$HOME\Desktop" -Name "Registry Workshop" -Description "An advanced registry editor." -Elevated
    PS C:\> New-Shortcut -TargetPath "C:\Tools and Utilities\Notepad++\notepad++.exe" -HotKey Ctrl+Alt+N
    PS C:\> "D:\Imaging Tools\Deployment\imagex.exe | New-Shortcut
    New-Shortcut -TargetPath 'C:\usr\local\bin\Admin-W10Home-TINSTOY-1280x768-TSK.RDP' -OutputDirectory "$HOME\Desktop" -Name "Tinstoy-RDP" -Description "RDP to Tinstoy." -Elevated -verbose #-whatif ;
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
#*------^ END Function new-Shortcut ^------