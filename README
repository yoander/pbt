pbt is a tool written in BASH that allows you to compile PHP from the source code, pbt is the evolution of the php-build.sh script allowing greater flexibility and customization in the PHP compilation / installation process. Some of the advantages of using pbt are:

- Use a configuration file (pbt.ini) instead of the command line options.

- Download / uncompress the PHP version specified in the configuration file and start the compilation and installation process automatically.

- Allows to enable / disable common extensions through the common.conf file that is included in the DIR extensions.

- Allows you to enable / disable specific extensions, using the pbt.ini configuration file and files related to the extension, found in the DIR extensions, example: mysql.conf.

- Allows you to enable extensions for a specific PHP version, for example the php-7.2.x.conf file that is located under the DIR extensions.

- Allows executing actions prior to the compilation process such as installing necessary dependencies. The previous actions are under DIR pre-build, example of previous actions: centos, centos-php-7.2.x

- Allows to execute actions subsequent to the installation process such as creating the PHP configuration file and creation of initialization scripts. The final actions are under the DIR post-install.

- Use curl as a download manager allowing to use metalinks as long as the metalink feature is available, otherwise curl will be used in its standard form, the script will iterate through each PHP mirror until it finds the first one that responds successfully to the download request.

- Perform PHP integrity tests in case of failure the compilation process is aborted.pbt

## Directory structure

### Directories

** downloads: ** Cache of downloaded files if there was a partial or corrupt download should clean the cache.

** extensions: ** Extensions configuration.

** metalinks: ** The generated metalinks are saved, a metalink is generated for each version of PHP to be downloaded, the version is specified in the pbt.ini.

** post-install: ** Post-installation actions, example activate opcache.

** pre-build: ** Actions prior to the compilation process, example install dependencies.

** signatures: ** Where digital signatures are stored, digital signatures must be downloaded manually from the PHP site, see example within the DIR.
