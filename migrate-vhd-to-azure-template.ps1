#************************
# MIGRATE VHD TO AZURE
# Author:@DaveRndn
#***********************

#**********************
# Variables
#*********************
$Subscription = "[Your Subscription]"
$SubscriptionId = "[Your SubscriptionId xxxx-xxxx-xxx]"
$StorageAccountName = '[yourstorageaccountname]'
$Location = 'East Us'
$ContainerName = "[yourcontainername]"
$LocalVHD = "C:\Users\Dave\Dropbox\KEMP\VLM-trial\LoadMasterVLM.vhd"
$AzureVHD = "https://yourstorageaccountname.blob.core.windows.net/yourcontainername/LoadMasterVLM.vhd"
$DiskName = 'LoadMaster-Hyper-V'
$LabelName = 'LoadMaster-Hyper-V'
$VMImageName = "LoadMaster"
# *************************************
# Prepare the access to your subscription
#**************************************
#Login to Azure Subscription
Add-AzureAccount
# List Available Windows Azure subscriptions
Get-AzureSubscription | Format-Table -Property SubscriptionName
#Set default Windows Azure subscription 
Select-AzureSubscription -SubscriptionId $SubscriptionId -Default
# Create a new storage account.
New-AzureStorageAccount –StorageAccountName $StorageAccountName -Location $Location
# Set a default storage account.
Set-AzureSubscription -CurrentStorageAccountName $StorageAccountName -SubscriptionName $Subscription
# Create a new container.
New-AzureStorageContainer -Name $ContainerName -Permission Off
# Get default Windows Azure Storage Account.
Get-AzureStorageAccount | Format-Table -Property Label
# Identify where the VHD is coming from and where it's going.
Add-AzureVhd -LocalFilePath $LocalVHD -Destination $AzureVHD
#Add the VHD to the “My Disk” section of the Gallery
# Register as an OS disk 
Add-AzureDisk -DiskName $DiskName -MediaLocation $AzureVHD -Label $LabelName -OS Windows
#If you want to create the image
Add-AzureVMImage -ImageName $VMImageName -MediaLocation $AzureVHD -OS Windows