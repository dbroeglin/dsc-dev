Configuration Java {

    Param(
        [Parameter(Mandatory)]
        $DownloadDir,
        $JdkVersion = '1.8.0_131',
        $Build      = '11',
        $Id         = "d54c1d3a095b4ff2b6607d096fa80163"
    )

    Import-DSCResource -ModuleName xPSDesiredStateConfiguration

    $Filename = "jdk-$JdkVersion-windows-x64.exe"

    Script "DownloadJdk" {
        GetScript = { }
        TestScript = {
            Test-Path c:\toto # TODO
        }
        SetScript = {
            $Url = "http://download.oracle.com/otn-pub/java/jdk/$using:JdkVersion-b$using:Build/$id/$filename"
            $DownloadFilename = Join-Path $using:DownloadDir $using:Filename

            Write-Verbose "Downloaing from: $Url"
            Write-Verbose "Downloading  to: $DownloadFilename"

            $Client = New-Object Net.WebClient
            $Null = $Client.Headers.Add('Cookie', 'gpw_e24=http://www.oracle.com; oraclelicense=accept-securebackup-cookie')
            $Null = $Client.DownloadFile($Url, $DownloadFilename)

        }
    } 
}