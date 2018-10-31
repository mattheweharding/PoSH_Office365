




Get-ADUser -Filter * -SearchBase 'OU=UMPH Users,DC=umpublishing,DC=org' -Properties DisplayName, Initials | Select-Object -Property DisplayName, GivenName, Initials, Surname

Get-ADUser -Filter * -SearchBase 'OU=UMPH Users,DC=umpublishing,DC=org' -Properties Initials |

ForEach-Object {
    Set-ADUser -Identity $_ -DisplayName ("$($_.GivenName) $($_.Initials) $($_.Surname)" -replace '\s+(?=\s)')
}
