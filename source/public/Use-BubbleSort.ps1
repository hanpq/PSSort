function Use-BubbleSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the bubble sort algorithm. This is the optimized version of
            bubblesort where already sorted items are skipped every pass.
        .PARAMETER InputObject
            Specify array of items to be sorted
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-BubbleSort
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object, therefor the verb sort is used')]
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

        function bubbleSort
        {
            param (
                $array
            )

            $n = $array.Count
            # Do passes over array until last swap was at position 1 or less
            do
            {
                $script:passes++
                # Reset last swap position
                $lastswap = 0

                # Go through array up to lastswap and compare each neighbour
                for ($i = 1; $i -le ($n - 1); $i++)
                {
                    $script:Compares++
                    if ($array[$i - 1] -gt $array[$i])
                    {
                        swap -array $array -position $i -with ($i - 1)
                        $lastswap = $i
                    }
                }
                # Update $n with the position of the last swap to skip over already sorted items
                $n = $lastswap
            } until ($n -le 1)
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

        bubblesort -array $Unsorted
        Write-Verbose ('BubbleSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)
        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'BubblesSort'
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
