 psping -t -i 1 google.com |Foreach{"{0} - {1}" -f (Get-Date),$_} | Tee-object -FilePath ping_log.txt