#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'date'
require 'open-uri'

# require 'open-uri/cached'
# require 'colorize'
# require 'pry'
# require 'csv'

def noko(url)
  Nokogiri::HTML(open(url).read) 
end

@BASE = 'http://www.parliament.gov.bd'
@PREF = '/index.php/en/mps/members-of-parliament/'
@terms = {
  '10' => "current-mp-s/list-of-10th-parliament-members-english",
  '9' => "former-mp-s/list-of-9th-parliament-members-english",
}

@terms.each do |term, pagename|
  url = @BASE + @PREF + pagename
  page = noko(url)
  added = 0

  page.xpath('//table//tr').drop(1).each do |tr|
    tds = tr.xpath('td')
    next if tds[1].text.strip == 'Vacant'
    data = { 
      localid: tds[0].text.gsub(/[[:space:]]/, ' ').strip,
      id: tds[3].xpath('.//img/@src').text.split('/').last.split('.').first,
      name: tds[1].text.gsub(/[[:space:]]/, ' ').strip,
      constituency: tds[2].text.gsub(/[[:space:]]/, ' ').strip.split('-').first,
      website: tds[3].xpath('a/@href').text,
      photograph: tds[3].xpath('a/img/@src').text,
      party: tds[4].text.gsub(/[[:space:]]/, ' ').strip,
      source: url,
      term: term,
    }
    data[:photograph] = URI.join(url, URI.escape(data[:photograph])).to_s unless data[:photograph].to_s.empty?
    data[:website] = URI.join(url, URI.escape(data[:website])).to_s unless data[:website].to_s.empty?
    added += 1
    ScraperWiki.save_sqlite([:name, :term], data)
  end
  warn "Added #{added} members of Parliament #{term}"
end

