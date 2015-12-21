module Blorgh
  class Article < ActiveRecord::Base
    has_many :comments, dependent: :destroy
  end
end
