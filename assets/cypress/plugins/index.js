const cypressTypeScriptPreprocessor = require('./cy-ts-preprocessor')
const clipboardy = require('clipboardy')


module.exports = (on, config) => {
  on('file:preprocessor', cypressTypeScriptPreprocessor)

  on('task', {
    // Clipboard test plugin
    getClipboard: () => {
      const clipboard = clipboardy.readSync()
      return clipboard
    },
  })

  return config
}
