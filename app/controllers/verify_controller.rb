class VerifyController < ApplicationController
  include IdvSession

  before_action :confirm_two_factor_authenticated
  before_action :require_no_active_profile, only: [:cancel, :fail, :retry]

  def index
    if active_profile?
      redirect_to verify_activated_path
    else
      analytics.track_event(Analytics::IDV_INTRO_VISIT)
    end
  end

  def retry
    flash.now[:error] = I18n.t('idv.errors.fail')
  end

  def activated
    redirect_to verify_url unless active_profile?
  end

  def fail
    redirect_to verify_url unless idv_attempter.exceeded?
  end

  private

  def require_no_active_profile
    redirect_to profile_url if active_profile?
  end

  def active_profile?
    current_user.active_profile.present?
  end
end
