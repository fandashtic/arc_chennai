CREATE Procedure Sp_List_SchemeToClaimDetail(@SchemeId int)    
As    
Set dateformat dmy    
Declare @bSelCustomers int     
Declare @IsPer int     
Declare @Flag int    
Declare @FromLim decimal(18,6)    
Declare @ToLim Decimal(18,6)    
Declare @Discount Decimal(18,6)    
Declare @AllAmt Decimal(18,6)    
Declare @FreeQty Decimal(18,6)    
Declare @bHasSlabs int    
Declare @Fromdate Datetime    
Declare @Todate Datetime    
    
--@Flag is set to 1 when OFFTAKE  InvoiceBased  Amount/Percentage    
--@Flag is set to 2 when OFFTAKE  ItemBased   Amount/Percentage    
--@Flag is Set to 3 when Display Scheme Is Entered.    
--@Flag is Set to 4 when OFFTAKE ItemBased Item Free is Given    
--@Flag is Set to 5 when OFFTAKE InvoiceBased Free Items For value is Given    
    
    
Create Table CusTable(CusCode nvarchar(15),CusName nvarchar(150),    
SalesValue Decimal(18,6) Default(0),DisAmt Decimal (18,6) Default(0),AllottedAmount Decimal(18,6) Default(0),    
Qty Decimal(18,6) Default(0),Product_Code nvarchar(100))      
    
Select @bSelCustomers=IsNull(Schemes.Customer,0),    
@IsPer=(Case SchemeType When 34 Then 1 When 51 then 1 Else 0 End),    
@Flag= (Case When SchemeTYpe=65 Then 3     
  When (SchemeType/16)=2 Then (Case SchemeType % 16 When 3 Then 5 Else 1 End)    
  When (SchemeType/16)=3 Then (Case When (SchemeType % 16)>= 3 Then 2 Else 4 End)End),    
@FromDate=ValidFrom,    
@ToDate=ValidTo,    
@bHasSlabs=HasSlabs    
From Schemes Where SchemeID=@SchemeId    


IF(@Flag=1)    
Begin    
 If(@bSelCustomers=0)    
 Begin        
  sET DATEFORMAT DMY    
  Insert into CusTable(Cuscode,CusName,SalesValue)    
   Select InvAb.CustomerID,CusMas.Company_Name,    
   Sum(Case InvAb.InvoiceType When 4 then 0-NetValue Else NetValue End)    
   From InvoiceAbstract InvAb,Customer CusMas,Schemes    
   Where InvAb.CustomerId=CusMas.CustomerId    
   And InvAb.Invoicedate Between @Fromdate And @ToDate    
   And InvAb.InvoiceType In (1,2,3)    
   And (InvAb.Status & 128)=0       
   And Schemes.SchemeId=@SchemeId    
   And InvAb.CustomerId <> '0'  
   And (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(InvAb.PaymentMode,schemes.SchemeID)=1 )
   Group by InvAb.CustomerId,CusMas.Company_nAME    
 End                
 Else    
 Begin    
  Insert into CusTable(Cuscode,CusName,SalesValue)    
   Select InvAb.CustomerID,CusMas.Company_Name,    
   Sum(Case InvAb.InvoiceType When 4 then 0-NetValue Else NetValue End)    
   From InvoiceAbstract InvAb,Customer CusMas,SchemeCustomers SchCus,Schemes    
   Where InvAb.CustomerId=CusMas.CustomerId    
   And InvAb.Invoicedate Between @Fromdate And @ToDate    
   And InvAb.InvoiceType In (1,2,3)    
   And (InvAb.Status & 128)=0      
   And SchCus.SchemeId=@SchemeId    
   And Schemes.SchemeId=SchCus.SchemeId    
   And SchCus.CustomerId=InvAb.CustomerId    
   And InvAb.CustomerId <> '0'  
   And (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(InvAb.PaymentMode,schemes.SchemeID)=1 )	
   Group by InvAb.CustomerId,CusMas.Company_nAME    
 End      
 --Calculation For SchemeDiscount,Alloted Amount    
 Declare SchemeDiscount Cursor For    
  Select StartValue,EndValue,Freevalue From SchemeItems    
  Where SchemeId=@SchemeID    
     
 Open SchemeDiscount    
      
 Fetch next From SchemeDiscount Into @FromLim,@ToLim,@Discount    
 While(@@fetch_status=0)    
 Begin    
  IF (@IsPer=1)    
  Begin    
   Update Custable Set DisAmt=@Discount,AllottedAmount=SalesValue * (@Discount /100)    
   Where SalesValue >=@FromLim And SalesValue <=@Tolim    
  End    
  Else    
  Begin    
   Update Custable Set DisAmt=@Discount,AllottedAmount=@Discount    
   Where SalesValue >=@FromLim And SalesValue <=@Tolim    
  End    
 Fetch next From SchemeDiscount Into @FromLim,@ToLim,@Discount    
 End    
     
 Close SchemeDiscount    
 Deallocate SchemeDiscount 
 Select * from Custable Where AllottedAmount > 0    
