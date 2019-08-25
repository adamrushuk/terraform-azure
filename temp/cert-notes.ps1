# Create slef-signed cert
$certpolicy = New-AzureKeyVaultCertificatePolicy -SubjectName "CN=www.example.com" ‑IssuerName Self -ValidityInMonths 12
Add-AzureKeyVaultCertificate -VaultName "UniqueKeyVaultName1" -Name Cert1 ‑CertificatePolicy $certpolicy
Get-AzureKeyVaultCertificate -VaultName "UniqueKeyVaultName1" -Name Cert1

#  import an existing .PFX file into Azure
$PfxPassword = ConvertTo-SecureString -String "password" -AsPlainText -Force
Import-AzureKeyVaultCertificate -VaultName "UniqueKeyVaultName1" -Name "Cert2" ‑FilePath "C:\temp\cert.pfx" -Password $PfxPassword
