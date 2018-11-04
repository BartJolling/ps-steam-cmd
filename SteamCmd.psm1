Using module .\VdfDeserializer.psm1;

Class SteamCmd
{
    hidden [ValidateNotNull()][System.IO.DirectoryInfo]$_SteamcmdFolder;

    <#
        .SYNOPSIS
            Constructor for SteamCmd class

        .DESCRIPTION
            Creates a new instance of the SteamCmd class.

        .PARAMETER SteamcmdFolder 
            Points to folder where steamcmd.exe is installed

        .PARAMETER Force
            Allows the class to download and install steamcmd.exe in the SteamcmdFolder, if missing.

        .NOTES
            The constructor verifies that either steamdcmd.exe is available in the folder. 
            In case it is not available, it should be allowed to -Force the installation or it will throw an exception. 
            The constructor itself will never install steamcmd.exe itself.
    #>
    SteamCmd([System.IO.DirectoryInfo]$SteamcmdFolder, [boolean]$Force)
    {
        $SteamcmdExe = Join-Path -Path $SteamcmdFolder -ChildPath "steamcmd.exe";

        # Remember location if steamcmd.exe exists or can be forced to install
        if( (Test-Path $SteamcmdExe -PathType Leaf) -or $Force )  {
            $this._SteamcmdFolder = $SteamcmdFolder; 
        } else {
            throw "Could not find " + $SteamcmdExe;
        }
    }

    <#
        .SYNOPSIS
            Returns the path to steamcmd.exe 

        .DESCRIPTION
            Returns the path to steamcmd.exe. If steamcmd isn't already installed, it will download it from steam

        .NOTES
            If steamcmd.exe is found, the function returns its the full path. 
            If not found, it will try to download it into the folder that was specified in the constructor
    #>
    [System.IO.FileInfo] GetSteamcmdExePath() 
    {
        $SteamcmdExe = Join-Path -Path  $this._SteamcmdFolder -ChildPath "steamcmd.exe";

        if( Test-Path $SteamcmdExe -PathType Leaf) {
            return $SteamcmdExe;
        }

        if( Test-Path $this._SteamcmdFolder -PathType Container ) {
            throw "Could not install steamcmd.exe in " + $this._SteamcmdFolder + ". The specified folder already exists.";
        }

        $tmpFile = [System.IO.Path]::GetTempPath() + "steamcmd.zip";
        Invoke-WebRequest -Uri https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip -OutFile $tmpFile;

        try {            
            Expand-Archive -Path $tmpFile -DestinationPath $this._SteamcmdFolder.FullName -Force;
        }
        catch {
            Remove-Item -Path $this._SteamcmdFolder.FullName -Confirm:$False;
            Throw "Could not unzip " + $tmpFile + " into " + $this._SteamcmdFolder.FullName;
        }
        finally {
            Remove-Item -Path $tmpFile -Confirm:$False;
        }

        if( Test-Path $SteamcmdExe -PathType Leaf) {
            return $SteamcmdExe;
        }

        throw "Could not find " + $SteamcmdExe;
    }    

    <#
        .SYNOPSIS
            Retrieves the app_info for the provided application id

        .DESCRIPTION
            Executes steamcmd.exe +app_info_print and returns the parsed VDF as a Hashtable
    #>
    [PSCustomObject] GetSteamAppInfo([string] $appId) {
        if([string]::IsNullOrWhiteSpace($appId)) {
            throw 'Missing value for parameter $appId';
        }

        $tmpFile = [System.IO.Path]::GetTempFileName();
        [string]$steamCmd = $this.GetSteamcmdExePath().FullName + " +login anonymous +app_info_update 1 +app_info_print `"" + $appId + "`" +app_info_print `"" + $appId + "`" +quit > " + $tmpFile;
        
        Invoke-Expression -Command $steamCmd;
        $appInfoContent = Get-Content -Path $tmpFile -Raw;
        $appInfoContent = $this.CleanAppInfoPrint($appId, $appInfoContent);
        Remove-Item -Path $tmpFile;

        $vdf = [VdfDeserializer]::new();
        $appInfo = $vdf.Deserialize($appInfoContent);
        return $appInfo;
    }

    [string] CleanAppInfoPrint([string] $appId, [string] $rawAppInfo) {

        if([string]::IsNullOrWhiteSpace($appId)) {
            throw 'Missing value for parameter $appId';
        }

        if([string]::IsNullOrWhiteSpace($rawAppInfo)) {
            throw 'Missing value for parameter `$rawAppInfo';
        }

        [bool] $doCopy = $false;
        [string] $match = 'AppID : ' + $appId;
        [string[]]$lines = $rawAppInfo -split "`r`n";

        [System.Text.StringBuilder]$sb = [System.Text.StringBuilder]::new();

        foreach($line in $lines) {
            if($line.StartsWith($match) ){
                $doCopy = !$doCopy
            } elseif($doCopy) {
                $sb.AppendLine($line);
            } elseif ($sb.Length -gt 0) {
                return $sb.ToString();
            }
        }
        return $null;
    }
} ## Class SteamCmd