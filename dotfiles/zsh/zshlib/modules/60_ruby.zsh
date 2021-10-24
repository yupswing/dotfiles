#######################################################################################
# RUBY

# Rails aliases

alias ra='rails'
alias rc='rails console'
alias rt='rails spec'
alias rcc='./bin/spring stop && rails console'
alias rs='rails server'
alias rss='./bin/spring stop && rails server'
alias rbi='bundle install --path="vendor/bundle"'
alias rbu='bundle update'
alias rgen='rails generate'
alias rdh='rm -f db/schema.rb && rails db:drop && rails db:create && rails db:migrate && rails db:seed'
alias rdr='rails db:schema:load && rails db:migrate && rails db:seed'
