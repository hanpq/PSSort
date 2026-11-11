function Use-HeapSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the heap sort algorithm. The array is first turned into a max
            heap, then the root (largest item) is repeatedly swapped to the end of the array and the heap
            property is restored for the remaining items.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-HeapSort

            Sorts the array using heap sort
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
        # Counts the number of heapify operations
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

        function heapify
        {
            param(
                $array,
                $heapSize,
                $root
            )

            $script:Passes++

            $largest = $root
            $left = (2 * $root) + 1
            $right = (2 * $root) + 2

            if ($left -lt $heapSize)
            {
                $script:Compares++
                if ($array[$left] -gt $array[$largest])
                {
                    $largest = $left
                }
            }

            if ($right -lt $heapSize)
            {
                $script:Compares++
                if ($array[$right] -gt $array[$largest])
                {
                    $largest = $right
                }
            }

            # If a child was larger, swap it with the root and restore the heap below
            if ($largest -ne $root)
            {
                swap -array $array -position $root -with $largest
                heapify -array $array -heapSize $heapSize -root $largest
            }
        }

        $n = $Unsorted.Count

        # Build a max heap
        for ($i = [int][math]::Floor($n / 2) - 1; $i -ge 0; $i--)
        {
            heapify -array $Unsorted -heapSize $n -root $i
        }

        # Extract items from the heap one by one
        for ($i = $n - 1; $i -gt 0; $i--)
        {
            swap -array $Unsorted -position 0 -with $i
            heapify -array $Unsorted -heapSize $i -root 0
        }

        Write-Verbose ('HeapSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'HeapSort'
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
