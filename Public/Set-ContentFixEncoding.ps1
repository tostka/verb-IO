#*------v Function Set-ContentFixEncoding v------
function Set-ContentFixEncoding {
    <#
    .SYNOPSIS
    Set-ContentFixEncoding - Set-Content variant that auto-coerces the encoding to UTF8 
    .NOTES
    Version     : 1.0.0
    Author: Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2022-05-03
    FileName    : Set-ContentFixEncoding.ps1
    License     : MIT License
    Copyright   : (c) 2022 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell,File,Encoding,Management
    REVISIONS   :
    * 9:25 AM 5/4/2022 add -passthru support, rather than true/false return ; add retry code & $DoRetries, $RetrySleep; alias 'Set-FileContent', retire the other function
    * 11:24 AM 5/3/2022 init
    .PARAMETER Path
    Specifies the path of the item that receives the content.[-Path c:\pathto\script.ps1]
    .PARAMETER Value
    Specifies the new content for the item.[-value $content]
    .PARAMETER Encoding
    Specifies the type of encoding for the target file. The default value is 'UTF8'.[-encoding Unicode]
    .PARAMETER PassThru
    Returns an object that represents the content. By default, this cmdlet does not generate any output [-PassThru]
    .PARAMETER whatIf
    Whatif switch [-whatIf]
    .INPUTS
    Accepts piped input (computername).
    .OUTPUTS
    System.String
    .DESCRIPTION
    Set-ContentFixEncoding - Set-Content variant that auto-coerces the encoding to UTF8 
    .EXAMPLE
    PS> Set-ContentFixEncoding -Path c:\tmp\tmp20220503-1101AM.ps1 -Value 'write-host blah' -verbose ;
    Adds specified value to specified file, (auto-coercing encoding to UTF8)
    .EXAMPLE
    PS> $bRet = Set-ContentFixEncoding -Value $updatedContent -Path $outfile -PassThru -Verbose -whatif:$($whatif) ;
    PS> if (!$bRet) {throw "FAILURE" } ;
    Demo use of -PassThru to return the set Content, for validation
    .LINK
    https://github.com/tostka/verb-io
    #>
    #Requires -Modules verb-Text, verb-logging
    # VALIDATORS: [ValidateNotNull()][ValidateNotNullOrEmpty()][ValidateLength(24,25)][ValidateLength(5)][ValidatePattern("some\sregex\sexpr")][ValidateSet("US","GB","AU")][ValidateScript({Test-Path $_ -PathType 'Container'})][ValidateScript({Test-Path $_})][ValidateRange(21,65)]#positiveInt:[ValidateRange(0,[int]::MaxValue)]#negativeInt:[ValidateRange([int]::MinValue,0)][ValidateCount(1,3)]
    ## [OutputType('bool')] # optional specified output type
    [CmdletBinding()]
    [Alias('Set-FileContent')]
    Param(
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True, HelpMessage = 'Specifies the path of the item that receives the content.[-Path c:\pathto\script.ps1]')]
        [Alias('PsPath','File')]
        [system.io.fileinfo[]]$Path,
        [Parameter(Mandatory = $true,Position = 1, HelpMessage = 'Specifies the new content for the item.[-value $content]')]
        [Alias('text','string')]
        [System.Object[]]$Value,
        [Parameter(HelpMessage = "Specifies the type of encoding for the target file. The default value is 'UTF8'.[-encoding Unicode]")]
        [ValidateSet('Ascii','BigEndianUnicode','BigEndianUTF32','Byte','Default','Oem','String','Unicode','Unknown','UTF7','UTF8','UTF32')]
        [Microsoft.PowerShell.Commands.FileSystemCmdletProviderEncoding]$encoding='UTF8',
        [Parameter(HelpMessage = "Returns an object that represents the content. By default, this cmdlet does not generate any output [-PassThru]")]
        [switch] $PassThru,
        [Parameter(HelpMessage = "Whatif switch [-whatIf]")]
        [switch] $whatIf
    ) ;
    BEGIN {
        $verbose = $($VerbosePreference -eq "Continue") ; 
        if(-not $DoRetries){$DoRetries = 4 } ;
        if(-not $RetrySleep){$RetrySleep = 10 } ; 
    } ;
    PROCESS {
        $Path | ForEach-Object -Process {
            $Item = $_ ; 
            $smsg = "(Set-ContentFixEncoding:$($Item.FullName))" ;
            if($verbose){ if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info }
            else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ; } ;
            # set-content overwrites target file, no need to pretest and attempt to retain, just force to encoding specified
            $pltSetCon = @{ Path=$Item.FullName ; encoding=$encoding ; ErrorAction = 'STOP' ; PassThru = $($PassThru); whatif=$($whatif) ;  } ;
            $Exit = 0 ;
            Do {
                Try{
                    $Returned = Set-Content @pltSetCon -Value $Value ;
                    $Returned | write-output ;
                    $Exit = $Retries ;
                }Catch{
                    #Write-Error -Message $_.Exception.Message ;
                    $ErrTrapd=$Error[0] ;
                    $smsg = "$('*'*5)`nFailed processing $($ErrTrapd.Exception.ItemName). `nError Message: $($ErrTrapd.Exception.Message)`nError Details: `n$(($ErrTrapd|out-string).trim())`n$('-'*5)" ;
                    if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level WARN } #Error|Warn|Debug 
                    else{ write-warning "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
                    #-=-record a STATUSWARN=-=-=-=-=-=-=
                    $statusdelta = ";WARN"; # CHANGE|INCOMPLETE|ERROR|WARN|FAIL ;
                    if(gv passstatus -scope Script -ea 0){$script:PassStatus += $statusdelta } ;
                    if(gv -Name PassStatus_$($tenorg) -scope Script -ea 0){set-Variable -Name PassStatus_$($tenorg) -scope Script -Value ((get-Variable -Name PassStatus_$($tenorg)).value + $statusdelta)} ; 
                    start-sleep -s $RetrySleep ; 
                    Break #Opts: STOP(debug)|EXIT(close)|CONTINUE(move on in loop cycle)|BREAK(exit loop iteration)|THROW $_/'CustomMsg'(end script with Err output)
                } ;
            } Until ($Exit -eq $DoRetries) ;
        } # loop-E
    } # Proc-E
} ;
#*------^ END Function Set-ContentFixEncoding ^------