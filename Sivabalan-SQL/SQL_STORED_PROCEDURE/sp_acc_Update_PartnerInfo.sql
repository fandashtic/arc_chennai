CREATE Procedure sp_acc_Update_PartnerInfo
                 (@NAME NVARCHAR (50),
		  @AGE INT,
		  @GENDER INT,
		  @ADDRESS NVARCHAR(255),
		  @ITPAN NVARCHAR(50),
		  @ITGRNO NVARCHAR(50),
		  @SALARYPAYABLE INT,
		  @PHONE NVARCHAR(50),
		  @EMAIL NVARCHAR(50),
		  @HIDDENNAME NVARCHAR(50),
		  @ACCOUNTID INT,
                  @DRAWINGACCOUNTID INT)

AS 
UPDATE SetupDetail SET  Name=@NAME,
			Age=@AGE,
			Gender=@GENDER,
			Address=@ADDRESS,
			ITPAN=@ITPAN,
			ITGRNo=@ITGRNO,
			SalaryPayable=@SALARYPAYABLE,
			Phone=@PHONE,
			EMail=@EMAIL			
Where Name=@HIDDENNAME

If IsNull(@AccountID,0) <>0
Begin
	Update AccountsMaster Set AccountName=@Name Where AccountID = @AccountID
End
If IsNull(@DRawingAccountID,0) <>0
Begin
	Update AccountsMaster Set AccountName=dbo.LookUpdictionaryItem('Drawing-',Default) + @Name Where AccountID = @DRawingAccountID
End




