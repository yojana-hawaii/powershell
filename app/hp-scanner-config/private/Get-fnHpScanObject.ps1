function Get-fnHpScanObject {

    $hpScanConfig  = Get-fnHpScannerConfig 
    return @{
        srcUserDirPrefix="\\"
        srcUserDirSuffix="\c$\users\"
        srcUserDir=""
        srcCompName=""

        excludeProfiles = ("$($hpScanConfig.excludeProfiles)"  -replace '"',"") -split(";")

        srcHpPath="\AppData\Local\HP"
        srcHpAltPath="\HP Scan"
        srcHpS3="\HP ScanJet Pro 3000 s3\"
        srcHpS4="\HP ScanJet Pro 3000 s4\"

        scanner_profile_name="ID/Insurance"
        default_username="newUser"

        src = ""
        dst = ""
        s3_src_ini_file=$hpScanConfig.s3fileLocation  -replace '"',""
        s4_src_ini_file=$hpScanConfig.s4FileLocation  -replace '"',""

        s3_modified_date = ""
        s4_modified_date = ""
        src_modified_date = ""

        currentUser = ""
    }
}