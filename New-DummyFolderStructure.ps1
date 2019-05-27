function New-DummyFolderStructure { 
    Param(
        [string]$Path,
        [int]$Long
    )
    while ($Long -gt 0) {
        $Folder = ([guid]::NewGuid()).Guid
        Try {
            New-Item -ItemType Directory -Path "$Path\$Folder" | Out-Null
        }
        Catch {
            Write-Error "Unable to create $Path\$Folder"
        }
        $Long--
    }  
}