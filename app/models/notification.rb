class Notification < ApplicationRecord
  belongs_to :user
  scope :unread, -> { where(read: false) }
  has_many :notifications, dependent: :destroy

end
