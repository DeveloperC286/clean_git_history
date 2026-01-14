#!/usr/bin/env python3
"""
Task runner for clean_git_history project.
Replaces Makefile with pure Python using only standard library.
"""

import argparse
import glob
import os
import platform
import subprocess
import sys


# =============================================================================
# Configuration and Environment Detection
# =============================================================================

def get_musl_target() -> str:
    """
    Auto-detect musl target for static binaries (Linux only).
    Maps x86_64 -> x86_64-unknown-linux-musl
    Maps aarch64 -> aarch64-unknown-linux-musl
    """
    machine = platform.machine()
    mapping = {
        'x86_64': 'x86_64-unknown-linux-musl',
        'aarch64': 'aarch64-unknown-linux-musl',
    }
    target = mapping.get(machine)
    if target is None:
        print(
            f"Error: Unsupported architecture: {machine}. "
            "Static musl builds only supported on Linux x86_64 and aarch64",
            file=sys.stderr
        )
        sys.exit(1)
    return target


def is_ci() -> bool:
    """Check if running in CI environment."""
    return os.environ.get('CI', '').lower() in ('true', '1', 'yes')


def get_cargo_locked_flag() -> list[str]:
    """Return ['--locked'] if in CI, empty list otherwise."""
    return ['--locked'] if is_ci() else []


# =============================================================================
# Command Execution Helper
# =============================================================================

def run(cmd: list[str], cwd: str | None = None) -> None:
    """
    Execute a command, printing it first and exiting on failure.
    """
    print(f"+ {' '.join(cmd)}", flush=True)
    result = subprocess.run(cmd, cwd=cwd)
    if result.returncode != 0:
        sys.exit(result.returncode)


# =============================================================================
# Permissions Target
# =============================================================================

def check_shell_permissions() -> None:
    run(['./ci/check-scripts-permissions.sh'])


# =============================================================================
# Formatting Targets
# =============================================================================

def check_rust_formatting() -> None:
    run(['cargo', 'fmt', '--all', '--', '--check', '--config=group_imports=StdExternalCrate'])


def fix_rust_formatting() -> None:
    run(['cargo', 'fmt', '--all', '--', '--config=group_imports=StdExternalCrate'])


def check_shell_formatting() -> None:
    files = sorted(glob.glob('ci/*'))
    run(['shfmt', '--simplify', '--diff'] + files)


def fix_shell_formatting() -> None:
    files = sorted(glob.glob('ci/*'))
    run(['shfmt', '--simplify', '--write'] + files)


def check_python_formatting() -> None:
    run([
        'autopep8', '--exit-code', '--diff', '--aggressive', '--aggressive',
        '--max-line-length', '120', '--recursive', 'end-to-end-tests/'
    ])


def fix_python_formatting() -> None:
    run([
        'autopep8', '--in-place', '--aggressive', '--aggressive',
        '--max-line-length', '120', '--recursive', 'end-to-end-tests/'
    ])


def check_yaml_formatting() -> None:
    files = sorted(glob.glob('.github/workflows/*'))
    run(['yamlfmt', '-verbose', '-lint', '-dstar'] + files)


def fix_yaml_formatting() -> None:
    files = sorted(glob.glob('.github/workflows/*'))
    run(['yamlfmt', '-verbose', '-dstar'] + files)


# =============================================================================
# Linting Targets
# =============================================================================

def check_rust_linting() -> None:
    cmd = ['cargo', 'clippy', '--verbose'] + get_cargo_locked_flag() + ['--', '-D', 'warnings']
    run(cmd)


def check_shell_linting() -> None:
    files = sorted(glob.glob('ci/*.sh'))
    run(['shellcheck'] + files)


def check_python_linting() -> None:
    run(['ruff', 'check', '--line-length', '120', 'end-to-end-tests/'])


def fix_python_linting() -> None:
    run(['ruff', 'check', '--fix', '--line-length', '120', 'end-to-end-tests/'])


def check_github_actions_workflows_linting() -> None:
    run(['actionlint', '-verbose', '-color'])


def check_rust_dependencies() -> None:
    run(['cargo', 'machete'])


# =============================================================================
# Build and Test Targets
# =============================================================================

def compile_project() -> None:
    """Named compile_project to avoid shadowing Python builtin."""
    cmd = ['cargo', 'build', '--verbose'] + get_cargo_locked_flag()
    run(cmd)


def unit_test() -> None:
    cmd = ['cargo', 'test', '--verbose'] + get_cargo_locked_flag()
    run(cmd)


def end_to_end_test() -> None:
    compile_project()
    run(['behave'], cwd='end-to-end-tests')


def release() -> None:
    target = get_musl_target()
    run(['cargo', 'build', '--release', f'--target={target}', '--locked', '--verbose'])


# =============================================================================
# Publish Targets
# =============================================================================

