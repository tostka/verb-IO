#*------v convert-ObjectToIndexedHash v------
function convert-ObjectToIndexedHash {
    <#
    .SYNOPSIS
    convert-ObjectToIndexedHash - Convert passed in System Object into an indexed hash (faster lookup via $vari['value'] on the indexed value)
    .NOTES
    Version     : 1.0.0.0
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    CreatedDate : 2020-08-10
    FileName    : convert-ObjectToIndexedHash
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/
    REVISIONS
    * 12:14 PM 8/10/2020 init
    .DESCRIPTION
    convert-ObjectToIndexedHash - Convert passed in System Object into an indexed hash (faster lookup via $vari['value'] on the indexed value)
    .PARAMETER Object
    System Object to be converted into an indexed-hash[-LicensedUsers alias]
    .PARAMETER Key
    Property to be used to 'index' the object[-Key 'PropName']
    .INPUTS
    None. Does not accepted piped input.
    .OUTPUTS
    System.Object indexed hashtable of updated Object
    .EXAMPLE
    $object = convert-ObjectToIndexedHash -object $object -Key 'property'
    .LINK
    https://github.com/tostka
    #>
    [CmdletBinding()]
    
    PARAM(
        [Parameter(Mandatory=$True,HelpMessage="System Object to be converted into an indexed-hash[-LicensedUsers alias]")]
        $Object,
        [Parameter(Mandatory=$True,HelpMessage="Property to be used to 'index' the object[-Key 'PropName']")]
        $Key
    ) ;
    BEGIN {
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        # Get parameters this function was invoked with
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        $Verbose = ($VerbosePreference -eq 'Continue') ;
        $smsg = "Indexing $(($Object|measure).count) items in passed object on key:$($key)" ; 
        if ($logging) { Write-Log -LogContent $smsg -Path $logfile -useHost -Level Info } #Error|Warn|Debug 
        else{ write-verbose "$((get-date).ToString('HH:mm:ss')):$($smsg)" } ;
    } ;
    PROCESS {
        $Hashtable = @{} ; 
        Foreach ($Item in $Object){
            $Hashtable[$Item.$Key.ToString()] = $Item ; 
        } ; 
    } ; 
    END{
        $Hashtable | write-output ; 
    } ;
} ; 
#*------^ convert-ObjectToIndexedHash ^------