var path = require('path');

var webpack           = require('webpack');

var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CopyPlugin        = require('copy-webpack-plugin');
var AssetsPlugin      = require('assets-webpack-plugin');
var BrowserSyncPlugin = require('browser-sync-webpack-plugin');

var production = process.env.NODE_ENV === 'production';

var autoprefixer = require('autoprefixer')(['last 2 versions']);
var mqpacker     = require('css-mqpacker');

var plugins = [
    new ExtractTextPlugin(production? 'app.[hash].css' : 'app.css'),
    new webpack.optimize.CommonsChunkPlugin({
        name:      'main',
        children:  true,
        minChunks: 2
    }),
    new CopyPlugin([
        { from: 'vendor/assets' }
    ])
];

if (production) {
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
            __SERVER__:      !production,
            __DEVELOPMENT__: !production,
            __DEVTOOLS__:    !production
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
        path: path.join(production? '../build/client' : '', 'public'),
        filename: production? 'app.[hash].js' : 'app.js',
        chunkFilename: production? 'register.[hash].js' : 'register.js'
    },
    resolve: {
        extensions: ['', '.js', '.coffee', '.jade', '.json']
    },
    debug: !production,
    devtool: production ? false : 'eval',
    module: {
        loaders: [
            {
                test: /\.coffee$/,
                loader: 'coffee'
            },
            {
                test: /\.styl$/,
                loader: ExtractTextPlugin.extract('style', production? 'css?-svgo&-autoprefixer&-mergeRules!postcss!stylus' : 'css!stylus')
            },
            {
                test: /\.css$/,
                exclude: /vendor/,
                loader: ExtractTextPlugin.extract('style', production? 'css?-svgo&-autoprefixer&-mergeRules!postcss' : 'css')
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
                loader:  'file?name=img/' + (production? '[name].[hash].[ext]' : '[name].[ext]')
            }
        ]
    },
    plugins: plugins,
    postcss: [autoprefixer, mqpacker]
};
