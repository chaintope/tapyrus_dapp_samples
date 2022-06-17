class Timestamp::Form
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :prefix, :string
  attribute :content, :string

  validates :content, presence: true

  def initialize(params = {})
    super(params)
  end
end