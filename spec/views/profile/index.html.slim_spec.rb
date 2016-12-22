require 'rails_helper'

describe 'profile/index.html.slim' do
  context 'user is not TOTP enabled' do
    before do
      user = build_stubbed(:user, :signed_up)
      allow(view).to receive(:current_user).and_return(user)
    end

    it 'has a localized title' do
      expect(view).to receive(:title).with(t('titles.profile'))

      render
    end

    it 'contains link to enable TOTP' do
      render

      expect(rendered).to have_link('Enable', href: authenticator_start_url)
      expect(rendered).not_to have_xpath("//input[@value='Disable']")
    end

    xit 'contains link to delete account' do
      pending 'temporarily disabled until we figure out the MBUN to SSN mapping'
      render

      expect(rendered).to have_content t('headings.delete_account', app: APP_NAME)
      expect(rendered).
        to have_xpath("//input[@value='#{t('forms.buttons.delete_account')}']")
    end
  end

  context 'when user is TOTP enabled' do
    it 'contains link to disable TOTP' do
      user = build_stubbed(:user, :signed_up, otp_secret_key: '123')
      allow(view).to receive(:current_user).and_return(user)

      render

      expect(rendered).to have_xpath("//input[@value='Disable']")
      expect(rendered).not_to have_link('Enable', href: authenticator_start_path)
    end
  end

  it 'contains a recovery code section' do
    user = User.new
    allow(view).to receive(:current_user).and_return(user)

    render

    expect(rendered).to have_content t('profile.items.recovery_code')
    expect(rendered).
      to have_link(t('profile.links.regenerate_recovery_code'), href: manage_recovery_code_path)
  end

  it 'contains account history' do
    user = User.new
    allow(view).to receive(:current_user).and_return(user)

    render

    expect(rendered).to have_content t('headings.profile.account_history')
  end

  context 'account status badges' do
    before { allow(view).to receive(:current_user).and_return(profile.user) }

    context 'LOA1 account' do
      let(:profile) { build(:profile) }

      it 'shows a "Basic Account" badge with a tooltip' do
        render

        expect(rendered).to have_content(t('headings.profile.basic_account'))
        expect(rendered).to have_css("[aria-label='#{t('tooltips.verified_account')}']")
      end
    end

    context 'LOA3 account' do
      let(:pii_attrs) { { ssn: '1111', dob: '1920-01-01' } }
      let(:profile) { create(:profile, :active, :verified, pii: pii_attrs) }

      it 'shows a "Verified Account" badge with no tooltip' do
        assign(:decrypted_pii, Pii::Attributes.new_from_hash(pii_attrs))

        render
        expect(rendered).to have_content(t('headings.profile.verified_account'))
      end
    end
  end
end
