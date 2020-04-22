#!/bin/bash
#
# @file testme
# @brief Setup requirements - run tests, from root folder run: ./testme.sh.

# Path to the project used as source, defaults to current path.
PROJECT_PATH=$(pwd)

# Python executable to use: python or python3. Empty by default.
PYTHON_EXEC=''

# Install requirements or not.
INSTALL_REQUIREMENT=false

# Run inside a Docker container.
DOCKER=false

# Docker image to use.
DOCKER_IMAGE='debian:stable-slim'

# String indicating to run only tests of specific types.
# The allowed values are:
# - a: Bare metal Ansible tests.
# - b: Bats tests.
# - m: Molecule tests.
# - p: Pytest tests.
# - t: Tox tests.
# - y: Poetry tests.
# The full string is: abmpty.
TYPE=''

# 'Become root password' to pass to Ansible roles.
BECOME_PASS=''

# Wheter to generate or not a Python coverage report.
COVERAGE_REPORT=false

# When set to true, enter recursively on each directory on project's
# root folder and execute every testme.sh script found (add a
# .testignore file to ignore a directory).
RECURSIVE=false

# Show time report on stdout when finished.
CLOCK=false

# Internal flag to prevent executing pytest two times when
# running Ansible tests.
PYTEST_EXECUTED=false

# @description Determines if Ansible bare metal tests exists.
#
# This function tries:
# - Search .yml files on $test_path.
# - Search .yaml files on $test_path.
# - Search for the library folder.
# - Search for the test_plugins folder.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @return true if ansible tests exists, false otherwise.
function ansible_exist() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    local test_path=$(get_test_path $project_path)
    ! [[ -d $test_path ]] && echo false && return 1

    # Bare metal tests (no molecule).
    # Search for yml tests.
    local ls_result=$(ls $test_path)
    [[ $ls_result == *'.yml'* ]] && echo true && return 0

    # Search for .yaml tests.
    ls_result=$(ls $test_path)
    [[ $ls_result == *'.yaml'* ]] && echo true && return 0

    # Check if ./library directory exists and contains py files.
    if [[ -d $project_path/library ]]; then
        ls_result=$(ls $project_path/library)
        [[ $ls_result == *'.py'* ]] && echo true && return 0
    fi

    # Check if ./test_plugins directory exists and
    # contains py files.
    if [[ -d $project_path/test_plugins ]]; then
        ls_result=$(ls $project_path/test_plugins)
        [[ $ls_result == *'.py'* ]] && echo true && return 0
    fi

    echo false && return 0

}

