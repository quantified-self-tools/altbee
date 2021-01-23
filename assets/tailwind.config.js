const defaultTheme = require('tailwindcss/defaultTheme')
const colors = require('tailwindcss/colors')

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
      colors: {
        orange: colors.orange,
        teal: colors.teal,
      },
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans]
      },
    }
  },
  variants: {
    extend: {
      textDecoration: ['group-focus'],
      textColor: ['group-focus'],
      ringWidth: ['hover'],
      ringColor: ['hover'],
      backgroundColor: ['active'],
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
  ],
}
