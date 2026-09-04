function Use-BucketSort
{
    <#
        .DESCRIPTION
            This function sorts numbers using the bucket sort algorithm. The value range is divided into a
            number of buckets, every item is distributed into the bucket matching its value and every bucket
            is then sorted individually using insertion sort before the buckets are concatenated.
        .PARAMETER InputObject
            Defines input objects to sort. Only numeric values are supported.
        .PARAMETER BucketCount
            Specifies the number of buckets to distribute the items into. Defaults to the number of items.
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-BucketSort

            Sorts the array using bucket sort
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object, therefor the verb sort is used')]
    [CmdletBinding()] # Enabled advanced function support
    [OutputType([collections.arraylist])]
    param(
        [parameter(ValueFromPipeline, Mandatory)][double[]]$InputObject,
        [parameter()][int]$BucketCount = 0,
        [parameter()][switch]$ReturnDiagnostics
    )

    BEGIN
    {
        $Unsorted = [collections.arraylist]::New()
        # Swaps are counted as item moves, both when distributing into buckets and when sorting a bucket
        $script:Swaps = 0
        $script:Compares = 0
        # One pass per bucket that is sorted
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
            if ($BucketCount -le 0)
            {
                $BucketCount = $n
            }

            $min = ($Unsorted | Measure-Object -Minimum).Minimum
            $max = ($Unsorted | Measure-Object -Maximum).Maximum
            $range = $max - $min

            # Create the buckets
            $buckets = New-Object 'collections.arraylist[]' $BucketCount
            for ($i = 0; $i -lt $BucketCount; $i++)
            {
                $buckets[$i] = [collections.arraylist]::New()
            }

            # Distribute the items over the buckets
            foreach ($item in $Unsorted)
            {
                if ($range -eq 0)
                {
                    $bucketIndex = 0
                }
                else
                {
                    $bucketIndex = [int]([math]::Floor((($item - $min) / $range) * ($BucketCount - 1)))
                }
                $null = $buckets[$bucketIndex].Add($item)
                $script:Swaps++
            }

            # Sort every bucket using insertion sort and write the items back
            $index = 0
            foreach ($bucket in $buckets)
            {
                $script:Passes++

                for ($i = 1; $i -lt $bucket.Count; $i++)
                {
                    $key = $bucket[$i]
                    $j = $i - 1
                    while ($j -ge 0)
                    {
                        $script:Compares++
                        if ($bucket[$j] -gt $key)
                        {
                            $bucket[$j + 1] = $bucket[$j]
                            $script:Swaps++
                            $j--
                        }
                        else
                        {
                            break
                        }
                    }
                    $bucket[$j + 1] = $key
                }

                foreach ($item in $bucket)
                {
                    $Unsorted[$index] = $item
                    $script:Swaps++
                    $index++
                }
            }
        }

        Write-Verbose ('BucketSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'BucketSort'
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
