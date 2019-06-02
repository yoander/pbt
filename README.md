**pbt** is a tool written in BASH that allows you to compile PHP from the source code, pbt is the evolution of the php-build.sh script allowing greater flexibility and customization in the PHP compilation / installation process. Some of the advantages of using pbt are:

- Use a configuration file (pbt.ini) instead of the command line options.

- Download / uncompress the PHP version specified in the configuration file and start the compilation and installation process automatically.

- Allows to enable / disable common extensions through the common.conf file that is included in the DIR extensions.

- Allows to enable / disable specific extensions, using the pbt.ini configuration file and files related to the extension, found in the DIR extensions, example: mysql.conf.

- Allows to enable extensions for a specific PHP version, for example the php-7.2.x.conf file that is located under the DIR extensions.

- Allows to execute actions prior to the compilation process such as installing necessary dependencies. The previous actions are under pre-build DIR, example of previous actions: centos, centos-php-7.2.x.

- Allows to execute actions after the installation process such as creating the PHP configuration file and creation of initialization scripts (systemd, sysv). The final actions are under post-install DIR.

- Use curl as a download manager allowing to use metalinks as long as the metalink feature is available, otherwise curl will be used in its standard form, the script will iterate through each PHP mirror until it finds the first one that responds successfully to the download request.

- Perform PHP integrity tests in case of failure the compilation process is aborted.

## Directory structure

### Directories

**downloads:** Cache of downloaded files if there was a partial or corrupt download should be cleaned.

**extensions:** Extensions configuration.

**metalinks:** The generated metalinks are saved, a metalink is generated for each version of PHP to be downloaded, the version is specified in the pbt.ini.

**post-install:** Post-installation actions, example activate opcache.

**pre-build:** Actions prior to the compilation process, example install dependencies.

**signatures:** Where digital signatures are stored, digital signatures must be downloaded manually from the PHP site or using sigd tool distributed in the root DIR, sigd takes as granted that your DNS is not poisoned.

### Files

**pbt:** Script that executes download / compilation / installation processes.

**pbt.ini:** Configuration file.

**mirrors.txt:** Mirror list of where PHP will be downloaded in case curl does not support metalinks.

**template.metalink:** Template to create the metalinks

**sigd:** Tool to download signatures from PHP site, use jq package for JSON parsing.

## Configuration file

The configuration file **pbt.ini** allows to set parameters that will be used during the compilation process.

** php_version:** Set the version to download / compile.

** compression:** Sets the extension of the file to be downloaded.

** php_mode:** Sets the way PHP will run: fpm or mod_php

**fpm_user:** User under which the fpm service will be executed.

**fpm_group:** Group under which will execute the fpm service.

**fpm_listen:** Port in which the fpm service will be receiving connections.

**fpm_allowed_clients:** Allowed IPs (separated by,). Leave blank to allow access from any device.

**web_server:** It has the purpose of executing actions prior to compilation / post-installation, example to install the nginx server, see previous action: centos-nginx.

**install_prefix:** Directory where PHP will be installed.

**sysinit:** Specify how to create the initialization, sysv or systemd scripts.

**sysinit_versioned:** A value of "true" allows you to create versioned initialization scripts, example php72-fpm, allowing you to have installed / use more than one PHP version at the same time.

**databases:** Compiles PHP with the specific DB drivers also allows to execute actions prior/after to compilation process.

**php_env:** Create the php.ini according to the specified environment.

## How to use

```
$ ./pbt
```
