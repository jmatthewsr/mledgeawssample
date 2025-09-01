# ML Edge Project - Development Workflow Script
# PowerShell automation script for standardized development tasks

param(
    [Parameter(Position=0)]
    [ValidateSet("setup", "build", "test", "lint", "lint-fix", "typecheck", "test-infra", "all", "")]
    [string]$Target = "all",
    
    [switch]$VerboseOutput,
    [switch]$Help
)

# Global configuration
$ErrorActionPreference = "Stop"
$ProjectRoot = $PSScriptRoot
$SrcDir = Join-Path $ProjectRoot "src"
$TestsDir = Join-Path $ProjectRoot "tests"
$InfraDir = Join-Path $ProjectRoot "infra"

# Color functions for better output
function Write-Success($message) {
    Write-Host "[SUCCESS] $message" -ForegroundColor Green
}

function Write-Info($message) {
    Write-Host "[INFO] $message" -ForegroundColor Cyan
}

function Write-Warning($message) {
    Write-Host "[WARNING] $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "[ERROR] $message" -ForegroundColor Red
}

function Write-Header($message) {
    Write-Host "`n[BUILD] $message" -ForegroundColor Magenta
    Write-Host ("=" * ($message.Length + 8)) -ForegroundColor Magenta
}

# Help function
function Show-Help {
    Write-Host @"
ML Edge Project - Development Workflow Script

USAGE:
    .\make.ps1 [target] [options]

TARGETS:
    setup       Set up development environment (install dependencies)
    build       Build the project (install in development mode)
    test        Run all tests with coverage
    lint        Run code linting and formatting with Ruff
    lint-fix    Run code linting and automatically fix issues
    typecheck   Run static type checking with Pyright
    test-infra  Run infrastructure tests (Terraform validation)
    all         Run all checks (default)

OPTIONS:
    -VerboseOutput Enable verbose output
    -Help          Show this help message

EXAMPLES:
    .\make.ps1                    # Run all checks
    .\make.ps1 setup              # Set up development environment
    .\make.ps1 test               # Run tests only
    .\make.ps1 lint               # Run linting only
    .\make.ps1 lint-fix           # Run linting and fix issues
    .\make.ps1 all -VerboseOutput # Run all with verbose output

"@ -ForegroundColor White
}

# Utility functions
function Test-PythonEnvironment {
    try {
        $pythonVersion = python --version 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Python is not available. Please install Python 3.9+ or activate your virtual environment."
            return $false
        }
        Write-Info "Using Python: $pythonVersion"
        return $true
    }
    catch {
        Write-Error "Failed to check Python version: $_"
        return $false
    }
}

function Test-Dependencies {
    $requiredPackages = @("pytest", "ruff", "pyright", "build")
    $missingPackages = @()
    
    foreach ($package in $requiredPackages) {
        try {
            $result = python -m pip show $package 2>&1
            if ($LASTEXITCODE -ne 0) {
                $missingPackages += $package
            }
        }
        catch {
            $missingPackages += $package
        }
    }
    
    if ($missingPackages.Count -gt 0) {
        Write-Warning "Missing packages: $($missingPackages -join ', ')"
        Write-Info "Run '.\make.ps1 setup' to install dependencies"
        return $false
    }
    
    return $true
}

function Invoke-SafeCommand {
    param(
        [string]$Command,
        [string]$Description,
        [switch]$ContinueOnError
    )
    
    Write-Info $Description
    if ($VerboseOutput) {
        Write-Host "Executing: $Command" -ForegroundColor Gray
    }
    
    try {
        Invoke-Expression $Command
        if ($LASTEXITCODE -ne 0) {
            if ($ContinueOnError) {
                Write-Warning "$Description completed with warnings (exit code: $LASTEXITCODE)"
                return $false
            }
            else {
                Write-Error "$Description failed (exit code: $LASTEXITCODE)"
                exit $LASTEXITCODE
            }
        }
        Write-Success "$Description completed successfully"
        return $true
    }
    catch {
        Write-Error "$Description failed: $_"
        if (-not $ContinueOnError) {
            exit 1
        }
        return $false
    }
}

# Task implementations
function Invoke-Setup {
    Write-Header "Setting up development environment"
    
    # Check Python availability
    if (-not (Test-PythonEnvironment)) {
        exit 1
    }
    
    # Upgrade pip
    Invoke-SafeCommand "python -m pip install --upgrade pip" "Upgrading pip"
    
    # Install development dependencies
    Invoke-SafeCommand "python -m pip install -e .[dev]" "Installing development dependencies"
    
    # Verify installation
    if (Test-Dependencies) {
        Write-Success "Development environment setup completed successfully"
    }
    else {
        Write-Error "Development environment setup failed"
        exit 1
    }
}

function Invoke-Build {
    Write-Header "Building project"
    
    if (-not (Test-PythonEnvironment)) {
        exit 1
    }
    
    # Clean previous builds
    $buildDirs = @("build", "dist", "*.egg-info")
    foreach ($dir in $buildDirs) {
        $fullPath = Join-Path $ProjectRoot $dir
        if (Test-Path $fullPath) {
            Write-Info "Cleaning $dir"
            Remove-Item $fullPath -Recurse -Force
        }
    }
    
    # Install in development mode
    Invoke-SafeCommand "python -m pip install -e ." "Installing project in development mode"
    
    Write-Success "Project build completed successfully"
}

