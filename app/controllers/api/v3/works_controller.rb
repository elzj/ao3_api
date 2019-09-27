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

  protected

  def query_params
    params.require(:query).permit(
      Search::Works::Form.permitted_params
    ).merge(current_user: current_user)
  end
end
