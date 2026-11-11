function Use-RadixSort
{
    <#
        .DESCRIPTION
            This function sorts non negative integers using the radix sort algorithm. A stable counting sort
            is applied once per digit, starting with the least significant digit. Since this is a non
            comparison based algorithm no comparisons are made and that counter will remain zero. The swap
            counter is used to count item writes instead.
        .PARAMETER InputObject
            Defines input objects to sort. Only non negative integer values are supported.
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            170,45,75,90,802,24,2,66 | Use-RadixSort

            Sorts the array using radix sort
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
        # Radix sort is not a comparison based algorithm, the swap counter is used to count item writes
        $script:Swaps = 0
        $script:Compares = 0
        # One pass per digit position
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
        if ($Unsorted.Where({ $PSItem -lt 0 }, 'First').Count -gt 0)
        {
            throw 'Use-RadixSort only supports non negative integers'
        }

        function countingSortByDigit
        {
            param(
                $array,
                $exponent
            )

            $n = $array.Count
            $output = New-Object 'int[]' $n
            $count = New-Object 'int[]' 10

            # Count the occurrences of every digit at the current position
            for ($i = 0; $i -lt $n; $i++)
            {
                $digit = [int]([math]::Floor($array[$i] / $exponent) % 10)
                $count[$digit]++
            }

            # Turn the counts into positions
            for ($i = 1; $i -lt 10; $i++)
            {
                $count[$i] = $count[$i] + $count[$i - 1]
            }

            # Build the output array traversing backwards to keep the sort stable
            for ($i = $n - 1; $i -ge 0; $i--)
            {
                $digit = [int]([math]::Floor($array[$i] / $exponent) % 10)
                $output[$count[$digit] - 1] = $array[$i]
                $script:Swaps++
                $count[$digit]--
            }

            for ($i = 0; $i -lt $n; $i++)
            {
                $array[$i] = $output[$i]
                $script:Swaps++
            }
        }

        if ($Unsorted.Count -gt 1)
        {
            $max = ($Unsorted | Measure-Object -Maximum).Maximum

            for ($exponent = 1; [int][math]::Floor($max / $exponent) -gt 0; $exponent = $exponent * 10)
            {
                $script:Passes++
                countingSortByDigit -array $Unsorted -exponent $exponent
            }
        }

        Write-Verbose ('RadixSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'RadixSort'
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
