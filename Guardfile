guard 'sass', input: 'lib/rack/templates/assets/sass',
              output: 'lib/rack/templates/assets/css',
              style: :compressed

guard "uglify", input: "lib/rack/templates/assets/js/rwpt.js",
                output: "lib/rack/templates/assets/js/rwpt.min.js"

guard 'rack', host: '127.0.0.1', port: '9292', config: 'examples/rack/config.ru' do
  watch %r{^(examples|lib)/.*\.rb}
  watch 'config.ru'
end
