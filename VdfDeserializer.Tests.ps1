Using module .\VdfDeserializer.psm1;

Describe 'VdfDeserializer::Deserialize' {

    [VdfDeserializer]$Script:vdf = $null;

    BeforeEach {
        $Script:vdf = [VdfDeserializer]::new();
    }

    Context ': Given $null as argument' {
        It 'should throw an exception' {
            { $Script:vdf.Deserialize($null) } | Should Throw;
        }
    }

    Context ': Given an empty [string]' {
        It 'should throw an exception' {
            { $Script:vdf.Deserialize("") } | Should Throw;
        }
    }

    Context ': Given a valid vdf as [string]' {
        It 'should return a valid object' {
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
            $result = $Script:vdf.Deserialize($vdfContent);

            $result | Should BeOfType [PSCustomObject];
            $result.basicvdf | Should Not Be $null;
            $result.basicvdf.foo | Should Not Be $null;
            $result.basicvdf.bar | Should Not Be $null;
            $result.basicvdf.foo.baz | Should Not Be $null;
            $result.basicvdf.foo.baz | Should Be "1";
            $result.basicvdf.bar.qux | Should Not Be $null;
            $result.basicvdf.bar.qux | Should Be "2";
        }
    }      

    Context ': Given a valid vdf as [string] from Get-Content' {
        It 'should return a valid object' {
            $vdfContent = Get-Content -Path ./vdf-test-files/basic.vdf -Raw;
            $result = $Script:vdf.Deserialize($vdfContent);

            $result | Should BeOfType [PSCustomObject];
            $result.basicvdf | Should Not Be $null;
            $result.basicvdf.foo | Should Not Be $null;
            $result.basicvdf.bar | Should Not Be $null;
            $result.basicvdf.foo.baz | Should Not Be $null;
            $result.basicvdf.foo.baz | Should Be "1";
            $result.basicvdf.bar.qux | Should Not Be $null;
            $result.basicvdf.bar.qux | Should Be "2";
        }
    }

    Context ': Given a [TextReader] based on a valid vdf' {
        It 'should return a valid object' {
            [System.IO.StreamReader] $reader = [System.IO.File]::OpenText('./vdf-test-files/basic.vdf');
            $result = $Script:vdf.Deserialize($reader);

            $result | Should BeOfType [PSCustomObject];
            $result.basicvdf | Should Not Be $null;
            $result.basicvdf.foo | Should Not Be $null;
            $result.basicvdf.bar | Should Not Be $null;
            $result.basicvdf.foo.baz | Should Not Be $null;
            $result.basicvdf.foo.baz | Should Be "1";
            $result.basicvdf.bar.qux | Should Not Be $null;
            $result.basicvdf.bar.qux | Should Be "2";

            if($reader) {
                $reader.Close();
            }
        }
    }

    Context ': Given a [TextReader] based on result of Steamcmd app_info_print' {
        It 'should return a valid object' {
            [System.IO.StreamReader] $reader = [System.IO.File]::OpenText('./vdf-test-files/appInfo258550.vdf');
            $result = $Script:vdf.Deserialize($reader);

            $result | Should BeOfType [PSCustomObject];
            $result.258550 | Should Not Be $null;
            $result.'258550'.common | Should Not Be $null;
            $result.'258550'.extended | Should Not Be $null;
            $result.'258550'.config | Should Not Be $null;
            $result.'258550'.depots | Should Not Be $null;
            $result.'258550'.depots.branches | Should Not Be $null;
            $result.'258550'.depots.branches.public | Should Not Be $null;

            if($reader) {
                $reader.Close();
            }
        }
    }    
}