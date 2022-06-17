class Token::Form
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :amount, :integer
  attribute :token_type, :integer
  attribute :split, :integer

  validates :amount, presence: true
  validates :token_type, presence: true
  validates :split, presence: true

  validate :amount_positive_integer?
  validate :split_allowed?

  TOKEN_TYPE_JP = [["再発行可能トークン", 1], ["再発行不可トークン", 2], ["NFT", 3]]

  def initialize(params = {})
    super(params)
  end

  private

  def amount_positive_integer?
    amount > 0
  end

  def split_allowed?
    split.between?(1, 100)
  end
end