function Use-StoogeSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the stooge sort algorithm. It is a recursive sorting algorithm
            with a notably bad time complexity of O(n^2.71). If the first item is larger than the last they
            are swapped, and if the range contains three or more items the first two thirds, the last two
            thirds and then the first two thirds again are sorted recursively.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-StoogeSort

            Sorts the array using stooge sort
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
        # Counts the number of recursive calls
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

        function stoogeSort
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

            # Make sure the first item is not larger than the last
            $script:Compares++
            if ($array[$low] -gt $array[$high])
            {
                swap -array $array -position $low -with $high
            }

            # If there are three or more items, recursively sort the thirds
            if (($high - $low + 1) -gt 2)
            {
                $third = [int][math]::Floor(($high - $low + 1) / 3)
                stoogeSort -array $array -low $low -high ($high - $third)
                stoogeSort -array $array -low ($low + $third) -high $high
                stoogeSort -array $array -low $low -high ($high - $third)
            }
        }

        if ($Unsorted.Count -gt 1)
        {
            stoogeSort -array $Unsorted -low 0 -high ($Unsorted.Count - 1)
        }

        Write-Verbose ('StoogeSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'StoogeSort'
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
