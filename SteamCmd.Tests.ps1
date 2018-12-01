Using module .\SteamCmd.psm1;

Describe 'SteamCmd' {

    $scriptFolder = Split-Path -Parent $PSCommandPath;
    $steamFolder = Join-Path $scriptFolder '\steamcmd\';

    BeforeEach {
        $Script:steamcmd = [SteamCmd]::new( $steamFolder, $true);
    };

    Context ': Constructor' {
        It 'set the installation folder for steamcmd' {
            $steamCmd._Steamcmdfolder.FullName | Should Be $steamFolder;
        }
    };

    Context ': GetSteamcmdExePath' {
        It 'returns a valid path to steamcmd.exe' {
            { 
                $steamcmdPath = $steamcmd.GetSteamcmdExePath() 
                Test-Path -Path $steamcmdPath | Should Be $true;
            } | Should Not Throw;            
        }        
    }
    
    Context ': CleanAppInfoPrint' {
        It 'extracts a valid vdf from the console output of steamcmd' {
            $appInfoContent = Get-Content -Path ./vdf-test-files/appInfoPrint258550.txt -Raw;
            $appInfoContent = $steamcmd.CleanAppInfoPrint("258550", $appInfoContent);
            
            $appInfoContent | Should Not BeNullOrEmpty;
        }                
    }

    Context ': GetSteamAppInfo' {
        It 'returns a hashtable containing app_info_print for Rust (258550)' {
            $rustAppInfo = $steamcmd.GetSteamAppInfo("258550");

            $rustAppInfo | Should Not Be $null;
        }        
    } 
};