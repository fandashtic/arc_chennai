Create Procedure mERP_SP_ProcessCLOCRNOTE
AS
BEGIN
Declare @CLOCRID int
SET Dateformat DMY
BEGIN Tran
Create Table #tmpRecDoc(RecDocID int)
/*
Create Table #Recd_CLOCrNote(
ID int,
RecdDocID Int,
CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CLOType nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
CLOMonth nvarchar(8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
Amount decimal(18,6) NOT NULL,
RefNumber nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
Active int not null,
CLODate datetime)
*/
/* Records to be processed */
Insert into #tmpRecDoc(RecDocID)
Select ID from RecdDoc_CLOCrNote where isnull(status,0)=0
/*
Insert into #Recd_CLOCrNote(ID,RecdDocID,CustomerID,CLOType,CLOMonth,Amount,RefNumber,Active,CLODate)
Select ID,RecdDocID,CustomerID,CLOType,CLOMonth,Amount,RefNumber,Active,dbo.fn_ReturnDateforPeriod(CLOMonth) from Recd_CLOCrNote
where RecdDocID in (select ID from #tmpRecDoc)
And isnull(status,0)=0
*/
Declare @RecDocId int
Declare @DayCloseMonth datetime
Declare @DaycloseDate Datetime
Declare @ErrorMsg as nvarchar(400)
Declare @MaxLoyaltyID int

Declare @ID int
Declare @CLORecDocId int
Declare @CustomerID nvarchar(15)
Declare @CLOType nvarchar(15)
Declare @CLOMonth nvarchar(8)
Declare @Amount decimal(18,6)
Declare @RefNumber nvarchar(50)
Declare @Active int
Declare @CLODate Datetime
Declare @Category nvarchar(255)
Declare @PrintFlag integer

Select Top 1 @DaycloseDate=isnull(Lastinventoryupload,getdate()) from Setup
Select Top 1 @DayCloseMonth='01/'+cast(month(isnull(Lastinventoryupload,getdate())) as nvarchar(10))+'/'+cast(year(isnull(Lastinventoryupload,getdate())) as nvarchar(10)) from Setup
/* If last day of the month is closed then we should consider next month only*/
If DAY(@DaycloseDate+1) = 1
set @DayCloseMonth=dateadd(m,1,@DayCloseMonth)

Declare AllDocs cursor For Select RecDocID from #tmpRecDoc
Open AllDocs
Fetch from AllDocs into @RecDocId
While @@fetch_status=0
BEGIN
Set @MaxLoyaltyID=0
Declare CreditNote cursor for Select ID,RecdDocID,CustomerID,CLOType,CLOMonth,Amount,RefNumber,Active,dbo.fn_ReturnDateforPeriod(CLOMonth),isnull(Category,''),PrintFlag from Recd_CLOCrNote
where isnull(status,0)=0
And RecdDocId=@RecDocId
Open CreditNote
Fetch from CreditNote into @ID,@CLORecDocId,@CustomerID,@CLOType,@CLOMonth,@Amount,@RefNumber,@Active,@CLODate,@Category,@PrintFlag
While @@fetch_status=0
BEGIN
/* Validating CLO Month is valid*/
if Len(Ltrim(Rtrim(@CLOMonth))) <> 8
BEGIN
Set @ErrorMsg = ''
Set @ErrorMsg='Credit Note month ('+cast(@CLOMonth as nvarchar(10))+ ') is invalid'
Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
update R set Status = 2,modifieddate=getdate() From Recd_CLOCrNote R
Where R.ID =@ID And
isnull(status,0)=0
GOTO NextDoc
END
/* Validating CLO Month is a month*/
If isDate(Cast(('01' + '-' + @CLOMonth) as nVarchar(15))) = 0
BEGIN
Set @ErrorMsg = ''
Set @ErrorMsg='Credit Note month ('+cast(@CLOMonth as nvarchar(10))+ ') is not in correct format'
Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
update R set Status = 2,modifieddate=getdate() From Recd_CLOCrNote R
Where R.ID =@ID And
isnull(status,0)=0
GOTO NextDoc
END
/* Validating Credit note month*/
If @DayCloseMonth > @CLODate
BEGIN
Set @ErrorMsg = ''
Set @ErrorMsg='Credit Note month ('+cast(@CLOMonth as nvarchar(10))+ ') is lesser than last day close date ('+cast(Convert(Nvarchar(10),@DaycloseDate,103) as nvarchar(15))+')'
Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
update R set Status = 2,modifieddate=getdate() From Recd_CLOCrNote R
Where R.ID =@ID And
isnull(status,0)=0
GOTO NextDoc
END
/* Validating CLO type*/
if @CLOType in ('All Loyalty Program','First Club','Shubh labh')
BEGIN
Set @ErrorMsg = ''
Set @ErrorMsg='CLO type ('+cast(@CLOType as nvarchar(255))+ ') can not be [All Loyalty Program], [First Club] and [Shubh labh]'
Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
update R set Status = 2,modifieddate=getdate() From Recd_CLOCrNote R
Where R.ID =@ID And
isnull(status,0)=0
GOTO NextDoc
END
/* Validating Customer */
If not exists (select 'x' from customer where customerid =@CustomerID)
BEGIN
Set @ErrorMsg = ''
Set @ErrorMsg='Customer ('+cast(@CustomerID as nvarchar(15))+ ') is not exists in the database'
Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
update R set Status = 2,modifieddate=getdate() From Recd_CLOCrNote R
Where R.ID =@ID And
isnull(status,0)=0
GOTO NextDoc
END
--			If exists (select 'x' from customer where customerid =@CustomerID and isnull(active,0)=0)
--			BEGIN
--				Set @ErrorMsg = ''
--				Set @ErrorMsg='Warning: Customer ('+cast(@CustomerID as nvarchar(15))+ ') is deactivated but still CLO will be processed'
--				Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
--			END
If exists (select 'x' from customer where customerid =@CustomerID and isnull(active,0)=0)
BEGIN
Set @ErrorMsg = ''
Set @ErrorMsg='Customer ('+cast(@CustomerID as nvarchar(15))+ ') is deactivated'
Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
update R set Status = 2,modifieddate=getdate() From Recd_CLOCrNote R
Where R.ID =@ID And	isnull(status,0)=0
GOTO NextDoc
END

