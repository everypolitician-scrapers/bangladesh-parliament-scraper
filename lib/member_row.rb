# frozen_string_literal: true

require 'scraped'

class MemberRow < Scraped::HTML
  field :id do
    File.basename(photograph, '.jpg').gsub('%20', '')
  end

  field :seatid do
    tds[0].text.tidy
  end

  field :name do
    tds[1].text.tidy
  end

  field :constituency do
    tds[2].text.tidy
  end

  field :website do
    tds[3].xpath('a/@href').text
  end

  field :photograph do
    tds[3].xpath('a/img/@src').text
  end

  field :party do
    tds[4].text.tidy
  end

  field :term do
    10
  end

  field :source do
    url.to_s
  end

  def vacant?
    name.downcase.include?('vacant') || party.downcase.include?('vacant')
  end

  private

  def tds
    noko.xpath('td')
  end
end
