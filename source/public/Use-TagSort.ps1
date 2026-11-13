function Use-TagSort
{
    <#
        .DESCRIPTION
            Sorts an index tag array by the corresponding input values, then emits the values in tag order.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Returns sorting diagnostics and the sorted array instead of only the sorted array.
        .EXAMPLE
            3,2,1 | Use-TagSort
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
        $tags = [int[]]::new($Unsorted.Count)
        for ($i = 0; $i -lt $tags.Length; $i++) { $tags[$i] = $i }
        for ($i = 1; $i -lt $tags.Length; $i++)
        {
            $tag = $tags[$i]
            $j = $i - 1
            while ($j -ge 0)
            {
                $script:Compares++
                if ($Unsorted[$tags[$j]] -le $Unsorted[$tag]) { break }
                $tags[$j + 1] = $tags[$j]
                $script:Swaps++
                $j--
            }
            $tags[$j + 1] = $tag
            $script:Swaps++
            $script:Passes++
        }
        $sorted = [collections.arraylist]::new()
        foreach ($tag in $tags) { $null = $sorted.Add($Unsorted[$tag]) }
        $Unsorted = $sorted

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm = 'TagSort'; ArrayLength = $Unsorted.Count; Passes = $script:Passes
                    Swaps = $script:Swaps; Compares = $script:Compares; SortedArray = $Unsorted
                })
        }
        return $Unsorted
    }
}
