$rg="myreso"
$locat="Central India"
$vnet="myvnet"

New-AzResourceGroup -Name $rg -Location $locat 

$subnet = New-AzVirtualNetworkSubnetConfig -Name "subnet1" -AddressPrefix "10.0.0.0/24" 

$virtualnetwork = New-AzVirtualNetwork -Name $vnet -ResourceGroupName $rg -Location $locat -AddressPrefix "10.0.0.0/16" -Subnet $subnet

$pubic = New-AzPublicIpAddress -Name "mypubic" -ResourceGroupName $rg -Location $locat -AllocationMethod Static 

$virtualnetwork = Get-AzVirtualNetwork -Name $vnet -ResourceGroupName $rg

$subnet = Get-AzVirtualNetworkSubnetConfig -Name "subnet1" -VirtualNetwork $virtualnetwork

$nic = New-AzNetworkInterface -Name "mynic" -ResourceGroupName $rg -Location $locat -PublicIpAddress $pubic -Subnet $subnet -IpConfigurationName "ipconfig"

$ipconfig = Get-AzNetworkInterfaceIpConfig -NetworkInterface $nic

$nic | Set-AzNetworkInterfaceIpConfig -Name "ipconfig" -PublicIpAddress $pubic 

$nsgrule1 = New-AzNetworkSecurityRuleConfig -Name "allow-rdp" -Access Allow -Direction Inbound -Protocol Tcp `
-SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix "10.0.0.0/24" -DestinationPortRange "3389" -Priority "120"

$nsgrule2 = New-AzNetworkSecurityRuleConfig -Name "allow-http" -Access Allow -Direction Inbound -Protocol Tcp `
-SourceAddressPrefix Internet -SourcePortRange * -DestinationAddressPrefix "10.0.0.0/24" -DestinationPortRange "80" -Priority "130"

$nsg = New-AzNetworkSecurityGroup -Name "mynsg" -ResourceGroupName $rg -Location $locat -SecurityRules $nsgrule1,$nsgrule2

$virtualnetwork = Get-AzVirtualNetwork -Name $vnet -ResourceGroupName $rg

$subnet = Get-AzVirtualNetworkSubnetConfig -Name "subnet1" -VirtualNetwork $virtualnetwork

$subnet | Set-AzVirtualNetworkSubnetConfig -Name $subnet.Name -VirtualNetwork $virtualnetwork -NetworkSecurityGroup $nsg -AddressPrefix "10.0.0.0/24"

$virtualnetwork | Set-AzVirtualNetwork

$vmName="appvm"
$vmSize="Standard_DS2_v2"
$location="Central India"

$vmConfig=New-AzVMConfig -Name $vmName -VMSize $vmSize
$Credential=Get-Credential

Set-AzVMOperatingSystem -VM $vmConfig -Credential $Credential -Windows -ComputerName $vmName

Set-AzVMSourceImage -VM $vmConfig -PublisherName "MicrosoftWindowsServer" `
-Offer "WindowsServer" -Skus "2022-Datacenter" -Version "latest"

$networkInterfaceName="mynic"
$networkInterface=Get-AzNetworkInterface -Name "mynic" -ResourceGroupName $rg

$vm=Add-AzVMNetworkInterface -VM $vmConfig -Id $networkInterface.Id

New-AzVM -ResourceGroupName $rg -Location $locat -VM $vm


