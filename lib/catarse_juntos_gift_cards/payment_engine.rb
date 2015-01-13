module CatarseJuntosGiftCards
  class PaymentEngine

    def name
      'JuntosGiftCard'
    end

    def review_path contribution
      CatarseJuntosGiftCards::Engine.routes.url_helpers.review_juntos_gift_card_path(contribution)
    end

    def can_do_refund?
      false
    end

    def locale
      'en'
    end

  end
end
