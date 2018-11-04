# ps-steam-cmd
Powershell wrapper around Valve's SteamCmd utility.

## SteamCmd
Wraps functionality of steamcmd.exe for easier use in Powershell

### Usage
The following script 
- imports the SteamCmd powershell module. 
- instantiates an instance of SteamCmd, pointing to the local folder where it can find or download steamcmd.exe.
- executes steamcmd.exe +app_info_print and returns the output as a custom Powershell object.

```ps1
Using module .\SteamCmd.psm1;

$Script:steamcmd = [SteamCmd]::new('.\steamcmd\', $true);
$rustAppInfo = $steamcmd.GetSteamAppInfo("258550");

ConvertTo-Json $rustAppInfo | Write-Host;
```

## VdfDeserializer
Parses Valve's VDF format and returns it as a PSCustomObject. This class has been translated to Powershell from [Shravan2x's Gameloop]( https://github.com/shravan2x/Gameloop.Vdf/blob/master/Gameloop.Vdf/VdfTextReader.cs) C# project

### Usage
```ps1
Using module .\VdfDeserializer.psm1;

$vdfContent = '
    "basicvdf" 
    { 
        "foo"
        {
            "baz" "1"
        }
        "bar" 
        {
            "qux" "2"
        }
    }'

$vdf = [VdfDeserializer]::new();    
$result = $vdf.Deserialize($vdfContent);

ConvertTo-Json $result | Write-Host ;
```
