﻿#*------v Compare-ObjectsSideBySide3.ps1 v------
function Compare-ObjectsSideBySide3 {
    <#
    .SYNOPSIS
    Compare-ObjectsSideBySide3() - Displays four objects side-by-side comparatively in console
    .NOTES
    Author: Richard Slater
    Website:	https://stackoverflow.com/users/74302/richard-slater
    Updated By: Todd Kadrie
    Website:	http://www.toddomation.com
    Twitter:	@tostka, http://twitter.com/tostka
    Additional Credits: REFERENCE
    FileName    : Compare-ObjectsSideBySide3.ps1
    License     : MIT License
    Copyright   : (c) 2020 Todd Kadrie
    Github      : https://github.com/tostka/verb-IO
    Tags        : Powershell,Compare
    REVISIONS   :
    * 10:33 AM 4/25/2022 edit back to compliance, prior overwrite with cosbs4; , fixed pos param specs (uniqued); included output in exmplt
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    * 10:17 AM 9/15/2021 moved to full param block,expanded CBH
    * 11:14 AM 7/29/2021 moved verb-desktop -> verb-io ; 
    * 10:18 AM 11/2/2018 Extension of base model, to 4 columns
    * May 7 '16 at 20:55 posted version
    .DESCRIPTION
    Compare-ObjectsSideBySide3() - Displays four objects side-by-side comparatively in console
    .PARAMETER col1
    Object to compare in 1st column[-col1 `$PsObject1]
    PARAMETER col2
    Object to compare in 2nd column[-col2 `$PsObject1]
    PARAMETER col3
    Object to compare in 3rd column[-col3 `$PsObject1]
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
    PS> $object3 = New-Object PSObject -Property @{
          'Forename' = 'Zhe';
          'Surname' = 'Person';
          'Company' = 'Apfel';
          'MaidenName' = 'NunaUBusiness' ;
        } ;
    PS> Compare-ObjectsSideBySide3 $object1 $object2 $object3| Format-Table Property, col1, col2, col3;
    Property     Col1    Col2   Col3
    --------     ----    ----   ----
    Company      Amido   Google Apfel
    Forename     Richard Jane   Zhe
    MaidenName           Jones  NunaUBusiness
    SelfEmployed True
    Surname      Slater  Smith  Person
    Display $object1,2, & 3 in comparative side-by-side columns
    .LINK
    https://stackoverflow.com/questions/37089766/powershell-side-by-side-objects
    #>
    PARAM(
        [Parameter(Position=0,Mandatory=$True,HelpMessage="Object to compare in 1st column[-col1 `$PsObject1]")]
        #[Alias('lhs')]
        $col1,
        [Parameter(Position=1,Mandatory=$True,HelpMessage="Object to compare in 2nd column[-col1 `$PsObject1]")]
        #[Alias('rhs')]        
        $col2,
        [Parameter(Position=2,Mandatory=$True,HelpMessage="Object to compare in 3rd column[-col1 `$PsObject1]")]
        #[Alias('rhs')]        
        $col3
    ) ;
    $col1Members = $col1 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col2Members = $col2 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $col3Members = $col3 | Get-Member -MemberType NoteProperty, Property | Select-Object -ExpandProperty Name ;
    $combinedMembers = ($col1Members + $col2Members + $col3Members) | Sort-Object -Unique ;
    $combinedMembers | ForEach-Object {
        $properties = @{'Property' = $_} ;
        if ($col1Members.Contains($_)) {$properties['Col1'] = $col1 | Select-Object -ExpandProperty $_} ;
        if ($col2Members.Contains($_)) {$properties['Col2'] = $col2 | Select-Object -ExpandProperty $_} ;
        if ($col3Members.Contains($_)) {$properties['Col3'] = $col3 | Select-Object -ExpandProperty $_} ;
        New-Object PSObject -Property $properties ;
    } ;
}

#*------^ Compare-ObjectsSideBySide3.ps1 ^------