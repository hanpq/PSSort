function Use-IterativeQuickSort
{
    <#
        .DESCRIPTION
            This function sorts objects using an iterative implementation of the quick sort algorithm. An
            explicit stack holds the subarray boundaries instead of relying on recursion.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-IterativeQuickSort

            Sorts the array using iterative quick sort
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object, therefor the verb sort is used')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Justification = 'False positive, get-partition is not implictly called. partition is a internal function')]
    [CmdletBinding()] # Enabled advanced function support
    [OutputType([collections.arraylist])]
    param(
        [parameter(ValueFromPipeline, Mandatory)]$InputObject,
        [parameter()][switch]$ReturnDiagnostics
    )

    BEGIN
    {
        $Unsorted = [collections.arraylist]::New()
        $script:Swaps = 0
        $script:Compares = 0
        # Counts the number of partitions processed from the stack
        $script:Passes = 0
    }

    PROCESS
    {
        $InputObject | ForEach-Object {
            $null = $Unsorted.Add($PSItem)
        }
    }

    END
    {
        # Determine default sort property
        if ($null -ne $Unsorted[0].PSStandardMembers.DefaultKeyPropertySet)
        {
            Write-Warning -Message 'This object has a default sorting specified'
        }

        function swap
        {
            param(
                $array,
                $position,
                $with
            )
            $temp = $array[$position]
            $array[$position] = $array[$with]
            $array[$with] = $temp
            $script:Swaps++
        }

        function partition
        {
            param(
                $array,
                $low,
                $high
            )
            $pivot = $array[$high]
            $i = $low - 1
            for ($j = $low; $j -lt $high; $j++)
            {
                $script:Compares++
                if ($array[$j] -lt $pivot)
                {
                    $i++
                    swap -array $array -position $i -with $j
                }
            }
            swap -array $array -position ($i + 1) -with $high
            return ($i + 1)
        }

        if ($Unsorted.Count -gt 1)
        {
            $stack = [collections.stack]::New()
            $stack.Push(@(0, ($Unsorted.Count - 1)))

            while ($stack.Count -gt 0)
            {
                $script:Passes++
                $range = $stack.Pop()
                $low = $range[0]
                $high = $range[1]

                $p = partition -array $Unsorted -low $low -high $high

                # Push the subarrays that still contain more than one item
                if (($p - 1) -gt $low)
                {
                    $stack.Push(@($low, ($p - 1)))
                }
                if (($p + 1) -lt $high)
                {
                    $stack.Push(@(($p + 1), $high))
                }
            }
        }

        Write-Verbose ('IterativeQuickSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'IterativeQuickSort'
                    ArrayLength = $Unsorted.Count
                    Passes      = $script:Passes
                    Swaps       = $script:Swaps
                    Compares    = $script:Compares
                    SortedArray = $Unsorted
                })
        }
        else
        {
            return $Unsorted
        }
    }
}
#endregion
