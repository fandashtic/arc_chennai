Create Procedure sp_Get_SchemeItemPerc(@Invoiceid int)
As
 Declare @ProdCode nVarchar(255),@serial int,@SplCategory int
 Declare @SlNo as nvarchar(2000)	
 DECLARE @TempSchemeItem TABLE (Product_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SchSalValue decimal(18,6),SchValue decimal(18,6),Serial Int,SpecialCategory Int,FreeItem int)

 DECLARE @TempSchemeFreeItem TABLE (Product_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SchSalValue decimal(18,6),SchValue decimal(18,6),SpecialCategory Int,Serial int,Invoice int,SSSerial int)

 DECLARE @Temp TABLE (Product_Code nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SpecialCategory Int,Serial int)
 
  
Begin
	Insert into @TempSchemeItem (Product_Code ,SchSalValue ,SchValue,Serial,specialcategory) 
    select Product_Code,(Quantity * isnull(SalePrice,0)),DiscountValue,Serial,(Case When IsNull(SPLCATDISCAMOUNT,0) > 0 THEN 1 ELSE 0 END) from 
    Invoicedetail where Invoiceid=@Invoiceid
    and flagword=0 
--    and ((Isnull(Multipleschemeid,'')<>'' AND isnull(MultipleSchemeid,'0')<>'0' ) or (Isnull(MultipleSPLCatSchemeid,'')<>'' and Isnull(MultipleSPLCatSchemeid,'0')<>'0' ))
--    and DiscountValue > 0
	and serial in (    select distinct Serial from Invoicedetail where Invoiceid=@Invoiceid and flagword=0 
    and ((Isnull(Multipleschemeid,'')<>'' AND isnull(MultipleSchemeid,'0')<>'0' ) or (Isnull(MultipleSPLCatSchemeid,'')<>'' and Isnull(MultipleSPLCatSchemeid,'0')<>'0' ))
	and (isnull(SchemediscAmount,0) > 0 or isnull(splCatDiscAmount,0) >0) )
	
	--FreeItem
	Insert into @TempSchemeFreeItem (Product_Code ,SchSalValue ,SchValue,SpecialCategory,Serial,SSSerial)	
	select Distinct ID.Product_Code,(ID.Quantity * isnull(ID.SalePrice,0)),SS.SchemeValue,SS.SpecialCategory,ID.Serial,SS.Serial
	from tbl_merp_schemesale SS,InvoiceDetail ID,
	tbl_merp_schemeslabdetail SL 
	where SS.Invoiceid=@Invoiceid
	and ID.InvoiceID=SS.InvoiceID
	and ID.Serial=SS.Serial
	and ID.Product_Code=SS.Product_Code	
	and SL.SlabID=SS.SlabID and SL.SlabType=3

	
	INSERT INTO @TEMP (Product_code,SpecialCategory,Serial ) select Distinct Product_code,SpecialCategory,Serial  from @TempSchemeFreeItem

	DECLARE Crsr CURSOR FOR  
	select Product_code,SpecialCategory,Serial from @Temp 
	OPEN Crsr  
	FETCH NEXT FROM Crsr into @ProdCode,@SplCategory,@Serial  
	WHILE (@@FETCH_STATUS <> -1)  
	Begin
	   If (@SplCategory=1)
  	   Begin
			 Select @SlNo = ID.splcatSerial from InvoiceDetail ID,tbl_mERP_SchemeSale SS 
             Where cast(ID.Serial as nvarchar)=cast(SS.Serial as nvarchar) and 
             ID.Invoiceid=SS.Invoiceid and SS.InvoiceID=@InvoiceID and SS.Serial=@Serial

			
			Insert into @TempSchemeFreeItem (Product_Code ,SchSalValue ,SchValue,SpecialCategory,Serial,Invoice,SSSerial)
			select ID.Product_Code,(ID.Quantity * isnull(ID.SalePrice,0)),SS.SchemeValue,SS.SpecialCategory,ID.Serial,1,@Serial
			from tbl_merp_schemesale SS,InvoiceDetail ID			
			where ID.Invoiceid=@InvoiceID and SS.InvoiceID = @InvoiceID and SS.Serial=@Serial
			and ID.Serial in (select itemvalue from dbo.fn_SplitIn2Rows_Int(@SlNo,',') )


			delete from @TempSchemeFreeItem where Serial = @Serial

			Update @TempSchemeFreeItem set SchValue = schValue/(select count(serial) from @TempSchemeFreeItem where SSSerial = @Serial and Invoice=1 ) 
			where SSSerial = @Serial and Invoice=1
			
  

             Update  @TempSchemeFreeItem set Product_Code=(select Top 1 Product_Code from InvoiceDetail ID 
             where ID.InvoiceID=@InvoiceID and isnull(flagword,0)=0 and ID.Serial in (select itemvalue from dbo.fn_SplitIn2Rows_Int(@SlNo,','))),
             SchSalValue=(select Top 1 (ID.Quantity * ID.SalePrice) from InvoiceDetail ID 
             where ID.InvoiceID=@InvoiceID and isnull(flagword,0)=0 and ID.Serial in (select itemvalue from dbo.fn_SplitIn2Rows_Int(@SlNo,',')))
			 where Product_Code=@ProdCode and Serial=@Serial and Invoice <>1	
			 			
  End
	   Else	
	   Begin
			 Select @SlNo = ID.freeserial from InvoiceDetail ID,tbl_mERP_SchemeSale SS 
             Where cast(ID.Serial as nvarchar)=cast(SS.Serial as nvarchar) and 
             ID.Invoiceid=SS.Invoiceid and SS.InvoiceID=@InvoiceID and SS.Serial=@Serial
			--New
			Insert into @TempSchemeFreeItem (Product_Code ,SchSalValue ,SchValue,SpecialCategory,Serial,Invoice,SSSerial)
			select ID.Product_Code,(ID.Quantity * isnull(ID.SalePrice,0)),SS.SchemeValue,SS.SpecialCategory,ID.Serial,1,@Serial
			from tbl_merp_schemesale SS,InvoiceDetail ID			
			where ID.Invoiceid=@InvoiceID and SS.InvoiceID = @InvoiceID and SS.Serial=@Serial
			and ID.Serial in (select itemvalue from dbo.fn_SplitIn2Rows_Int(@SlNo,',') )
			delete from @TempSchemeFreeItem where Serial = @Serial
			--			 
			 Update  @TempSchemeFreeItem set Product_Code=(select Top 1 Product_Code from InvoiceDetail ID 
             where ID.InvoiceID=@InvoiceID and isnull(flagword,0)=0 and ID.Serial in (select itemvalue from dbo.fn_SplitIn2Rows_Int(@SlNo,','))),
             SchSalValue=(select Top 1 (ID.Quantity * ID.SalePrice) from InvoiceDetail ID 
             where ID.InvoiceID=@InvoiceID and isnull(flagword,0)=0 and ID.Serial in (select itemvalue from dbo.fn_SplitIn2Rows_Int(@SlNo,',')))
			 where Product_Code=@ProdCode and Serial=@Serial
       End	
  	   FETCH NEXT FROM Crsr into @ProdCode,@SplCategory,@Serial  	
	End 

	Close CrSr
	Deallocate CrSr

	--To update SchemeValue for Non Spl Category Free Items
	DECLARE Crsr CURSOR FOR  
	select Distinct Product_code,SSSerial from @TempSchemeFreeItem where isnull(SPECIALCATEGORY,0)<>1
	OPEN Crsr  
	FETCH NEXT FROM Crsr into @ProdCode,@Serial  
	WHILE (@@FETCH_STATUS <> -1)  
	Begin					
		Update @TempSchemeFreeItem set SchValue = SchValue/(select count(SSserial) from @TempSchemeFreeItem where SSSerial = @Serial and isnull(SPECIALCATEGORY,0)<>1 ) 
		where SSSerial = @Serial and isnull(SPECIALCATEGORY,0)<>1
	FETCH NEXT FROM Crsr into @ProdCode,@Serial  
	End	
	Close CrSr
	Deallocate CrSr

