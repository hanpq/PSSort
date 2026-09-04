function Use-ShellSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the shell sort algorithm. It is a generalization of insertion
            sort where items separated by a gap are compared. The gap is halved for every pass until it
            reaches one, at which point the array is almost sorted.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-ShellSort

            Sorts the array using shell sort
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
        # One pass per gap size
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

        for ($gap = [int][math]::Floor($n / 2); $gap -gt 0; $gap = [int][math]::Floor($gap / 2))
        {
            $script:Passes++

            # Gapped insertion sort for the current gap size
            for ($i = $gap; $i -lt $n; $i++)
            {
                $temp = $Unsorted[$i]
                $j = $i
                while ($j -ge $gap)
                {
                    $script:Compares++
                    if ($Unsorted[$j - $gap] -gt $temp)
                    {
                        $Unsorted[$j] = $Unsorted[$j - $gap]
                        $script:Swaps++
                        $j = $j - $gap
                    }
                    else
                    {
                        break
                    }
                }
                $Unsorted[$j] = $temp
            }
        }

        Write-Verbose ('ShellSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'ShellSort'
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
