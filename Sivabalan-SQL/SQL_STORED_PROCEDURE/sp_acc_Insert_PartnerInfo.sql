CREATE Procedure [dbo].[sp_acc_Insert_PartnerInfo]  
                 (@NAME NVARCHAR (50),  
    @AGE INT,  
    @GENDER INT,  
    @SHAREOFPROFIT DECIMAL(18,6),  
    @SHAREOFLOSS DECIMAL(18,6),  
    @ADDRESS NVARCHAR(255),  
    @ITPAN NVARCHAR(50),  
    @ITGRNO NVARCHAR(50),  
    @SALARYPAYABLE INT,  
    @PHONE NVARCHAR(50),  
    @EMAIL NVARCHAR(50),  
    @DRAWINGACCOUNTFLAG INT)  
  
  
AS  
  
Declare @GroupID Int,@NewAccountID Int,@NewDrawingAccountID Int,@DRAWINGACCOUNTNAME nVarchar(250)  
  
Set @GroupID=1 -- Capital Account  
Exec sp_acc_insertaccounts @Name,@GROUPID,0  
Set @NewAccountID=@@Identity  
If @DRAWINGACCOUNTFLAG=1  
Begin  
 Set @DRAWINGACCOUNTNAME=dbo.LookupDictionaryItem('Drawing-',Default) + @Name  
 Exec sp_acc_insertaccounts @DRAWINGACCOUNTNAME,@GROUPID,0  
 Set @NewDrawingAccountID=@@Identity  
End  
  
INSERT INTO [SetupDetail]  
               (Name,  
  Age,  
  Gender,  
  ShareofProfit,  
  ShareOfLoss,  
  Address,  
  ITPAN,  
  ITGRNO,  
  SalaryPayable,  
  Phone,  
  EMail,  
  AccountID,  
  DrawingAccountID)  
Values  
                 (@NAME,  
    @AGE,  
    @GENDER,  
    @SHAREOFPROFIT,  
    @SHAREOFLOSS,  
    @ADDRESS,  
    @ITPAN,  
    @ITGRNO,  
    @SALARYPAYABLE,  
    @PHONE,  
    @EMAIL,  
    @NEWACCOUNTID,  
    @NEWDRAWINGACCOUNTID)  
  

Set Dateformat DMY
Declare @FOpeningDate Datetime

Select @FOpeningDate = OpeningDate from Setup

Begin
	IF (Select Count(GSTDateEnabled) From Setup Where isnull(GSTDateEnabled,'') = '' and isnull(LastInventoryUpload,'') = '') = 0
		Begin
			Update Setup Set GSTDateEnabled = '01/07/2017', LastInventoryUpload = OpeningDate - 1  , OldInventoryUploadDate = OpeningDate - 1 , Restore_flag = 1 Where isnull(GSTDateEnabled,'') = ''
			Update dayclosemodules Set DayCloseDate = @FOpeningDate - 1
			Update Reports_To_Upload Set LastUploadDate = @FOpeningDate - 1
	    End	 
End

