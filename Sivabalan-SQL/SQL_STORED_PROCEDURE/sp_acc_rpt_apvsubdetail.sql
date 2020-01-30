CREATE Procedure sp_acc_rpt_apvsubdetail(@DocRef Int, @Info nvarchar(4000),@Detail Int = 0)
As

Declare @COLSEP nVarchar(15)
Declare @ROWSEP nVarchar(15)
Declare @Type Int
Declare @AccountID Int
Declare @LenInfo Int
Declare @Local as nVarchar(250)

Declare @Field1 nVarchar(4000)
Declare @RowField1 nVarchar(4000)
Declare @ColField1 nVarchar(4000)
Declare @Flag Int
Declare @FieldCount Int
Declare @SQL nVarchar(4000)
Set @Flag=0
Set @FieldCount=2

Create Table #TempAssetRow(RowField1 nVarchar(4000))
Create Table #TempAssetCol(ColField1 nVarchar(4000))
Create Table #TempOther(Field1 nVarchar(4000))
Create Table #TempItemRow(RowField1 nVarchar(4000))
Create Table #TempItemCol(ColField1 nVarchar(4000))
Create Table #DynamicTable(Remark nVarchar(250),Amount nvarchar(250))
--Create Table #DynamicTable(Remark Varchar(250),Amount Decimal(18,6))
Create Table #DynamicTableAsset(Serial nVarchar(250),Amount nvarchar(250))
--Create Table #DynamicTableAsset(Serial Varchar(250),Amount Decimal(18,6))
Create Table #DynamicTableItem(ItemName nVarchar(250),Qty nvarchar(250),Rate nVarchar(250),Amount nVarchar(250))
Set @COLSEP = Char(1)
Set @ROWSEP = Char(2)


If @DocRef=2 
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
				Insert #DynamicTableAsset Values(@ColField1,0)
				Set @Flag=1
				Set @Local=@ColField1
				
			End
			Else If @Flag=1
			Begin
				--Set @SQL = 'Alter Table #DynamicTable Add [DynamicField' + cast(@FieldCount as varchar) + '] Varchar(250) Null'
				--Select @SQL
				--EXEC @SQL
				--Set @SQL = 'Update #DynamicTable Set [DynamicField' + cast(@FieldCount as varchar) + '] = '' + @Field1 '''
				--EXEC @SQL
				--Select @local
				--Update #DynamicTableAsset Set Amount=Cast(@ColField1 as Decimal(18,6)) where Serial=@Local
				Update #DynamicTableAsset Set Amount=@ColField1 where Serial=@Local
				Set @Flag=2
				--Set @FieldCount=@FieldCount+1
				
			End
			  
		  	FETCH NEXT FROM scantempcol INTO @ColField1
		END
		CLOSE scantempcol
		DEALLOCATE scantempcol
		Set @Flag=0
		Set @local=Null
		Delete #TempAssetCol
	  	FETCH NEXT FROM scantemprow INTO @RowField1
	END
	CLOSE scantemprow
	DEALLOCATE scantemprow

	If @Detail = 0
	Begin
		Select Serial,Amount,5 from #DynamicTableAsset
	End
	Else
	Begin
		Select Count(*) from #DynamicTableAsset
	End

End
Else if @DocRef=1

Begin
	Insert #TempOther
	Exec Sp_acc_SQLSplit @Info,@COLSEP
	--Select * from #TempOther
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
			Update #DynamicTable Set Amount=@Field1
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
		Select count(*) from #DynamicTable
	End
	Drop Table #DynamicTable
	Drop Table #DynamicTableAsset
	Drop Table #TempOther
End
Else If @DocRef=0
Begin
	Insert #TempItemRow
	Exec Sp_acc_SQLSplit @Info,@ROWSEP
	--Select * From #TempAssetRow
	DECLARE scantemprow CURSOR KEYSET FOR
	select RowField1 from #TempItemRow 
	
	OPEN scantemprow
	FETCH FROM scantemprow INTO @RowField1
	
	WHILE @@FETCH_STATUS =0
	BEGIN

		Insert #TempItemCol
		Exec Sp_acc_SQLSplit @RowField1,@COLSEP
		--Select * from #TempAssetCol
		DECLARE scantempcol CURSOR KEYSET FOR
		select ColField1 from #TempItemCol 
		
		OPEN scantempcol
		FETCH FROM scantempcol INTO @ColField1
		
		WHILE @@FETCH_STATUS =0
		BEGIN
			If @Flag=0
			Begin
				Insert #DynamicTableItem Values(@ColField1,0,0,0)
				Set @Flag=1
				Set @Local=@ColField1
				
			End
			Else If @Flag=1
			Begin
				Update #DynamicTableItem Set Qty=@ColField1 where ItemName=@Local
				Set @Flag=2
			End
			Else If @Flag=2
			Begin
				Update #DynamicTableItem Set Rate=@ColField1 where ItemName=@Local
				Set @Flag=3
				
			End
			Else If @Flag=3
			Begin
				Update #DynamicTableItem Set Amount=@ColField1 where ItemName=@Local
				Set @Flag=4
				
			End
			  
		  	FETCH NEXT FROM scantempcol INTO @ColField1
		END
		CLOSE scantempcol
		DEALLOCATE scantempcol
		Set @Flag=0
		Set @local=Null
		Delete #TempItemCol
	  	FETCH NEXT FROM scantemprow INTO @RowField1
	END
	CLOSE scantemprow
	DEALLOCATE scantemprow

	If @Detail = 0
	Begin
		Select ItemName,Qty,Rate,Amount,5 from #DynamicTableItem
	End
	Else
	Begin
		Select count(*) from #DynamicTableItem
	End

End













