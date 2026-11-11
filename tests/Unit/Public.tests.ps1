BeforeAll {
    $projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
    $project = & (Join-Path $projectRoot 'scripts\Get-BuildProject.ps1') -ProjectRoot $projectRoot
    $ProjectName = $project.Name
    Import-Module $ProjectName -Force -ErrorAction Stop
}

BeforeDiscovery {
    $sortCases = @(
        @{ Scenario = 'a single item'; Values = @(7); Expected = @(7) }
        @{ Scenario = 'two reversed items'; Values = @(2, 1); Expected = @(1, 2) }
        @{ Scenario = 'sorted input'; Values = @(0, 1, 2, 3, 4); Expected = @(0, 1, 2, 3, 4) }
        @{ Scenario = 'reversed input'; Values = @(5, 4, 3, 2, 1, 0); Expected = @(0, 1, 2, 3, 4, 5) }
        @{ Scenario = 'an odd-length input'; Values = @(4, 1, 6, 0, 3, 5, 2); Expected = @(0, 1, 2, 3, 4, 5, 6) }
        @{ Scenario = 'duplicates'; Values = @(3, 1, 3, 0, 1, 2, 3); Expected = @(0, 1, 1, 2, 3, 3, 3) }
        @{ Scenario = 'equal items'; Values = @(2, 2, 2, 2); Expected = @(2, 2, 2, 2) }
        @{ Scenario = 'only zeros'; Values = @(0, 0, 0); Expected = @(0, 0, 0) }
        @{ Scenario = 'multiple digit positions'; Values = @(170, 45, 75, 90, 802, 24, 2, 66); Expected = @(2, 24, 45, 66, 75, 90, 170, 802) }
    )

    $sortingTests = {
        It 'sorts <Scenario> through the pipeline' -ForEach $sortCases {
            $actual = @($Values | & $CommandName -ErrorAction Stop)

            $actual.Count | Should -Be $Expected.Count
            $actual | Should -Be $Expected
        }

        It 'sorts <Scenario> passed directly without changing the caller array' -ForEach $sortCases {
            $original = $Values.Clone()
            $actual = @(& $CommandName -InputObject $Values -ErrorAction Stop)

            $actual | Should -Be $Expected
            $Values | Should -Be $original
        }

        It 'returns diagnostics and sorted values for <Scenario>' -ForEach $sortCases {
            $results = @($Values | & $CommandName -ReturnDiagnostics -ErrorAction Stop)

            $results.Count | Should -Be 1
            $diagnostics = $results[0]
            $diagnostics | Should -BeOfType [pscustomobject]
            @($diagnostics.PSObject.Properties.Name) | Should -Be @(
                'Algorithm', 'ArrayLength', 'Passes', 'Swaps', 'Compares', 'SortedArray'
            )
            $expectedAlgorithm = if ($CommandName -eq 'Use-BubbleSort') { 'BubblesSort' } else { $CommandName.Substring(4) }
            $diagnostics.Algorithm | Should -BeExactly $expectedAlgorithm
            $diagnostics.ArrayLength | Should -Be $Values.Count
            @($diagnostics.SortedArray) | Should -Be $Expected
            $diagnostics.Swaps | Should -BeGreaterOrEqual 0
            $diagnostics.Compares | Should -BeGreaterOrEqual 0
            if ($CommandName -in @('Use-QuickSort', 'Use-SelectionSort', 'Use-GnomeSort'))
            {
                $diagnostics.Passes | Should -BeExactly 'N/A'
            }
            else
            {
                $diagnostics.Passes | Should -BeGreaterOrEqual 0
            }
        }

        It 'resets diagnostic counters between calls' {
            $first = 3, 1, 2 | & $CommandName -ReturnDiagnostics
            $null = 9, 8, 7, 6, 5, 4 | & $CommandName -ReturnDiagnostics
            $second = 3, 1, 2 | & $CommandName -ReturnDiagnostics

            $second.Passes | Should -Be $first.Passes
            $second.Swaps | Should -Be $first.Swaps
            $second.Compares | Should -Be $first.Compares
            @($second.SortedArray) | Should -Be @(1, 2, 3)
        }

        It 'rejects null input' {
            { & $CommandName -InputObject $null -ErrorAction Stop } | Should -Throw
        }

        if ($CommandName -ne 'Use-RadixSort')
        {
            It 'sorts negative values and zero' {
                $actual = @(-3, 2, 0, -1, 2, -3 | & $CommandName -ErrorAction Stop)

                $actual | Should -Be @(-3, -3, -1, 0, 2, 2)
            }
        }

        if ($CommandName -notin @('Use-CountingSort', 'Use-RadixSort', 'Use-PigeonholeSort'))
        {
            It 'sorts fractional values without rounding' {
                $actual = @(0.25, -2.5, 3.75, 0.25, -0.5 | & $CommandName -ErrorAction Stop)

                $actual | Should -Be @(-2.5, -0.5, 0.25, 0.25, 3.75)
            }
        }

        if ($CommandName -notin @('Use-CountingSort', 'Use-RadixSort', 'Use-PigeonholeSort', 'Use-BucketSort'))
        {
            It 'sorts strings while retaining duplicates' {
                $actual = @('pear', 'apple', 'orange', 'apple', 'banana' | & $CommandName -ErrorAction Stop)

                $actual | Should -Be @('apple', 'apple', 'banana', 'orange', 'pear')
            }
        }

        if ($CommandName -in @('Use-CountingSort', 'Use-RadixSort', 'Use-PigeonholeSort'))
        {
            It 'reports item writes rather than comparisons' {
                $diagnostics = 3, 1, 2 | & $CommandName -ReturnDiagnostics

                $diagnostics.Compares | Should -Be 0
                $diagnostics.Swaps | Should -Be 6
                $expectedPasses = if ($CommandName -eq 'Use-RadixSort') { 1 } else { 2 }
                $diagnostics.Passes | Should -Be $expectedPasses
            }
        }

        if ($CommandName -eq 'Use-RadixSort')
        {
            It 'rejects negative integers' {
                { 1, -1, 0 | & $CommandName -ErrorAction Stop } |
                    Should -Throw '*only supports non negative integers*'
            }

            It 'sorts the largest supported integer without overflowing the digit exponent' {
                $actual = @(2147483647, 0, 10, 2147483646 | & $CommandName -ErrorAction Stop)

                $actual | Should -Be @(0, 10, 2147483646, 2147483647)
            }
        }

        if ($CommandName -eq 'Use-BucketSort')
        {
            It 'sorts with <BucketCount> buckets' -ForEach @(
                @{ BucketCount = 1 }
                @{ BucketCount = 2 }
                @{ BucketCount = 10 }
                @{ BucketCount = 0 }
                @{ BucketCount = -1 }
            ) {
                $actual = @(2.5, -1.5, 0.25, 2.5, -0.5 |
                        & $CommandName -BucketCount $BucketCount -ErrorAction Stop)

                $actual | Should -Be @(-1.5, -0.5, 0.25, 2.5, 2.5)
            }
        }
    }
}

