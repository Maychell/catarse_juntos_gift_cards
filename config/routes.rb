CatarseJuntosGiftCards::Engine.routes.draw do
  resources :juntos_gift_cards, only: [], path: 'payment/juntos_gift_cards' do
	  member do
	    get :review
	    post :pay
	  end
	end
end