/* Validating Division in Category Master */

--			IF isnull(@Category,'') = ''
--			BEGIN
--				Set @ErrorMsg = ''
--				Set @ErrorMsg='Category is empty'
--				Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
--				Update R Set Status = 2,modifieddate=getdate() From Recd_CLOCrNote R
--				Where R.ID =@ID And	isnull(Status,0)=0
--				GOTO NextDoc
--			END

--IF Not Exists(Select 'x' From ItemCategories Where Category_Name=@Category And Level = 2)

--			IF Exists(Select ItemValue From dbo.sp_SplitIn2Rows(@Category,'|')
--						Where ItemValue not in (Select Category_Name From ItemCategories Where Level = 2))
--			BEGIN
--				Set @ErrorMsg = ''
--				Set @ErrorMsg='Category not exists in Category master'
--				Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
--				Update R Set Status = 2,modifieddate=getdate() From Recd_CLOCrNote R
--				Where R.ID =@ID And	isnull(Status,0)=0
--				GOTO NextDoc
--			END
--
--			--IF Exists(Select 'x' From ItemCategories Where Category_Name=@Category And Level = 2 and isnull(Active,0) = 0)
--
--			IF Exists(Select ItemValue From dbo.sp_SplitIn2Rows(@Category,'|')
--						Where ItemValue in (Select Category_Name From ItemCategories Where Level = 2 and isnull(Active,0) = 0))
--			BEGIN
--				Set @ErrorMsg = ''
--				Set @ErrorMsg='Category is not active'
--				Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
--				Update R Set Status = 2,modifieddate=getdate() From Recd_CLOCrNote R
--				Where R.ID =@ID And	isnull(Status,0)=0
--				GOTO NextDoc
--			END

/* Validating Credit Note Generation*/
If exists(Select 'x' from CLOCrNote where CustomerID=@CustomerID And CLOType=@CLOType And CLOMonth=@CLOMonth And RefNumber=@RefNumber and IsGenerated=1)
BEGIN
Set @ErrorMsg = ''
Set @ErrorMsg='Credit Note already generated for  ('+cast(@CustomerID as nvarchar(15))+ ') and RefNumber ('+@RefNumber+')'
Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg
update R set Status = 2,modifieddate=getdate() From Recd_CLOCrNote R
Where R.ID =@ID And
isnull(status,0)=0
GOTO NextDoc
END

IF Not Exists(Select 'x' From Loyalty Where LoyaltyName=@CLOType)
BEGIN
Create Table #tmpMaxID(ID int)
Insert Into #tmpMaxID(ID)
Select SubString(LoyaltyID,2,Len(LoyaltyID)) From Loyalty
Select @MaxLoyaltyID=Max(ID)+1 From #tmpMaxID
Insert Into Loyalty(LoyaltyID,LoyaltyName)
Select 'L'+cast(@MaxLoyaltyID as nvarchar(20)),@CLOType
Drop Table #tmpMaxID
END

/* Deleting the existing data*/
Delete From CLOCrNote where CustomerID=@CustomerID And CLOType=@CLOType And CLOMonth=@CLOMonth And RefNumber=@RefNumber and IsGenerated=0

/* Processing the valid data */
Insert Into CLOCrNote(RecdDocID,CustomerID,CLOType,CLOMonth,Amount,RefNumber, Active,IsGenerated,CLODate,Category,PrintFlag)
Select @CLORecDocId,@CustomerID,@CLOType,@CLOMonth,@Amount,@RefNumber,@Active,0,@CLODate,isnull(@Category,''),@PrintFlag

Select @CLOCRID = @@IDENTITY
IF Isnull(@Active,0) = 1
Exec sp_AutoGenerate_CLOCreditNote @CLOCRID

Set @ErrorMsg = ''
Set @ErrorMsg='Credit Note processed for  ('+cast(@CustomerID as nvarchar(15))+ ') and RefNumber ('+@RefNumber+') and CLOMonth('+@CLOMonth+ ')'
Exec mERP_sp_Update_CLOCRNOTEErrorStatus @RecDocId, @ErrorMsg

Update Recd_CLOCrNote Set Status =1 Where ID=@ID

NextDoc:
Fetch Next From CreditNote into @ID,@CLORecDocId,@CustomerID,@CLOType,@CLOMonth,@Amount,@RefNumber,@Active,@CLODate,@Category,@PrintFlag
END
Close CreditNote
Deallocate CreditNote
Update RecdDoc_CLOCrNote set status =1 where ID=@RecDocId
Fetch Next from AllDocs into @RecDocId
END
Close AllDocs
Deallocate AllDocs

Drop Table #tmpRecDoc
Commit Tran
END
