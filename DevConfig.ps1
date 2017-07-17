Configuration DevConfig {

    Import-DSCResource -ModuleName PSDesiredStateConfiguration
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration
    Import-DSCResource -ModuleName Composites

    Node $env:COMPUTERNAME {
        LocalConfigurationManager {
            RebootNodeIfNeeded   = $true;
            AllowModuleOverwrite = $true;
            ConfigurationMode    = 'ApplyOnly';
        }

        WindowsOptionalFeature "Microsoft-Hyper-V-All" {
            Ensure   = "Enable"
            Name     = "Microsoft-Hyper-V-All"
        }

        WindowsOptionalFeature "Containers" {
            Ensure   = "Enable"
            Name     = "Containers"
        }

        Java Jdk {
            DownloadDir = "c:\Downloads"

        } 
    }
}
