<#
.SYNOPSIS
  Quickly disable an account in Office 365 if it's compromised.
.DESCRIPTION
  I'm still working through this script. The point would be to rapidily disable a user's
  Office 365 account if it was compromised. Some steps don't seem to be automatable.
.INPUTS
  None.
.OUTPUTS
  None.
.NOTES
  Version:        0.1
  Author:         Matthew Harding
  Creation Date:  10/30/2018
  Purpose/Change: Initial script development

.EXAMPLE
  CompromisedOffice365Account.ps1
#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

﻿Install-Module -Name MSOnline
Install-Module -Name AzureAD

#----------------------------------------------------------[Declarations]----------------------------------------------------------

#Prompt for email address in Office 365
$User = Read-Host -Prompt 'Enter the Office 365 email address of the affected user'

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Write-Host 'Connecting to Azure AD...'
Connect-MsolService -Credential $Credential

Write-Host 'Setting randon password...'
Set-MsolUserPassword -UserPrincipalName $User -ForceChangePassword $True

Write-Host 'The password was last changed on...'
Get-MsolUser -UserPrincipalName $User | select LastPasswordChangeTimestamp

Write-Host 'Blocking sign ins to Office 365...'
Set-MsolUser -UserPrincipalName $User -BlockCredential $true

Write-Host 'Enabling Multifactor Authentication...'
Set-MsolUser -UserPrincipalName $User -StrongAuthenticationRequirements $MFA

#Connect to Azure AD
Write-Host 'Logging into Office 365..'
Connect-AzureAD -Credential $Credential

Write-Host 'Kill all active user sessions in any Azure AD application..'
Get-AzureADUser -SearchString $User | Revoke-AzureADUserAllRefreshToken

Write-Host 'Connecting to Office 365 Exchange...'
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking

Write-Host 'Setting Litigation Hold for 7 years...'
Set-Mailbox $User -LitigationHoldEnabled $true -LitigationHoldDuration 2555
Write-Host 'This takes up to 60 minutes to take effect.'

#Write-Host 'Moving mailbox to clear cached connections...'
#New-MoveRequest $User -PrimaryOnly
#Write-Host 'This takes up to one hour to complete.'

Write-Host 'Review these mailbox permissions for abnoramlities...'
Get-MailboxPermission -Identity $user | Select AccessRights,User

Write-Host 'Disconnecting from Office 365 Exchange'
Remove-PSSession $Session
