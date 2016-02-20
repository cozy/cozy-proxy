var webpack           = require('webpack');

var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CopyPlugin        = require('copy-webpack-plugin');

var production = process.env.NODE_ENV === 'production';

var plugins = [
    new ExtractTextPlugin('app.css'),
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
}

module.exports = {
    entry: './app/initialize',
    output: {
        path: path.join(production? '../build/client' : '', 'public'),
        filename: 'app.js',
        chunkFilename: 'register.js'
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
                loader: ExtractTextPlugin.extract('style', 'css?-svgo!stylus')
            },
            {
                test: /\.css$/,
                exclude: /vendor/,
                loader: ExtractTextPlugin.extract('style', 'css')
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
                loader: 'file?name=img/[name].[ext]'
            }
        ]
    },
    plugins: plugins,
};
