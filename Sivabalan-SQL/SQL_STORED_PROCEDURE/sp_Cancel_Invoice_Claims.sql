Create Procedure sp_Cancel_Invoice_Claims(@InvoiceID as Int, @CSQPSFlag Int = 0 )As     
Begin  
 Update SchemeSale Set Pending = 0 Where InvoiceID = @InvoiceID    
 Declare @Temp Table(SchemeId int, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, Quantity Decimal(18,6))  
  If @CSQPSFlag = 0
   Begin
   Insert Into @Temp   
   Select Sci.SchemeID, SCi.CustomerID, Sci.Product_Code, Sum(InvoiceDetail.Quantity)  
   From SchemecustomerItems SCI, InvoiceAbstract, Invoicedetail  
   Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
     SCi.SChemeID = InvoiceDetail.Schemeid and  
     SCI.CustomerID = InvoiceAbstract.CustomerID and  
     Sci.Product_code = InvoiceDetail.Product_Code and  
     InvoiceAbstract.InvoiceID = @InvoiceID and  
     InvoiceAbstract.Status & 192 = 0  
     Group By Sci.SchemeID, SCi.CustomerID, Sci.Product_Code  
  
   Update SchemeCustomerItems  
   Set Pending = SCI.Pending + T.Quantity,  
     Claimed = (Case When SCI.Pending + T.Quantity > 0 then 0 Else 1 end)  
   From SchemeCustomerItems Sci, @Temp T  
   Where SCi.SChemeID = T.Schemeid and  
     SCI.CustomerID = T.CustomerID and  
     SCI.Product_code = T.Product_Code
   End 
  Else If @CSQPSFlag = 1 
   Begin 
   Insert Into @Temp
   Select Sci.SchemeID, SCi.CustomerID, Sci.Product_Code, Sum(InvoiceDetail.Quantity)
   From SchemeCustomerItems SCI, InvoiceAbstract, Invoicedetail  
   Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID and  
     Sci.SChemeID = InvoiceDetail.Schemeid and  
     ScI.CustomerID = InvoiceAbstract.CustomerID and  
     Sci.Product_code = InvoiceDetail.Product_Code and  
     Sci.InvoiceRef = Cast(InvoiceAbstract.InvoiceID as nVarchar(15)) and 
     InvoiceAbstract.InvoiceID = @InvoiceID and  
     InvoiceAbstract.Status & 192 = 0  
   Group By Sci.SchemeID, SCi.CustomerID, Sci.Product_Code
   Order by Sci.SchemeID, SCi.CustomerID, Sci.Product_Code

   /*Get the Latest payout list for the given InvoiceID*/
   Declare @SchID Int
   Declare @InvoiceRef nVarchar(1000) 
   Declare @InvQty  Decimal(18,6)
   Declare @CustomerID  nVarchar(50), @ProductCode nVarchar(50)
   Declare CusAdjustQty Cursor For
   Select T.SchemeID, T.CustomerID, T.Product_Code, Sum(T.Quantity)
   From @Temp T  
   Group by T.SchemeID, T.CustomerID, T.Product_Code
   Open CusAdjustQty
   Fetch Next From CusAdjustQty Into @SchID, @CustomerID, @ProductCode, @InvQty
   While @@Fetch_status = 0 
     Begin
       Declare @payoutID Int
       Declare @Pending Decimal(18,6)
       Declare @SchQty Decimal(18,6)
       Declare @SchPending Decimal(18,6)
       Declare @UpdRowCnt Int 
       Declare @Cnt Int , @InvRef nVarchar(1000)
       Set @Pending = 0

       Declare CurUpdatePending Cursor For      
       Select PayoutID From SchemeCustomerItems 
       Where SChemeID = @SchID and  
       CustomerID = @CustomerID and  
       Product_Code = @ProductCode and 
       InvoiceRef = Cast(@InvoiceID as nVarchar(15)) 
       and IsNull(Claimed,0) = 1
       Order By PayoutID Desc 
       Open CurUpdatePending
       Fetch Next From CurUpdatePending Into @payoutID
       While @@Fetch_status = 0
         Begin
           Select @SchQty = Quantity ,@SchPending = Pending, @InvRef = InvoiceRef 
           From SchemeCustomerItems 
           Where SChemeID = @SchID and PayoutID = @payoutID 
                 and CustomerID = @CustomerID and Product_Code = @ProductCode 
                 and InvoiceRef = Cast(@InvoiceID as nVarchar(15)) 
                 and IsNull(Claimed,0) = 1
           IF (@SchQty - @SchPending) >= @InvQty
              Begin
              Set @Pending = @InvQty
              End
           Else 
              Begin
              Set @Pending = @InvQty - (@InvQty - (@SchQty - @SchPending))
              End
           Select @Cnt = Count(*) From dbo.sp_SplitIn2Rows(@InvRef,',')
           If @InvQty > 0 
             Begin 
             Update SchemeCustomerItems  
		     Set Pending = Pending + @Pending,
		       Claimed = (Case When (Quantity <= (Pending + @Pending))  then 0 Else 1 end)
		       From SchemeCustomerItems 
		       Where SChemeID = @SchID and  
		       PayoutID = @payoutID and 
		       CustomerID = @CustomerID and  
		       Product_Code = @ProductCode
               set @UpdRowCnt = @@Rowcount
               Set @InvQty = @InvQty - @Pending
               set @Pending = 0
              /*To Update IsInvoiced and Invoice Ref irespective of the Item*/
               If @UpdRowCnt > 0 
               Begin 
                 Update SchemeCustomerItems Set IsInvoiced = 0 , InvoiceRef = ''  
                 Where SChemeID = @SchID and  
                 PayoutID = @payoutID and 
                 CustomerID = @CustomerID and 
                 IsInvoiced > 0 
               End
             End
           Fetch Next From CurUpdatePending Into @payoutID
         End
       Close CurUpdatePending
       Deallocate CurUpdatePending
     Fetch Next From CusAdjustQty Into @SchID, @CustomerID, @ProductCode, @InvQty
     End
     Close CusAdjustQty
     Deallocate CusAdjustQty
  End
End  
