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
} ; 
#*------^ convert-HelpToMarkdown.ps1 ^------