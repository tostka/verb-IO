# Remove-InvalidFileNameCharsTDO.ps1


#*----------v Function Remove-InvalidFileNameCharsTDO() v----------
function Remove-InvalidFileNameCharsTDO{
    <#
    .SYNOPSIS
    Remove-InvalidFileNameCharsTDO.ps1 - Removes characters from a string that are not valid in Windows file names.
    .NOTES
    Version     : 1.1.2
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2025-03-01
    FileName    : Remove-InvalidFileNameCharsTDO.ps1
    License     : http://creativecommons.org/licenses/by-sa/4.0/
    Copyright   : 2016 Chris Carter
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,RegularExpression,String,filesystem
    AddedCredit : Chris Carter
    AddedWebsite:	https://gallery.technet.microsoft.com/Remove-Invalid-Characters-39fa17b1
    AddedTwitter:	URL
    REVISIONS
    * 7:15 PM 3/1/2025 spliced in missing -ReplaceBrackets & -dashReplaceChars handling pieces in the unpathed else block (wasn't doing those removals as intended); 
        added -ReplaceBrackets (sub square brackets with parenthesis), and -DashReplaceChars (characters to be replaced with chars specified by the new -DashReplacement character or string); 
        added additional exmpl with pipeline support
    * 10:56 PM 2/13/2025 converted to function, expanded CBH
    * August 8, 2016 v1.5.1  CC posted latest copy
    .DESCRIPTION
    Remove-InvalidFileNameCharsTDO accepts a string and removes characters that are invalid in Windows file names. 

    This is an extension of Chris Carter's original simpler function, extended with support for replacement of brackets (to parenthesis) and configurable additional characters. 

    The -Name parameter can also clean file paths. If the string begins with "\\" or a drive like "C:\", it will then treat the string as a file path and clean the strings between "\". This has the side effect of removing the ability to actually remove the "\" character from strings since it will then be considered a divider.
    
    Use of -RemoveSpace will crush out all space charcters (replace with nothing). 

    Use of the additional -ReplaceBrackets switch will replace square brackets ([]) with matching paranthesis characters. 

    You can optionally use the -DashReplacement parameter to specifify a string array of characters to be replaced with a character/string specified by the new -DashReplaceChars parameter. 

    The resulting cleaned string or path will be returned to the pipeline. 
 
    The Replacement parameter will replace the invalid characters with the specified string. To remove rather than replace the invalid characters, use 
 
    The Name parameter can also clean file paths. If the string begins with "\\" or a drive like "C:\", it will then treat the string as a file path and clean the strings between "\". This has the side effect of removing the ability to actually remove the "\" character from strings since it will then be considered a divider.
    
    .PARAMETER Name
    Array of filenames or fullnames to strip of invalid characters.[-name @('filename.ext','c:\pathto\file.ext')]
    .PARAMETER Replacement
    Specifies the string to use as a replacement for the invalid characters (leave blank to delete without replacement).[-Replacement ' ']
    .PARAMETER RemoveSpace
    Switch to include the space character (U+0020) in the removal process.[-Removespace]
    .PARAMETER ReplaceBrackets
    Switch to replace square brackets with paranthesis characters[-ReplaceBrackets]
    .PARAMETER DashReplaceChars
    Characters to be replaced with the -DashReplacement specification[-DashReplaceChars @('|','~')]
    .PARAMETER DashReplacement
    Character to use for all -DashReplacement characters (defaults to dash '-')[-DashReplacement 'x']
    .INPUTS
    System.String
    Remove-InvalidFileNameCharsTDO accepts System.String objects in the pipeline.
 
    Remove-InvalidFileNameCharsTDO accepts System.String objects in a property Name from objects in the pipeline.
 
    .OUTPUTS
    System.String 
    .EXAMPLE
    PS> Remove-InvalidFileNameCharsTDO -Name "<This /name \is* an :illegal ?filename>.txt"
    Output: This name is an illegal filename.txt
 
    This command will strip the invalid characters from the string and output a clean string.
    .EXAMPLE
    PS> Remove-InvalidFileNameCharsTDO -Name "<This /name \is* an :illegal ?filename>.txt" -RemoveSpace
    Output: Thisnameisanillegalfilename.txt
 
    This command will strip the invalid characters from the string and output a clean string, removing the space character (U+0020) as well.
    .EXAMPLE
    PS> Remove-InvalidFileNameCharsTDO -Name '\\Path/:|?*<\With:*?>\:Illegal /Characters>?*.txt"'
    Output: \\Path\With\Illegal Characters.txt
 
    This command will strip the invalid characters from the path and output a valid path. Note: it would not be able to remove the "\" character.
    .EXAMPLE
    PS> Remove-InvalidFileNameCharsTDO -Name '\\Path/:|?*<\With:*?>\:Illegal /Characters>?*.txt"' -RemoveSpace
    Output: \\Path\With\IllegalCharacters.txt
 
    This command will strip the invalid characters from the path and output a valid path, also removing the space character (U+0020) as well. Note: it would not be able to remove the "\" character.
    .EXAMPLE
    PS> Remove-InvalidFileNameCharsTDO -Name "<This /name \is* an :illegal ?filename>.txt" -Replacement +
    Output: +This +name +is+ an +illegal +filename+.txt
 
    This command will strip the invalid characters from the string, replacing them with a "+", and outputting the result string.
    .EXAMPLE
    PS> Remove-InvalidFileNameCharsTDO -Name "<This /name \is* an :illegal ?filename>.txt" -Replacemet + -RemoveOnly "*", 58, 0x3f
    Output: +This +name +is an illegal filename+.txt
 
    This command will strip the invalid characters from the string, replacing them with a "+", except the "*", the charcter with a decimal value of 58 (:), and the character with a hexidecimal value of 0x3f (?). These will simply be removed, and the resulting string output.
    .EXAMPLE
    PS> $results = Remove-InvalidFileNameCharsTDO  -Name "C:\vidtmp\convert\Westworld\001 - Westworld S4 Official Soundtrack ｜ Main Title Theme - Ramin Djawadi ｜ WaterTower(UL20220815-H9qE9D0TjJo).mp3" -Verbose -ReplaceBrackets ;
    PS> $results ; 

        C:\vidtmp\convert\Westworld\001 - Westworld S4 Official Soundtrack - Main Title Theme - Ramin Djawadi - WaterTower(UL20220815-H9qE9D0TjJo).mp3

    Demo use of -replacebrackets & uses a -Name string with a targeted 
    .EXAMPLE
    PS> $results = "\\jun|/k{$[;:]left" | Remove-InvalidFileNameCharsTDO -Verbose -ReplaceBrackets
    PS> $results ; 

        junk{$(;)left

    .Link
    System.RegEx
    .Link
    about_Join
    .Link
    about_Operators
    .LINK
    https://github.com/tostka/verb-io
    #>
    #Requires -Version 2.0
    #[CmdletBinding(HelpURI='https://gallery.technet.microsoft.com/scriptcenter/Remove-Invalid-Characters-39fa17b1')]
    # defer to updated local CBH
    [CmdletBinding()]
    [Alias('Remove-InvalidFileNameChars')]
    Param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true,
            HelpMessage="Array of filenames or fullnames to strip of invalid characters.[-name @('filename.ext','c:\pathto\file.ext')]")]
            [String[]]$Name,
        [Parameter(Position=1,HelpMessage="Specifies the string to use as a replacement for the invalid characters (leave blank to delete without replacement).[-Replacement ' ']")]
            [String]$Replacement='',
        [Parameter(HelpMessage="Switch to include the space character (U+0020) in the removal process.[-Removespace]")]
            [switch]$RemoveSpace,
        [Parameter(HelpMessage="Switch to replace square brackets with paranthesis characters[-ReplaceBrackets]")]
            [switch]$ReplaceBrackets,
        [Parameter(HelpMessage="Characters to be replaced with the -DashReplacement specification (default includes a pipe-lookalike that doesn't replace properly as part of a regex)[-DashReplaceChars @('|','~')]")]
            [string[]]$DashReplaceChars = @("｜"),
        [Parameter(HelpMessage="Character to use for all -DashReplacement characters (defaults to dash '-')[-DashReplacement 'x']")]
            [string]$DashReplacement='-'
    ) ; 
    BEGIN {
        # dashReplaceChars addresses issues getting pipe-lookalikes purged, that don't come out of the OS list; or even properly match or replace as part of a regex

        #Get an array of invalid characters from the OS
        $arrInvalidChars = [System.IO.Path]::GetInvalidFileNameChars()

        
        #Cast into a string, adding the space character
        $(@($arrInvalidChars);@(' '))  | 
            foreach -begin {[string]$rgxChars = $null } -process {$rgxChars+=$_} ; 
        [regex]$rgxInvalidCharsWithSpace = '[' + [regex]::escape($rgxChars) + ']' ;
        write-verbose "`$rgxInvalidCharsWithSpace: $($rgxInvalidCharsWithSpace.tostring())" ; 

        # cast to string wo space char
        $arrInvalidChars | 
            foreach -begin {[string]$rgxChars = $null } -process {$rgxChars+=$_} ; 
        [regex]$rgxinvalidCharsNoSpace = '[' + [regex]::escape($rgxChars) + ']' ;
        write-verbose "`$rgxinvalidCharsNoSpace: $($rgxinvalidCharsNoSpace.tostring())" ; 

        # build the $dashReplaceChars into a rgx as well
        $dashReplaceChars | 
            foreach -begin {[string]$rgxChars = $null } -process {$rgxChars+=$_} ; 
        [regex]$rgxdashReplaceChars = '[' + [regex]::escape($rgxChars) + ']' ;
        write-verbose "`$rgxdashReplaceChars: $($rgxdashReplaceChars.tostring())" ; 

        #Check that the -Replacement specified does not have invalid characters itself
        if ($RemoveSpace) {
            if ($Replacement -match $rgxInvalidCharsWithSpace) {
                Write-Error "The Replacement string also contains invalid filename characters."; break ; 
            }
        } else {
            if ($Replacement -match $rgxInvalidCharsNoSpace) {
                Write-Error "The Replacement string also contains invalid filename characters."; break ; 
            }
        }

        #*======v FUNCTIONS v======
        #*------v Function Remove-Chars v------
        Function Remove-Chars {
            PARAM(
                [Parameter(Mandatory=$true,Position=0,HelpMessage="String to be processed")]
                    [string]$String,
                [Parameter(Position=0,HelpMessage="Specifies the string to use as a Replacement for the invalid characters.")]
                    [string]$Replacement,
                [Parameter(HelpMessage="The RemoveSpace parameter will include the space character (U+0020) in the removal process.")]
                    [switch]$RemoveSpace
            )
            #Replace the invalid characters with a blank string (removal) or the $Replacement value
            #Perform replacement based on whether spaces are desired or not
            if ($RemoveSpace) {
                [RegEx]::Replace($String, $rgxInvalidCharsWithSpace, $Replacement) | write-output ;
            } else {
                [RegEx]::Replace($String, $rgxInvalidCharsNoSpace, $Replacement) | write-output ;
            }
        } 
        #*------^ END Function Remove-Chars ^------      
        #*======^ END FUNCTIONS  ^======


    } ;  # BEG-E
    PROCESS {
        foreach ($n in $Name) {
            $sBnr3="`n#*~~~~~~v PROCESSING : $($n) v~~~~~~" ; 
            write-verbose $sBnr3; 
            #Check if the string matches a valid path
            if ($n -match '(?<start>^[a-zA-z]:\\|^\\\\)(?<path>(?:[^\\]+\\)+)(?<file>[^\\]+)$') {
                #Split the path into separate directories
                $path = $Matches.path -split '\\'

                #This will remove any empty elements after the split, eg. double slashes "\\"
                $path = $path | Where-Object {$_}
                #Add the filename to the array
                $path += $Matches.file

                #Send each part of the path, except the start, to the removal function
                $cleanPaths = foreach ($p in $path) {
                    write-verbose "`$p: $($p)" ; 
                    $buffer = Remove-Chars -String $p -Replacement $Replacement -RemoveSpace:$($RemoveSpace) ;
                    if($ReplaceBrackets){
                        $buffer = $buffer -replace "\[","(" -replace "\]",")" ; 
                    }; 
                    if($rgxdashReplaceChars){
                        $buffer = $buffer -replace $rgxdashReplaceChars,$dashReplacement ; 
                    }; 
                    $buffer | write-output  ; 
                }
                #Remove any blank elements left after removal.
                $cleanPaths = $cleanPaths | Where-Object {$_}
                write-verbose "`$cleanPaths: $($cleanPaths)" ; 
            
                #Combine the path together again
                $Matches.start + ($cleanPaths -join '\') | write-output ; 
            } else {
                #String is not a path, so send immediately to the removal function
                $buffer = Remove-Chars -String $N -Replacement $Replacement -RemoveSpace:$($RemoveSpace) | write-output ; 
                if($ReplaceBrackets){
                    $buffer = $buffer -replace "\[","(" -replace "\]",")" ; 
                }; 
                if($rgxdashReplaceChars){
                    $buffer = $buffer -replace $rgxdashReplaceChars,$dashReplacement ; 
                }; 
                $buffer | write-output ; 
            } ; 
            write-verbose $sBnr3.replace('~v','~^').replace('v~','^~')
        } ;  # loop-E
    } ;  # PROC-E
} ; 
#*------^ END Function Remove-InvalidFileNameCharsTDO ^------