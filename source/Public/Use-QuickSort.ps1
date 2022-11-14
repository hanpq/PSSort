function Use-QuickSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the quick sort algorithm
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            Use-QuickSort

            Description of example
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object, therefor the verb sort is used')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingCmdletAliases', '', Justification = 'False positive, get-partition is not implictly called. partition is a internal function')]
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

        function quicksort
        {
            param (
                $array,
                $low,
                $high
            )

            if ($low -lt $high)
            {
                $p = partition -array $array -low $low -high $high
                quicksort -array $array -low $low -high ($p - 1)
                quicksort -array $array -low ($P + 1) -high $high
            }
        }
        function partition
        {
            param(
                $array,
                $low,
                $high
            )
            $pivot = $array[$high]
            $i = $low
            for ($j = $low; $j -le $high; $j++)
            {
                $script:Compares++
                if ($array[$j] -lt $pivot)
                {
                    swap -array $array -position $i -with $j
                    $i = $i + 1
                }
            }
            swap -array $array -position $i -with $high
            return $i
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

        quicksort -array $Unsorted -low 0 -high ($Unsorted.count - 1)
        Write-Verbose ('QuickSort | Array length: {0} | Passes: N/A | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)
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
