param(
    [Parameter(Mandatory = $true)]
    [string]$ProductRepository
)

$ErrorActionPreference = "Stop"

function Invoke-GitCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory
    )

    Push-Location $WorkingDirectory

    try {
        $output = @(
            & git @Arguments 2>&1 |
            ForEach-Object { $_.ToString() }
        )

        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }

    return [PSCustomObject]@{
        Output   = $output
        ExitCode = $exitCode
    }
}

function Get-GitRepositoryRoot {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CandidatePath,

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    if (-not (Test-Path -LiteralPath $CandidatePath)) {
        throw "$Description does not exist: $CandidatePath"
    }

    $resolvedPath =
    [System.IO.Path]::GetFullPath(
        (Resolve-Path -LiteralPath $CandidatePath).Path)

    $result = Invoke-GitCommand `
        -Arguments @("rev-parse", "--show-toplevel") `
        -WorkingDirectory $resolvedPath

    if ($result.ExitCode -ne 0 -or $result.Output.Count -eq 0) {
        throw "$Description is not inside a Git repository: $CandidatePath"
    }

    return [System.IO.Path]::GetFullPath(
        $result.Output[0].Trim()).TrimEnd(
            [System.IO.Path]::DirectorySeparatorChar,
            [System.IO.Path]::AltDirectorySeparatorChar)
}

function Test-PathInsideRepository {
    param(
        [Parameter(Mandatory = $true)]
        [string]$CandidatePath,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $repositoryPrefix =
    $RepositoryRoot +
    [System.IO.Path]::DirectorySeparatorChar

    return $CandidatePath.Equals(
        $RepositoryRoot,
        [System.StringComparison]::OrdinalIgnoreCase) -or
    $CandidatePath.StartsWith(
        $repositoryPrefix,
        [System.StringComparison]::OrdinalIgnoreCase)
}

$workflowRepoRoot = Get-GitRepositoryRoot `
    -CandidatePath $PSScriptRoot `
    -Description "The workflow script directory"

$productRepoRoot = Get-GitRepositoryRoot `
    -CandidatePath $ProductRepository `
    -Description "The product repository path"

if ($workflowRepoRoot.Equals(
        $productRepoRoot,
        [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "The product repository and workflow repository must be separate Git repositories."
}

$workflowProjectDirectory =
Split-Path $PSScriptRoot -Parent

$productDocsDirectory =
Join-Path $productRepoRoot "docs"

$destinationDirectory =
$env:OSU_HITSOUND_CONTEXT_MIRROR

if ([string]::IsNullOrWhiteSpace($destinationDirectory)) {
    throw "OSU_HITSOUND_CONTEXT_MIRROR is not configured. Set it to the local continuity-mirror directory before running this script."
}

$destinationDirectory =
$destinationDirectory.Trim().Trim('"').Trim("'")

$destinationDirectory =
[Environment]::ExpandEnvironmentVariables(
    $destinationDirectory)

$destinationDirectory =
[System.IO.Path]::GetFullPath(
    $destinationDirectory).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar)

if (Test-PathInsideRepository `
        -CandidatePath $destinationDirectory `
        -RepositoryRoot $workflowRepoRoot) {
    throw "OSU_HITSOUND_CONTEXT_MIRROR must point outside the workflow Git repository."
}

if (Test-PathInsideRepository `
        -CandidatePath $destinationDirectory `
        -RepositoryRoot $productRepoRoot) {
    throw "OSU_HITSOUND_CONTEXT_MIRROR must point outside the product Git repository."
}

$sourceFiles = @(
    [PSCustomObject]@{
        Source = Join-Path `
            $workflowProjectDirectory `
            "PROJECT_PROFILE.md"
        Destination = "PROJECT_PROFILE.md"
        Owner = "workflow"
    },
    [PSCustomObject]@{
        Source = Join-Path `
            $workflowProjectDirectory `
            "PROJECT_CONTEXT.md"
        Destination = "PROJECT_CONTEXT.md"
        Owner = "workflow"
    },
    [PSCustomObject]@{
        Source = Join-Path `
            $workflowProjectDirectory `
            "WORKFLOW.md"
        Destination = "WORKFLOW.md"
        Owner = "workflow"
    },
    [PSCustomObject]@{
        Source = Join-Path `
            $workflowProjectDirectory `
            "AI_WORKFLOW.md"
        Destination = "AI_WORKFLOW.md"
        Owner = "workflow"
    },
    [PSCustomObject]@{
        Source = Join-Path `
            $productDocsDirectory `
            "ROADMAP.md"
        Destination = "ROADMAP.md"
        Owner = "product"
    },
    [PSCustomObject]@{
        Source = Join-Path `
            $productDocsDirectory `
            "DECISIONS.md"
        Destination = "DECISIONS.md"
        Owner = "product"
    },
    [PSCustomObject]@{
        Source = Join-Path `
            $productDocsDirectory `
            "architecture.md"
        Destination = "architecture.md"
        Owner = "product"
    }
)

foreach ($sourceFile in $sourceFiles) {
    if (-not (Test-Path -LiteralPath $sourceFile.Source)) {
        throw "Required $($sourceFile.Owner) continuity source not found: $($sourceFile.Source)"
    }
}

if (-not (Test-Path -LiteralPath $destinationDirectory)) {
    New-Item `
        -ItemType Directory `
        -Path $destinationDirectory `
        -Force |
    Out-Null
}

foreach ($sourceFile in $sourceFiles) {
    $destinationFile =
    Join-Path `
        $destinationDirectory `
        $sourceFile.Destination

    Copy-Item `
        -LiteralPath $sourceFile.Source `
        -Destination $destinationFile `
        -Force

    $sourceHash =
    (Get-FileHash `
        -LiteralPath $sourceFile.Source `
        -Algorithm SHA256).Hash

    $destinationHash =
    (Get-FileHash `
        -LiteralPath $destinationFile `
        -Algorithm SHA256).Hash

    if ($sourceHash -ne $destinationHash) {
        throw "Synchronization verification failed for: $($sourceFile.Destination)"
    }

    Write-Host (
        "Synchronized: {0} ({1})" -f
        $sourceFile.Destination,
        $sourceFile.Owner)
}

Write-Host ""
Write-Host "Project context synchronized successfully."
