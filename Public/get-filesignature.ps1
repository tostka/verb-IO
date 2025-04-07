# get-filesignature.ps1

#*------v Function get-filesignature v------
Function get-filesignature {
    <#
    .SYNOPSIS
    get-filesignature.ps1 - Obtains file signature information on file, such as MZ if it's an executable.
    .NOTES
    Version     : 0.0.
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-
    FileName    : get-filesignature.ps1
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell
    AddedCredit : Boe Prox
    AddedWebsite: https://mvp.microsoft.com/en-us/PublicProfile/5000355
    AddedTwitter: @proxb / http://twitter.com/proxb
    REVISIONS
    * 6:19 PM 5/12/2023 added/fixed the bundled CBH
    * 07/25/2018 BP posted rev from article, reflects enhancements from Psv5

    .DESCRIPTION
    get-filesignature.ps1 - Obtains file signature information on file, such as MZ if it's an executable.
    The cmdlet all allows you to view signature information of file which could reveal things like executables with different file extensions.

    > TK: NOTE: get-filesignature simply returns the *existing* Extension, *NOT* a suitable/appropriate one, where the file has the wrong extension assigned 
    >   (have to parse and determine externally, eg. via get-FileType's output).

    Original Weekend Scripter function links broken 
    [Weekend Scripter: Use PowerShell to Investigate File Signatures—Part 2 - Scripting Blog](https://devblogs.microsoft.com/scripting/weekend-scripter-use-powershell-to-investigate-file-signaturespart-2/)

    Found 2018-era mcpmag post with the function: 
    [Investigating File Signatures Using PowerShell -- Microsoft Certified Professional Magazine Online](https://mcpmag.com/articles/2018/07/25/file-signatures-using-powershell.aspx)

    .PARAMETER Path
    Enter one or more file paths.
    .INPUTS
    None. Does not accepted piped input.(.NET types, can add description)
    .OUTPUTS
    System.Object
    Returns three properties of the file:
    HexSignature
    ASCIISignature
    Extension (*Current* Extension assigned to file)
    .EXAMPLE
    PS> .\get-filesignature.ps1 -whatif -verbose
    EXSAMPLEOUTPUT
    Run with whatif & verbose
    .EXAMPLE
    PS> Get-FileSignature -Path C:\Windows\System32\cmd.exe

        Name           : cmd.exe
        FullName       : C:\Windows\System32\cmd.exe
        HexSignature   : 4D5A
        ASCIISignature : MZ
        Length         : 273920
        Extension      : exe

    The above examples shows how to view the basic signature of a file and it's output.
    .LINK
    https://github.com/tostka/verb-IO
    .LINK
    https://bitbucket.org/tostka/powershell/
    .LINK
    [Investigating File Signatures Using PowerShell -- Microsoft Certified Professional Magazine Online](https://mcpmag.com/articles/2018/07/25/file-signatures-using-powershell.aspx)
    #>
    [CmdletBinding()]
    PARAM(
        [Parameter(Position=0,Mandatory=$true, ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$True)]
            [Alias("PSPath","FullName")]
            [string[]]$Path,
        [Parameter()]
            [Alias('Filter')]
            [string]$HexFilter = "*",
        [Parameter()]
            [int]$ByteLimit = 2,
        [Parameter()]
            [Alias('OffSet')]
            [int]$ByteOffset = 0
    )
    BEGIN {
        #Determine how many bytes to return if using the $ByteOffset
        $TotalBytes = $ByteLimit + $ByteOffset

        #Clean up filter so we can perform a regex match
        #Also remove any spaces so we can make it easier to match
        [regex]$pattern = ($HexFilter -replace '\*','.*') -replace '\s',''
    }
    PROCESS {  
        ForEach ($item in $Path) { 
            TRY {                     
                $item = Get-Item -LiteralPath (Convert-Path $item) -Force -ErrorAction Stop
            } CATCH {
                Write-Warning "$($item): $($_.Exception.Message)"
                Return
            }
            If (Test-Path -Path $item -Type Container) {
                Write-Warning ("Cannot find signature on directory: {0}" -f $item)
            } Else {
                TRY {
                    If ($Item.length -ge $TotalBytes) {
                        #Open a FileStream to the file; this will prevent other actions against file until it closes
                        $filestream = New-Object IO.FileStream($Item, [IO.FileMode]::Open, [IO.FileAccess]::Read)

                        #Determine starting point
                        [void]$filestream.Seek($ByteOffset, [IO.SeekOrigin]::Begin)

                        #Create Byte buffer to read into and then read bytes from starting point to pre-determined stopping point
                        $bytebuffer = New-Object "Byte[]" ($filestream.Length - ($filestream.Length - $ByteLimit))
                        [void]$filestream.Read($bytebuffer, 0, $bytebuffer.Length)

                        #Create string builder objects for hex and ascii display
                        $hexstringBuilder = New-Object Text.StringBuilder
                        $stringBuilder = New-Object Text.StringBuilder

                        #Begin converting bytes
                        For ($i=0;$i -lt $ByteLimit;$i++) {
                            If ($i%2) {
                                [void]$hexstringBuilder.Append(("{0:X}" -f $bytebuffer[$i]).PadLeft(2, "0"))
                            } Else {
                                If ($i -eq 0) {
                                    [void]$hexstringBuilder.Append(("{0:X}" -f $bytebuffer[$i]).PadLeft(2, "0"))
                                } Else {
                                    [void]$hexstringBuilder.Append(" ")
                                    [void]$hexstringBuilder.Append(("{0:X}" -f $bytebuffer[$i]).PadLeft(2, "0"))
                                }        
                            }
                            If ([char]::IsLetterOrDigit($bytebuffer[$i])) {
                                [void]$stringBuilder.Append([char]$bytebuffer[$i])
                            } Else {
                                [void]$stringBuilder.Append(".")
                            }
                        }
                        If (($hexstringBuilder.ToString() -replace '\s','') -match $pattern) {
                            $object = [pscustomobject]@{
                                Name = ($item -replace '.*\\(.*)','$1')
                                FullName = $item
                                HexSignature = $hexstringBuilder.ToString()
                                ASCIISignature = $stringBuilder.ToString()
                                Length = $item.length
                                Extension = $Item.fullname -replace '.*\.(.*)','$1'
                            }
                            $object.pstypenames.insert(0,'System.IO.FileInfo.Signature')
                            Write-Output $object
                        }
                    } ElseIf ($Item.length -eq 0) {
                        Write-Warning ("{0} has no data ({1} bytes)!" -f $item.name,$item.length)
                    } Else {
                        Write-Warning ("{0} size ({1}) is smaller than required total bytes for the tested signature ({2})" -f $item.name,$item.length,$TotalBytes)
                    }
                } CATCH {
                    Write-Warning ("{0}: {1}" -f $item,$_.Exception.Message)
                }

                #Close the file stream so the file is no longer locked by the process
                $FileStream.Close()
            };  # if-E
        }  # loop-E
    } # PROC-E
} ; 
#*------^ END Function get-filesignature ^------