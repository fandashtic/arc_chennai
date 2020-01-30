CREATE Procedure sp_acc_rpt_arvsubdetail(@DocRef Int, @Info nvarchar(4000),@Detail Int = 0)
As

Declare @COLSEP nVarchar(15)
Declare @ROWSEP nVarchar(15)
Declare @Type Int
Declare @AccountID Int
Declare @LenInfo Int
Declare @Local as nVarchar(250)
Declare @ColumnCount Int

Declare @Field1 nVarchar(4000)
Declare @RowField1 nVarchar(4000)
Declare @ColField1 nVarchar(4000)
Declare @Flag Int
Declare @FieldCount Int
Declare @SQL nVarchar(4000)
Set @Flag=0
Set @FieldCount=2
Set @ColumnCount=1

Declare @TYPE_ASSET INT
Declare @TYPE_OTHER INT
Declare @TYPE_CREDITCARD INT
Declare @TYPE_COUPON INT

Set @TYPE_ASSET = 0
Set @TYPE_OTHER = 1
Set @TYPE_CREDITCARD = 3
Set @TYPE_COUPON = 4

Create Table #TempAssetRow(RowField1 nVarchar(4000))
Create Table #TempAssetCol(ColField1 nVarchar(4000))
Create Table #TempOther(Field1 nVarchar(4000))
Create Table #DynamicTable(Remark nVarchar(250),Amount Decimal(18,6))
Create Table #DynamicTableAsset(BatchCode nVarchar(15),Serial nVarchar(250),Amount Decimal(18,6))
Create Table #DynamicTableCreditCard(ContraSerialCode nVarchar(15),ContraID nVarchar(15),Customer nVarchar(255),Number nVarchar(255),Type nVarchar(255),InvoiceID nVarchar(15),Amount Decimal(18,6))
Create Table #DynamicTableCoupon(ContraSerialCode nVarchar(15),ContraID nVarchar(15),Customer nVarchar(255),Coupon nVarchar(255),Quantity nVarchar(255),Rate Decimal(18,6),Amount Decimal(18,6))

Set @COLSEP = Char(1)
Set @ROWSEP = Char(2)


If @DocRef=@TYPE_ASSET
Begin
	Insert #TempAssetRow
	Exec Sp_acc_SQLSplit @Info,@ROWSEP
	--Select * From #TempAssetRow
	DECLARE scantemprow CURSOR KEYSET FOR
	select RowField1 from #TempAssetRow 
	
	OPEN scantemprow
	FETCH FROM scantemprow INTO @RowField1
	
	WHILE @@FETCH_STATUS =0
	BEGIN

		Insert #TempAssetCol
		Exec Sp_acc_SQLSplit @RowField1,@COLSEP
		--Select * from #TempAssetCol
		DECLARE scantempcol CURSOR KEYSET FOR
		select ColField1 from #TempAssetCol 
		
		OPEN scantempcol
		FETCH FROM scantempcol INTO @ColField1
		
		WHILE @@FETCH_STATUS =0
		BEGIN
			If @Flag=0
			Begin
				Insert #DynamicTableAsset Values(@ColField1,0,0)
				Set @Flag=1
				Set @Local=@ColField1
				Set @ColumnCount=@ColumnCount+1
			End
			Else
			Begin
				--Set @SQL = 'Alter Table #DynamicTable Add [DynamicField' + cast(@FieldCount as varchar) + '] Varchar(250) Null'
				--Select @SQL
				--EXEC @SQL
				--Set @SQL = 'Update #DynamicTable Set [DynamicField' + cast(@FieldCount as varchar) + '] = '' + @Field1 '''
				--EXEC @SQL
				--Select @local
				If @ColumnCount=2
					Update #DynamicTableAsset Set Serial=@ColField1 where BatchCode=@Local
				Else If @ColumnCount=3
					Update #DynamicTableAsset Set Amount=Cast(@ColField1 as Decimal(18,6)) where BatchCode=@Local
				--Set @FieldCount=@FieldCount+1
				Set @ColumnCount=@ColumnCount+1
			End
			  
		  	FETCH NEXT FROM scantempcol INTO @ColField1
		END
		CLOSE scantempcol
		DEALLOCATE scantempcol
		Set @Flag=0
		Set @local=Null
		Delete #TempAssetCol
		Set @ColumnCount=1
	  	FETCH NEXT FROM scantemprow INTO @RowField1
	END
	CLOSE scantemprow
	DEALLOCATE scantemprow

	--Select 'Remark'=DynamicField1 , 'Amount'= DynamicField2 from #DynamicTable
	If @Detail = 0
	Begin
		Select Serial,Amount,5 from #DynamicTableAsset
	End
	Else
	Begin
		Select count(*) from #DynamicTableAsset
	End

