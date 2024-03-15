<?php
$plugins = array(
	'akismet/akismet.php'
);
foreach ( $plugins as $plugin ) {
	$path = dirname( __FILE__ ) . '/' . $plugin;
	// Add this line to ensure mu-plugins subdirectories can be symlinked
	wp_register_plugin_realpath( $path );
	include $path;
}