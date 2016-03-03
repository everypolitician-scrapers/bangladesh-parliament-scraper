#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'date'
require 'open-uri'
require 'pry'
require 'resolv-replace'

# require 'open-uri/cached'

class String
  def tidy
    self.gsub(/[[:space:]]+/, ' ').strip
  end
end

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_term(url)
  page = noko_for(url)
  added = 0

  page.xpath('//table//tr').drop(1).each do |tr|
    tds = tr.xpath('td')
    next if tds[1].text.tidy.downcase == 'vacant'
    data = { 
      seatid: tds[0].text.gsub(/[[:space:]]/, ' ').strip,
      id: tds[3].xpath('.//img/@src').text.split('/').last.split('.').first,
      name: tds[1].text.gsub(/[[:space:]]/, ' ').strip,
      constituency: tds[2].text.gsub(/[[:space:]]/, ' ').strip.split('-').first,
      website: tds[3].xpath('a/@href').text,
      photograph: tds[3].xpath('a/img/@src').text,
      party: tds[4].text.gsub(/[[:space:]]/, ' ').strip,
      term: 10,
      source: url.to_s,
    } 
    data[:photograph] = URI.join(url, URI.escape(data[:photograph])).to_s unless data[:photograph].to_s.empty?
    data[:website] = URI.join(url, URI.escape(data[:website])).to_s unless data[:website].to_s.empty?
    added += 1
    ScraperWiki.save_sqlite([:seatid, :name], data)
  end
  warn "Added #{added} members"
end

scrape_term 'http://www.parliament.gov.bd/index.php/en/mps/members-of-parliament/current-mp-s/list-of-10th-parliament-members-english'
