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

add_filter( 'auto_update_plugin', '__return_false' );
add_filter( 'auto_update_theme', '__return_false' );
add_filter( 'allow_dev_auto_core_updates', '__return_false' );
add_filter( 'allow_minor_auto_core_updates', '__return_false' );
add_filter( 'allow_major_auto_core_updates', '__return_false' );

add_action( 'wp_head', function() {
	echo <<<HTML
<style type="text/css">
html{scroll-behavior: smooth}
</style>
HTML;

} );

add_action('muplugins_loaded', function() {
	if (isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
		$_SERVER['HTTPS'] = 'on';
	}
} );
