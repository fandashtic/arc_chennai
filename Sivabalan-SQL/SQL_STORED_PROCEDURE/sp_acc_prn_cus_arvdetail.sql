CREATE procedure sp_acc_prn_cus_arvdetail(@DocumentID as int)  
as  

Declare @RECORD_SEP nvarchar(10)
Declare @COLUMN_SEP nvarchar(10)

set @RECORD_SEP = Char(2)
set @COLUMN_SEP = Char(1)

Declare @Type  			nvarchar(4000)
Declare @AccountID 		nvarchar(4000)
Declare @Amount			decimal(18,6) 		
Declare @Particular		nvarchar(4000)
Declare @AccountName	nvarchar(4000)
Declare @TaxPercentage 	decimal(18,6)
Declare @TaxAmount		decimal(18,6)

Declare @RowWiseData 	nVarchar(4000)
Declare @ColWiseData 	nVarchar(4000)

Declare @particular1	nvarchar(4000)
Declare @particular2	nvarchar(4000)

Declare @AccountType	nVarchar(4000)


CREATE table #SplitRow 
(
	RowNum Int identity(1,1),
	RowData nvarchar(4000)
)

CREATE table #SplitColumn
(
	RowNum Int identity(1,1),
	ColumnData nvarchar(4000)
)

CREATE table #ArvDetails
(
	Rownum Int Identity(1,1),
	ArvType nVarchar(100),
	AccountName nVarchar(1000),
	Particular1 nvarchar(3000),
	Particular2 nvarchar(3000),
	Amount decimal(18,6),
	Tax		decimal(18,6),
	TaxAmount decimal(18,6),
	NetAmount decimal(18,6)
)

DECLARE CursorArvDetail CURSOR for 
	select Type, AccountID, Amount, Particular,dbo.getaccountname(AccountID),TaxPercentage,TaxAmount from ARVDetail  
	where DocumentID = @DocumentID  

	Open CursorArvDetail

		FETCH FROM CursorArvDetail into 
		@Type,@AccountID ,@Amount,@Particular,@AccountName,@TaxPercentage ,@TaxAmount
        


		WHILE @@FETCH_STATUS =0        
			BEGIN        
				/* Before Splitting the Details , insert the Main Row */
				if cast(@type as numeric) = 1 
					begin
						set @AccountType = dbo.LookupDictionaryItem('Others',Default)
					end
				else if cast(@type as numeric) = 0
					begin
						set @AccountType = dbo.LookupDictionaryItem('Asset',Default)
					end
				else if cast(@type as numeric) = 3
					begin
						set @AccountType = dbo.LookupDictionaryItem('Credit Card',Default)
					end
				else if cast(@type as numeric) = 4 
					begin
						set @AccountType = dbo.LookupDictionaryItem('Coupon',Default)
					end
	
				Insert into #ArvDetails
				values(@AccountType, @AccountName, dbo.LookupDictionaryItem('<Detail>',Default),'', @Amount, @TaxPercentage, @TaxAmount,
					@Amount + @TaxAmount)

				/* first split the records Row Wise */
				truncate table #splitrow
				insert into #splitrow
				exec sp_acc_sqlsplit @particular,@RECORD_SEP


				/* after splitting into separate Records , Split it into colum wise */
				Declare CursorRowData Cursor for
					Select RowData from #splitrow order by RowNum

					Open CursorRowData 
						Fetch From CursorRowData into @RowWiseData
						
						While @@Fetch_Status = 0
 							Begin
								/* First Truncate the Table every time , to avoid Appending */
								Truncate table #SplitColumn
								insert into #SplitColumn
								exec sp_acc_sqlsplit @RowWiseData,@COLUMN_SEP
								
								/* insert into Main Table */
								/* Before Splitting the Details , insert the Main Row */
								/* For Details Part , Basis the ARV Type , different columns
									has to be inserted */
								if @type = 1 --Others
									begin
										select @particular1 = columndata from #SplitColumn 
										where Rownum = 1
										select @particular2 = columndata from #SplitColumn 
										where Rownum = 2
									end
								else if @type = 0 --Asset
									begin
										select @particular1 = columndata from #SplitColumn 
										where Rownum = 2
										select @particular2 = columndata from #SplitColumn 
										where Rownum = 3
									end
								else if (@type = 3) or  (@type = 4) --Credit Card or Coupoun
									begin
										select @particular1 = columndata from #SplitColumn 
										where Rownum = 4
										select @particular2 = columndata from #SplitColumn 
										where Rownum = 7

									end
								--select @particular1,@particular2
								Insert into #ArvDetails
								values('','',@particular1,@particular2,null, null, null,null)
								Fetch Next From CursorRowData into @RowWiseData 
							End
				
					Close CursorRowData
					Deallocate CursorRowData
			
				FETCH Next from CursorArvDetail into 
				@Type,@AccountID ,@Amount,@Particular,@AccountName,@TaxPercentage ,@TaxAmount
			end

close CursorArvDetail
deallocate CursorArvDetail

select 
	"ARV Type" = ArvType,
	"Account Name" = AccountName,
	"Particular 1" = Particular1,
	"Particular 2" = Particular2,
	"Amount" = Amount,
	"Tax(%)" = Tax,
	"Tax Amount" = TaxAmount,
	"Net Amount" = NetAmount
from #arvdetails
Order by 
	Rownum



drop table #splitrow
drop table #SplitColumn
drop table #ArvDetails


