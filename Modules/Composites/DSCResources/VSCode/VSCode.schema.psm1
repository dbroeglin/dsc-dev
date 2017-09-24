Configuration VSCode {
    
    Param(
        $InstallDir = "C:\Program Files (x86)\Microsoft VS Code"
    )
    
    Script "DownloadAndInstallVSCode" {
        GetScript = { }
        TestScript = {
            Test-Path -PathType Container -Path $Using:InstallDir
        }
        SetScript = {
            # Source: https://github.com/Azure/azure-devtestlab/blob/master/Artifacts/windows-vscode/installVSCode.ps1
            Function Get-RedirectedUrl
            {
                Param (
                    [Parameter(Mandatory=$true)]
                    [String]$URL
                )
             
                $request = [System.Net.WebRequest]::Create($url)
                $request.AllowAutoRedirect=$false
                $response=$request.GetResponse()
             
                If ($response.StatusCode -eq "Found")
                {
                    $response.GetResponseHeader("Location")
                }
            }
            
            $url = 'http://go.microsoft.com/fwlink/?LinkID=623230'
            $codeSetupUrl = Get-RedirectedUrl -URL $url
            
            $infPath = $PSScriptRoot + "\vscode.inf"
            $vscodeSetup = "${env:Temp}\VSCodeSetup.exe"
            
            try
            {
                (New-Object System.Net.WebClient).DownloadFile($codeSetupUrl, $vscodeSetup)
            }
            catch
            {
                Write-Error "Failed to download VSCode Setup"
            }
            
            $infPath = "c:\vscode.inf"

            try
            {
                @(
                    "[Setup]"
                    "Lang=english"
                    "Dir=$Using:InstallDir"
                    "Group=Visual Studio Code"
                    "NoIcons=0"
                    "Tasks=desktopicon,addcontextmenufiles,addcontextmenufolders,addtopath"
                ) | Out-File -Encoding ascii -FilePath $infPath

                Start-Process -FilePath $vscodeSetup -ArgumentList "/VERYSILENT /MERGETASKS=!runcode /LOADINF=$infPath"
            }
            catch
            {
                Write-Error 'Failed to install VSCode'
            }
            finally 
            {
                Remove-Item $infPath -Force -ErrorAction Continue
            }
        }
    }
}