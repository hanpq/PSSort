function Use-MergeSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the recursive (top down) merge sort algorithm. The array is
            divided into two halves which are sorted individually and then merged back together.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-MergeSort

            Sorts the array using merge sort
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
        # Merge sort does not swap items, the swap counter is used to count item writes back into the array
        $script:Swaps = 0
        $script:Compares = 0
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

        function merge
        {
            param(
                $array,
                $left,
                $middle,
                $right
            )

            # Copy both halves into temporary arrays
            $leftPart = @($array[$left..$middle])
            $rightPart = @($array[($middle + 1)..$right])

            $i = 0
            $j = 0
            $k = $left

            # Repeatedly pick the smallest of the two heads
            while (($i -lt $leftPart.Count) -and ($j -lt $rightPart.Count))
            {
                $script:Compares++
                if ($leftPart[$i] -le $rightPart[$j])
                {
                    $array[$k] = $leftPart[$i]
                    $i++
                }
                else
                {
                    $array[$k] = $rightPart[$j]
                    $j++
                }
                $script:Swaps++
                $k++
            }

            # Copy any remaining items
            while ($i -lt $leftPart.Count)
            {
                $array[$k] = $leftPart[$i]
                $script:Swaps++
                $i++
                $k++
            }
            while ($j -lt $rightPart.Count)
            {
                $array[$k] = $rightPart[$j]
                $script:Swaps++
                $j++
                $k++
            }
        }

        function mergeSort
        {
            param(
                $array,
                $left,
                $right
            )

            if ($left -lt $right)
            {
                $script:Passes++
                $middle = [int][math]::Floor(($left + $right) / 2)
                mergeSort -array $array -left $left -right $middle
                mergeSort -array $array -left ($middle + 1) -right $right
                merge -array $array -left $left -middle $middle -right $right
            }
        }

        if ($Unsorted.Count -gt 1)
        {
            mergeSort -array $Unsorted -left 0 -right ($Unsorted.Count - 1)
        }

        Write-Verbose ('MergeSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'MergeSort'
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
