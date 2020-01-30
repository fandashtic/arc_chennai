CREATE Procedure sp_SCR_OpeningDetail_UpdateDC
As

--To update OpeningDetails

Declare @OpeningDate Datetime
Declare @ProductCode nVarchar(30)
Declare @OpeningQty  Decimal(18, 6)
Declare @OpeningValue Decimal(18, 6)

Declare @MaxDate Datetime
Declare @Date Datetime
Declare @ExecSCR Int
Declare @OpenDate1 DateTime
Declare @OpenDate2 DateTime

set dateformat dmy

select @OpenDate1 = max(Opening_Date) from OpeningDetails 
select @OpenDate2 = max(Opening_Date) from OpeningDetails_SCRReport  

if (@OpenDate1 > @OpenDate2 )
	Insert into OpeningDetails_SCRReport select * from OpeningDetails where Opening_Date > @OpenDate2

Select @ExecSCR = 0
If (Select IsNull(Flag, 0) From tblConfigDC Where ProcessName='SCRDC' and Flag = 1) = 1
	Set @ExecSCR = 1

If @ExecSCR = 0
	GoTo OvernOut	


Select top 1 @OpeningDate = OpeningDate From Setup

--Updating opening details

 if (select count(*) from tmpDamage where flag=0) >=1
 Begin
	Delete from OpeningDetails where product_code in (select Product_code from tmpDamage where flag=0)
	Insert into OpeningDetails select * from OpeningDetails_SCRReport where Product_code in (select Product_code from tmpDamage where flag=0) 
 ENd


Declare OpeningCur  Cursor For select Product_Code, UpdQty, UpdValue from tmpDamage where flag=0
Open OpeningCur
Fetch From OpeningCur Into @ProductCode, @OpeningQty, @OpeningValue
While @@Fetch_Status = 0
	Begin		
		Update OpeningDetails Set Opening_Quantity = IsNull(Opening_Quantity, 0) + @OpeningQty, 
									Opening_Value = IsNull(Opening_Value, 0) + @OpeningValue,
									Damage_Opening_Quantity = IsNull(Damage_Opening_Quantity, 0) + @OpeningQty,
									Damage_Opening_Value = IsNull(Damage_Opening_Value, 0) + @OpeningValue
				Where Product_Code = @ProductCode
					And Opening_Date = @OpeningDate

		Select @MaxDate = Max(Opening_Date) From OpeningDetails where Product_Code = @ProductCode
		
		Exec FixOpening_BPTemp_PreSet @ProductCode,@OpeningDate,@MaxDate
		
		Declare Cur  Cursor For
		Select Opening_Date from OpeningDetails where Product_Code = @ProductCode Order By Opening_Date
		Open Cur
		Fetch From Cur Into @Date
		While @@Fetch_Status = 0
			Begin						
				IF @MaxDate = @Date
				exec FixOpening_Itemwise_Datewise @ProductCode, @Date, 1
				Else
				exec FixOpening_Itemwise_Datewise @ProductCode, @Date, 0
				
				Fetch Next From Cur Into @Date
			End
		Close Cur
		Deallocate Cur		
		Update tmpDamage set flag=1 where product_Code = @ProductCode
		Fetch Next From OpeningCur Into @ProductCode, @OpeningQty, @OpeningValue
	End
Close OpeningCur
Deallocate OpeningCur

Update tblconfigDC Set Flag = 0 Where Flag = 1 and ProcessName='SCRDC'

OvernOut:
   
