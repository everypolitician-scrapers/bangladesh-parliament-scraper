# frozen_string_literal: true

require 'scraped'

class MemberRow < Scraped::HTML
  field :id do
    return seatid unless photograph
    File.basename(photograph, '.jpg').gsub('%20', '') rescue binding.pry
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

  field :photograph do
    tds[3].css('img[src^="http"]/@src').text.split(/http:\/+/).last&.prepend('http://')
  end

  field :party do
    tds[4].text.tidy
  end

  field :term do
    noko.xpath('preceding::h2').first.text.tidy[/(\d+)/, 1].to_i
  end

  field :source do
    url.to_s.split(/http:\/+/).last.prepend('http://')
  end

  def vacant?
    name.downcase.include?('vacant') || party.downcase.include?('vacant')
  end

  private

  def tds
    noko.xpath('td')
  end
end
