# get-FileType.ps1
#*------v Function Get-FileType v------
function Get-FileType {
    <#
.SYNOPSIS
Get-FileType - Try to get the file type based on it's file signature.
.NOTES
Version     : 0.0.
Author      : Todd Kadrie
Website     : http://www.toddomation.com
Twitter     : @tostka / http://twitter.com/tostka
CreatedDate : 2023-
FileName    : Get-FileType.ps1
License     : (none asserted)
Copyright   : (none asserted)
Github      : https://github.com/tostka/verb-IO
Tags        : Powershell
AddedCredit : gravejester (Øyvind Kallstad)
AddedWebsite: https://gist.github.com/gravejester
AddedTwitter: @okallstad / https://twitter.com/okallstad
REVISIONS
* 6:19 PM 5/12/2023 updated/expanded CBH, extra example demoing parse of returned FileType to provide a 'proper' extension for misnamed files.
* Dec 15, 2014 GJ's posted version
.DESCRIPTION
Get-FileType - Try to get the file type based on it's file signature.

This function uses Get-FileSignature by Boe Prox and a list of
known file signatures to try to find the file type of a given file.

[Get-FileType.ps1 · GitHub](https://gist.github.com/gravejester/803649515c2dd85ab37e)

.PARAMETER Path
Path [-path c:\path-to\]
.INPUTS
None. Does not accepted piped input.(.NET types, can add description)
.OUTPUTS
System.object
Returns a summary of the specified file. 
.EXAMPLE
PS> Get-FileType c:\path\to\file.pdf
Run with whatif & verbose
.EXAMPLE
PS> $dfile = get-childitem -path $Path ; 
PS> $Imagetype = get-FileType -Path $dfile.fullname -verbose:$($VerbosePreference -eq "Continue") ;
PS> $ImagetypeExtension = ([regex]::match($Imagetype.FileType,"\(.*\)").groups[0].captures[0].value.replace('(','').replace(')','').split('/'))[0] ; 
PS> if($dfile.extension -ne ".$($ImagetypeExtension)"){
PS>     $pltRI = @{
PS>         Path = $dfile.fullname ;
PS>         NewName = $dfile.name.replace($dfile.extension,".$($ImagetypeExtension.tolower())") ; 
PS>         ErrorAction = 'STOP'
PS>         verbose = $($VerbosePreference -eq "Continue") ;
PS>     } ; 
PS>     rename-item @pltRI ; 
PS> } ; 
Demo coercing a 'correct' extension for the file type (where files come down misnamed - and get-filesignature simply returns the *existing* extension)
Accommodates multi-extension filetypes by parsing output: split on '/' (between extensions), and always take the first entry in the array.
Ergo: Filetype: 'Archive (ZIP/JAR)' == returns ZIP (vs JAR)
.LINK
https://github.com/tostka/verb-IO
.LINK
https://gallery.technet.microsoft.com/scriptcenter/Get-FileSignature-f5ae19f5
.LINK
https://gist.github.com/gravejester/803649515c2dd85ab37e
.LINK
https://github.com/gravejester
#>
<#
.SYNOPSIS
Try to get the file type based on it's file signature.
.DESCRIPTION

.EXAMPLE
Get-FileType c:\path\to\file.pdf
.LINK
#>
    [CmdletBinding()]
    PARAM (
        # Path to file.
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [string[]] $Path
    )

    BEGIN {
        # description, hex signature, byte offset, byte limit
        $fileSignatures = @(
            @('JPG/JPEG','FFD8FF',0,3),
            @('Portable Network Graphics (PNG)','89504E470D0A1A0A',0,8),
            @('Graphics Interchange Format - GIF87a (GIF)','474946383761',0,6),
            @('Graphics Interchange Format - GIF89a (GIF)','474946383961',0,6),
            @('Icon (ICO)','00000100',0,4),
            @('MPEG-4 (MP4)','000000*66747970',0,8),
            @('MPEG-4 (MP4)','336770',0,3),
            @('Windows/DOS executable file (EXE/COM/DLL/DRV/PIF/OCX/OLB/SCR/CPL ++)','4D5A',0,2),
            @('Archive (RAR)','526172211A0700',0,7),
            @('Archive (RAR)','526172211A070100',0,8),
            @('Adobe Portable Document Format (PDF) / Forms Document file (FDF)','25504446',0,4),
            @('MPEG-1 Audio Layer 3 (MP3)','FFFB',0,2),
            @('MPEG-1 Audio Layer 3 (MP3)','494433',0,3),
            @('ISO9660 CD/DVD image (ISO)','4344303031','0x8001',5),
            @('ISO9660 CD/DVD image (ISO)','4344303031','0x8801',5),
            @('ISO9660 CD/DVD image (ISO)','4344303031','0x9001',5),
            @('Install Shield compressed file (CAB/HDR)','49536328',0,4),
            @('Microsoft cabinet file (CAB) / Powerpoint Packaged Presentation (PPZ) / Microsoft Access Snapshot Viewer file (SNP)','4D534346',0,4),
            @('Microsoft Windows Imaging Format file (WIM)','4D5357494D',0,5),
            @('Rich text format (RTF)','7B5C72746631',0,6),
            @('TrueType font file (TTF)','0001000000',0,5),
            @('Windows shell link (shortcut) file (LNK)','4C00000001140200',0,8),
            @('Windows Help (HLP/GID)','4C4E0200',0,4),
            @('Windows Help (HLP/GID)','3F5F0300',0,4),
            @('Windows Help (HLP)','0000FFFFFFFF',0,6),
            @('Windows Registry (REG/SUD)','52454745444954',0,7),
            @('Windows Registry (REG)','FFFE',0,2),
            @('Archive (ZIP/JAR)','504B0304',0,4),
            @('Microsoft security catalog file (CAT)','30',0,1),
            @('Windows memory dump (DMP)','5041474544554D50',0,8),
            @('Windows 64-bit memory dump (DMP)','5041474544553634',0,8),
            @('Windows minidump (DMP) / Windows heap dump (HDMP)','4D444D5093A7',0,6),
            @('Microsoft Compiled HTML Help (CHM/CHI)','49545346',0,4),
            @('Waveform Audio (WAV)','52494646*57415645',0,12)
        ) ; 

    } # BEG-E
    PROCESS {
        foreach ($filePath in $Path) {
            if (Test-Path $filePath) {
                foreach($signature in $fileSignatures) {
                    if($thisSig = Get-FileSignature -Path $filePath -HexFilter $signature[1] -ByteOffset $signature[2] -ByteLimit $signature[3]) {
                        Write-Output (,([PSCustomObject] [Ordered] @{
                            Path = $filePath
                            FileType = ($signature[0])
                            HexSignature = $thisSig.HexSignature
                            ASCIISignature = $thisSig.ASCIISignature
                            Extension = $thisSig.Extension
                        }))
                    }
                }  ; # loop-E
            } else {
                Write-Warning "$filePath not found!" ; 
            } ; 
        }  ; # loop-E
    } ;# PROC-E
} ; 
#*------^ END Function Get-FileType ^------
