Function Connect-vCenter{
# Connect to vCenter
Import-Module VMware.VimAutomation.Core
connect-viserver < server name >
}
Function VM-Selection{
    $sourcename = "C:\maintenance\cluster1.txt"
         $list = Get-Content $sourcename | Foreach-Object {Get-VM $_ | Get-View | Where-Object {-not $_.config.template} | Select Name }
         $vms = $list
   return $vms
}
Function PowerOn-VM($vm){
   Start-VM -VM $vm -Confirm:$false -RunAsync | Out-Null
   Write-Host "$vm is starting!" -ForegroundColor Yellow
}
Function PowerOff-VM($vm){
   $vmview = Get-VM $vm | Get-View
   $toolsstatus = $vmview.Guest.ToolsStatus
   if (($toolsstatus -eq "toolsNotInstalled") -or ($toolsstatus -eq "toolsNotRunning")){
      Stop-VM -VM $vm -Confirm:$false | Out-Null}
    
   else{
      Shutdown-VMGuest -VM $vm -Confirm:$false | Out-Null
      Write-Host "$vm is stopping!" -ForegroundColor Yellow
      sleep 10
      $toolsstatus = $null
      $teller = 0
      while (($powerstate -ne "PoweredOff") -and ($teller -ne 11)){
          sleep 15
          $vmview = Get-VM $vm | Get-View
          $getvm = Get-VM $vm
          $powerstate = $getvm.PowerState
          $toolsstatus = $vmview.Guest.ToolsStatus
          Write-Host "$vm is stopping with powerstate $powerstate and toolsStatus $toolsstatus!" -ForegroundColor Yellow
          $teller ++
      }
       
   }
   $getvm = Get-VM $vm
   $powerstate = $getvm.PowerState
   write-host "This is" + $powerstate
   if($powerstate -eq "poweredoff"){
     return "ok"
   }
}
Function Check-VMHardwareVersion($vm){
   $vmView = get-VM $vm | Get-View
   $vmVersion = $vmView.Config.Version
   $v4 = "vmx-04"
   $v7 = "vmx-07"
   $v8 = "vmx-08"
   $v9 = "vmx-09"
   $v10 = "vmx-10"
   $v11 = "vmx-11"
   if ($vmVersion -eq $v4){
      $vmHardware = "Old"}
   elseif($vmVersion -eq $v7){
      $vmHardware = "Old"}
   elseif($vmVersion -eq $v8){
      $vmHardware = "Old"}
  elseif($vmVersion -eq $v9){
      $vmHardware = "Old"}
  elseif($vmVersion -eq $v10){
      $vmHardware = "Old"}
  elseif($vmVersion -eq $v11){
      $vmHardware = "Ok"}
   else{
      $vmHardware = "ERROR"
      [console]::ForegroundColor = "Red"
      Read-Host "The Hardware version is unknown This is unusual. Press <CTRL>+C to quit the script or press <ENTER> to continue"
      [console]::ResetColor()
   }
   return $vmHardware
}
Function Upgrade-VMHardware($vm){
   $vmview = Get-VM $vm | Get-View
   $vmVersion = $vmView.Config.Version
   $v4 = "vmx-04"
   $v7 = "vmx-07"
   $v8 = "vmx-08"
   $v9 = "vmx-09"
   $v10 = "vmx-10"
   $v11 = "vmx-11"
   if ($vmVersion -ne $v11){
      Write-Host "Old Version of hardware detected." -ForegroundColor Red
# Update Hardware
      Write-Host "Upgrading Hardware on" $vm -ForegroundColor Yellow
      Get-View ($vmView.UpgradeVM_Task($v11)) | Out-Null
   }
}
Function CheckAndUpgrade($vm){
   $vmHardware = Check-VMHardwareVersion $vm
   $getvm = Get-VM $vm
   $powerstate = $getvm.PowerState
  
        
    
   if(($vmHardware -ne "Ok") -and ($powerstate -eq "poweredon")){
       $PowerOffVM = PowerOff-VM $vm
               
       if($PowerOffVM -eq "OK"){
         Write-Host "Starting upgrade hardware level on $vm."
         Upgrade-VMHardware $vm
         sleep 5
         $PowerOnVM = PowerOn-VM $vm
         if($PowerOnVM -eq "OK"){
            Write-Host "$vm is up to date" -ForegroundColor Green}
       else{
            Write-Host "$vm is up to date" -ForegroundColor Green}
       }
   }
   if(($vmHardware -ne "Ok") -and ($powerstate -eq "poweredoff")){
        Upgrade-VMHardware $vm
   }
   if(($vmHardware -eq "Ok") -and ($powerstate -eq "poweredon")){
        $PowerOffVM = PowerOff-VM $vm
         
        if($PowerOffVM -eq "OK"){
         sleep 5
         $PowerOnVM = PowerOn-VM $vm
         if($PowerOnVM -eq "OK"){
            Write-Host "$vm is up to date" -ForegroundColor Green}
       else{
            Write-Host "$vm is up to date" -ForegroundColor Green}
       }
   }  
    
}
Connect-vCenter
$vms = VM-Selection
foreach($item in $vms){
   $vm = $item.Name
   Write-Host "Starting $vm"
   CheckAndUpgrade $vm
}
Disconnect-VIServer     * -confirm:$false
