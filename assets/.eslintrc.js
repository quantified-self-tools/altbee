module.exports = {
  env: {
    browser: true,
    es2020: true
  },
  extends: [
    'standard'
  ],
  parserOptions: {
    ecmaVersion: 11,
    sourceType: 'module'
  },
  rules: {
    'arrow-parens': [
      2,
      'as-needed'
    ],
    'comma-dangle': [
      2,
      'only-multiline'
    ]
  }
}
