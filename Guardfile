guard 'sass', input: 'lib/rack/templates/assets/sass',
              output: 'lib/rack/templates/assets/css',
              style: :compressed

guard "uglify", input: "lib/rack/templates/assets/js/rwpt.js",
                output: "lib/rack/templates/assets/js/rwpt.min.js"

guard :rspec, cmd: 'rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

guard 'rack', host: '0.0.0.0', port: '9292', config: 'examples/rack/config.ru' do
  watch %r{^(examples|lib)/.*\.rb}
  watch 'examples/rack/config.ru'
end
