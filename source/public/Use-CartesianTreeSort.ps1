function Use-CartesianTreeSort
{
    <#
        .DESCRIPTION
            Builds a min-Cartesian tree from the input order, then visits its heap-ordered nodes by priority.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Returns sorting diagnostics and the sorted array instead of only the sorted array.
        .EXAMPLE
            3,2,1 | Use-CartesianTreeSort
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
        $stack = [collections.stack]::new()
        for ($i = 0; $i -lt $Unsorted.Count; $i++)
        {
            $node = [pscustomobject]@{ Value = $Unsorted[$i]; Left = $null; Right = $null }
            $last = $null
            while ($stack.Count -gt 0)
            {
                $script:Compares++
                if ($stack.Peek().Value -le $node.Value) { break }
                $last = $stack.Pop()
            }
            $node.Left = $last
            if ($stack.Count -gt 0) { $stack.Peek().Right = $node }
            $stack.Push($node)
            $script:Passes++
        }

        $root = $null
        if ($stack.Count -gt 0) { $root = $stack.ToArray()[-1] }
        $queue = [collections.arraylist]::new()
        if ($null -ne $root) { $null = $queue.Add($root) }
        $Unsorted.Clear()
        while ($queue.Count -gt 0)
        {
            $minimum = 0
            for ($i = 1; $i -lt $queue.Count; $i++)
            {
                $script:Compares++
                if ($queue[$i].Value -lt $queue[$minimum].Value) { $minimum = $i }
            }
            $node = $queue[$minimum]
            $queue.RemoveAt($minimum)
            $null = $Unsorted.Add($node.Value)
            if ($null -ne $node.Left) { $null = $queue.Add($node.Left) }
            if ($null -ne $node.Right) { $null = $queue.Add($node.Right) }
            $script:Swaps++
        }
        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm = 'CartesianTreeSort'; ArrayLength = $Unsorted.Count; Passes = $script:Passes
                    Swaps = $script:Swaps; Compares = $script:Compares; SortedArray = $Unsorted
                })
        }
        return $Unsorted
    }
}
