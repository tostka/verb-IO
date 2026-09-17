# import-csvFixEncoding.ps1

#region IMPORT_CSVFIXENCODING ; #*------v Import-CsvFixEncoding v------
function Import-CsvFixEncoding {
	<#
	.SYNOPSIS
	Import-CsvFixEncoding - Wrapper around Import-Csv that coerces -Encoding to 'Unicode'.
	.NOTES
	Version     : 0.1.0
	Author      : Todd Kadrie
	Website     : http://www.toddomation.com
	Twitter     : @tostka / http://twitter.com/tostka
	CreatedDate : 2026-09-16
	FileName    : import-csvFixEncoding.ps1
	License     : MIT License
	Copyright   : (c) 2026 Todd Kadrie
	Github      : https://github.com/tostka/verb-io
	Tags        : Powershell,CSV,Encoding
	REVISIONS
	* 9/16/2026 posh1.0 debut
	.DESCRIPTION
	Import-CsvFixEncoding is a pass-through wrapper for the built-in Import-Csv
	cmdlet. It accepts Import-Csv's standard supported parameters and forwards
	them via $PSBoundParameters, but always forces -Encoding to 'Unicode'
	(overriding any -Encoding value the caller may have passed), to work around
	source files that were exported as UTF-16/Unicode and misread when
	imported with Import-Csv's default encoding detection.
	.PARAMETER Path
	Path to one or more input CSV files (supports wildcards).
	.PARAMETER LiteralPath
	Literal path to one or more input CSV files (no wildcard expansion).
	.PARAMETER Delimiter
	Delimiter that separates the property values in the CSV file.
	.PARAMETER UseCulture
	Use the delimiter for the current culture.
	.PARAMETER Header
	Alternate column headers for the imported CSV.
	.PARAMETER TypeName
	Custom type name to apply to the imported objects.
	.INPUTS
	None
	.OUTPUTS
	System.Management.Automation.PSCustomObject
	.EXAMPLE
	PS> Import-CsvFixEncoding -Path 'C:\data\export.csv'

	Imports export.csv, always reading it as Unicode (UTF-16) regardless of its
	actual byte-order-mark, to correct misdetected encoding.
	.LINK
	https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv
    .LINK
    https://github.com/tostka/verb-io
	#>
	[CmdletBinding()]
	PARAM(
		[Parameter(Position = 0, ValueFromPipeline, ValueFromPipelineByPropertyName, HelpMessage = 'Path to one or more input CSV files (supports wildcards)')]
			[ValidateNotNullOrEmpty()]
			[string[]]$Path,
		[Parameter(ValueFromPipelineByPropertyName, HelpMessage = 'Literal path to one or more input CSV files (no wildcard expansion)')]
			[Alias('PSPath')]
			[ValidateNotNullOrEmpty()]
			[string[]]$LiteralPath,
		[Parameter(Position = 1, HelpMessage = 'Delimiter that separates the property values in the CSV file')]
			[ValidateNotNull()]
			[char]$Delimiter,
		[Parameter(HelpMessage = 'Use the delimiter for the current culture')]
			[switch]$UseCulture,
		[Parameter(HelpMessage = 'Alternate column headers for the imported CSV')]
			[string[]]$Header,
		[Parameter(HelpMessage = 'Custom type name to apply to the imported objects')]
			[string]$TypeName
	)
	PROCESS {
		# Copy caller's bound params (Path/LiteralPath/Delimiter/UseCulture/Header/TypeName/common params),
		# then coerce/force Encoding to Unicode regardless of what (if anything) was supplied.
		$ImportCsvParams = @{} + $PSBoundParameters ;
		$ImportCsvParams['Encoding'] = 'Unicode' ;
		Import-Csv @ImportCsvParams ;
	} ; # PROCESS-END
} ; # Import-CsvFixEncoding
#endregion IMPORT_CSVFIXENCODING ; #*------^ END Import-CsvFixEncoding ^------
