function Use-ThreeWayQuickSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the 3-way quick sort algorithm, also known as the Dutch
            national flag partitioning. The array is partitioned into three parts, items less than the
            pivot, items equal to the pivot and items greater than the pivot. This makes the algorithm
            efficient on arrays containing many duplicate values.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-ThreeWayQuickSort

            Sorts the array using 3-way quick sort
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object, therefor the verb sort is used')]
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
        # Counts the number of partitioning operations
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

        function threeWayQuickSort
        {
            param(
                $array,
                $low,
                $high
            )

            if ($low -ge $high)
            {
                return
            }

            $script:Passes++

            $pivot = $array[$low]
            $lt = $low
            $gt = $high
            $i = $low

            # Move all items smaller than the pivot to the left and all larger items to the right
            while ($i -le $gt)
            {
                $script:Compares++
                if ($array[$i] -lt $pivot)
                {
                    swap -array $array -position $lt -with $i
                    $lt++
                    $i++
                }
                elseif ($array[$i] -gt $pivot)
                {
                    swap -array $array -position $i -with $gt
                    $gt--
                }
                else
                {
                    $i++
                }
            }

            # Items between $lt and $gt are equal to the pivot and are already in place
            threeWayQuickSort -array $array -low $low -high ($lt - 1)
            threeWayQuickSort -array $array -low ($gt + 1) -high $high
        }

        if ($Unsorted.Count -gt 1)
        {
            threeWayQuickSort -array $Unsorted -low 0 -high ($Unsorted.Count - 1)
        }

        Write-Verbose ('ThreeWayQuickSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'ThreeWayQuickSort'
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
