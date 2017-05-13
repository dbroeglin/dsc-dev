[CmdletBinding()]

$ErrorActionPreference = 'Stop'

if (-not (Get-PackageProvider -name NuGet)) {
    Write-Verbose "Installing Nuget package provider..."
    Install-PackageProvider -Name NuGet -RequiredVersion 2.8.5.201 -Force
}
if (-not (Get-PSRepository PSGallery ).Trusted) {
    Write-Verbose "Setting PSGallery installation policy to Trusted..."
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

if ("Stopped" -eq (Get-Service -Name winrm).Status) {
    Write-Verbose "Setting up winrm quick config..."
    winrm quickconfig -force
}

. $PSScriptRoot\DevConfig.ps1

DevConfig -ConfigurationData @{ 
    AllNodes = @(
        @{
            NodeName = $env:COMPUTERNAME
        }
    )} -OutputPath DevConfig -Verbose

Set-DscLocalConfigurationManager -Path DevConfig -Verbose
Start-DscConfiguration -Wait  -Force -Path DevConfig -Verbose -Debug