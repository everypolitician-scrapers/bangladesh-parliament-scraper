#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'require_all'
require 'scraped'
require 'scraperwiki'

require_rel 'lib'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

url_9 = 'http://web.archive.org/web/20150905124754/http://www.parliament.gov.bd/index.php/en/mps/members-of-parliament/former-mp-s/list-of-9th-parliament-members-english'
data_9 = MembersPage.new(response: Scraped::Request.new(url: url_9).response).members.reject(&:vacant?).map(&:to_h)

url_10 = 'http://www.parliament.gov.bd/index.php/en/mps/members-of-parliament/former-mp-s/list-of-10th-parliament-members-english'
data_10 = MembersPage.new(response: Scraped::Request.new(url: url_10).response).members.reject(&:vacant?).map(&:to_h)

data = data_9 + data_10
data.each { |r| puts r.reject { |k, v| v.to_s.empty? }.sort_by { |k, v| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
ScraperWiki.save_sqlite(%i[term seatid name], data)