# @description Execute ansible tests.
#
# @arg $1 string Optional project path. Default to current path.
# @arg $2 string Optional become password.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function ansible_run() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    if [[ $(ansible_exist $project_path) == 'true' ]]; then

        ansible_setup $project_path
        [ $? -eq 1 ] && return 1

        local test_path=$(get_test_path $project_path)

        local become_parameter=''
        ! [[ -z $2 ]] && become_parameter="ansible_become_pass: '$2', "

        # Recolect the list of playbooks to execute.
        local yml_files=''

        local ls_result=$(ls $test_path)
        [[ $ls_result == *'.yml'* ]] && yml_files=$(ls $test_path/*.yml)

        local ls_result=$(ls $test_path)
        [[ $ls_result == *'.yaml'* ]] && yml_files="yml_files $(ls $test_path/*.yaml)"

        # Bare metal tests, using test playbook files.
        # dependency roles must be preinstalled: ansible-galaxy install.
        local python_exec=$(get_python_exec)

        # Check if inventory exists, if not, create a temporary one.
        local inventory_path=$test_path/inventory
        if ! [[ -f $inventory_path ]]; then
            echo 'localhost' > $test_path/inventory_tmp
            inventory_path=$test_path/inventory_tmp
        fi

        for playbook in $yml_files; do

            ansible-playbook -i $inventory_path $playbook -e \
                             "{${become_parameter}ansible_python_interpreter: '/usr/bin/$python_exec'}"

            # Clear history for security.
            ! [[ -z $become_parameter ]] && history -c
        done

    fi

    [[ -f $test_path/inventory_tmp ]] && rm -f $test_path/inventory_tmp

    return 0

}

# @description Setup ansible tests.
#
# @arg $1 string Optional project path. Default to current_path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function ansible_setup() {

    # Ensure Python requirements are installed.
    install_pip
    [ $? -eq 1 ] && return 1

    if [[ $(validate 'ansible') == 'false' ]]; then
        install_pip 'ansible>=2.8'
        [ $? -eq 1 ] && return 1
    fi

    if [[ $(validate_pip 'requests') == 'false' ]]; then
        install_pip 'requests'
        [ $? -eq 1 ] && return 1
    fi

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    local test_path=$(get_test_path $project_path)

    if [[ -d $project_path/library ]] && [[ -d $test_path ]]; then
        ansible_setup_python $project_path/library $test_path
        [ $? -eq 1 ] && return 1
    fi

    if [[ -d  $project_path/test_plugins ]] && [[ -d $test_path ]]; then
         ansible_setup_python $project_path/test_plugins $test_path
         [ $? -eq 1 ] && return 1
    fi

    # Check if project is an ansible role.
    if [[ -f $project_path/meta/main.yml ]]; then

        # Get author from meta information.
        local author=$(cat $project_path/meta/main.yml | grep 'author:')

        if ! [[ -z $author ]]; then

            # Remove the 'author:' part.
            author=${author//author\: /}

            # Sanitize the string.
            author=$(sanitize "$author")

            local role_name=$(basename $project_path)

            # Copy role to ~/.ansible/roles.
            ! [[ -d ~/.ansible/roles ]] && mkdir -p ~/.ansible/roles

            # Prevents copy a role with double author name if we are
            # inside an installed role (i.e.: ~/.ansible/roles/author.role).
            if [[ $role_name == *"${author}."* ]]; then
                cp -rf $project_path ~/.ansible/roles &>/dev/null
            else
                cp -rf $project_path ~/.ansible/roles/${author}.${role_name}
            fi
        fi

    # If ansible role.
    fi

    return 0

}

# @description Create symbolic links for Ansible modules and plugins.
#
# Link the directories:
# - ./library
# - ./test_plugins
#
# To the locations:
# - $test_path/library
# - $test_path/test_plugins
#
# Each .py file found under those directories will be compiled.
#
# @arg $1 Source directory (i.e.: $project_path/library).
# @arg $2 Destination directory (i.e.: $test_path).
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function ansible_setup_python() {

    if [[ -z $1 ]] || ! [[ -d $1 ]]; then
        error_message 'path' "$1"
        error_message 'custom' 'Must specify an existent source directory.'
    fi

    if [[ -z $2 ]] || ! [[ -d $2 ]]; then
        error_message 'path' "$2"
        error_message 'custom' 'Must specify an existent destiny directory.'
    fi

    local source_path="$( cd "$1" ; pwd -P )"
    local destiny_path="$( cd "$2" ; pwd -P )"

    # Check if source directory contains python files.
    local ls_result=$(ls $source_path)
    if [[ $ls_result == *'.py'* ]]; then

        ln -fs $source_path $destiny_path

        # Once we know .py files exists, list again and store the listings.
        local files_list=$(ls $source_path/*.py)

        # Ensure Python requirements are installed.
        install_pip
        [ $? -eq 1 ] && return 1
        local python_exec=$(get_python_exec)

        for file_item in $file_list; do
            $python_exec -m py_compile $file_item
        done
    fi

    return 0

}

# @description Determines if Bats tests exists.
#
# This function tries:
# - Search .bats files on $test_path.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @return true if ansible tests exists, false otherwise.
function bats_exist() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    local test_path=$(get_test_path $project_path)
    ! [[ -d $test_path ]] && echo false && return 1

    local test_list=$(ls $test_path)
    [[ $test_list == *'.bats'* ]] && echo true && return 0

    echo false && return 0

}

# @description Execute bats tests.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function bats_run() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Verify bats tests exists.
    [[ $(bats_exist $project_path) == 'false' ]] && return 0

    bats_setup
    [ $? -eq 1 ] && return 1

    # Verify test folder exists.
    local test_path=$(get_test_path $project_path)
    ! [[ -d $test_path ]] && error_message 'path' "$test_path" && return 1

    # Run bats tests.
    bats $test_path

    return 0
}

# @description Setup bats tests.
#
# @noargs
#
# @exitcode 0 if succesuful.
# @exitcode 1 if failure.
function bats_setup() {

    install_apt 'bats'
    [ $? -eq 1 ] && return 1

    return 0

}

# @description Create a parameters string to pass to each
# recursively call of the testme.sh script.
#
#  - *g* (coverage report).
#  - *i* (install requirements).
#  - *k* (clock report).
#  - *K* (become password for Ansible roles).
#  - *t* <type> (only tests of type).
#  - *x* <python executable>.
#
# @arg $@ string Bash arguments.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @stdout Prints the created parameter string.
function create_parameter_string() {

    local become_pass_regex='-K (.*)'
    local python_exec_regex='-x (python[0-9]*)'
    local type_regex='-t ([abmpty])+'
    local parameter_string=''

    [[ "$@" == *'-g'* ]] && parameter_string+='-g '
    [[ "$@" == *'-i'* ]] && parameter_string+='-i '

    # Type.
    if [[ $@ =~ $type_regex ]]; then
        parameter_string+="-t ${BASH_REMATCH[1]} "
    fi

    # Clock.
    [[ "$@" == *'-k'* ]] && parameter_string+='-k '

    if [[ $@ =~ $python_exec_regex ]]; then
        parameter_string+="-x ${BASH_REMATCH[1]} "
    fi

    # Become password.
    if [[ $@ =~ $become_pass_regex ]]; then
        parameter_string+="-K $(sanitize ${BASH_REMATCH[1]})"
    fi

    echo "$parameter_string"

    return 0
}

# @description Setups Docker.
#
# @noargs
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function docker_setup() {

    # Ensure Python requirements are installed.
    install_pip
    [ $? -eq 1 ] && return 1

    # Docker must be installed.
    if [[ $(validate_apt 'docker-ce') == 'false' ]]; then

        # Check if can install.
        if [[ $(validate 'install') == 'true' ]]; then

            # Ensure python requirements are present.
            install_pip

            # Official procedure:
            # https://docs.docker.com/install/linux/docker-ce/debian.
            # https://docs.docker.com/install/linux/docker-ce/ubuntu.
            uninstall_apt 'containerd containerd.io docker docker-ce docker-engine docker.io runc'
            [ $? -eq 1 ] && return 1

            install_apt 'apt-transport-https ca-certificates curl gnupg2 software-properties-common'
            [ $? -eq 1 ] && return 1

            # Get 'debian' or 'ubuntu' name.
            local os_name=$(cat /etc/os-release | grep ^ID=)
            os_name="${os_name//ID=/}"

            # Get codename, i.e.: 'buster'.
            local os_codename=$(cat /etc/os-release | grep ^VERSION_CODENAME=)
            os_codename="${os_codename//VERSION_CODENAME=/}"

            # Add docker key.
            echo 'Adding docker key with apt-key add ...'
            curl -fsSL https://download.docker.com/linux/${os_name}/gpg | sudo apt-key add -
            echo 'Adding docker fingerprint with apt-key ...'
            sudo apt-key fingerprint 0EBFCD88

            # Add docker repository.
            echo 'Adding docker repository with add-apt-repository ...'
            sudo add-apt-repository \
                 "deb [arch=amd64] https://download.docker.com/linux/$os_name \
                  $os_codename \
                  stable"

            # Install all requirements.
            install_apt 'docker-ce docker-ce-cli containerd.io'
            [ $? -eq 1 ] && return 1

        else
            error_message 'docker'
            return 1

        fi
    fi

    return 0

}

# @description Shows an error message.
#
# @arg $1 string Error name: custom, execution, path, sudo, <name>.
# @arg $2 string Optional text to use on error messages.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @stdout 'Error message'
function error_message() {

    [[ -z $1 ]] && return 1

    case $1 in
        custom)
            if ! [[ -z $2 ]]; then
                echo "$2"
            else
                echo 'Unknown error ocurred.'
            fi
            ;;

        execution)
            if ! [[ -z $2 ]]; then
                echo "An error occurred executing $2."
            else
                echo 'An error ocurred during execution.'
            fi
            ;;

        path)
            if ! [[ -z $2 ]]; then
                echo "$2 is not an existent directory."
            else
                echo 'Inexistent directory used.'
            fi
            ;;

        sudo)
            echo "It's not possible to adquire administrative permissions."
            echo 'It could be one of the following causes:'
            echo '- The program "sudo" is not installed.'
            echo '- Your user is not on the "root" or "sudo" groups.'
            echo 'Run:'
            echo 'su -c "apt install -y sudo" && su -c "sudo adduser $(whoami) sudo" && su'
            ;;

        uninstall)
            if ! [[ -z $2 ]]; then
                echo "Cannot uninstall $2."
            else
                echo 'Cannot uninstall package.'
            fi
            ;;

        *)
            echo '        __.....__'
            echo '     ."" _  o    "`.'
            echo '   ." O (_)     () o`.'
            echo '  .           O       .'
            echo ' . ()   o__...__    O  .'
            echo '. _.--"""       """--._ .'
            echo ':"                     ";'
            echo ' `-.__    :   :    __.-"'
            echo '      """-:   :-"""'
            echo '         J     L'
            echo '         :     :'
            echo '        J       L'
            echo '        :       :'
            echo '        `._____."'
            echo "$1 needs to be installed ..."
            echo "Run:"
            echo "./$(basename $0).sh -i"
            ;;
    esac
    return 0
}

# @description Get bash parameters.
#
# Accepts:
#  - *d* (docker).
#  - *D* (docker image).
#  - *g* (coverage report).
#  - *h* (help).
#  - *i* (install requirements).
#  - *k* (clock).
#  - *K* (become password for Ansible roles).
#  - *p* <project_path>.
#  - *r* (recursive).
#  - *t* <types> (only tests of type).
#  - *x* <python executable>.
#
# @arg '$@' string Bash arguments.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function get_parameters() {

    # Obtain parameters.
    while getopts 'd;D:g;h;i;k;K:p:r;t:x:' opt; do
        OPTARG=$(sanitize "$OPTARG")
        case "$opt" in
            d) DOCKER=true;;
	    D) DOCKER_IMAGE="${OPTARG}";;
            g) COVERAGE_REPORT=true;;
            h) help && exit 0;;
            i) INSTALL_REQUIREMENT=true;;
            k) CLOCK=true;;
            K) BECOME_PASS="${OPTARG}";;
            p) PROJECT_PATH="${OPTARG}";;
            r) RECURSIVE=true;;
            t) TYPE="${OPTARG}";;
            x) [[ "${OPTARG}" == *'python'* ]] && PYTHON_EXEC="${OPTARG}";;
        esac
    done

    return 0
}

# @description Obtains the Python executable to use: python or python3.
#
# This function tries:
# - Use the $PYTHON_EXEC variable if not empty and like 'python'.
# - Use 'python3' is available.
# - Use 'python' if available.
#
# @args noargs
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout the python executable (python or python3).
function get_python_exec() {

    # Try user passed exec.
    if ! [[ -z $PYTHON_EXEC ]]; then
        if [[ $(validate_apt "$PYTHON_EXEC") == 'true' ]]; then
            echo "$PYTHON_EXEC" && return 0
        fi

        # Check if python was installed by compiling or other method.
        if [[ $($PYTHON_EXEC --version) -eq 0 ]]; then
            echo "$PYTHON_EXEC" && return 0
        fi
    fi

    # Try python3.
    if [[ $(validate_apt 'python3') == 'true' ]]; then
        echo 'python3' && return 0
    fi
    python3 --version &>/dev/null
    [ $? -eq 0 ] && echo 'python3' && return 0

    # Try python.
    if [[ $(validate_apt 'python') == 'true' ]]; then
        echo 'python' && return 0
    fi
    python --version &>/dev/null
    [ $? -eq 0 ] && echo 'python' && return 0

    # Python is not installed.
    echo '' && return 1
}

# @description Obtains the project's test directory.
#
# This function tries:
# - Search for the */tests* directory.
# - Default to */test* directory.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout Path to the test directory.
function get_test_path() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Try /tests.
    [[ -d $project_path/tests ]] && echo "$project_path/tests" && return 0

    # Default /test.
    echo "$project_path/test" && return 0

}

