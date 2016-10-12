var path = require('path');
var fs   = require('fs');

var webpack = require('webpack');

var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CopyPlugin        = require('copy-webpack-plugin');
var BrowserSyncPlugin = require('browser-sync-webpack-plugin');

// use the `OPTIMIZE` env VAR to switch from dev to production build
var optimize = process.env.OPTIMIZE === 'true';


// Stylesheets extractors
var CSSCommon     = new ExtractTextPlugin(optimize? 'common.[hash].css' : 'common.css')
var CSSApp        = new ExtractTextPlugin(optimize? 'app.[hash].css' : 'app.css')
var CSSOnBoarding = new ExtractTextPlugin(optimize? 'onboarding.[hash].css' : 'onboarding.css', {allChunks: true})


/**
 * Loaders used by webpack
 *
 * - CSS and images files from `vendor` are excluded
 * - stylesheets are optimized via cssnano, minus svgo and autoprefixer that are
 * customized via PostCSS
 * - images are cache-busted in production build
 */
var cssOptions = optimize? 'css?-svgo&-autoprefixer&-mergeRules!postcss':'css';
var imgPath = 'img/' + '[name]' + (optimize? '.[hash]': '') + '.[ext]';
var loaders = [
    {
        test: /\.coffee$/,
        loader: 'coffee'
    },
    {
        test: /app\.styl$/,
        loader: CSSApp.extract('style', cssOptions + '!stylus')
    },
    {
        test: /onboarding\.styl$/,
        loader: CSSOnBoarding.extract('style', cssOptions + '!stylus')
    },
    {
        test: /\.css$/,
        exclude: /vendor/,
        loader: CSSCommon.extract('style', cssOptions)
    },
    {
        test: /\.jade$/,
        loader: 'jade'
    },
    {
        test: /\.json$/,
        loader: 'json'
    },
    {
        test: /\.(png|gif|jpe?g|svg)$/i,
        exclude: /vendor/,
        loader: 'file?name=' + imgPath
    }
];

/**
 * Configure Webpack's plugins to tweaks outputs:
 *
 * all builds:
 * - ExtractTextPlugin: output CSS to file instead of inlining it
 * - CommonsChunkPlugin: push to _main_ file the common dependencies
 * - CopyPlugin: copy assets to public dir
 *
 * prod build:
 * - AssetsPlugin: paths to cache-busted's assets to read them from server
 * - DedupePlugin
 * - OccurenceOrderPlugin
 * - UglifyJsPlugin
 * - DefinePlugin: disable webpack env dev vars
 *
 * dev build:
 * - BrowserSyncPlugin: make hot reload via browsersync exposed at
 *   http://localhost:3000, proxified to the server app port
 */
var plugins = [
    CSSCommon,
    CSSApp,
    CSSOnBoarding,
    new webpack.optimize.CommonsChunkPlugin({
        name:      'main',
        children:  true,
        minChunks: 2
    }),
    new CopyPlugin([
        { from: 'vendor/assets' }
    ])
];

if (optimize) {
    plugins = plugins.concat([
        new webpack.optimize.DedupePlugin(),
        new webpack.optimize.OccurenceOrderPlugin(),
        new webpack.optimize.UglifyJsPlugin({
            mangle: true,
            compress: {
                warnings: false
            },
        }),
        new webpack.DefinePlugin({
            __SERVER__:      !optimize,
            __DEVELOPMENT__: !optimize,
            __DEVTOOLS__:    !optimize
        }),
        function() {
            this.plugin("done", function(stats) {
                fs.writeFileSync(
                    path.join(__dirname, '..', 'build', 'assets.json'),
                    '{"hash":"' + stats.hash + '"}'
                );
            });
        }
    ]);
} else {
    plugins = plugins.concat([
        new BrowserSyncPlugin({
            proxy: 'http://localhost:' + (process.env.PORT || 9104) + '/',
            open: false
        })
    ]);
}

/**
 * PostCSS Config
 *
 * - autoprefixer to add vendor prefixes for last 2 versions
 * - mqpacker to bring together all MQ rule's set
 */
var postcss = [
    require('autoprefixer')(['last 2 versions']),
    require('css-mqpacker')
];

/**
 * Webpack config
 *
 * - output to `public` dir
 * - cache-bust assets when build for production
 */

module.exports = {
    entry: './app/initialize',
    output: {
        path: path.join(optimize? '../build/client' : '', 'public'),
        filename: optimize? 'app.[hash].js' : 'app.js',
        chunkFilename: optimize? 'register.[hash].js' : 'register.js'
    },
    alias: {
      // Force all modules to use versions of backbone and underscore defined
      // in package.json to prevent duplicate dependencies
      'backbone': path.join(__dirname, 'node_modules', 'backbone', 'backbone.js'),
      'underscore': path.join(__dirname, 'node_modules', 'underscore', 'underscore.js')
    },
    resolve: {
        extensions: ['', '.js', '.coffee', '.jade', '.json']
    },
    debug: !optimize,
    devtool: 'source-map',
    module: {
        loaders: loaders
    },
    plugins: plugins,
    postcss: postcss
};
