$EmailAddress = 'james@derp.com'
get-inboxrule -Mailbox $EmailAddress
Get-MessageTrace -RecipientAddress $EmailAddress -StartDate 09/29/2018 -EndDate 10/3/2018 -PageSize 5000 | export-csv Recieved.csv
Get-MessageTrace -SenderAddress $EmailAddress -StartDate 09/29/2018 -EndDate 10/3/2018 -PageSize 5000 | export-csv Sent.csv