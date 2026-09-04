function Use-PigeonholeSort
{
    <#
        .DESCRIPTION
            This function sorts integers using the pigeonhole sort algorithm. One pigeonhole is created for
            every value in the range between the smallest and the largest item, every item is placed in its
            hole and the holes are then emptied in order. Since this is a non comparison based algorithm no
            comparisons are made and that counter will remain zero. The swap counter is used to count item
            writes instead.
        .PARAMETER InputObject
            Defines input objects to sort. Only integer values are supported.
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-PigeonholeSort

            Sorts the array using pigeonhole sort
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object, therefor the verb sort is used')]
    [CmdletBinding()] # Enabled advanced function support
    [OutputType([collections.arraylist])]
    param(
        [parameter(ValueFromPipeline, Mandatory)][int[]]$InputObject,
        [parameter()][switch]$ReturnDiagnostics
    )

    BEGIN
    {
        $Unsorted = [collections.arraylist]::New()
        # Pigeonhole sort is not a comparison based algorithm, the swap counter is used to count item writes
        $script:Swaps = 0
        $script:Compares = 0
        # One pass to fill the holes and one pass to empty them
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
        $n = $Unsorted.Count

        if ($n -gt 1)
        {
            $min = ($Unsorted | Measure-Object -Minimum).Minimum
            $max = ($Unsorted | Measure-Object -Maximum).Maximum
            $range = $max - $min + 1

            # Place every item in the hole matching its value
            $script:Passes++
            $holes = New-Object 'int[]' $range
            foreach ($item in $Unsorted)
            {
                $holes[$item - $min]++
                $script:Swaps++
            }

            # Empty the holes in order
            $script:Passes++
            $index = 0
            for ($i = 0; $i -lt $range; $i++)
            {
                while ($holes[$i] -gt 0)
                {
                    $Unsorted[$index] = $i + $min
                    $script:Swaps++
                    $holes[$i]--
                    $index++
                }
            }
        }

        Write-Verbose ('PigeonholeSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'PigeonholeSort'
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
