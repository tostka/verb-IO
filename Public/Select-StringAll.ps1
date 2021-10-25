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
    (Get-ChildItem -File -Filter *.abc -Recurse |
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