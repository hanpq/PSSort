function Use-ThreeWayMergeSort
{
    <#
        .DESCRIPTION
            Sorts objects by recursively dividing the input into three parts and merging the sorted parts.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Returns sorting diagnostics and the sorted array instead of only the sorted array.
        .EXAMPLE
            3,2,1 | Use-ThreeWayMergeSort
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
        function mergeThree
        {
            param($Array, $Left, $MiddleOne, $MiddleTwo, $Right)
            $parts = [collections.arraylist]::new()
            $null = $parts.Add([object[]]@($Array[$Left..$MiddleOne]))
            if ($MiddleOne + 1 -le $MiddleTwo)
            {
                $null = $parts.Add([object[]]@($Array[($MiddleOne + 1)..$MiddleTwo]))
            }
            else { $null = $parts.Add([object[]]@()) }
            if ($MiddleTwo + 1 -le $Right)
            {
                $null = $parts.Add([object[]]@($Array[($MiddleTwo + 1)..$Right]))
            }
            else { $null = $parts.Add([object[]]@()) }
            $positions = @(0, 0, 0)
            for ($output = $Left; $output -le $Right; $output++)
            {
                $selected = -1
                for ($part = 0; $part -lt 3; $part++)
                {
                    if ($positions[$part] -ge $parts[$part].Count) { continue }
                    if ($selected -lt 0) { $selected = $part; continue }
                    $script:Compares++
                    if ($parts[$part][$positions[$part]] -lt $parts[$selected][$positions[$selected]]) { $selected = $part }
                }
                $Unsorted[$output] = $parts[$selected][$positions[$selected]]
                $positions[$selected]++
                $script:Swaps++
            }
        }
        function sortThree
        {
            param($Array, $Left, $Right)
            if ($Right -le $Left) { return }
            $length = $Right - $Left + 1
            $middleOne = $Left + [int][math]::Ceiling($length / 3) - 1
            $middleTwo = $Left + [int][math]::Ceiling((2 * $length) / 3) - 1
            $script:Passes++
            sortThree -Array $Array -Left $Left -Right $middleOne
            sortThree -Array $Array -Left ($middleOne + 1) -Right $middleTwo
            sortThree -Array $Array -Left ($middleTwo + 1) -Right $Right
            mergeThree -Array $Array -Left $Left -MiddleOne $middleOne -MiddleTwo $middleTwo -Right $Right
        }
        if ($Unsorted.Count -gt 1) { sortThree -Array $Unsorted -Left 0 -Right ($Unsorted.Count - 1) }
        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm = 'ThreeWayMergeSort'; ArrayLength = $Unsorted.Count; Passes = $script:Passes
                    Swaps = $script:Swaps; Compares = $script:Compares; SortedArray = $Unsorted
                })
        }
        return $Unsorted
    }
}
