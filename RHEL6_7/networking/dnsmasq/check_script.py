#!/usr/bin/python2
# -*- Mode: Python; python-indent: 8; indent-tabs-mode: t -*-
"""
"""

import os
import re
from collections import namedtuple
from preup.script_api import *

check_applies_to (check_applies="dnsmasq")
check_rpm_to (check_rpm="", check_bin="python")

#END GENERATED SECTION
# exit functions are exit_{pass,not_applicable, fixed, fail, etc.}
COMPONENT = "DNSMASQ"
# logging functions are log_{error, warning, info, etc.}
# for logging in-place risk use functions log_{extreme, high, medium, slight}_risk
ConfFile = namedtuple("ConfFile", ["path", "buffer"])
CONFIG_FILE = "/etc/dnsmasq.conf"
FILES_TO_CHECK = []

# Exit codes
EXIT_NOT_APPLICABLE = 0
EXIT_PASS = 1
EXIT_INFORMATIONAL = 2
EXIT_FIXED = 3
EXIT_FAIL = 4
EXIT_ERROR = 5


class SolutionText(object):
    """
    class for handling construction of solution text.
    """
    def __init__(self):
        self.header = """Some issues have been found in your DNSMASQ configuration.
Use following solutions to fix them:"""
        self.tail = """For more information, please see the DNSMASQ manual page
'man 8 dnsmasq'."""
        self.solutions = []

    def add_solution(self, solution=""):
        if solution:
            self.solutions.append(solution)

    def get_text(self):
        text = self.header + "\n\n\n"
        for solution in self.solutions:
            text += solution + "\n\n\n"
        text += self.tail
        return text


# object used for creating solution text
sol_text = SolutionText()


#######################################################
### CONFIGURATION CHECKS PART - BEGIN
#######################################################


CONFIG_CHECKS = []


def register_check(check):
    """
    Function decorator that adds configuration check into list of checks.
    """
    CONFIG_CHECKS.append(check)
    return check


def run_checks(files_to_check):
    """
    Runs all available checks on files loaded into files_to_check list.
    """
    gl_result = EXIT_PASS

    for check in CONFIG_CHECKS:
        log_info("Running check: \"" + check.__name__ + "\"")
        for fpath, buff in FILES_TO_CHECK:
            log_info("checking: \"" + fpath + "\"")
            result = check(fpath, buff)
            if result > gl_result:
                gl_result = result

    return gl_result


@register_check
def check_interface_labels(file_path, buff):
    """
    Handle IPv4 interface-address labels in Linux. These are
    often used to emulate the old IP-alias addresses. Before,
    using --interface=eth0 would service all the addresses of
    eth0, including ones configured as aliases, which appear
    in ifconfig as eth0:0. Now, only addresses with the label
    eth0 are active. This is not backwards compatible: if you
    want to continue to bind the aliases too, you need to add
    eg. --interface=eth0:0 to the config.
    """

    status = EXIT_PASS

    interface_pattern_str = "interface=(.+)"
    interface_pattern = re.compile(interface_pattern_str)
    interface_stat_iter = interface_pattern.finditer(buff)

    for statement in interface_stat_iter:
        log_medium_risk("Found '" + statement.group(0) + "' option in \"" + file_path + "\".")
        status = EXIT_FAIL

    if status == EXIT_FAIL:
        sol_text.add_solution(
"""'interface' option with defined interface name:
--------------------------------------------------
Previously, dnsmasq configured with ex. '--interface=eth0' would bind
and listen on all addresses of the 'eth0' interface, including addresses
configured as aliases (which appear in ifconfig output as ex. 'eth0:0').
Now only addresses with the label 'eth0' are used (in other words, the
addresses configured as aliases for the interface are NOT used).
If you want dnsmasq to continue to listen on addresses configured as
asliases for the interface, you have to specify each alias in the
configuration using the 'interface' option (ex. '--interface=eth0:0').""")

    return status


@register_check
def check_dhcp_tags(file_path, buff):
    """
    Rationalised the DHCP tag system. Every configuration item
    which can set a tag does so by adding "set:<tag>" and
    every configuration item which is conditional on a tag is
    made so by "tag:<tag>". The NOT operator changes to '!',
    which is a bit more intuitive too. Dhcp-host directives
    can set more than one tag now. The old '#' NOT,
    "net:" prefix and no-prefixes are still honoured, so
    no existing config file needs to be changed, but
    the documentation and new-style config files should be
    much less confusing.
    """

    status = EXIT_PASS
    dhcp_tag_pattern_str = ".*=(.*?net:.+)"
    dhcp_tag_pattern = re.compile(dhcp_tag_pattern_str)
    dhcp_tag_iter = dhcp_tag_pattern.finditer(buff)

    for statement in dhcp_tag_iter:
        log_slight_risk("It looks like you are using DHCP tags ('" + statement.group(0) + "') in \"" + file_path + "\".")
        status = EXIT_INFORMATIONAL

    if status == EXIT_INFORMATIONAL:
        sol_text.add_solution(
"""Using DHCP tag system:
-------------------------
In new dnsmasq version, the way of configuring tags used in DHCP options
have changed. The old way is still still works, but it is advised to use
the new syntax for new configurations and if possible also for existing
ones. The new syntax in configuration options supprting tags is as follows:
- To set a tag, use 'set:<tag>' as the argument of the option.
- To match a tach, use 'tag:<tag>' as the argument of the option,
  (instead of old 'net:<tag>' way).
- As a NOT operator use '!' (instead of old '#').

dhcp-host option can now set more than one tag.""")

    return status


