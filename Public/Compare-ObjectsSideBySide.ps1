#*------v Compare-ObjectsSideBySide.ps1 v------
function Compare-ObjectsSideBySide{
    <#
    .SYNOPSIS
    Compare-ObjectsSideBySide() - Displays a pair of objects side-by-side comparatively in console
    .NOTES
    Author: Richard Slater
    Website:	https://stackoverflow.com/users/74302/richard-slater
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    Website:	URL
    Twitter:	URL
    FileName    : convert-ColorHexCodeToWindowsMediaColorsName.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : PowershellConsole
    REVISIONS   :
    * 11:04 AM 4/25/2022 added CBH example output, and another example using Exchange Get-MailboxDatabaseCopyStatus results, between a pair of DAG nodes.
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 10:17 AM 9/15/2021 fixed typo in params, moved to full param block, and added lhs/rhs as aliases; expanded CBH
    * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
    * 10:18 AM 11/2/2018 reformatted, tightened up, shifted params to body, added pshelp
    * May 7 '16 at 20:55 posted version
    .DESCRIPTION
    Compare-ObjectsSideBySide() - Displays a pair of objects side-by-side comparatively in console
    .PARAMETER  col1
    Object to be displayed in Left Column [-col1 $PsObject1]
    .PARAMETER  col2
    Object to be displayed in Right Column [-col2 $PsObject2]
    .PARAMETER ShowDebug
    Parameter to display Debugging messages [-ShowDebug switch]
    .INPUTS
    Acceptes piped input.
    .OUTPUTS
    Outputs specified object side-by-side on console
    .EXAMPLE
    PS> $object1 = New-Object PSObject -Property @{
          'Forename' = 'Richard';
          'Surname' = 'Slater';
          'Company' = 'Amido';
          'SelfEmployed' = $true;
        } ;
    PS> $object2 = New-Object PSObject -Property @{
          'Forename' = 'Jane';
          'Surname' = 'Smith';
          'Company' = 'Google';
          'MaidenName' = 'Jones' ;
        } ;
    PS> Compare-ObjectsSideBySide $object1 $object2 | Format-Table Property, col1, col2;
    Property     Col1    Col2
    --------     ----    ----
    Company      Amido   Google
    Forename     Richard Jane
    MaidenName           Jones
    SelfEmployed True
    Surname      Slater  Smith
    Display $object1 & $object2 in comparative side-by-side columns
    .EXAMPLE
    PS> $prpDBR = 'Name','Status', @{ Label ="CopyQ"; Expression={($_.CopyQueueLength).tostring("F0")}}, @{ Label ="ReplayQ"; Expression={($_.ReplayQueueLength).tostring("F0")}},@{ Label ="IndxState"; Expression={$_.ContentIndexState.ToSTring()}} ; 
    PS> $dbs0 = (Get-MailboxDatabaseCopyStatus -Server $srvr0.name -erroraction silentlycontinue | sort Status,Name| select $prpDBR) ; 
    PS> $dbs1 = (Get-MailboxDatabaseCopyStatus -Server $srvr1.name -erroraction silentlycontinue | sort Status,Name| select $prpDBR) ; 
    PS> Compare-ObjectsSideBySide $dbs0 $dbs1 | ft  property,col1,col2
    Property  Col1                                                                        Col2
    --------  ----                                                                        ----
    CopyQ     {0, 0, 0}                                                                   {0, 0, 0}
    IndxState {Healthy, Healthy, Healthy}                                                 {Healthy, Healthy, Healthy}
    Name      {SPBMS640Mail01\SPBMS640, SPBMS640Mail03\SPBMS640, SPBMS640Mail04\SPBMS640} {SPBMS640Mail01\SPBMS641, SPBMS640Mail03\SPBMS641, SPBMS640Mail04\SPBMS641}
    ReplayQ   {0, 0, 0}                                                                   {0, 0, 0}
    Status    {Mounted, Mounted, Mounted}                                                 {Healthy, Healthy, Healthy}
    Demo output with Exchange DAG database status from two nodes. Not as well formatted as prior demo, but still somewhat useful for side by side of DAG nodes. 
    .LINK
    https://stackoverflow.com/questions/37089766/powershell-side-by-side-objects
    .LINK
    https://github.com/tostka/verb-IO
    #>
    PARAM(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Object to compare in left/1st column[-col1 `$obj1]")]
        [Alias('lhs')]
        $col1,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Object to compare in left/1st column[-col1 `$obj2]")]
        [Alias('rhs')]        
        $col2
    ) ;
    $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $combinedMembers = ($col1Members + $col2Members) | Sort-Object -Unique ;
    $combinedMembers | ForEach-Object {
        $properties = @{'Property' = $_} ;
        if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
        if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
        New-Object PSObject -Property $properties ;
    } ;
}

#*------^ Compare-ObjectsSideBySide.ps1 ^------