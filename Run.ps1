[CmdletBinding()]
Param(
    [String]
    $LanguageList = "fr-CH",

    [Switch]
    $WithCopy
)

$RequiredModules = "xPSDesiredStateConfiguration"


$ErrorActionPreference = 'Stop'
$PSPathSeparator       = [System.IO.Path]::PathSeparator
$resetLcm              = $False

if ($WithCopy) {
    $Root = "c:\dsc-dev"
    Write-Verbose "Using $Root as working directory..."
    if (Test-Path $Root) {
        Remove-Item -Recurse -Force $Root        
    }
    Copy-Item -Recurse -Force $PSScriptRoot $Root
    $LocalModulesCacheDir  = "C:\ModulesCache"
} else {
    $Root = $PSScriptRoot
    $LocalModulesCacheDir  = Join-Path $Root "ModulesCache"
}

$LocalModulesDir       = Join-Path $Root "Modules"

Write-Verbose "Setting language list to $LanguageList..."
Set-WinUserLanguageList -LanguageList $LanguageList -Force

if (-not (Get-PackageProvider -name NuGet)) {
    Write-Verbose "Installing Nuget package provider..."
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
}
if (-not (Get-PSRepository PSGallery ).Trusted) {
    Write-Verbose "Setting PSGallery installation policy to Trusted..."
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
}

if ("Stopped" -eq (Get-Service -Name winrm).Status) {
    Write-Verbose "Setting up winrm quick config..."
    winrm quickconfig -force
}

if (-not ($env:PSModulePath -split $PSPathSeparator).Contains($LocalModulesDir)) {
    Write-Verbose "Adding $LocalModulesDir to PSMODULEPATH"
    $env:PSModulePath = "$LocalModulesDir$PSPathSeparator$env:PSModulePath"
    [environment]::SetEnvironmentVariable("PSModulePath", $env:PSModulePath, "Machine")
    $resetLcm = $True
}

if (-not ($env:PSModulePath -split $PSPathSeparator).Contains($LocalModulesCacheDir)) {
    Write-Verbose "Adding $LocalModulesCacheDir to PSMODULEPATH"
    $env:PSModulePath = "$LocalModulesCacheDir$PSPathSeparator$env:PSModulePath"
    [environment]::SetEnvironmentVariable("PSModulePath", $env:PSModulePath, "Machine")
    $resetLcm = $True
}

if ($resetLcm) {
    Write-Verbose "Reseting the LCM..."
    $dscProcessID = Get-WmiObject msft_providers | 
    Where-Object {$_.provider -like 'dsccore'} | 
    Select-Object -ExpandProperty HostProcessIdentifier
    if ($dscProcessID) {
        Write-Verbose "Killing process $dscProcessId..."
        Get-Process -Id $dscProcessID | Stop-Process -Force          
    }
}

if (-not (Test-Path -Path $LocalModulesCacheDir)) {
    New-Item -ItemType Container -Path $LocalModulesCacheDir > $Null
}
$RequiredModules | ForEach-Object {
    if (-not (Get-Module -ListAvailable $_)) {
        Write-Verbose "Installing module $_ to $LocalModulesCacheDir..."
        Save-Module $_ -Path $LocalModulesCacheDir
    }
}

Push-Location
Set-Location $Root
try { 
    . $Root\DevConfig.ps1

    DevConfig -ConfigurationData @{ 
        AllNodes = @(
            @{
                NodeName = $env:COMPUTERNAME
            }
        )} -OutputPath DevConfig -Verbose

    Set-DscLocalConfigurationManager -Path DevConfig -Verbose
    Start-DscConfiguration -Wait  -Force -Path DevConfig -Verbose -Debug
} finally {
    Pop-Location
}