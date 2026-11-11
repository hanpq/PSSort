function Use-CountingSort
{
    <#
        .DESCRIPTION
            This function sorts integers using the counting sort algorithm. The number of occurrences of
            every distinct value is counted and the counts are then used to place every item directly at its
            correct position. Since this is a non comparison based algorithm no comparisons are made and
            that counter will remain zero. The swap counter is used to count item writes instead.
        .PARAMETER InputObject
            Defines input objects to sort. Only integer values are supported.
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-CountingSort

            Sorts the array using counting sort
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object, therefor the verb sort is used')]
    [CmdletBinding()] # Enabled advanced function support
    [OutputType([collections.arraylist])]
    param(
        [parameter(ValueFromPipeline, Mandatory)][int[]]$InputObject,
        [parameter()][switch]$ReturnDiagnostics
    )

    begin
    {
        $Unsorted = [collections.arraylist]::New()
        # Counting sort is not a comparison based algorithm, the swap counter is used to count item writes
        $script:Swaps = 0
        $script:Compares = 0
        # Counting sort makes one counting pass and one output pass
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
        $n = $Unsorted.Count

        if ($n -gt 1)
        {
            $min = ($Unsorted | Measure-Object -Minimum).Minimum
            $max = ($Unsorted | Measure-Object -Maximum).Maximum
            $range = $max - $min + 1

            # Count the number of occurrences of every value
            $script:Passes++
            $count = New-Object 'int[]' $range
            foreach ($item in $Unsorted)
            {
                $count[$item - $min]++
                $script:Swaps++
            }

            # Write the values back to the array in ascending order
            $script:Passes++
            $index = 0
            for ($i = 0; $i -lt $range; $i++)
            {
                for ($j = 0; $j -lt $count[$i]; $j++)
                {
                    $Unsorted[$index] = $i + $min
                    $script:Swaps++
                    $index++
                }
            }
        }

        Write-Verbose ('CountingSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'CountingSort'
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
