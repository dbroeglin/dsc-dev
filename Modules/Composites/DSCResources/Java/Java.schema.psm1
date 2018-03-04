Configuration Java {

    Param(
        [Parameter(Mandatory)]
        $DownloadDir,
        
        [String]
        $JavaVersion = '1.8.0_162',

        [String]
        $JdkVersion = '8u162',

        [String]
        $Build      = '12',

        [String]
        $OracleId   = '0da788060d494f5095bf8624735fa2f1',   
        
        # Obtain with: Get-WmiObject Win32_Product | Format-Table IdentifyingNumber, Name, Version | ? Name -like *Java*
        [String]       
        $ProductId  = "{64A3A4F4-B792-11D6-A78A-00B0D0180162}",

        [String]
        $PackageName = "Java SE Development Kit 8 Update 162"
    )

    Import-DSCResource -ModuleName xPSDesiredStateConfiguration

    $filename = "jdk-$JdkVersion-windows-x64.exe"
    $downloadFilename = Join-Path $DownloadDir $filename
    
    Script "DownloadJdk" {
        GetScript = { }
        TestScript = {
            Test-Path -PathType Leaf -Path $Using:downloadFilename
        }
        SetScript = {
            $url = "http://download.oracle.com/otn-pub/java/jdk/$Using:JdkVersion-b$Using:Build/$Using:OracleId/$Using:filename"

            Write-Verbose "Downloading from: $url"
            Write-Verbose "Downloading   to: $Using:downloadFilename"

            $Client = New-Object Net.WebClient
            $Null = $Client.Headers.Add('Cookie', 'gpw_e24=http://www.oracle.com;oraclelicense=accept-securebackup-cookie')
            $Null = $Client.DownloadFile($url, $Using:downloadFilename)
        }
    }

    xPackage Jdk {
        Name      = $PackageName
        Path      = $downloadFilename
        ProductId = $ProductId
        Ensure    = "Present"
        Arguments = '/s STATIC=1 ADDLOCAL="ToolsFeature"'
        DependsOn = "[Script]DownloadJdk"
    }
}