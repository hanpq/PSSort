function Use-IterativeMergeSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the iterative (bottom up) merge sort algorithm. Subarrays of
            increasing width are merged until the whole array is sorted, which avoids the recursion used by
            the classic merge sort implementation.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-IterativeMergeSort

            Sorts the array using iterative merge sort
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

            $leftPart = @($array[$left..$middle])
            $rightPart = @($array[($middle + 1)..$right])

            $i = 0
            $j = 0
            $k = $left

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

        $n = $Unsorted.Count

        # Merge subarrays of size 1, 2, 4, 8 ... until the width covers the whole array
        for ($width = 1; $width -lt $n; $width = $width * 2)
        {
            $script:Passes++
            for ($left = 0; $left -lt ($n - $width); $left = $left + (2 * $width))
            {
                $middle = $left + $width - 1
                $right = [math]::Min(($left + (2 * $width) - 1), ($n - 1))
                merge -array $Unsorted -left $left -middle $middle -right $right
            }
        }

        Write-Verbose ('IterativeMergeSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'IterativeMergeSort'
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
