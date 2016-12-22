require 'rails_helper'

describe TwoFactorAuthCode::PhoneDeliveryPresenter do
  let(:presenter) do
    TwoFactorAuthCode::PhoneDeliveryPresenter.new(
      code_value: '123',
      delivery_method: 'sms',
      phone_number: '123-123-1234'
    )
  end

  it 'implements GenericDeliveryPresenter' do
    TwoFactorAuthCode::PhoneDeliveryPresenter.instance_methods(false).each do |m|
      expect(presenter.send(m)).to be
    end
  end
end
