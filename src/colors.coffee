import chalk from 'chalk'

gray       = (s) -> chalk.gray s
gray.bold  = (s) -> chalk.gray.bold s
white      = (s) -> chalk.white s
white.bold = (s) -> chalk.white.bold s
white.dim  = (s) -> chalk.white.dim s

export {gray, white}
