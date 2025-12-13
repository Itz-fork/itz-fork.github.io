#!usr/bin/env


# ------------------ Variables ------------------#
PKGM="pnpm"
GHP_BRANCH="gh-pages"
UPSTREAM_NM="ghupstream"
REPO_URL="https://github.com/Itz-fork/itz-fork.github.io.git"
NO_KEEP_GIT=false
BUILD_START=$(date +%Y-%m-%d-%H-%M-%S)
COMMIT_MSG="build ${BUILD_START}"
FLAGS=""
# Constants, don't change em
CURDIR="./${PWD##*/}/."
TMPDIR="./pages_build/"


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
            NO_KEEP_GIT=true
            shift
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
    -nk|--no-keep - Resets git history for build branch if passed. Not recommended
    -h|--help - Shows this message
${RESET}"
            exit 1
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
    if [ $1 = -ex ]; then
        exit 1
    fi
}


# ------------------ Builders ------------------#
setup_env() {
    say_sh "> Setting up build environment..."
    cd ..
    mkdir $TMPDIR
    cp -a $CURDIR $TMPDIR
    cd $TMPDIR
}


build_site() {
    say_sh "> Creating build branch - ${GHP_BRANCH}"
    git checkout $GHP_BRANCH &> /dev/null || git checkout -b $GHP_BRANCH

    say_sh "> Building site..."
    if [ ! -d "node_modules" ]; then
        warn_sh "node_modules folder doesn't exist"
        info_sh "> Installing dependencies..."
        $PKGM install
    fi
    $PKGM build $FLAGS
}

pre_pub() {
    say_sh "> Preparing to publish..."
    mkdir nodel
    mv dist nodel
    if [ $NO_KEEP_GIT = false ]; then
        mv .git nodel
    fi
    find ./ -mindepth 1 ! -regex '^./nodel\(/.*\)?' -delete
    mv nodel/dist/* ./ || warn_sh "Unable to find build dir. Aborting..." -ex
    mv nodel/.git ./ || warn_sh ".git directory was deleted for this build. Don't use '-nk' to avoid this"
    rm -rf nodel
}

gh_publish() {
    say_sh "> Publishing your branch to ${REPO_URL}"
    if [ ! -d ".git" ]; then
        warn_sh "Git folder doesn't exist"
        info_sh "> Initializing a new project..."
        git init
    fi
    git add . &> /dev/null
    git commit -m "${COMMIT_MSG}" &> /dev/null
    git checkout $GHP_BRANCH &> /dev/null || git checkout -b $GHP_BRANCH &> /dev/null
    git remote -v
    git remote add "${UPSTREAM_NM}" "${REPO_URL}"
    git push -u "${UPSTREAM_NM}" "${GHP_BRANCH}" --force
}

cleanup() {
    say_sh "> Switching back to working dir"
    cd ..
    rm -rf $TMPDIR
    cd $CURDIR
}


main() {
    setup_env
    build_site
    pre_pub
    gh_publish
    cleanup
    say_sh "> Done"
}

main