End
Else If @DocRef=@TYPE_CREDITCARD
Begin
	Insert #TempAssetRow
	Exec Sp_acc_SQLSplit @Info,@ROWSEP
	--Select * From #TempAssetRow
	DECLARE scantemprow CURSOR KEYSET FOR
	select RowField1 from #TempAssetRow 
	
	OPEN scantemprow
	FETCH FROM scantemprow INTO @RowField1
	
	WHILE @@FETCH_STATUS =0
	BEGIN

		Insert #TempAssetCol
		Exec Sp_acc_SQLSplit @RowField1,@COLSEP
		--Select * from #TempAssetCol
		DECLARE scantempcol CURSOR KEYSET FOR
		select ColField1 from #TempAssetCol 
		
		OPEN scantempcol
		FETCH FROM scantempcol INTO @ColField1
		
		WHILE @@FETCH_STATUS =0
		BEGIN
			If @Flag=0
			Begin
				Insert #DynamicTableCreditCard Values(@ColField1,0,0,0,0,0,0)
				Set @Flag=1
				Set @Local=@ColField1
				Set @ColumnCount=@ColumnCount+1
			End
			Else
			Begin
				If @ColumnCount=2
					Update #DynamicTableCreditCard Set ContraID=@ColField1 where ContraSerialCode=@Local
				Else If @ColumnCount=3
					Update #DynamicTableCreditCard Set Customer=@ColField1 where ContraSerialCode=@Local
				Else If @ColumnCount=4
					Update #DynamicTableCreditCard Set Number=@ColField1 where ContraSerialCode=@Local
				Else If @ColumnCount=5
					Update #DynamicTableCreditCard Set Type=@ColField1 where ContraSerialCode=@Local
				Else If @ColumnCount=6
					Update #DynamicTableCreditCard Set InvoiceID=@ColField1 where ContraSerialCode=@Local
				Else If @ColumnCount=7
					Update #DynamicTableCreditCard Set Amount=Cast(@ColField1 as Decimal(18,6)) where ContraSerialCode=@Local
				--Set @FieldCount=@FieldCount+1
				Set @ColumnCount=@ColumnCount+1
			End
			  
		  	FETCH NEXT FROM scantempcol INTO @ColField1
		END
		CLOSE scantempcol
		DEALLOCATE scantempcol
		Set @Flag=0
		Set @local=Null
		Delete #TempAssetCol
		Set @ColumnCount=1
	  	FETCH NEXT FROM scantemprow INTO @RowField1
	END
	CLOSE scantemprow
	DEALLOCATE scantemprow

	--Select 'Remark'=DynamicField1 , 'Amount'= DynamicField2 from #DynamicTable
	If @Detail = 0
	Begin
		Select ContraID,Customer,'Card Number'=Number,'Card Type'=Type,InvoiceID,Amount,5 from #DynamicTableCreditCard
	end
	Else
	Begin
		Select count(*) from #DynamicTableCreditCard
	End
