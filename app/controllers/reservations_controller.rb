class ReservationsController < ApplicationController
    before_action :authenticate_user!


    def new
        @listing = Listing.find(params[:listing_id])
        @user = current_user

        @start_date =  params[:reservation][:start_date]
        @end_date =  params[:reservation][:end_date]
        @price_pernight =  params[:reservation][:price_pernight]
        @total_price =  params[:reservation][:price_pernight]
      end

    def index
    @reservations = current_user.reservations
  end

	def reserved
	    @listings = current_user.listings
	  end

    def create
        @listing = Listing.find(params[:listing_id])

        #他人の部屋の予約作成とStripeのpayアクションの実行
      # Find the user to pay.
      user = @listing.user

      # Charge 
      amount = params[:reservation][:price_pernight]

      #fee
      fee = (amount.to_i * 0.164).to_i

      # Calculate the fee amount that goes to the application.
      begin
        charge_attrs = {
          amount: amount,
          currency: user.currency,
          source: params[:token],
          application_fee: fee
        }

      # Use the platform's access token, and specify the
      # connected account's user id as the destination so that
      # the charge is transferred to their account.
      charge_attrs[:destination] = user.stripe_user_id
      charge = Stripe::Charge.create( charge_attrs )

        #have to edit view template to show html in flash
        flash[:notice] = "Charged successfully!"

      rescue Stripe::CardError => e
        error = e.json_body[:error][:message]
        flash[:error] = "Charge failed! #{error}"
      end

        @reservation = current_user.reservations.create(reservation_params)  

        redirect_to @reservation.listing, notice: "予約が完了しました。" 
    end


    private
        def reservation_params
            params.require(:reservation).permit(:start_date, :end_date, :price_pernight, :total_price, :listing_id)
        end
end
