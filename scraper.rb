#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'nokogiri'
require 'pry'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'
# require 'scraped_page_archive/open-uri'

class String
  def tidy
    gsub(/[[:space:]]+/, ' ').strip
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
    next if %w(vacant -vacant- ---).include?(tds[1].text.tidy.downcase)
    data = {
      seatid:       tds[0].text.tidy,
      name:         tds[1].text.tidy,
      constituency: tds[2].text.tidy.split('-').first,
      website:      tds[3].xpath('a/@href').text,
      photograph:   tds[3].xpath('a/img/@src').text,
      party:        tds[4].text.tidy,
      term:         10,
      source:       url.to_s,
    }
    data[:id] = tds[3].xpath('.//img/@src').text.split('/').last.split('.').first rescue ''
    data[:photograph] = URI.join(url, URI.escape(data[:photograph])).to_s unless data[:photograph].to_s.empty?
    data[:website] = URI.join(url, URI.escape(data[:website])).to_s unless data[:website].to_s.empty?
    added += 1
    # puts data
    ScraperWiki.save_sqlite(%i(seatid name), data)
  end
  warn "Added #{added} members"
end

scrape_term 'http://www.parliament.gov.bd/index.php/en/mps/members-of-parliament/current-mp-s/list-of-10th-parliament-members-english'
