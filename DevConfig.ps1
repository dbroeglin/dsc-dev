Configuration DevConfig {

    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration -ModuleVersion 7.0.0.0
    Import-DSCResource -ModuleName Composites -ModuleVersion 1.0

    $DownloadDir = "c:\Downloads"

    Node $env:COMPUTERNAME {
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true
            AllowModuleOverwrite = $true
            ConfigurationMode    = 'ApplyOnly'
            DebugMode            = "ForceModuleImport"            
        }

        WindowsOptionalFeature "Microsoft-Hyper-V-All" {
            Ensure   = "Enable"
            Name     = "Microsoft-Hyper-V-All"
        }

        WindowsOptionalFeature "Containers" {
            Ensure   = "Enable"
            Name     = "Containers"
        }

        File DownloadDir {
            DestinationPath = $DownloadDir
            Type            = "Directory"
            Ensure          = "Present"
        }

        Java Jdk {
            DownloadDir = $DownloadDir
            DependsOn   = "[File]DownloadDir"
        } 

        VSCode VSCode {

        }

        Script "RSATClient-Roles-AD-Powershell" {
            # Inspired from: https://gallery.technet.microsoft.com/Install-the-Active-fd32e541
            TestScript = {
                (Get-WindowsOptionalFeature -Online -FeatureName RSATClient-Roles-AD-Powershell -ErrorAction SilentlyContinue).State -eq "Enabled"
            }
            SetScript = {
                if (Get-HotFix -Id KB2693643 -ErrorAction SilentlyContinue) {
                    Write-Verbose 'RSAT for Windows 10 is already installed.'
                } else {
                    Write-Verbose 'Downloading RSAT for Windows 10...'
            
                    if ((Get-CimInstance Win32_ComputerSystem).SystemType -like "x64*") {
                        $dl = 'WindowsTH-KB2693643-x64.msu'
                    } else {
                        $dl = 'WindowsTH-KB2693643-x86.msu'
                    }

                    $baseURL = 'https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/'
                    $url = $baseURL + $dl
                    $destination = Join-Path -Path $Using:DownloadDir -ChildPath $dl
                    if (-not (Test-Path -Path $destination -PathType Leaf)) {
                        $webClient = New-Object System.Net.WebClient
                        $webClient.DownloadFile($url, $destination)
                        $webClient.Dispose()    
                    }

                    # http://stackoverflow.com/questions/21112244/apply-service-packs-msu-file-update-using-powershell-scripts-on-local-server
                    Start-Process -FilePath wusa.exe @($Destination, '/quiet', '/norestart', "/log:$Using:DownloadDir\RSAT.log") -NoNewWindow
            
                    do {
                        Start-Sleep -Seconds 5
                        Write-Verbose "Waiting..."
                    } until (Get-HotFix -Id KB2693643 -ErrorAction SilentlyContinue)
                }                

                Enable-WindowsOptionalFeature -Online -FeatureName RSATClient-Roles-AD-Powershell
            }
            GetScript = {
                (Get-WindowsOptionalFeature -Online -FeatureName RSATClient-Roles-AD-Powershell -ErrorAction SilentlyContinue)
            }
        }
    }
}