End    
Else IF(@Flag=2)    
Begin     
 If(@bSelCustomers=0)    
 Begin        
  sET DATEFORMAT DMY    
  Insert into CusTable(Cuscode,CusName,SalesValue,Qty,Product_Code)  
 Select InvAb.CustomerID,CusMas.Company_Name,    
  Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Amount Else InvDet.Amount End),    
  Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Quantity Else InvDet.Quantity End),      
  Invdet.Product_Code
  From InvoiceAbstract InvAb,Customer CusMas,Schemes,    
  InvoiceDetail InvDet,ItemSchemes    
  Where InvAb.CustomerId=CusMas.CustomerId    
  And InvAb.Invoicedate Between @Fromdate And @ToDate    
  And InvAb.InvoiceId=InvDet.InvoiceId    
  And InvAb.InvoiceType In (1,2,3)    
  And (InvAb.Status & 128)=0      
  And Schemes.SchemeID=@SchemeID    
  And ItemSchemes.SchemeId=Schemes.Schemeid    
  And InvDet.Product_Code=ItemSchemes.Product_Code    
  And InvDet.FlagWord =0    
  And InvAb.CustomerId <> '0'  
  And (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(InvAb.PaymentMode,schemes.SchemeID)=1 )
  Group by InvAb.CustomerId,CusMas.Company_nAME,Invdet.Product_Code    
 End    
 Else    
 Begin    
  sET DATEFORMAT DMY    
  Insert into CusTable(Cuscode,CusName,SalesValue,Qty,Product_Code)      
  Select InvAb.CustomerID,CusMas.Company_Name,    
  Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Amount Else InvDet.Amount End),    
  Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Quantity Else InvDet.Quantity End),      
  Invdet.Product_Code
  From InvoiceAbstract InvAb,Customer CusMas,SchemeCustomers SchCus,Schemes,    
  InvoiceDetail InvDet,ItemSchemes    
  Where InvAb.CustomerId=CusMas.CustomerId    
  And InvAb.Invoicedate Between @Fromdate And @ToDate    
  And InvAb.InvoiceId=InvDet.InvoiceId    
  And InvAb.InvoiceType In (1,2,3)    
  And (InvAb.Status & 128)=0      
  And SchCus.SchemeId=@SchemeId    
  And Schemes.SchemeId=SchCus.SchemeId    
  And ItemSchemes.SchemeId=Schemes.Schemeid    
  And InvDet.Product_Code=ItemSchemes.Product_Code    
  And SchCus.CustomerId=InvAb.CustomerId    
  And InvDet.FlagWord =0    
  And InvAb.CustomerId <> '0'  
  And (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(InvAb.PaymentMode,schemes.SchemeID)=1 )
  Group by InvAb.CustomerId,CusMas.Company_nAME,Invdet.Product_Code    
 End


    
 Declare SchemeDiscount Cursor For    
  Select StartValue,EndValue,Freevalue From SchemeItems    
  Where SchemeId=@SchemeID    
    
 Open SchemeDiscount    
      
 Fetch next From SchemeDiscount Into @FromLim,@ToLim,@Discount    
 While(@@fetch_status=0)    
 Begin    
  IF (@IsPer=1)    
  Begin    
   Update Custable Set DisAmt=@Discount,AllottedAmount=SalesValue * (@Discount /100)    
   Where Qty >=@FromLim And Qty <=@Tolim    
  End    
  Else    
  Begin    
   Update Custable Set DisAmt=@Discount,AllottedAmount=@Discount    
   Where Qty >=@FromLim And Qty <=@Tolim    
  End    
  Fetch next From SchemeDiscount Into @FromLim,@ToLim,@Discount    
 End    
 Close SchemeDiscount    
 Deallocate SchemeDiscount    

