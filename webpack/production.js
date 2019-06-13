const path = require('path');
const OwlResolver = require('opal-webpack-loader/resolver');

module.exports = {
    target: 'web',
    context: path.resolve(__dirname, '../isomorfeus'),
    mode: "production",
    optimization: {
        minimize: false
    },
    performance: {
        maxAssetSize: 20000000,
        maxEntrypointSize: 20000000
    },
    resolve: {
        plugins: [
            new OwlResolver('resolve', 'resolved') // resolve ruby files
        ]
    },

    entry: {
        "devtools-panel": [path.resolve(__dirname, '../isomorfeus/imports/devtools_panel.js')],
        "opal-inject": [path.resolve(__dirname, '../isomorfeus/imports/opal_inject.js')]
    },
    output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '../extension/devtools/panel'),
        publicPath: '/'
    },
    module: {
        rules: [
            {
                test: /.scss$/,
                use: [
                    {
                        loader: "style-loader",
                        options: { hmr: false }
                    },
                    {
                        loader: "css-loader",
                        options: {
                            sourceMap: false, // set to false to speed up hot reloads
                            minimize: true // set to false to speed up hot reloads
                        }
                    },
                    {
                        loader: "sass-loader",
                        options: {
                            includePath: [path.resolve(__dirname, '../isomorfeus/styles')],
                            sourceMap: false // set to false to speed up hot reloads
                        }
                    }
                ]
            },
            {
                // loader for .css files
                test: /.css$/,
                use: [ "style-loader", "css-loader" ]
            },
            {
                test: /.(png|svg|jpg|gif|woff|woff2|eot|ttf|otf)$/,
                use: [ "file-loader" ]
            },
            {
                // opal-webpack-loader will compile and include ruby files in the pack
                test: /.(rb|js.rb)$/,
                use: [
                    { loader: "cache-loader" },
                    {
                        loader: 'opal-webpack-loader',
                        options: {
                            sourceMap: false,
                            hmr: false
                        }
                    }
                ]
            }
        ]
    }
};
