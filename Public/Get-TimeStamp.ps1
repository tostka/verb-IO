#*------v Function Get-TimeStamp v------
function Get-TimeStamp {
    # vers: 8:43 AM 10/31/2014 - simple timestamp echo
    # stock version
    #Get-DateTime -Format 'yyyy-MM-dd HH:mm:ss'
    # my version
    #(get-date).ToString("HH:mm:ss")
    #Get-DateTime -Format "HH:mm:ss"
    # 2:11 PM 12/3/2014 no such cmd as get-datetime
    Get-Date -Format "HH:mm:ss"
} #*------^ END Function Get-TimeStamp ^------