Select CusCode,Cusname,"SalesValue" = Sum(SalesValue),"DisAmt" = Sum(DisAmt),"AllottedAmount" = Sum(AllottedAmount),"Qty" = Sum(Qty) from Custable Where AllottedAmount > 0 Group By CusCode,CusName

End    
Else IF(@Flag=3)    
Begin     
 Insert into CusTable(Cuscode,CusName,AllottedAmount)    
   Select SchCus.CustomerID,CusMas.Company_Name,    
   Sum(SchCus.AllotedAmount)    
   From SchemeCustomers SchCus,Customer CusMas,Schemes    
   Where SchCus.CustomerId=CusMas.CustomerId    
   And SchCus.SchemeId=Schemes.SchemeID    
   And Schemes.SchemeId=@SchemeId    
   Group by SchCus.CustomerID,CusMas.Company_Name    
    
 Select * from Custable Where AllottedAmount > 0    
End    
Else IF(@Flag=5)    
Begin    
 --Invoice based Free Items For Value    
 If(@bSelCustomers=0)    
 Begin        
  sET DATEFORMAT DMY    
  Insert into CusTable(Cuscode,CusName,SalesValue)    
   Select InvAb.CustomerID,CusMas.Company_Name,    
   Sum(Case InvAb.InvoiceType When 4 then 0-NetValue Else NetValue End)    
   From InvoiceAbstract InvAb,Customer CusMas,Schemes    
   Where InvAb.CustomerId=CusMas.CustomerId    
   And InvAb.Invoicedate Between @Fromdate And @ToDate    
   And InvAb.InvoiceType In (1,2,3)    
   And (InvAb.Status & 128)=0       
   And Schemes.SchemeId=@SchemeId  
   And InvAb.CustomerId <> '0'
   And (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(InvAb.PaymentMode,schemes.SchemeID)=1 )    
   Group by InvAb.CustomerId,CusMas.Company_nAME    
 End                
 Else    
 Begin    
Insert into CusTable(Cuscode,CusName,SalesValue)    
   Select InvAb.CustomerID,CusMas.Company_Name,    
   Sum(Case InvAb.InvoiceType When 4 then 0-NetValue Else NetValue End)    
   From InvoiceAbstract InvAb,Customer CusMas,SchemeCustomers SchCus,Schemes    
   Where InvAb.CustomerId=CusMas.CustomerId    
   And InvAb.Invoicedate Between @Fromdate And @ToDate    
   And InvAb.InvoiceType In (1,2,3)    
   And (InvAb.Status & 128)=0      
   And SchCus.SchemeId=@SchemeId    
   And Schemes.SchemeId=SchCus.SchemeId    
   And SchCus.CustomerId=InvAb.CustomerId   
   And InvAb.CustomerId <> '0'   
   And (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(InvAb.PaymentMode,schemes.SchemeID)=1 )
   Group by InvAb.CustomerId,CusMas.Company_nAME    
 End      
 --Calculation For Alloted Amount    
 Declare SchemeDiscount Cursor For    
  Select StartValue,EndValue,Freevalue From SchemeItems    
  Where SchemeId=@SchemeID    
     
 Open SchemeDiscount    
      
 Fetch next From SchemeDiscount Into @FromLim,@ToLim,@FreeQty    
 While(@@fetch_status=0)    
 Begin    
   Update Custable Set AllottedAmount=AllottedAmount + @FreeQty    
   Where SalesValue >=@FromLim And SalesValue <=@Tolim      
 Fetch next From SchemeDiscount Into @FromLim,@ToLim,@Discount    
 End    
     
 Close SchemeDiscount    
 Deallocate SchemeDiscount     
 Select * from Custable Where AllottedAmount > 0    
