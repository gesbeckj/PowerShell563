$AllMbx = Get-Mailbox * | where {$_.RecipientTypeDetails -ne "EquipmentMailbox"} | Where {$_.RecipientTypeDetails -ne "RoomMailbox"}
foreach($mailbox in $AllMbx)
{
    $Users = get-mailboxpermission $mailbox.name | Where-Object {$_.IsInherited -eq $false} | Where-object {$_.AccessRights -eq "FullAccess"} | where-object {$_.User -inotlike 'S-*'}
    foreach ($user in $users)
    {
        Add-MailboxPermission -Identity $mailbox.name -User $user.user -AccessRights FullAccess -InheritanceType All -AutoMapping $true
    }
    }