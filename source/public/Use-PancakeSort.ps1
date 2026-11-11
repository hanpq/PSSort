function Use-PancakeSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the pancake sort algorithm. The only allowed operation is to
            flip (reverse) a prefix of the array. For every pass the largest remaining item is flipped to
            the front and then flipped into its final position.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-PancakeSort

            Sorts the array using pancake sort
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
        # Swaps are counted inside the flip operation
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

        function flip
        {
            param(
                $array,
                $end
            )

            $start = 0
            while ($start -lt $end)
            {
                swap -array $array -position $start -with $end
                $start++
                $end--
            }
        }

        $n = $Unsorted.Count

        for ($size = $n; $size -gt 1; $size--)
        {
            $script:Passes++

            # Locate the largest item within the unsorted part
            $maxIndex = 0
            for ($i = 1; $i -lt $size; $i++)
            {
                $script:Compares++
                if ($Unsorted[$i] -gt $Unsorted[$maxIndex])
                {
                    $maxIndex = $i
                }
            }

            if ($maxIndex -ne ($size - 1))
            {
                # Flip the largest item to the front and then to its final position
                flip -array $Unsorted -end $maxIndex
                flip -array $Unsorted -end ($size - 1)
            }
        }

        Write-Verbose ('PancakeSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'PancakeSort'
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
