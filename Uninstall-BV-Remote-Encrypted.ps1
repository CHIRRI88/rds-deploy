#=============================================================================
# CHIRRI RDS Deployment - Encrypted Script
# This script requires a password to execute
#=============================================================================

$ErrorActionPreference = "Stop"

function ConvertFrom-EncryptedPayload {
    param(
        [Parameter(Mandatory)][string]$EncryptedBase64,
        [Parameter(Mandatory)][SecureString]$Password
    )
    
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
    $passwordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    
    $combined = [Convert]::FromBase64String($EncryptedBase64)
    
    $salt = New-Object byte[] 32
    $iv = New-Object byte[] 16
    $encryptedBytes = New-Object byte[] ($combined.Length - 48)
    
    [Array]::Copy($combined, 0, $salt, 0, 32)
    [Array]::Copy($combined, 32, $iv, 0, 16)
    [Array]::Copy($combined, 48, $encryptedBytes, 0, $encryptedBytes.Length)
    
    $keyDerivation = New-Object System.Security.Cryptography.Rfc2898DeriveBytes(
        $passwordPlain, 
        $salt, 
        100000,
        [System.Security.Cryptography.HashAlgorithmName]::SHA256
    )
    $key = $keyDerivation.GetBytes(32)
    $keyDerivation.Dispose()
    
    $passwordPlain = $null
    [System.GC]::Collect()
    
    $aes = [System.Security.Cryptography.Aes]::Create()
    $aes.Key = $key
    $aes.IV = $iv
    $aes.Mode = [System.Security.Cryptography.CipherMode]::CBC
    $aes.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
    
    $decryptor = $aes.CreateDecryptor()
    $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
    
    $aes.Dispose()
    
    return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
}

# Encrypted payload
$encryptedPayload = "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"

# Prompt for password
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " CHIRRI BV Remote Desktop Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
$securePassword = Read-Host "Enter setup password" -AsSecureString

# Attempt decryption and execution
try {
    $decryptedScript = ConvertFrom-EncryptedPayload -EncryptedBase64 $encryptedPayload -Password $securePassword
    Invoke-Expression $decryptedScript
}
catch {
    Write-Host ""
    Write-Host "ERROR: Invalid password or corrupted data." -ForegroundColor Red
    Write-Host ""
    Write-Host "If you believe this is an error, contact IT support." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
