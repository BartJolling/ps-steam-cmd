# ps-steam-cmd
Powershell wrapper around Valve's SteamCmd utility.

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
