function Use-OddEvenSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the odd-even sort algorithm, also known as brick sort. It is a
            variation of bubble sort where every pass consists of one phase comparing all odd indexed pairs
            followed by one phase comparing all even indexed pairs.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-OddEvenSort

            Sorts the array using odd-even sort
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
        $isSorted = $false

        while (-not $isSorted)
        {
            $script:Passes++
            $isSorted = $true

            # Odd indexed phase
            for ($i = 1; $i -lt ($n - 1); $i = $i + 2)
            {
                $script:Compares++
                if ($Unsorted[$i] -gt $Unsorted[$i + 1])
                {
                    swap -array $Unsorted -position $i -with ($i + 1)
                    $isSorted = $false
                }
            }

            # Even indexed phase
            for ($i = 0; $i -lt ($n - 1); $i = $i + 2)
            {
                $script:Compares++
                if ($Unsorted[$i] -gt $Unsorted[$i + 1])
                {
                    swap -array $Unsorted -position $i -with ($i + 1)
                    $isSorted = $false
                }
            }
        }

        Write-Verbose ('OddEvenSort | Array length: {0} | Passes: {1} | Swaps: {2} | Compares: {3}' -f $Unsorted.count, $script:Passes, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'OddEvenSort'
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
