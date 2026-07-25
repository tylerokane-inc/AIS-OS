<#
Shared ClickUp hierarchy + task push capability, used by the project-planner and
clickup-capture skills. Written for Windows PowerShell 5.1 (no pwsh/PS7-only syntax).

Auth + endpoint reference: ..\references\clickup-api.md
Hierarchy cache: .\clickup_project_map.json (committed, IDs only, no secrets)

Every action prints JSON to stdout on success. On failure it throws a terminating
error (clear message to stderr, non-zero exit) rather than retrying or hiding it.
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet(
        'list-spaces', 'create-space',
        'list-folders', 'create-folder',
        'list-lists', 'create-list', 'create-folderless-list',
        'create-task', 'update-task', 'add-comment',
        'resolve', 'remember', 'remember-phase',
        'push-plan', 'quick-add'
    )]
    [string]$Action,

    [string]$Name,
    [string]$SpaceId,
    [string]$FolderId,
    [string]$ListId,
    [string]$TaskId,
    [string]$ParentTaskId,
    [string]$Project,
    [string]$Phase,
    [string]$ChecklistFile,
    [string]$Steps,
    [string]$Status,
    [string]$CommentText,
    [string]$TeamId = "90141451608"
)

$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
$EnvPath = Join-Path $RepoRoot ".env"
$MapPath = Join-Path $PSScriptRoot "clickup_project_map.json"
$BaseUrl = "https://api.clickup.com/api/v2"

function Get-ClickUpToken {
    if (-not (Test-Path $EnvPath)) {
        throw "No .env file found at $EnvPath"
    }
    $line = Get-Content $EnvPath -Encoding UTF8 | Where-Object { $_ -match '^\s*CLICKUP_API_TOKEN\s*=' }
    if (-not $line) {
        throw "CLICKUP_API_TOKEN not found in .env"
    }
    $token = ($line -split '=', 2)[1]
    return $token.Trim().Trim('"').Trim("'")
}

function Invoke-ClickUp {
    param(
        [Parameter(Mandatory = $true)][string]$Method,
        [Parameter(Mandatory = $true)][string]$Path,
        [object]$Body
    )
    $token = Get-ClickUpToken
    $headers = @{ Authorization = $token; "Content-Type" = "application/json" }
    $uri = "$BaseUrl$Path"
    try {
        if ($Body) {
            $json = $Body | ConvertTo-Json -Depth 10
            return Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers -Body $json
        }
        return Invoke-RestMethod -Uri $uri -Method $Method -Headers $headers
    }
    catch {
        $errorBody = $null
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            $errorBody = $_.ErrorDetails.Message
        }
        elseif ($_.Exception.Response) {
            try {
                $stream = $_.Exception.Response.GetResponseStream()
                $stream.Position = 0
                $reader = New-Object System.IO.StreamReader($stream)
                $errorBody = $reader.ReadToEnd()
            }
            catch {}
        }
        $msg = "ClickUp API call failed: $Method $Path"
        if ($errorBody) { $msg = "$msg -- $errorBody" } else { $msg = "$msg -- $($_.Exception.Message)" }
        throw $msg
    }
}

function Get-ProjectMap {
    if (-not (Test-Path $MapPath)) {
        return [PSCustomObject]@{}
    }
    $raw = Get-Content $MapPath -Raw -Encoding UTF8
    if ([string]::IsNullOrWhiteSpace($raw)) {
        return [PSCustomObject]@{}
    }
    return $raw | ConvertFrom-Json
}

function Save-ProjectMap {
    param([Parameter(Mandatory = $true)][object]$MapObject)
    $MapObject | ConvertTo-Json -Depth 10 | Set-Content -Path $MapPath -Encoding utf8
}

function New-ClickUpTask {
    param(
        [Parameter(Mandatory = $true)][string]$ListId,
        [Parameter(Mandatory = $true)][string]$Title,
        [string]$Parent,
        [string]$Status
    )
    $body = @{ name = $Title }
    if ($Parent) { $body.parent = $Parent }
    if ($Status) { $body.status = $Status }
    return Invoke-ClickUp -Method POST -Path "/list/$ListId/task" -Body $body
}

