function Use-RecursiveInsertionSort
{
    <#
        .DESCRIPTION
            This function sorts objects using a recursive implementation of the insertion sort algorithm.
            The array of length n is sorted by first recursively sorting the first n-1 items and then
            inserting the last item at its correct position.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-RecursiveInsertionSort

            Sorts the array using recursive insertion sort
        .NOTES
            The recursion depth equals the number of items to sort, so arrays of a few hundred items or
            more will fail with a call depth overflow. Use Use-InsertionSort for larger arrays.
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

        function recursiveInsertionSort
        {
            param(
                $array,
                $n
            )

            # An array with one or zero items is already sorted
            if ($n -le 1)
            {
                return
            }

            # Sort the first n-1 items
            recursiveInsertionSort -array $array -n ($n - 1)

            $script:Passes++
            $key = $array[$n - 1]
            $j = $n - 2

            # Insert the last item into the sorted part of the array
            while ($j -ge 0)
            {
                $script:Compares++
                if ($array[$j] -gt $key)
                {
                    $array[$j + 1] = $array[$j]
                    $script:Swaps++
                    $j--
                }
                else
                {
                    break
                }
            }
            $array[$j + 1] = $key
        }

        recursiveInsertionSort -array $Unsorted -n $Unsorted.Count

        Write-Verbose ('RecursiveInsertionSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'RecursiveInsertionSort'
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
