Rails.application.routes.draw do

  resources :productlist
  get '/' => 'productlist#index'
  
  #resources :Productlist で以下のルートが生成されている
  # GET  /Productlist(.:format)	=> Productlist#index
  # POST /Productlist(.:format)	=> Productlist#create
  #	GET  /Productlist/new(.:format)	=> Productlist#new
  #	GET  /Productlist/:id/edit(.:format) => Productlist#edit
  #	GET  /Productlist/:id(.:format)	=> Productlist#show
  # PATCH /Productlist/:id(.:format) => Productlist#update
  # PUT  /Productlist/:id(.:format)	=> Productlist#update
  # DELETE /Productlist/:id(.:format)	=> Productlist#destroy
  # GET / => Productlist#index

end
