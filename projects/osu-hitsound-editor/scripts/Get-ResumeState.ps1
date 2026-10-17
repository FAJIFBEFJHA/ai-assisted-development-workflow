param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$ProductRepository,

    [ValidateRange(1, 30)]
    [int]$RecentCommits = 5,

    [ValidateRange(1, 200)]
    [int]$MaxFiles = 20
)

$ErrorActionPreference = 'Stop'

function Invoke-GitRead {
    param(
        [Parameter(Mandatory = $true)] [string]$Repository,
        [Parameter(Mandatory = $true)] [string[]]$Arguments
    )

    # Git is invoked only with inspection operations; do not add pull/fetch/test here.
    $lines = @(& git -C $Repository -c core.quotepath=false @Arguments 2>&1 |
        ForEach-Object { $_.ToString() })
    return [pscustomobject]@{
        Lines = $lines
        ExitCode = $LASTEXITCODE
    }
}

function Get-RequiredGitOutput {
    param([string]$Repository, [string[]]$Arguments, [string]$Label)
    $result = Invoke-GitRead -Repository $Repository -Arguments $Arguments
    if ($result.ExitCode -ne 0) {
        throw "Failed to inspect $Label (Git exit code $($result.ExitCode)): $($result.Lines -join ' ')"
    }
    return ,@($result.Lines)
}

function Resolve-RepositoryRoot {
    param([string]$Path, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "$Label does not exist or is not a directory: $Path"
    }
    $lines = Get-RequiredGitOutput -Repository $Path -Arguments @('rev-parse', '--show-toplevel') -Label $Label
    if ($lines.Count -ne 1 -or [string]::IsNullOrWhiteSpace($lines[0])) {
        throw "Could not determine the Git root for $Label."
    }
    return [IO.Path]::GetFullPath($lines[0].Trim())
}

function Write-Section {
    param([string]$Title)
    Write-Output ''
    Write-Output "=== $Title ==="
}

function Write-LimitedItems {
    param([string]$Label, [object[]]$Items, [int]$Limit)
    $itemsArray = @($Items | Where-Object { $null -ne $_ -and $_.ToString().Length -gt 0 })
    Write-Output "$Label`: $($itemsArray.Count)"
    $visible = [Math]::Min($itemsArray.Count, $Limit)
    for ($i = 0; $i -lt $visible; $i++) {
        Write-Output "  $($itemsArray[$i])"
    }
    if ($itemsArray.Count -gt $Limit) {
        Write-Output "  ... $($itemsArray.Count - $Limit) more not shown"
    }
}

