$EmailAddress = 'acvalencia@VNECORP.COM'
get-inboxrule -Mailbox $EmailAddress
Get-MessageTrace -RecipientAddress $EmailAddress -StartDate 2/10/2019 -EndDate 2/14/2019 -PageSize 5000 | export-csv VNERecieved.csv
Get-MessageTrace -SenderAddress $EmailAddress -StartDate 2/10/2019 -EndDate 2/14/2019 -PageSize 5000 | export-csv VNESent.csv