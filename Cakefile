task "clean", "remove build artifacts", ->
  require('child_process').exec 'git clean -xf', (err, stdout, stderr) ->
    console.error(err) if err
    console.log(stdout) if stdout
    console.log(stderr) if stderr
