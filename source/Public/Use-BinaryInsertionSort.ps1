function Use-BinaryInsertionSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the binary insertion sort algorithm. It is a variation of
            insertion sort where a binary search is used to locate the insertion point which reduces the
            number of comparisons to O(n log n) while the number of moves remains O(n^2).
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-BinaryInsertionSort

            Sorts the array using binary insertion sort
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object, therefor the verb sort is used')]
    [CmdletBinding()] # Enabled advanced function support
    [OutputType([collections.arraylist])]
    param(
        [parameter(ValueFromPipeline, Mandatory)]$InputObject,
        [parameter()][switch]$ReturnDiagnostics
    )

    begin
    {
        $Unsorted = [collections.arraylist]::New()
        $script:Swaps = 0
        $script:Compares = 0
        $script:Passes = 0
    }

    process
    {
        $InputObject | ForEach-Object {
            $null = $Unsorted.Add($PSItem)
        }
    }

    end
    {
        # Determine default sort property
        if ($null -ne $Unsorted[0].PSStandardMembers.DefaultKeyPropertySet)
        {
            Write-Warning -Message 'This object has a default sorting specified'
        }

        function binarySearch
        {
            param(
                $array,
                $item,
                $low,
                $high
            )

            while ($low -le $high)
            {
                $mid = [int][math]::Floor(($low + $high) / 2)
                $script:Compares++
                if ($item -lt $array[$mid])
                {
                    $high = $mid - 1
                }
                else
                {
                    $low = $mid + 1
                }
            }
            return $low
        }

        $n = $Unsorted.Count
        for ($i = 1; $i -lt $n; $i++)
        {
            $script:Passes++
            $key = $Unsorted[$i]

            # Locate the position where the key should be inserted
            $location = binarySearch -array $Unsorted -item $key -low 0 -high ($i - 1)

            # Shift all items between the insertion point and the key one position to the right
            for ($j = $i; $j -gt $location; $j--)
            {
                $Unsorted[$j] = $Unsorted[$j - 1]
                $script:Swaps++
            }
            $Unsorted[$location] = $key
        }

        Write-Verbose ('BinaryInsertionSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'BinaryInsertionSort'
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
