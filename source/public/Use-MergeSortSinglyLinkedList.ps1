function Use-MergeSortSinglyLinkedList
{
    <#
        .DESCRIPTION
            Sorts pipeline input with merge sort over an internal singly linked list.
        .PARAMETER InputObject
            Defines input objects to sort
        .PARAMETER ReturnDiagnostics
            Returns sorting diagnostics and the sorted array instead of only the sorted array.
        .EXAMPLE
            3,2,1 | Use-MergeSortSinglyLinkedList

            Sorts the values with merge sort over singly linked nodes.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseApprovedVerbs', '', Justification = 'Purpose of function is to mimic Sort-Object')]
    [CmdletBinding()]
    [OutputType([collections.arraylist])]
    param(
        [parameter(ValueFromPipeline, Mandatory)]$InputObject,
        [parameter()][switch]$ReturnDiagnostics
    )
    BEGIN { $Unsorted = [collections.arraylist]::new() }
    PROCESS { $InputObject | ForEach-Object { $null = $Unsorted.Add($PSItem) } }
    END { Invoke-LinkedListSort -InputList $Unsorted -Algorithm Merge -DoublyLinked $false -ReturnDiagnostics:$ReturnDiagnostics }
}
