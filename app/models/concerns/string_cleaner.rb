# frozen_string_literal: true

# Utility methods for cleaning up string values
module StringCleaner
  def remove_articles_from_string(str)
    if str.respond_to?(:gsub)
      str.gsub(article_removing_regex, '')
    else
      str
    end
  end

  def article_removing_regex
    Regexp.new(/^(a|an|the|la|le|les|l'|un|une|des|die|das|il|el|las|los|der|den)\s/i)
  end
end
  
