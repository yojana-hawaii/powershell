function Join-fnTwoOrderArray {
    [CmdletBinding()]
    param (
        [parameter()]
        [System.Array]$array1,
        [parameter()]
        [System.Array]$array2,
        [parameter()]
        [string]$type,
        [parameter()]
        [string]$array2_prefix    
    )

    Write-Verbose "$($MyInvocation.MyCommand.Name): Combine 2 grouped order array - $type $array2_prefix"
    # $array1
    # $array2
    if($null -eq $array1){
        Write-Information "$array1 is null"
        return $array2 | Select-Object @{Name="Dept"; expression={($_.Name)}}, @{Name="$array2_prefix-$type"; expression={$_.Count} } `
    }
    
    Write-Information "$($array1[0]) & $($array2[0]) is not null"
    return $array1 | Select-Object *, @{Name="$array2_prefix-$type"; expression={$tmp=$_.Dept; ($array2 | Where-Object name -eq $tmp).Count} }
   
}

