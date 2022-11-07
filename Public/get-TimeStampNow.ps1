#*------v Function get-TimeStampNow v------
Function get-TimeStampNow () {
    <#
    .SYNOPSIS
    get-TimeStampNow - Generate and return to pipeline, a timestamp-format [datetime]
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
    get-TimeStampNow.ps1 - Generate and return to pipeline, a timestamp-format [datetime]
    .EXAMPLE
    PS> $timest = get-TimeStampNow
    OPTSAMPLEOUTPUT
    Assign a timestamp to $timest
    .LINK
    https://github.com/tostka/verb-io
    #>
    $TimeStampNow = get-date -uformat "%Y%m%d-%H%M"
    return $TimeStampNow
} #*------^ END Function get-TimeStampNow ^------
