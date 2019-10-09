# frozen_string_literal: true

class Api::V3::WorksController < Api::V3::BaseController
  before_action :authenticate_user!, only: [:create]

  def index
    @works = WorkSearch.new(query_params).search_results
    render json: @works.to_json
  end

  def show
    @work = WorkSearch.document(
      Work.find(params[:id])
    )
    render json: @work.to_json
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
      WorkSearch.permitted_params
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
