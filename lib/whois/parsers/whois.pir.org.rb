#--
# Ruby Whois
#
# An intelligent pure Ruby WHOIS client and parser.
#
# Copyright (c) 2009-2018 Simone Carletti <weppos@weppos.net>
#++


require_relative 'base_afilias'
require 'whois/scanners/whois.pir.org.rb'

module Whois
  class Parsers

    # Parser for the whois.pir.org server.
    class WhoisPirOrg < BaseAfilias

      self.scanner = Scanners::WhoisPirOrg

      # Checks whether the response has been throttled.
      #
      # @return [Boolean]
      #
      # @example
      #   WHOIS LIMIT EXCEEDED - SEE WWW.PIR.ORG/WHOIS FOR DETAILS
      #
      def response_throttled?
        !!node("response:throttled")
      end

      property_supported :status do
        Array.wrap(node("Domain Status"))
      end

      property_supported :registrar do
        node('Registrar') do |name|
          Parser::Registrar.new(
              id:           node('Registrar IANA ID'),
              name:         node('Registrar')
          )
        end
      end

      property_supported :created_on do
        node("Creation Date") do |value|
          parse_time(value)
        end
      end

      property_supported :updated_on do
        node("Updated Date") do |value|
          parse_time(value)
        end
      end

      property_supported :expires_on do
        node("Registry Expiry Date") do |value|
          parse_time(value)
        end
      end

      def build_contact(element, type)
        node("#{element} ID") do
          address = [node("#{element} Street")]
          address = (address + (1..3).map { |i| node("#{element} Street#{i}") }).
            delete_if { |i| i.nil? || i.empty? }.
            join("\n")

          Parser::Contact.new(
              :type         => type,
              :id           => node("#{element} ID"),
              :name         => node("#{element} Name"),
              :organization => node("#{element} Organization"),
              :address      => address,
              :city         => node("#{element} City"),
              :zip          => node("#{element} Postal Code"),
              :state        => node("#{element} State/Province"),
              :country_code => node("#{element} Country"),
              :phone        => node("#{element} Phone"),
              :fax          => node("#{element} Fax"),
              :email        => node("#{element} Email")
          )
        end
      end

    end

  end
end
