function New-DummyFolderStructure { 
    Param(
        [string]$Path,
        [int]$Long,
        [int]$Deep
    )
    For($LongCounter = 0; $LongCounter -lt $Long; $LongCounter++) {
        $Folder = ([guid]::NewGuid()).Guid
        $NewDir = New-Item -ItemType Directory -Path "$Path\$Folder"
        while ($Deep -gt 1) {
            $Folder = ([guid]::NewGuid()).Guid
            $NewDir = New-Item -ItemType Directory -Path "$NewDir\$Folder"
            $Deep--
        }
    }
}