--	select * from @TempSchemeFreeItem
	insert into @TempSchemeItem (Product_Code,SchSalValue,SchValue,SPECIALCATEGORY,Serial,FreeItem)
    Select distinct Product_Code,SUM(SchSalValue),sum(SchValue),SPECIALCATEGORY,Serial,1  
    from @TempSchemeFreeItem
    group by Product_Code,SPECIALCATEGORY,Serial,SSSerial
	--To update SchemeSaleValue for free items -- Spl Category Free Items
	DECLARE Crsr CURSOR FOR  
	select Distinct Serial from @TempSchemeItem where Serial in (select serial from @TempSchemeItem where isnull(FreeItem,0)=1 ) --Isnull(specialcategory,0) = 1 
	OPEN Crsr  
	FETCH NEXT FROM Crsr into @Serial  
	WHILE (@@FETCH_STATUS <> -1)  
	Begin					
		Update @TempSchemeItem set SchSalValue = schSalValue/(select count(serial) from @TempSchemeItem where Serial = @Serial )--and isnull(SPECIALCATEGORY,0)=1 ) 
		where Serial = @Serial --and Isnull(SPECIALCATEGORY,0)=1
	FETCH NEXT FROM Crsr into @Serial  
	End	
	Close CrSr
	Deallocate CrSr
--	--To update SchemeSaleValue for Non Spl Category Free Items
--	DECLARE Crsr CURSOR FOR  
--	select Distinct Serial from @TempSchemeItem where IsNull(specialcategory,0) = 0 
--	OPEN Crsr  
--	FETCH NEXT FROM Crsr into @Serial  
--	WHILE (@@FETCH_STATUS <> -1)  
--	Begin					
--		Update @TempSchemeItem set SchSalValue = schSalValue/(select count(serial) from @TempSchemeItem where Serial = @Serial and IsNull(specialcategory,0)=0 ) 
--		where Serial = @Serial and IsNull(specialcategory,0)=0
--	FETCH NEXT FROM Crsr into @Serial  
--	End	
--	Close CrSr
--	Deallocate CrSr

	Select distinct Product_code,Sum(SchValue) SchemeValue ,
    sum(SchSalValue) GrossValue,
    (Sum(SchValue) /sum(Isnull(SchSalValue,1))) * 100  as Percentage 
	from @TempSchemeItem group by Product_Code

End
