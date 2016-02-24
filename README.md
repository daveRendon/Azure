
# Migrar VHD a Azure con Powershell


Una de las características interesantes de Azure es la flexibilidad para migrar VHD´s. Esto significa que puedes cargar y descargar VHD´s hacia y desde la nube.

Consideraciones:

En este artículo migraremos una máquina virtual KEMP LoadMaster Hyper-v hacia Azure. Se puede descargar desde aquí: kemptechnologies.com/vlm-download/

El formato VHDx no está soportado en Microsoft Azure, puedes convertir el disco en formato VHD mediante el Administrador de Hyper-V o el cmdlet Convert-VHD.

Pre-requisitos:

Contar con una suscripción activa de Azure

Tener el módulo Microsoft Azure Powershell instalado y asociado con la suscripción activa, se puede descargar desde: https://azure.microsoft.com/downloads/

Pasos.

Preparar el VHD
Acceder a la cuenta de Azure
Crear un Storage Account y un Container
Obtener el Storage Account
Identificar la ubicación local del VHD y la ubicación donde lo alojaremos en Azure.


#1. Preparar el VHD

Antes de migrar el VHD a Azure, tiene que generalizarse mediante el uso de la herramienta Sysprep. Esto prepara el VHD para ser utilizado como una imagen. (Actualmente estamos utilizando el KEMP LoadMaster, por lo que podemos omitir este paso).

Desde la máquina virtual donde se instaló el sistema operativo:

Iniciar sesión.

Abrir una ventana del símbolo del sistema como administrador. Cambiar el directorio a %windir%\system32\sysprep y ejecutar sysprep.exe.

sysprep_commandprompt

A continuación, se mostrará la ventana del System Preparation Tool:

sysprepgeneral

Seleccionar Enter System Out-of-Box (OOBE) y marca la opción de Generalize.

En Shutdown Options , selecciona Shutdown, Clic en OK.

# Variables 

Abrimos Powershell ISE como administrador y añadimos las primeras variables de nuestro script.


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
Preparamos el acceso a la suscripción asociada y obtenemos las posibles suscripciones asociadas y definimos la suscripción por default: :


# Acceder a la cuenta de Azure

//Login to Azure Subscription
Add-AzureAccount
// List Available Windows Azure subscriptions
Get-AzureSubscription | Format-Table -Property SubscriptionName
//Set default Windows Azure subscription 
Select-AzureRmSubscription -SubscriptionId $SubscriptionId
Select-AzureSubscription -SubscriptionId $SubscriptionId -Default
3. Creamos el storage account y lo definimos como default para alojar nuestro VHD, definimos una condición en caso de que el nombre del storage no esté disponible:

# Crear un nuevo storage account.
New-AzureStorageAccount –StorageAccountName $StorageAccountName -Location $Location
if (Test-AzureName -Storage -Name $StorageAccountName) {
 "Storage account name '$StorageAccountName' is already taken, try another one"
} else {
 New-AzureStorageAccount @Params
}
Set-AzureSubscription -CurrentStorageAccountName $StorageAccountName -SubscriptionName $Subscription
4. Definimos un Container  donde alojaremos nuestro VHD, y obtenemos el Storage Account:

# Creae un container.
New-AzureStorageContainer -Name $ContainerName -Permission Off
Get-AzureStorageAccount | Format-Table -Property Label

#Identificar la ubicación local del VHD y la ubicación donde lo alojaremos en Azure.

Add-AzureVhd -LocalFilePath $LocalVHD -Destination $AzureVHD
Podemos crear la imagen para la instancia de la Máquina Virtual en Azure ó podemos asociar el VHD a “Mis Discos” en la sección de la galería:

# Agregar el VHD a la sección de  “My Disk” en la galería

Add-AzureDisk -DiskName $DiskName -MediaLocation $AzureVHD -Label $LabelName -OS Windows

# Agregar el VHD como imagen para crear varias VM´s
Add-AzureVMImage -ImageName $VMImageName -MediaLocation $AzureVHD -OS Windows

 http://wikiazure.com/migrar-vhd-a-azure-con-powershell/
