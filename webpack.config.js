const path = require("path")
const webpack = require("webpack")

module.exports = (_env, argv = {}) => ({
  mode: argv.mode || process.env.NODE_ENV || "production",
  devtool: "source-map",
  entry: {
    application: "./app/javascript/application.js"
  },
  output: {
    filename: "[name].js",
    sourceMapFilename: "[file].map",
    path: path.resolve(__dirname, "app/assets/builds"),
    assetModuleFilename: "[name]-[hash].digested[ext]"
  },
  module: {
    rules: [
      {
        test: /\.(eot|gif|jpeg|jpg|png|svg|ttf|webp|woff|woff2)$/i,
        type: "asset/resource"
      }
    ]
  },
  plugins: [
    new webpack.optimize.LimitChunkCountPlugin({
      maxChunks: 1
    })
  ]
})