#######################################################
### CONFIGURATION CHECKS PART - END
#######################################################


def is_config_changed():
    """
    Checks if configuration files changed.
    """
    with open(VALUE_ALLCHANGED, "r") as f:
        files = f.read()
        for fpath, buff in FILES_TO_CHECK:
            found = re.findall(fpath, files)
            if found:
                return True
    return False


def return_with_code(code):
    if code == EXIT_FAIL:
        exit_fail()
    elif code == EXIT_FIXED:
        exit_fixed()
    elif code == EXIT_NOT_APPLICABLE:
        exit_not_applicable()
    elif code == EXIT_PASS:
        exit_pass()
    elif code == EXIT_ERROR:
        exit_error()
    elif code == EXIT_INFORMATIONAL:
        exit_informational()
    else:
        exit_unknown()


def remove_comments(lines):
    """
    Removes the following types of comments from passed string and returns it:
    # .*
    """
    string = ""
    for line in lines:
        tmp = line.strip()
        if tmp and not tmp.startswith("#"):
            string += tmp + "\n"
    return string


def is_file_loaded(path=""):
    """
    Checks if file with given 'path' is already loaded in FILES_TO_CHECK.
    """
    for f in FILES_TO_CHECK:
        if f.path == path:
            return True
    return False


def load_more_config():
    """
    Finds configuration files that are included in some configuration
    file, reads it, closes and adds into FILES_TO_CHECK list.
    """
    def load_config_file(path=""):
        """
        Load file with the given path if it is not already loaded.
        """
        if is_file_loaded(path):
            return
        try:
            f = open(path, 'r')
        except:
            log_error("Cannot open configuration file: \"" + path + "\"")
            exit_error()
        else:
            log_info("Loading configuration file \"" + path + "\"")
            filtered_string = remove_comments(f.readlines())
            f.close()
            FILES_TO_CHECK.append(ConfFile(buffer=filtered_string,
                                           path=path))


    def load_config_from_dir(path=""):
        """
        Walk recursively through the given dir and load all files.
        """
        def filter_files(path):
            if os.path.isfile(path):
                f = os.path.split(path)[1]
                if not f.endswith("~") and not f.startswith(".") and not (f.startswith("#") and f.endswith("#")):
                    return True
            return False

        log_info("Checking \"" + path + "\" for configuration files...")
        files = [ os.path.join(path, f) for f in os.listdir(path) if filter_files(os.path.join(path, f)) ]
        for f in files:
            load_config_file(os.path.join(path, f))


    pattern_conf_file = re.compile("conf-file\s*=\s*(.+)\s*")
    pattern_conf_dir = re.compile("conf-dir\s*=\s*(.+)\s*")

    # walk through all already loaded files
    for ch_file in FILES_TO_CHECK:
        # find all configuration files
        config_files = pattern_conf_file.findall(ch_file.buffer)
        for f in config_files:
            load_config_file(f)
        # find all condiguration directories
        config_dirs = pattern_conf_dir.findall(ch_file.buffer)
        for d in config_dirs:
            load_config_from_dir(d)


def load_main_config():
    """
    Loads main CONFIG_FILE.
    """
    try:
        f = open(CONFIG_FILE, 'r')
    except IOError:
        log_error(
            "Cannot open the configuration file: \"" + CONFIG_FILE + "\"")
        exit_error()
    else:
        log_info("Loading configuration file: \"" + CONFIG_FILE + "\"")
        filtered_string = remove_comments(f.readlines())
        f.close()
        FILES_TO_CHECK.append(ConfFile(buffer=filtered_string,
                                       path=CONFIG_FILE))


def main():
    load_main_config()
    load_more_config()
    # need to check also paths of included files
    if not is_config_changed():
        return_with_code(EXIT_NOT_APPLICABLE)
    result = run_checks(FILES_TO_CHECK)
    # if there was some issue, write a solution text
    if result > EXIT_PASS:
        solution_file(sol_text.get_text())
    return_with_code(result)


if __name__ == "__main__":
    set_component(COMPONENT)
    main()