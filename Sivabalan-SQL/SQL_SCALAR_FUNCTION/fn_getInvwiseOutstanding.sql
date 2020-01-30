CREATE function fn_getInvwiseOutstanding  
(  
@CustomerId nVarchar(100),  
@InvoiceId Int,  
@CollectionId Int,@CollToDate datetime,  
@CollPaymentModeNo int,  
@CollDate datetime  
)    
Returns decimal(18,6)    
as    
Begin    
  
     declare @OutstandingAmt decimal(18,6)    
     select @OutstandingAmt = documentvalue - AdjAmount  
     from  
     (  
         select DocumentID,documentvalue , sum(AdjAmount) as AdjAmount  
         from   
         (  
         --Excluding Postdated only  
         select Det.DocumentID,isnull(Det.documentvalue,0) as documentvalue,   
                Isnull(AdjustedAmount,0) + isnull(Adjustment,0) as AdjAmount  
         from Collections Abst,CollectionDetail Det    
         where   
              Det.DocumentID = @InvoiceId      
--                        and Abst.Paymentmode = @CollPaymentModeNo    
              and Isnull(Abst.Status,0) & 192 = 0    
              and Abst.CustomerId=@CustomerID     
              --Dont use dbo.striptimefromdate() on this.Because same date can have more than one collections  
              and (dbo.striptimefromdate(Abst.DocumentDate) <= dbo.striptimefromdate(@CollDate)  and Det.CollectionId <= @CollectionId)     
              and Abst.DocumentDate <= @CollToDate  
              And Abst.Value >= 0   
              and Abst.DocumentID = Det.CollectionId     
         union all  
         --Postdated only  
         select Det.DocumentID,isnull(Det.documentvalue,0) as documentvalue,   
                Isnull(AdjustedAmount,0) + isnull(Adjustment,0) as AdjAmount  
         from Collections Abst,CollectionDetail Det    
         where   
              Det.DocumentID = @InvoiceId      
--                        and Abst.Paymentmode = @CollPaymentModeNo    
              and Isnull(Abst.Status,0) & 192 = 0    
              and Abst.CustomerId=@CustomerID     
              and (dbo.striptimefromdate(Abst.DocumentDate) < dbo.striptimefromdate(@CollDate)  and Det.CollectionId > @CollectionId)     
              and Abst.DocumentDate <= @CollToDate  
              And Abst.Value >= 0   
              and Abst.DocumentID = Det.CollectionId     
          ) tmp  
         group by DocumentID,documentvalue  
     ) tmp            
     return @OutstandingAmt    
End   


