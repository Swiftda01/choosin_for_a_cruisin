class Stop < ApplicationRecord
  belongs_to :cruise
  belongs_to :port
end
