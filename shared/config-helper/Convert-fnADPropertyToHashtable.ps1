

function Convert-fnADPropertyToHashtable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$adPropertyArray
    )

    $adPropertyHashtable = foreach($property in $adPropertyArray){
                                if($property -eq 'Manager' ){
                                    @{Name=$property; Expression=[ScriptBlock]::Create("(Get-AdUser `$_.$($property)).sAMAccountName")}
                                    break
                                } 
                                if($property -eq 'AccountExpires'){
                                    @{Name=$property; Expression=[ScriptBlock]::Create("[datetime]::FromFileTime(`$_.$($property))")}
                                    break
                                }
                                @{Name=$property; Expression=[ScriptBlock]::Create("`$_.$($property)")}
                                
                            }

    return $adPropertyHashtable
}