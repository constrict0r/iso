#!/bin/bash
#
# @file docthis
# @brief Generate documentation with Sphinx, from root run: ./docthish.sh.

# Path to project used as source, defaults to current path.
PROJECT_PATH=$(pwd)

# Python executable to use: python or python3. Empty by default.
PYTHON_EXEC=''

# Install requirements or not.
INSTALL_REQUIREMENT=false

# requirements.txt file contents.
REQUIREMENTS_PIP_CONTENTS='sphinx
sphinxcontrib-restbuilder
sphinxcontrib-globalsubs
Sphinx-Substitution-Extensions
sphinx_rtd_theme'

# conf.py file contents.
CONFIGURATION_CONTENTS='# Configuration for Sphinx documentation builder.

import os
import sys

project = "|PROJECT_GENERATED_NAME|"
copyright = "|YEAR_GENERATED_VALUE|, |AUTHOR_GENERATED_NAME|"
author = "|AUTHOR_GENERATED_NAME|"
version = "0.0.1"
release = "0.0.1"

sys.path.insert(0, os.path.abspath("../.."))

extensions = [
    "sphinxcontrib.restbuilder",
    "sphinxcontrib.globalsubs",
    "sphinx-prompt",
    "sphinx_substitution_extensions"
]

templates_path = ["_templates"]

exclude_patterns = []

html_static_path = ["_static"]

html_theme = "sphinx_rtd_theme"

master_doc = "index"

img_base_url = "https://raw.githubusercontent.com/"
img_url = img_base_url + author + "/" + project + "/master/img/"

author_img = ".. image:: " + img_url + "/author.png\\n   :alt: author"
author_slogan = "The Travelling Vaudeville Villain."

github_base_url = "https://github.com/"
github_url = github_base_url + author + "/" + project
github_badge = github_url + "workflows/CI/badge.svg\\n   :alt: github_ci"
github_ci_url = github_url + "/actions"
github_ci_link = "`Github CI <" + github_ci_url + ">`_."
github_link = "`Github <" + github_url + ">`_."

gitlab_base_url = "https://gitlab.com/"
gitlab_url = gitlab_base_url + author + "/" + project
gitlab_badge = gitlab_url + "/badges/master/pipeline.svg\\n   :alt: pipeline"
gitlab_ci_url = gitlab_url + "/pipelines"
gitlab_ci_link = "`Gitlab CI <" + gitlab_ci_url + ">`_."
gitlab_link = "`Gitlab <" + gitlab_url + ">`_."

travis_base_url = "https://travis-ci.org/"
travis_url = travis_base_url + author + "/" + project
travis_badge = ".. image:: " + travis_url + ".svg\\n   :alt: travis"
travis_ci_url = travis_url
travis_link = "`Travis CI <" + travis_url + ">`_."

readthedocs_url = "https://" + project + ".readthedocs.io"
readthedocs_badge = "/projects/" + project + "/badge\\n   :alt: readthedocs"
readthedocs_link = "`Readthedocs <" + readthedocs_url + ">`_."

gh_cover_base_url = "https://coveralls.io/repos/github/" + author + "/"
gh_cover_url = gh_cover_base_url + project + "/badge.svg"

gl_cover_base_url = "https://gitlab.com/" + author + "/" + project
gl_cover_url = gl_cover_base_url + "/badges/master/coverage.svg"

global_substitutions = {
    "AUTHOR_IMG": author_img,
    "AUTHOR_SLOGAN": author_slogan,
    "COVERAGE_GITHUB_BADGE":  ".. image:: " + gh_cover_url
    + "\\n   :alt: coverage",
    "COVERAGE_GITLAB_BADGE":  ".. image:: " + gl_cover_url
    + "\\n   :alt: coverage_gitlab",
    "GITHUB_BADGE": ".. image:: " + github_badge,
    "GITHUB_CI_LINK": github_ci_link,
    "GITHUB_LINK": github_link,
    "GITLAB_BADGE": ".. image:: " + gitlab_badge,
    "GITLAB_CI_LINK": gitlab_ci_link,
    "GITLAB_LINK": gitlab_link,
    "PROJECT": project,
    "READTHEDOCS_BADGE": ".. image:: https://rtfd.io" + readthedocs_badge,
    "READTHEDOCS_LINK": readthedocs_link,
    "TRAVIS_BADGE": travis_badge,
    "TRAVIS_LINK": travis_link
}

