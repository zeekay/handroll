import fs from 'fs'

stat = (path) ->
  new Promise (resolve, reject) ->
    fs.stat path, (err, stats) ->
      return reject(err) if err?
      resolve stats

writeFile = (path, data) ->
  new Promise (resolve, reject) ->
    fs.writeFile path, data, 'utf-8', (err) ->
      return reject(err) if err?
      resolve()

export default stat: stat, writeFile: writeFile
