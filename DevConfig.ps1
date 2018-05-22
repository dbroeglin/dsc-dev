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

        WindowsOptionalFeature "ADAM" {
            Ensure   = "Enable"
            Name     = "DirectoryServices-ADAM-Client"
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
    }
}