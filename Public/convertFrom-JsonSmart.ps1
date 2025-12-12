# convertFrom-JsonSmart.ps1

#*------v Function convertFrom-JsonSmart v------
function convertFrom-JsonSmart {
    <#
    .SYNOPSIS
    convertFrom-JsonSmart - Wrapper for ConvertFrom-Json, that adds smart import fail recovery (sourced in: PowerShell objects and hashtables are case-insensitive for property names, while the JSON standard allows keys to be case-sensitive)
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2025-12-12
    FileName    : convertFrom-JsonSmart.ps1
    License     : MIT License
    Copyright   : (c) 2025 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,Json,Error
    AddedCredit : 
    AddedWebsite: 
    AddedTwitter: 
    REVISIONS
    * 1:04 PM 12/12/2025 init
    .DESCRIPTION
    convertFrom-JsonSmart - Wrapper for ConvertFrom-Json, that adds smart import fail recovery (sourced in: PowerShell objects and hashtables are case-insensitive for property names, while the JSON standard allows keys to be case-sensitive)

    Aims to address the error "Cannot convert the JSON string because a dictionary that was converted from the string contains the duplicated keys 'value' and 'Value'"

    This occurs because PowerShell objects and hashtables are **case-insensitive** for property names, while the JSON standard allows keys to be case-sensitive. 

    The solution this implements, is modifying the JSON string _before_ conversion: swaps 'value' for 'Value' in the stream, before importing

    And this - shifting to json storage of query outputs - is only necessary because MS's Microsoft.Graph outputs are so heavily nested and broken, that the long-standing export-clixml cmdlet can't properly export functional data. 
    So we shift to json, and it's own issues...
    
    .PARAMETER  InputObject
    Specifies the JSON strings to convert to JSON objects. Enter a variable that contains the string, or type a command or expression that gets the string. You can also pipe a string to `ConvertFrom-Json`.

    The InputObject parameter is required, but its value can be an empty string. When the input object is an empty string, `ConvertFrom-Json` doesn't generate any output. The InputObject value can't be `$null`.
    
    .INPUTS
    System.String Accepts piped input json text data to be converted.
    .OUTPUTS
    System.Object[] converted json data returned to pipeline (or $false, where unable to convert)
    System.Boolean
    [| get-member the output to see what .NET obj TypeName is returned, to use here]
    .EXAMPLE
    PS> $json | ConvertTo-Json  | convertFrom-JsonSmart -Indentation 2
    .EXAMPLE
    PS> $json = Get-Content 'D:\script\test.json' -Encoding UTF8 | ConvertFrom-JsonSmart ; 
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [CmdletBinding(DefaultParameterSetName = 'Prettify')]
    PARAM(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true,HelpMessage="Specifies the JSON strings to convert to JSON objects. Enter a variable that contains the string, or type a command or expression that gets the string. You can also pipe a string to `ConvertFrom-Json`.")]
            [System.String]$InputObject
    ) ;
    BEGIN{
        # broad match
        $rgxDuplicateValueKeys = 'Cannot\sconvert\sthe\sJSON\sstring\sbecause\sa\sdictionary\sthat\swas\sconverted\sfrom\sthe\sstring\scontains\sthe\sduplicated\skeys' ; 
        # capture replacable strings
        $rgxDuplicateValueKeysCapture = "Cannot\sconvert\sthe\sJSON\sstring\sbecause\sa\sdictionary\sthat\swas\sconverted\sfrom\sthe\sstring\scontains\sthe\sduplicated\skeys\s'(?<Value1>\w+)'\sand\s'(?<Value2>\w+)'\." ; 
    }
    PROCESS{
        TRY{
            $InputObject | ConvertFrom-Json -EA stop;
        } CATCH [System.InvalidOperationException] { 
            $ErrTrapd=$Error[0] ;
            if($ErrTrapd.exception -match $rgxDuplicateValueKeys){
                if($ErrTrapd.exception -match $rgxDuplicateValueKeysCapture){
                    if($matches.value1 -AND $matches.value2){
                        $smsg = "Isolated values; attempting to replace: $($matches.value2) -> $($matches.value1)" ; 
                        $smsg += "`n... and re-run ConvertFrom-Json" ;
                        write-host -foregroundcolor yellow $smsg ; 
                        TRY{
                            $find = '"' + $($matches.value2) + '":'
                            $replace = '"' + $($matches.value1) + '":'
                            $smsg = "replace: $($find) -> $($replace)" ; 
                            write-verbose $smsg                             
                            $correctedJson = $InputObject -replace $find,$replace ; 
                            $jsondata = $correctedJson | ConvertFrom-Json -ea STOP ; 
                        } CATCH {
                            $ErrTrapd=$Error[0] ;
                            write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
                            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
                            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
                        } ;
                    } else { 
                        $smsg = "Unable to isolate replaceable values in the returned Error Exception"
                        write-warning $smsg ; 
                        throw $ErrTrapd ; # passthrough to generic below
                    } ; 
                } else { 
                    $smsg = "Unable to -match replaceable values in the returned Error Exception"
                    write-warning $smsg ; 
                    throw $ErrTrapd ; # passthrough to generic below
                } ;
            } else{
                throw $ErrTrapd ; # passthrough to generic below
            }; 
        } CATCH {
            $ErrTrapd=$Error[0] ;
            write-host -foregroundcolor gray "TargetCatch:} CATCH [$($ErrTrapd.Exception.GetType().FullName)] {"  ;
            $smsg = "`n$(($ErrTrapd | fl * -Force|out-string).trim())" ;
            write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" ;
        } ;
    }
    END{
        if($jsondata ){
            return $jsondata ; 
        }else{
            write-verbose "No converted data to return" ; 
            return $false ; 
        }
    }
} ; 
#*------^ END Function convertFrom-JsonSmart ^------
