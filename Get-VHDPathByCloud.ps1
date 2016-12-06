function Get-VHDPathByCloud {
param (
    [Parameter(Mandatory=$true)]
    [string]$CloudWildCard, 
    [Parameter(Mandatory=$true)]
    [string]$outFile
)
    [array]$AllVMs = $null
    $DiskLocation = @{}
    [array]$Clouds = Get-SCCloud -VMMServer dev-vmm |  where-object -filterscript {$_.Name -like $CloudWildCard} 
    foreach ($cloud in $Clouds)
    {
        [array]$AllVMs += Get-SCVirtualMachine -Cloud $cloud

    }
    foreach ($vm in $AllVMs)
    {
        $path = $vm.VirtualHardDisks | select -ExpandProperty sharepath
        $name = $vm.Name
        $DiskLocation.Add($vm.Name, $path)
    }
    $DiskLocation| Format-list | Out-File $outFile 
}
Get-VHDPathByCloud -CloudWildCard 'EDI*' -outFile C:\EDI_Disks.log