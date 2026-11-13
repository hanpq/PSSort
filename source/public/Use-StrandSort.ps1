function Use-StrandSort
{
    <#
        .DESCRIPTION
            Sorts objects by repeatedly extracting an ordered strand and merging it into the output.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Returns sorting diagnostics and the sorted array instead of only the sorted array.
        .EXAMPLE
            3,2,1 | Use-StrandSort
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
    PROCESS { $InputObject | ForEach-Object { $null = $Unsorted.Add($PSItem) } }
    END
    {
        $remaining = [collections.arraylist]::new()
        foreach ($item in $Unsorted) { $null = $remaining.Add($item) }
        $Unsorted = [collections.arraylist]::new()

        while ($remaining.Count -gt 0)
        {
            $strand = [collections.arraylist]::new()
            $last = $null
            $hasLast = $false
            for ($i = 0; $i -lt $remaining.Count;)
            {
                $take = -not $hasLast
                if ($hasLast)
                {
                    $script:Compares++
                    $take = $remaining[$i] -ge $last
                }
                if ($take)
                {
                    $last = $remaining[$i]
                    $hasLast = $true
                    $null = $strand.Add($last)
                    $remaining.RemoveAt($i)
                }
                else { $i++ }
            }

            $merged = [collections.arraylist]::new()
            $i = 0
            $j = 0
            while ($i -lt $Unsorted.Count -and $j -lt $strand.Count)
            {
                $script:Compares++
                if ($Unsorted[$i] -le $strand[$j]) { $null = $merged.Add($Unsorted[$i++]) }
                else { $null = $merged.Add($strand[$j++]) }
            }
            while ($i -lt $Unsorted.Count) { $null = $merged.Add($Unsorted[$i++]) }
            while ($j -lt $strand.Count) { $null = $merged.Add($strand[$j++]) }
            $script:Swaps += $merged.Count
            $script:Passes++
            $Unsorted = $merged
        }

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm = 'StrandSort'; ArrayLength = $Unsorted.Count; Passes = $script:Passes
                    Swaps = $script:Swaps; Compares = $script:Compares; SortedArray = $Unsorted
                })
        }
        return $Unsorted
    }
}