function Get-PathCategory {
    param([string]$Path, [bool]$IsWorkflow)
    $normalized = $Path.Replace('\', '/')
    if ($IsWorkflow) {
        if ($normalized -match '^projects/osu-hitsound-editor/(AI_WORKFLOW\.md|WORKFLOW\.md|PROJECT_PROFILE\.md|PROJECT_CONTEXT\.md)$') {
            return 'Project workflow documents'
        }
        if ($normalized -like 'projects/osu-hitsound-editor/scripts/*') {
            return 'Project workflow scripts'
        }
        if ($normalized -like 'projects/osu-hitsound-editor/*') {
            return 'Other project workflow files'
        }
        return 'Other workflow repository files'
    }
    if ($normalized -like 'src/*') { return 'Production files' }
    if ($normalized -like 'tests/*') { return 'Test files' }
    if ($normalized -like 'docs/*') { return 'Product documentation' }
    return 'Other product files'
}

function Get-EntriesFromStatus {
    param([string[]]$Lines, [bool]$IsWorkflow)
    $entries = @()
    foreach ($line in $Lines) {
        if ($line.Length -lt 4) { continue }
        $path = $line.Substring(3).Trim('"')
        if ($path -match ' -> ') { $path = ($path -split ' -> ')[-1].Trim('"') }
        $entries += [pscustomobject]@{
            Category = Get-PathCategory -Path $path -IsWorkflow $IsWorkflow
            Display = "$($line.Substring(0,2)) $path"
        }
    }
    return $entries
}

function Get-EntriesFromDiff {
    param([string[]]$Lines, [bool]$IsWorkflow)
    $entries = @()
    foreach ($line in $Lines) {
        $fields = $line -split "`t"
        if ($fields.Count -lt 2) { continue }
        $path = $fields[-1]
        $entries += [pscustomobject]@{
            Category = Get-PathCategory -Path $path -IsWorkflow $IsWorkflow
            Display = "$($fields[0]) $path"
        }
    }
    return $entries
}

function Write-EntryCategories {
    param([object[]]$Entries, [bool]$IsWorkflow, [int]$Limit)
    $categories = if ($IsWorkflow) {
        @('Project workflow documents', 'Project workflow scripts', 'Other project workflow files', 'Other workflow repository files')
    } else {
        @('Production files', 'Test files', 'Product documentation', 'Other product files')
    }
    foreach ($category in $categories) {
        $matching = @($Entries | Where-Object { $_.Category -eq $category } | ForEach-Object { $_.Display })
        Write-LimitedItems -Label $category -Items $matching -Limit $Limit
    }
}

function Write-RepoSummary {
    param([string]$Repository, [string]$Label, [bool]$IsWorkflow, [int]$Limit, [int]$CommitLimit)
    Write-Section $Label
    $head = Get-RequiredGitOutput -Repository $Repository -Arguments @('rev-parse', 'HEAD') -Label "$Label HEAD"
    $branch = Get-RequiredGitOutput -Repository $Repository -Arguments @('branch', '--show-current') -Label "$Label branch"
    Write-Output "HEAD: $($head[0])"
    Write-Output "Branch: $(if ($branch.Count -and $branch[0]) { $branch[0] } else { 'DETACHED' })"

    $upstream = Invoke-GitRead -Repository $Repository -Arguments @('rev-parse', '--abbrev-ref', '--symbolic-full-name', '@{upstream}')
    if ($upstream.ExitCode -eq 0 -and $upstream.Lines.Count -gt 0) {
        $name = $upstream.Lines[0].Trim()
        $counts = Get-RequiredGitOutput -Repository $Repository -Arguments @('rev-list', '--left-right', '--count', "HEAD...$name") -Label "$Label upstream comparison"
        $parts = $counts[0].Trim() -split '\s+'
        if ($parts.Count -ne 2 -or $parts[0] -notmatch '^\d+$' -or $parts[1] -notmatch '^\d+$') {
            throw "Unexpected Git upstream-count output for $Label."
        }
        Write-Output "Upstream (local reference only; no fetch): $name | ahead $($parts[0]) | behind $($parts[1])"
    } else {
        Write-Output 'Upstream: none or unavailable (not interpreted as up to date)'
    }

    $status = Get-RequiredGitOutput -Repository $Repository -Arguments @('status', '--porcelain=v1', '--untracked-files=all') -Label "$Label status"
    Write-Output "Working tree: $(if ($status.Count -eq 0) { 'CLEAN' } else { 'HAS CHANGES' })"
    $localEntries = @(Get-EntriesFromStatus -Lines $status -IsWorkflow $IsWorkflow)
    Write-EntryCategories -Entries $localEntries -IsWorkflow $IsWorkflow -Limit $Limit

    $recentArgs = @('log', "--max-count=$CommitLimit", '--format=%h %as %s')
    if ($IsWorkflow) {
        $recentArgs += @('--', 'projects/osu-hitsound-editor/')
    }
    $recent = Get-RequiredGitOutput -Repository $Repository -Arguments $recentArgs -Label "$Label recent commits"
    Write-LimitedItems -Label "Recent $(if ($IsWorkflow) { 'project-specific ' } else { '' })commits (historical)" -Items $recent -Limit $CommitLimit
}

function Get-CheckpointInfo {
    param([string]$WorkflowRoot)
    $path = Join-Path $WorkflowRoot 'projects/osu-hitsound-editor/PROJECT_CONTEXT.md'
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        return [pscustomobject]@{ Commit = $null; Suite = $null; Issue = 'PROJECT_CONTEXT.md is missing.' }
    }
    $text = Get-Content -LiteralPath $path -Raw -Encoding UTF8
    $commitMatch = [regex]::Match($text, '(?ms)Product checkpoint:\s*```text\s*.*?^\s*Commit:\s*([0-9a-f]{7,40})\s*$')
    $suiteMatch = [regex]::Match($text, '(?m)^\s*(\d+/\d+\s+passing;[^\r\n]+)')
    $commit = $null
    $suite = $null
    $issue = $null
    if ($commitMatch.Success) { $commit = $commitMatch.Groups[1].Value }
    else { $issue = 'Product checkpoint SHA could not be parsed.' }
    if ($suiteMatch.Success) { $suite = $suiteMatch.Groups[1].Value.Trim() }
    return [pscustomobject]@{
        Commit = $commit
        Suite = $suite
        Issue = $issue
    }
}

