#Requires -Modules "ActiveDirectory"

function Get-ADUserUA
{
    Param(
        [Parameter(Mandatory, ParameterSetName="Filter")]
        [string]
        $Filter,

        [Parameter(Mandatory, ParameterSetName="Identity", Position=0)]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Identity,
        
        [Parameter(Mandatory, ParameterSetName="LDAPFilter")]
        [string]
        $LDAPFilter,

        [hashtable]
        $GetADUserParams = @{}
    )

    $GetADUserParams["-Properties"] = "*"

    if ($Filter) { $GetADUserParams["-Filter"] = $Filter }
    if ($Identity) { $GetADUserParams["-Identity"] = $Identity }
    if ($LDAPFilter) { $GetADUserParams["-LDAPFilter"] = $LDAPFilter }

    Get-ADUser @GetADUserParams | Select-Object -Property "SamAccountName","uidNumber","gidNumber","Name","unixHomeDirectory","Loginshell"
}

function Get-ADGroupUA
{
    Param(
        [Parameter(Mandatory, ParameterSetName="Filter")]
        [string]
        $Filter,

        [Parameter(Mandatory, ParameterSetName="Identity", Position=0)]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Identity,
        
        [Parameter(Mandatory, ParameterSetName="LDAPFilter")]
        [string]
        $LDAPFilter,

        [hashtable]
        $GetADGroupParams = @{}
    )

    $GetADGroupParams["-Properties"] = "*"

    if ($Filter) { $GetADGroupParams["-Filter"] = $Filter }
    if ($Identity) { $GetADGroupParams["-Identity"] = $Identity }
    if ($LDAPFilter) { $GetADGroupParams["-LDAPFilter"] = $LDAPFilter }

    Get-ADGroup @GetADGroupParams | Select-Object -Property "SamAccountName","gidNumber"
}

function Set-ADUserUA
{
    Param(
        [Parameter(Mandatory, ParameterSetName="Identity", Position=0)]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Identity,
        
        [int]
        $uidNumber,
        
        [int]
        $gidNumber,
        
        [string]
        $unixHomeDirectory,        
        
        [string]
        $Loginshell,

        [hashtable]
        $SetADUserParams = @{}
    )

    $Attributes = @{}

    if ($uidNumber) { $Attributes["uidNumber"] = $uidNumber }
    if ($gidNumber) { $Attributes["gidNumber"] = $gidNumber }
    if ($unixHomeDirectory) { $Attributes["unixHomeDirectory"] = $unixHomeDirectory }
    if ($Loginshell) { $Attributes["Loginshell"] = $Loginshell }
    
    Set-ADUser -Identity $Identity -Replace $Attributes @SetADUserParams
}

function Set-ADGroupUA
{
    Param(
        [Parameter(Mandatory, ParameterSetName="Identity", Position=0)]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Identity,       
        
        [int]
        $gidNumber,       

        [hashtable]
        $SetADGroupParams = @{}
    )

    $Attributes = @{"gidNumber"=$gidNumber}

    Set-ADGroup -Identity $Identity -Replace $Attributes @SetADGroupParams
}
