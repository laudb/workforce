class Admin::RequestsController < Admin::ApplicationController
  before_action :set_request, only: [:edit, :show, :destroy, :assign]	
  before_action :set_client, except: [:assign, :index, :show]

  def index
    @all_requests = Request.all
  	@requests = Request.all.where(resolved: false)
    @resolved_requests= Request.all.where(resolved: true)
    @requests_without_client = Request.all.where(client_id: nil)
  end

  def show
    @workers = Worker.all
  end

  def new
    @request = @client.requests.build
  end

  def create 
    @request = @client.requests.build(request_params)

    if @request.save
      flash[:notice] = "Request has been created."
      redirect_to [:admin, @client, @request]
    else
      flash.now[:alert] = "Request has not been created."
      render 'new'
    end
  end


  def edit
  end

  def update
    if @request.update(request_params)
      flash[:notice] = "Your request has been updated!"
      redirect_to @request
    else
      flash.now[:alert] = "An update of your request failed!"
      render 'edit'
    end
  end 

  def assign
    @worker = Worker.find(params[:worker_id])

    @request.workers << @worker
    @request.resolve 

    @client = @request.client
    NotifyClientJob.set(wait: 2.seconds).perform_later(@client)
    flash[:alert] = "You just assigned #{@worker.first_name} to #{@request.id}."

    redirect_to admin_root_path
  end

  # def unassign
  #   @worker = Worker.find(params[:id])

  #   @request.workers.delete(@worker)
  #   @request.unresolve
  #   redirect_to admin_root_path
  # end


  def destroy
    @request.destroy
    redirect_to admin_root_path
  end

  
  private

  def set_request
  	@request = Request.find(params[:id]) 
  # rescue ActiveRecord::RecordNotFound
  #   # flash[:alert] = "can find the resource you are looking for!"
  #    redirect_to errors_not_found_path
  end

  def set_client
    @client = Client.find(params[:client_id])
  # rescue ActiveRecord::RecordNotFound
  #   redirect_to errors_not_found_path
  end

 def request_params
    params.require(:request).permit(:days, {:weekdays=>[]}, {:extra_services=>[]}, :date_time, :frequency, :bathrooms, :bedrooms, :hall, :kitchens, :provide)
 end

end