End    
Else IF(@Flag=4)    
Begin    
 If(@bSelCustomers=0)    
 Begin        
  sET DATEFORMAT DMY    
  Insert into CusTable(Cuscode,CusName,SalesValue,Qty,Product_Code)      
  Select InvAb.CustomerID,CusMas.Company_Name,    
  Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Amount Else InvDet.Amount End),    
  Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Quantity Else InvDet.Quantity End),      
  InvDet.Product_Code	
  From InvoiceAbstract InvAb,Customer CusMas,Schemes,    
  InvoiceDetail InvDet,ItemSchemes    
  Where InvAb.CustomerId=CusMas.CustomerId    
  And InvAb.Invoicedate Between @Fromdate And @ToDate    
  And InvAb.InvoiceId=InvDet.InvoiceId    
  And InvAb.InvoiceType In (1,2,3)    
  And (InvAb.Status & 128)=0      
  And Schemes.SchemeID=@SchemeID    
  And ItemSchemes.SchemeId=Schemes.Schemeid    
  And InvDet.Product_Code=ItemSchemes.Product_Code    
  And InvDet.FlagWord =0    
  And InvAb.CustomerId <> '0'  
  And (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(InvAb.PaymentMode,schemes.SchemeID)=1 )
  Group by InvAb.CustomerId,CusMas.Company_nAME,InvDet.Product_Code    
 End    
 Else    
 Begin    
  sET DATEFORMAT DMY    
  Insert into CusTable(Cuscode,CusName,SalesValue,Qty,Product_Code)      
  Select InvAb.CustomerID,CusMas.Company_Name,    
  Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Amount Else InvDet.Amount End),    
  Sum(Case InvAb.InvoiceType When 4 then 0-InvDet.Quantity Else InvDet.Quantity End),
  InvDet.Product_Code	      
  From InvoiceAbstract InvAb,Customer CusMas,SchemeCustomers SchCus,Schemes,    
  InvoiceDetail InvDet,ItemSchemes    
  Where InvAb.CustomerId=CusMas.CustomerId    
  And InvAb.Invoicedate Between @Fromdate And @ToDate    
  And InvAb.InvoiceId=InvDet.InvoiceId    
  And InvAb.InvoiceType In (1,2,3)    
  And (InvAb.Status & 128)=0      
  And SchCus.SchemeId=@SchemeId    
  And Schemes.SchemeId=SchCus.SchemeId    
  And ItemSchemes.SchemeId=Schemes.Schemeid    
  And InvDet.Product_Code=ItemSchemes.Product_Code 
  And SchCus.CustomerId=InvAb.CustomerId   
  And InvDet.FlagWord =0    
  And InvAb.CustomerId <> '0'  
  And (Isnull(schemes.PaymentMode,N'')=N'' or dbo.Fn_IsPaymentMode_In_Scheme(InvAb.PaymentMode,schemes.SchemeID)=1 )
  Group by InvAb.CustomerId,CusMas.Company_nAME,InvDet.Product_Code    
 End
	
	 Declare SchemeDiscount Cursor For    
	  Select StartValue,EndValue,Freevalue From SchemeItems    
	  Where SchemeId=@SchemeID Group by StartValue,EndValue,FreeValue   
	    
	 Open SchemeDiscount    
	      
	 Fetch next From SchemeDiscount Into @FromLim,@ToLim,@FreeQty    
	 While(@@fetch_status=0) 
		Begin    
		IF (@bHasSlabs=1)    
		Begin    
			Update Custable Set AllottedAmount=AllottedAmount + @FreeQty    
			Where Qty >=@FromLim And Qty <=@Tolim 
			And Custable.Product_Code in (Select Product_Code From ItemSchemes Where SchemeID=@SchemeID)
		End  
		Else    
		Begin    
			Update Custable Set AllottedAmount=AllottedAmount + (Cast(Qty/@FromLim as int) * @FreeQty)    
			Where Qty/@FromLim > 0    
			And Custable.Product_Code in (Select Product_Code From ItemSchemes Where SchemeID=@SchemeID)
		End   
	Fetch next From SchemeDiscount Into @FromLim,@ToLim,@Discount    
	End    
	Close SchemeDiscount    
	Deallocate SchemeDiscount    
	IF(@Flag=4)     
	Begin    
	 	Select CusCode,Cusname,"SalesValue" = Sum(SalesValue),"DisAmt" = Sum(DisAmt),"AllottedAmount" = Sum(AllottedAmount),"Qty" = Sum(Qty) from Custable Where AllottedAmount > 0 Group By CusCode,CusName
	End
	Else
	Begin
	 	Select * from Custable Where AllottedAmount > 0 
	End
    
End    
Drop Table Custable    
    
