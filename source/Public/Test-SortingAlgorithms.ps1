function Test-SortingAlgorithms
{
    <#
        .DESCRIPTION
            A demo function to run all sort algorithms
        .EXAMPLE
            Test-SortingAlgorithms

            Description of example
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '', Justification = 'False positive')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Sole purpose of function is to run for all available functions in module.')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseCompatibleCommands', '', Justification = 'Only core is supported by the module')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingInvokeExpression', '', Justification = 'This function calls module cmdlets from a list to simplyfy code. non-production')]
    [CmdletBinding()] # Enabled advanced function support
    param(
    )

    BEGIN
    {

        Write-Warning 'NOTE: The built in Sort-Object is a compiled cmdlet and will be much faster compared to script based implementations of sorting algoritms. A fair comparison can be made between all other script based algorithms'

        $List = 1..1000 | Get-Random -Shuffle

        $SortAlgorithms = @(
            'Sort-Object',
            'Use-QuickSort',
            'Use-BubbleSort'
        )
    }

    PROCESS
    {
        foreach ($Object in $SortAlgorithms)
        {
            $measure = Measure-Command -Expression {
                $SortedList = Invoke-Expression -Command ('{0} | {1} -Verbose' -f (([string[]]$List) -join ','), $Object )
            }
            [pscustomobject]@{
                Algorithm = $Object
                Time      = $Measure.TotalMilliseconds
                Result    = $SortedList
            }
        }
    }

    END
    {

    }

}
#endregion
