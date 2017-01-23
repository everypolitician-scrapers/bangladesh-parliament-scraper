#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

# require 'open-uri/cached'
# OpenURI::Cache.cache_path = '.cache'
require 'scraped_page_archive/open-uri'

class MembersPage < Scraped::HTML
  decorator Scraped::Response::Decorator::AbsoluteUrls

  field :members do
    noko.xpath('//table//tr').drop(1).map do |tr|
      fragment tr => MemberRow
    end
  end
end

class MemberRow < Scraped::HTML
  field :id do
    File.basename(photograph, '.jpg')
  end

  field :seatid do
    tds[0].text.tidy
  end

  field :name do
    tds[1].text.tidy
  end

  field :constituency do
    tds[2].text.tidy.split('-').first
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
    name.downcase.include?('vacant') || constituency.downcase.include?('vacant')
  end

  private

  def tds
    noko.xpath('td')
  end
end

start = 'http://www.parliament.gov.bd/index.php/en/mps/members-of-parliament/current-mp-s/list-of-10th-parliament-members-english'
data = MembersPage.new(response: Scraped::Request.new(url: start).response).members.reject(&:vacant?).map(&:to_h)
# data.each { |r| puts r.reject { |k, v| v.to_s.empty? }.sort_by { |k, v| k }.to_h }

ScraperWiki.sqliteexecute('DELETE FROM data') rescue nil
ScraperWiki.save_sqlite(%i(seatid name), data)
warn "Added #{data.count} members"
