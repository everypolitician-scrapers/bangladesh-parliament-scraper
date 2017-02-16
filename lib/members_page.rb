# frozen_string_literal: true
require 'scraped'
require_relative 'member_row'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :members do
    noko.xpath('//table//tr').drop(1).map do |tr|
      fragment tr => MemberRow
    end
  end
end
