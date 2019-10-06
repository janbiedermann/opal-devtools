const path = require('path');
const OwlResolver = require('opal-webpack-loader/resolver'); // to resolve ruby files

const common_config = {
    target: 'web',
    context: path.resolve(__dirname, '../isomorfeus'),
    mode: "development",
    optimization: {
        minimize: false // dont minimize for debugging
    },
    performance: {
        maxAssetSize: 20000000,
        maxEntrypointSize: 20000000
    },
    // use one of these below for source maps
    // devtool: 'source-map', // this works well, good compromise between accuracy and performance
    // devtool: 'cheap-eval-source-map', // less accurate
    devtool: 'inline-source-map', // slowest
    // devtool: 'inline-cheap-source-map',
    resolve: {
        plugins: [
            // this makes it possible for webpack to find ruby files
            new OwlResolver('resolve', 'resolved')
        ],
        alias: {
            'react-dom': 'react-dom/profiling',
            'schedule/tracing': 'schedule/tracing-profiling',
        }
    },
    module: {
        rules: [
            {
                // loader for .scss files
                // test means "test for for file endings"
                test: /.scss$/,
                use: [
                    {
                        loader: "style-loader",
                        options: { hmr: true }
                    },
                    {
                        loader: "css-loader",
                        options: { sourceMap: true }
                    },
                    {
                        loader: "sass-loader",
                        options: {
                            includePaths: [path.resolve(__dirname, '../isomorfeus/styles')],
                            sourceMap: true // set to false to speed up hot reloads
                        }
                    }
                ]
            },
            {
                // loader for .css files
                test: /.css$/,
                use: [
                    {
                        loader: "style-loader"
                    },
                    {
                        loader: "css-loader",
                        options: { sourceMap: true }
                    }
                ]
            },
            {
                test: /.(png|svg|jpg|gif|woff|woff2|eot|ttf|otf)$/,
                use: [ "file-loader" ]
            },
            {
                // opal-webpack-loader will compile and include ruby files in the pack
                test: /(\.js)?\.rb$/,
                use: [
                    {
                        loader: 'opal-webpack-loader',
                        options: {
                            sourceMap: true,
                            hmr: false
                        }
                    }
                ]
            }
        ]
    },
};

const chrome_config = {
    entry: {
        "devtools-panel": [path.resolve(__dirname, '../isomorfeus/imports/devtools_panel.js')],
        "opal-inject": [path.resolve(__dirname, '../isomorfeus/imports/opal_inject.js')]
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '../chrome_extension/devtools/panel'),
        publicPath: '/'
    }
};

const firefox_config = {
    entry: {
        "devtools-panel": [path.resolve(__dirname, '../isomorfeus/imports/devtools_panel.js')],
        "opal-inject": [path.resolve(__dirname, '../isomorfeus/imports/opal_inject.js')]
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '../firefox_extension/devtools/panel'),
        publicPath: '/'
    }
};

const chrome = Object.assign({}, common_config, chrome_config);
const firefox = Object.assign({}, common_config, firefox_config);

module.exports = [ chrome, firefox ];
