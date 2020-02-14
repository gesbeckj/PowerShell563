Connect-PartnerCenter
$TemplateID = "117a77b0-9360-443b-8795-c6dedc750cf9"
$Customers = Get-PartnerCustomer

$CustomerList = Import-CSV C:\users\james.gesbeck\Documents\CSP4.csv
$customer = $CustomerList[1]
foreach($customer in $CustomerList)
{
    #Write-Output $customer.Status
    if($customer.Status -eq "Complete")
    {
        $CUST = $Customers | Where {$_.Name -eq $customer.O365Name}
        $CUSTID = $CUST.CustomerId
        New-PartnerCustomerAgreement -AgreementType MicrosoftCustomerAgreement -TemplateId $TemplateID -ContactFirstName $customer.'First Name' -ContactLastName $customer.'Last Name' -ContactEmail $customer.Email -CustomerId $CUSTID
        Write-Output "Accepting Agreement for $($customer.O365Name)"
    }
}

117a77b0-9360-443b-8795-c6dedc750cf9