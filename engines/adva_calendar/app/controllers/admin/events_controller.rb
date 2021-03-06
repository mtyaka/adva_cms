class Admin::EventsController < Admin::BaseController
  layout "admin"
  helper :assets, :roles

  before_filter :set_section
  before_filter :set_event, :only => [:show, :edit, :update, :destroy]
  before_filter :set_categories, :only => [:new, :edit]

  before_filter :params_draft, :only => [:create, :update]
  before_filter :params_published_at, :only => [:create, :update]
  before_filter :params_dates, :only => [:create, :update]
  before_filter :params_location, :only => [:create, :update]
  before_filter :params_category_ids, :only => [:update]

  widget :sub_nav, :partial => 'widgets/admin/sub_nav',
                   :only  => { :controller => ['admin/events'] }

  guards_permissions :calendar_event

  def index
    source = @section.events
    if %w(title body).include?(params[:filter])
      @events = source.search(params[:query], params[:filter]).paginate({:page => params[:page]})
    elsif params[:filter] == 'tags' and not params[:query].blank?
      @events = source.paginate_tagged_with(params[:query], :page => params[:page])
    else
      if params[:category]
        @events = source.by_categories(params[:category].to_i).paginate(:page => params[:page])
      else
        @events ||= source.paginate(:page => params[:page])
      end
    end
  end
  
  def new
    @event = @calendar.events.build(:title => t(:'adva.calendar.titles.new_event'), :startdate => Time.now)
  end
  
  def create
    @event = @calendar.events.new(params[:calendar_event])
    if @location.save and @event.save
      trigger_events @event
      flash[:notice] = "The event has been successfully created."
      redirect_to edit_admin_calendar_event_path(@site.id, @section.id, @event.id)
    else
      set_categories
      flash[:error] = "The event could not been created."
      render :action => 'new' and return
    end
  end
  
  def edit
  end
  
  def update
    @event.attributes = params[:calendar_event]
    @event.all_day = params[:calendar_event][:all_day]
    if @location.save and @event.save
      trigger_events @event
      flash[:notice] = "The event has been successfully updated."
      redirect_to edit_admin_calendar_event_path(@site.id, @section.id, @event.id)
    else
      flash[:error] = "The event could not been updated."
      render :action => 'edit'
    end
  end

  def destroy
    if @event.destroy
      trigger_events @event
      flash[:notice] = "The event has been deleted."
      redirect_to admin_calendar_events_path
    else
      flash[:error] = "The event could not be deleted."
      render :action => 'show'
    end
  end

  private
    def set_section
      @calendar = @section = Calendar.find(params[:section_id], :conditions => {:site_id => @site.id})
    end

    def set_event
      @event = @calendar.events.find params[:id]
    end

    def set_categories
      @categories = @calendar.categories.roots
    end

    def params_category_ids
      default_calendar_event_param :category_ids, []
    end

    def params_draft
      set_calendar_event_param :published_at, nil if save_draft?
    end

    def params_published_at
      date = Time.extract_from_attributes!(params[:calendar_event], :published_at, :local)
      set_calendar_event_param :published_at, date if date && !save_draft?
    end

    def params_dates
      set_calendar_event_param :startdate, Time.zone.local(params[:calendar_event][:startdate]) unless params[:calendar_event][:startdate].blank?
      set_calendar_event_param :enddate, Time.zone.local(params[:calendar_event][:enddate]) unless params[:calendar_event][:enddate].blank?
    end

    # will check if existing location is selected, otherwise try to create a new one 
    def params_location
      unless params[:calendar_event][:location_id].blank?
        @location = @site.locations.find(params[:calendar_event][:location_id])
      else
        @location = @site.locations.new(params[:location])
      end
      set_calendar_event_param(:location_id, @location.save ? @location.id : nil)
    end

    def save_draft?
      params[:draft] == '1'
    end

    def set_calendar_event_param(key, value)
      params[:calendar_event] ||= {}
      params[:calendar_event][key] = value
    end

    def default_calendar_event_param(key, value)
      params[:calendar_event] ||= {}
      params[:calendar_event][key] ||= value
    end
end

