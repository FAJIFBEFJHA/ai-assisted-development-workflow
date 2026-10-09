param(
    [Parameter(Mandatory = $true)]
    [string]$ProductRepository
)

$ErrorActionPreference = "Stop"

function Invoke-NativeCommandCaptured {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory
    )

    $previousErrorActionPreference = $ErrorActionPreference
    $previousConsoleOutputEncoding = [Console]::OutputEncoding
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)

    Push-Location $WorkingDirectory

    try {
        # Native commands such as dotnet and Git emit UTF-8 output.
        # Windows PowerShell 5.1 may otherwise decode that output using
        # the active OEM console encoding, producing mojibake.
        [Console]::OutputEncoding = $utf8NoBom

        # Native commands may legitimately write warnings to stderr.
        # Do not allow PowerShell to convert those warnings into terminating errors.
        $ErrorActionPreference = "Continue"

        $output = @(
            & $Command @Arguments 2>&1 |
            ForEach-Object { $_.ToString() }
        )

        $exitCode = $LASTEXITCODE
    }
    finally {
        [Console]::OutputEncoding = $previousConsoleOutputEncoding
        $ErrorActionPreference = $previousErrorActionPreference
        Pop-Location
    }

    return [PSCustomObject]@{
        Output   = $output
        ExitCode = $exitCode
    }
}

function Add-Section {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    "" | Add-Content -Path $Path -Encoding utf8
    "============================================================" |
    Add-Content -Path $Path -Encoding utf8
    $Title |
    Add-Content -Path $Path -Encoding utf8
    "============================================================" |
    Add-Content -Path $Path -Encoding utf8
}

