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
        'cool-gray': colors.coolGray,
        orange: colors.orange,
        green: colors.green,
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
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
  ],
}