End
Else If @DocRef=@TYPE_COUPON
Begin
	Insert #TempAssetRow
	Exec Sp_acc_SQLSplit @Info,@ROWSEP
	--Select * From #TempAssetRow
	DECLARE scantemprow CURSOR KEYSET FOR
	select RowField1 from #TempAssetRow 
	
	OPEN scantemprow
	FETCH FROM scantemprow INTO @RowField1
	
	WHILE @@FETCH_STATUS =0
	BEGIN

		Insert #TempAssetCol
		Exec Sp_acc_SQLSplit @RowField1,@COLSEP
		--Select * from #TempAssetCol
		DECLARE scantempcol CURSOR KEYSET FOR
		select ColField1 from #TempAssetCol 
		
		OPEN scantempcol
		FETCH FROM scantempcol INTO @ColField1
		
		WHILE @@FETCH_STATUS =0
		BEGIN
			If @Flag=0
			Begin
				Insert #DynamicTableCoupon Values(@ColField1,0,0,0,0,0,0)
				Set @Flag=1
				Set @Local=@ColField1
				Set @ColumnCount=@ColumnCount+1
			End
			Else
			Begin
				If @ColumnCount=2
					Update #DynamicTableCoupon Set ContraID=@ColField1 where ContraSerialCode=@Local
				Else If @ColumnCount=3
					Update #DynamicTableCoupon Set Customer=@ColField1 where ContraSerialCode=@Local
				Else If @ColumnCount=4
					Update #DynamicTableCoupon Set Coupon=@ColField1 where ContraSerialCode=@Local
				Else If @ColumnCount=5
					Update #DynamicTableCoupon Set Quantity=@ColField1 where ContraSerialCode=@Local
				Else If @ColumnCount=6
					Update #DynamicTableCoupon Set Rate=Cast(@ColField1 as Decimal(18,6)) where ContraSerialCode=@Local
				Else If @ColumnCount=7
					Update #DynamicTableCoupon Set Amount=Cast(@ColField1 as Decimal(18,6)) where ContraSerialCode=@Local
				--Set @FieldCount=@FieldCount+1
				Set @ColumnCount=@ColumnCount+1
			End
			  
		  	FETCH NEXT FROM scantempcol INTO @ColField1
		END
		CLOSE scantempcol
		DEALLOCATE scantempcol
		Set @Flag=0
		Set @local=Null
		Delete #TempAssetCol
		Set @ColumnCount=1
	  	FETCH NEXT FROM scantemprow INTO @RowField1
	END
	CLOSE scantemprow
	DEALLOCATE scantemprow

	--Select 'Remark'=DynamicField1 , 'Amount'= DynamicField2 from #DynamicTable
	If @Detail = 0
	Begin
		Select ContraID,Customer,Coupon,Quantity,Rate,Amount,5 from #DynamicTableCoupon
	End
	Else
	Begin
		Select Count(*) from #DynamicTableCoupon
	End
End
Else
Begin
	Insert #TempOther
	Exec Sp_acc_SQLSplit @Info,@COLSEP

	DECLARE PivotTable CURSOR KEYSET FOR
	select field1 from #tempOther 
	
	OPEN PivotTable
	FETCH FROM PivotTable INTO @Field1
	
	WHILE @@FETCH_STATUS =0
	BEGIN
		If @Flag=0
		Begin
			Insert #DynamicTable Values(@Field1,0)
			Set @Flag=1
		End
		Else
		Begin
			Update #DynamicTable Set Amount=Cast(@Field1 as Decimal(18,6))
		End
		  
	  	FETCH NEXT FROM PivotTable INTO @Field1
	END
	CLOSE PivotTable
	DEALLOCATE PivotTable
	If @Detail = 0
	Begin
		Select Remark,Amount,5 from #DynamicTable
	End
	Else
	Begin
		Select Count(*) from #DynamicTable
	End
	Drop Table #DynamicTable
	Drop Table #TempOther
End


