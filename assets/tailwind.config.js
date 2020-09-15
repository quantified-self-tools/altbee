const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  purge: {
    content: [
      '../lib/**/*.ex',
      '../lib/**/*.eex',
      '../lib/**/*.leex',
      './js/**/*.js'
    ]
  },
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans]
      }
    }
  },
  variants: {
  },
  plugins: [
    require('@tailwindcss/ui')
  ],
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true
  },
  experimental: 'all'
}