# @description Shows help message.
#
# @noargs
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function help() {

    echo 'Auto discover and execute project tests.'
    echo 'Parameters:'
    echo '-d (docker): Execute the tests inside a Docker container.'
    echo '-D (docker image): Docker image to use.'
    echo '-g (coverage): Generate a Python coverage report.'
    echo '-h (help): Show this help message.'
    echo '-i (requirements): Install requirements.'
    echo '-k (clock): Show time report when finished'
    echo '-K (become pass): Plain-text sudo password (for Ansible roles).'
    echo '-t <type>: Optional string containing:
              a (Ansible bare metal tests)
              b (Bats tests)
              m (Molecule tests)
              p (Pytest tests)
              t (Tox tests)
              y (Poetry tests)'
    echo "-p <project-path>: Absolute path to project's root directory."
    echo "-r (recursive): Enter recursively each directory on project's
             root directory and execute every testme.sh script found."
    echo '-x <python-executable>: Run using python or python3.'
    echo 'Example:'
    echo "./testme.sh -d -D debian:stable-slim -g -i -k -K pass -t abmpty -p /project/path -r -x python3"
    return 0

}

# @description Installs Apt packages.
#
# @arg $1 string List of package names to install, must be space-separated.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
function install_apt() {

    [[ -z $1 ]] && return 1

    local package_array=($(echo $1 | tr " " "\n"))

    # Prevents updating apt twice.
    local apt_updated=false

    # sudo must be installed.
    if [[ $(validate_apt 'sudo') == 'false' ]]; then
        # Add current user to sudoers.
        local current_username=$(whoami)
        echo 'Installing sudo using su -c ...'
        su -c "apt update && apt install -y sudo && /usr/sbin/addgroup $current_username sudo"
        apt_updated=true
    fi

    # build-essential must be installed.
    if [[ $(validate_apt 'build-essential') == 'false' ]]; then

        # Validate if can install
        if [[ $(validate 'install') == 'false' ]]; then
            error_message 'build-essential'
            echo '░░░░░░░░▄▄▄███░░░░░░░░░░░░░░░░░░░░'
            echo '░░░▄▄██████████░░░░░░░░░░░░░░░░░░░'
            echo '░███████████████░░░░░░░░░░░░░░░░░░'
            echo '░▀███████████████░░░░░▄▄▄░░░░░░░░░'
            echo '░░░███████████████▄███▀▀▀░░░░░░░░░'
            echo '░░░░███████████████▄▄░░░░░░░░░░░░░'
            echo '░░░░▄████████▀▀▄▄▄▄▄░▀░░░░░░░░░░░░'
            echo '▄███████▀█▄▀█▄░░█░▀▀▀░█░░▄▄░░░░░░░'
            echo '▀▀░░░██▄█▄░░▀█░░▄███████▄█▀░░░▄░░░'
            echo '░░░░░█░█▀▄▄▀▄▀░█▀▀▀█▀▄▄▀░░░░░░▄░▄█'
            echo '░░░░░█░█░░▀▀▄▄█▀░█▀▀░░█░░░░░░░▀██░'
            echo '░░░░░▀█▄░░░░░░░░░░░░░▄▀░░░░░░▄██░░'
            echo '░░░░░░▀█▄▄░░░░░░░░▄▄█░░░░░░▄▀░░█░░'
            echo '░░░░░░░░░▀███▀▀████▄██▄▄░░▄▀░░░░░░'
            echo '░░░░░░░░░░░█▄▀██▀██▀▄█▄░▀▀░░░░░░░░'
            echo '░░░░░░░░░░░██░▀█▄█░█▀░▀▄░░░░░░░░░░'
            echo '░░░░░░░░░░█░█▄░░▀█▄▄▄░░█░░░░░░░░░░'
            echo '░░░░░░░░░░█▀██▀▀▀▀░█▄░░░░░░░░░░░░░'
            echo '░░░░░░░░░░░░▀░░░░░░░░░░░▀░░░░░░░░░'
            return 1
        fi

        echo 'Installing build-essential ...'
        [[ $apt_updated == 'false' ]] && sudo apt update && apt_updated=true
        sudo apt install --no-install-recommends -y build-essential

    fi

    for package_name in ${package_array[@]}; do

        # Validate if the package is already installed via apt.
        [[ $(validate_apt "$package_name") == 'true' ]] && continue

        # Validate if can install
        if [[ $(validate 'install') == 'false' ]]; then
            error_message "$package_name"
            return 1
        fi

        echo "Installing $package_name ..."

        # Check if the package is pip to handle specially.
        if [[ "$package_name" == 'pip' ]] || [[ "$package_name" == 'pip3' ]] ||
               [[ "$package_name" == 'python-pip' ]] || [[ "$package_name" == 'python3-pip' ]]; then

            local python_exec=$(get_python_exec)

            if [[ -z $python_exec ]]; then
                install_apt python3
                [ $? -eq 1 ] && return 1
                python_exec=python3
            fi

            if [[ $(validate_pip_installed) == 'false' ]]; then

                # Install pip.
                package_name="${python_exec}-pip"

            fi

        fi

        [[ $apt_updated == 'false' ]] && sudo apt update && apt_updated=true
        sudo apt install --no-install-recommends -y "$package_name"

    done

    return 0
}

