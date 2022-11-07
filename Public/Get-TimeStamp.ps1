#*------v Function Get-TimeStamp v------
function Get-TimeStamp {
    <#
    .SYNOPSIS
    Get-TimeStamp - Generate and return to pipeline, a timestamp-format [datetime]
    .NOTES
    Author      : Todd Kadrie
    Website     :	http://www.toddomation.com
    Twitter     :	@tostka / http://twitter.com/tostka
    Github      : https://github.com/tostka/verb-XXX
    REVISIONS
    * 10:35 AM 2/21/2022 CBH example ps> adds 
    # 	# ren'd TimeStampNow to get-TimeStampNow
    # vers: 20091002
    .DESCRIPTION
    Get-TimeStamp - Generate and return to pipeline, a timestamp-format [datetime]
    .EXAMPLE
    PS> $timest = get-TimeStamp
    OPTSAMPLEOUTPUT
    Assign a timestamp to $timest
    .LINK
    https://github.com/tostka/verb-io
    #>
    Get-Date -Format "HH:mm:ss"
} #*------^ END Function Get-TimeStamp ^------
