<?php
/**
 * Plugin Name: mu-plugin Autoloader
 * Plugin URI: https://github.com/JayWood/
 * Description: This plugin autoloads plugins within the MU-Plugins directory.
 * Author: JayWood
 * Author URI: https://plugish.com/
 * Version: 1.0.0
 */
$plugins = array(
	'akismet/akismet.php'
);
foreach ( $plugins as $plugin ) {
	$path = dirname( __FILE__ ) . '/' . $plugin;
	// Add this line to ensure mu-plugins subdirectories can be symlinked
	wp_register_plugin_realpath( $path );
	include $path;
}