substitutions = [
    ("|AUTHOR|", author),
    ("|PROJECT|", project)
]
'

# .readthedocs.yml file contents.
READTHEDOCS_CONTENTS="---
version: 2

sphinx:
  configuration: doc/source/conf.py

python:
  version: 3.7
  install:
    - requirements: doc/requirements.txt

submodules:
  include: all"

# index.rst file contents.
INDEX_CONTENTS="|PROJECT_GENERATED_NAME|
============================================================================

|GITHUB_BADGE|

|GITLAB_BADGE|

|TRAVIS_BADGE|

|READTHEDOCS_BADGE|

|COVERAGE_GITHUB_BADGE|

|COVERAGE_GITLAB_BADGE|

My project short description.

Full documentation on |READTHEDOCS_LINK|.

Source code on:

|GITHUB_LINK|

|GITLAB_LINK|

Contents
============================================================================

.. toctree::

   description

   usage

   variable

   requirement

   compatibility

   license

   link

   author"

# description.rst file contents.
DESCRIPTION_CONTENTS='Description
----------------------------------------------------------------------------

Describe me.'

# usage.rst file contents
USAGE_CONTENTS="Usage
----------------------------------------------------------------------------

Download the script, give it execution permissions and execute it:

.. substitution-code-block:: bash

 wget https://raw.githubusercontent.com/|AUTHOR|/|PROJECT|/master/|PROJECT|.sh
 chmod +x |PROJECT|.sh
 ./|PROJECT|.sh -h"

# variable.rst file contents.
VARIABLE_CONTENTS="Variables
----------------------------------------------------------------------------

The following variables are supported:

- *-h* (help): Show help message and exit.

 .. substitution-code-block:: bash

  ./|PROJECT|.sh -h

- *-p* (path): Optional path to project root folder.

 .. substitution-code-block:: bash

  ./|PROJECT|.sh -p /home/username/myproject"

# requirement.rst file contents.
REQUIREMENT_CONTENTS='Requirements
----------------------------------------------------------------------------

- Python 3.'

# compatibility.rst file contents.
COMPATIBILITY_CONTENTS='Compatibility
----------------------------------------------------------------------------

- Debian buster.

- Raspbian buster.

- Ubuntu bionic.'

# license.rst file contents.
LICENSE_CONTENTS='License
----------------------------------------------------------------------------

MIT. See the LICENSE file for more details.'

# link.rst file contents.
LINK_CONTENTS='Links
----------------------------------------------------------------------------

- |GITHUB_LINK|

- |GITHUB_CI_LINK|

- |GITLAB_LINK|

- |GITLAB_CI_LINK|

- |TRAVIS_LINK|'

# author.rst file contents.
AUTHOR_CONTENTS='Author
----------------------------------------------------------------------------

|AUTHOR_IMG|

|AUTHOR_SLOGAN|'

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

# @description Escape especial characters.
#
# The escaped characters are:
#
#  - Period.
#  - Slash.
#  - Colon.
#
# @arg $1 string Text to scape.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout Escaped input.
function escape() {
    [[ -z $1 ]] && echo '' && return 0
    local escaped=$(sanitize "$1")
    # Escape period.
    escaped="${escaped//\./\\.}"
    # Escape slash.
    escaped="${escaped//\//\\/}"
    # Escape colon.
    escaped="${escaped//\:/\\:}"
    echo "$escaped" && return 0
}

