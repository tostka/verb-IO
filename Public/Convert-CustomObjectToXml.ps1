# Convert-CustomObjectToXml.ps1

#region CONVERT_CUSTOMOBJECTTOXML ; #*------v Convert-CustomObjectToXml v------
Function Convert-CustomObjectToXml {
<#
.SYNOPSIS
Convert-CustomObjectToXml.ps1 - Outputs a human readable simple text XML representation of a simple PS object.
.NOTES
Version     : 0.0.
Author      : Todd Kadrie
Website     : http://www.toddomation.com
Twitter     : @tostka / http://twitter.com/tostka
CreatedDate : 2025-08-01
FileName    : Convert-CustomObjectToXml.ps1
License     : (none asserted)
Copyright   : (none asserted)
Github      : https://github.com/tostka/verb-XXX
Tags        : Powershell
AddedCredit : Nathan Kulas (omrsafetyo)
AddedWebsite: https://github.com/omrsafetyo
AddedTwitter: URL
AddedCredit : Eric Wannemacher
AddedWebsite: https://blog.wannemacher.us/posts/p430/
AddedTwitter: @ericwannemacher / https://twitter.com/ericwannemacher
REVISIONS
* 10:13 PM 8/1/2025 reformatted & updated CBH
* Nov 23, 2017 omrsafetyo's most recent github rev posted rev
* June 2, 2011 ericwannemacher's original article at https://blog.wannemacher.us/posts/p430/
.DESCRIPTION
Convert-CustomObjectToXml.ps1 - Outputs a human readable simple text XML representation of a simple PS object.

Outputs a human readable simple text XML representation of a simple PS object.
 
A PSObject with member types of NoteProperty will be dumped to XML.  Only
nested PSObjects up to the depth specified will be searched. All other
note properties will be ouput using their strings values.
 
The output consists of node with property names and text nodes containing the
property value.

Original Author: http://wannemacher.us/?p=430
Modified to include working with Object arrays, and now outputs XML instead of strings.

.PARAMETER object
The input object to inspect and dump.
.PARAMETER depth
The number of levels deep to dump. Defaults to 1.
.PARAMETER rootEl
The name of the root element in the document. Defaults to "root"
.PARAMETER indentString
The string used to indent each level of XML. Defaults to two spaces.
Set to "" to remove indentation..INPUTS
None. Does not accepted piped input.(.NET types, can add description)
.OUTPUTS
None. Returns no objects or output (.NET types)
System.Boolean
[| get-member the output to see what .NET obj TypeName is returned, to use here]
.EXAMPLE
PS> Convert-CustomObjectToXml -whatif -verbose
EXSAMPLEOUTPUT
Run with whatif & verbose
.LINK
https://github.com/omrsafetyo/PowerShellSnippets/blob/master/Convert-CustomObjectToXml.ps1
.LINK
https://github.com/tostka/verb-IO
#>
	[CmdletBinding()]
	param (
		[PSCustomObject]$object,
		[Int32]$depth = 1,
		[String]$rootEl = "root",
		[String]$indentString = "  ",
		[Int32]$indent = 1,
		[switch]$isRoot = $true,
		[String]$XmlVersion = "1.0",
		[String]$Encoding = "UTF-8"
	)
	BEGIN {
		$sb = [System.Text.StringBuilder]::new()
	}
	
	PROCESS {
		# Output the root element opening tag
		if ($isRoot) {
			[void]$sb.AppendLine(("<{0}>" -f $rootEl))
		}
		
		ForEach ( $item in $object ) {
			# Iterate through all of the note properties in the object.
			foreach ($prop in (Get-Member -InputObject $item -MemberType NoteProperty)) {
				$children = $item.($prop.Name)
				foreach ($child in $children) {
					# Check if the property is an object and we want to dig into it
					if ($child.GetType().Name -eq "PSCustomObject" -and $depth -gt 1) {
						[void]$sb.AppendLine(("{0}<{1}>" -f ($indentString * $indent), $prop.Name))
						Convert-CustomObjectToXml $child -isRoot:$false -indent ($indent + 1) -depth ($depth - 1) -indentString $indentString | ForEach-Object { [void]$sb.AppendLine($_) }
						[void]$sb.AppendLine(("{0}</{1}>" -f ($indentString * $indent), $prop.Name))
					}
					else {
						# output the element or elements in the case of an array
						foreach ($element in $child) {
							[void]$sb.AppendLine(("{0}<{1}>{2}</{1}>" -f ($indentString * $indent), $prop.Name, $element))
						}
					}
				}
			}
		}
	 
		# If this is the root, close the root element and convert it to Xml and output
		if ($isRoot) {
			[void]$sb.AppendLine(("</{0}>" -f $rootEl))
			[xml]$Output = $sb.ToString()
			$xmlDeclaration = $Output.CreateXmlDeclaration($XmlVersion,$Encoding,$null)
			[void]$Output.InsertBefore($xmlDeclaration, $Output.DocumentElement)
			$Output
		}
		else {
			# If this is the not the root, this has been called recursively, output the string
			Write-Output $sb.ToString()
		}
	}
	END {}
}
#endregion CONVERT_CUSTOMOBJECTTOXML ; #*------^ END Convert-CustomObjectToXml ^------