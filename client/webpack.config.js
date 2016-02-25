var path = require('path');

var webpack           = require('webpack');

var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CopyPlugin        = require('copy-webpack-plugin');
var AssetsPlugin      = require('assets-webpack-plugin');
var BrowserSyncPlugin = require('browser-sync-webpack-plugin');

var optimize = process.env.OPTIMIZE === 'true';

var autoprefixer = require('autoprefixer')(['last 2 versions']);
var mqpacker     = require('css-mqpacker');

var plugins = [
    new ExtractTextPlugin(optimize? 'app.[hash].css' : 'app.css'),
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
        new AssetsPlugin({
            filename: '../build/webpack-assets.json'
        }),
        new webpack.optimize.DedupePlugin(),
        new webpack.optimize.OccurenceOrderPlugin(),
        new webpack.optimize.UglifyJsPlugin({
            mangle:   true,
            compress: {
                warnings: false
            },
        }),
        new webpack.DefinePlugin({
            __SERVER__:      !optimize,
            __DEVELOPMENT__: !optimize,
            __DEVTOOLS__:    !optimize
        })
    ]);
} else {
    plugins = plugins.concat([
        new BrowserSyncPlugin({
            proxy: 'http://localhost:' + (process.env.PORT || 9104) + '/',
            open: false
        })
    ]);
}

module.exports = {
    entry: './app/initialize',
    output: {
        path: path.join(optimize? '../build/client' : '', 'public'),
        filename: optimize? 'app.[hash].js' : 'app.js',
        chunkFilename: optimize? 'register.[hash].js' : 'register.js'
    },
    resolve: {
        extensions: ['', '.js', '.coffee', '.jade', '.json']
    },
    debug: !optimize,
    devtool: 'source-map',
    module: {
        loaders: [
            {
                test: /\.coffee$/,
                loader: 'coffee'
            },
            {
                test: /\.styl$/,
                loader: ExtractTextPlugin.extract('style', optimize? 'css?-svgo&-autoprefixer&-mergeRules!postcss!stylus' : 'css!stylus')
            },
            {
                test: /\.css$/,
                exclude: /vendor/,
                loader: ExtractTextPlugin.extract('style', optimize? 'css?-svgo&-autoprefixer&-mergeRules!postcss' : 'css')
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
                loader:  'file?name=img/' + (optimize? '[name].[hash].[ext]' : '[name].[ext]')
            }
        ]
    },
    plugins: plugins,
    postcss: [autoprefixer, mqpacker]
};
