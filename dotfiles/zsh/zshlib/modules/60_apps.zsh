#######################################################################################
# INSOMNIA (App like postman)

function insomnia_setup {
    # Setup a workspace for insomnia in the current git repo
    #   After creation in insomnia `Create > Git Clone` with settings:
    #   Repo: https://user@gitrepourl
    #   Token: a read/write token for user

    WORKSPACE=".insomnia/Workspace"

    IS_REPO=`git rev-parse --git-dir 2> /dev/null;`

    if [ -z "$IS_REPO" ]; then
        echo "$(pwd) is not in a git repository."
        return 1
    fi

    REPO_ROOT=$(git rev-parse --show-toplevel)
    cd $REPO_ROOT

    if [ -d "$WORKSPACE" ]; then
        echo "Insomnia workspace already exists in this repository."
        return 1
    fi

    mkdir -p $WORKSPACE

    # Generare un md5 dal nome del proprio progetto:
    PROJECT=`git config --local remote.origin.url|sed -n 's#.*/\([^.]*\)\.git#\1#p'`
    MD5=`echo $PROJECT | md5sum | sed 's/[^a-f0-9]//g'`
    NOW=`date +%s`

    # Creare il file yml di insomnia:
    cd $WORKSPACE

    # Scriverci dentro:
    cat <<EOT > wrk_${MD5}.yml
_id: wrk_${MD5}
created: ${NOW}
description: ""
modified: ${NOW}
name: ${PROJECT}
parentId: null
scope: spec
type: Workspace
EOT

    echo "Insomnia workspace created."
    echo "  Project: ${PROJECT}"
    echo "  Workspace: $(pwd)"

    cd $REPO_ROOT
}
