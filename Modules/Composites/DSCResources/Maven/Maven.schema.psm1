# Source: https://chocolatey.org/packages/maven
Configuration Maven {
    
    Param(
        [String]
        $version = '3.5.0',
        
        [String]
        $name = "apache-maven-$version",

        [String]
        $url = "https://archive.apache.org/dist/maven/maven-3/$version/binaries/$name-bin.zip",

        [String]
        $InstallDir = "C:\Program Files\Maven",
        
        [String]
        $DownloadDir = 'c:\Downloads'
    )
   
    Import-DSCResource -ModuleName xPSDesiredStateConfiguration
    
    xRemoteFile {
        Name = ""
    }
}