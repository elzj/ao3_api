class Api::V3::TagsController < Api::V3::BaseController
  respond_to :json

  def index
    tags = TagSearch.new(query_params).results
    respond_with tags.to_json
  end

  def show
    @tag = Tag.find params[:id]
    respond_with @tag.as_json
  end

  protected

  def query_params
    params.require(:query).permit(:name, :canonical, :tag_type)
  end

end
