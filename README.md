***EN*** | [RU](README.ru.md)

# WebP Utility

A set of utilities for quick and easy installation, configuration and further use of the *WebP* image format tools.

## This must be done before working with PowerShell scripts

By default, scripting is turned off on Windows systems, so when you working with a "Default" system, PowerShell will refuse to run scripts and you will not be able to use the utilities from this suite.

To solve this problem, all you need to do is run PowerShell as Administrator:

`Type "PowerShell" in Windows search -> *Right-click on PowerShell* -> Run as administrator`

After that, you need to execute the following command:

`Set-ExecutionPolicy RemoteSigned`

Now you can execute scripts on your system.

If you want to secure yourself after installing the WebP package, you can enter the following command to restore the default settings:

`Set-ExecutionPolicy Restricted`

## What's here?

### **WebP Package Installer** *(Necessary for work)*

To install *WebP* on your device, simply run the file *PS_WebP_Installer.ps1* in *PowerShell*.

`Right-click -> Run with PowerShell`

The installer will download the latest version of the libraries to work with *WebP*, install the necessary materials and embed the path to them in *Environment Variables*.

### **Converter** *(Work for all images in the folder)*

If you just need to convert *JPG/PNG* into *WebP* you can run the file *PS_All_Images_To_WebP.ps1* which by default converts *JPG/PNG* images lying with him in the same folder to *WebP*.

## Settings

Each of the utilities has a block of available settings at the beginning with the necessary explanations of the functionality. 

To change the settings, do the following:

`Right-click -> Open with -> *Select any text editor that suits you*`

After that you can see/change the settings of the utilities.