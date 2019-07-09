Function Test-FileSystemAccess {
    <#
    .SYNOPSIS
    Check for read access on a given folder.
    .DESCRIPTION
    This is a very fast method of checking for read access on $Path by pulling access rules and comparing it to the ID to the user's context running this cricket.
    I can not take any credit for this function. Huge thanks to Patrick in WinAdmins Slack!
    Called by main body.
    .OUTPUTS
    System.Int32
    0 = ERROR_SUCCESS
    5 = ERROR_ACCESS_DENIED
    3 = ERROR_PATH_NOT_FOUND
    #>
    param
    (
        [string]$Path,
        [System.Security.AccessControl.FileSystemRights]$Rights
    )

    # Thanks to Patrick in Windows Admins slack

    [System.Security.Principal.WindowsIdentity]$currentIdentity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    [System.Security.Principal.WindowsPrincipal]$currentPrincipal = New-Object Security.Principal.WindowsPrincipal($currentIdentity)
    $IsElevated = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if ([System.IO.Directory]::Exists($Path))
    {
        try
        {
            [System.Security.AccessControl.FileSystemSecurity]$security = (Get-Item -Path ("FileSystem::{0}" -f $Path) -Force).GetAccessControl()
            if ($security -ne $null)
            {
                [System.Security.AccessControl.AuthorizationRuleCollection]$rules = $security.GetAccessRules($true, $true, [System.Security.Principal.SecurityIdentifier])
                for([int]$i = 0; $i -lt $rules.Count; $i++)
                {
                    if (($currentIdentity.Groups.Contains($rules[$i].IdentityReference)) -or ($currentIdentity.User -eq $rules[$i].IdentityReference))
                    {
                        [System.Security.AccessControl.FileSystemAccessRule]$fileSystemRule = [System.Security.AccessControl.FileSystemAccessRule]$rules[$i]
                        if ($fileSystemRule.FileSystemRights.HasFlag($Rights))
                        {
                            return 0
                        }
                    }
                }

                # If reached this point, then $Rights was not determined by enumerating the ACL
                # Unless the user is in Administrators group and Administrators group is delegated $Rights but process wasn't elevated to be able to find out

                # If process is not elevated and Administrators group has $AccessRights
                If (($IsElevated -eq $false) -And ($rules | Where-Object { ($_.IdentityReference -eq "S-1-5-32-544") -And ($_.FileSystemRights -eq $Rights)})) {
                    return 740
                }
                Else {
                    return 5
                }

            }
            else
            {
                return 5
            }
        }
        catch
        {
            return 5
        }
    }
    else
    {
        return 3
    }
}

Test-FileSystemAccess -Path "C:\Users\acc\Documents\New folder\1" -Rights FullControl