# vim: set ft=ruby

# {{@@ header() @@}}
# FILE: ~/.pryrc

# ------------------------------------------------------------------------------
#          FILE:  .pryrc
#   DESCRIPTION:  IRB configuration file
#        AUTHOR:  Sorin Ionescu <sorin.ionescu@gmail.com>
#       VERSION:  1.0.0
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# General
# ------------------------------------------------------------------------------
Pry.editor = ENV['EDITOR'] || 'nvim'

# Load the Rails configuration if Pry is running as a rails console.
# load File.dirname(__FILE__) + '/.railsrc' if defined?(Rails) && Rails.env

# ------------------------------------------------------------------------------
# Prompt
# ------------------------------------------------------------------------------

def rails_prompt
  # Maybe this is only running as `pry` an not `rails console`, so check first
  return '' unless defined? Rails

  app_env =
    if Rails.env.production?
      puts "\n\e[1m\e[41mWARNING: YOU ARE USING RAILS CONSOLE IN PRODUCTION!\n" \
           "Changing data can cause serious data loss.\n" \
           "Make sure you know what you're doing.\e[0m\e[22m\n\n"
      "\e[31mproduction\e[0m" # red
    elsif Rails.env.development?
      "\e[32mdev\e[0m" # green
    elsif Rails.env.staging?
      "\e[32mstg\e[0m" # green
    else
      "\e[32m#{Rails.env[0...3]}\e[0m" # green
    end
  "(\e[1m#{app_env}\e[22m) " # bold
end

# now = proc { Time.new.strftime('%T%Z') } # or the time format you need it

# # For newer versions
# Pry::Prompt.add(:rich, 'It is mine') do |context, nesting, pry_instance, sep|
#   format(
#     # '[%<in_count>s][%<timestamp>s] %<name>s(%<context>s)%<rails_prompt>s%<nesting>s%<separator>s ',
#     '%<rails_prompt>s%<nesting>s%<separator>s ',
#     in_count: pry_instance.input_ring.count,
#     timestamp: now.call,
#     name: pry_instance.config.prompt_name,
#     context: Pry.view_clip(context),
#     rails_prompt: rails_prompt,
#     nesting: (nesting.positive? ? ":#{nesting}" : ''),
#     separator: sep
#   )
# end

# Pry.config.prompt = Pry::Prompt[:rich][:value]

default_prompt = Pry::Prompt[:default]

Pry.config.prompt = Pry::Prompt.new(
  'custom',
  'my custom prompt',
  [
    proc { |*args| "#{rails_prompt}#{default_prompt.wait_proc.call(*args)}" },
    proc { |*args| "#{rails_prompt}#{default_prompt.incomplete_proc.call(*args)}" }
  ]
)

# ------------------------------------------------------------------------------
# Syntax Highlighting
# ------------------------------------------------------------------------------
CodeRay.scan('example', :ruby).term

# https://github.com/rubychan/coderay/blob/master/lib/coderay/encoders/terminal.rb
TOKEN_COLORS = {
  attribute_name: '33',
  attribute_value: '31',
  binary: '1;35',
  char: {
    self: '36', delimiter: '34'
  },
  class: '1;35',
  class_variable: '36',
  color: '32',
  comment: '37',
  complex: '34',
  constant: %w[34 4],
  decoration: '35',
  definition: '1;32',
  directive: %w[32 4],
  doc: '46',
  doctype: '1;30',
  doc_string: %w[31 4],
  entity: '33',
  error: ['1;33', '41'],
  exception: '1;31',
  float: '1;35',
  function: '1;34',
  global_variable: '42',
  hex: '1;36',
  include: '33',
  integer: '1;34',
  key: '35',
  label: '1;15',
  local_variable: '33',
  octal: '1;35',
  operator_name: '1;29',
  predefined_constant: '1;36',
  predefined_type: '1;30',
  predefined: ['4', '1;34'],
  preprocessor: '36',
  pseudo_class: '34',
  regexp: {
    self: '31',
    content: '31',
    delimiter: '1;29',
    modifier: '35',
    function: '1;29'
  },
  reserved: '1;31',
  shell: {
    self: '42',
    content: '1;29',
    delimiter: '37'
  },
  string: {
    self: '36',
    modifier: '1;32',
    escape: '1;36',
    delimiter: '1;32'
  },
  symbol: '1;31',
  tag: '34',
  type: '1;34',
  value: '36',
  variable: '34',
  insert: '42',
  delete: '41',
  change: '44',
  head: '45'
}

module CodeRay
  module Encoders
    class Term < Encoder
      # Override old colors.
      TOKEN_COLORS.each_pair do |key, value|
        TOKEN_COLORS[key] = value
      end
    end
  end
end

# ------------------------------------------------------------------------------
# History
# ------------------------------------------------------------------------------

HISTORY_FILE = '~/.irb-save-history'
Pry.config.history_file = HISTORY_FILE

# ------------------------------------------------------------------------------
# Listing
# ------------------------------------------------------------------------------
Pry.config.ls.separator = "\n"
Pry.config.ls.heading_color = :magenta
Pry.config.ls.public_method_color = :green
Pry.config.ls.protected_method_color = :yellow
Pry.config.ls.private_method_color = :bright_black

# ------------------------------------------------------------------------------
# Plugins
# ------------------------------------------------------------------------------
# begin
#   require 'awesome_print'
#   # Enables Awesome Print and auto paging for all Pry output.
#   Pry.config.print = lambda do |output, value|
#     Pry::Helpers::BaseHelpers.stagger_output("=> #{value.ai}", output)
#   end

#   # Disable auto paging.
#   # Pry.config.print = lambda do |output, value|
#   #  output.puts value.ai
#   # end
# rescue LoadError => err
#   puts "Awesome Print is missing, please install it:"
#   puts "  gem install awesome_print"
# end

# ------------------------------------------------------------------------------
# Commands
# ------------------------------------------------------------------------------
# https://gist.github.com/1297510
default_command_set = Pry::CommandSet.new do
  command 'copy', 'Copy argument to the clip-board' do |str|
    IO.popen('pbcopy', 'w') { |f| f << str.to_s }
  end

  command 'fzf', 'Reverse search with fzf' do
    cmd = `cat #{HISTORY_FILE} | fzf --tac |  tr '\n' ' '`
    unless cmd.blank?
      output.puts cmd
      eval(cmd)
    end
  end

  command 'clear' do
    system 'clear'
    output.puts 'Rails Environment: ' + ENV['RAILS_ENV'] if ENV['RAILS_ENV']
  end

  command 'sql', 'Send SQL over ActiveRecord.' do |query|
    if ENV['RAILS_ENV'] || defined?(Rails)
      pp ActiveRecord::Base.connection.select_all(query)
    else
      pp 'No rails env defined'
    end
  end

  command 'caller_method' do |depth|
    depth = depth.to_i || 1
    if /^(.+?):(\d+)(?::in `(.*)')?/ =~ caller(depth + 1).first
      file = Regexp.last_match[1]
      line = Regexp.last_match[2].to_i
      method = Regexp.last_match[3]
      output.puts [file, line, method]
    end
  end
end

Pry.config.commands.import default_command_set

# ------------------------------------------------------------------------------
# Extensions
# ------------------------------------------------------------------------------
# Generate populated arrays and hashes.
# https://gist.github.com/807492
class Array
  def self.toy(n = 10, &block)
    block_given? ? Array.new(n, &block) : Array.new(n) { |i| i + 1 }
  end
end

class Hash
  def self.toy(n = 10)
    Array.toy(n).zip(Array.toy(n) { |c| (96 + (c + 1)).chr }).to_h
  end
end
