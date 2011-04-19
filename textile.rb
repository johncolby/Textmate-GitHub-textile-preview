#!/usr/bin/env ruby
begin 
  require 'rubygems'
  require 'redcloth'
rescue LoadError
  require ENV['TM_BUNDLE_SUPPORT'] + '/lib/redcloth'
end

require "#{ENV['TM_SUPPORT_PATH']}/lib/tm/htmloutput"

##########
module RedClothGithubExtension
  
  CODE_RE = /```([^\n]*)\n([^`]+)\n```/m
  LINK_RE = /([@_]{0,2})  # Opening formatting
            (\[\[)        # Start link
            ([^\|\]]+)    # Link text
            (\|?)         # Optional pipe
            ([^\|\]]*)    # Optional link address
            (\]\])        # End link
            ([@_]{0,2})/x # Closing formatting
  
  def refs_github(text)
     # Custom code blocks
    text.gsub!(CODE_RE) do |m|
      code_str = $2
      "<pre><code>#{ code_str }</code></pre>"
    end
    
    # Wiki links
    text.gsub!(LINK_RE) do |m|
      form_str = $1
      text_str = $3
      link_str = $5
      if link_str == ''
        link_str = text_str.gsub(/ /, '-')
      end
      "\"#{form_str}#{text_str}#{form_str.reverse}\":#{link_str}.textile"
    end
  end
end

RedCloth.send(:include, RedClothGithubExtension)
##########

contents = []
$stdin.each_line { |line| contents << line }

output = RedCloth.new(contents.join()).to_html(:textile, :refs_github)

TextMate::HTMLOutput.show(:title => "Textile Preview", :sub_title => ENV['TM_FILENAME']) do |io|
  io << output
 end