# @description Installs Python packages via pip.
#
# This function ensures that Python, Pip and Setuptools are installed
# and then installs all required packages.
#
# You can pass to this function:
# - A filepath to a requirements*.txt file to be installed.
# - A filepath to directory containing requirements*.txt files to install.
# - A single package name.
#
# If this function is called without passing any argument to it,
# it will search for requirements*.txt files on the current directory.
#
# This function expects that each requirements filename has the text
# 'requirements' included on it and to have the .txt extension.
#
# This function will always check for Python, Pip and Setuptools to be
# installed and will try to install them if not present.
#
# Each package will be checked to see if its installed, if not installed
# then this function proceeds to install it.
#
# @arg $1 string Optional filepath, path to dir or single package name.
#
# @exitcode 0 on success.
# @exitcode 1 on failure.
function install_pip() {

    local python_exec=$(get_python_exec)

    # Python must be installed.
    if [[ -z $python_exec ]]; then
        install_apt 'python3'
        [ $? -eq 1 ] && return 1
        python_exec='python3'
    fi

    # Pip must be installed.
    install_apt "${python_exec}-pip"
    [ $? -eq 1 ] && return 1

    # Setuptools must be installed.
    if [[ $(validate_apt "${python_exec}-setuptools") == 'false' ]] &&
           [[ $(validate_pip 'setuptools') == 'false' ]]; then
        $python_exec -m pip install setuptools
    fi

    # Virtualenv must be installed.
    if [[ $(validate_apt "${python_exec}-venv") == 'false' ]] &&
           [[ $(validate_pip 'virtualenv') == 'false' ]]; then
        install_apt "${python_exec}-venv"
    fi

    # Path to where requirement files resides.
    local base_path=''
    local file_name=''

    # List of files to install.
    local requirement_list=''

    # Check if single file.
    if ! [[ -z $1 ]] && [[ -f $1 ]]; then
        requirement_list=$1
        base_path=$(dirname $1)

    # Check if directory.
    elif ! [[ -z $1 ]] && [[ -d $1 ]]; then
        requirement_list=$(ls $1)
        base_path=$1

    # Single package, install it.
    elif ! [[ -z $1 ]]; then
        if [[ $(validate_pip "$1") == 'false' ]]; then
            $python_exec -m pip install $1
            return 0
        fi
    fi

    # If at least one requirement file exists.
    if [[ "$requirement_list" =~ .*requirements.*.txt ]]; then

        # Traverse all requirements files, i.e.:
        # requirements.txt, requirements-dev.txt.
        for requirement_file in $requirement_list; do

            if [[ "$requirement_file" == *'requirements'* ]]; then

                file_name=$(basename $requirement_file)

                # Copy file and add a newline to it to overcome bash limit.
                cp -f $base_path/$file_name reqs-current-tmp.txt
                echo '' >> reqs-current-tmp.txt

                # Traverse current requirements file checking item by
                # item if is installed or not.
                while read LINE
                do
                    # If not installed, install it.
                    if ! [[ -z $LINE ]] &&
                        [[ $(validate_pip "$LINE") == 'false' ]];
                    then
                        $python_exec -m pip install $LINE
                    fi

                    # Traverse requirement items (item by item).
                done < reqs-current-tmp.txt
                rm -f reqs-current-tmp.txt

            fi

        # Traverse requirements files (file by file).
        done
    fi
    return 0
}

