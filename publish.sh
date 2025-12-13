#!/usr/bin/env bash

set -euo pipefail

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}"

# ------------------ Variables ------------------#
PKGM="pnpm"
GHP_BRANCH="gh-pages"
UPSTREAM_NM="ghupstream"
REPO_URL="https://github.com/Itz-fork/itz-fork.github.io.git"
PRESERVE_GIT_HISTORY=true
BUILD_START=$(date +%Y-%m-%d-%H-%M-%S)
COMMIT_MSG="build ${BUILD_START}"
FLAGS=""
TMPDIR=""
CLEANUP_TRAP_SET=false

# ------------------ Colors codes ------------------#
WHITE="\033[1;37m"
CYAN="\033[1;36m"
YELLOW="\033[1;93m"
RED="\033[1;31m"
RESET="\033[0m"

#----------------- Argument parser -----------------#
while [[ $# -gt 0 ]]; do
    case "${1}" in
        -f|--flags)
            FLAGS="$2"
            shift
            shift
            ;;
        -pm|--pkgmn)
            PKGM="$2"
            shift
            shift
            ;;
        -m|--msg)
            COMMIT_MSG="$2"
            shift
            shift
            ;;
        -b|--branch)
            GHP_BRANCH="$2"
            shift
            shift
            ;;
        -nk|--no-keep)
            PRESERVE_GIT_HISTORY=false
            shift
            ;;
        -h|--help)
            echo -e "${YELLOW}
Usage:
    bash publish

Arguments:
    -f|--flags - Custom flags to pass on to parcel in double quotes. Defaults to \"\"
    -pm|--pkgmn - Your package manager. Defaults to 'pnpm'
    -m|--msg - Commit messsage. Defaults to 'build <timestamp>'
    -b|--branch - Branch name. Defaults to 'gh-pages'
    -nk|--no-keep - Do not preserve git history; start with a fresh branch. Not recommended
    -h|--help - Shows this message
${RESET}"
            exit 0
            ;;
    esac
done

# ------------------ Output functions ------------------#
say_sh() {
    echo -e "${CYAN}$1${RESET}\n"
}

info_sh() {
    echo -e "   ${WHITE}$1${RESET}\n"
}

warn_sh() {
    echo -e "${RED}WARNING !\n $1${RESET}\n"
}

error_sh() {
    echo -e "${RED}ERROR !\n $1${RESET}\n" >&2
    exit 1
}

# ------------------ Setup and Cleanup ------------------#
setup_temp_dir() {
    TMPDIR=$(mktemp -d) || error_sh "Failed to create temporary directory"
    trap cleanup_on_exit EXIT
    CLEANUP_TRAP_SET=true
}

cleanup_on_exit() {
    if [[ -n "$TMPDIR" && -d "$TMPDIR" ]]; then
        rm -rf "$TMPDIR" || warn_sh "Failed to clean temporary directory: $TMPDIR"
    fi
}

# ------------------ Build Stage ------------------#
build_site() {
    say_sh "> Building site..."
    
    cd "$PROJECT_ROOT" || error_sh "Failed to navigate to project root"
    
    # Clean dependencies and build for hermetic builds
    rm -rf node_modules || true
    
    info_sh "> Installing dependencies..."
    $PKGM install || error_sh "Failed to install dependencies"
    
    # Clean build directory
    rm -rf dist || true
    
    # Build
    $PKGM build $FLAGS || error_sh "Build failed"
    
    [ -d "dist" ] || error_sh "Build did not produce dist directory"
}

# ------------------ Publish Stage ------------------#
init_publish_repo() {
    say_sh "> Initializing publish repository..."
    
    cd "$TMPDIR" || error_sh "Failed to navigate to temporary directory"
    
    git init || error_sh "Failed to initialize git"
    git config user.email "publisher@example.com" || error_sh "Failed to set git email"
    git config user.name "Publisher" || error_sh "Failed to set git name"
}

restore_or_reset_branch() {
    cd "$TMPDIR" || error_sh "Failed to navigate to temporary directory"
    
    if [ "$PRESERVE_GIT_HISTORY" = true ] && [ -d "$PROJECT_ROOT/.git" ]; then
        say_sh "> Restoring git history..."
        
        # Remove the fresh .git and replace with preserved history
        rm -rf .git || error_sh "Failed to remove temporary .git"
        cp -r "$PROJECT_ROOT/.git" . || error_sh "Failed to restore .git from project root"
        
        # Ensure we're on the correct branch, creating if needed
        git checkout "$GHP_BRANCH" &> /dev/null || {
            git checkout -b "$GHP_BRANCH" || error_sh "Failed to create branch $GHP_BRANCH"
        }
    else
        # Fresh branch, no history
        git checkout -b "$GHP_BRANCH" || error_sh "Failed to create branch $GHP_BRANCH"
    fi
}

stage_build_artifacts() {
    say_sh "> Staging build artifacts..."
    
    cd "$TMPDIR" || error_sh "Failed to navigate to temporary directory"
    
    # Remove all existing content except .git
    find . -mindepth 1 ! -name '.git' -delete || error_sh "Failed to clean repository"
    
    # Copy build artifacts
    cp -r "$PROJECT_ROOT/dist"/* . || error_sh "Failed to copy build artifacts"
}

commit_if_changed() {
    cd "$TMPDIR" || error_sh "Failed to navigate to temporary directory"
    
    if [ -n "$(git status --porcelain)" ]; then
        info_sh "> Changes detected, committing..."
        git add . || error_sh "Failed to stage changes"
        git commit -m "${COMMIT_MSG}" || error_sh "Failed to commit"
    else
        info_sh "> No changes to commit"
    fi
}

setup_remote() {
    say_sh "> Setting up remote..."
    
    cd "$TMPDIR" || error_sh "Failed to navigate to temporary directory"
    
    # Only add remote if it doesn't exist
    if ! git remote get-url "$UPSTREAM_NM" &> /dev/null; then
        git remote add "$UPSTREAM_NM" "$REPO_URL" || error_sh "Failed to add remote"
    else
        git remote set-url "$UPSTREAM_NM" "$REPO_URL" || error_sh "Failed to update remote URL"
    fi
}

publish_to_github() {
    say_sh "> Publishing to ${REPO_URL}"
    
    cd "$TMPDIR" || error_sh "Failed to navigate to temporary directory"
    
    git push -u "$UPSTREAM_NM" "$GHP_BRANCH" --force || error_sh "Failed to push to remote"
}

# ------------------ Main Flow ------------------#
main() {
    setup_temp_dir
    
    # Stage 1: Build (uses project root, hermetic)
    build_site
    
    # Stage 2: Publish (clean, explicit state transitions)
    init_publish_repo
    restore_or_reset_branch
    stage_build_artifacts
    commit_if_changed
    setup_remote
    publish_to_github
    
    say_sh "> Done"
}

main "$@"