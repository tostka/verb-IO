# Convert-TimeIso8601ToTraceDate.ps1

#region CONVERT_TIMEISO8601TOTRACEDATE ; #*------v Convert-TimeIso8601ToTraceDate v------
function Convert-Iso8601ToTraceDate {
    <#
    .SYNOPSIS
    Convert-TimeIso8601ToTraceDate.ps1 - Converts a timestamp to a UTC [DateTime] suitable for Get-MessageTraceV2 -StartDate/-EndDate
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2019-02-06
    License     : MIT License
    Copyright   : (c) 2019 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    AddedCredit : REFERENCE
    AddedWebsite:	URL
    AddedTwitter:	URL
    REVISIONS
    * 10:34 AM 2/12/2026 added Position 0 to InputObject, added Parse-UtcBracketedTimestamp() helper func, to parse non-ISO UTC Bracketed Timestamps (as are returned by SER searches); init
    .DESCRIPTION
    Convert-TimeIso8601ToTraceDate.ps1 - Converts a timestamp to a UTC [DateTime] suitable for Get-MessageTraceV2 -StartDate/-EndDate

    Accepts ISO 8601 strings (with or without offset), [DateTimeOffset], or [DateTime].
    * also has helper function to convert non-ISO UtcBracketedTimestamp, '2026-02-09 09:04:35 [UTC-0600]'

        Preserves offset where present by parsing as [DateTimeOffset], then returns UTC [DateTime].
        Optionally computes a matching EndDate and validates EXO Message Trace limits:
          - Max 10 days per query window
          - Data available only up to ~90 days back


    MessageTraceV2 expects [DateTime] parameters. Providing UTC is safest.
        Microsoft Docs: Get-MessageTraceV2 (UTC output; 10-day window recommendation; 90-day data) and
        Get-MessageTraceDetailV2 (date format notes). 


    .PARAMETER InputObject
        The timestamp to convert. Can be:
          * ISO 8601 string: e.g. '2026-02-09T09:04:35.848870-06:00' or '2026-02-09T15:04:35Z'
          * [DateTimeOffset]
          * [DateTime] (assumed Local/Unspecified — will be treated as Local unless you set -KindUtc)
          * also has helper function to convert non-ISO UtcBracketedTimestamp, '2026-02-09 09:04:35 [UTC-0600]'

        .PARAMETER Duration
        Optional [TimeSpan] to produce an EndDate: StartDate + Duration (default 1 hour).

        .PARAMETER KindUtc
        If InputObject is [DateTime] with Kind=Unspecified, treat it as UTC instead of Local.

    .OUTPUTS
        PSCustomObject with:
          StartDateUtc : [DateTime] (UTC)
          EndDateUtc   : [DateTime] (UTC, if Duration provided)
          Warnings     : string[] (validation notes)

    .EXAMPLE
    PS> $timestamp = Convert-TimeIso8601ToTraceDate -time '2026-02-09 09:04:35 [UTC-0600]' 
    PS> $timestamp

        StartDateUtc        EndDateUtc          Warnings
        ------------        ----------          --------
        2/9/2026 3:04:35 PM 2/9/2026 4:04:35 PM {}    

    Call specifying a non-ISO UtcBracketedTimestamp format string (as is output in primary SER search results)
    .EXAMPLE
    PS> $timestamp = cvd8ser2exo -time '2026-02-09 09:04:35 [UTC-0600]' 
    Alias call
    .LINK
    https://github.com/tostka/verb-io
    #>
    #[Parameter(Mandatory=$false,ValueFromPipeline,ValueFromPipelineByPropertyName,HelpMessage="MGraph Application AppID guid to be resolved")]
    [CmdletBinding()]
    [Alias('Convert-SERDateToEXO','cvD8Ser2Exo')]
    PARAM(    
        [Parameter(Mandatory=$true,Position = 0,ValueFromPipeline,HelpMessage="The timestamp to convert: ISO 8601 string, [DateTimeOffset], or [DateTime] (assumed Local/Unspecified — will be treated as Local unless you set -KindUtc)")]
            [Alias('Time','Timestamp','Date')]
            [object]$InputObject,
        [Parameter(HelpMessage="Optional [TimeSpan] to produce an EndDate: StartDate + Duration (default 1 hour)")]
            [TimeSpan]$Duration = (New-TimeSpan -Hours 1),
        [Parameter(HelpMessage="If InputObject is [DateTime] with Kind=Unspecified, treat it as UTC instead of Local.")]
            [switch]$KindUtc
    )
    BEGIN{    
        #region FUNCTIONS_LOCAL ; #*======v FUNCTIONS_LOCAL v======
        
        #region PARSE_UTCBRACKETEDTIMESTAMP ; #*------v Parse-UtcBracketedTimestamp v------
        function Parse-UtcBracketedTimestamp {
            <#
            .SYNOPSIS
            Parses "yyyy-MM-dd HH:mm:ss[.fffffff] [UTC±HHMM]" into a [DateTimeOffset], plus UTC/Local [DateTime].

            .DESCRIPTION
            Expects a timestamp like:
                2026-02-09 09:04:35 [UTC-0600]
                2026-02-09 09:04:35.848870 [UTC+0100]
            Returns a PSCustomObject with:
                Original       : original string
                DateTimeOffset : parsed [DateTimeOffset] (preserves offset)
                Utc            : [DateTime] UTC
                Local          : [DateTime] local
                Offset         : [TimeSpan] (the declared offset)
            Throws if parsing fails.
            .OUTPUT
            PSCustomObject with:
                Original       : original string
                DateTimeOffset : parsed [DateTimeOffset] (preserves offset)
                Utc            : [DateTime] UTC
                Local          : [DateTime] local
                Offset         : [TimeSpan] (the declared offset)
            Throws if parsing fails.
            .PARAMETER InputString
            The timestamp to convert
            .EXAMPLE
            
            #>
            [CmdletBinding()]
            PARAM(
                [Parameter(Mandatory, ValueFromPipeline,HelpMessage="The timestamp to convert")]
                [string]$InputString
            )
            PROCESS {
                # 1) Regex: capture date/time and the ±HHMM parts
                $m = [regex]::Match(
                    $InputString,
                    '^\s*(?<dt>\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}(?:\.\d{1,7})?)\s*\[\s*UTC(?<sign>[+-])(?<hh>\d{2})(?<mm>\d{2})\s*\]\s*$'
                )

                if (-not $m.Success) {
                    throw "Input doesn't match expected format: 'yyyy-MM-dd HH:mm:ss[.fffffff] [UTC±HHMM]'"
                }

                $dtPart = $m.Groups['dt'].Value
                $sign   = $m.Groups['sign'].Value
                $hh     = $m.Groups['hh'].Value
                $mm     = $m.Groups['mm'].Value

                # 2) Normalize offset to ISO8601 style: ±HH:MM
                $offset = "{0}{1}:{2}" -f $sign, $hh, $mm

                # 3) Compose ISO8601-compatible string and parse
                #    Note: space between date & time is fine as long as we use a matching format string.
                $iso = "$dtPart$offset"

                # Try with fractional seconds, then without
                $dto = $null
                $styles = @(
                    'yyyy-MM-dd HH:mm:ss.fffffffK',
                    'yyyy-MM-dd HH:mm:ssK'
                )
                foreach ($fmt in $styles) {
                    try {
                        $dto = [datetimeoffset]::ParseExact($iso, $fmt, $null)
                        break
                    } catch { }
                }
                if (-not $dto) {
                    throw "Unable to parse normalized ISO timestamp: $iso"
                }

                [pscustomobject]@{
                    Original       = $InputString
                    DateTimeOffset = $dto
                    Utc            = $dto.UtcDateTime
                    Local          = $dto.LocalDateTime
                    Offset         = $dto.Offset
                }
            }  # PROC-E
        } ; 
        #endregion PARSE_UTCBRACKETEDTIMESTAMP ; #*------^ END Parse-UtcBracketedTimestamp ^------

        #endregion FUNCTIONS_LOCAL ; #*======^ END FUNCTIONS_LOCAL  ^======

        $rgxUTCOffsetTimeFormat = '\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}\s\[UTC[+-]\d{4}]' ; 
        $warnings = New-Object System.Collections.Generic.List[string] ; 
        $nowUtc = [DateTime]::UtcNow ; 
    }  # BEG-E
    PROCESS {
        if($InputObject -match $rgxUTCOffsetTimeFormat){
            write-verbose "UtcBracketedTimestamp (SER track) format detected, converting to proper ISO.DateTimeOffset..." ; 
            $InputObject = (Parse-UtcBracketedTimestamp -InputString $InputObject).DateTimeOffset ;  
        } ; 
        # Normalize into DateTimeOffset first (preserves any explicit offset from strings)
        $dto = $null
        switch ($InputObject.GetType().FullName) {
            'System.DateTimeOffset' {
                $dto = [DateTimeOffset]$InputObject
            }
            'System.DateTime' {
                $dt = [DateTime]$InputObject
                if ($dt.Kind -eq [DateTimeKind]::Utc -or $KindUtc) {
                    $dto = [DateTimeOffset]::new($dt, [TimeSpan]::Zero)
                } elseif ($dt.Kind -eq [DateTimeKind]::Local) {
                    $dto = [DateTimeOffset]::new($dt)
                } else {
                    # Unspecified -> assume Local unless -KindUtc was provided
                    if ($KindUtc) {
                        $dto = [DateTimeOffset]::new([DateTime]::SpecifyKind($dt, [DateTimeKind]::Utc), [TimeSpan]::Zero)
                    } else {
                        $local = [DateTime]::SpecifyKind($dt, [DateTimeKind]::Local)
                        $dto = [DateTimeOffset]::new($local)
                        $warnings.Add("Input DateTime.Kind was Unspecified; treated as Local.")
                    }
                }
            }
            default {
                # Treat as string -> parse as DateTimeOffset to honor offsets in ISO 8601
                $s = [string]$InputObject
                try {
                    # Prefer strict ISO 8601 if possible, fall back to flexible parse
                    try {
                        $dto = [DateTimeOffset]::ParseExact($s, 'o', $null) # round-trip "o"
                    } catch {
                        $dto = [DateTimeOffset]::Parse($s)
                    }
                } catch {
                    throw "Unable to parse input '$s' as a timestamp."
                }
            }
        }
        # Produce UTC DateTime(s)
        $startUtc = $dto.UtcDateTime
        $endUtc = $startUtc.Add($Duration)
        # Validate 10-day per-query guidance
        if (($endUtc - $startUtc).TotalDays -gt 10.0) {
            $warnings.Add("The requested window exceeds 10 days. Get-MessageTraceV2 only returns up to 10 days per query; narrow the range or split queries.")
        }
        # Validate ~90-day retention (best-effort warning)
        if (($nowUtc - $startUtc).TotalDays -gt 90.0) {
            $warnings.Add("StartDate is older than ~90 days; Message Trace data likely unavailable.")
        }
        [pscustomobject]@{
            StartDateUtc = $startUtc
            EndDateUtc   = $endUtc
            Warnings     = $warnings.ToArray()
        }
    } # PROC-E
}
#endregion CONVERT_TIMEISO8601TOTRACEDATE ; #*------^ END Convert-TimeIso8601ToTraceDate ^------