switch ($Action) {

    'list-spaces' {
        (Invoke-ClickUp -Method GET -Path "/team/$TeamId/space") | ConvertTo-Json -Depth 10
    }

    'create-space' {
        if (-not $Name) { throw "-Name is required for create-space" }
        $body = @{ name = $Name; multiple_assignees = $true; features = @{} }
        (Invoke-ClickUp -Method POST -Path "/team/$TeamId/space" -Body $body) | ConvertTo-Json -Depth 10
    }

    'list-folders' {
        if (-not $SpaceId) { throw "-SpaceId is required for list-folders" }
        (Invoke-ClickUp -Method GET -Path "/space/$SpaceId/folder") | ConvertTo-Json -Depth 10
    }

    'create-folder' {
        if (-not $SpaceId -or -not $Name) { throw "-SpaceId and -Name are required for create-folder" }
        $body = @{ name = $Name }
        (Invoke-ClickUp -Method POST -Path "/space/$SpaceId/folder" -Body $body) | ConvertTo-Json -Depth 10
    }

    'list-lists' {
        if (-not $FolderId) { throw "-FolderId is required for list-lists" }
        (Invoke-ClickUp -Method GET -Path "/folder/$FolderId/list") | ConvertTo-Json -Depth 10
    }

    'create-list' {
        if (-not $FolderId -or -not $Name) { throw "-FolderId and -Name are required for create-list" }
        $body = @{ name = $Name }
        (Invoke-ClickUp -Method POST -Path "/folder/$FolderId/list" -Body $body) | ConvertTo-Json -Depth 10
    }

    'create-folderless-list' {
        if (-not $SpaceId -or -not $Name) { throw "-SpaceId and -Name are required for create-folderless-list" }
        $body = @{ name = $Name }
        (Invoke-ClickUp -Method POST -Path "/space/$SpaceId/list" -Body $body) | ConvertTo-Json -Depth 10
    }

    'create-task' {
        if (-not $ListId -or -not $Name) { throw "-ListId and -Name are required for create-task" }
        (New-ClickUpTask -ListId $ListId -Title $Name -Parent $ParentTaskId -Status $Status) | ConvertTo-Json -Depth 10
    }

    'update-task' {
        # Rename and/or re-status an existing task. Send only what changed.
        if (-not $TaskId) { throw "-TaskId is required for update-task" }
        if (-not $Name -and -not $Status) { throw "update-task needs -Name and/or -Status to change" }
        $body = @{}
        if ($Name) { $body.name = $Name }
        if ($Status) { $body.status = $Status }
        (Invoke-ClickUp -Method PUT -Path "/task/$TaskId" -Body $body) | ConvertTo-Json -Depth 10
    }

    'add-comment' {
        if (-not $TaskId -or -not $CommentText) { throw "-TaskId and -CommentText are required for add-comment" }
        $body = @{ comment_text = $CommentText }
        (Invoke-ClickUp -Method POST -Path "/task/$TaskId/comment" -Body $body) | ConvertTo-Json -Depth 10
    }

    'resolve' {
        if (-not $Project) { throw "-Project is required for resolve" }
        $map = Get-ProjectMap
        if ($map.PSObject.Properties.Name -contains $Project) {
            $map.$Project | ConvertTo-Json -Depth 10
        }
        else {
            Write-Output "null"
        }
    }

    'remember' {
        # Two shapes, depending on what the caller passes:
        #  - FolderId given -> a project-planner-style project: a Folder with one List
        #    per phase (recorded separately via remember-phase as they're created).
        #  - ListId given instead (no FolderId) -> a simple flat bucket, e.g.
        #    clickup-capture's `_default_capture` Inbox, or any one-off that doesn't need
        #    phase breakdown. Exactly one of FolderId/ListId must be given.
        if (-not $Project) { throw "-Project is required for remember" }
        if (-not $SpaceId) { throw "-SpaceId is required for remember" }
        if (-not $FolderId -and -not $ListId) { throw "remember needs either -FolderId (project with phases) or -ListId (simple flat bucket)" }
        if ($FolderId -and $ListId) { throw "remember takes -FolderId OR -ListId, not both" }

        $map = Get-ProjectMap
        $existingPhases = [PSCustomObject]@{}
        if ($map.PSObject.Properties.Name -contains $Project) {
            if ($map.$Project.PSObject.Properties.Name -contains 'phases') { $existingPhases = $map.$Project.phases }
            $map.PSObject.Properties.Remove($Project)
        }

        if ($FolderId) {
            $entry = [PSCustomObject]@{
                space_id  = $SpaceId
                folder_id = $FolderId
                phases    = $existingPhases
                last_used = (Get-Date -Format "yyyy-MM-dd")
            }
        }
        else {
            $entry = [PSCustomObject]@{
                space_id  = $SpaceId
                list_id   = $ListId
                last_used = (Get-Date -Format "yyyy-MM-dd")
            }
        }
        $map | Add-Member -NotePropertyName $Project -NotePropertyValue $entry
        Save-ProjectMap -MapObject $map
        $entry | ConvertTo-Json -Depth 10
    }

    'remember-phase' {
        # Records one phase's List ID under an already-remembered project, so a
        # crash mid-push doesn't lose track of Lists already created.
        if (-not $Project -or -not $Phase -or -not $ListId) {
            throw "-Project, -Phase, and -ListId are required for remember-phase"
        }
        $map = Get-ProjectMap
        if ($map.PSObject.Properties.Name -notcontains $Project) {
            throw "Project '$Project' has no top-level entry yet -- call -Action remember first"
        }
        $entry = $map.$Project
        if ($entry.phases.PSObject.Properties.Name -contains $Phase) {
            $entry.phases.($Phase) = $ListId
        }
        else {
            $entry.phases | Add-Member -NotePropertyName $Phase -NotePropertyValue $ListId
        }
        Save-ProjectMap -MapObject $map
        $entry.phases | ConvertTo-Json -Depth 10
    }

    'push-plan' {
        # Model: one Folder per project, one List per phase inside that Folder, one
        # plain Task per step inside its phase's List. A line indented under a task
        # becomes a native ClickUp subtask of that task (for a task's own small
        # sub-steps only) -- phases themselves are never subtasks, they're always
        # their own List, so a whole phase is still visible in one screen.
        #
        # A task line may carry a " :: " suffix -- everything after it is posted as a
        # ClickUp comment on that task right after creation, instead of living in the
        # task title. This is how Discovery answers stay out of task names and land in
        # comments instead: "- [x] What does this need to connect to? :: Nothing --
        # local-first, see product-spec.md" creates a task titled just the question,
        # marked complete, with the answer as its first comment.
        #
        # Incremental by design: a phase already in the cached `phases` map is
        # treated as already-pushed and its task lines are SKIPPED entirely on this
        # run -- only phases new to this checklist file (e.g. a freshly-added
        # "Expansion --" section) get their tasks created. This is what lets Tyler
        # append new Expansion phases to the same checklist file weeks later and
        # re-run push-plan without duplicating anything already in ClickUp.
        if (-not $Project -or -not $FolderId -or -not $ChecklistFile) {
            throw "-Project, -FolderId, and -ChecklistFile are required for push-plan"
        }
        if (-not (Test-Path $ChecklistFile)) { throw "Checklist file not found: $ChecklistFile" }

        $currentPhase = ""
        $currentListId = $null
        $phaseIsNew = $false
        $lastTopTaskId = $null
        $inFence = $false
        $listsCreated = @()
        $created = @()
        $skipped = @()
        $failed = @()

        foreach ($line in (Get-Content $ChecklistFile -Encoding UTF8)) {
            if ($line -match '^\s*```') {
                $inFence = -not $inFence
                continue
            }
            if ($inFence) {
                # Fenced code blocks are documentation/examples inside the checklist file
                # (e.g. the template's own sample of subtask syntax) -- never real phases
                # or tasks, so skip everything inside one regardless of what it looks like.
                continue
            }
            if ($line -match '^\s*##\s+(.+)$') {
                $currentPhase = $matches[1].Trim()
                $lastTopTaskId = $null
                $map = Get-ProjectMap
                $entry = $map.$Project
                if ($entry.phases.PSObject.Properties.Name -contains $currentPhase) {
                    $currentListId = $entry.phases.($currentPhase)
                    $phaseIsNew = $false
                }
                else {
                    $newList = Invoke-ClickUp -Method POST -Path "/folder/$FolderId/list" -Body @{ name = $currentPhase }
                    $currentListId = $newList.id
                    $entry.phases | Add-Member -NotePropertyName $currentPhase -NotePropertyValue $currentListId
                    Save-ProjectMap -MapObject $map
                    $listsCreated += [PSCustomObject]@{ phase = $currentPhase; list_id = $currentListId }
                    $phaseIsNew = $true
                    Start-Sleep -Milliseconds 650
                }
            }
            elseif ($line -match '^(\s*)-\s*\[( |x|X)\]\s*(.+)$') {
                $indent = $matches[1]
                $taskStatus = if ($matches[2] -ne ' ') { 'complete' } else { $null }
                $rawTitle = $matches[3].Trim()
                $commentText = $null
                $splitIdx = $rawTitle.IndexOf(' :: ')
                if ($splitIdx -ge 0) {
                    $commentText = $rawTitle.Substring($splitIdx + 4).Trim()
                    $title = $rawTitle.Substring(0, $splitIdx).Trim()
                }
                else {
                    $title = $rawTitle
                }
                if (-not $currentListId) {
                    $failed += [PSCustomObject]@{ title = $title; error = "No phase header found before this item" }
                    continue
                }
                if (-not $phaseIsNew) {
                    $skipped += [PSCustomObject]@{ phase = $currentPhase; title = $title }
                    continue
                }
                $isSubtask = ($indent.Length -gt 0) -and $lastTopTaskId
                try {
                    if ($isSubtask) {
                        $result = New-ClickUpTask -ListId $currentListId -Title $title -Parent $lastTopTaskId -Status $taskStatus
                        $created += [PSCustomObject]@{ phase = $currentPhase; title = $title; id = $result.id; url = $result.url; parent = $lastTopTaskId }
                    }
                    else {
                        $result = New-ClickUpTask -ListId $currentListId -Title $title -Status $taskStatus
                        $created += [PSCustomObject]@{ phase = $currentPhase; title = $title; id = $result.id; url = $result.url }
                        $lastTopTaskId = $result.id
                    }
                    if ($commentText) {
                        Start-Sleep -Milliseconds 650
                        Invoke-ClickUp -Method POST -Path "/task/$($result.id)/comment" -Body @{ comment_text = $commentText } | Out-Null
                    }
                }
                catch {
                    $failed += [PSCustomObject]@{ phase = $currentPhase; title = $title; error = $_.Exception.Message }
                }
                # Throttle: token rate limit is 100 req/min on Free/Unlimited/Business plans
                # (see references/clickup-api.md). A large plan can easily exceed that
                # without a small delay between calls.
                Start-Sleep -Milliseconds 650
            }
        }

        [PSCustomObject]@{
            lists_created = $listsCreated.Count
            created_count = $created.Count
            skipped_count = $skipped.Count
            failed_count  = $failed.Count
            tasks         = $created
            skipped       = $skipped
            failures      = $failed
        } | ConvertTo-Json -Depth 10
    }

    'quick-add' {
        if (-not $ListId -or -not $Name) { throw "-ListId and -Name are required for quick-add" }
        $task = New-ClickUpTask -ListId $ListId -Title $Name
        $output = [PSCustomObject]@{
            task = [PSCustomObject]@{ id = $task.id; url = $task.url; name = $task.name }
        }
        if ($Steps) {
            $stepList = $Steps -split ';' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
            $subtasks = @()
            foreach ($step in $stepList) {
                $sub = New-ClickUpTask -ListId $ListId -Title $step -Parent $task.id
                $subtasks += [PSCustomObject]@{ title = $step; id = $sub.id; url = $sub.url }
                Start-Sleep -Milliseconds 650
            }
            $output | Add-Member -NotePropertyName subtasks -NotePropertyValue $subtasks
        }
        $output | ConvertTo-Json -Depth 10
    }
}
