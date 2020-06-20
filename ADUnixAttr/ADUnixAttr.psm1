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

    if ($Filter) { $Users = Get-ADUser -Filter $Filter @GetADUserParams }
    if ($Identity) { $Users = Get-ADUser -Identity $Identity @GetADUserParams }
    if ($LDAPFilter) { $Users = Get-ADUser -LDAPFilter $LDAPFilter @GetADUserParams }

    $Users | Select-Object -Property "SamAccountName","uidNumber","gidNumber","Name","unixHomeDirectory","Loginshell"
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

    if ($Filter) { $Groups = Get-ADGroup -Filter $Filter @GetADGroupParams }
    if ($Identity) { $Groups = Get-ADGroup -Identity $Identity @GetADGroupParams }
    if ($LDAPFilter) { $Groups = Get-ADGroup -LDAPFilter $LDAPFilter @GetADGroupParams }

    $Groups | Select-Object -Property "SamAccountName","gidNumber"
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

    if ($uidNumber) { Set-ADUser -Identity $Identity -Replace @{"uidNumber"=$uidNumber} @SetADUserParams }
    if ($gidNumber) { Set-ADUser -Identity $Identity -Replace @{"gidNumber"=$gidNumber} @SetADUserParams }
    if ($unixHomeDirectory) { Set-ADUser -Identity $Identity -Replace @{"unixHomeDirectory"=$unixHomeDirectory} @SetADUserParams }
    if ($Loginshell) { Set-ADUser -Identity $Identity -Replace @{"Loginshell"=$Loginshell} @SetADUserParams }
}

function Set-ADGroupUA {}
