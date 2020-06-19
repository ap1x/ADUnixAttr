$GroupProps = "gidNumber","MemberUid"

function Get-ADUserUA
{
    Param(
        [Parameter(Mandatory, ParameterSetName="Filter")]
        [string]
        $Filter,

        [Parameter(Mandatory, ParameterSetName="Identity", Position=0)]
        [string]
        $Identity,
        
        [Parameter(Mandatory, ParameterSetName="LDAPFilter")]
        [string]
        $LDAPFilter,

        [hashtable]
        $GetADUserParams
    )

    $UserProps = "SamAccountName","uidNumber","gidNumber","Name","unixHomeDirectory","Loginshell"

    if ($Filter)
    {
        Get-ADUser -Filter $Filter -Properties * @GetADUserParams | Select-Object -Property $UserProps
    }
}

function Set-ADUserUA {}

function Get-ADGroupUA {}

function Set-ADGroupUA {}
