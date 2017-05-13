# DSC Developer VM setup

DSC Configuration for setting up a generic Windows PowerShell / C# dev virtual machine

# Virtual Machine Setup

1. Setup the VM 
        
        ovftool --hideEula --extraConfig:vhv.enable=true --allowAllExtraConfig Downloads/WinDev1704Eval.VMware/WinDev1704Eval.ovf ~/Documents/Virtual\ Machines.localized/
        
        # we should have virtualhw.version = "11" :
        sed -i -e 's/guestos = "other-64"/guestos = "windows9-64"/' ~/Documents/Virtual\ Machines.localized/WinDev1704Eval.vmwarevm/WinDev1704Eval.vmx

        vmrun start ~/Documents/Virtual\ Machines.localized/WinDev1704Eval.vmwarevm
1. Install VMWare Guest Tools
        
        vmrun installTools ~/Documents/Virtual\ Machines.localized/WinDev1704Eval.vmwarevm/WinDev1704Eval.vmx 

    then run `D:\setup64.exe` to install the tools and restart when asked to.
1. Share `~/Sources/dsc-dev/`

        vmrun enableSharedFolders ~/Documents/Virtual\ Machines.localized/WinDev1704Eval.vmwarevm/WinDev1704Eval.vmx
        vmrun addSharedFolder ~/Documents/Virtual\ Machines.localized/WinDev1704Eval.vmwarevm/WinDev1704Eval.vmx dsc-dev ~/Sources/dsc-dev
1. Add Language/Keyboard settings

        Set-WinUserLanguageList -LanguageList fr-CH
1. In PowerShell as admin if you want to access shared folders

        net use Z: "\\vmware-host\Shared Folders"
1. TODO: winrm quickconfig
1. Install the configuration:

        cd z:\dsc-dev
        .\DevConfig.ps1
