class Token::TransferForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :token_id, :string
  attribute :address, :string
  attribute :amount, :integer

  validates :token_id, presence: true
  validates :address, presence: true
  validates :amount, presence: true

  validate :amount_positive_integer?, if: -> { amount.present? }

  def initialize(params = {})
    super(params)
  end

  private

  def amount_positive_integer?
    unless amount > 0
      errors.add(:amount, 'must be positive integer')
    end
  end
end