def publish_binary(release_tag: str) -> None:
    release()
    target = get_musl_target()
    run(['./ci/publish-binary.sh', release_tag, target])


def publish_crate() -> None:
    run(['cargo', 'publish', '--verbose'])


def publish_docker_image(release_tag: str, docker_platform: str, build_target: str, suffix: str) -> None:
    run(['./ci/publish-docker-image.sh', release_tag, docker_platform, build_target, suffix])


def publish_docker_manifest(release_tag: str) -> None:
    run(['./ci/publish-docker-manifest.sh', release_tag])


# =============================================================================
# Dogfood Target
# =============================================================================

def dogfood_docker(from_ref: str) -> None:
    release()
    target = get_musl_target()
    run(['docker', 'build', '--build-arg', f'TARGET={target}', '--tag', 'clean_git_history', '--file', 'Dockerfile', '.'])

    pwd = os.getcwd()
    run([
        'docker', 'run', '--rm',
        '--volume', f'{pwd}:/workspace',
        '--workdir', '/workspace',
        '--env', 'HOME=/github/home',
        '--env', 'GITHUB_ACTIONS=true',
        '--env', 'CI=true',
        'clean_git_history', '--verbose', from_ref
    ])


# =============================================================================
# Main Entry Point
# =============================================================================

# Registry mapping target names to their handlers (None = requires arguments)
SIMPLE_TARGETS = {
    # Permissions
    'check-shell-permissions': check_shell_permissions,

    # Formatting
    'check-rust-formatting': check_rust_formatting,
    'fix-rust-formatting': fix_rust_formatting,
    'check-shell-formatting': check_shell_formatting,
    'fix-shell-formatting': fix_shell_formatting,
    'check-python-formatting': check_python_formatting,
    'fix-python-formatting': fix_python_formatting,
    'check-yaml-formatting': check_yaml_formatting,
    'fix-yaml-formatting': fix_yaml_formatting,

    # Linting
    'check-rust-linting': check_rust_linting,
    'check-shell-linting': check_shell_linting,
    'check-python-linting': check_python_linting,
    'fix-python-linting': fix_python_linting,
    'check-github-actions-workflows-linting': check_github_actions_workflows_linting,
    'check-rust-dependencies': check_rust_dependencies,

    # Build and Test
    'compile': compile_project,
    'unit-test': unit_test,
    'end-to-end-test': end_to_end_test,
    'release': release,

    # Publish (no arguments)
    'publish-crate': publish_crate,
}

# Targets that require specific arguments
TARGETS_WITH_ARGS = {
    'publish-binary': {'required': ['release']},
    'publish-docker-image': {'required': ['release', 'platform', 'target', 'suffix']},
    'publish-docker-manifest': {'required': ['release']},
    'dogfood-docker': {'required': ['from']},
}

ALL_TARGETS = list(SIMPLE_TARGETS.keys()) + list(TARGETS_WITH_ARGS.keys())


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Task runner for clean_git_history project.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
Examples:
  python tasks.py compile
  python tasks.py check-rust-formatting
  python tasks.py publish-binary --release v1.0.0
  python tasks.py dogfood-docker --from origin/main
        '''
    )

    parser.add_argument(
        'target',
        choices=sorted(ALL_TARGETS),
        help='The target to run'
    )

    # Target-specific arguments
    parser.add_argument('--release', help='Release tag (e.g., v1.0.0)')
    parser.add_argument('--platform', help='Docker platform (e.g., linux/amd64)')
    parser.add_argument('--target', dest='build_target', help='Build target (e.g., x86_64-unknown-linux-musl)')
    parser.add_argument('--suffix', help='Docker image suffix (e.g., amd64)')
    parser.add_argument('--from', dest='from_ref', help='Git ref to compare from')

    args = parser.parse_args()

    # Check if target requires arguments
    if args.target in TARGETS_WITH_ARGS:
        required_args = TARGETS_WITH_ARGS[args.target]['required']
        for arg in required_args:
            if arg == 'from':
                arg_name = 'from_ref'
            elif arg == 'target':
                arg_name = 'build_target'
            else:
                arg_name = arg
            if getattr(args, arg_name) is None:
                parser.error(f"Target '{args.target}' requires --{arg}")

    # Dispatch to appropriate handler
    if args.target == 'publish-binary':
        publish_binary(args.release)
    elif args.target == 'publish-docker-image':
        publish_docker_image(args.release, args.platform, args.build_target, args.suffix)
    elif args.target == 'publish-docker-manifest':
        publish_docker_manifest(args.release)
    elif args.target == 'dogfood-docker':
        dogfood_docker(args.from_ref)
    else:
        # Simple target without arguments
        handler = SIMPLE_TARGETS[args.target]
        handler()


if __name__ == '__main__':
    main()
