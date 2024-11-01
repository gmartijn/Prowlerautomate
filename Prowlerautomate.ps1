# ------------------------------------------------------------------------------  
# Script Title: Python and Prowler Installation Script  
# Version: 1.20  
# Author: Cybersharks BV 
#  
# Description:  
# This PowerShell script automates the installation of Python 3.12.5 (64-bit)  
# and the Prowler security scanning tool. It checks for administrative privileges,  
# sets the execution policy, and ensures that Python and its associated tools   
# are correctly installed and configured for use. The script also prompts the   
# user for necessary cloud account credentials and initiates a security scan   
# using Prowler, providing a streamlined setup for cloud security assessments.  
#  
# Key Features:  
# - Checks for administrative permissions before execution.  
# - Downloads and installs Python 3.12.5 silently to a specified directory.  
# - Adds Python's script directory to the system PATH for easy access to tools   
#   like pip.  
# - Installs the Prowler tool for cloud security scanning.  
# - Prompts the user for Tenant ID and Account ID for scanning purposes.  
# - Initiates a Prowler scan with user-provided credentials.  
#  
# Usage:  
# Run this script in an elevated PowerShell window to ensure it has the necessary   
# permissions. Follow the on-screen prompts to complete the installation and   
# configuration process.  
# ------------------------------------------------------------------------------  
  
# Function to check if the script is running with administrative privileges  
function Test-IsAdmin {  
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()  
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)  
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)  
}  
  
# Check for administrative privileges  
if (-not (Test-IsAdmin)) {  
    Write-Host "This script requires administrative privileges. Please run it as an administrator." -ForegroundColor Red  
    exit  
}  
  
# Set execution policy to allow script execution  
Set-ExecutionPolicy Unrestricted  
  
# Install Python 3.12.5 x64  
Write-Host "Installing Python 3.12.5 x64..." -ForegroundColor Cyan  
Write-Host "Downloading..."  
  
$exePath = "$env:TEMP\python-3.12.5-amd64.exe"  
(New-Object Net.WebClient).DownloadFile(  
    'https://www.python.org/ftp/python/3.12.5/python-3.12.5-amd64.exe',  
    $exePath  
)  
  
Write-Host "Installing Python..."  
cmd /c start /wait $exePath /quiet `  
    TargetDir=C:\Python36-x64 `  
    Shortcuts=1 `  
    Include_launcher=1 `  
    InstallLauncherAllUsers=0  
  
# Add Pip to the system PATH  
Write-Host "Adding Pip to path..."  
$addPath = 'C:\Python36-x64\scripts'  
$arrPath = $env:Path -split ';' | Where-Object { $_ -notlike "$addPath*" }  
$env:Path = ($arrPath + $addPath) -join ';'  
  
# Install Prowler  
Write-Host "Installing Prowler... This might take up to 15 minutes. Please hang on."  
Write-Host "Progress can be monitored through the PIP window. Please hang on."  
  
cmd /c start /wait C:\Python36-x64\scripts\pip install prowler  
Write-Host "Prowler is now installed"  
  
# Check Prowler version  
C:\Python36-x64\scripts\prowler.exe --version  
  
# User input for scanning  
$TenantID = Read-Host "What Tenant are you scanning? AWS/Azure? (e.g., xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx format)"  
$AccountID = Read-Host "What Account are you scanning? AWS/Azure? (e.g., xxxxxxx-xxxx-xxxx-xxxx-xxxxxxxx format)"  
  
# Instructions for user  
Write-Host "Open up the default browser, and enter your credentials!"  
  
# Run Prowler with user-provided credentials  
prowler azure --browser-auth --tenant-id $AccountID --subscription-ids $TenantID  
  
# Zip the output folder  
$outputFolder = ".\output"  # Replace with the actual output folder path  
$zipFileName = "$AccountID-cybershark.zip"  
$zipFilePath = Join-Path -Path $env:TEMP -ChildPath $zipFileName  
  
Write-Host "Zipping output folder to $zipFileName..."  
  
# Create the zip archive  
Compress-Archive -Path $outputFolder\* -DestinationPath $zipFilePath  
  
Write-Host "Output folder zipped successfully. File saved as: $zipFilePath"  