# @description Setup requirements and run tests.
#
# @arg $@ string Bash arguments.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function main() {

    get_parameters "$@"

    if ! [[ -d $PROJECT_PATH ]]; then
        error_message 'path' "$PROJECT_PATH"
        return 1
    fi

    local parameter_string=''

    # Run on docker.
    if [[ $DOCKER == "true" ]]; then

        # Handle docker setup.
        docker_setup
        [ $? -eq 1 ] && return 1

        parameter_string=$(create_parameter_string "$@")
        if [[ $RECURSIVE == 'true' ]]; then
            parameter_string="{parameter_string} -r"
        fi

        echo " DOCKA: $DOCKER_IMAGE  ..."
        echo '     ------------'
        echo '    /  (_)_      \'
        echo '  /)     (_) (_)  \'
        echo ' |                 |'
        echo '| _   (_)   _   (_) |'
        echo '|(_)  _  (_) _   (_)|'
        echo '|___(_)_____(_)_____|'
        echo ' |||||||||||||||||||'
        echo '        |   |'
        echo '        |   |'
        echo '        |   |'
        echo '        |___|'
        echo '--------------------'

	local proj_name=$(basename $PROJECT_PATH)
        docker run \
               --rm \
               --mount type=bind,source="$PROJECT_PATH",target=/$proj_name \
               $DOCKER_IMAGE \
               bash -c "cd /$proj_name && ./testme.sh -i ${parameter_string}"

        return 0
    fi

    # Track time.
    local start_time=''
    [[ $CLOCK == 'true' ]] && start_time=`date +%s`

    # Recursive run.
    if [[ $RECURSIVE == 'true' ]]; then

        # Verify if project has subdirectories.
        find "$PROJECT_PATH" -mindepth 1 -type d -print &>/dev/null
        if [ $? -eq 1 ]; then
            error_message 'custom' "$PROJECT_PATH has no subidrectories."
            return 1
        fi

        # Create recursive parameters string from bash parameters string.
        parameter_string=$(create_parameter_string "$@")

        # Enter each subdirectory checking if testme.sh exists.
        local directories_list=$(find $PROJECT_PATH -type d -print)

        for directory in $directories_list; do
            # testme.sh exists and a .testignore does not exists, execute.
            if [[ -f $directory/testme.sh ]] &&
                   ! [[ -f $directory/.testignore ]]; then
                ./testme.sh -p $( cd "$directory" ; pwd -P ) $parameter_string
                show_time $start_time
            fi
        done

    else
        # Run ansible tests.
        if [[ -z $TYPE ]] || [[ $TYPE == *'a'* ]]; then
            ansible_run "$PROJECT_PATH" "$BECOME_PASS"
            [ $? -eq 1 ] && error_message 'execution' 'ansible' && return 1

            # Execute pytest.
            pytest_run $project_path
            [ $? -eq 1 ] && error_message 'execution' 'pytest' && return 1
            PYTEST_EXECUTED=true
        fi

        # Run bats tests.
        if [[ -z $TYPE ]] || [[ $TYPE == *'b'* ]]; then
            bats_run "$PROJECT_PATH"
            [ $? -eq 1 ] && error_message 'execution' 'bats' && return 1
        fi

        # Run molecule tests.
        if [[ -z $TYPE ]] || [[ $TYPE == *'m'* ]]; then
            molecule_run "$PROJECT_PATH"
            [ $? -eq 1 ] && error_message 'execution' 'molecule' && return 1
        fi

        # Run pytest tests.
        if [[ (-z $TYPE && $(poetry_exist $PROJECT_PATH) == 'false' &&
                   $(tox_exist $PROJECT_PATH) == 'false') ||
                  $TYPE == *'p'* ]]; then

            if [[ $PYTEST_EXECUTED == 'false' ]]; then
                pytest_run "$PROJECT_PATH"
                if [ $? -eq 1 ]; then
                    error_message 'execution' 'pytest' && return 1
                fi
            fi

            if [[ $COVERAGE_REPORT == 'true' ]]; then
                pytest_coverage "$PROJECT_PATH"
                if [ $? -eq 1 ]; then
                    error_message 'execution' 'coverage'
                    return 1
                fi
            fi

        # Pytest.
        fi

        # Run poetry tests.
        if [[ -z $TYPE ]] || [[ $TYPE == *'y'* ]]; then
            poetry_run "$PROJECT_PATH"
            [ $? -eq 1 ] && error_message 'execution' 'poetry' && return 1
        fi

        # Run tox tests.
        if [[ (-z $TYPE && $(poetry_exist $PROJECT_PATH) == 'false') ||
                  $TYPE == *'t'* ]]; then
            tox_run "$PROJECT_PATH"
            [ $? -eq 1 ] && error_message 'execution' 'tox' && return 1
        fi

    fi # recursive?

    [[ $TIME == 'true' ]] && show_time $start_time

    return 0
}

