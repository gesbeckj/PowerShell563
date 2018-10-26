$EmailAddress = 'a'
get-inboxrule -Mailbox $EmailAddress
Get-MessageTrace -RecipientAddress $EmailAddress -StartDate 10/10/2018 -EndDate 10/19/2018 -PageSize 5000 | export-csv TRRecieved.csv
Get-MessageTrace -SenderAddress $EmailAddress -StartDate 10/10/2018 -EndDate 10/19/2018 -PageSize 5000 | export-csv TRSent.csv