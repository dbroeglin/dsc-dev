# DSC Developer VM setup

DSC Configuration for setting up a generic Windows PowerShell / C# dev virtual machine

# Virtual Machine Setup

1. Setup the VM 
        
        VERSION=1709
        
        ovftool --hideEula --extraConfig:vhv.enable=true --allowAllExtraConfig $HOME/Downloads/WinDev${VERSION}Eval.VMware/WinDev${VERSION}Eval.ovf ~/Documents/Virtual\ Machines.localized/
        
        # we should have virtualhw.version = "11" :
        # v1704 required: 
        sed -i -e 's/guestos = "other-64"/guestos = "windows9-64"/' ~/Documents/Virtual\ Machines.localized/WinDev${VERSION}Eval.vmwarevm/WinDev${VERSION}Eval.vmx

        vmrun start ~/Documents/Virtual\ Machines.localized/WinDev${VERSION}Eval.vmwarevm
1. Install VMWare Guest Tools (if required you can upgrade the VMWare tools with the following commands):

        vmrun installTools ~/Documents/Virtual\ Machines.localized/WinDev${VERSION}Eval.vmwarevm/WinDev${VERSION}Eval.vmx 

    then run `D:\setup64.exe` to install the tools and restart when asked to.
1. Share `~/Sources/dsc-dev/`

        vmrun enableSharedFolders ~/Documents/Virtual\ Machines.localized/WinDev${VERSION}Eval.vmwarevm/WinDev${VERSION}Eval.vmx
        vmrun addSharedFolder ~/Documents/Virtual\ Machines.localized/WinDev${VERSION}Eval.vmwarevm/WinDev${VERSION}Eval.vmx dsc-dev ~/Sources/dsc-dev
1. Add Language/Keyboard settings

        Set-WinUserLanguageList -LanguageList fr-CH

1. In PowerShell *as administrator*:

        cd z:\dsc-dev
        Set-ExecutionPolicy -ExecutionPolicy Bypass -Force  
        .\Run.ps1 -WithCopy -Verbose

# References

## Troubleshooting DSC 

* https://docs.microsoft.com/fr-fr/powershell/dsc/troubleshooting?tduid=(a72d1576be339a12893f2268dc8dee3f)(256380)(2459594)(TnL5HPStwNw-G3YawjTSXxm43ytsqcG1SQ)()#my-resources-won-t-update-how-to-reset-the-cache&ranMID=24542&ranEAID=TnL5HPStwNw&ranSiteID=TnL5HPStwNw-G3YawjTSXxm43ytsqcG1SQ
* https://ingogegenwarth.wordpress.com/2015/11/11/powershell-desired-state-configurationdschow-to-enforce-a-consistency-check/

# TODOs

* Install AzureRM module
* Install AzureAD module
* Install nuget CLI