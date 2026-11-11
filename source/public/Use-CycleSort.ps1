function Use-CycleSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the cycle sort algorithm. The algorithm is optimal in terms of
            the number of memory writes since every item is written at most once to its correct position,
            which makes it useful when writes are expensive.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-CycleSort

            Sorts the array using cycle sort
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
        # Cycle sort does not swap pairs, the swap counter is used to count item writes
        $script:Swaps = 0
        $script:Compares = 0
        # One pass per cycle start
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

        $n = $Unsorted.Count

        for ($cycleStart = 0; $cycleStart -lt ($n - 1); $cycleStart++)
        {
            $script:Passes++
            $item = $Unsorted[$cycleStart]

            # Find the position where the item belongs by counting smaller items
            $position = $cycleStart
            for ($i = $cycleStart + 1; $i -lt $n; $i++)
            {
                $script:Compares++
                if ($Unsorted[$i] -lt $item)
                {
                    $position++
                }
            }

            # The item is already at its correct position
            if ($position -eq $cycleStart)
            {
                continue
            }

            # Skip duplicates
            while ($item -eq $Unsorted[$position])
            {
                $position++
            }

            $temp = $Unsorted[$position]
            $Unsorted[$position] = $item
            $item = $temp
            $script:Swaps++

            # Rotate the rest of the cycle
            while ($position -ne $cycleStart)
            {
                $position = $cycleStart
                for ($i = $cycleStart + 1; $i -lt $n; $i++)
                {
                    $script:Compares++
                    if ($Unsorted[$i] -lt $item)
                    {
                        $position++
                    }
                }

                while ($item -eq $Unsorted[$position])
                {
                    $position++
                }

                if ($item -ne $Unsorted[$position])
                {
                    $temp = $Unsorted[$position]
                    $Unsorted[$position] = $item
                    $item = $temp
                    $script:Swaps++
                }
            }
        }

        Write-Verbose ('CycleSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'CycleSort'
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
