#*------v Function Output-XMLRendered v------
function Output-XMLRendered {
    <#
    .SYNOPSIS
    Output-XMLRendered.ps1 - function to render an XML objectinto rendered XML code.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2023-
    FileName    : 
    License     : MIT License
    Copyright   : (c) 2023 Todd Kadrie
    Github      : https://github.com/tostka/verb-XXX
    Tags        : Powershell
    AddedCredit : samaspin
    AddedWebsite:	https://stackoverflow.com/users/763163/samaspin
    AddedTwitter:	URL
    REVISIONS
    * 7:56 PM 1/14/2025 minor tweaks, added CBH, adv function, pipeline support, removed default [xml] type coercian from declare
    .DESCRIPTION
    Output-XMLRendered.ps1 - function to render an XML objectinto rendered XML code.

    Adapted from samaspin's posted code sample in a stackoverflow discussion::
    [Powershell, output xml to screen - Stack Overflow](https://stackoverflow.com/questions/6142053/powershell-output-xml-to-screen)

    .PARAMETER xml
    XML object or code to be rendered[-xml '<root><so><user name=`"john`">thats me</user><user name=`"jane`">do you like her?</user></so></root>']
    .EXAMPLE
    PS> $xml = [xml]'<root><so><user name="john">thats me</user><user name="jane">do you like her?</user></so></root>' ; 
    PS> Output-XMLRendered $xml ; 
    OPTSAMPLEOUTPUT
    OPTDESCRIPTION
    .LINK
    https://stackoverflow.com/questions/6142053/powershell-output-xml-to-screen
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$True,ValueFromPipeline=$true,HelpMessage="XML object or code to be rendered[-xml '<root><so><user name=`"john`">thats me</user><user name=`"jane`">do you like her?</user></so></root>']")]
        $xml
    )
    PROCESS{
        foreach ($item in $xml){
            switch ($item.gettype().fullname){
                'System.Xml.XmlDocument'{
                    write-verbose "XmlDcument detected" ;                         
                }
                'System.String'{
                    write-verbose "coercing [string] to [xml]" 
                    [xml]$item = $item ; 
                }
                default {
                    throw "unrecognized object type:$($item.gettype().fullname)" ; 
                }
            } ; 
            $StringWriter = New-Object System.IO.StringWriter ;
            $XmlWriter = New-Object System.Xml.XmlTextWriter $StringWriter ;
            $XmlWriter.Formatting = "indented" ;
            #$xml.WriteTo($XmlWriter) ;
            $item.WriteTo($XmlWriter) ;
            $XmlWriter.Flush() ;
            $StringWriter.Flush() ;
            $StringWriter.ToString() | Write-Output ;
        } ; 
    } ; 
} ; 
#*------^ END Function Output-XMLRendered ^------