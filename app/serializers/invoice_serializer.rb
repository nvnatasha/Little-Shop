class InvoiceSerializer
    def self.format_invoices(invoices)
        {
            data: invoices.map do |invoice|
                {
                    id: invoice.id.to_s,
                    type: 'invoice',
                    attributes: {
                        status: invoice.status,
                        merchant_id: invoice.merchant_id,
                        customer_id: invoice.customer_id,
                        coupon_id: invoice.coupon_id
                    }
                }
            end,
        }
    end


    def self.format_invoice(invoice)
        {
            data: {
                id: invoice.id.to_s,
                type: 'invoice',
                attributes: {
                    status: invoice.status,
                    merchant_id: invoice.merchant_id,
                    customer_id: invoice.customer_id,
                    coupon_id: invoice.coupon_id
                }
            }
        }
    end
end