function Use-TimSort
{
    <#
        .DESCRIPTION
            Sorts objects with a stable, adaptive merge sort that detects existing ordered runs and
            extends short runs with insertion sort before merging them.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Returns sorting diagnostics and the sorted array instead of only the sorted array.
        .EXAMPLE
            3,2,1 | Use-TimSort
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object')]
    [CmdletBinding()]
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
        $script:Passes = 0
    }

    PROCESS
    {
        $InputObject | ForEach-Object { $null = $Unsorted.Add($PSItem) }
    }

    END
    {
        if ($Unsorted.Count -gt 1)
        {
            $minimumRun = 32
            $runs = [collections.arraylist]::New()

            for ($start = 0; $start -lt $Unsorted.Count;)
            {
                $end = $start + 1
                $descending = $false
                if ($end -lt $Unsorted.Count)
                {
                    $script:Compares++
                    $descending = $Unsorted[$end] -lt $Unsorted[$start]
                    while ($end -lt $Unsorted.Count)
                    {
                        $script:Compares++
                        if ($descending)
                        {
                            if ($Unsorted[$end] -ge $Unsorted[$end - 1]) { break }
                        }
                        elseif ($Unsorted[$end] -lt $Unsorted[$end - 1])
                        {
                            break
                        }
                        $end++
                    }
                }

                if ($descending)
                {
                    $left = $start
                    $right = $end - 1
                    while ($left -lt $right)
                    {
                        $value = $Unsorted[$left]
                        $Unsorted[$left] = $Unsorted[$right]
                        $Unsorted[$right] = $value
                        $script:Swaps++
                        $left++
                        $right--
                    }
                }

                $runEnd = [math]::Min([math]::Max($end, ($start + $minimumRun)), $Unsorted.Count)
                for ($i = $start + 1; $i -lt $runEnd; $i++)
                {
                    $value = $Unsorted[$i]
                    $j = $i - 1
                    while ($j -ge $start)
                    {
                        $script:Compares++
                        if ($Unsorted[$j] -le $value) { break }
                        $Unsorted[$j + 1] = $Unsorted[$j]
                        $script:Swaps++
                        $j--
                    }
                    $Unsorted[$j + 1] = $value
                    $script:Swaps++
                }

                $null = $runs.Add(@{ Start = $start; Length = ($runEnd - $start) })
                $script:Passes++
                $start = $runEnd
            }

            while ($runs.Count -gt 1)
            {
                $nextRuns = [collections.arraylist]::New()
                for ($r = 0; $r -lt $runs.Count; $r += 2)
                {
                    $leftRun = $runs[$r]
                    if ($r + 1 -ge $runs.Count)
                    {
                        $null = $nextRuns.Add($leftRun)
                        continue
                    }

                    $rightRun = $runs[$r + 1]
                    $left = $leftRun.Start
                    $middle = $left + $leftRun.Length - 1
                    $right = $middle + $rightRun.Length
                    $leftPart = @($Unsorted[$left..$middle])
                    $rightPart = @($Unsorted[($middle + 1)..$right])
                    $i = 0
                    $j = 0
                    $k = $left
                    while ($i -lt $leftPart.Count -and $j -lt $rightPart.Count)
                    {
                        $script:Compares++
                        if ($leftPart[$i] -le $rightPart[$j])
                        {
                            $Unsorted[$k] = $leftPart[$i++]
                        }
                        else
                        {
                            $Unsorted[$k] = $rightPart[$j++]
                        }
                        $script:Swaps++
                        $k++
                    }
                    while ($i -lt $leftPart.Count)
                    {
                        $Unsorted[$k++] = $leftPart[$i++]
                        $script:Swaps++
                    }
                    while ($j -lt $rightPart.Count)
                    {
                        $Unsorted[$k++] = $rightPart[$j++]
                        $script:Swaps++
                    }

                    $null = $nextRuns.Add(@{ Start = $left; Length = ($leftRun.Length + $rightRun.Length) })
                    $script:Passes++
                }
                $runs = $nextRuns
            }
        }

        Write-Verbose ('TimSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.Count, $script:Passes, $script:Swaps, $script:Compares)
        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'TimSort'
                    ArrayLength = $Unsorted.Count
                    Passes      = $script:Passes
                    Swaps       = $script:Swaps
                    Compares    = $script:Compares
                    SortedArray = $Unsorted
                })
        }
        return $Unsorted
    }
}
