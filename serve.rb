#!/usr/bin/env ruby
# Temporary workaround for SSL certificate verification issues with Ruby 3.4.1
# This should only be used for local development

require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

# Load Jekyll
load Gem.bin_path('jekyll', 'jekyll')