$productRoot = Resolve-RepositoryRoot -Path $ProductRepository -Label 'Product repository'
$workflowRoot = Resolve-RepositoryRoot -Path $PSScriptRoot -Label 'Workflow repository'
if ($productRoot.TrimEnd('\', '/') -eq $workflowRoot.TrimEnd('\', '/')) {
    throw 'Product and workflow repositories must be distinct.'
}

$checkpoint = Get-CheckpointInfo -WorkflowRoot $workflowRoot
Write-Output 'OSU HITSOUND EDITOR - RESUME DIAGNOSTIC'
Write-Output 'Read-only report. Git upstream references are local snapshots; no network refresh.'
Write-Output 'No tests, builds, commits, patches, or files were generated.'

Write-RepoSummary -Repository $productRoot -Label 'PRODUCT' -IsWorkflow $false -Limit $MaxFiles -CommitLimit $RecentCommits

Write-Section 'PRODUCT CHECKPOINT COMPARISON'
Write-Output "Documented checkpoint: $(if ($checkpoint.Commit) { $checkpoint.Commit } else { 'UNKNOWN' })"
if ($checkpoint.Issue) { Write-Output "WARNING: $($checkpoint.Issue)" }
$changedSourceOrTests = $null
if ($checkpoint.Commit) {
    $exists = Invoke-GitRead -Repository $productRoot -Arguments @('cat-file', '-e', "$($checkpoint.Commit)^{commit}")
    if ($exists.ExitCode -ne 0) {
        Write-Output 'WARNING: Checkpoint commit is unavailable locally; differences cannot be determined.'
    } else {
        $ancestor = Invoke-GitRead -Repository $productRoot -Arguments @('merge-base', '--is-ancestor', $checkpoint.Commit, 'HEAD')
        if ($ancestor.ExitCode -eq 1) {
            Write-Output 'WARNING: Checkpoint is not an ancestor of HEAD; comparison shows net snapshot differences, not chronological work since checkpoint.'
        } elseif ($ancestor.ExitCode -ne 0) {
            throw "Failed to compare checkpoint ancestry (Git exit code $($ancestor.ExitCode))."
        }
        $changes = Get-RequiredGitOutput -Repository $productRoot -Arguments @('diff', '--name-status', '--find-renames', $checkpoint.Commit, 'HEAD', '--') -Label 'product checkpoint diff'
        $committedEntries = @(Get-EntriesFromDiff -Lines $changes -IsWorkflow $false)
        Write-EntryCategories -Entries $committedEntries -IsWorkflow $false -Limit $MaxFiles
        $changedSourceOrTests = @($committedEntries | Where-Object { $_.Category -in @('Production files', 'Test files') }).Count -gt 0
        if ($ancestor.ExitCode -eq 0) {
            $commitRange = "$($checkpoint.Commit)..HEAD"
            $commitCount = Get-RequiredGitOutput -Repository $productRoot -Arguments @('rev-list', '--count', $commitRange) -Label 'product commits since checkpoint'
            Write-Output "Product commits since checkpoint: $($commitCount[0])"
            $recentSince = Get-RequiredGitOutput -Repository $productRoot -Arguments @('log', "--max-count=$RecentCommits", '--format=%h %as %s', $commitRange) -Label 'recent product commits since checkpoint'
            Write-LimitedItems -Label 'Recent product commits since checkpoint' -Items $recentSince -Limit $RecentCommits
            $touched = Get-RequiredGitOutput -Repository $productRoot -Arguments @('log', '--format=', '--name-only', "$($checkpoint.Commit)..HEAD", '--', 'tests/') -Label 'tests touched since checkpoint'
            $distinctTouched = @($touched | Where-Object { $_ } | Sort-Object -Unique)
            Write-LimitedItems -Label 'Test files touched in commits since checkpoint (includes files later reverted)' -Items $distinctTouched -Limit $MaxFiles
        }
    }
}

Write-Section 'TEST VERIFICATION'
Write-Output "Historical suite in PROJECT_CONTEXT.md: $(if ($checkpoint.Suite) { $checkpoint.Suite } else { 'UNKNOWN' })"
Write-Output 'Current suite executed by this diagnostic: NO'
$localProductStatus = Get-RequiredGitOutput -Repository $productRoot -Arguments @('status', '--porcelain=v1', '--untracked-files=all') -Label 'product test freshness'
$localChanged = @(Get-EntriesFromStatus -Lines $localProductStatus -IsWorkflow $false)
$unverifiedLocals = @($localChanged | Where-Object { $_.Category -in @('Production files', 'Test files') }).Count -gt 0
if ($null -eq $changedSourceOrTests) {
    Write-Output 'Current source/test verification against checkpoint: UNKNOWN (checkpoint comparison unavailable)'
} elseif ($changedSourceOrTests -or $unverifiedLocals) {
    Write-Output 'Current source/test verification against checkpoint: RECHECK NEEDED (source or tests differ)'
} else {
    Write-Output 'Current source/test verification against checkpoint: NO SOURCE/TEST DIFF DETECTED (historical suite is not a new run)'
}

Write-RepoSummary -Repository $workflowRoot -Label 'WORKFLOW' -IsWorkflow $true -Limit $MaxFiles -CommitLimit $RecentCommits

Write-Section 'RECOVERY LIMITATIONS'
Write-Output 'Recent workflow commits are historical; without a workflow baseline they do not establish a full since-last-chat delta.'
Write-Output 'Git does not reconstruct unrecorded chat decisions or personal-terminal configuration.'
Write-Output 'Review this report before sharing it: repository-relative filenames may contain sensitive information.'
