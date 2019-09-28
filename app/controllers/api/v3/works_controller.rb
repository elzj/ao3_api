# frozen_string_literal: true

class Api::V3::WorksController < Api::V3::BaseController
  respond_to :json

  def index
    @works = Search::Works::Form.new(query_params).search_results
    respond_with @works.to_json
  end

  def show
    @work = Search::Works::Document.new(
      Work.find(params[:id])
    )
    respond_with @work.to_json
  end

  def create
    work = WorkPosting.build(work_params).post!
    if work
      render json: { id: work.id }, status: :created
    else
      render json: { errors: work.errors }, status: :unprocessable_entity
    end
  end

  protected

  def query_params
    params.require(:query).permit(
      Search::Works::Form.permitted_params
    ).merge(current_user: current_user)
  end

  def work_params
    params.require(:work).permit(
      *Draft::FIELDS + [{
        chapters: [
          :content, :title, :notes, :endnotes, :summary, :position
        ]
      }]
    ).merge(user_id: current_user&.id)
  end
end
