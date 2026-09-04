function Use-CocktailSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the cocktail shaker sort algorithm, a bidirectional variation
            of bubble sort. Every iteration traverses the array forwards and then backwards which moves both
            large and small items towards their final position.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-CocktailSort

            Sorts the array using cocktail sort
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
        # A pass is counted for every traversal of the array, forwards as well as backwards
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

        $start = 0
        $end = $Unsorted.Count - 1
        $swapped = $true

        while ($swapped)
        {
            $swapped = $false

            # Forward pass, bubbles the largest remaining item to the end
            $script:Passes++
            for ($i = $start; $i -lt $end; $i++)
            {
                $script:Compares++
                if ($Unsorted[$i] -gt $Unsorted[$i + 1])
                {
                    swap -array $Unsorted -position $i -with ($i + 1)
                    $swapped = $true
                }
            }

            if (-not $swapped)
            {
                break
            }

            $swapped = $false
            $end--

            # Backward pass, bubbles the smallest remaining item to the start
            $script:Passes++
            for ($i = ($end - 1); $i -ge $start; $i--)
            {
                $script:Compares++
                if ($Unsorted[$i] -gt $Unsorted[$i + 1])
                {
                    swap -array $Unsorted -position $i -with ($i + 1)
                    $swapped = $true
                }
            }

            $start++
        }

        Write-Verbose ('CocktailSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'CocktailSort'
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
