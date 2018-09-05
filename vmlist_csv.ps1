
Import-Module VMware.VimAutomation.Core
connect-viserver < server name >
New-VIProperty -ObjectType VirtualMachine -Name Cluster -Value {$Args[0].VMHost.Parent} -Force
New-VIProperty -ObjectType VirtualMachine -Name ToolsStatus -ValueFromExtensionProperty 'Guest.ToolsStatus' -Force
Get-VM | Select-Object -Property Name,Cluster,GuestID,powerstate,ToolsStatus | export-csv C:\maintenance\test1.csv
Disconnect-VIServer     * -confirm:$false
