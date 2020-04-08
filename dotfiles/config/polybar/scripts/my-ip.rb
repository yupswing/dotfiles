#!/usr/bin/env ruby

# frozen_string_literal: true

require 'json'
require 'net/http'

class IpInfo
  #############################################################################
  ### Public attributes                                                     ###
  #############################################################################
  attr_reader :info
  attr_reader :ip_data
  attr_reader :label
  attr_reader :update_in_progress
  attr_reader :uri
  attr_reader :error_color
  attr_reader :warning_color

  #############################################################################
  ### Public methods                                                        ###
  #############################################################################

  def initialize(opts = {})
    @info = opts[:info] == true
    @ip_data = nil
    @label = opts[:label] || ''
    @update_in_progress = false
    @uri = URI (opts[:uri] || 'https://ifconfig.co/json').to_s
    @error_color = opts[:error_color] || '#FF0000'
    @warning_color = opts[:warning_color] || '#FFB52A'
  end

  # Updates the IP info and shows it:
  def update
    # Do nothing if there's an update in progress:
    return if @update_in_progress

    # Temporary message for the user:
    puts "%{F#{@warning_color}}%{F-}"
    STDOUT.flush

    # Prevent concurrent update requests:
    @update_in_progress = true

    # Let's be extra sure:
    begin
      # Perform the request:
      @ip_data = JSON.parse(Net::HTTP.get(@uri))
                     .slice('ip', 'country', 'city')
                     .map { |k, v| [k.to_sym, v] }
                     .to_h

    # If something goes wrong:
    rescue StandardError => e
      @ip_data = nil
    end

    # Update the shown data:
    show

    # Allow new update requests:
    @update_in_progress = false
  end

  # Prints out the current IP info:
  def show
    # Just a red dot if we are not connected:
    if @ip_data.nil?
      puts "%{F#{@error_color}}#{@label}%{F-}"

    # IP info:
    else
      # If no info has to be shown, just put in a green dot if we are
      # connected:
      if @info
        # Always add the current ip:
        to_print = "#{@label} #{@ip_data[:ip]}"

        if @ip_data[:country]
          to_print += " (#{@ip_data[:country]}"
          to_print += ", #{@ip_data[:city]}" if @ip_data[:city]
          to_print += ')'
        end

        puts to_print
      else
        puts @label.to_s
      end
    end

    # Always flush at the end:
    STDOUT.flush
  end

  # Show/hide connection info:
  def toggle_ip_info
    @info = !@info
    show
  end
end

# If this has been launched as a standalone:
if $PROGRAM_NAME == __FILE__
  # Instance the class:
  ip_info = IpInfo.new uri: 'https://ifconfig.co/json',
                       label: ARGV[1],
                       error_color: ARGV[2],
                       warning_color: ARGV[3],
                       info: false

  # Update info on USR1 signal:
  Signal.trap 'USR1' do
    # Update the info:
    ip_info.update
  end

  Signal.trap 'USR2' do
    ip_info.toggle_ip_info
  end

  # Update shown info every x seconds (30 by default):
  loop do
    ip_info.update
    sleep (ARGV[0] || '30').to_s.to_i
  end
end
