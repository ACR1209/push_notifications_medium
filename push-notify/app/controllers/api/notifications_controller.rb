module Api
    class NotificationsController < ApplicationController
      skip_before_action :verify_authenticity_token 
  
      def create
        user = User.find(params[:user_id])
        if user && user.tokens.count > 0
          fcm_service = FcmService.new
          user.tokens.each do |token|
            pp fcm_service.send_notification(token.token, params[:title], params[:body])
          end
          render json: { status: 'Notifications sent'}, status: :ok
        else
          render json: { error: 'User not found or token not set' }, status: :not_found
        end
      end

      def set_token
        user = User.find(params[:user_id])

        if user
          Token.create!(user: user, token: params[:token])
          render json: { status: 'Token saved' }, status: :ok
        else
          render json: { error: 'User not found' }, status: :not_found
        end
      end
    end
  end