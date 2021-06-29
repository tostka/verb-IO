#*------v Function ConvertFrom-IniFile v------
Function ConvertFrom-IniFile {
    <#
    .Synopsis
    Convert an INI file to an object
    ConvertFrom-IniFile.ps1 - convert a legacy INI file into a PowerShell custom object. Each INI section will become a property name. Then each section setting will become a nested object. Blank lines and comments starting with ; will be ignored.
    .NOTES
    Version     : 1.0.0
    Author      : Todd Kadrie
    Website     : http://www.toddomation.com
    Twitter     : @tostka / http://twitter.com/tostka
    CreatedDate : 2020-
    FileName    : 
    License     : (none asserted)
    Copyright   : (none asserted)
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell
    AddedCredit : Jeff Hicks
    AddedWebsite: https://www.petri.com/managing-ini-files-with-powershell
    AddedTwitter: 
    Learn more about PowerShell:
    http://jdhitsolutions.com/blog/essential-powershell-resources/
    REVISIONS
    * 12:46 PM 6/29/2021 minor vervisions & syntax tightening; expanded CBH; added delimiting to unexpected line dump
    * posted rev 1/29/2015 (June 5, 2015)
    .Description
    Use this command to convert a legacy INI file into a PowerShell custom object. Each INI section will become a property name. Then each section setting will become a nested object. Blank lines and comments starting with ; will be ignored. 
    It is assumed that your ini file follows a typical layout like this:
    ```text
    ;This is a sample ini
    [General]
    Action = Start
    Directory = c:\work
    ID = 123ABC
   ;this is another comment
    [Application]
    Name = foo.exe
    Version = 1.0
    [User]
    Name = Jeff
    Company = Globomantics
    ```
    .PARAMETER Path
    The path to the INI file.
    .INPUTS
    [string]
    .OUTPUTS
    [pscustomobject]
    .EXAMPLE
    PS C:\> $sample = ConvertFrom-IniFile c:\scripts\sample.ini
    PS C:\> $sample
    General                           Application                      User                            
    -------                           -----------                      ----                            
    @{Directory=c:\work; ID=123ABC... @{Version=1.0; Name=foo.exe}     @{Name=Jeff; Company=Globoman...
    PS C:\> $sample.general.action
    Start
    In this example, a sample ini file is converted to an object with each section a separate property.
    .EXAMPLE
    PS C:\> ConvertFrom-IniFile c:\windows\system.ini | export-clixml c:\work\system.ini
    Convert the System.ini file and export results to an XML format.
    .LINK
    Get-Content
    .LINK
    https://github.com/tostka/verb-IO
    #>
    [cmdletbinding()]
    Param(
        [Parameter(Position=0,Mandatory,HelpMessage="Enter the path to an INI file",
        ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias("fullname","pspath")]
        [ValidateScript({
        if (Test-Path $_) {$True}else {Throw "Cannot validate path $_"}
        })]     
        [string]$Path
    )
    Begin {
        # function self-name (equiv to script's: $MyInvocation.MyCommand.Path) ;
        ${CmdletName} = $PSCmdlet.MyInvocation.MyCommand.Name ;
        # Get parameters this function was invoked with
        $PSParameters = New-Object -TypeName PSObject -Property $PSBoundParameters ;
        $Verbose = ($VerbosePreference -eq 'Continue') ; 
        Write-Verbose "Starting $($MyInvocation.Mycommand)" ; 
    } 
    Process {
        Write-Verbose "Getting content from $(Resolve-Path $path)"
        #strip out comments that start with ; and blank lines
        $all = Get-content -Path $path | Where {$_ -notmatch "^(\s+)?;|^\s*$"}
        $obj = New-Object -TypeName PSObject -Property @{}
        $hash = [ordered]@{}
        foreach ($line in $all) {
            Write-Verbose "Processing $line" ; 
            if ($line -match "^\[.*\]$" -AND $hash.count -gt 0) {
                #has a hash count and is the next setting
                #add the section as a property
                write-Verbose "Creating section $section" ; 
                Write-verbose ([pscustomobject]$hash | out-string) ; 
                $obj | Add-Member -MemberType Noteproperty -Name $Section -Value $([pscustomobject]$Hash) -Force ; 
                #reset hash
                Write-Verbose "Resetting hashtable" ; 
                $hash=[ordered]@{} ; 
                #define the next section
                $section = $line -replace "\[|\]","" ; 
                Write-Verbose "Next section $section" ; 
            } elseif ($line -match "^\[.*\]$") {
                #Get section name. This will only run for the first section heading
                $section = $line -replace "\[|\]","" ; 
                Write-Verbose "New section $section"
            } elseif ($line -match "=") {
                #parse data
                $data = $line.split("=").trim() ; 
                $hash.add($data[0],$data[1]) ; 
            } else {
                #this should probably never happen
                Write-Warning "Unexpected line:`n'$($line|out-string)'" ; 
            } ; 
        }  ;  # loop-E
        #get last section
        If ($hash.count -gt 0) {
            Write-Verbose "Creating final section $section" ; 
            Write-Verbose ([pscustomobject]$hash | Out-String) ; 
            #add the section as a property
            $obj | Add-Member -MemberType Noteproperty -Name $Section -Value $([pscustomobject]$Hash) -Force ; 
        }
        #write the result to the pipeline
        $obj | write-output ;
    } ;
    End {
        Write-Verbose "Ending $($MyInvocation.Mycommand)" ; 
    } ;
} ;
#*------^ END Function ConvertFrom-IniFile ^------
