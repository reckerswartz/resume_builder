const path = require("path")
const CssMinimizerPlugin = require("css-minimizer-webpack-plugin")
const MiniCssExtractPlugin = require("mini-css-extract-plugin")

module.exports = (_env, argv = {}) => {
  const mode = argv.mode || process.env.NODE_ENV || "production"
  const isProduction = mode === "production"

  return {
    mode,
    devtool: isProduction ? false : "source-map",
    stats: "errors-warnings",
    cache: isProduction ? {
      type: "filesystem",
      buildDependencies: {
        config: [
          __filename,
          path.resolve(__dirname, "postcss.config.js")
        ]
      }
    } : false,
    entry: {
      application: [
        "./app/javascript/application.js",
        "./app/assets/tailwind/application.css"
      ]
    },
    output: {
      filename: "[name].js",
      chunkFilename: "[name]-[contenthash].digested.js",
      sourceMapFilename: "[file].map",
      path: path.resolve(__dirname, "app/assets/builds"),
      clean: {
        keep: /(?:^|\/)\.keep$/
      },
      assetModuleFilename: "media/[name]-[contenthash].digested[ext]"
    },
    module: {
      rules: [
        {
          test: /\.css$/i,
          use: [
            MiniCssExtractPlugin.loader,
            {
              loader: "css-loader",
              options: {
                importLoaders: 1,
                sourceMap: !isProduction
              }
            },
            {
              loader: "postcss-loader",
              options: {
                sourceMap: !isProduction
              }
            }
          ]
        },
        {
          test: /\.(avif|eot|gif|ico|jpeg|jpg|png|svg|ttf|webp|woff|woff2)$/i,
          type: "asset/resource"
        }
      ]
    },
    optimization: {
      chunkIds: "deterministic",
      moduleIds: "deterministic",
      minimize: isProduction,
      minimizer: [
        "...",
        new CssMinimizerPlugin()
      ]
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: ({ chunk }) => chunk.name === "application" ? "app.css" : "[name].css"
      })
    ],
    watchOptions: {
      ignored: /node_modules/
    }
  }
}
