Import-Module VMware.VimAutomation.Core
connect-viserver < server name >
Get-Cluster "cluster1" | Get-VM | Select -ExpandProperty Name | Out-File C:\maintenance\cluster1.txt
Disconnect-VIServer     * -confirm:$false
