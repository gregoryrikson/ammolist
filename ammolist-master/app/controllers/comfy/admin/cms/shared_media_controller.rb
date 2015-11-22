class Comfy::Admin::Cms::SharedMediaController < Comfy::Admin::Cms::BaseController

  before_action :build_cms_shared_media,    :only => [:new, :create]
  before_action :load_cms_shared_media,     :only => [:edit, :update, :destroy]
  before_action :authorize
  
  def index
    return redirect_to :action => :new if @site.shared_media.count == 0
    @shared_media = @site.shared_media
  end

  def new
    render
  end

  def edit
    render
  end

  def update
    @shared_media.save!
    flash[:success] = I18n.t('comfy.admin.cms.shared_media.updated')
    redirect_to :action => :edit, :id => @shared_media
  rescue ActiveRecord::RecordInvalids
    flash.now[:danger] = I18n.t('comfy.admin.cms.shared_media.update_failure')
    render :action => :edit
  end

protected

  def build_cms_shared_media
    @shared_media = @site.shared_media.new(shared_media_params)
  end

  def load_cms_shared_media
    @shared_media = @site.shared_media.find(params[:id])
    @shared_media.attributes = shared_media_params
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = I18n.t('comfy.admin.cms.shared_media.not_found')
    redirect_to :action => :index
  end

  def shared_media_params
    params.fetch(:shared_media, {}).permit!
  end
end
