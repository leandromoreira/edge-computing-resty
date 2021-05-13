class Rendition < ApplicationRecord
  belongs_to :video

  validates :path, presence: true
  validates :video, presence: true
end
