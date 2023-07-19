#*------v Function search-Excel v------
function search-Excel{
    <#
    .SYNOPSIS
    search-Excel.ps1 - Search excel (xlsx) file(s) for specific string.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2023-06-16
    FileName    : search-Excel.ps1
    License     : MIT License
    Copyright   : (c) 2023 Todd Kadrie
    Github      : https://github.com/tostka/verb-io
    Tags        : Powershell, fileystem, junctionpoint,  symlink,  reparsepoint
    AddedCredit : REFERENCE
    AddedWebsite: URL
    AddedTwitter: URL
    AddedCredit : TheMadTechnician
    AddedWebsite: https://stackoverflow.com/users/3245749/themadtechnician
    AddedTwitter: URL
    REVISIONS
    * 10:59 AM 7/7/2023 added timer; also spliced in additional com-obj removal for subobjects
    * 10:14 AM 7/6/2023 retooled with: excel extension path validation;  added pipeline support ; added CBH ; moved obj open to begin block
    * 8/16/2021 TheMadTechnician's posted looping tweak example
    * 10/1/2019 S Mohammad's posted copy
    .DESCRIPTION
    search-Excel.ps1 - Search excel (xlsx) file(s) for specific string.
    
    Fairly slow tweaked variant of Shuaib Mohammad's excel-search function (stackedit post comment from TheMadTechnician). 
    It's generally much quicker to use desktop search if the target files are being WindowsSearch indexed. Just sayin'
    
    The search text can accept wildcard characters such as * and ?, does substring matches by default.
    
    .PARAMETER Path
    Path [-path c:\path-to\]
    .PARAMETER Text
    Text to be searched[-Text 'word']
    .INPUTS
    Accepts piped input.
    .OUTPUTS
    System.PSCustomObject
    .EXAMPLE
    search-excel -path 'path-to\spreadsheet.xlsx' -Text 'text string' ; 

        WorkSheet : WORKSHEETNAME
        Column    : 43
        Row       : 4
        Text      : [full matching cell contents]
        Address   : '[XXXX.xlsx]WORKSHEETNAME'!AQ4

    Demo running text search
    .EXAMPLE
    $hits = gci c:\usr\work\* -include ('*.xlsx','*.xls') -recurse -ea 0 | search-excel -Text 'Marie.Chinnery@hayter.co.uk' -verbose ; 
    Demo running search for xlsx/xls files, and then running a text search on the retruned spreadsheets 
    .LINK
    https://stackoverflow.com/questions/68808806/powershell-script-to-search-through-a-directory-of-excel-files-to-find-a-string
    .LINK
    https://shuaiber.medium.com/searching-through-excel-files-for-a-string-using-powershell-964db62348ef
    .LINK
    https://github.com/tostka/verb-io
    #>
    [CmdletBinding()]
    #[Alias('xxx')]
    PARAM(
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline = $True, HelpMessage = 'Paths[-path c:\pathto\file.ext or c:\pathto]')]
            [Alias('PsPath')]
            [ValidateScript({
                TRY {
                    If (Test-Path -Path $_ ) {
                        if( [IO.Path]::GetExtension($_) -match '\.(xls|xlsx|xlsm|xlsb)'){$True}
                        else {Throw "$($_) is not a valid Excel file type!"}
                    } Else {Throw "$($_) is not a valid path!"}
                } CATCH {
                    Throw $_ ; 
                }
            })]
            [system.io.fileinfo[]]$Path,
        [Parameter(Mandatory = $true,HelpMessage = "Text to be searched[-Text 'word']")]
            [string]$Text
            #You can specify wildcard characters (*, ?)
    ) ; 
    BEGIN {
        if ($PSCmdlet.MyInvocation.ExpectingInput) {
            write-verbose "(Data received from pipeline input)" ;
        } ;
        write-verbose "Loading ComObject Excel.Application" ; 
        $Excel = New-Object -ComObject Excel.Application ; 
    } ;
    PROCESS {
        foreach($item in $Path) {
            if($VerbosePreference -eq "Continue"){
                $smsg = $sBnrS="Checking: $($item)..." ; 
                write-verbose $smsg ; 
            } else { 
                write-host "." -NoNewLine ; $1F=$true ; 
            } ; 
            $Error.Clear() ; 
            $sw = [Diagnostics.Stopwatch]::StartNew();
            write-verbose "Opening Workbook $($item.fullname)..." ; 
            $Workbook = $Excel.Workbooks.Open($item.fullname) ; 
            ForEach ($Worksheet in @($Workbook.Sheets)) {
               write-verbose "searching workbook" ; 
                $Found = $WorkSheet.Cells.Find($Text) ; 
                If ($Found) {
                    $BeginAddress = $Found.Address(0,0,1,1) ; 
                    #Initial Found Cell
                    [pscustomobject]@{
                        WorkSheet = $Worksheet.Name ; 
                        Column = $Found.Column ; 
                        Row =$Found.Row ; 
                        Text = $Found.Text ; 
                        Address = $BeginAddress ; 
                    } | write-output ;              
                    Do {
                        $Found = $WorkSheet.Cells.FindNext($Found) ; 
                        $Address = $Found.Address(0,0,1,1) ; 
                        If ($Address -eq $BeginAddress) {
                            BREAK ; 
                        } ; 
                        [pscustomobject]@{
                            WorkSheet = $Worksheet.Name
                            Column = $Found.Column ; 
                            Row =$Found.Row ; 
                            Text = $Found.Text ; 
                            Address = $Address ; 
                        } | write-output ;              
                    } Until ($False) ; 
                } Else {
                    write-verbose "[$($WorkSheet.Name)] Nothing Found!" ; 
                } ; 
            } ; 
            write-verbose "Closing workbook" ; 
            $workbook.close($false) ; 
            $sw.Stop() ;
            $smsg =  ("Elapsed Time: {0:dd}d {0:hh}h {0:mm}m {0:ss}s {0:fff}ms" -f $sw.Elapsed) ;
            write-host -foregroundcolor gray "$((get-date).ToString('HH:mm:ss')):$($smsg)" ; 
        } ;  # loop-E
    } ;  # PROC-E
    END {
        write-verbose "Cleaning up COM objects..." ; 
        [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) ;
        [void][System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) ; 
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject([System.__ComObject]$excel) ; 
        [gc]::Collect() ; 
        [gc]::WaitForPendingFinalizers() ; 
        Remove-Variable excel -ErrorAction SilentlyContinue ; 
    } ; 
} ; 
#*------^ END Function search-Excel ^------
