const path = require('path')
const glob = require('glob')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const TerserPlugin = require('terser-webpack-plugin')
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin')
const CopyWebpackPlugin = require('copy-webpack-plugin')

const BABEL = {
  test: /\.js$/,
  exclude: /node_modules/,
  use: {
    loader: 'babel-loader'
  }
}

module.exports = (env, options) => {
  const devMode = options.mode !== 'production'

  return [
    {
      optimization: {
        minimizer: [
          new TerserPlugin({ cache: true, parallel: true, sourceMap: devMode }),
          new OptimizeCSSAssetsPlugin({})
        ]
      },
      entry: {
        app: glob.sync('./vendor/**/*.js').concat(['./js/app.js']),
      },
      output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '../priv/static/js'),
        publicPath: '/js/'
      },
      devtool: devMode ? 'source-map' : undefined,
      module: {
        rules: [
          BABEL,
          {
            test: /\.css$/,
            use: [
              MiniCssExtractPlugin.loader,
              'css-loader',
              'postcss-loader',
            ]
          }
        ]
      },
      plugins: [
        new MiniCssExtractPlugin({ filename: '../css/app.css' }),
        new CopyWebpackPlugin({ patterns: [{ from: 'static/', to: '../' }] }),
      ]
    },
    {
      entry: { sw: './js/sw.js' },
      output: {
        filename: '[name].js',
        path: path.resolve(__dirname, '../priv/static'),
        publicPath: '/'
      },
      devtool: devMode ? 'source-map' : undefined,

      module: {
        rules: [BABEL]
      }
    },
  ]
}
