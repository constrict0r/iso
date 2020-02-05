#!/bin/bash
#
# @file tests
# @brief Setup requirements and run tests, from root folder run: ./testme.sh.

# Default values.
# Become root password to pass to Ansible roles.
BECOME_PASS=''

# Wheter to generate or not a coverage report.
COVERAGE_REPORT=false

# String indicating to run only tests of specific types.
# The allowed values are: abmp, being a = ansible, 
# b = bats, m = molecule, p = python.
ONLY_TYPE=''

# Path to the project where to run tests, if not specified the current path
# will be used.
PROJECT_PATH=$(pwd)

# Python executable to use: python (python2) or python3.
PYTHON_EXEC=python

# When set to true, enter recursively on each directory on project's
# root folder and execute every testme.sh script found.
RECURSIVE=false

# Wheter to install or not requirements.txt files.
REQUIREMENTS_INSTALL=false

# Show time report on stdout when finished.
TIME=false

# @description Determines if ansible related tests exists.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @return true if ansible tests exists, false otherwise.
function ansible_tests_exists() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Bare metal tests (no molecule/docker).
    # Search for yml tests.
    ls $project_path/tests/*.yml &>/dev/null
    [ $? -eq 0 ] && echo true && return 0

    # Search for .yaml tests.
    ls $project_path/tests/*.yaml &>/dev/null
    [ $? -eq 0 ] && echo true && return 0

    # Brute force search, search ansible word on all files.
    # If we do not create soft links (with ln -s) for
    # plugins and modules it could crash the python and ansible tests.
    ! [[ -z $(grep -r "ansible" $project_path) ]] && echo true && return 0

    echo false && return 0

}

# @description Generates coverage report.
#
# Creates a .coverage file and a htmlcov folder.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @stdout .coverage file, htmlcov folder.
function coverage_report() {

    local python_exec='python'
    ! [[ -z $PYTHON_EXEC ]] && python_exec=$PYTHON_EXEC

    [[ $(validate $python_exec) == false ]] && return 1

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Check if bare metal tests exists.
    ls $project_path/tests/*.py &>/dev/null
    [ $? -eq 1 ] && return 1

    local pip_list=$($python_exec -m pip list)    

    if [[ $pip_list == *"coverage"* ]]; then
        local current_path=$(pwd)
        cd $project_path
        $python_exec -m coverage run --omit */*-packages/* -m pytest tests/*.py
        $python_exec -m coverage html
        cd $current_path
    fi
    return 0

}

# @description Shows an error message.
#
# @arg $1 string Message to show.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function error_message() {
    [[ -z $1 ]] && return 0
    local python_exec='python'
    
    case $1 in
    molecule)
        echo "An error occurred executing molecule."
        ;;
    path)
        echo "$1 is not an existent directory."
        ;;
    *)
        ! [[ -z $PYTHON_EXEC ]] && python_exec=$PYTHON_EXEC
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
        echo "$1 tests detected ..."
        echo "But $1 is not installed ..."
        echo "Install it with:"
        echo "sudo apt install $1"
        echo "Or run:"
        echo "sudo $python_exec -m pip install $1"
        echo "if it is a python package (i.e.: ansible)."
        ;;
    esac
    return 0
}

# @description Get bash parameters.
#
# Accepts:
#
#  - *c* (coverage report).
#  - *h* (help).
#  - *i* (install requirements).
#  - *K* (become password for Ansible roles).
#  - *o* <types> (only tests of type).
#  - *p* <path> (project_path).
#  - *r* (recursive).
#  - *t* (time report).
#  - *x* (python executable).
#
# @arg '$@' string Bash arguments.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function get_parameters() {

    # Obtain parameters.
    while getopts 'c;h;i;K:o:p:r;t;x:' opt; do
        OPTARG=$(sanitize "$OPTARG")
        case "$opt" in
            c) COVERAGE_REPORT=true;;
            h) help && exit 0;;
            i) REQUIREMENTS_INSTALL=true;;
            K) BECOME_PASS="${OPTARG}";;
            o) ONLY_TYPE="${OPTARG}";;
            p) PROJECT_PATH="${OPTARG}";;
            r) RECURSIVE=true;;
            t) TIME=true;;
            x) [[ "${OPTARG}" == *'python'* ]] && PYTHON_EXEC="${OPTARG}";;
        esac
    done

    return 0
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
    echo '-c (coverage): When present, generate coverage report.'
    echo '-h (help): Show this help message.'
    echo '-i (install requirements): When present all found requirements.txt
             files are installed.'
    echo '-K (become pass): Plain text sudo password (for Ansible roles).'
    echo '-o <only type> (type string): Optional string containing any of the
             following characters: a, b, m, p. Each one indicating to only
             execute a specific type of tests, being a = ansible, b = bats,
             m = molecule, p = python, for example the value "-o mp" will
             execute the molecule and python tests only.'
    echo '-p <file_path> (project path): Optional absolute file path to the
             root directory of the project to test. if this
             parameter is not especified, the current path will be used.'
    echo "-r (recursive): Enter recursively each directory on project's root
             directory and execute every testme.sh script found."
    echo '-t (time): Show time report when finished'
    echo '-x <python-exec> (executable): Select to run using python (python2)
             or python3. Defaults to python.'
    echo 'Example:'
    echo "./testme.sh -c -i -o abmp -p /home/username/project -r -x python3"
    return 0

}

# @description Create a parameters string to pass to each
# recursively called testme.sh.
#
# @arg $@ string Bash arguments.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @stdout Prints the created parameters string.
function create_recursive_parameters_string() {
    local become_pass_regex='-K (.*)'
    local python_exec_regex='-x (python[0-9]*)'
    local only_type_regex='-o ([abmp])+'
    local parameters_string=''

    [[ "$@" == *'-c'* ]] && parameters_string+='-c '
    [[ "$@" == *'-i'* ]] && parameters_string+='-i '

    if [[ $@ =~ $only_type_regex ]]; then
        parameters_string+="-o ${BASH_REMATCH[1]} "
    fi

    [[ "$@" == *'-t'* ]] && parameters_string+='-t '

    if [[ $@ =~ $python_exec_regex ]]; then
        parameters_string+="-x ${BASH_REMATCH[1]} "
    fi

    if [[ $@ =~ $become_pass_regex ]]; then
        parameters_string+="-K $(sanitize ${BASH_REMATCH[1]})"
    fi

    echo "${parameters_string}"

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
        error_message 'path'  
        return 1
    fi

    # Track time.
    [[ $TIME == true ]] && start_time=`date +%s`

    if [[ $RECURSIVE == true ]]; then

        # Verify if project has subdirectories.
        find "$PROJECT_PATH" -mindepth 1 -type d -print &>/dev/null
        [ $? -eq 1 ] && error_message 'path' && return 1

        # Create recursive parameters string from bash parameters string.
        local recursive_parameters=$(create_recursive_parameters_string "$@")

        # Enter each subdirectory checking if testme.sh exists.
        local directories_list=$(find $main_project -type d -print)

        for directory in $directories_list; do
            # if testme.sh exists and a .testignore does not exists, execute.
            if [[ -f $directory/testme.sh ]] && ! [[ -f $directory/.testignore ]]; then
                ./testme.sh -p $( cd "$directory" ; pwd -P ) $recursive_parameters
                show_time $start_time
            fi
        done

    else
        # Run bats tests.
        if [[ -z $ONLY_TYPE ]] || [[ $ONLY_TYPE == *'b'* ]]; then
            tests_bats "$PROJECT_PATH"
            [ $? -eq 1 ] && error_message 'bats'
        fi

        # Verify/setup python tests.
        if [[ $(python_tests_exists "$PROJECT_PATH") == true ]]; then

            if [[ $(validate $PYTHON_EXEC) == true ]]; then

                if [[ $REQUIREMENTS_INSTALL == true ]]; then
                    setup_python_requirements "$PROJECT_PATH"
                fi

                # Setup ansible plugins and modules when python or ansible tests.
                if [[ -z $ONLY_TYPE ]] || [[ $ONLY_TYPE == *'a'* ]] ||
                    [[ $ONLY_TYPE == *'p'* ]]; then

                    if [[ $(ansible_tests_exists "$PROJECT_PATH") == true ]]; then
                        setup_ansible_python_plugins "$PROJECT_PATH"
                        setup_ansible_python_modules "$PROJECT_PATH"
                    fi

                fi

                # Run ansible tests.
                if [[ -z $ONLY_TYPE ]] || [[ $ONLY_TYPE == *'a'* ]]; then
                    tests_ansible "$PROJECT_PATH" "$BECOME_PASS"
                    [ $? -eq 1 ] && error_message 'ansible'
                fi

                # Run molecule tests.
                if [[ -z $ONLY_TYPE ]] || [[ $ONLY_TYPE == *'m'* ]]; then
                    tests_molecule "$PROJECT_PATH"
                    [ $? -eq 1 ] && error_message 'molecule'
                fi

                # Run python tests.
                if [[ -z $ONLY_TYPE ]] || [[ $ONLY_TYPE == *'p'* ]]; then
                    tests_python "$PROJECT_PATH"
                    [ $? -eq 1 ] && error_message 'python'
                fi
            
                [[ $COVERAGE_REPORT == true ]] && coverage_report "$PROJECT_PATH"

            else
                error_message $PYTHON_EXEC
            fi

        fi # python tests?

    fi # recursive?

    [[ $TIME == true ]] && show_time $start_time
 
    return 0
}

# @description Determines if molecule tests exists.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @return true if molecule tests exists, false otherwise.
function molecule_tests_exists() {

    local python_exec='python'
    ! [[ -z $PYTHON_EXEC ]] && python_exec=$PYTHON_EXEC

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Search for molecule tests.
    ! [[ -d "$project_path/molecule" ]] && echo false && return 0

    local pip_list=$($python_exec -m pip list)

    [[ $pip_list == *"molecule"* ]] && echo true && return 0

    echo false && return 0

}

# @description Determines if python related tests exists.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @return true if python tests exists, false otherwise.
function python_tests_exists() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Molecule tests.
    if [[ $(molecule_tests_exists $project_path) == true ]]; then
        echo true
        return 0
    fi

    # Bare metal tests.
    # Search for plugins.
    [[ -d $project_path/test_plugins ]] && echo true && return 0

    # Bare metal tests.
    # Search for modules.
    [[ -d $project_path/library ]] && echo true && return 0

    # Bare metal tests.
    # Search for pytest tests.
    ls $project_path/tests/*.py &>/dev/null
    [ $? -eq 0 ] && echo true && return 0

    # Bare metal tests.
    # Search the playbook ./tests/test-playbook.yml.
    ls $project_path/tests/test-playbook.yml &>/dev/null
    [ $? -eq 0 ] && echo true && return 0

    echo false && return 0

}

# @description Sanitize input.
#
# The applied operations are:
#
# - Trim.
#
# @arg $1 string Text to sanitize.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
#
# @stdout Sanitized input.
function sanitize() {
    [[ -z $1 ]] && echo '' && return 0
    local sanitized="$1"
    # Trim.
    sanitized="${sanitized## }"
    sanitized="${sanitized%% }"
    echo "$sanitized"
    return 0
}

# @description Create symbolic links for modules.
#
# The modules on the following paths are linked:
#
#  - ./library
#
# To the locations:
#
#  - ./tests/library
#
# For each for .py file found, a soft link will be created.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function setup_ansible_python_modules() {

    local python_exec='python'
    ! [[ -z $PYTHON_EXEC ]] && python_exec=$PYTHON_EXEC

    [[ $(validate $python_exec) == false ]] && return 1

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    ls $project_path/library/*.py &>/dev/null
    if [ $? -eq 0 ]; then

        if ! [[ -d $project_path/tests/library ]]; then
            ln -s $project_path/library $project_path/tests/library
        fi

        # Once we know .py files exists, list again and store the listings.
        local module_list=$(ls $project_path/library/*.py)

        for module_item in $module_list; do
            $python_exec -m py_compile $module_item
        done
    fi
    return 0

}

# @description Create symbolic links for plugins.
#
# The plugins on the following paths are linked:
#
# - ./test_plugins
#
# To the locations:
#
# - ./tests/test_plugins
#
# For each for .py file found, a soft link will be created.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function setup_ansible_python_plugins() {

    local python_exec='python'
    ! [[ -z $PYTHON_EXEC ]] && python_exec=$PYTHON_EXEC

    [[ $(validate $python_exec) == false ]] && return 1

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    ls $project_path/test_plugins/*.py &>/dev/null
    if [ $? -eq 0 ]; then

        if ! [[ -d $project_path/tests/test_plugins ]]; then
            ln -fs $project_path/test_plugins $project_path/tests/test_plugins
        fi

        # Once we know .py files exists, list again and store the listings.
        local plugin_list=$(ls $project_path/test_plugins/*.py)
 
        for plugin_item in $plugin_list; do
            $python_exec -m py_compile $plugin_item
        done
    fi
    return 0

}

# @description Install requirement files.
#
# This function installs all requirements*.txt files found on
# project's root directory and if exists on docs/requirements.txt.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function setup_python_requirements() {

    local python_exec='python'
    ! [[ -z $PYTHON_EXEC ]] && python_exec=$PYTHON_EXEC

    [[ $(validate $python_exec) == false ]] && return 1

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    ls $project_path/requirements*.txt &>/dev/null

    if [ $? -eq 0 ]; then

        local requirement_list=$(ls $project_path/requirements*.txt)

        local packages_list=''

        # Traverse all requirements files, i.e.:
        # requirements.txt, requirements-dev.txt.
        for requirement_item in $requirement_list; do
            $python_exec -m pip install -r $requirement_item
        done

    fi

    # Verify if a docs/requirements.txt file exists.
    if [[ -f $project_path/docs/requirements.txt ]]; then
        $python_exec -m pip install -r $project_path/docs/requirements.txt
    fi

    return 0
}

# @description Shows the time the test took on stdout.
#
# This function uses the global variable PROJECT_PATH
# as the project folder whose time is being measured.
#
# If the PROJECT_PATH variable is not defined the current
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

    [[ $RECURSIVE == true ]] && [[ -f $PROJECT_PATH/.testignore ]] && return 0

    echo "PROJECT: $PROJECT_PATH"
    echo '
============================================================================='
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
==------===========--------========----======-------------===--------========'

    return 0
}

# @description Execute ansible tests.
#
# @arg $1 string Optional project path. Default to current path.
# @arg $2 string Optional become password.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function tests_ansible() {

    local python_exec='python'
    ! [[ -z $PYTHON_EXEC ]] && python_exec=$PYTHON_EXEC

    [[ $(validate $python_exec) == false ]] && return 1

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    ! [[ -d $project_path/tests ]] && return 0

    local become_parameter=''
    ! [[ -z $2 ]] && become_parameter="ansible_become_pass: '$2', "

    if [[ $(ansible_tests_exists "$PROJECT_PATH") == true ]]; then
        [[ $(validate 'ansible') == false ]] && return 1
    fi

    local yml_files=''

    ls $project_path/tests/*.yml &>/dev/null
    [ $? -eq 0 ] && yml_files=$(ls $project_path/tests/*.yml)

    ls $project_path/tests/*.yaml &>/dev/null
    [ $? -eq 0 ] && yml_files="$yml_files $(ls $project_path/tests/*.yaml)"

    # Bare metal tests, using test playbook files.
    # roles must be preinstalled with: ansible-galaxy install.
    for playbook in $yml_files; do

        if ! [[ -f $project_path/tests/inventory ]]; then
            echo 'localhost' > $project_path/tests/inventory
        fi

        ansible-playbook -i $project_path/tests/inventory $playbook -e \
            "{${ansible_become_pass}ansible_python_interpreter: '/usr/bin/$python_exec'}"

        # Clear history for security.
        history -c
    done

    return 0

}

# @description Execute bats tests.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function tests_bats() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    local project=$(basename $project_path)

    ls $project_path/tests/*.bats &>/dev/null
    [ $? -eq 1 ] && return 0

    [[ $(validate 'bats') == false ]] && return 1
    [[ -d $project_path/tests ]] && bats $project_path/tests

    return 0
}

# @description Execute molecule tests.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function tests_molecule() {

    local python_exec='python'
    ! [[ -z $PYTHON_EXEC ]] && python_exec=$PYTHON_EXEC

    [[ $(validate $python_exec) == false ]] && return 1

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Molecule tests.
    if [[ $(molecule_tests_exists $project_path) == true ]]; then
        local current_path=$(pwd)
        cd $project_path
        $python_exec -m molecule test
        cd $current_path
    fi
    return 0
}


# @description Execute python tests.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 if successful.
# @exitcode 1 on failure.
function tests_python() {

    local python_exec='python'
    ! [[ -z $PYTHON_EXEC ]] && python_exec=$PYTHON_EXEC

    [[ $(validate $python_exec) == false ]] && return 1

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    ls $project_path/tests/test*.py &>/dev/null
    if [ $? -eq 0 ]; then
        local current_path=$(pwd)
        cd $project_path
        $python_exec -m pytest --ignore molecule
        cd $current_path
    fi
    return 0

}

# @description Apply validations.
#
# The applied validations are:
#
#  - Verify if a system package is installed.
#
# @arg $1 string Name of the package to check.
#
# @exitcode 0 if valid.
# @exitcode 1 if invalid or on failure.
#
# @return true if the validations passed, false otherwise.
function validate() {

    [[ -z $1 ]] && echo false && return 1

    [[ -z $(which $1) ]] && echo false && return 1

    echo true && return 0
}

# Avoid running the main function if we are sourcing this file.
return 0 2>/dev/null
main "$@"
