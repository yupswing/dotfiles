#######################################################################################
# RUBY

# Rails aliases

alias rb='./bin/bundle'
alias rc='./bin/rails console'
alias rs='RUBY_DEBUG_OPEN=true ./bin/rails server'
# alias rbi='bundle install --path="vendor/bundle"'
alias rdh='rm -f db/schema.rb && ./bin/rails db:drop && ./bin/rails db:create && ./bin/rails db:migrate && ./bin/rails db:seed'
alias rdr='./bin/rails db:schema:load && ./bin/rails db:migrate && ./bin/rails db:seed'
