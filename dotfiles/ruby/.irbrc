# vim: set ft=ruby

# {{@@ header() @@}}
# FILE: ~/.irbrc

# Make gems available
require 'rubygems'
# include Date automatically as well as Time enhancements
require 'date'
require 'time'

ANSI = { RESET: "\e[0m",
         BOLD: "\e[1m",
         UNDERLINE: "\e[4m",
         LGRAY: "\e[0;37m",
         GRAY: "\e[0;90m",
         RED: "\e[31m",
         GREEN: "\e[32m",
         YELLOW: "\e[33m",
         BLUE: "\e[34m",
         MAGENTA: "\e[35m",
         CYAN: "\e[36m",
         WHITE: "\e[37m" }

# Build a simple colorful IRB prompt
IRB.conf[:PROMPT][:SIMPLE_COLOR] = {
  PROMPT_I: "#{ANSI[:BLUE]}»#{ANSI[:RESET]} ",
  PROMPT_N: "#{ANSI[:BLUE]}»#{ANSI[:RESET]} ",
  PROMPT_C: "#{ANSI[:RED]}?#{ANSI[:RESET]} ",
  PROMPT_S: "#{ANSI[:YELLOW]}?#{ANSI[:RESET]} ",
  RETURN: "#{ANSI[:GREEN]}=>#{ANSI[:RESET]} %s\n",
  AUTO_INDENT: true
}

# ARGV.concat ['--readline', '--prompt-mode', 'simple']

# IRB_START_TIME = Time.now

# Load the readline module.
# disable autocomple if enabled
# IRB.conf[:USE_READLINE] = true

# Replace the irb(main):001:0 with a simple >>
IRB.conf[:PROMPT_MODE] = :SIMPLE_COLOR
# Tab completion
require 'irb/completion'
# Automatic indentation
IRB.conf[:AUTO_INDENT] = true
# Save History between irb sessions
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV.fetch('HOME', nil)}/.irb-save-history"

# Loading extensions of the console. This is wrapped
# because some might not be included in your Gemfile
# and errors will be raised.
def extend_console(name, care = true, required = true)
  if care
    require name if required
    yield if block_given?
    $console_extensions << "#{ANSI[:GREEN]}#{name}#{ANSI[:RESET]}"
  else
    $console_extensions << "#{ANSI[:GRAY]}#{name}#{ANSI[:RESET]}"
  end
rescue LoadError
  $console_extensions << "#{ANSI[:RED]}#{name}#{ANSI[:RESET]}"
end
$console_extensions = []

# Hirb is a mini view framework for console applications, designed
# to make formatting of ActiveRecord objects easier on the eyes
# http://tagaholic.me/2009/03/13/hirb-irb-on-the-good-stuff.html
extend_console 'hirb' do
  Hirb.enable
  extend Hirb::Console
end

if ENV['RAILS_ENV']
  rails_env = ENV['RAILS_ENV']
  rails_root = File.basename(Dir.pwd)

  # #{ANSI[:GREEN]}#{rails_root}
  prompt = "#{ANSI[:BOLD]}rails#{ANSI[:GREEN]}[#{rails_env.sub('production', 'prod').sub('development',
                                                                                         'dev')}]#{ANSI[:RESET]}"
  IRB.conf[:PROMPT][:RAILS] = {
    PROMPT_I: "#{prompt} #{ANSI[:BLUE]}»#{ANSI[:RESET]} ",
    PROMPT_N: "#{prompt} #{ANSI[:BLUE]}»#{ANSI[:RESET]} ",
    PROMPT_C: "#{prompt} #{ANSI[:RED]}?#{ANSI[:RESET]} ",
    PROMPT_S: "#{prompt} #{ANSI[:YELLOW]}?#{ANSI[:RESET]} ",
    RETURN: "#{ANSI[:GREEN]}=>#{ANSI[:RESET]} %s\n",
    AUTO_INDENT: true
  }

  IRB.conf[:PROMPT_MODE] = :RAILS

  # if IRB.conf[:VERBOSE]

  # Redirect log to STDOUT, which means the console itself
  IRB.conf[:IRB_RC] = proc do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.instance_eval { alias :[] :find }
  end

  extend_console 'rails3', defined?(ActiveSupport::Notifications), false do
    $odd_or_even_queries = false
    ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
      $odd_or_even_queries = !$odd_or_even_queries
      color = $odd_or_even_queries ? ANSI[:CYAN] : ANSI[:MAGENTA]
      event = ActiveSupport::Notifications::Event.new(*args)
      time  = '%.1fms' % event.duration
      name  = event.payload[:name]
      sql   = event.payload[:sql].gsub("\n", ' ').squeeze(' ')
      puts "  #{ANSI[:UNDERLINE]}#{color}#{name} (#{time})#{ANSI[:RESET]}  #{sql}"
    end
  end

  # else

  #   IRB.conf[:IRB_RC] = proc do
  #     ActiveRecord::Base.logger = nil
  #   end

  # end

  def tables
    ActiveRecord::Base.connection.tables.sort!
  end

  def columns(table)
    ActiveRecord::Base.connection.columns(table).map(&:name).sort!
  end

  def models
    tables.reject { |t| t == 'schema_migrations' }.map { |t| t.underscore.singularize.camelize.to_sym }
  end

  #   ### RAILS SPECIFIC HELPER METHODS
  #   def log_ar_to(stream)
  #     ActiveRecord::Base.logger = expand_logger stream
  #     reload!
  #   end

  #   def log_ac_to(stream)
  #     ActionController::Base.logger = expand_logger stream
  #     reload!
  #   end

  #   def expand_log_file(name)
  #     "log/#{name}.log"
  #   end

  #   def expand_logger(name)
  #     logger = if name.is_a? Symbol
  #                expand_log_file name
  #              else
  #                name
  #              end
  #     Logger.new logger
  #   end
end

# Simple methods in Rails console to get names of tables, columns(given a table), and models

# Automating the creating of contexts in rails console
def set_context
  require 'factory_bot_rails'
  require './test/contexts'
  include Contexts
  puts 'Contexts enabled'
  if Contexts.respond_to?(:create_all)
    create_all
    puts 'Contexts built'
  end
end

### IRb HELPER METHODS

# clear the screen
def clear
  system('clear')
end
alias cl clear

# ruby documentation right on the console
# ie. ri Array#each
def ri(*names)
  system(%(ri #{names.map(&:to_s).join(' ')}))
end

### CORE EXTENSIONS
class Object
  # methods defined in the parent class of the object
  def local_methods(obj = self)
    (obj.methods - obj.class.superclass.instance_methods).sort
  end

  def pm
    local_methods.each do |item|
      print "#{ANSI[:GREEN]}#{item}#{ANSI[:RESET]}\n"
    end
    nil
  end

  # print documentation
  #
  #   ri 'Array#pop'
  #   Array.ri
  #   Array.ri :pop
  #   arr.ri :pop
  def ri(method = nil)
    unless method && method =~ /^[A-Z]/ # if class isn't specified
      klass = is_a?(Class) ? name : self.class.name
      method = [klass, method].compact.join('#')
    end
    system 'ri', method.to_s
  end
end

class Class
  public :include

  def class_methods
    (methods - Class.instance_methods - Object.methods).sort
  end

  # Returns an array of methods defined in the class, class methods and instance methods
  def defined_methods
    methods = {}

    methods[:instance] = new.local_methods
    methods[:class] = class_methods

    methods
  end
end

### USEFUL ALIASES
alias q exit
