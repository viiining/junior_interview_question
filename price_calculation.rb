require './models/campaign.rb'
require './models/order.rb'

# 計算規則
#
# 1. 消費未滿 $1,500, 則須增加 $60 運費
# 2. 若消費期間有超過兩個優惠活動，取最優者折扣 
# 3. 運費計算在優惠折抵之後
#
# Please implemenet the following methods.
# Additional helper methods are recommended.

class PriceCalculation
  def initialize(order_id)
    @order = find_order(order_id)
    @campaigns = Campaign.running_campaigns(@order.order_date) # 找到在訂單日期適用的促銷活動
  end

  def total
    total_price = @order.price
    total_discount = 0

    # 計算滿足訂單日期的促銷活動中最大的折扣
    if @campaigns.any?
      max_discount = @campaigns.max_by(&:discount_ratio).discount_ratio
      total_discount = (total_price * max_discount / 100).to_i
    end

    total_price -= total_discount

    total_price += 60 if !free_shipment?

    total_price
  end

  def free_shipment?
    @order.price >= 1500
  end

  private

  def find_order(order_id)
    order = Order.find(order_id)
    raise Order::NotFound if order.nil?
    order
  end
end