function Invoke-Test {
    Write-Header "Running tests"
    
    if (-not (Test-Dependencies)) {
        Write-Error "Dependencies not installed. Run '.\make.ps1 setup' first."
        exit 1
    }
    
    # Ensure test directories exist
    if (-not (Test-Path $TestsDir)) {
        Write-Info "Creating tests directory"
        New-Item -ItemType Directory -Path $TestsDir -Force | Out-Null
    }
    
    # Run pytest with coverage
    $pytestArgs = @(
        "--cov=src",
        "--cov-report=term-missing",
        "--cov-report=html:htmlcov",
        "--cov-fail-under=80",
        "-v"
    )
    
    if ($VerboseOutput) {
        $pytestArgs += "-s"
    }
    
    $command = "python -m pytest $($pytestArgs -join ' ') $TestsDir"
    Invoke-SafeCommand $command "Running tests with coverage"
}

function Invoke-Lint {
    Write-Header "Running code linting and formatting"
    
    if (-not (Test-Dependencies)) {
        Write-Error "Dependencies not installed. Run '.\make.ps1 setup' first."
        exit 1
    }
    
    # Run Ruff check
    Invoke-SafeCommand "python -m ruff check $SrcDir $TestsDir" "Running Ruff linting"
    
    # Run Ruff format check
    Invoke-SafeCommand "python -m ruff format --check $SrcDir $TestsDir" "Checking code formatting"
    
    Write-Success "Code linting and formatting checks passed"
}

function Invoke-LintFix {
    Write-Header "Running code linting and formatting with auto-fix"
    
    if (-not (Test-Dependencies)) {
        Write-Error "Dependencies not installed. Run '.\make.ps1 setup' first."
        exit 1
    }
    
    # Run Ruff check with --fix
    Invoke-SafeCommand "python -m ruff check --fix $SrcDir $TestsDir" "Running Ruff linting with auto-fix"
    
    # Run Ruff format to fix formatting issues
    Invoke-SafeCommand "python -m ruff format $SrcDir $TestsDir" "Auto-formatting code with Ruff"
    
    Write-Success "Code linting and formatting fixes applied successfully"
}

function Invoke-TypeCheck {
    Write-Header "Running static type checking"
    
    if (-not (Test-Dependencies)) {
        Write-Error "Dependencies not installed. Run '.\make.ps1 setup' first."
        exit 1
    }
    
    # Run Pyright
    Invoke-SafeCommand "python -m pyright $SrcDir" "Running Pyright type checking"
    
    Write-Success "Type checking completed successfully"
}

function Invoke-TestInfra {
    Write-Header "Running infrastructure tests"
    
    if (-not (Test-Path $InfraDir)) {
        Write-Warning "Infrastructure directory not found. Skipping infrastructure tests."
        return
    }
    
    # Check if Terraform is available
    try {
        $terraformVersion = terraform version 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Terraform not available. Skipping infrastructure tests."
            return
        }
        Write-Info "Using Terraform: $($terraformVersion -split "`n" | Select-Object -First 1)"
    }
    catch {
        Write-Warning "Terraform not available. Skipping infrastructure tests."
        return
    }
    
    # Change to infrastructure directory
    Push-Location $InfraDir
    try {
        # Terraform format check
        Invoke-SafeCommand "terraform fmt -check=true -diff=true" "Checking Terraform formatting" -ContinueOnError
        
        # Terraform validation
        Invoke-SafeCommand "terraform init -backend=false" "Initializing Terraform (validation mode)"
        Invoke-SafeCommand "terraform validate" "Validating Terraform configuration"
        
        Write-Success "Infrastructure tests completed successfully"
    }
    finally {
        Pop-Location
    }
}

function Invoke-All {
    Write-Header "Running all development checks"
    
    $startTime = Get-Date
    $results = @()
    
    # Run all tasks
    $tasks = @(
        @{ Name = "Setup"; Function = { Invoke-Setup } },
        @{ Name = "Build"; Function = { Invoke-Build } },
        @{ Name = "Lint"; Function = { Invoke-Lint } },
        @{ Name = "TypeCheck"; Function = { Invoke-TypeCheck } },
        @{ Name = "Test"; Function = { Invoke-Test } },
        @{ Name = "TestInfra"; Function = { Invoke-TestInfra } }
    )
    
    foreach ($task in $tasks) {
        try {
            Write-Host "`n" -NoNewline
            & $task.Function
            $results += @{ Task = $task.Name; Status = "✅ PASSED" }
        }
        catch {
            $results += @{ Task = $task.Name; Status = "❌ FAILED" }
            Write-Error "Task '$($task.Name)' failed: $_"
        }
    }
    
    # Summary
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Header "Summary"
    foreach ($result in $results) {
        Write-Host "$($result.Status) $($result.Task)"
    }
    
    Write-Host "`nTotal time: $($duration.TotalSeconds.ToString('F1')) seconds" -ForegroundColor Gray
    
    $failedTasks = $results | Where-Object { $_.Status -like "*FAILED*" }
    if ($failedTasks.Count -gt 0) {
        Write-Error "Some tasks failed. Please check the output above."
        exit 1
    }
    else {
        Write-Success "All development checks passed successfully!"
    }
}

# Main execution
try {
    if ($Help) {
        Show-Help
        exit 0
    }
    
    # Change to project root
    Set-Location $ProjectRoot
    
    Write-Info "ML Edge Project - Development Workflow"
    Write-Info "Project root: $ProjectRoot"
    Write-Info "Target: $Target"
    
    switch ($Target) {
        "setup" { Invoke-Setup }
        "build" { Invoke-Build }
        "test" { Invoke-Test }
        "lint" { Invoke-Lint }
        "lint-fix" { Invoke-LintFix }
        "typecheck" { Invoke-TypeCheck }
        "test-infra" { Invoke-TestInfra }
        { $_ -in @("all", "") } { Invoke-All }
        default {
            Write-Error "Unknown target: $Target"
            Show-Help
            exit 1
        }
    }
    
    Write-Success "Operation completed successfully!"
}
catch {
    Write-Error "Unexpected error: $_"
    exit 1
}
