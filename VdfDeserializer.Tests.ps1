Using module .\VdfDeserializer.psm1;

Describe 'VdfDeserializer::Deserialize' {

    BeforeEach {
        $vdf = [VdfDeserializer]::new();
    }

    Context ': Given $null as argument' {
        It 'should throw an exception' {            
            { $vdf.Deserialize($null) } | Should Throw;
        }
    }

    Context ': Given an empty [string]' {
        It 'should throw an exception' {
            { $vdf.Deserialize("") } | Should Throw;
        }
    }

    Context ': Given a valid vdf as [string]' {
        It 'should return a valid object' {
            $vdfContent = Get-Content -Path ./vdf-test-files/basic.vdf -Raw;
            $result = $vdf.Deserialize($vdfContent);

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
            $result = $vdf.Deserialize($reader);
            
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
}