# @description Determines if molecule tests exists.
#
# This function tries:
# - Search for the molecule directory on $project_path.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @return true if molecule tests exists, false otherwise.
function molecule_exist() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Search for molecule tests.
    [[ -d "$project_path/molecule" ]] && echo true && return 0

    echo false
    return 0
}

# @description Execute molecule tests.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function molecule_run() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    if [[ $(molecule_exist $project_path) == 'true' ]]; then
        molecule_setup
        [ $? -eq 1 ] && return 1

        local python_exec=$(get_python_exec)

        local current_path=$(pwd)
        cd $project_path
        $python_exec -m molecule test
        cd $current_path
    fi

    return 0
}

# @description Setup Molecule tests.
#
# @arg noargs.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function molecule_setup() {

    docker_setup
    [ $? -eq 1 ] && return 1

    install_pip 'flake8'
    [ $? -eq 1 ] && return 1

    local python_exec=$(get_python_exec)
    [ $? -eq 1 ] && return 1

    install_pip 'molecule[docker]'
    [ $? -eq 1 ] && return 1

    return 0
}

# @description Determines if molecule tests exists.
#
# This function tries:
# - Search for the pyproject.toml file on $project_path.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @return true if poetry tests exists, false otherwise.
function poetry_exist() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Search for pyproject.toml file.
    [[ -f $project_path/pyproject.toml ]] && echo true && return 0

    echo false && return 0
}

