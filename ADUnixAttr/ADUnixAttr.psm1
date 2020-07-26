#Requires -Modules "ActiveDirectory"

function Get-ADUserUA
{
    [CmdletBinding(DefaultParameterSetName="Identity")]
    
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
    [CmdletBinding(DefaultParameterSetName="Identity")]
    
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
        [Parameter(Mandatory, Position=0)]
        [Microsoft.ActiveDirectory.Management.ADUser]
        $Identity,
        
        [Parameter(ParameterSetName="SetAttr")]
        [int]
        $uidNumber,
        
        [Parameter(ParameterSetName="SetAttr")]
        [string]
        $gidNumber,
        
        [Parameter(ParameterSetName="SetAttr")]
        [string]
        $unixHomeDirectory,        
        
        [Parameter(ParameterSetName="SetAttr")]
        [string]
        $Loginshell,

        [Parameter(ParameterSetName="SetAttr")]
        [hashtable]
        $SetADUserParams = @{},

        [Parameter(ParameterSetName="Clear")]
        [switch]
        $Clear = $false
    )

    if ($Clear)
    {
        Set-ADUser -Identity $Identity -Clear "uidNumber","gidNumber","unixHomeDirectory","LoginShell"
        return
    }

    $Attributes = @{}

    if ($uidNumber)
    {
        # verify uidNumber is not already in use
        if (Get-ADUserUA -Filter * | where { $_.uidNumber -eq $uidNumber })
        {
            $takenuser = (Get-ADUserUA -Filter * | where { $_.uidNumber -eq $uidNumber }).SamAccountName
            throw "uidNumber $uidNumber already belongs to user $takenuser"
        }
        else
        {
            $Attributes["uidNumber"] = $uidNumber
        }
    }
    
    if ($gidNumber)
    {
        # check if gidNumber is a positive integer and set normally, otherwise treat as group name
        if ($gidNumber -match "^\d+$")
        {
            $Attributes["gidNumber"] = $gidNumber
        }
        else
        {
            # check if the group exists, error if not
            $group = Get-ADGroupUA -Identity $gidNumber -ErrorAction Stop
            
            # check if the group has a gidNumber, error if not
            if ( -not ($group.gidNumber)) { throw "Group $($group.SamAccountName) has no gidNumber set" }
            $Attributes["gidNumber"] = $group.gidNumber
        }
    }
    
    if ($unixHomeDirectory) { $Attributes["unixHomeDirectory"] = $unixHomeDirectory }
    if ($Loginshell) { $Attributes["Loginshell"] = $Loginshell }
    
    Set-ADUser -Identity $Identity -Replace $Attributes @SetADUserParams
}

function Set-ADGroupUA
{
    Param(
        [Parameter(Mandatory, Position=0)]
        [Microsoft.ActiveDirectory.Management.ADGroup]
        $Identity,       
        
        [Parameter(ParameterSetName="SetAttr")]
        [int]
        $gidNumber,       

        [Parameter(ParameterSetName="SetAttr")]
        [hashtable]
        $SetADGroupParams = @{},

        [Parameter(ParameterSetName="Clear")]
        [switch]
        $Clear = $false
    )

    if ($Clear)
    {
        Set-ADGroup -Identity $Identity -Clear "gidNumber"
        return
    }

    $Attributes = @{}

    if ($gidNumber)
    {
        # verify gidNumber is not already in use
        if (Get-ADGroupUA -Filter * | where { $_.gidNumber -eq $gidNumber })
        {
            $takengroup = (Get-ADGroupUA -Filter * | where { $_.gidNumber -eq $gidNumber }).SamAccountName
            throw "gidNumber $gidNumber already belongs to group $takengroup"
        }
        else
        {
            $Attributes["gidNumber"] = $gidNumber
        }
    }

    Set-ADGroup -Identity $Identity -Replace $Attributes @SetADGroupParams
}
