function Use-RecursiveBubbleSort
{
    <#
        .DESCRIPTION
            This function sorts objects using a recursive implementation of the bubble sort algorithm.
            One pass bubbles the largest item to the end of the array and the function then calls itself
            on the remaining n-1 items.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-RecursiveBubbleSort

            Sorts the array using recursive bubble sort
        .NOTES
            The recursion depth equals the number of items to sort, so arrays of a few hundred items or
            more will fail with a call depth overflow. Use Use-BubbleSort for larger arrays.
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

        function recursiveBubbleSort
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

            $script:Passes++

            # Bubble the largest item of the current range to position n-1
            for ($i = 0; $i -lt ($n - 1); $i++)
            {
                $script:Compares++
                if ($array[$i] -gt $array[$i + 1])
                {
                    swap -array $array -position $i -with ($i + 1)
                }
            }

            recursiveBubbleSort -array $array -n ($n - 1)
        }

        recursiveBubbleSort -array $Unsorted -n $Unsorted.Count

        Write-Verbose ('RecursiveBubbleSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'RecursiveBubbleSort'
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
