function Invoke-LinkedListSort
{
    <#
        .DESCRIPTION
            Sorts values linked through internal nodes with linked-list quicksort or merge sort.
        .PARAMETER InputList
            The input values to sort.
        .PARAMETER Algorithm
            Selects quicksort or merge sort.
        .PARAMETER DoublyLinked
            Creates and maintains previous links when true.
        .PARAMETER ReturnDiagnostics
            Returns sorting diagnostics and sorted values instead of only the sorted values.
        .EXAMPLE
            Invoke-LinkedListSort -InputList $values -Algorithm Merge -DoublyLinked $false
    #>
    [CmdletBinding()]
    [OutputType([collections.arraylist], [pscustomobject])]
    param(
        [parameter(Mandatory)][collections.arraylist]$InputList,
        [parameter(Mandatory)][ValidateSet('Quick', 'Merge')][string]$Algorithm,
        [parameter(Mandatory)][bool]$DoublyLinked,
        [parameter()][switch]$ReturnDiagnostics
    )

    $script:Swaps = 0
    $script:Compares = 0
    $script:Passes = 0
    $head = $null
    $tail = $null
    foreach ($value in $InputList)
    {
        $node = [pscustomobject]@{ Value = $value; Next = $null; Previous = $null }
        if ($null -eq $head) { $head = $node }
        else
        {
            $tail.Next = $node
            if ($DoublyLinked) { $node.Previous = $tail }
        }
        $tail = $node
    }

    function mergeLinkedRuns
    {
        param($LeftHead, $LeftLength, $RightHead, $RightLength)
        $left = $LeftHead
        $right = $RightHead
        $leftRemaining = $LeftLength
        $rightRemaining = $RightLength
        $mergedHead = $null
        $mergedTail = $null
        while ($leftRemaining -gt 0 -or $rightRemaining -gt 0)
        {
            if ($leftRemaining -eq 0) { $takeLeft = $false }
            elseif ($rightRemaining -eq 0) { $takeLeft = $true }
            else
            {
                $script:Compares++
                $takeLeft = $left.Value -le $right.Value
            }

            if ($takeLeft)
            {
                $selected = $left
                $left = $left.Next
                $leftRemaining--
            }
            else
            {
                $selected = $right
                $right = $right.Next
                $rightRemaining--
            }
            $selected.Next = $null
            if ($DoublyLinked) { $selected.Previous = $mergedTail }
            if ($null -eq $mergedHead) { $mergedHead = $selected }
            else { $mergedTail.Next = $selected }
            $mergedTail = $selected
            $script:Swaps++
        }
        [pscustomobject]@{ Head = $mergedHead; Tail = $mergedTail }
    }

    function mergeSortLinked
    {
        param($ListHead, [int]$Length)
        if ($Length -le 1) { return [pscustomobject]@{ Head = $ListHead; Tail = $ListHead } }

        $leftLength = [int][math]::Floor($Length / 2)
        $leftTail = $ListHead
        for ($i = 1; $i -lt $leftLength; $i++) { $leftTail = $leftTail.Next }
        $rightHead = $leftTail.Next
        $leftTail.Next = $null
        if ($DoublyLinked) { $rightHead.Previous = $null }
        $script:Passes++
        $leftSorted = mergeSortLinked -ListHead $ListHead -Length $leftLength
        $rightSorted = mergeSortLinked -ListHead $rightHead -Length ($Length - $leftLength)
        mergeLinkedRuns -LeftHead $leftSorted.Head -LeftLength $leftLength -RightHead $rightSorted.Head -RightLength ($Length - $leftLength)
    }

    function quickSortLinked
    {
        param($ListHead, [int]$Length)
        if ($Length -le 1) { return [pscustomobject]@{ Head = $ListHead; Tail = $ListHead } }

        $pivotNode = $ListHead
        for ($i = 0; $i -lt [int][math]::Floor($Length / 2); $i++) { $pivotNode = $pivotNode.Next }
        $pivot = $pivotNode.Value
        $lessHead = $null; $lessTail = $null; $lessCount = 0
        $equalHead = $null; $equalTail = $null; $equalCount = 0
        $greaterHead = $null; $greaterTail = $null; $greaterCount = 0
        $currentNode = $ListHead
        while ($null -ne $currentNode)
        {
            $nextNode = $currentNode.Next
            $currentNode.Next = $null
            if ($DoublyLinked) { $currentNode.Previous = $null }
            $script:Compares++
            if ($currentNode.Value -lt $pivot)
            {
                $bucket = 'Less'
            }
            else
            {
                $script:Compares++
                if ($currentNode.Value -gt $pivot) { $bucket = 'Greater' }
                else { $bucket = 'Equal' }
            }
            if ($bucket -eq 'Less')
            {
                if ($null -eq $lessHead) { $lessHead = $currentNode } else { $lessTail.Next = $currentNode }
                if ($DoublyLinked -and $null -ne $lessTail) { $currentNode.Previous = $lessTail }
                $lessTail = $currentNode; $lessCount++
            }
            elseif ($bucket -eq 'Greater')
            {
                if ($null -eq $greaterHead) { $greaterHead = $currentNode } else { $greaterTail.Next = $currentNode }
                if ($DoublyLinked -and $null -ne $greaterTail) { $currentNode.Previous = $greaterTail }
                $greaterTail = $currentNode; $greaterCount++
            }
            else
            {
                if ($null -eq $equalHead) { $equalHead = $currentNode } else { $equalTail.Next = $currentNode }
                if ($DoublyLinked -and $null -ne $equalTail) { $currentNode.Previous = $equalTail }
                $equalTail = $currentNode; $equalCount++
            }
            $currentNode = $nextNode
        }
        $script:Passes++
        $lessSorted = quickSortLinked -ListHead $lessHead -Length $lessCount
        $greaterSorted = quickSortLinked -ListHead $greaterHead -Length $greaterCount
        $resultHead = $equalHead
        $resultTail = $equalTail
        if ($lessCount -gt 0)
        {
            $lessSorted.Tail.Next = $equalHead
            if ($DoublyLinked) { $equalHead.Previous = $lessSorted.Tail }
            $resultHead = $lessSorted.Head
        }
        if ($greaterCount -gt 0)
        {
            $resultTail.Next = $greaterSorted.Head
            if ($DoublyLinked) { $greaterSorted.Head.Previous = $resultTail }
            $resultTail = $greaterSorted.Tail
        }
        if ($null -ne $resultHead -and $DoublyLinked) { $resultHead.Previous = $null }
        [pscustomobject]@{ Head = $resultHead; Tail = $resultTail }
    }

    if ($Algorithm -eq 'Merge' -and $InputList.Count -gt 1)
    {
        $sorted = mergeSortLinked -ListHead $head -Length $InputList.Count
        $head = $sorted.Head
    }
    elseif ($Algorithm -eq 'Quick' -and $InputList.Count -gt 1)
    {
        $sorted = quickSortLinked -ListHead $head -Length $InputList.Count
        $head = $sorted.Head
    }

    $sortedValues = [collections.arraylist]::new()
    while ($null -ne $head)
    {
        $null = $sortedValues.Add($head.Value)
        $head = $head.Next
    }

    $algorithmName = if ($Algorithm -eq 'Quick') { 'QuickSort' } else { 'MergeSort' }
    $structureName = if ($DoublyLinked) { 'DoublyLinkedList' } else { 'SinglyLinkedList' }
    $name = $algorithmName + $structureName
    if ($ReturnDiagnostics)
    {
        return ([pscustomobject]@{
                Algorithm = $name; ArrayLength = $sortedValues.Count; Passes = $script:Passes
                Swaps = $script:Swaps; Compares = $script:Compares; SortedArray = $sortedValues
            })
    }
    return $sortedValues
}
