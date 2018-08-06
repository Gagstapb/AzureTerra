
resource "azurerm_resource_group" "tfprodgs" {
        name = "tfprodrg"
        location = "west us"
}

resource "azurerm_virtual_network" "tfprodgs" {
        name = "tfvnet"
        address_space = ["10.0.0.0/16"]
        location = "west us"
        resource_group_name = "${azurerm_resource_group.tfprodgs.name}"
}

resource "azurerm_subnet" "tfprodgs" {
        name = "tfsubnet"
        resource_group_name = "${azurerm_resource_group.tfprodgs.name}"
        virtual_network_name = "${azurerm_virtual_network.tfprodgs.name}"
        address_prefix = "10.0.2.0/24"
}

resource "azurerm_public_ip" "tfprodgs" {
  name                         = "tfprodpbip"
  location                     = "West US"
  resource_group_name          = "${azurerm_resource_group.tfprodgs.name}"
  public_ip_address_allocation = "static"

}
resource "azurerm_network_interface" "tfprodgs" {
        name = "tfnet"
        location = "west us"
        resource_group_name="${azurerm_resource_group.tfprodgs.name}"
        
        ip_configuration {
                name = "tfipconfigprod"
                subnet_id = "${azurerm_subnet.tfprodgs.id}"
                private_ip_address_allocation = "dynamic"
                public_ip_address_id ="${azurerm_public_ip.tfprodgs.id}"
                //depends_on = "${azurerm_network_interface.tfprodgs}"
        }
}

resource "azurerm_managed_disk" "tfprodgs" {
        name = "tdprod_data"
        location = "west us"
        resource_group_name ="${azurerm_resource_group.tfprodgs.name}"
        storage_account_type = "Standard_LRS"
        create_option = "Empty"
        disk_size_gb = "50"
}




resource "azurerm_virtual_machine" "tfprodgs" {
        name = "tfprodgsvm"
        location = "west us"
        resource_group_name = "${azurerm_resource_group.tfprodgs.name}"
        network_interface_ids = ["${azurerm_network_interface.tfprodgs.id}"]
        vm_size = "Standard_DS2"

        storage_image_reference {
                publisher = "Canonical"
                offer = "UbuntuServer"
                sku = "16.04-LTS"
                version = "latest"  
        }

        storage_os_disk {
                name = "tfsosdiskprod"
                caching = "ReadWrite"
                create_option = "FromImage"
                managed_disk_type = "Standard_LRS"
        }

        storage_data_disk {
                name = "tfproddata"
                managed_disk_type = "Standard_LRS"
                create_option = "Empty"
                lun = 0
                disk_size_gb = "20"
        }

        os_profile {
              computer_name = "tfprodgs"
              admin_username = "pb"
              admin_password = " Pikachu123456"  
        }

        os_profile_linux_config {
                disable_password_authentication = false
        }

        tags{
                environment = "demo"
        }




}       