function Convert-ToPortableOutput {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]]$Lines,

        [Parameter(Mandatory = $true)]
        [hashtable]$PathReplacements
    )

    return @(
        foreach ($line in $Lines) {
            $portableLine = $line

            foreach ($path in $PathReplacements.Keys) {
                $replacement = $PathReplacements[$path]

                $pathVariants = @(
                    $path,
                    ($path -replace "/", "\"),
                    ($path -replace "\\", "/")
                ) |
                Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
                Select-Object -Unique

                foreach ($pathVariant in $pathVariants) {
                    $portableLine =
                    [System.Text.RegularExpressions.Regex]::Replace(
                        $portableLine,
                        [System.Text.RegularExpressions.Regex]::Escape(
                            $pathVariant),
                        $replacement,
                        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
                }
            }

            $portableLine
        }
    )
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

    $result = Invoke-NativeCommandCaptured `
        -Command "git" `
        -Arguments @("rev-parse", "--show-toplevel") `
        -WorkingDirectory $resolvedPath

    if ($result.ExitCode -ne 0 -or $result.Output.Count -eq 0) {
        throw "$Description is not inside a Git repository: $CandidatePath"
    }

    return [System.IO.Path]::GetFullPath(
        $result.Output[0].Trim())
}

function Get-GitHead {
    param(
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $result = Invoke-NativeCommandCaptured `
        -Command "git" `
        -Arguments @("rev-parse", "HEAD") `
        -WorkingDirectory $RepositoryRoot

    if ($result.ExitCode -eq 0 -and $result.Output.Count -gt 0) {
        return $result.Output[0].Trim()
    }

    return "(no commits yet)"
}

function Add-CommandResult {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$Command,

        [Parameter(Mandatory = $true)]
        [string[]]$Arguments,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [Parameter(Mandatory = $true)]
        [hashtable]$PathReplacements,

        [string]$EmptyMessage = "(none)"
    )

    Add-Section -Title $Title -Path $OutputPath

    $result = Invoke-NativeCommandCaptured `
        -Command $Command `
        -Arguments $Arguments `
        -WorkingDirectory $WorkingDirectory

    $portableOutput = Convert-ToPortableOutput `
        -Lines $result.Output `
        -PathReplacements $PathReplacements

    if ($portableOutput.Count -gt 0) {
        $portableOutput |
        Add-Content -Path $OutputPath -Encoding utf8
    }
    else {
        $EmptyMessage |
        Add-Content -Path $OutputPath -Encoding utf8
    }

    "" | Add-Content -Path $OutputPath -Encoding utf8
    "$Command exit code: $($result.ExitCode)" |
    Add-Content -Path $OutputPath -Encoding utf8

    return $result
}

function Add-UntrackedFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [Parameter(Mandatory = $true)]
        [hashtable]$PathReplacements
    )

    Add-Section -Title $Title -Path $OutputPath

    $untrackedResult = Invoke-NativeCommandCaptured `
        -Command "git" `
        -Arguments @(
            "ls-files",
            "--others",
            "--exclude-standard"
        ) `
        -WorkingDirectory $RepositoryRoot

    $untrackedFiles = $untrackedResult.Output

    $textExtensions = @(
        ".cs",
        ".csproj",
        ".md",
        ".txt",
        ".json",
        ".xml",
        ".props",
        ".targets",
        ".ps1",
        ".yml",
        ".yaml",
        ".sln",
        ".slnx"
    )

    if ($untrackedFiles.Count -eq 0) {
        "(none)" |
        Add-Content -Path $OutputPath -Encoding utf8
        return
    }

    foreach ($file in $untrackedFiles) {
        "" | Add-Content -Path $OutputPath -Encoding utf8

        "----- $file -----" |
        Add-Content -Path $OutputPath -Encoding utf8

        $fullPath = Join-Path $RepositoryRoot $file

        $extension =
        [System.IO.Path]::GetExtension(
            $file).ToLowerInvariant()

        $name =
        [System.IO.Path]::GetFileName($file)

        if (
            $extension -in $textExtensions -or
            $name -eq ".editorconfig"
        ) {
            $rawContent = Get-Content `
                -LiteralPath $fullPath `
                -Raw `
                -Encoding UTF8

            $portableContent = Convert-ToPortableOutput `
                -Lines @($rawContent) `
                -PathReplacements $PathReplacements

            $portableContent |
            Add-Content `
                -Path $OutputPath `
                -Encoding utf8
        }
        else {
            "[Binary or unsupported text file - content omitted]" |
            Add-Content `
                -Path $OutputPath `
                -Encoding utf8
        }
    }
}

$productRepoRoot = Get-GitRepositoryRoot `
    -CandidatePath $ProductRepository `
    -Description "The product repository path"

$workflowRepoRoot = Get-GitRepositoryRoot `
    -CandidatePath $PSScriptRoot `
    -Description "The workflow script directory"

if ($productRepoRoot.Equals(
        $workflowRepoRoot,
        [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "The product repository and workflow repository must be separate Git repositories."
}

$productRepoName = Split-Path $productRepoRoot -Leaf
$productRepoParent = Split-Path $productRepoRoot -Parent

$generatedAt = Get-Date
$dateFolder = $generatedAt.ToString("yyyy-MM-dd")
$timestamp = $generatedAt.ToString("yyyy-MM-dd_HH-mm-ss")

$reviewRoot = Join-Path `
    $productRepoParent `
    "$productRepoName-session-reviews"

$reviewDirectory = Join-Path `
    $reviewRoot `
    $dateFolder

New-Item `
    -ItemType Directory `
    -Path $reviewDirectory `
    -Force |
Out-Null

$fileName =
"$productRepoName-session-review_$timestamp.txt"

$outputPath = Join-Path `
    $reviewDirectory `
    $fileName

$pathReplacements = @{
    $productRepoRoot  = "<product-repo-root>"
    $workflowRepoRoot = "<workflow-repo-root>"
}

$productHead = Get-GitHead `
    -RepositoryRoot $productRepoRoot

$workflowHead = Get-GitHead `
    -RepositoryRoot $workflowRepoRoot

@(
    "OSU HITSOUND EDITOR - SESSION REVIEW"
    "Generated: $($generatedAt.ToString('yyyy-MM-dd HH:mm:ss'))"
    "Product repository: $productRepoName"
    "Product HEAD: $productHead"
    "Workflow repository: $(Split-Path $workflowRepoRoot -Leaf)"
    "Workflow HEAD: $workflowHead"
) | Set-Content -Path $outputPath -Encoding utf8

$testResult = Add-CommandResult `
    -Title "PRODUCT - DOTNET TEST" `
    -Command "dotnet" `
    -Arguments @("test") `
    -WorkingDirectory $productRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(no output)"

$productStatusResult = Add-CommandResult `
    -Title "PRODUCT - GIT STATUS" `
    -Command "git" `
    -Arguments @("status", "--short") `
    -WorkingDirectory $productRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(clean)"

Add-CommandResult `
    -Title "PRODUCT - DIFF STAT" `
    -Command "git" `
    -Arguments @("diff", "--stat") `
    -WorkingDirectory $productRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(no tracked unstaged changes)" |
Out-Null

$productDiffCheckResult = Add-CommandResult `
    -Title "PRODUCT - DIFF CHECK" `
    -Command "git" `
    -Arguments @("diff", "--check") `
    -WorkingDirectory $productRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(no issues)"

Add-CommandResult `
    -Title "PRODUCT - UNSTAGED TRACKED DIFF" `
    -Command "git" `
    -Arguments @(
        "diff",
        "--no-ext-diff",
        "--text"
    ) `
    -WorkingDirectory $productRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(none)" |
Out-Null

Add-CommandResult `
    -Title "PRODUCT - STAGED DIFF" `
    -Command "git" `
    -Arguments @(
        "diff",
        "--cached",
        "--no-ext-diff",
        "--text"
    ) `
    -WorkingDirectory $productRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(none)" |
Out-Null

Add-UntrackedFiles `
    -Title "PRODUCT - UNTRACKED FILES" `
    -RepositoryRoot $productRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements

$workflowStatusResult = Add-CommandResult `
    -Title "WORKFLOW - GIT STATUS" `
    -Command "git" `
    -Arguments @("status", "--short") `
    -WorkingDirectory $workflowRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(clean)"

Add-CommandResult `
    -Title "WORKFLOW - DIFF STAT" `
    -Command "git" `
    -Arguments @("diff", "--stat") `
    -WorkingDirectory $workflowRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(no tracked unstaged changes)" |
Out-Null

$workflowDiffCheckResult = Add-CommandResult `
    -Title "WORKFLOW - DIFF CHECK" `
    -Command "git" `
    -Arguments @("diff", "--check") `
    -WorkingDirectory $workflowRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(no issues)"

Add-CommandResult `
    -Title "WORKFLOW - UNSTAGED TRACKED DIFF" `
    -Command "git" `
    -Arguments @(
        "diff",
        "--no-ext-diff",
        "--text"
    ) `
    -WorkingDirectory $workflowRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(none)" |
Out-Null

Add-CommandResult `
    -Title "WORKFLOW - STAGED DIFF" `
    -Command "git" `
    -Arguments @(
        "diff",
        "--cached",
        "--no-ext-diff",
        "--text"
    ) `
    -WorkingDirectory $workflowRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements `
    -EmptyMessage "(none)" |
Out-Null

Add-UntrackedFiles `
    -Title "WORKFLOW - UNTRACKED FILES" `
    -RepositoryRoot $workflowRepoRoot `
    -OutputPath $outputPath `
    -PathReplacements $pathReplacements

Add-Section -Title "SUMMARY" -Path $outputPath

if ($testResult.ExitCode -eq 0) {
    "Product tests: PASS" |
    Add-Content -Path $outputPath -Encoding utf8
}
else {
    "Product tests: FAIL" |
    Add-Content -Path $outputPath -Encoding utf8
}

if ($productStatusResult.Output.Count -gt 0) {
    "Product repository has uncommitted changes." |
    Add-Content -Path $outputPath -Encoding utf8
}
else {
    "Product repository is clean." |
    Add-Content -Path $outputPath -Encoding utf8
}

if ($workflowStatusResult.Output.Count -gt 0) {
    "Workflow repository has uncommitted changes." |
    Add-Content -Path $outputPath -Encoding utf8
}
else {
    "Workflow repository is clean." |
    Add-Content -Path $outputPath -Encoding utf8
}

Write-Host ""
Write-Host "Session review created:"
Write-Host $outputPath

if ($testResult.ExitCode -ne 0) {
    Write-Warning "Product tests failed. Review the report before committing."
}

if ($productDiffCheckResult.ExitCode -ne 0) {
    Write-Warning "Product git diff --check reported issues. Review the report before committing."
}

if ($workflowDiffCheckResult.ExitCode -ne 0) {
    Write-Warning "Workflow git diff --check reported issues. Review the report before committing."
}
