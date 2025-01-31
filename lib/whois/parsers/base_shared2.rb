#--
# Ruby Whois
#
# An intelligent pure Ruby WHOIS client and parser.
#
# Copyright (c) 2009-2018 Simone Carletti <weppos@weppos.net>
#++


require_relative 'base'
require 'whois/scanners/base_shared2'


module Whois
  class Parsers

    # Shared parser 2.
    #
    # @abstract
    class BaseShared2 < Base
      include Scanners::Scannable

      self.scanner = Scanners::BaseShared2


      # Actually the :disclaimer is supported,
      # but extracting it with the current scanner
      # would require too much effort.
      # property_supported :disclaimer


      property_supported :domain do
        node("Domain Name", &:downcase)
      end

      property_supported :domain_id do
        node("Domain ID")
      end


      property_supported :status do
        node("Domain Status") { |value| Array.wrap(value) }
      end

      property_supported :available? do
        !!node("status:available")
      end

      property_supported :registered? do
        !available?
      end


      property_supported :created_on do
        node("Domain Registration Date") { |value| parse_time(value) }
      end

      property_supported :updated_on do
        node("Domain Last Updated Date") { |value| parse_time(value) }
      end

      property_supported :expires_on do
        node("Domain Expiration Date") { |value| parse_time(value) }
      end


      property_supported :registrar do
        node("Registrar") do |str|
          Parser::Registrar.new(
            :id           => node("Registrar IANA ID"),
            :name         => node("Registrar")
          )
        end
      end


      property_supported :registrant_contacts do
        build_contact("Registrant", Parser::Contact::TYPE_REGISTRANT)
      end

      property_supported :admin_contacts do
        build_contact("Administrative Contact", Parser::Contact::TYPE_ADMINISTRATIVE)
      end

      property_supported :technical_contacts do
        build_contact("Technical Contact", Parser::Contact::TYPE_TECHNICAL)
      end


      property_supported :nameservers do
        Array.wrap(node("Name Server")).map do |name|
          Parser::Nameserver.new(:name => name.downcase)
        end
      end


      private

      def build_contact(element, type)
        node("#{element} ID") do |str|
          address = (1..3).
              map { |i| node("#{element} Address#{i}") }.
              delete_if(&:nil?).
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
            :country      => node("#{element} Country"),
            :country_code => node("#{element} Country Code"),
            :phone        => node("#{element} Phone Number"),
            :fax          => node("#{element} Facsimile Number"),
            :email        => node("#{element} Email")
          )
        end
      end

    end

  end
end
