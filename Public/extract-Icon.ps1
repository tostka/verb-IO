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
