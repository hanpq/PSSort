function Use-CombSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the comb sort algorithm. It improves on bubble sort by
            comparing items separated by a gap that shrinks by a factor of 1.3 for every pass, which
            removes small values (turtles) near the end of the array early.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-CombSort

            Sorts the array using comb sort
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

        $n = $Unsorted.Count
        $gap = $n
        $swapped = $true

        # Keep going until the gap is one and a full pass was made without swaps
        while (($gap -ne 1) -or $swapped)
        {
            $script:Passes++

            # Shrink the gap with the ideal shrink factor of 1.3
            $gap = [int][math]::Floor($gap / 1.3)
            if ($gap -lt 1)
            {
                $gap = 1
            }

            $swapped = $false
            for ($i = 0; $i -lt ($n - $gap); $i++)
            {
                $script:Compares++
                if ($Unsorted[$i] -gt $Unsorted[$i + $gap])
                {
                    swap -array $Unsorted -position $i -with ($i + $gap)
                    $swapped = $true
                }
            }
        }

        Write-Verbose ('CombSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'CombSort'
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