# @description Setup Sphinx and generate html and rst documentation,
# generates a single README-single file that can be used on github
# or gitlab.
#
# @arg $1 string Optional project path. Default to current path.
# @arg $2 string Optional CI service to use for generating a coverage badge.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout *README-single* rst on project's root directory.
function generate() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    local doc_path=$(get_doc_path $project_path)

    local conf_path=$doc_path/source/conf.py

    # Valid values: 'github' or 'gitlab'.
    local coverage_ci='github'
    if ! [[ -z $2 ]]; then
        if [[ "$2" == 'github' ]] || [[ "$2" == 'gitlab' ]]; then
            coverage_ci="$2"
        fi
    fi

    local author=$(get_author $conf_path)

    local project=$(get_project $conf_path)

    local project_year=$(date +"%Y")

    # Setup everything for new projects.
    if ! [[ -f $conf_path ]]; then

        # Directory layout.
        mkdir -p $doc_path/source/_static &>/dev/null
        mkdir -p $doc_path/source/_templates &>/dev/null
        mkdir -p $doc_path/build/html &>/dev/null
        mkdir -p $doc_path/build/rst &>/dev/null

        # Create requirements.txt file.
        if ! [[ -f $doc_path/requirements.txt ]];
        then
            printf "$REQUIREMENTS_PIP_CONTENTS" > $doc_path/requirements.txt
        fi

        # Create conf.py file.
        if ! [[ -f $doc_path/source/conf.py ]];
        then
            printf "$CONFIGURATION_CONTENTS" > $conf_path
        fi

        # Create source files.
        if ! [[ -f $doc_path/source/index.rst ]]; then
            printf "$INDEX_CONTENTS" > $doc_path/source/index.rst
            printf "$DESCRIPTION_CONTENTS" > $doc_path/source/description.rst
            printf "$USAGE_CONTENTS" > $doc_path/source/usage.rst
            printf '%s' "$VARIABLE_CONTENTS" > $doc_path/source/variable.rst
            printf '%s' "$REQUIREMENT_CONTENTS" > $doc_path/source/requirement.rst
            printf '%s' "$COMPATIBILITY_CONTENTS" > $doc_path/source/compatibility.rst
            printf "$LICENSE_CONTENTS" > $doc_path/source/license.rst
            printf '%s' "$LINK_CONTENTS" > $doc_path/source/link.rst
            printf "$AUTHOR_CONTENTS" > $doc_path/source/author.rst
            sed -i -E "s/\|AUTHOR_GENERATED_NAME\|/$author/g" $doc_path/source/*.*
            sed -i -E "s/\|PROJECT_GENERATED_NAME\|/$project/g" $doc_path/source/*.*
            sed -i -E "s/\|YEAR_GENERATED_VALUE\|/$project_year/g" $doc_path/source/*.*
        fi

        # Create .readthedocs.yml configuration file.
        if ! [[ -f $project_path/.readthedocs.yml ]]; then
            printf '%s' "$READTHEDOCS_CONTENTS" > $project_path/.readthedocs.yml
        fi

        # Copy docthis.sh if not exists.
        if ! [[ -f $project_path/docthis.sh ]]; then
            cp "$( cd "$(dirname "$0")" ; pwd -P )"/docthis.sh $project_path/docthis.sh
        fi

    fi # New project?.

    if [[ $INSTALL_REQUIREMENT == 'true' ]]; then

        # Try to install Python requirements, stop if can't install them.
        install_pip $doc_path
        if [ $? -eq 1 ]; then
            error_message 'custom' "Python packages not installed."
            return 1
        fi

    fi

    # Before generating, validate that sphinx is installed.
    if [[ $(validate_apt "${python_exec}-sphinx") == 'false' ]] &&
           [[ $(validate_pip 'sphinx') == 'false' ]]; then
        error_message "sphinx"
        return 1
    fi

    # Cleanup old files.
    rm -rf $doc_path/build &>/dev/null
    rm -f $doc_path/source/index-tmp.rst &>/dev/null

    # Generate documentation.
    local python_exec=$(get_python_exec)
    $python_exec -m sphinx -b html $doc_path/source/ $doc_path/build/html
    generate_rst $project_path $coverage_ci

    return 0
}

# @description Generate rst documentation using sphinx.
#
# This function will extract each filename to include from the
# index.rst file and concatenate all files into a single
# README-single.rst file.
#
# This function assumes:
#   - The project has a file structure as created by generate().
#   - The index.rst file contains the :toctree: directive.
#
# @arg $1 string Optional project path. Default to current path.
# @arg $2 string Optional CI service to use for generating a coverage badge.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout *README-single* rst on project's root directory.
function generate_rst() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Valid values: 'gitlab' or 'travis'.
    local coverage_ci='travis'
    if ! [[ -z $2 ]]; then
        if [[ "$2" == 'gitlab' ]] || [[ "$2" == 'travis' ]]; then
            coverage_ci="$2"
        fi
    fi

    local project=$(get_project $project_path)

    local author=$(get_author $project_path)

    local doc_path=$(get_doc_path $project_path)

    local python_exec=$(get_python_exec)

    # This flag indicates if menu items where found on index.rst (toctree).
    local items_found=false

    # Clean files first.
    rm -r $doc_path/build/rst/*.rst &>/dev/null

    # Build rst files.
    $python_exec -m sphinx -b rst $doc_path/source/ $doc_path/build/rst

    # Construct the README-single file, add the index first.
    # Verify if index.rst exists.
    if [[ -f $doc_path/build/rst/index.rst ]]; then

        # Convert index.rst from readthedocs format to standard rst.
        readthedocs_to_rst $doc_path/build/rst/index.rst $project_path $coverage_ci
        # Add index.rst to README-single.rst.
        cat $doc_path/build/rst/index.rst > $project_path/README-single.rst
        printf '\n' >> $project_path/README-single.rst
    fi

    # Copy index.rst to index-tmp.rst and add a newline to it, this to
    # ensure to visit all lines because Bash expects a newline at the
    # end (C standard).
    cp -f $doc_path/source/index.rst $doc_path/source/index-tmp.rst
    echo '' >> $doc_path/source/index-tmp.rst

    # Here the index.rst file will be readed to search for menu items,
    # The directive :toctree: MUST be present or an empty file will
    # be generated.
    while read LINE
    do
        # The directive :toctree: of the index.rst file
        # activates the search for menu item lines within that file.
        [[ $LINE == *'toctree::'* ]] && items_found=true && continue

        if [[ $items_found == true ]] && ! [[ -z "$LINE"  ]]; then

            # Verify if the current file (described on LINE) exists.
            if [[ -f $doc_path/build/rst/${LINE}.rst ]]; then

                # Copy current to current-tmp and add newline (Bash issue).
                cp -f $doc_path/build/rst/${LINE}.rst $doc_path/build/rst/${LINE}-tmp.rst
                echo '' >> $doc_path/build/rst/${LINE}-tmp.rst

                # Convert current file from readthedocs to common rst.
                readthedocs_to_rst $doc_path/build/rst/${LINE}-tmp.rst $project_path $coverage_ci

                # Add current file to README-single.
                cat $doc_path/build/rst/${LINE}-tmp.rst >> $project_path/README-single.rst
                printf "\n" >> $project_path/README-single.rst

                # Remove temporary file.
                rm $doc_path/build/rst/${LINE}-tmp.rst
            fi

        fi

    done < $doc_path/source/index-tmp.rst
    rm $doc_path/source/index-tmp.rst

    return 0
}

# @description Get the author's name.
#
# @arg $1 string Path to the configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo author's name.
function get_author() {

    local conf_path=$1

    # Path to configuration file.
    if [[ -f $conf_path ]]; then
        local author=$(get_variable 'author' $conf_path)
        ! [[ -z $author ]] && echo $author && return 0
    fi
    whoami && return 0

}

# @description Obtains the project's documentation directory.
#
# This function tries:
# - Read a *.readthedocs.yml* file.
# - Search for the *./docs* directory.
# - Default to *./doc* directory.
#
# @arg $1 string Optional project path. Default to current path.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout Path to the documentation directory
function get_doc_path() {

    local project_path=$(pwd)
    [[ -d $1 ]] && project_path="$( cd "$1" ; pwd -P )"

    # Read documentation path from Readthedocs configuration.
    if [[ -f $project_path/.readthedocs.yml ]]; then

        local config_line=$(cat .readthedocs.yml | grep 'configuration')

        if ! [[ -z config_line ]]; then

            # Remove the 'configuration:' part.
            config_line=${config_line//configuration\: /}
            config_line=$(dirname $config_line)

            # Remove the 'source/' part.
            config_line=${config_line//source/}

            # Sanitize the string.
            config_line=$(sanitize "$config_line")

            # Get the full path.
            config_line=$(realpath -s $config_line)
            echo $config_line

            return 0
        fi
    fi

    # Try /docs.
    [[ -d $project_path/docs ]] && echo "$project_path/docs" && return 0

    # Default /doc.
    echo "$project_path/doc" && return 0

}

# @description Get the continuous integration repository URL for Github.
#
# If the URL cannot be found, then a default URL is returned.
#
# This function assumes:
#   - The project has a file structure as created by generate().
#
# @arg $1 string Path to the configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo Github continuous integration URL.
function get_github_ci_url() {

    local conf_path=$1

    if [[ -f $conf_path ]]; then

        local github_ci_url=$(get_variable 'github_ci_url' $conf_path)

        if ! [[ -z $github_ci_url ]]; then
            if [[ "$github_ci_url" =~ 'github_url' ]]; then
                local github_url=$(get_variable 'github_url' $conf_path)
                if ! [[ -z $github_url ]]; then
                    github_ci_url="${github_ci_url//github_url/$github_url}"
                fi
            fi

            if [[ "$github_ci_url" =~ 'github_base_url' ]]; then
                local github_base_url=$(get_variable 'github_base_url' $conf_path)
                if ! [[ -z $github_base_url ]]; then
                    github_ci_url="${github_ci_url//github_base_url/$github_base_url}"
                fi
            fi

            echo "$github_ci_url"
            return 0
        fi

    fi

    local author=$(get_author $conf_path)
    local project=$(get_project $conf_path)
    echo "https://github.com/$author/$project/actions"
    return 0

}

# @description Get the continuous integration repository URL for Gitlab.
#
# If the URL cannot be found, then a default URL is returned.
#
# This function assumes:
#   - The project has a file structure as created by generate().
#
# @arg $1 string Path to the configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo Gitlab continuous integration URL.
function get_gitlab_ci_url() {

    local conf_path=$1

    if [[ -f $conf_path ]]; then

        local gitlab_ci_url=$(get_variable 'gitlab_ci_url' $conf_path)

        if ! [[ -z $gitlab_ci_url ]]; then
            if [[ "$gitlab_ci_url" =~ 'gitlab_url' ]]; then
                local gitlab_url=$(get_variable 'gitlab_url' $conf_path)
                if ! [[ -z $gitlab_url ]]; then
                    gitlab_ci_url="${gitlab_ci_url//gitlab_url/$gitlab_url}"
                fi
            fi

            if [[ "$gitlab_ci_url" =~ 'gitlab_base_url' ]]; then
                local gitlab_base_url=$(get_variable 'gitlab_base_url' $conf_path)
                if ! [[ -z $gitlab_base_url ]]; then
                    gitlab_ci_url="${gitlab_ci_url//gitlab_base_url/$gitlab_base_url}"
                fi
            fi

            echo "$gitlab_ci_url"
            return 0
        fi

    fi

    local author=$(get_author $conf_path)
    local project=$(get_project $conf_path)
    echo "https://gitlab.com/$author/$project/pipelines"
    return 0

}

# @description Get the coverage badge URL for Github (coveralls).
#
# @arg $1 string Path to the configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo Github coverage (coveralls) badge URL.
function get_gh_cover_url() {

    local conf_path=$1

    if [[ -f $conf_path ]]; then

        local gh_cover_url=$(get_variable 'gh_cover_url' $conf_path)

        if ! [[ -z $gh_cover_url ]]; then
            if [[ "$gh_cover_url" =~ 'gh_cover_base_url' ]]; then
                local gh_cover_base_url=$(get_variable 'gh_cover_base_url' $conf_path)
                if ! [[ -z $gh_cover_base_url ]]; then
                    gh_cover_url="${gh_cover_url//gh_cover_base_url/$gh_cover_base_url}"
                fi
            fi

            echo "$gh_cover_url"
            return 0
        fi

    fi

    local author=$(get_author $conf_path)
    local project=$(get_project $conf_path)
    echo "https://coveralls.io/repos/github/$author/$project/badge.svg"
    return 0

}

# @description Get the coverage badge URL for Gitlab.
#
# @arg $1 string Path to the configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo Gitlab coverage badge URL.
function get_gl_cover_url() {

    local conf_path=$1

    if [[ -f $conf_path ]]; then

        local gl_cover_url=$(get_variable 'gl_cover_url' $conf_path)

        if ! [[ -z $gl_cover_url ]]; then
            if [[ "$gl_cover_url" =~ 'gl_cover_base_url' ]]; then
                local gl_cover_base_url=$(get_variable 'gl_cover_base_url' $conf_path)
                if ! [[ -z $gl_cover_base_url ]]; then
                    gl_cover_url="${gl_cover_url//gl_cover_base_url/$gl_cover_base_url}"
                fi
            fi

            echo "$gl_cover_url"
            return 0
        fi

    fi

    local author=$(get_author $conf_path)
    local project=$(get_project $conf_path)
    echo "https://gitlab.com/$author/$project/badges/master/coverage.svg"
    return 0

}

# @description Get the images repository URL.
#
# If the URL cannot be found, then a default Github URL is returned.
#
# This function assumes:
#   - The project has a file structure as created by generate().
#
# @arg $1 Path to the configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo repository images URL.
function get_img_url() {

    local conf_path=$1

    if [[ -f $conf_path ]]; then

        local img_url=$(get_variable 'img_url' $conf_path)
        if ! [[ -z $img_url ]]; then
            # Verify if img_url contains ../../ (local files).
            if [[ "$img_url" == *'../..'* ]]; then
                img_url="${img_url//\.\.\/\.\.\//\.\/}"
            fi
            echo "$img_url"
            return 0
        fi

    fi

    local author=$(get_author $conf_path)
    local project=$(get_project $conf_path)
    echo "https://raw.githubusercontent.com/$author/$project/master/img/"
    return 0

}

# @description Get bash parameters.
#
# Accepts:
#
#  - *h* (help).
#  - *i* (requirements).
#  - *p* <project-path>.
#  - *x* <python-executable>.
#
# @arg '$@' string Bash arguments.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
function get_parameters() {

    # Obtain parameters.
    while getopts 'h;i;p:x:' opt; do
        OPTARG=$(sanitize "$OPTARG")
        case "$opt" in
            h) help && exit 0;;
            i) INSTALL_REQUIREMENT=true;;
            p) PROJECT_PATH="${OPTARG}";;
            x) [[ "${OPTARG}" == *'python'* ]] && PYTHON_EXEC="${OPTARG}";;
        esac
    done

    return 0
}

# @description Get the project's name.
#
# @arg $1 string Path to configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo project's name.
function get_project() {

    local conf_path=$1

    if [[ -f $conf_path ]]; then
        local project=$(get_variable 'project' $conf_path)
        if [ $? -eq 0 ]; then
            ! [[ -z $project ]] && echo $project && return 0
        fi
    fi

    basename $(pwd) && return 0

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

# @description Get the continuous integration repository URL for Travis.
#
# If the  URL cannot be found, then a default URL is returned.
#
# This function assumes:
#   - The project has a file structure as created by generate().
#
# @arg $1 string Path to configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo continuous integration URL.
function get_travis_ci_url() {

    local conf_path=$1

    if [[ -f $conf_path ]]; then

        local travis_ci_url=$(get_variable 'travis_ci_url' $conf_path)

        if ! [[ -z $travis_ci_url ]]; then
            if [[ "$travis_ci_url" =~ 'travis_url' ]]; then
                local travis_url=$(get_variable 'travis_url' $conf_path)
                if ! [[ -z $travis_url ]]; then
                    travis_ci_url="${travis_ci_url//travis_url/$travis_url}"
                fi
            fi

            if [[ "$travis_ci_url" =~ 'travis_base_url' ]]; then
                local travis_base_url=$(get_variable 'travis_base_url' $conf_path)
                if ! [[ -z $travis_base_url ]]; then
                    travis_ci_url="${travis_ci_url//travis_base_url/$travis_base_url}"
                fi
            fi

            echo "$travis_ci_url"
            return 0
        fi

    fi

    local author=$(get_author $conf_path)
    local project=$(get_project $conf_path)
    echo "https://travis-ci.org/$author/$project"
    return 0

}

# @description Get a variable from the configuration file.
#
# @arg $1 string Required variable name.
# @arg $2 string Path to the configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo variable value.
function get_variable() {

    [[ -z $1 ]] && return 1
    local variable_name=$1

    local conf_path=$2

    if [[ -f $conf_path ]]; then

	local variable_value=$(get_variable_from_conf "$variable_name" $conf_path)
        [ $? -eq 1 ] && echo '' && return 1

        # Replace author, project, *_url, *_link and *_badge.
	variable_value=$(replace_tokens "$variable_value" $conf_path)

        # Remove '+'.
        variable_value="${variable_value//+/\/}"
        # Remove quotes.
        variable_value="${variable_value//\"/}"
        variable_value="${variable_value//\'/}"
        variable_value=$(sanitize "$variable_value")

        echo $variable_value
        return 0

    fi

    echo '' && return 1

}

# @description Get a raw variable from the configuration file.
#
# @arg $1 string Required variable name.
# @arg $2 string Path to the configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo variable value.
function get_variable_from_conf() {

    [[ -z $1 ]] && return 1
    local variable_name=$1

    local conf_path=$2

    if [[ -f $conf_path ]]; then

        local variable_value=''

        if  [[ "$variable_name" =~ .*_url ]] ||
                [[ "$variable_name" =~ .*_link ]] ||
                [[ "$variable_name" =~ .*_badge ]]; then

            variable_value=$(get_variable_line "$variable_name" $conf_path)
            [ $? -eq 1 ] && echo '' && return 1

        else
            variable_value=$(cat $conf_path | sed -n "s/^.*${variable_name}\s*\=\s*\(\S*\)\s*.*$/\1/p")
        fi

        # Remove quotes.
        variable_value="${variable_value//\"/}"
        variable_value="${variable_value//\"/}"
        variable_value="${variable_value//\'/}"
        variable_value="${variable_value//\'/}"
        echo $variable_value && return 0

    fi

    echo '' && return 1

}

# @description Get a matching line from the configuration file.
#
# @arg $1 string Required variable name.
# @arg $2 string Path to the configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo variable value.
function get_variable_line() {

    [[ -z $1 ]] && return 1
    local variable_name=$1

    local conf_path=$2

    if [[ -f $conf_path ]]; then

        local variable_value=''
        variable_value=$(grep "$variable_name =" $conf_path)

        # Remove spaces.
        variable_value="${variable_value//\ /}"

        # Remove variable_name=.
        variable_value="${variable_value//$variable_name=/}"

        # Sanitize.
        variable_value=$(sanitize "$variable_value")

        echo "$variable_value" && return 0

    fi

    echo '' && return 1

}

# @description Shows help message.
#
# @noargs
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
function help() {

    echo 'Uses Sphinx to generate html and rst documentation.'
    echo 'Parameters:'
    echo '-h (help): Show this help message.'
    echo '-i (requirements): Install requirements.'
    echo "-p <project-path>: Absolute path to project's root directory."
    echo '-x <python-executable>: Run using python or python3.'
    echo 'Example:'
    echo "./docthis.sh -i -p /home/user/my_project -x python3"
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

# @description Generate documentation using sphinx.
#
# @arg $@ string Bash arguments.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
function main() {

    get_parameters "$@"

    if ! [[ -d $PROJECT_PATH ]]; then
        error_message 'path'
        return 1
    fi

    generate "$PROJECT_PATH"

    return 0
}

# @description Replace reference from readthedocs format to standard rst.
#
# See `this link <https://gitlab.com/constrict0r/img>`_ for an example
# images repository.
#
# @arg $1 string Path to file where to apply replacements.
# @arg $2 string Optional project path. Default to current path.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout Modified passed file.
function readthedocs_to_rst() {

    ! [[ -f $1 ]] && return 1

    local project_path=$(pwd)
    [[ -d $2 ]] && project_path="$( cd "$2" ; pwd -P )"

    local doc_path=$(get_doc_path $project_path)

    local conf_path=$doc_path/source/conf.py

    local author=$(get_author $conf_path)

    local project=$(get_project $conf_path)

    local img_url=$(get_img_url $conf_path)
    img_url=$(escape $img_url)

    local gitlab_ci_url=$(get_gitlab_ci_url $conf_path)

    # Replace '/pipelines' by 'badges/master/pipeline'.
    gitlab_ci_url="${gitlab_ci_url//pipelines/badges\/master\/pipeline}"
    gitlab_ci_url=$(escape $gitlab_ci_url)

    local github_ci_url=$(get_github_ci_url $conf_path)

    # Replace '/actions' by '/workflows/CI/badge'.
    github_ci_url="${github_ci_url//actions/\/workflows\/CI\/badge}"
    github_ci_url=$(escape $github_ci_url)

    local travis_ci_url=$(get_travis_ci_url $conf_path)
    travis_ci_url=$(escape $travis_ci_url)

    local gh_cover_url=$(get_gh_cover_url $conf_path)
    gh_cover_url=$(escape $gh_cover_url)

    local gl_cover_url=$(get_gl_cover_url $conf_path)
    gl_cover_url=$(escape $gl_cover_url)

    # Convert all `<text.rst>`_ references to `<#text>`.
    sed -i -E "s/\<([[:alpha:]]*[[:punct:]]*)+\.rst\>//g" $1
    sed -i -E 's/([[:alpha:]]+)\ <>/\1\ <#\1>/g' $1

    # Replace travis-ci status badge image.
    sed -i -E "s@\[image\:\ travis\]\[image\]@\.\.\ image\:\:\ $travis_ci_url\.svg\\n   :alt: travis@g" $1

    # Replace gitlab-ci status badge image.
    sed -i -E "s@\[image\:\ pipeline\]\[image\]@\.\.\ image\:\:\ $gitlab_ci_url\.svg\\n   :alt: pipeline@g" $1

    # Replace github-ci status badge image.
    sed -i -E "s@\[image\:\ github_ci\]\[image\]@\.\.\ image\:\:\ $github_ci_url\.svg\\n   :alt: github_ci@g" $1

    # Replace readthedocs status badge image.
    sed -i -E "s@\[image\:\ readthedocs\]\[image\]@\.\.\ image\:\:\ https\:\/\/readthedocs\.org\/projects\/$project\/badge\\n   :alt: readthedocs@g" $1

    # Replace coverage status badge image on github using coveralls.
    sed -i -E "s@\[image\:\ coverage\]\[image\]@\.\.\ image\:\:\ https\:\/\/coveralls\.io\/repos\/github\/$author\/$project\/badge\.svg\\n   :alt: coverage@g" $1

    # Replace coverage status badge image on gitlab.
    sed -i -E "s@\[image\:\ coverage_gitlab\]\[image\]@\.\.\ image\:\:\ https\:\/\/gitlab\.com\/$author\/$project\/badges\/master\/coverage\.svg\\n   :alt: coverage_gitlab@g" $1

    # Replace rest of images.
    sed -i -E "s@\[image\:\ (.*)+\]\[image\]@\.\.\ image\:\:\ $img_url\1\.png\\n   :alt: \1@g" $1

    return 0
}

# @description Given an input string, replaces the tokens:
#
# - author
# - project
# - *_url
# - *_link
# - *_badge
#
# This function is recursive, this means that it will not
# stop replacing tokens until there is no token left.
#
# @arg $1 string Input text where to apply the substitutions.
# @arg $2 string Path to the configuration file.
#
# @exitcode 0 If successful.
# @exitcode 1 On failure.
#
# @stdout echo replaced string.
function replace_tokens() {

    [[ -z $1 ]] && return 1
    local variable_value="$1"

    local conf_path=$2

    if [[ -f $conf_path ]]; then

        local author=$(get_variable_from_conf 'author' $conf_path)
        local project=$(get_variable_from_conf 'project' $conf_path)

        # Replace author, project, *_url, *_link and *_badge.
        if [[ "$variable_value" =~ ((.*)_url).*$ ]] ||
               [[ "$variable_value" =~ ((.*)_link).*$ ]] ||
               [[ "$variable_value" =~ ((.*)_badge).*$ ]]; then

            variable_name="${BASH_REMATCH[1]}"
            local variable_subpart=$(get_variable_from_conf "$variable_name" $conf_path)

            if ! [[ -z $variable_subpart ]]; then
                variable_value="${variable_value//$variable_name/$variable_subpart}"
            fi
        fi

        variable_value="${variable_value//author/$author}"
        variable_value="${variable_value//project/$project}"

        # *_url, *_link or *_badge on the string yet?
        if [[ "$variable_value" =~ ((.*)_url).*$ ]] ||
               [[ "$variable_value" =~ ((.*)_link).*$ ]] ||
               [[ "$variable_value" =~ ((.*)_badge).*$ ]]; then
            echo $(replace_tokens "$variable_value" $conf_path)
            return 0
        fi

    fi

    echo "$variable_value" && return 0
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
    local pip_list=$($python_exec -m pip list --format=columns)

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

return 0 2>/dev/null
main "$@"
