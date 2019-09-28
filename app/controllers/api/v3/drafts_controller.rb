# frozen_string_literal: true

module Api
  module V3
    # JSON API for drafts
    class DraftsController < Api::V3::BaseController
      before_action :authenticate_user!

      def index
        @drafts = Draft.for_user(current_user).map(&:as_json)
        render json: @drafts.to_json
      end

      def show
        @draft = Draft.for_user(current_user).find(params[:id])
        render json: @draft.as_json.to_json
      end

      def create
        @draft = Draft.new(draft_params)
        if @draft.save
          msg = { id: @draft.id }
          status = :created
        else
          msg = { errors: @draft.errors.full_messages }
          status = :unprocessable_entity
        end
        render json: msg, status: status
      end

      protected

      def draft_params
        params.require(:draft).permit(
          *Draft::FIELDS + [{
            chapters: [
              :content, :title, :notes, :endnotes, :summary, :position
            ]
          }]
        ).merge(user_id: current_user&.id)
      end
    end
  end
end
