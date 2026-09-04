function Use-InsertionSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the insertion sort algorithm. Each item is picked from the
            unsorted part of the array and inserted at its correct position in the sorted part.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-InsertionSort

            Sorts the array using insertion sort
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object, therefor the verb sort is used')]
    [CmdletBinding()] # Enabled advanced function support
    [OutputType([collections.arraylist])]
    param(
        [parameter(ValueFromPipeline, Mandatory)]$InputObject,
        [parameter()][switch]$ReturnDiagnostics
    )

    begin
    {
        $Unsorted = [collections.arraylist]::New()
        $script:Swaps = 0
        $script:Compares = 0
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
        # Determine default sort property
        if ($null -ne $Unsorted[0].PSStandardMembers.DefaultKeyPropertySet)
        {
            Write-Warning -Message 'This object has a default sorting specified'
        }

        $n = $Unsorted.Count
        # One pass per item that is inserted into the already sorted part of the array
        for ($i = 1; $i -lt $n; $i++)
        {
            $script:Passes++
            $key = $Unsorted[$i]
            $j = $i - 1

            # Shift all items greater than the key one position to the right
            while ($j -ge 0)
            {
                $script:Compares++
                if ($Unsorted[$j] -gt $key)
                {
                    $Unsorted[$j + 1] = $Unsorted[$j]
                    $script:Swaps++
                    $j--
                }
                else
                {
                    break
                }
            }
            $Unsorted[$j + 1] = $key
        }

        Write-Verbose ('InsertionSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'InsertionSort'
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
