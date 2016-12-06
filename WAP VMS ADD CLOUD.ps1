$SCVMMSERVER = Get-SCVMMServer -ComputerName dev-vmm -ForOnBehalfOf

function Set-RoleAndCloud ($Description, $CloudPath, $UserName = $null,$CloudName = $null, $VMName = $null, $ExceptVMTag = $null) {
$SCVMMSERVER = Get-SCVMMServer -ComputerName dev-vmm -ForOnBehalfOf
[array]$AllVMs = $null
$Cloud = Get-SCCloud -VMMServer dev-vmm |  where-object -filterscript {$_.Name -eq "$CloudName"}
$Cloud
Write-Host "Группы хостов определены:" -f Green

if ($VMName -ne $null) {
    foreach ($PathName in $CloudPath) {[array]$AllVMs += Get-SCVirtualMachine -Name $VMName  | where-object -filterscript {($_.Description -match "$Description")}}
    }else{
        foreach ($PathName in $CloudPath) {[array]$AllVMs += Get-SCVirtualMachine  | where-object -filterscript {($_.Description -match "$Description")}}
}

Write-Host "Виртуальные машины определены:" -f Green
$AllVMs.name

$UserName
if ($UserName -ne $null) {
    $RoleList = Get-SCUserRole | where-object -filterscript {(($_.Name -match $UserName))}
    $RoleList.Name
    }else{
    $RoleList = Get-SCUserRole | where-object -filterscript {(($_.Profile -match "tenant") -and ($_.cloud -match "$CloudName"))}
    $RoleList.Name
}

foreach ($Role in $RoleList) {
$UserName = $Role.Name
$UserName
$RoleNameID = $Role.ID

    foreach ($VM in $AllVMs) {
    $GrantList = $null
    $GrantList = (($VM).Owner) | Where-Object -FilterScript {$_ -eq $UserName}
    $VMName = $VM.name


    if ($VM.Tag -ne $ExceptVMTag) {
        if ($VM.Cloud -eq $null) {
            write-host "Назначаю облако '$Cloud' на $VM ..."
            Set-SCVirtualMachine -VM $VM -Cloud $Cloud
            }else{ write-host "Облако уже назначено!"}
        if ($VM.Cloud -eq $Cloud){
            if ($UserName -ne $null) {
                if (!($GrantList)) {
                    write-host "Назначаю роль $UserName на $VM ..."
                    Set-SCVirtualMachine -VM $VMName -UserRole $Role
                    Set-SCVirtualMachine -VM $VMName  -OnBehalfOfUser $Role -OnBehalfOfUserRole $Role -Owner $UserName
                    }else{write-host "Роль уже назначена!"}
            }
        }else{echo "Cloud jopa"}
    }else{
        write-host  "ВМ $VMName в списке исключений!!!" -f Yellow
        $CheckGrant = $null
        $CheckGrant = Get-SCVirtualMachine $VMName | Where-Object -FilterScript {$_.GrantedToList -match $UserName}
        if ($CheckGrant -ne $null) { 
        write-host "Права будут сняты с ВМ $VMName, так как она в списке исключений!!!" -f Yellow 
        Set-SCVirtualMachine -VM $VMName -OnBehalfOfUser $null -OnBehalfOfUserRole $null -Owner $null
        }     
    }
    }
}
}

$cats = (Get-SCVirtualMachine | ? name -like elba-37*).Name
foreach ($cat in $cats) { 
Set-RoleAndCloud -CloudName "elba-Standard-Testing" -CloudPath "Clusters" -UserName "elba-standard-testing" -VMName $cat
}

#$cat = (Get-SCVirtualMachine | ? name -like lightCat).Name

#Set-RoleAndCloud -CloudName "EDI-Standard-Testing" -CloudPath "Clusters" -UserName "EDI-Standard-Testing" -VMName $cat