Describe 'Use-BinaryInsertionSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-BinaryInsertionSort' } -Fixture $sortingTests
Describe 'Use-BubbleSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-BubbleSort' } -Fixture $sortingTests
Describe 'Use-BucketSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-BucketSort' } -Fixture $sortingTests
Describe 'Use-CocktailSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-CocktailSort' } -Fixture $sortingTests
Describe 'Use-CombSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-CombSort' } -Fixture $sortingTests
Describe 'Use-CountingSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-CountingSort' } -Fixture $sortingTests
Describe 'Use-CycleSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-CycleSort' } -Fixture $sortingTests
Describe 'Use-GnomeSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-GnomeSort' } -Fixture $sortingTests
Describe 'Use-HeapSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-HeapSort' } -Fixture $sortingTests
Describe 'Use-InsertionSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-InsertionSort' } -Fixture $sortingTests
Describe 'Use-IterativeMergeSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-IterativeMergeSort' } -Fixture $sortingTests
Describe 'Use-IterativeQuickSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-IterativeQuickSort' } -Fixture $sortingTests
Describe 'Use-MergeSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-MergeSort' } -Fixture $sortingTests
Describe 'Use-OddEvenSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-OddEvenSort' } -Fixture $sortingTests
Describe 'Use-PancakeSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-PancakeSort' } -Fixture $sortingTests
Describe 'Use-PigeonholeSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-PigeonholeSort' } -Fixture $sortingTests
Describe 'Use-QuickSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-QuickSort' } -Fixture $sortingTests
Describe 'Use-RadixSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-RadixSort' } -Fixture $sortingTests
Describe 'Use-RecursiveBubbleSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-RecursiveBubbleSort' } -Fixture $sortingTests
Describe 'Use-RecursiveInsertionSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-RecursiveInsertionSort' } -Fixture $sortingTests
Describe 'Use-SelectionSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-SelectionSort' } -Fixture $sortingTests
Describe 'Use-ShellSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-ShellSort' } -Fixture $sortingTests
Describe 'Use-StoogeSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-StoogeSort' } -Fixture $sortingTests
Describe 'Use-ThreeWayQuickSort' -Tag 'Unit' -ForEach @{ CommandName = 'Use-ThreeWayQuickSort' } -Fixture $sortingTests

Describe 'Test-SortingAlgorithms' -Tag 'Unit' {
    BeforeAll {
        Mock Get-Random -ModuleName $ProjectName {
            if ($InputObject -eq 500)
            {
                3, 1, 2
            }
        }
    }

    It 'returns the built-in result and all selected algorithm results' {
        $warnings = @()
        $results = @(Test-SortingAlgorithms -WarningAction SilentlyContinue -WarningVariable warnings)

        $warnings.Count | Should -Be 1
        $warnings[0].Message | Should -Match 'Sort-Object'
        $results.Count | Should -Be 24
        @($results.Algorithm | Select-Object -Unique).Count | Should -Be 24
        $results[0].Algorithm | Should -BeExactly 'Built-in sort'
        $results.Algorithm | Should -Not -Contain 'StoogeSort'
        foreach ($result in $results)
        {
            @($result.PSObject.Properties.Name) | Should -Be @(
                'Algorithm', 'ArrayLength', 'Passes', 'Swaps', 'Compares', 'Time', 'Result'
            )
            $result.ArrayLength | Should -Be 3
            @($result.Result) | Should -Be @(1, 2, 3)
            $result.Time | Should -BeGreaterOrEqual 0
        }
        Should -Invoke Get-Random -ModuleName $ProjectName -Exactly 500 -Scope It -ParameterFilter { $Count -eq 500 }
    }
}
