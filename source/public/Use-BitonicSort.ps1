function Use-BitonicSort
{
    <#
        .DESCRIPTION
            Sorts objects with a bitonic sorting network, padding internally to a power-of-two length.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Returns sorting diagnostics and the sorted array instead of only the sorted array.
        .EXAMPLE
            3,2,1 | Use-BitonicSort
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
        $length = 1
        while ($length -lt $Unsorted.Count) { $length *= 2 }
        $values = [object[]]::new($length)
        $valid = [bool[]]::new($length)
        for ($i = 0; $i -lt $Unsorted.Count; $i++) { $values[$i] = $Unsorted[$i]; $valid[$i] = $true }

        for ($size = 2; $size -le $length; $size *= 2)
        {
            for ($stride = [int]($size / 2); $stride -gt 0; $stride = [int]($stride / 2))
            {
                $script:Passes++
                for ($i = 0; $i -lt $length; $i++)
                {
                    $partner = $i -bxor $stride
                    if ($partner -le $i) { continue }
                    $ascending = (($i -band $size) -eq 0)
                    $script:Compares++
                    $swap = $false
                    if ($valid[$i] -and -not $valid[$partner]) { $swap = -not $ascending }
                    elseif (-not $valid[$i] -and $valid[$partner]) { $swap = $ascending }
                    elseif ($valid[$i] -and $valid[$partner])
                    {
                        if ($ascending) { $swap = $values[$i] -gt $values[$partner] }
                        else { $swap = $values[$i] -lt $values[$partner] }
                    }
                    if ($swap)
                    {
                        $temp = $values[$i]; $values[$i] = $values[$partner]; $values[$partner] = $temp
                        $present = $valid[$i]; $valid[$i] = $valid[$partner]; $valid[$partner] = $present
                        $script:Swaps++
                    }
                }
            }
        }
        $Unsorted.Clear()
        for ($i = 0; $i -lt $length; $i++) { if ($valid[$i]) { $null = $Unsorted.Add($values[$i]) } }

        if ($ReturnDiagnostics)
        {
            return ([pscustomobject]@{
                    Algorithm = 'BitonicSort'; ArrayLength = $Unsorted.Count; Passes = $script:Passes
                    Swaps = $script:Swaps; Compares = $script:Compares; SortedArray = $Unsorted
                })
        }
        return $Unsorted
    }
}
