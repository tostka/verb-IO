#*------v Function get-TimeStampNow v------
Function get-TimeStampNow () {
    # 	# ren'd TimeStampNow to get-TimeStampNow
    # vers: 20091002
    $TimeStampNow = get-date -uformat "%Y%m%d-%H%M"
    return $TimeStampNow
} #*------^ END Function get-TimeStampNow ^------