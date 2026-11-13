function Test-SortingAlgorithms
{
    <#
        .DESCRIPTION
            A demo function to run all sort algorithms
        .PARAMETER ListSize
            Specifies how many values to generate for each sorting algorithm.
        .EXAMPLE
            Test-SortingAlgorithms

            Description of example
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'False positive')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Sole purpose of function is to run for all available functions in module.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', '', Justification = 'Only core is supported by the module')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Justification = 'This function calls module cmdlets from a list to simplyfy code. non-production')]
    [CmdletBinding()] # Enabled advanced function support
    param(
        $ListSize = 1000
    )

    begin
    {

        Write-Warning 'NOTE: The built in Sort-Object is a compiled cmdlet and will be much faster compared to script based implementations of sorting algoritms. A fair comparison can be made between all other script based algorithms'

        $List = 1..$ListSize | Get-Random -Count $ListSize

        # Use-StoogeSort is deliberately excluded, its O(n^2.71) complexity makes it unusable for this array size.
        # Use-RecursiveBubbleSort and Use-RecursiveInsertionSort are excluded since they recurse once per item
        # which exceeds the PowerShell call depth limit for an array of this size.
        $SortAlgorithms = @(
            'Use-QuickSort',
            'Use-IterativeQuickSort',
            'Use-ThreeWayQuickSort',
            'Use-QuickSortSinglyLinkedList',
            'Use-QuickSortDoublyLinkedList',
            'Use-BubbleSort',
            'Use-SelectionSort',
            'Use-InsertionSort',
            'Use-BinaryInsertionSort',
            'Use-MergeSort',
            'Use-MergeSortSinglyLinkedList',
            'Use-MergeSortDoublyLinkedList',
            'Use-IterativeMergeSort',
            'Use-ThreeWayMergeSort',
            'Use-TimSort',
            'Use-HeapSort',
            'Use-ShellSort',
            'Use-CombSort',
            'Use-CocktailSort',
            'Use-GnomeSort',
            'Use-OddEvenSort',
            'Use-CycleSort',
            'Use-PancakeSort',
            'Use-CountingSort',
            'Use-RadixSort',
            'Use-BucketSort',
            'Use-PigeonholeSort',
            'Use-StrandSort',
            'Use-BitonicSort',
            'Use-TagSort',
            'Use-TreeSort',
            'Use-CartesianTreeSort'
        )
    }

    process
    {
        $measure = Measure-Command -Expression {
            $SortObject = [string[]]$List | Sort-Object
        }
        [pscustomobject]@{
            Algorithm   = 'Built-in sort'
            ArrayLength = $List.count
            Passes      = 'Unknown'
            Swaps       = 'Unknown'
            Compares    = 'Unknown'
            Time        = $Measure.TotalMilliseconds
            Result      = $SortObject
        }

        foreach ($Object in $SortAlgorithms)
        {
            $measure = Measure-Command -Expression {
                $ReturnObject = Invoke-Expression -Command ('{0} | {1} -ReturnDiagnostics' -f (([string[]]$List) -join ','), $Object )
            }
            [pscustomobject]@{
                Algorithm   = $ReturnObject.Algorithm
                ArrayLength = $ReturnObject.ArrayLength
                Passes      = $ReturnObject.Passes
                Swaps       = $ReturnObject.Swaps
                Compares    = $ReturnObject.Compares
                Time        = $Measure.TotalMilliseconds
                Result      = $ReturnObject.SortedArray
            }
        }
    }
}