# @description Execute Poetry tests.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function poetry_run() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    local test_path=$(get_test_path $project_path)

    if [[ $(poetry_exist $project_path) == 'true' ]]; then

        poetry_setup
        [ $? -eq 1 ] && return 1

        local python_exec=$(get_python_exec)

        local current_path=$(pwd)
        cd $project_path

        $python_exec -m poetry install

        if [[ $(cat $project_path/pyproject.toml) == *'tox'* ]]; then
            $python_exec -m poetry run tox $test_path/*.py
        else
            $python_exec -m poetry run pytest $test_path/*.py
        fi

        cd $current_path

    fi

    return 0

}

# @description Setup Poetry tests.
#
# @arg noargs.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function poetry_setup() {
    install_pip 'poetry'
    [ $? -eq 1 ] && return 1
    return 0
}

# @description Generates coverage report using pytest (bare metal).
#
# Creates a .coverage file and a htmlcov folder.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @stdout .coverage file, htmlcov folder.
function pytest_coverage() {

    install_pip 'coverage'
    [ $? -eq 1 ] && return 1

    install_pip 'pytest-cov'
    [ $? -eq 1 ] && return 1

    install_pip 'python-coveralls'
    [ $? -eq 1 ] && return 1

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    local test_path=$(get_test_path $project_path)

    # Check if bare metal tests exists.
    local ls_result=$(ls $test_path)
    ! [[ $ls_result == *'.py'* ]] && return 1

    local python_exec=$(get_python_exec)

    local current_path=$(pwd)
    cd $project_path
    $python_exec -m coverage run --omit */*-packages/* -m pytest $test_path/*.py
    $python_exec -m coverage html
    cd $current_path
    return 0

}

# @description Determines if pytest tests exists.
#
# This function tries:
# - Search python files on $test_path.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @return true if pytest tests exists, false otherwise.
function pytest_exist() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    local test_path=$(get_test_path $project_path)
    ! [[ -d $test_path ]] && echo false && return 1

    # Search for pytest (bare metal) tests.
    local ls_result=$(ls $test_path)
    [[ $ls_result == *'.py'* ]] && echo true && return 0

    echo false && return 0

}

# @description Execute pytest tests.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function pytest_run() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    if [[ $(pytest_exist $project_path) == 'true' ]]; then

        pytest_setup $project_path
        [ $? -eq 1 ] && return 1

        local test_path=$(get_test_path $project_path)

        local python_exec=$(get_python_exec)

        $python_exec -m pytest $test_path/*.py

    fi

    return 0

}

# @description Setup pytest tests.
#
# @arg $1 string Optional project path. Default to current_path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function pytest_setup() {

    install_pip 'pytest'
    [ $? -eq 1 ] && return 1

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Install requirements.txt files if exits.
    install_pip $project_path

    # Run package setup.
    if [[ -f $project_path/setup.py ]]; then
        local python_exec=$(get_python_exec)
        local current_path=$(pwd)
        cd $project_path
        $python_exec setup.py install
        cd $current_path
    fi

    [ $? -eq 1 ] && return 1

    return 0

}

# @description Sanitize input.
#
# The applied operations are:
#
#  - Trim.
#  - Remove unnecesary slashes.
#
# @arg $1 string Text to sanitize.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout Sanitized input.
function sanitize() {
    [[ -z $1 ]] && echo '' && return 0
    local sanitized="$1"

    # Trim.
    sanitized=$(trim "$sanitized")

    # Remove double and triple slashes.
    # Extract the protocol URL part (http:// or https://) (if exists).
    protocol="$(echo $sanitized | grep :// | sed -e's,^\(.*://\).*,\1,g')"

    # Remove the protocol.
    sanitized="${sanitized/${protocol}/}"

    # Remove unnecesary slashes.
    sanitized=$(echo "$sanitized" | tr -s /)

    # Readd the protocol (if exists).
    sanitized=${protocol}${sanitized}

    echo "$sanitized" && return 0
}

# @description Shows the time the test took on stdout.
#
# This function uses the global variable PROJECT_PATH
# as the project folder whose time is being measured.
#
# If the PROJECT_PATH variable is not defined, the current
# path will be used as project path.
#
# @arg $1 string Initial time, if no initial time parameter passed,
# zero will be displayed.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function show_time() {

    local start_time=`date +%s`
    ! [[ -z $1 ]] && start_time=$1

    local project_path=$(pwd)
    ! [[ -z $PROJECT_PATH ]] && project_path="$PROJECT_PATH"

    [[ $RECURSIVE == 'true' ]] &&
        [[ -f $PROJECT_PATH/.testignore ]] && return 0

    echo "PROJECT: $PROJECT_PATH"
    echo '
==========================================================================='
    echo "$((($(date +%s)-$start_time)/60)) min."
    echo '
     .-"~~~-.        ----------------- ---- ----       ---- ----------
   ."o  oOOOo`.      |               | |  | | |        |  | |        |
  :~~~-.oOo   o`.    ------    ------- ---- |  \      /   | |  -------
   `. \ ~-.  oOOo.         |  |        |  | |   \    /    | |  |
     `.; / ~.  OO:         |  |        |  | | \  \--/  /| | |  ----
     ."  ;-- `.o."         |  |        |  | | |\      / | | |     |
    ,"  ; ~~--"~           |  |        |  | | | \    /  | | |  ----
    ;  ;                   |  |        |  | | |  ----   | | |  |
_\\;_\\//__________________|  |________|  |_| |_________| |_|  -------|
==------===========--------========----======-------------===--------======'

    return 0
}

# @description Sanitize input.
#
# The applied operations are:
#
#  - Trim.
#  - Remove unnecesary slashes.
#
# @arg $1 string Text to sanitize.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout Sanitized input.
function sanitize() {
    [[ -z $1 ]] && echo '' && return 0
    local sanitized="$1"

    # Trim.
    sanitized=$(trim "$sanitized")

    # Remove double and triple slashes.
    # Extract the protocol URL part (http:// or https://) (if exists).
    protocol="$(echo $sanitized | grep :// | sed -e's,^\(.*://\).*,\1,g')"

    # Remove the protocol.
    sanitized="${sanitized/${protocol}/}"

    # Remove unnecesary slashes.
    sanitized=$(echo "$sanitized" | tr -s /)

    # Readd the protocol (if exists).
    sanitized=${protocol}${sanitized}

    echo "$sanitized"
    return 0
}

# @description Determines if tox tests exists.
#
# This function tries:
# - Search for the $project_path/tox.ini file on $project_path.
#
# @arg $1 string Optional project path. Default to current_path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @return true if pytest tests exists, false otherwise.
function tox_exist() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Search for tox.ini file.
    [[ -f $project_path/tox.ini ]] && echo true && return 0

    echo false && return 0

}

# @description Execute tox tests.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function tox_run() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    if [[ $(tox_exist $project_path) == 'true' ]]; then

        tox_setup
        [ $? -eq 1 ] && return 1

        local python_exec=$(get_python_exec)

        local current_path=$(pwd)
        cd $project_path
        $python_exec -m tox
        cd $current_path

    fi

    return 0

}

# @description Setup tox tests.
#
# @noargs
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function tox_setup() {
    install_pip 'tox'
    [ $? -eq 1 ] && return 1
    return 0
}

# @description Trim whitespace at the beggining and end of a string.
#
# @arg $1 string Text where to apply trim.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout Trimmed input.
function trim() {

    [[ -z $1 ]] && return 1
    local trimmed="$1"

    # Strip leading spaces.
    while [[ $trimmed == ' '* ]]; do
       trimmed="${trimmed## }"
    done
    # Strip trailing spaces.
    while [[ $trimmed == *' ' ]]; do
        trimmed="${trimmed%% }"
    done

    echo "$trimmed" && return 0
}

# @description Uninstalls packages via apt.
#
# The packages must be space-separated: 'gedit hello pencil3d'
#
# @arg $1 string package name or list of packages to uninstall.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
function uninstall_apt() {

    [[ -z $1 ]] && return 1

    local package_array=($(echo $1 | tr " " "\n"))

    for package_name in ${package_array[@]}; do

        # If installed.
        if [[ $(validate_apt "$package_name") == 'true' ]]; then

            # If can uninstall.
            if [[ $(validate 'install') == 'true' ]]; then

                echo "Uninstalling $package_name ..."
                
                sudo apt purge -y "$package_name"
                sudo apt update
                sudo apt autoremove -y

            else
                error_message 'custom' "Can't uninstall ${package_name}."
                return 1
            fi

        fi

    done

    return 0
}

# @description Uninstalls Python packages via pip.
#
# This function ensures that Python, Pip and Setuptools are installed
# and then installs all required packages.
#
# You can pass to this function:
# - A filepath to a requirements*.txt file to be uninstalled.
# - A path to directory containing requirements*.txt files to uninstall.
# - A single package name.
#
# If this function is called without passing any argument to it,
# it will search for requirements*.txt files on the current directory.
#
# This function expects that each requirements filename has the text
# 'requirements' included on it.
#
# Each package will be checked to see if its installed, if installed
# then this function proceeds to uninstall it.
#
# @arg $1 string Optional filepath, path to dir or single package name.
#
# @exitcode 0 on success.
# @exitcode 1 on failure.
function uninstall_pip() {

    # Ensure requirements are installed.
    install_pip
    [ $? -eq 1 ] && return 1

    local python_exec=$(get_python_exec)

    # Path to where requirement files resides.
    local base_path=''
    local file_name=''

    local requirement_list=''

    # Check if single file.
    if ! [[ -z $1 ]] && [[ -f $1 ]]; then
        requirement_list=$1
        base_path=$(dirname $1)

    # Check if directory.
    elif ! [[ -z $1 ]] && [[ -d $1 ]]; then
        requirement_list=$(ls $1)
        base_path=$1

    # Single package, uninstall it.
    elif ! [[ -z $1 ]]; then

        if [[ $(validate_pip "$1") == 'true' ]]; then
            $python_exec -m pip uninstall -y $1
        fi

        return 0
    fi

    # If at least one requirement file exists.
    if [[ "$requirement_list" =~ .*requirements.*.txt ]]; then

        # Traverse all requirements files, i.e.:
        # requirements.txt, requirements-dev.txt.
        for requirement_file in $requirement_list; do

            if [[ "$requirement_file" == *'requirements'* ]]; then

                file_name=$(basename $requirement_file)

                # Copy file and add a newline to it to overcome bash limit.
                cp -f $base_path/$file_name reqs-current-tmp.txt
                echo '' >> reqs-current-tmp.txt

                # Traverse current requirements file checking item by
                # item if is installed or not.
                while read LINE
                do
                    # If installed, uninstall it.
                    if ! [[ -z $LINE ]] &&
                            [[ $(validate_pip "$LINE") == 'true' ]];
                    then
                        $python_exec -m pip uninstall -y $LINE
                    fi

                    # Traverse requirement items (item by item).
                done < reqs-current-tmp.txt
                rm reqs-current-tmp.txt

            fi

        # Traverse requirements files (file by file).
        done
    fi
    return 0
}

# @description Apply validations.
#
# The validation categories are:
# - install: Verifies if current user can install/uninstall via apt.
# - sudo: Verifies if current user can obtain administrative permissions.
# - package-name: Verifies if specific package is installed via apt or pip.
#
# This function assumes that everything that is not the word 'sudo',
# is a package name.
#
# @arg $1 string The word 'sudo' or a package name.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout '<program-name> not installed' when <program> is not installed.
function validate() {

    [[ -z $1 ]] && return 1
    local validation_name=$(sanitize "$1")

    case $validation_name in

        # Validate if the user can install/uninstall requirement via apt.
        install)
            # Verify if install requirements enabled.
            if [[ $INSTALL_REQUIREMENT == 'true' ]]; then
                [[ $(validate 'sudo') == 'true' ]] && echo true && return 0
            fi
            ;;

        # Validate permissions.
        sudo)
            # Verify if current user is root.
            local current_username=$(whoami)
            [[ "$current_username" == 'root' ]] && echo true && return 0

            # Verify if sudo is installed.
            if [[ $(validate_apt 'sudo') == 'false' ]]; then
                echo false && return 0
            fi

            # Verify if the current user belongs to groups 'sudo' or 'root'.
            local current_user_groups=$(groups $current_username)
            if [[ $current_user_groups == *'root'* ]] ||
                   [[ $current_user_groups == *'sudo'* ]]; then
                echo true && return 0
            fi

            # Verify if file /etc/sudoers.d/username exists.
            if [[ -f /etc/sudoers.d/$current_username ]]; then
                echo true && return 0
            fi
            ;;

        # Validate packages are installed.
        *)

            if [[ $(validate_apt "$validation_name") == 'true' ]];
            then
                echo true && return 0
            fi

            if [[ $(validate_pip "$validation_name") == 'true' ]];
            then
                echo true && return 0
            fi
            ;;
    esac

    echo false && return 0
}

# @description Determines if a package is installed via Apt.
#
# @arg $1 string The package name.
#
# @exitcode 0 on sucess.
# @exitcode 1 on failure.
#
# @stdout true if installed via apt, false otherwise.
function validate_apt() {

    [[ -z $1 ]] && echo false && return 1
    local package_name=$(sanitize "$1")

    # Verify if the package is installed via apt with apt-cache policy.
    local apt_cache_policy=$(apt-cache policy "$package_name" | head -n 2 | tail -n 1)

    # Verify if a (none), (ninguno), etc text don't exists.
    if ! [[ -z $apt_cache_policy ]] &&
            ! [[ "$apt_cache_policy" =~ .*\(.*\).* ]]; then
        echo true && return 0
    fi

    echo false && return 0
}

# @description Determines if a package is installed via pip.
#
# @arg $1 string The package name.
#
# @exitcode 0 on sucess.
# @exitcode 1 on failure.
#
# @stdout true if installed via pip, false otherwise.
function validate_pip() {

    [[ -z $1 ]] && echo false && return 1
    local package_name=$(sanitize "$1")

    # Verify python is installed.
    local python_exec=$(get_python_exec)
    [[ -z $python_exec ]] && echo false && return 1

    # Remove package version.
    # Set lowercase.
    package_name="${package_name,,}"

    # Remove from '=' to end.
    package_name="${package_name%=*}"

    # Remove from '>' to end.
    package_name="${package_name%>*}"

    # Remove from '<' to end.
    package_name="${package_name%<*}"

    # Check if the package to validate is pip itself.
    if [[ "$package_name" == "${python_exec}-pip" ]] ||
           [[ "$package_name" == 'pip' ]] ||
           [[ "$package_name" == 'pip3' ]]; then
        [[ $(validate_pip_installed) == 'true' ]] && echo true && return 0
        echo false && return 0
    fi

    # Verify pip is installed.
    if [[ $(validate_pip_installed) == 'false' ]]; then
        echo false && return 1
    fi

    # Get pip installed packages.
    local pip_list=$($python_exec -m pip list)

    # Set lowercase.
    pip_list="${pip_list,,}"

    # Replace '-' with '_'.
    pip_list="${pip_list//-/_}"
    package_name="${package_name//-/_}"

    # Add one space to prevent not finding the last package.
    pip_list="$pip_list "

    # Verify if package installed via pip.
    [[ $pip_list == *"$package_name "* ]] && echo true && return 0

    echo false && return 0
}

# @description Verifies if pip is installed.
#
# @noargs
#
# @exitcode 0 on success.
# @exitcode 1 on failure.
#
# @stdout true if installed, false otherwise.
function validate_pip_installed() {
    local python_exec=$(get_python_exec)
    [[ -z $python_exec ]] && echo false && return 1
    if [[ $(validate_apt "${python_exec}-pip") == 'true' ]]; then
        echo true && return 0
    fi
    $python_exec -m pip --version &>/dev/null
    [ $? -eq 0 ] && echo true && return 0
    echo false && return 0
}

# Avoid running the main function if we are sourcing this file.
return 0 2>/dev/null
main "$@"
