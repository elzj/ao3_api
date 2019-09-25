# frozen_string_literal: true

class Api::V3::PseudsController < Api::V3::BaseController
  respond_to :json

  def index
    @pseuds = Search::Pseuds::Form.new(query_params).search_results
    respond_with @pseuds.to_json
  end

  def show
    @pseud = Search::Pseuds::Document.new(
      Pseud.find(params[:id])
    )
    respond_with @pseud.to_json
  end

  protected

  def query_params
    params.require(:query).permit(:query, :name, :fandom, :collection_ids)
  end
end
