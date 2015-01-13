# encoding: utf-8
class CatarseJuntosGiftCards::JuntosGiftCardsController < ApplicationController

  skip_before_filter :force_http
  
  layout :false

  SCOPE = 'projects.contributions.review.juntos_gift_cards_info'

  def review
  end

  def pay
    contribution = current_user.contributions.with_state(:pending).find params[:id]
    if contribution
      response = HTTParty.put("https://juntosgiftcards.herokuapp.com/gift_cards/#{params[:coupon]}/redeem", headers: {'Authorization' => "Token token=\"#{PaymentEngines.configuration[:juntos_gift_cards_api_key]}\""}, body: { value: contribution.value.to_i })
      case response.code
      when 200, 204, 406
        if Contribution.with_state(:confirmed).where(payment_method: 'JuntosGiftCard', payment_id: params[:coupon]).count == 0
          contribution.update_attribute :payment_method, 'JuntosGiftCard'
          contribution.update_attribute :payment_id, params[:coupon]
          contribution.confirm!
          flash[:notice] = t('success', scope: SCOPE)
          redirect_to main_app.project_contribution_path(project_id: contribution.project.id, id: contribution.id)
        else
          flash[:alert] = t('error_duplicate', scope: SCOPE)
          return redirect_to main_app.new_project_contribution_path(contribution.project)  
        end
      when 404
        flash[:alert] = t('error_coupon', scope: SCOPE)
        return redirect_to main_app.new_project_contribution_path(contribution.project)  
      when 422
        error = JSON.parse(response.body)["error"]
        case error
        when 'wrong_value'
          flash[:alert] = t('error_value', scope: SCOPE)
          return redirect_to main_app.new_project_contribution_path(contribution.project)  
        when 'cant_redeem'
          flash[:alert] = t('error_duplicate', scope: SCOPE)
          return redirect_to main_app.new_project_contribution_path(contribution.project)  
        else
          flash[:alert] = t('error', scope: SCOPE)
          return redirect_to main_app.new_project_contribution_path(contribution.project)  
        end
      else
        flash[:alert] = t('error', scope: SCOPE)
        return redirect_to main_app.new_project_contribution_path(contribution.project)  
      end
    else
      flash[:alert] = t('error', scope: SCOPE)
      return redirect_to main_app.new_project_contribution_path(contribution.project)  
    end
  end

end
