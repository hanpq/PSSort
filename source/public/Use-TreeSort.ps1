function Use-TreeSort
{
    <#
        .DESCRIPTION
            Sorts objects by inserting them into a binary search tree and emitting an in-order traversal.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Returns sorting diagnostics and the sorted array instead of only the sorted array.
        .EXAMPLE
            3,2,1 | Use-TreeSort
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
        $root = $null
        foreach ($value in $Unsorted)
        {
            $node = [pscustomobject]@{ Value = $value; Left = $null; Right = $null }
            if ($null -eq $root) { $root = $node; continue }
            $current = $root
            while ($true)
            {
                $script:Compares++
                if ($value -lt $current.Value)
                {
                    if ($null -eq $current.Left) { $current.Left = $node; break }
                    $current = $current.Left
                }
                else
                {
                    if ($null -eq $current.Right) { $current.Right = $node; break }
                    $current = $current.Right
                }
            }
            $script:Passes++
        }

        $Unsorted.Clear()
        $stack = [collections.stack]::new()
        $current = $root
        while ($null -ne $current -or $stack.Count -gt 0)
        {
            while ($null -ne $current) { $stack.Push($current); $current = $current.Left }
            $current = $stack.Pop()
            $null = $Unsorted.Add($current.Value)
            $current = $current.Right
            $script:Swaps++
        }
        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm = 'TreeSort'; ArrayLength = $Unsorted.Count; Passes = $script:Passes
                    Swaps = $script:Swaps; Compares = $script:Compares; SortedArray = $Unsorted
                })
        }
        return $Unsorted
    }
}
