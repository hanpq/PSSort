function Use-GnomeSort
{
    <#
        .DESCRIPTION
            This function sorts objects using the gnome sort algorithm, also known as stupid sort. The
            algorithm walks forward through the array and whenever two neighbours are out of order they are
            swapped and the position is moved one step back.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Specifies that instead of returning the sorted array, an object containing sort diagnostic data will be return. The sorted array will stored as an property of that object.
        .EXAMPLE
            3,2,1 | Use-GnomeSort

            Sorts the array using gnome sort
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
        # Gnome sort does not work in passes over the array
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
        $index = 0

        while ($index -lt $n)
        {
            if ($index -eq 0)
            {
                $index++
                continue
            }

            $script:Compares++
            if ($Unsorted[$index] -ge $Unsorted[$index - 1])
            {
                # Neighbours are in order, step forward
                $index++
            }
            else
            {
                # Neighbours are out of order, swap them and step back
                swap -array $Unsorted -position $index -with ($index - 1)
                $index--
            }
        }

        Write-Verbose ('GnomeSort | Array length: {0} | Passes: N/A | Swaps: {1} | Compares: {2}' -f $Unsorted.count, $script:swaps, $script:compares)

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm   = 'GnomeSort'
                    ArrayLength = $Unsorted.Count
                    Passes      = 'N/A'
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
