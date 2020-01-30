Create Procedure sp_Update_AdjustmentValue (@InvoiceID Int, 
					    @DebitID Int, 
					    @Value Decimal(18,6))
As
Update InvoiceAbstract Set Balance = Balance + @Value Where InvoiceID = @InvoiceID
Update DebitNote Set Balance = 0 Where DebitID = @DebitID
