#************************
# MIGRATE VHD TO AZURE
# Author:@DaveRndn
#***********************

#**********************
# Variables
#*********************
$Params = @{
    StorageAccountName = "vmdepottestkemp" #set a name for your storage account name
    Location = "East Us"
    }
$Subscription = "[Your Subscription]"
$SubscriptionId = "[Your SubscriptioId]"
$ContainerName = "[your container name with no spaces and lowercase]"
$LocalVHD = "C:\Users\....your location to your VHD"
$AzureVHD = "https://yourstorageaccountname.blob.core.windows.net/vhds/yourimagename.vhd"
$DiskName = '[your disk name]'
$LabelName = '[your label name]'
$VMImageName = "VirtualMachine Image Name"
# *************************************
# Prepare the access to your subscription
#**************************************
#Login to Azure Subscription
Add-AzureAccount
# List Available Windows Azure subscriptions
Get-AzureSubscription | Format-Table -Property SubscriptionName
#Set default Windows Azure subscription 
Select-AzureRmSubscription -SubscriptionId $SubscriptionId
Select-AzureSubscription -SubscriptionId $SubscriptionId -Default
# Create a new storage account.
New-AzureStorageAccount –StorageAccountName $StorageAccountName -Location $Location
if (Test-AzureName -Storage -Name $StorageAccountName) {
    "Storage account name '$StorageAccountName' is already taken, try another one"
} else {
    New-AzureStorageAccount @Params
}
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